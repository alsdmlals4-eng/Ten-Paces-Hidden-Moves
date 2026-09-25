extends SceneTree
## A recorded-win fixture exercises rewards and the next actual combat binding.
const RUN = preload("res://src/run/vertical_slice_run_state.gd")
const STARTER = preload("res://src/run/vertical_slice_starter_manual_catalog.gd")
const RESULT = preload("res://src/run/vertical_slice_result_model.gd")
const BRIDGE = preload("res://src/run/frame_combat_bridge.gd")
const CODEC = preload("res://src/run/run_checkpoint_codec.gd")
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
    var run = RUN.new()
    _check(run.start_new_frame_run(550, "frame-acquisition"), "new run")
    var learned: String = run.get_current_opponent().signature_manual_id
    var starters: Array = []
    for id in STARTER.STARTER_MANUAL_IDS:
        if id != learned and starters.size() < 4: starters.append(id)
    _check(run.advance() and run.confirm_setup_loadout(starters, STARTER.new().build_mastery(starters)) and run.advance(), "select four manuals excluding opponent signature")
    for step in range(3): _check(run.advance(), "tutorial step")
    _check(run.complete_frame_practice(20) and run.advance() and run.enter_first_journey() and run.select_first_journey_choice("leave") and run.advance() and run.advance(), "first combat reached through onboarding")
    _win(run)
    _check(run.set_pending_result_reward(RESULT.new().build_reward_receipt("faction_transfer", "", run.get_player_manual_loadout(), run.get_current_opponent())) and run.advance(), "confirmed reward grants opponent manual")
    _check(run.get_progression_snapshot().owned_manual_ids.size() == 5, "progression owns earned fifth manual")
    _check(run.get_player_manual_loadout().size() == 5 and learned in run.get_player_manual_loadout(), "all five manuals are combat-eligible")
    _roundtrip(run)
    var selection := [{"constraint_id":"CST_TECH_MANUAL_SEAL", "target_manual_id":learned}]
    var forged: Dictionary = run.export_snapshot()
    forged.pending_bimu_constraints = selection.duplicate(true)
    forged.frozen_bimu_receipt = preload("res://src/run/bimu_constraint_model.gd").new().validate_selection(selection, run.get_player_manual_loadout(), [learned])
    forged.frozen_bimu_receipt.merge({"duel_index":1, "run_seed":forged.run_seed, "enemy_candidate_id":forged.current_opponent_id}, true)
    _check(not run.validate_snapshot(forged).ok, "new reward cannot retroactively become a first-fight constraint target")
    _route(run)
    _check(run.select_bimu_constraints(selection), "earned manual can be a valid briefing constraint target")
    _roundtrip(run)
    _check(run.advance(), "second combat starts")
    _roundtrip(run)
    var board = BRIDGE.new()
    var opponent: Dictionary = run.get_current_opponent()
    var encounter: Dictionary = run.get_current_encounter()
    var total := 0
    for value in encounter.stats.values(): total += int(value)
    opponent.final_stat_total_seed = total
    var binding: Dictionary = preload("res://src/run/vertical_slice_opponent_runtime_binding.gd").new().build(opponent)
    binding.stats = encounter.stats.duplicate(true)
    binding.final_stat_total_seed = total
    var enemy_ids: Array = []
    var enemy_mastery := {}
    for manual in encounter.manuals:
        enemy_ids.append(manual.id)
        enemy_mastery[manual.id] = manual.mastery
    var configured: bool = board.configure_vertical_slice_loadouts(run.get_player_manual_loadout(), run.get_player_mastery_by_manual(), enemy_ids, enemy_mastery, opponent.candidate_id, binding, {"name":opponent.working_name}, run.get_frozen_bimu_receipt(), encounter, run.get_giyun_state())
    _check(configured, "second frame combat binds every earned manual")
    if configured:
        board.configure_checkpoint_identity(run.duel_index, 0)
        _check(board.apply_vertical_slice_player_resources(run.get_player_run_resources()), "carried resources apply")
        var encoded: Dictionary = CODEC.new().encode("frame-acquisition", "second-combat", 1, run.export_snapshot(), board.get_last_stable_checkpoint())
        _check(encoded.ok, "five-manual combat is durable: " + str(encoded.get("error", "")))
        if encoded.ok: _check(CODEC.new().decode(encoded.text).ok, "five-manual combat JSON restores")
    board.free()
    _win(run)
    _check(run.set_pending_result_reward(RESULT.new().build_reward_receipt("focused_training", learned, run.get_player_manual_loadout(), run.get_current_opponent())), "earned manual receives focused training")
    _roundtrip(run)
    _check(run.advance(), "focused reward applies once")
    _roundtrip(run)
    _route(run)
    _roundtrip(run)
    for failure in failures: printerr("FAIL: ", failure)
    print("FRAME_ACQUISITION checks=%d failures=%d" % [checks, failures.size()])
    quit(0 if failures.is_empty() else 1)

func _win(run) -> void:
    _check(run.mark_combat_finished({"outcome":"win", "player_resources":run.get_player_run_resources()}) and run.advance(), "recorded result reaches reward")

func _route(run) -> void:
    if run.get_current_screen() != "JIANGHU":
        _check(false, "route has a confirmed reward")
        return
    for step in range(4):
        var options: Array = run.get_jianghu_options()
        var id: String = str(options[0].id)
        _check(run.select_jianghu_node(id, step), "normal route node")
        if id == "event": _check(run.select_jianghu_node("event.leave", step), "safe event resolution")
        _roundtrip(run)
        _check(run.advance(), "normal route continuation")

func _roundtrip(run) -> void:
    var copy = RUN.new()
    var restored: Dictionary = copy.import_snapshot(JSON.parse_string(JSON.stringify(run.export_snapshot())))
    _check(restored.ok, "earned-manual snapshot imports: " + run.get_current_screen())
    if restored.ok: _check(copy.export_snapshot() == run.export_snapshot(), "snapshot restoration grants no extra rewards")

func _check(value: bool, label: String) -> void:
    checks += 1
    if not value: failures.append(label)
