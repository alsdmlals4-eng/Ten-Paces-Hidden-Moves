extends SceneTree

const RunScript := preload("res://src/run/vertical_slice_run_state.gd")
const EngineScript := preload("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd")
const CatalogScript := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const BindingScript := preload("res://src/run/vertical_slice_opponent_runtime_binding.gd")
const STARTERS := ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func check(value: bool, message: String) -> void:
    if not value: failures.append(message)

func _run() -> void:
    var run = RunScript.new()
    var engine = EngineScript.new()
    if not run.has_method("select_bimu_constraints") or not engine.has_method("configure_bimu_constraints"):
        push_error("Missing run lifecycle and engine constraint integration")
        quit(1)
        return
    _lifecycle(run)
    _engine_guards(engine)
    _overlays()
    await _bridge_handoff()
    if failures.is_empty():
        print("BIMU_CONSTRAINT_RUNTIME_OK")
    else:
        for failure in failures: push_error(failure)
    quit(0 if failures.is_empty() else 1)

func _briefing(run) -> void:
    run.configure_opponents(CatalogScript.new(), 42)
    run.start_new_run()
    var mastery := {}
    for id in STARTERS: mastery[id] = 3
    check(run.confirm_setup_loadout(STARTERS, mastery), "setup loadout")
    run.advance()
    run.advance()

func _lifecycle(run) -> void:
    _briefing(run)
    var selection := [{"constraint_id": "CST_TECH_RESPONSE_SEAL"}]
    check(run.select_bimu_constraints(selection), "valid selection")
    selection.clear()
    check(run.get_pending_bimu_constraints().size() == 1, "pending deep copy")
    var before: Array = run.get_pending_bimu_constraints()
    check(not run.select_bimu_constraints([{"constraint_id": "wrong"}]), "invalid selection rejects")
    check(run.get_pending_bimu_constraints() == before, "invalid selection atomic")
    check(run.advance(), "briefing freezes")
    var receipt: Dictionary = run.get_frozen_bimu_receipt()
    check(receipt.get("duel_index") == 1 and receipt.get("enemy_candidate_id") == "slot1_dogyeom", "duel identity frozen")
    check(not run.select_bimu_constraints([]), "combat selection locked")
    var malformed: Dictionary = run.get("_pre_battle_snapshot").duplicate(true)
    malformed["bimu_receipt"]["duel_index"] = 99
    var progression: Dictionary = run.get_progression_snapshot()
    check(not run.call("_restore_pre_battle_snapshot", malformed), "wrong duel snapshot rejects")
    check(run.get_progression_snapshot() == progression and run.get_frozen_bimu_receipt() == receipt, "invalid retry atomic")
    run.mark_combat_finished({"outcome": "loss"})
    run.advance()
    check(run.retry_failed_duel(), "retry accepted")
    check(run.get_frozen_bimu_receipt() == receipt, "retry same receipt")
    run.mark_combat_finished({"outcome": "win"})
    run.advance()
    run.set_pending_result_reward({"reward_type": "free_training", "free_training": 6})
    run.advance()
    for step in 4:
        run.select_jianghu_node(str(run.get_jianghu_options()[0]["id"]), step)
        run.advance()
    check(run.get_current_screen() == "BRIEFING" and run.get_pending_bimu_constraints().is_empty() and run.get_frozen_bimu_receipt().is_empty(), "next duel reset")
    check(run.advance() and run.get_frozen_bimu_receipt().get("selections") == [], "zero selection valid")
    run.mark_combat_finished({"outcome": "loss"})
    run.advance()
    run.end_failed_run()
    run.start_new_run()
    check(run.get_frozen_bimu_receipt().is_empty() and run.get_pending_bimu_constraints().is_empty(), "new run reset")

func _engine_guards(engine) -> void:
    var mastery := {}
    for id in STARTERS: mastery[id] = 10
    check(engine.configure_bimu_constraints([{"constraint_id": "CST_TECH_MANUAL_SEAL", "target_manual_id": STARTERS[0]}], STARTERS, [STARTERS[1]]), "engine selection binds")
    engine.configure_martial_loadouts(STARTERS, mastery, [STARTERS[1]], {STARTERS[1]: 3})
    var state: Dictionary = engine.make_initial_state(_hud(), 4, 6)
    state["ai_enabled"] = true
    var blocked_id := ""
    for id in engine.get_player_martial_card_ids():
        if engine.cards_by_id[id].get("manual_id") == STARTERS[0]:
            blocked_id = id
            break
    check(not blocked_id.is_empty(), "real registry blocked ID exists")
    var forged := {"card_id": blocked_id, "anchor_index": 1, "span": 1, "definition": {"id": blocked_id, "source": "basic", "manual_id": "fake", "action_slots": 1}}
    var before := state.duplicate(true)
    var trace: Dictionary = engine.ai_planner.get_last_trace()
    check(not engine.preview_player_plan(state, [forged]).get("valid", true), "preview rejects forged definition")
    var result: Dictionary = engine.resolve_bundle([forged], {"bundle_index": 1}, state)
    check(result.get("rejected", false) and result.get("state") == before, "bundle rejects without time resource metrics mutation")
    check(state == before and engine.ai_planner.get_last_trace() == trace, "rejection leaves input and enemy planner unchanged")
    engine.lock_enemy_bundle(state, 1)
    var locked: Array = engine.get("_locked_enemy_actions").duplicate(true)
    var locked_state := state.duplicate(true)
    result = engine.resolve_bundle([forged], {"bundle_index": 1}, state)
    check(result.get("state") == locked_state and engine.get("_locked_enemy_actions") == locked, "rejection preserves already locked enemy plan")
    check(not engine.resolve_martial_card(blocked_id, state, "player").get("completed", true), "direct martial guard")
    check(engine.get_action_lock_reason("basic_meditate").is_empty(), "base action allowed")
    check(not engine.configure_bimu_constraints([{"constraint_id": "CST_TECH_MANUAL_SEAL", "target_manual_id": "fake"}], STARTERS, [STARTERS[1]]), "forged target rejected")
    check(not engine.get_action_lock_reason(blocked_id).is_empty(), "invalid bind preserves prior constraints")
    var all_ids: Array = Array(engine.martial_registry.get_manual_ids())
    for id in all_ids: mastery[id] = 10
    engine.configure_martial_loadouts(all_ids, mastery, [STARTERS[1]], {STARTERS[1]: 3})
    for seal in ["CST_TECH_ULTIMATE_SEAL", "CST_TECH_RESPONSE_SEAL", "CST_TECH_RECOVERY_SEAL", "CST_TECH_MULTI_SLOT_SEAL"]:
        check(engine.configure_bimu_constraints([{"constraint_id": seal}], all_ids, [STARTERS[1]]), "seal binds " + seal)
        var matches := 0
        for id in engine.get_player_martial_card_ids():
            if engine.get_action_lock_reason(id).is_empty(): continue
            matches += 1
            var forged_action := {"card_id": id, "definition": {"id": "basic_meditate", "source": "basic"}, "anchor_index": 1}
            check(not engine.preview_player_plan(state, [forged_action]).get("valid", true), "seal preview " + seal)
            check(engine.resolve_bundle([forged_action], {}, state).get("rejected", false), "seal resolver " + seal)
        check(matches > 0, "real card selector reaches " + seal)
        for id in engine.cards_by_id:
            if engine.cards_by_id[id].get("source") != "martial_manual":
                check(engine.get_action_lock_reason(id).is_empty(), "base and base ultimate exempt")

func _overlays() -> void:
    var catalog = CatalogScript.new()
    var candidate: Dictionary = catalog.get_candidate("slot1_dogyeom")
    var original := candidate.duplicate(true)
    var binding: Dictionary = BindingScript.new().build(candidate)
    var enemy_id: String = candidate["signature_manual_id"]
    var mastery := {enemy_id: int(candidate["signature_star_seed"])}
    for selection in [
        [{"constraint_id": "CST_ENEMY_START_MOMENTUM_1"}],
        [{"constraint_id": "CST_ENEMY_RESOURCE_SURPLUS"}],
        [{"constraint_id": "CST_ENEMY_STAT_DISCIPLINE", "target_stat_key": "external"}],
        [{"constraint_id": "CST_ENEMY_MASTERED_MANUAL", "target_enemy_manual_id": enemy_id}]
    ]:
        var engine = EngineScript.new()
        check(engine.configure_bimu_constraints(selection, STARTERS, [enemy_id]), "overlay selection validates")
        check(engine.configure_enemy_runtime_binding(binding), "base binding validates before overlay")
        var boosted: Dictionary = engine.get_bimu_enemy_mastery(mastery)
        engine.configure_martial_loadouts(STARTERS, {}, [enemy_id], boosted)
        var hud := _hud()
        hud["enemy"]["stamina"] = [1, 5]
        hud["enemy"]["internal"] = [1, 5]
        hud["enemy"]["start_penalties"] = {"stamina": 4, "internal": 4}
        var state: Dictionary = engine.make_initial_state(hud, 4, 6)
        check(state == engine.make_initial_state(hud, 4, 6), "overlay never accumulates")
        match selection[0]["constraint_id"]:
            "CST_ENEMY_START_MOMENTUM_1": check(state["enemy"]["momentum"][0] == 1, "momentum reaches engine")
            "CST_ENEMY_RESOURCE_SURPLUS": check(state["enemy"]["stamina"][0] == 2 and state["enemy"]["internal"][0] == 2, "resources reach engine")
            "CST_ENEMY_STAT_DISCIPLINE": check(state["enemy"]["stats"]["external"] == binding["stats"]["external"] + 1, "stats overlay after binding")
            "CST_ENEMY_MASTERED_MANUAL":
                check(boosted[enemy_id] == mini(10, mastery[enemy_id] + 2), "mastery boost")
                var expected: Dictionary = engine.martial_registry.build_loadout_cards([enemy_id], boosted)
                var actual_ids: Array = engine.get_enemy_martial_card_ids()
                var expected_ids: Array = expected.keys()
                actual_ids.sort()
                expected_ids.sort()
                check(actual_ids == expected_ids, "boosted registry exact unlock IDs reach engine")
    check(candidate == original and catalog.get_candidate("slot1_dogyeom") == original, "catalog immutable")

func _hud() -> Dictionary:
    return JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))

func _bridge_handoff() -> void:
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    _briefing(shell.run_state)
    var selection := [{"constraint_id": "CST_TECH_RESPONSE_SEAL"}, {"constraint_id": "CST_ENEMY_START_MOMENTUM_1"}]
    check(shell.run_state.select_bimu_constraints(selection), "shell selection")
    shell.run_state.advance()
    await process_frame
    var bridge = shell.combat_host.get_child(0)
    var receipt: Dictionary = shell.run_state.get_frozen_bimu_receipt()
    check(bridge.get_vertical_slice_loadout_snapshot().get("bimu_receipt") == receipt, "shell passes frozen receipt")
    check(bridge.combat_state["enemy"]["momentum"][0] == 1, "shell engine consumes receipt")
    # Inject an otherwise complete plan with stale readiness, then prove the native
    # commit consumer rechecks the engine before changing presentation or counters.
    var sealed_id := ""
    for id in bridge.resolution_engine.get_player_martial_card_ids():
        if not bridge.resolution_engine.get_action_lock_reason(id).is_empty():
            sealed_id = id
            break
    check(not sealed_id.is_empty(), "shell has a sealed owned response")
    var panel = bridge.action_timing_panel
    var prior_placements: Dictionary = panel.placements.duplicate(true)
    panel.placements = {1: {"card_id": sealed_id, "definition": {"id": sealed_id, "source": "basic"}, "anchor_index": 1, "span": 3, "target_ready": true, "resource_ready": true}}
    panel.resource_plan_valid = true
    for index in range(1, 4):
        panel.get_slot(index).set_assignment({"id": sealed_id}, 1, 3, index - 1)
    check(panel.is_current_bundle_complete() and not bridge.call("_inputs_locked"), "stale forged plan fixture can reach native commit")
    var progress_count: int = bridge.get("_progress_request_count")
    var presentation: String = bridge.get("_presentation_state")
    bridge.call("_on_progress_requested", {"bundle_index": 1})
    check(bridge.get("_progress_request_count") == progress_count and bridge.get("_presentation_state") == presentation, "commit guard rejects before presentation and time mutation")
    panel.placements = prior_placements
    for index in range(1, 4): panel.get_slot(index).clear_assignment()
    var snapshot: Dictionary = bridge.get_vertical_slice_loadout_snapshot()
    var before: Dictionary = bridge.combat_state.duplicate(true)
    var original_engine = bridge.resolution_engine
    var bad := {"valid": true, "enemy_candidate_id": snapshot["enemy_candidate_id"], "selections": [{"constraint_id": "CST_ENEMY_MASTERED_MANUAL", "target_enemy_manual_id": "forged"}]}
    check(not bridge.configure_vertical_slice_loadouts(snapshot["player_loadout"], snapshot["player_mastery_by_manual"], snapshot["enemy_loadout"], snapshot["enemy_mastery_by_manual"], snapshot["enemy_candidate_id"], snapshot["enemy_runtime_binding"], {}, bad), "bridge revalidates forged valid flag")
    check(bridge.combat_state == before and bridge.resolution_engine == original_engine and bridge.get_vertical_slice_loadout_snapshot() == snapshot, "bridge reject atomic")
    for _repeat in 2:
        check(bridge.configure_vertical_slice_loadouts(snapshot["player_loadout"], snapshot["player_mastery_by_manual"], snapshot["enemy_loadout"], snapshot["enemy_mastery_by_manual"], snapshot["enemy_candidate_id"], snapshot["enemy_runtime_binding"], {}, receipt), "bridge repeated bind")
        check(bridge.combat_state["enemy"]["momentum"][0] == 1, "bridge overlay not cumulative")
    shell.queue_free()
    await process_frame
