extends SceneTree

const RUN = preload("res://src/run/vertical_slice_run_state.gd")
const RESULT = preload("res://src/run/vertical_slice_result_model.gd")
const CODEC = preload("res://src/run/run_checkpoint_codec.gd")
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func check(value: bool, label: String) -> void:
    checks += 1
    if not value:
        failures.append(label)
        push_error(label)

func _run() -> void:
    var model = RESULT.new()
    var all_ids: Array = load("res://src/combat/martial_manual_registry.gd").new().get_manual_ids()
    for id in all_ids:
        var opponent := {"signature_manual_id": id}
        var choices: Array = model.build_reward_options(all_ids, opponent)
        check(choices[2].get("available", true) == false, "owned transfer unavailable: " + id)
        check(choices[2].get("unavailable_reason_key", "") == "ALREADY_OWNED", "owned reason: " + id)
        check(choices[0].get("available", false) and choices[1].get("available", false), "other rewards available")
        check(model.build_reward_receipt("faction_transfer", "", all_ids, opponent).is_empty(), "builder rejects duplicate")
        var without := all_ids.duplicate()
        without.erase(id)
        check(not model.build_reward_receipt("faction_transfer", "", without, opponent).is_empty(), "new transfer preserved")
    for version in [1, 2, 3, 4]:
        var run = _result_run(version)
        if run == null: continue
        var original: Dictionary = run.export_snapshot()
        var old_receipt := {"reward_type":"faction_transfer", "manual_id":run.get_current_opponent().signature_manual_id,
            "mastery":3, "target_manual_id":"", "application_status":"DEFERRED_TO_PHASE_V"}
        check(not run.set_pending_result_reward(old_receipt), "domain rejects duplicate v%d" % version)
        check(run.export_snapshot() == original, "rejected duplicate changes nothing")
        # Historical fixture bypasses the current command to represent an already saved selection.
        run._pending_result_reward = old_receipt.duplicate(true)
        var encoded: Dictionary = CODEC.new().encode("duplicate" if version > 1 else "historical-duplicate", "pending", 1, run.export_snapshot())
        check(encoded.ok, "historical pending remains encodable v%d: %s" % [version, str(encoded.get("error", ""))])
        if not encoded.ok: continue
        var restored = RUN.new()
        check(restored.import_snapshot(CODEC.new().decode(encoded.text).payload.run_state).ok, "historical pending restores")
        var before: Dictionary = restored.get_progression_snapshot()
        check(restored.advance(), "historical pending still confirms")
        var after: Dictionary = restored.get_progression_snapshot()
        check(after.free_training_pool == before.free_training_pool and after.mastery_by_manual == before.mastery_by_manual, "no retrospective compensation")
        check(after.pending_duplicate_transfers.size() == 1, "historical record preserved once")
        check(restored.validate_snapshot(restored.export_snapshot()).ok, "historical confirmed ledger validates")
        var no_resources: Dictionary = restored.export_snapshot()
        no_resources.last_combat_result.erase("player_resources")
        var old_route = RUN.new()
        check(old_route.import_snapshot(no_resources).ok, "legacy optional resource omission restores")
        var route_id: String = old_route.get_jianghu_options()[0].id
        var expected_route: Dictionary = old_route.get_jianghu_effect_view(route_id)
        check(old_route.select_jianghu_node(route_id, 0), "legacy route applies")
        var old_view: Dictionary = old_route.get_jianghu_effect_view(route_id, true)
        check(not old_view.is_empty() and not old_view.get("resource_delta_known", true), "unknown historical recovery is explicit")
        check(old_view.get("free_training", -1) == expected_route.free_training, "known legacy training amount retained")
        var reload_route = RUN.new()
        check(reload_route.import_snapshot(old_route.export_snapshot()).ok and reload_route.get_jianghu_effect_view(route_id, true) == old_view, "legacy result explanation survives reload")
        check(not restored.set_pending_result_reward(old_receipt), "late repeated command rejected")
        var fresh = _result_run(version)
        if fresh == null: continue
        var bad := {"reward_type":"free_training", "free_training":999, "focused_training":0}
        check(not fresh.set_pending_result_reward(bad), "forged reward rejected before persistence")
        check(fresh.get_pending_result_reward().is_empty(), "invalid reward does not lock choice")
        check(fresh.set_pending_result_reward(model.build_reward_receipt("free_training", "", fresh.get_owned_player_manuals(), fresh.get_current_opponent())), "valid alternative remains selectable")
        var pool_before: int = fresh.get_progression_snapshot().free_training_pool
        check(fresh.advance() and fresh.get_progression_snapshot().free_training_pool == pool_before + 6, "alternative applies exactly six")
    print("REWARD_AVAILABILITY checks=%d failures=%d" % [checks, failures.size()])
    quit(0 if failures.is_empty() else 1)

func _result_run(version: int):
    var run = RUN.new()
    if version == 1:
        run.configure_opponents(load("res://src/run/vertical_slice_opponent_catalog.gd").new(), 42)
        run.start_new_run()
    elif version == 2: run.start_new_variable_run(34, "duplicate")
    elif version == 3: run.start_new_growth_run(34, "duplicate")
    else: run.start_new_stats_run(34, "duplicate")
    var starters: Array = load("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0,4)
    var mastery := {}
    for id in starters: mastery[id] = 3
    var allocation: Dictionary = load("res://src/run/player_growth_state.gd").new().recommended_allocation(starters) if version == 4 else {}
    var setup_ok: bool = run.confirm_setup_loadout(starters, mastery, allocation)
    check(setup_ok, "setup v%d" % version)
    if not setup_ok: return null
    # Find the first opponent whose signature is already owned without altering its roster.
    for duel in range(1,11):
        for step in range(3):
            if run.get_current_screen() == "COMBAT": break
            check(run.advance(), "advance to combat")
        if run.get_current_screen() != "COMBAT":
            check(false, "bounded fixture must reach combat")
            return null
        check(run.mark_combat_finished({"outcome":"win", "player_health":30,"enemy_health":0,"player_resources":run.get_player_run_resources()}), "synthetic domain terminal")
        check(run.advance(), "review to result")
        if run.get_current_opponent().signature_manual_id in run.get_owned_player_manuals(): return run
        check(run.set_pending_result_reward(RESULT.new().build_reward_receipt("free_training", "", run.get_owned_player_manuals(), run.get_current_opponent())), "interim reward")
        check(run.advance(), "interim confirm")
        for step in range(4):
            check(run.select_jianghu_node(run.get_jianghu_options()[0].id, step), "interim route")
            check(run.advance(), "interim route advance")
    return run
