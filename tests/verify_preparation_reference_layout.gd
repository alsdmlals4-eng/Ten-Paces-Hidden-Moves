extends SceneTree

var failures: Array[String] = []
func _initialize() -> void:
    call_deferred("run")
func check(value: bool, message: String) -> void:
    if not value: failures.append(message)
func run() -> void:
    root.content_scale_size = Vector2i.ZERO
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    for viewport in [Vector2i(1280,800), Vector2i(1280,720), Vector2i(960,640), Vector2i(1920,1080)]:
        root.size = viewport
        await process_frame
        await process_frame
        board._layout_board()
        await process_frame
        var dock = board.action_selection_dock
        var reference_rect: Rect2 = board.get_meta("reference_preparation_rect", Rect2())
        check(reference_rect.has_area(), "Reference painting is the active preparation surface")
        if reference_rect.has_area():
            check(absf(reference_rect.size.x / reference_rect.size.y - 1086.0 / 1448.0) < 0.001, "Preserve the supplied portrait proportions")
            check(Rect2(Vector2.ZERO, Vector2(viewport)).encloses(reference_rect), "Reference composition fits inside each viewport")
            var progress_rect: Rect2 = board.combat_progress_button.get_global_rect()
            check(progress_rect.position.x >= reference_rect.position.x + reference_rect.size.x * 0.79, "Progress follows reference paper strip")
            board._settle_inline_result_row(24, 4)
            check(reference_rect.encloses(board.inline_result_label.get_global_rect()), "Result refresh remains inside the reference paper after a bundle")
        check(board.get_node_or_null("ReferencePreparationPainting") != null, "Native UI has a text-free reference painting")

        check(dock.action_detail_panel.visible, "Selected action detail always occupies the right column")
        check(board.observation_reveal_panel.get_global_rect().end.y <= board.action_timing_panel.get_global_rect().position.y, "Observation never covers planning or execution")
        var buttons = dock.basic_panel.buttons
        check(buttons.size() == 10, "Ten actions remain available")
        for button in buttons:
            var art = button.get_node("CardIllustration")
            var title = button.get_node("CardName")
            check(button.get_global_rect().position.y >= dock.basic_tab.get_global_rect().end.y + 4, "Cards stay below tabs")
            check(dock.content_host.get_global_rect().grow(0.5).encloses(button.get_global_rect()), "Card grid stays inside its body lane")
            check(art.position.y >= title.get_rect().end.y - 1, "Illustration is below the card title")
            check(art.size.x > button.size.x * 0.7, "Art uses card width")
            check(button.get_global_rect().end.y <= dock.get_node("PreparationKeyHints").get_global_rect().position.y, "Both card rows stay above the footer")
            check(button.get_global_rect().end.x <= dock.detail_host.get_global_rect().position.x, "Cards do not overlap detail")
        check(not board.top_hud.enemy_panel.show_numeric_values, "Hidden enemy resources remain hidden")
    var observation = board.observation_reveal_panel
    observation.set_revealed_types(["공격"])
    check(observation.get_node("ObservationHint").text == "확인한 행동 유형", "Observation updates its hint when a real clue is revealed")
    observation.clear_revealed_types()
    check(observation.get_node("ObservationType01").visible, "Empty observation keeps the no-clue explanation")
    var guard: Dictionary = board.resolution_engine.get_actor_card_definition("basic_guard", "player")
    board.action_selection_dock.request_action(guard)
    await process_frame
    check(board.action_timing_panel.has_assignment_at(1), "Real card still places into the real plan")
    board.action_selection_dock.request_detail(guard, false)
    board.action_selection_dock.clear_detail()
    check(board.action_selection_dock.action_detail_panel.visible, "Pointer exit does not empty the reference detail column")
    board.queue_free()
    await process_frame
    for message in failures: push_error(message)
    print("PREPARATION_REFERENCE: %s (%d failures)" % ["PASS" if failures.is_empty() else "FAIL", failures.size()])
    quit(0 if failures.is_empty() else 1)
