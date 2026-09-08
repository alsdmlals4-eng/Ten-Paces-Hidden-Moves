extends SceneTree

const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var board := BOARD_SCENE.instantiate() as CombatBoardPreview
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = Vector2(1440.0, 900.0)
	root.add_child(board)
	for _frame in range(6):
		await process_frame

	_expect(is_instance_valid(board.action_selection_dock), "Product combat must expose the shared action-selection dock.")
	if not is_instance_valid(board.action_selection_dock):
		_finish()
		return
	for _index in range(3):
		board.action_selection_dock.basic_panel.buttons[2].emit_signal("pressed")
		await process_frame

	_expect(board.action_timing_panel.is_current_bundle_complete(), "Three ready actions must complete the first bundle before plan lock.")
	_expect(board.combat_progress_button.progress_enabled, "A complete bundle must enable the plan-lock CTA.")
	_expect(board.combat_progress_button._button.text == "행동 실행", "The compact CTA must use the approved single-execute label.")
	_expect(board.combat_progress_button.size.x >= 88.0, "The plan-lock CTA must remain inside a usable compact timing-row width.")

	board.combat_progress_button.request_progress()
	await process_frame
	_expect(int(board.get_meta("resolution_count", 0)) == 1, "One CTA activation must resolve the completed bundle exactly once.")
	_expect(str(board.get_meta("presentation_state", "")) in ["committed", "resolving", "presenting_result"], "One activation must enter the existing resolution presentation flow.")
	_expect(not board.planning_surface.visible and not board.action_selection_dock.visible and not board.action_timing_panel.visible, "The single transition must close the lower planning controls before reveal.")
	board.combat_progress_button.request_progress()
	await process_frame
	_expect(int(board.get_meta("resolution_count", 0)) == 1, "Repeated progress input while resolving must not start a second resolution.")

	board.queue_free()
	await process_frame
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("FRONTAL_DUEL_PLAN_LOCK_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("FRONTAL_DUEL_PLAN_LOCK_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
