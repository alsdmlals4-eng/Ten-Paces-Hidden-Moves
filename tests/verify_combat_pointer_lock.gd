# 판정 중 실제 마우스 입력 신호가 전투 예약을 바꾸지 않는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene := load(BOARD_SCENE_PATH) as PackedScene
    var board := scene.instantiate() as CombatBoardPreview
    root.add_child(board)
    for _index in range(4):
        await process_frame

    var mouse_click := InputEventMouseButton.new()
    mouse_click.button_index = MOUSE_BUTTON_LEFT
    mouse_click.pressed = true

    var basic_panel: BasicActionPanel = board.action_selection_dock.basic_panel
    var meditate_button: Button = basic_panel.buttons[7]
    meditate_button.emit_signal("pressed")
    var initial_placement := board.action_timing_panel.get_placement(1)
    if str(initial_placement.get("card_id", "")) != "basic_meditate":
        failures.append("Pointer card input must auto-place the selected planning action before the lock.")

    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [5, 5]
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()
    var first_ultimate := board.ultimate_list_buttons[0]
    var momentum_before := int((board.combat_state.get("player", {}) as Dictionary).get("momentum", [0, 5])[0])
    board._set_presentation_state("resolving")

    var guard_button: Button = basic_panel.buttons[2]
    guard_button.emit_signal("pressed")
    if board.action_timing_panel.has_assignment_at(2):
        failures.append("Pointer card input during resolving must not auto-place another action.")

    var first_slot := board.action_timing_panel.get_slot(1)
    first_slot._on_gui_input(mouse_click)
    var locked_placement := board.action_timing_panel.get_placement(1)
    if str(locked_placement.get("card_id", "")) != "basic_meditate":
        failures.append("Pointer timing-slot input during resolving must not alter an existing reservation.")

    first_ultimate.emit_signal("pressed")
    var momentum_after := int((board.combat_state.get("player", {}) as Dictionary).get("momentum", [0, 5])[0])
    if momentum_after != momentum_before or not board._ultimate_reservation_anchors.is_empty():
        failures.append("Pointer ultimate input during resolving must not consume momentum or reserve a skill.")

    board.queue_free()
    await process_frame
    _finish()

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_POINTER_LOCK_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)
