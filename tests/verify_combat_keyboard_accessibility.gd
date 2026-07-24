# 전투 화면의 카드 자동 배치·대상 칸·진행 버튼 키보드 포커스와 Enter 조작을 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame

    var move_card := board.basic_card_tray.cards[0]
    if move_card.focus_mode != Control.FOCUS_ALL:
        failures.append("Basic combat cards must participate in keyboard focus traversal.")
    move_card.grab_focus()
    move_card._on_gui_input(_accept_key())
    if not board.action_timing_panel.has_assignment_at(1):
        failures.append("Enter on a focused card must auto-place it in the earliest timing.")
    if int(board.get_meta("targeting_anchor", 0)) != 1:
        failures.append("Keyboard auto-placement of a move must enter tile targeting.")
    if not board._selected_action_definition.is_empty():
        failures.append("Automatic placement must clear the transient selected-card state.")

    var slot := board.action_timing_panel.get_slot(1)
    if slot.focus_mode != Control.FOCUS_ALL:
        failures.append("Assigned timing slots must remain keyboard focusable for removal.")

    var target_tile := board.get_tile(5)
    if target_tile.focus_mode != Control.FOCUS_ALL:
        failures.append("Targetable combat tiles must receive keyboard focus.")
    target_tile.grab_focus()
    target_tile._on_gui_input(_accept_key())
    var placement := board.action_timing_panel.get_placement(1)
    if not bool(placement.get("target_ready", false)) or int(placement.get("target_tile", 0)) != 5:
        failures.append("Enter on a focused target tile must confirm the target.")

    if board.combat_progress_button._button.focus_mode != Control.FOCUS_ALL:
        failures.append("The progress button must participate in keyboard focus traversal.")
    if board.reduced_motion_button.focus_mode != Control.FOCUS_ALL or board.sound_toggle_button.focus_mode != Control.FOCUS_ALL:
        failures.append("Presentation accessibility controls must be keyboard focusable.")

    board.queue_free()
    await process_frame
    _finish()

func _accept_key() -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = KEY_ENTER
    event.pressed = true
    return event

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_KEYBOARD_ACCESSIBILITY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_KEYBOARD_ACCESSIBILITY_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
