extends SceneTree

const PROGRESSION = preload("res://src/run/vertical_slice_progression_state.gd")
var failures: Array[String] = []
var checks := 0

func check(value: bool, label: String) -> bool:
    checks += 1
    if not value:
        failures.append(label)
        push_error(label)
    return value

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var p = PROGRESSION.new()
    var ids: Array = load("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0, 4)
    var mastery := {}
    for id in ids: mastery[id] = 3
    check(p.initialize_from_setup(ids, mastery), "valid starter setup")
    check(p.add_free_training(6), "real free pool")
    if check(p.has_method("preview_training") and p.has_method("commit_training"), "free training has preview and atomic allocation consumer"):
        var initial: Dictionary = p.get_snapshot()
        var allocation := {ids[0]: 2}
        var preview: Dictionary = p.preview_training(allocation)
        check(preview.get("ok", false), "preview accepts available training")
        check(p.get_snapshot() == initial, "preview and cancel do not mutate live progression")
        if preview.get("ok", false):
            check(preview.pool_after == 4 and preview.mastery_by_manual[ids[0]] == 4, "2 training reaches fourth star and leaves 4")
        for invalid in [{}, {ids[0]:0}, {ids[0]:-1}, {ids[0]:1.5}, {ids[0]:true}, {ids[0]:7}, {"unknown":1}, {ids[0]:4,ids[1]:3}]:
            check(not p.commit_training(invalid), "reject invalid allocation " + str(invalid))
            check(p.get_snapshot() == initial, "rejection is atomic")
        check(p.commit_training(allocation), "commit first star")
        check(p.free_training_pool == 4 and p.mastery_by_manual[ids[0]] == 4, "first commit effective")
        check(p.commit_training({ids[0]:3}), "commit fifth star")
        check(p.free_training_pool == 1 and p.mastery_by_manual[ids[0]] == 5, "cumulative cost uses domain contract")
        check(p.get_player_resources() == initial.player_resources and p.owned_manual_ids == initial.owned_manual_ids, "allocation does not change resources or ownership")
        p.add_free_training(100)
        check(p.commit_training({ids[0]:33}), "remaining 33 reaches total 38")
        var capped: Dictionary = p.get_snapshot()
        check(p.mastery_by_manual[ids[0]] == 10 and p.training_by_manual[ids[0]] == 38, "exact maximum")
        check(not p.commit_training({ids[0]:1}) and p.get_snapshot() == capped, "tenth star cannot spend more")
        p.add_focused_training(ids[0], 5)
        var focused: Dictionary = p.get_snapshot()
        check(not p.commit_training({ids[0]:1}) and p.get_snapshot() == focused, "legacy focused surplus preserved")
        check(p.validate_snapshot(p.get_snapshot()).ok, "allocated progression remains valid")
    print("TRAINING_ALLOCATION checks=%d failures=%d" % [checks,failures.size()])
    quit(0 if failures.is_empty() else 1)
