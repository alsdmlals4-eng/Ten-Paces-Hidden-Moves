extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    await _verify_basic_earliest_placement()
    await _verify_contiguous_range_selection()
    await _verify_ultimate_auto_reservation_and_refund()
    _finish()

func _new_board() -> CombatBoardPreview:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    return board

func _settle() -> void:
    for _index in range(4):
        await process_frame

func _verify_basic_earliest_placement() -> void:
    var board := _new_board()
    await _settle()
    var meditate := _card_definition(board, "basic_meditate")
    board._on_action_card_selected(meditate)
    if str(board.action_timing_panel.get_placement(1).get("card_id", "")) != "basic_meditate":
        failures.append("Selecting a one-slot card must place it in the earliest empty timing.")
    board._on_action_card_selected(meditate)
    if str(board.action_timing_panel.get_placement(2).get("card_id", "")) != "basic_meditate":
        failures.append("A second selected one-slot card must skip the occupied first timing.")
    board.queue_free()
    await process_frame

func _verify_contiguous_range_selection() -> void:
    var board := _new_board()
    await _settle()
    var meditate := _card_definition(board, "basic_meditate")
    var heavy := _card_definition(board, "basic_heavy_attack")
    board.action_timing_panel.place_card(meditate, 1)
    board._on_action_card_selected(heavy)
    var placement := board.action_timing_panel.get_placement(2)
    if str(placement.get("card_id", "")) != "basic_heavy_attack" or int(placement.get("span", 0)) != 2:
        failures.append("A two-slot card must use the earliest contiguous two-timing range.")
    board._clear_targeting()
    board.action_timing_panel.clear_current_bundle()
    board.action_timing_panel.place_card(meditate, 2)
    var before_count := board.action_timing_panel.get_placement_list().size()
    board._on_action_card_selected(heavy)
    var after_count := board.action_timing_panel.get_placement_list().size()
    if before_count != after_count:
        failures.append("A two-slot card must not place when no contiguous two-timing range exists.")
    board.queue_free()
    await process_frame

func _verify_ultimate_auto_reservation_and_refund() -> void:
    var board := _new_board()
    await _settle()
    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [5, 5]
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()
    await process_frame

    var ultimate_index := -1
    for index in range(board._ultimate_definitions.size()):
        if str((board._ultimate_definitions[index] as Dictionary).get("id", "")) == "ultimate_cleave_peak":
            ultimate_index = index
            break
    if ultimate_index < 0:
        failures.append("Auto-reservation test could not find the two-slot ultimate.")
    else:
        board._on_ultimate_menu_id_pressed(ultimate_index)
        var placement := board.action_timing_panel.get_placement(1)
        if str(placement.get("card_id", "")) != "ultimate_cleave_peak" or int(placement.get("span", 0)) != 2:
            failures.append("Selecting an ultimate must auto-reserve the earliest contiguous range.")
        player = board.combat_state.get("player", {})
        if _resource_current(player, "momentum") != 0:
            failures.append("Ultimate auto-reservation must immediately spend momentum 5.")
        board._on_timing_slot_clicked(2)
        if not board.action_timing_panel.get_placement(1).is_empty():
            failures.append("Clicking any reserved ultimate timing before progress must cancel the reservation.")
        player = board.combat_state.get("player", {})
        if _resource_current(player, "momentum") != 5:
            failures.append("Cancelling an auto-reserved ultimate must refund momentum 5.")
    board.queue_free()
    await process_frame

func _card_definition(board: CombatBoardPreview, card_id: String) -> Dictionary:
    for card in board.basic_card_tray.cards:
        if str(card.definition.get("id", "")) == card_id:
            return card.definition.duplicate(true)
    return {}

func _resource_current(actor: Dictionary, key: String) -> int:
    var pair = actor.get(key, [0, 0])
    return int(pair[0]) if typeof(pair) == TYPE_ARRAY and pair.size() >= 1 else 0

func _finish() -> void:
    if failures.is_empty():
        print("AUTO_CARD_PLACEMENT_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("AUTO_CARD_PLACEMENT_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
