extends SceneTree

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _expect(value: bool, message: String) -> void:
    if not value:
        failures.append(message)
        push_error(message)

func _has_label(node: Node, text: String) -> bool:
    if node is Label and node.text == text and not node.is_queued_for_deletion():
        return true
    for child in node.get_children():
        if not child.is_queued_for_deletion() and _has_label(child, text):
            return true
    return false

func _run() -> void:
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    await process_frame
    var timing = board.action_timing_panel
    for bundle in range(4):
        var previous_end := -1.0
        for index in timing.get_visible_timing_indices():
            var rect: Rect2 = timing.get_slot(index).get_rect()
            _expect(rect.position.x >= previous_end, "Bundle %d slots must not overlap without resize" % bundle)
            _expect(Rect2(Vector2.ZERO, timing.size).encloses(rect), "Visible slot must fit panel")
            previous_end = rect.end.x
        timing.advance_after_resolution()

    var panel = load("res://scenes/ui/action_selection/action_detail_panel.tscn").instantiate()
    panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
    root.add_child(panel)
    panel.size = Vector2(250, 400)
    var adapter = load("res://src/ui/action_selection/action_view_model_adapter.gd").new()
    var summaries: Array[String] = []
    for action in adapter.build_basic_actions():
        if action.id not in ["basic_guard", "basic_evade"]:
            continue
        panel.show_action(action, false)
        var text := str(action.get("detail", {}).get("effect_text", action.get("effect_text", "")))
        _expect(not text.is_empty() and _has_label(panel, text), "Full effect must remain readable: " + action.id)
        summaries.append(str(panel.get_detail_snapshot().primary_effect))
    _expect(summaries.size() == 2 and summaries[0] != summaries[1], "Guard and evade require distinct summaries")
    panel.size.x = 600
    _expect(not panel._is_compact_layout(), "Actual wide panel must not remain compact")

    board.combat_log_panel.set_collapsed(false)
    board._set_presentation_state("presenting_result")
    board._set_resolution_surface_visible(false)
    board._refresh_observation_reveal()
    _expect(not board.combat_log_panel.visible, "Observation refresh must not reveal future bundle logs")
    board._set_presentation_state("review_ready")
    board.combat_log_panel.visible = false
    board._on_review_detail_requested()
    _expect(board.combat_log_panel.visible, "Review detail must display resolved logs")
    panel.queue_free()
    board.queue_free()
    await process_frame
    print("INTEGRATION_INFORMATION_BOUNDARIES_OK" if failures.is_empty() else "INTEGRATION_INFORMATION_BOUNDARIES_FAILED: %d" % failures.size())
    quit(0 if failures.is_empty() else 1)
