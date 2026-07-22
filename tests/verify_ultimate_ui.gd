# 절초 메뉴의 기세 조건·예약 잠금·연속 슬롯 점유를 UI 수준에서 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const CASES := [
    ["ultimate_ten_paces_wave", 1],
    ["ultimate_cleave_peak", 2],
    ["ultimate_void_sword_qi", 3]
]

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for case_value in CASES:
        var case: Array = case_value
        await _verify_reservation(str(case[0]), int(case[1]))
    _finish()

func _verify_reservation(card_id: String, span: int) -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame

    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [5, 5]
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()
    await process_frame
    if board.ultimate_menu.disabled:
        failures.append("Ultimate menu must activate at exactly five momentum for %s." % card_id)
    if not bool(board.get_layout_snapshot().get("ultimate_vfx_ready", false)):
        failures.append("Approved RGBA ultimate VFX sheet must load into the combat screen.")

    var selected_index := -1
    for index in range(board._ultimate_definitions.size()):
        if str((board._ultimate_definitions[index] as Dictionary).get("id", "")) == card_id:
            selected_index = index
    if selected_index < 0:
        failures.append("Ultimate definition was missing from the menu: %s" % card_id)
    else:
        board._on_ultimate_menu_id_pressed(selected_index)
        board._on_timing_slot_clicked(1)
        var reserved_player: Dictionary = board.combat_state.get("player", {})
        var momentum: Array = reserved_player.get("momentum", [5, 5])
        if int(momentum[0]) != 0:
            failures.append("Ultimate reservation must immediately spend all momentum: %s" % card_id)
        var placement := board.action_timing_panel.get_placement(1)
        var definition: Dictionary = placement.get("definition", {})
        if str(definition.get("id", "")) != card_id or int(placement.get("span", 0)) != span:
            failures.append("Ultimate reservation must occupy its declared consecutive slots: %s" % card_id)
        for slot_index in range(1, span + 1):
            if not board.action_timing_panel.has_assignment_at(slot_index):
                failures.append("Ultimate %s must occupy slot %d." % [card_id, slot_index])
        board._show_ultimate_vfx({"card_id": card_id})
        if not board.presentation_vfx.visible or board.presentation_vfx.texture == null:
            failures.append("Ultimate VFX must select a visible atlas band: %s" % card_id)
        board._on_timing_slot_clicked(1)
        if board.action_timing_panel.get_placement(1).is_empty():
            failures.append("Reserved ultimate must not be removable or refundable: %s" % card_id)

    board.queue_free()
    await process_frame

func _finish() -> void:
    if failures.is_empty():
        print("ULTIMATE_UI_RESERVATION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("ULTIMATE_UI_RESERVATION_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
