extends SceneTree

const RUN = preload("res://src/run/vertical_slice_run_state.gd")
var checks := 0
var failures: Array[String] = []

func check(value: bool, label: String) -> void:
    checks += 1
    if not value:
        failures.append(label)
        push_error(label)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var run = RUN.new()
    if not run.has_method("get_jianghu_effect_view"):
        check(false, "route effect view must exist")
        finish()
        return
    run.start_new_stats_run(34, "route-effects")
    var ids: Array = load("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0,4)
    var mastery := {}
    for id in ids: mastery[id] = 3
    check(run.confirm_setup_loadout(ids, mastery, load("res://src/run/player_growth_state.gd").new().recommended_allocation(ids)), "setup")
    for i in range(3): check(run.advance(), "initial combat")
    var seen := {}
    for duel in range(1,11):
        check(run.mark_combat_finished({"outcome":"win", "player_health":29, "enemy_health":0,"player_resources":{"health":[29,30],"stamina":[0,5],"internal":[3,4]}}), "synthetic terminal")
        check(run.advance(), "result")
        check(run.set_pending_result_reward({"reward_type":"free_training","free_training":6,"focused_training":0}), "reward")
        check(run.advance(), "confirm reward")
        if duel == 10:
            check(run.get_jianghu_effect_view("rest").is_empty(), "no extra route after ten")
            break
        for step in range(4):
            var snapshot: Dictionary = run.export_snapshot()
            for option in run.get_jianghu_options():
                var preview: Dictionary = run.get_jianghu_effect_view(option.id)
                check(run.export_snapshot() == snapshot, "preview does not mutate")
                var fork = RUN.new()
                check(fork.import_snapshot(snapshot).ok, "fork valid boundary")
                var before: Dictionary = fork.get_progression_snapshot()
                check(fork.select_jianghu_node(option.id, step), "choose offered option")
                var after: Dictionary = fork.get_progression_snapshot()
                check(after.free_training_pool - before.free_training_pool == preview.free_training, "free gain matches preview")
                for key in ["health","stamina","internal"]:
                    check(after.player_resources[key][0] - before.player_resources[key][0] == preview.gains[key], "resource gain matches " + key)
                check(fork.get_jianghu_effect_view(option.id, true) == preview, "pending report matches original preview")
                var restored = RUN.new()
                check(restored.import_snapshot(fork.export_snapshot()).ok, "pending original receipt restores")
                check(restored.get_jianghu_effect_view(option.id, true) == preview, "restored report unchanged")
                check(not restored.select_jianghu_node(option.id, step), "duplicate command blocked")
                seen[option.id] = true
            var chosen: String = run.get_jianghu_options()[0].id
            check(run.select_jianghu_node(chosen, step), "campaign route")
            check(run.advance(), "campaign route advance")
        check(run.advance(), "next combat")
    check(seen.size() == 5, "all five effects covered")
    finish()

func finish() -> void:
    print("JIANGHU_EFFECT_VIEW checks=%d failures=%d" % [checks, failures.size()])
    quit(0 if failures.is_empty() else 1)
