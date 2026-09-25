extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var stage = load("res://src/ui/ink/ink_combat_stage.gd").new()
    root.add_child(stage)
    await process_frame
    for cue in [
        {"kind":"move", "actor":"player", "duration":0.6, "event":{"positions_before_bundle":{"player":4},"actor_tile_after_action":5}},
        {"kind":"clash", "actor":"player", "duration":2.1, "contact":true},
        {"kind":"evade", "actor":"player", "duration":1.4, "event":{"motion_from_clash":true}},
        {"kind":"attack", "actor":"enemy", "duration":1.2}
    ]:
        var before: Dictionary = stage.pose.duplicate()
        stage.begin(cue)
        stage.sample(0, false)
        for key in ["px", "py", "ex", "ey", "zoom"]:
            check(is_equal_approx(stage.pose[key], before[key]), "No root/camera jump between " + cue.kind)
        var previous: Dictionary = stage.pose.duplicate()
        for frame in range(1, 121):
            stage.sample(frame / 120.0, false)
            for role in ["p", "e"]:
                var delta := Vector2(stage.pose[role+"x"]-previous[role+"x"], stage.pose[role+"y"]-previous[role+"y"]).length()
                check(delta < 38, "No teleport at a pose or cut boundary")
            previous = stage.pose.duplicate()
    # The close shot must enter and leave continuously, rather than replace a frame.
    if not stage.has_method("close_shot_rect"):
        check(false, "Close shot covers the full widescreen stage")
    else:
        for viewport in [Vector2(1280,440), Vector2(1440,530), Vector2(960,620)]:
            stage.size = viewport
            check(stage.close_shot_rect().encloses(Rect2(Vector2.ZERO, viewport)), "Close shot cannot expose a rectangular seam into the previous camera")
    if not stage.has_method("close_shot_opacity"):
        check(false, "Close shot has a continuous transition")
    else:
        stage.begin({"kind":"clash","actor":"player","contact":true,"duration":2.1})
        var last := 0.0
        for frame in range(241):
            stage.sample(frame/240.0, false)
            var alpha: float = stage.close_shot_opacity()
            check(absf(alpha-last) < 0.18, "Close shot opacity has no hard cut")
            last = alpha
        check(is_zero_approx(last), "Close shot returns to the moving actors before cue end")
        stage.sample(0.9, true)
        check(is_zero_approx(stage.close_shot_opacity()), "Reduced motion omits camera cut")
    stage.queue_free()
    await process_frame
    for message in failures: push_error(message)
    print("INK_CONTINUITY: %s (%d failures)" % ["PASS" if failures.is_empty() else "FAIL", failures.size()])
    quit(0 if failures.is_empty() else 1)
func check(ok: bool, message: String) -> void:
    if not ok and message not in failures: failures.append(message)
