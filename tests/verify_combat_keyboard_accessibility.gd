# 전투 화면의 공통 행동 카드·의도 카드·진행 버튼 키보드 포커스와 Enter 조작을 검증한다.
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

    var move_card: Button = board.action_selection_dock.basic_panel.buttons[0] as Button
    if move_card.focus_mode != Control.FOCUS_ALL:
        failures.append("Basic combat cards must participate in keyboard focus traversal.")
    move_card.grab_focus()
    move_card.emit_signal("pressed")
    await process_frame
    if not board.action_timing_panel.has_assignment_at(1):
        failures.append("Activating a focused card must auto-place it in the earliest timing.")
    if int(board.get_meta("targeting_anchor", 0)) != 1 or board._targeting_mode != "move_intent":
        failures.append("Focused-card movement placement must enter semantic movement-intent targeting.")
    if not board._selected_action_definition.is_empty():
        failures.append("Automatic placement must clear the transient selected-card state.")

    var slot := board.action_timing_panel.get_slot(1)
    if slot.focus_mode != Control.FOCUS_ALL:
        failures.append("Assigned timing slots must remain keyboard focusable for removal.")

    var intent_cards: Array = board.action_selection_dock.action_intent_panel.intent_buttons
    if intent_cards.is_empty():
        failures.append("Movement targeting must expose keyboard-focusable intent cards.")
    else:
        var intent_card: Button = intent_cards[0] as Button
        if intent_card.focus_mode != Control.FOCUS_ALL:
            failures.append("Intent cards must receive keyboard focus.")
        intent_card.grab_focus()
        intent_card.emit_signal("pressed")
        await process_frame
    var placement := board.action_timing_panel.get_placement(1)
    if not bool(placement.get("target_ready", false)) or not str(placement.get("target_text", "")).begins_with("접근"):
        failures.append("Activating a focused intent card must confirm the semantic movement choice.")

    if board.combat_progress_button._button.focus_mode != Control.FOCUS_ALL:
        failures.append("The progress button must participate in keyboard focus traversal.")
    if board.reduced_motion_button.focus_mode != Control.FOCUS_ALL or board.sound_toggle_button.focus_mode != Control.FOCUS_ALL:
        failures.append("Presentation accessibility controls must be keyboard focusable.")

    board.queue_free()
    await process_frame
    _finish()

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_KEYBOARD_ACCESSIBILITY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_KEYBOARD_ACCESSIBILITY_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
