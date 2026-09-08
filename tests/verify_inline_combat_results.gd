extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _run() -> void:
	var board = preload("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	for _frame in range(8):
		await process_frame
	board._reduced_motion = true
	for _index in range(3):
		board.action_selection_dock.basic_panel.buttons[2].emit_signal("pressed")
		await process_frame
	board.combat_progress_button.request_progress()
	var deadline := Time.get_ticks_msec() + 15000
	while str(board.get_meta("presentation_state", "")) != "next_bundle_ready" and Time.get_ticks_msec() < deadline:
		await process_frame
	_expect(str(board.get_meta("presentation_state", "")) == "next_bundle_ready", "No modal review click is required")
	_expect(int(board.get_meta("resolution_count", 0)) == 1, "One existing resolution only")
	_expect(not board.combat_review_panel.visible, "No standalone product review overlay")
	_expect(not str(board.get_meta("inline_result_cause", "")).is_empty(), "Actual inline cause is retained")
	_expect(not bool(board.get_meta("presentation_future_action_exposed", true)), "No future timing is exposed")

	var overlay = board.action_reveal_overlay
	var fixture := [{"type":"action_result", "actor":"player", "card_name":"전진", "category":"move", "category_label":"이동", "action_slots":1, "outcome":"executed"}]
	for viewport_size in [Vector2(1280, 720), Vector2(1280, 800), Vector2(1920, 1080)]:
		board.size = viewport_size
		overlay.size = viewport_size
		overlay.configure_presentation_rect(Rect2(Vector2.ZERO, viewport_size * Vector2(1.0, 0.62)))
		overlay.show_timing(1, "대응", fixture, true)
		for _frame in range(2):
			await process_frame
		_expect(bool(overlay.get_meta("layout_bounded", false)), "Reveal cards and result are bounded at %s" % viewport_size)
		overlay.hide_reveal()

	board.queue_free()
	await process_frame
	if failures.is_empty():
		print("INLINE_COMBAT_RESULTS_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
