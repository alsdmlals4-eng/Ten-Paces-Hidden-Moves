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

    _require_focus_ring(board.ultimate_menu, "ultimate menu")
    _require_focus_ring(board.ultimate_list_buttons[0], "ultimate list")
    _require_focus_ring(board.fast_replay_button, "fast playback")
    _require_focus_ring(board.skip_presentation_button, "skip playback")
    _require_focus_ring(board.reduced_motion_button, "reduced motion")
    _require_focus_ring(board.sound_toggle_button, "sound toggle")
    _require_focus_ring(board.sound_volume_slider, "sound volume")
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

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_FOCUS_VISUALS_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)
