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
    await _verify_disabled_reason_copy()
    for case_value in CASES:
        var case: Array = case_value
        await _verify_reservation(str(case[0]), int(case[1]))
    await _verify_ultimate_playback_visibility()
    _finish()

func _verify_disabled_reason_copy() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame

    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [4, 5]
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()
    if board.ultimate_list_buttons.is_empty() or not board.ultimate_list_buttons[0].tooltip_text.contains("기세 5 필요"):
        failures.append("Disabled ultimate buttons must explain the exact momentum requirement.")

    player["momentum"] = [5, 5]
    board.combat_state["player"] = player
    var meditate := _card_definition(board, "basic_meditate")
    board.action_timing_panel.place_card(meditate, 1)
    board.action_timing_panel.place_card(meditate, 2)
    board.action_timing_panel.place_card(meditate, 3)
    board._refresh_ultimate_menu()
    if board.ultimate_list_buttons.size() < 2 or not board.ultimate_list_buttons[1].tooltip_text.contains("연속 빈 수 부족"):
        failures.append("Disabled multi-slot ultimate buttons must explain the missing contiguous timings.")

    board._set_presentation_state("resolving")
    board._refresh_ultimate_menu()
    if not board.ultimate_list_buttons[0].tooltip_text.contains("판정 중"):
        failures.append("Disabled ultimate buttons must explain that resolving locks reservations.")

    board.queue_free()
    await process_frame

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

func _verify_ultimate_playback_visibility() -> void:
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
    var ultimate_index := -1
    for index in range(board._ultimate_definitions.size()):
        if str((board._ultimate_definitions[index] as Dictionary).get("id", "")) == "ultimate_ten_paces_wave":
            ultimate_index = index
    if ultimate_index < 0:
        failures.append("Playback VFX test could not find the one-slot ultimate.")
    else:
        board._on_ultimate_menu_id_pressed(ultimate_index)
        board._on_timing_slot_clicked(1)
        board.action_timing_panel.set_placement_target(1, {"direction": 1, "target_tile": 5, "origin_tile": 4})
        var meditate := _card_definition(board, "basic_meditate")
        var stance := _card_definition(board, "basic_stance")
        board.action_timing_panel.place_card(meditate, 2)
        board.action_timing_panel.place_card(stance, 3)
        board._sync_progress_availability()
        if not board.combat_progress_button.progress_enabled:
            failures.append("Playback VFX test could not complete the first bundle.")
        else:
            board.combat_progress_button.request_progress()
            var ultimate_timing_seen := false
            for _attempt in range(40):
                await process_frame
                if int(board.get_meta("presentation_timing", -1)) == 1 and board.presentation_vfx.visible:
                    ultimate_timing_seen = true
                    break
                await create_timer(0.05).timeout
            if not ultimate_timing_seen or int(board.get_meta("presentation_timing", -1)) != 1:
                failures.append("Ultimate playback must advance to the first actual timing after response setup.")
            if not ultimate_timing_seen or not board.presentation_vfx.visible:
                failures.append("Ultimate VFX must remain visible during its authoritative timing playback.")

    board.queue_free()
    await process_frame

func _card_definition(board: CombatBoardPreview, card_id: String) -> Dictionary:
    for card in board.basic_card_tray.cards:
        if str(card.definition.get("id", "")) == card_id:
            return card.definition.duplicate(true)
    return {}

func _finish() -> void:
    if failures.is_empty():
        print("ULTIMATE_UI_RESERVATION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("ULTIMATE_UI_RESERVATION_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
