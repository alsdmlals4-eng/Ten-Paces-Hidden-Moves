extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for viewport_size in [Vector2i(1280, 720), Vector2i(1280, 800), Vector2i(1920, 1080)]:
		if not await _verify_size(viewport_size):
			quit(1)
			return
	print("PREPARATION_ART_FILL_PASS")
	quit(0)

func _verify_size(viewport_size: Vector2i) -> bool:
	root.size = viewport_size
	var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = Vector2(viewport_size)
	for i in range(10):
		await process_frame
	var panel = board.action_selection_dock.basic_panel
	var last = panel.buttons.back()
	var art = panel.buttons[0].get_node("CardIllustration")
	if art.stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_CENTERED or art.size.y < 50.0:
		print("CARD_METRICS viewport=", viewport_size, " card=", panel.buttons[0].size, " art=", art.size, " summary=", panel.buttons[0].get_node("CardSummary").get_combined_minimum_size())
		push_error("CARD_ART_STILL_CROPPED_OR_SHALLOW")
		return false
	if absf(panel.get_global_rect().end.y - last.get_global_rect().end.y) > 8.0:
		print("GRID_BOUNDS ", viewport_size, " panel=", panel.get_global_rect(), " last=", last.get_global_rect())
		push_error("CARD_GRID_LEAVES_UNUSED_BOTTOM")
		return false
	var definition: Dictionary = board.basic_card_tray.cards[0].definition
	board.action_timing_panel.place_card(definition, 1)
	await process_frame
	var block = board.action_timing_panel.get_linked_block(1)
	print("PLAN_LAYOUT panel=",board.action_timing_panel.get_global_rect()," title=",board.action_timing_panel._title_label.get_global_rect()," flow=",board.action_timing_panel._sequence_label.get_global_rect()," slot=",board.action_timing_panel.get_slot(1).get_global_rect()," block=",block.get_global_rect())
	if board.action_timing_panel._sequence_label.get_global_rect().intersects(block.get_global_rect()) or board.action_timing_panel._title_label.get_global_rect().intersects(block.get_global_rect()):
		push_error("CURRENT_PLAN_TITLE_FLOW_OCCLUDED")
		return false
	if block == null or block.find_child("PlanIllustration", true, false) == null or block.get_node("PlanIllustration").texture == null:
		push_error("CURRENT_PLAN_HAS_NO_ILLUSTRATION")
		return false
	if not board.action_timing_panel._sequence_label.visible or not board.action_timing_panel._sequence_label.text.contains("4수"):
		push_error("CURRENT_PLAN_FLOW_MISSING")
		return false
	board.action_timing_panel.advance_after_resolution()
	board.action_timing_panel.advance_after_resolution()
	for timing_index in board.action_timing_panel.get_current_bundle_indices():
		board.action_timing_panel.place_card(definition, timing_index)
	for i in range(3):
		await process_frame
	for timing_index in board.action_timing_panel.get_current_bundle_indices():
		var four_block = board.action_timing_panel.get_linked_block(timing_index)
		if four_block == null or board.action_timing_panel._title_label.get_global_rect().intersects(four_block.get_global_rect()) or board.action_timing_panel._sequence_label.get_global_rect().intersects(four_block.get_global_rect()):
			push_error("FOUR_MOVE_PLAN_OCCLUDED")
			return false
	# Font fallback metrics may arrive after a card has entered its container.
	# Increase native label metrics late; the image must keep its 50px band.
	var late_card = panel.buttons[0]
	for line in late_card.get_node("CardSummary").get_children():
		line.add_theme_font_size_override("font_size", 14)
	for i in range(10):
		await process_frame
	print("LATE_CARD_METRICS ", late_card.size, " art=", late_card.get_node("CardIllustration").get_rect(), " summary=", late_card.get_node("CardSummary").get_rect(), " native=", late_card.get_node("CardSummary").get_combined_minimum_size())
	if late_card.get_node("CardIllustration").size.y < 50.0 or late_card.get_node("CardSummary").get_rect().end.y > late_card.size.y - 3.5:
		push_error("LATE_FONT_METRICS_SHRINK_CARD_ART")
		return false
	board.free()
	return true
