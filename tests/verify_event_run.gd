extends SceneTree
const STARTERS := ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run_tests")
func check(value: bool, text: String) -> void:
    if not value: failures.append(text); push_error(text)
func run_tests() -> void:
    var script = load("res://src/run/vertical_slice_run_state.gd")
    var run = script.new()
    check(run.has_method("start_new_giyun_run"), "New journey needs opt-in giyun rules")
    if not run.has_method("start_new_giyun_run"): quit(1); return
    check(run.start_new_giyun_run(99, "giyun-test"), "Start new giyun journey")
    var codec = load("res://src/run/run_checkpoint_codec.gd").new()
    var encoded: Dictionary = codec.encode("giyun-test", "setup", 1, run.export_snapshot())
    check(encoded.get("ok",false) and encoded.get("payload",{}).get("schema_version") == 6, "New events use schema6 without colliding with v3/v4/v5")
    var masteries := {}
    for id in STARTERS: masteries[id] = 3
    check(run.confirm_setup_loadout(STARTERS, masteries), "Select starter manuals")
    for i in range(3): check(run.advance(), "Setup/intro/briefing advance")
    check(run.mark_combat_finished({"outcome":"win", "player_resources":{"health":[30,30],"stamina":[5,5],"internal":[4,4]},"battle_metrics":{},"review_summary":{}}), "Resolve first duel fixture")
    check(run.advance(), "Review to reward")
    check(run.set_pending_result_reward({"reward_type":"free_training","free_training":6}), "Choose training reward")
    check(run.advance(), "Reward to route")
    check(run.select_jianghu_node("event",0), "Open event without consuming route step")
    check(run.jianghu_step == 0 and run.get_pending_jianghu().is_empty(), "Event requires an outcome choice")
    var snapshot: Dictionary = run.export_snapshot()
    check(run.validate_snapshot(snapshot).ok, "Pending event is durable and valid")
    var restored = script.new()
    check(restored.import_snapshot(snapshot).ok, "Continue pending event")
    check(restored.get_jianghu_options() == run.get_jianghu_options(), "Continue does not reroll")
    check(restored.select_jianghu_node("event.accept",0), "Accept shown reward")
    check(not restored.select_jianghu_node("event.accept",0), "Repeated click cannot grant twice")
    check(restored.get_giyun_state().owned.size() <= 1, "At most one rare reward for one choice")
    check(restored.get_pending_jianghu().event_outcome.has("chance"), "Receipt records the actual check")
    var cloned = script.new()
    check(cloned.import_snapshot(snapshot).ok, "Second continuation imports exact pending event")
    check(cloned.select_jianghu_node("event.accept",0), "Second continuation resolves same choice")
    check(cloned.get_pending_jianghu() == restored.get_pending_jianghu(), "Fresh model continuation does not reroll result")
    var forged_roll: Dictionary = restored.export_snapshot()
    forged_roll.pending_jianghu.event_outcome.roll += 1
    check(not restored.validate_snapshot(forged_roll).ok, "Forged result roll is rejected by replay")
    check(restored.validate_snapshot(restored.export_snapshot()).ok, "Applied event receipt validates")
    for original in [snapshot, restored.export_snapshot()]:
        for invalid in [null, "bad", {}, {"health":[99,30],"stamina":[5,5],"internal":[4,4]}]:
            var malformed: Dictionary = original.duplicate(true)
            malformed.duel_history[0]["route_start_resources"] = invalid
            check(not restored.validate_snapshot(malformed).ok, "Malformed route resource receipt rejected")
        var missing: Dictionary = original.duplicate(true)
        missing.duel_history[0].erase("route_start_resources")
        check(not restored.validate_snapshot(missing).ok, "Missing route resource receipt rejected")
    var cost_forgery: Dictionary = restored.export_snapshot()
    cost_forgery.progression.free_training_pool += 1
    check(not restored.validate_snapshot(cost_forgery).ok, "Event reward cannot be forged in progression")
    for invalid_id in [null, {}, 42]:
        var malformed: Dictionary = restored.export_snapshot()
        malformed.pending_jianghu.id = invalid_id
        check(not restored.validate_snapshot(malformed).ok, "Malformed route id safely rejected")
    var missing_id: Dictionary = restored.export_snapshot()
    missing_id.pending_jianghu.erase("id")
    check(not restored.validate_snapshot(missing_id).ok, "Missing route id safely rejected")
    check(restored.advance(), "Outcome consumes exactly one route step")
    var changed: Dictionary = restored.export_snapshot()
    changed.giyun.owned.append("invalid")
    check(not restored.validate_snapshot(changed).ok, "Forged ownership rejected")
    var folder := OS.get_cache_dir().path_join("ten-giyun-"+str(Time.get_ticks_usec()))
    var store = load("res://src/run/run_save_store.gd").new(folder)
    var transported: Dictionary = codec.encode("giyun-test", "route", 1, restored.export_snapshot())
    var decoded: Dictionary = codec.decode(transported.text)
    check(decoded.ok, "Schema6 transport: "+str(decoded.get("error", "")))
    var saved: Dictionary = store.replace_run("giyun-test", "route", restored.export_snapshot())
    check(saved.ok, "New schema persists through immutable store: "+str(saved.get("error", "")))
    if saved.ok:
        check(store.load_checkpoint().payload.run_state == codec.normalized(restored.export_snapshot()), "Store readback exact")
    while restored.duel_index < 10:
        while restored.get_current_screen() == "JIANGHU":
            var step: int = restored.jianghu_step
            check(restored.select_jianghu_node("event", step), "Campaign event entry")
            check(restored.select_jianghu_node("event.accept", step), "Campaign event acceptance")
            check(restored.validate_snapshot(restored.export_snapshot()).ok, "Campaign durable route step")
            check(restored.advance(), "Campaign route step advance")
        check(restored.advance(), "Campaign briefing to combat")
        check(restored.mark_combat_finished({"outcome":"win", "player_resources":{"health":[30,30],"stamina":[5,5],"internal":[4,4]},"battle_metrics":{},"review_summary":{}}), "Campaign terminal fixture")
        check(restored.advance(), "Campaign review to result")
        check(restored.set_pending_result_reward({"reward_type":"free_training","free_training":6}), "Campaign reward")
        check(restored.advance(), "Campaign result advance")
    check(restored.route_visits == 36, "All 36 route choices remain available")
    check(restored.validate_snapshot(restored.export_snapshot()).ok, "Completed journey validates")
    var legacy = script.new()
    check(legacy.start_new_variable_run(99,"legacy-test"), "Legacy route remains constructible")
    check(not legacy.export_snapshot().has("giyun"), "Legacy save gains no giyun silently")
    check(legacy.validate_snapshot(legacy.export_snapshot()).ok, "Legacy valid")
    print("EVENT_RUN: ", "PASS" if failures.is_empty() else "FAIL")
    quit(0 if failures.is_empty() else 1)
