extends SceneTree

const SHELL_SCENE_PATH := "res://scenes/run/vertical_slice_shell.tscn"

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var packed := load(SHELL_SCENE_PATH) as PackedScene
    if packed == null:
        failures.append("Vertical Slice shell scene is missing.")
        _finish()
        return

    var shell = packed.instantiate()
    root.add_child(shell)
    if shell is Control:
        shell.set_anchors_preset(Control.PRESET_TOP_LEFT)
        shell.size = Vector2(1440.0, 900.0)
    for _index in range(3):
        await process_frame

    _expect_true(shell.get("opponent_catalog") != null, "Runtime shell must own the validated opponent catalog.")
    _expect_true(bool(shell.get_meta("opponent_catalog_bound", false)), "Runtime shell must record successful opponent-catalog binding.")
    _expect_eq(str(shell.get_meta("opponent_selection_binding", "")), "REVERSIBLE_SELECTION_BINDING", "Runtime shell must preserve the reversible selection-binding status.")

    _expect_true(shell.start_new_run(), "Runtime shell must start a configured run.")
    var current: Dictionary = shell.run_state.get_current_opponent()
    _expect_true(not current.is_empty(), "Runtime shell must lock a Duel 1 candidate at run start.")
    _expect_eq(int(current.get("duel_slot", 0)), 1, "Runtime shell Duel 1 candidate must belong to Slot 1.")

    _expect_true(shell.advance_noncombat(), "SETUP → INTRO")
    _expect_true(shell.advance_noncombat(), "INTRO → BRIEFING")
    _expect_eq(str(shell.run_state.get_current_opponent().get("candidate_id", "")), str(current.get("candidate_id", "")), "Briefing must use the opponent already locked at run start.")

    shell.queue_free()
    await process_frame
    _finish()


func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)


func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])


func _finish() -> void:
    if failures.is_empty():
        print("VERTICAL_SLICE_OPPONENT_SHELL_BINDING_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_OPPONENT_SHELL_BINDING_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
