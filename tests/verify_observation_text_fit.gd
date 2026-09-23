extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var panel = load("res://src/ui/observation_reveal_panel.gd").new()
	root.add_child(panel)
	for dimensions in [Vector2(200, 320), Vector2(260, 390)]:
		panel.size = dimensions
		panel._layout()
		var hint: Label = panel.get_node("ObservationHint")
		var title: Label = panel.get_node("ObservationTitle")
		if hint.position.y + hint.size.y > dimensions.y * 0.245 or hint.position.y < title.position.y + title.size.y:
			push_error("Observation text crosses the parchment/header boundary: %s title=%s hint=%s" % [dimensions, title.get_rect(), hint.get_rect()])
			quit(1)
			return
		if hint.get_theme_font("font").get_string_size(hint.text, HORIZONTAL_ALIGNMENT_LEFT, -1, hint.get_theme_font_size("font_size")).x > hint.size.x:
			push_error("Observation hint text clips horizontally")
			quit(1)
			return
	panel.queue_free()
	var detail = load("res://src/ui/action_selection/action_detail_panel.gd").new()
	root.add_child(detail)
	var header = detail.get_node("ActionDetailColumn").find_child("ActionDetailHeader", true, false)
	var surface = header.get_parent()
	if not surface is PanelContainer or not surface.get_theme_stylebox("panel") is StyleBoxFlat:
		push_error("Detail title is drawn over frame ornament without a readable surface")
		quit(1)
		return
	detail.queue_free()
	await process_frame
	print("OBSERVATION_TEXT_FIT_PASS")
	quit()
