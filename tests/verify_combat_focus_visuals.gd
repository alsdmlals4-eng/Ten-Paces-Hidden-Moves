# 키보드로 도달하는 표준 전투 컨트롤이 색과 무관한 포커스 링을 가지는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame

    _require_focus_ring(board.action_selection_dock.ultimate_tab, "ultimate source tab")
    var player: Dictionary = board.combat_state.get("player", {})
    player["momentum"] = [5, 5]
    board.combat_state["player"] = player
    board._sync_action_selection_dock()
    board.action_selection_dock.set_active_source("ultimate")
    await process_frame
    var available_ultimate: Button = null
    for button in board.action_selection_dock.ultimate_panel.action_buttons:
        if not bool(button.get_meta("locked", true)):
            available_ultimate = button
            break
    _require_focus_ring(available_ultimate, "available ultimate action")
    if is_instance_valid(board.get_node_or_null("SkipPresentationButton")):
        failures.append("The retired immediate-complete control must not remain in the focusable surface.")
    for retired_presentation_control in [
        board.fast_replay_button,
        board.reduced_motion_button,
        board.sound_toggle_button,
        board.sound_volume_slider,
    ]:
        _require_excluded_from_focus(retired_presentation_control, "retired presentation control")
    _require_focus_ring(board.combat_progress_button._button, "progress")

    board.queue_free()
    await process_frame
    _finish()

func _require_focus_ring(control: Control, label: String) -> void:
    if control == null or control.focus_mode != Control.FOCUS_ALL:
        failures.append("%s must remain keyboard focusable." % label)
        return
    var focus_style := control.get_theme_stylebox("focus")
    if focus_style == null or not bool(control.get_meta("keyboard_focus_ring", false)):
        failures.append("%s must have a visible non-color-only focus ring." % label)

func _require_excluded_from_focus(control: Control, label: String) -> void:
    if control == null or control.visible or control.focus_mode != Control.FOCUS_NONE:
        failures.append("%s must remain hidden and absent from keyboard traversal." % label)

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_FOCUS_VISUALS_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)
