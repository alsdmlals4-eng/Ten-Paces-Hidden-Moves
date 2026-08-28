# 제품 전투 계획의 Tab 포커스가 출처·행동·수·진행·접근성 순서로 고정되는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const REPORT_PATH := "res://focus-order-report.txt"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    if packed == null:
        failures.append("Focus order requires the combat board scene.")
        _finish()
        return
    var board := packed.instantiate() as CombatBoardPreview
    root.add_child(board)
    for _index in range(4):
        await process_frame

    if not is_instance_valid(board.action_selection_dock):
        failures.append("Focus order requires the product ActionSelectionDock.")
        board.queue_free()
        await process_frame
        _finish()
        return
    if board.basic_card_tray.visible or board.basic_card_tray.focus_mode != Control.FOCUS_NONE:
        failures.append("Hidden legacy basic-card controls must not remain in the product focus order.")
    if board.ultimate_list_panel.visible or board.ultimate_menu.focus_mode != Control.FOCUS_NONE:
        failures.append("Hidden legacy ultimate controls must not remain in the product focus order.")

    var basic_tab: Button = board.action_selection_dock.basic_tab
    var martial_tab: Button = board.action_selection_dock.martial_tab
    var ultimate_tab: Button = board.action_selection_dock.ultimate_tab
    var basic_buttons: Array[Button] = board.action_selection_dock.basic_panel.buttons
    var first_slot: ActionTimingSlot = board.action_timing_panel.get_slot(1)
    var last_slot: ActionTimingSlot = board.action_timing_panel.get_slot(10)
    var progress: Button = board.combat_progress_button._button
    var hypothesis_focus: Control = board.opponent_hypothesis_panel.get_focus_control()

    _require_next(basic_tab, martial_tab, "basic source tab")
    _require_next(martial_tab, ultimate_tab, "martial source tab")
    if basic_buttons.size() != 10:
        failures.append("Product basic source must expose exactly ten focusable actions.")
    else:
        _require_next(ultimate_tab, basic_buttons[0], "ultimate source tab")
        for index in range(basic_buttons.size() - 1):
            _require_next(basic_buttons[index], basic_buttons[index + 1], "basic action %d" % (index + 1))
        _require_next(basic_buttons[basic_buttons.size() - 1], first_slot, "last basic action")

    for timing_index in range(1, 10):
        _require_next(
            board.action_timing_panel.get_slot(timing_index),
            board.action_timing_panel.get_slot(timing_index + 1),
            "timing slot %d" % timing_index
        )
    _require_next(last_slot, progress, "last timing slot")
    _require_next(progress, board.fast_replay_button, "progress button")
    _require_next(board.fast_replay_button, board.skip_presentation_button, "fast playback")
    _require_next(board.skip_presentation_button, board.reduced_motion_button, "skip playback")
    _require_next(board.reduced_motion_button, board.sound_toggle_button, "reduced motion")
    _require_next(board.sound_toggle_button, board.sound_volume_slider, "sound toggle")
    _require_next(board.sound_volume_slider, hypothesis_focus, "sound volume")
    _require_next(hypothesis_focus, basic_tab, "hypothesis selector")

    board.queue_free()
    await process_frame
    _finish()

func _require_next(control: Control, expected: Control, label: String) -> void:
    if control == null or expected == null:
        failures.append("%s focus controls must exist." % label)
        return
    var expected_path := control.get_path_to(expected)
    var actual_path := control.focus_next
    if actual_path != expected_path:
        failures.append(
            "%s next mismatch: control=%s actual=%s expected=%s target=%s" % [
                label,
                str(control.get_path()),
                str(actual_path),
                str(expected_path),
                str(expected.get_path())
            ]
        )

func _write_report(lines: Array[String]) -> void:
    var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
    if file == null:
        push_error("Could not write focus-order report.")
        return
    file.store_string("\n".join(lines) + "\n")
    file.close()

func _finish() -> void:
    if failures.is_empty():
        _write_report(["COMBAT_FOCUS_ORDER_VERIFY_OK"])
        print("COMBAT_FOCUS_ORDER_VERIFY_OK")
        quit(0)
        return
    _write_report(failures)
    for failure in failures:
        push_error(failure)
        print("FOCUS_MISMATCH %s" % failure)
    print("COMBAT_FOCUS_ORDER_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
