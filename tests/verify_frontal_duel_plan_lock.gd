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
	_expect(board.combat_progress_button._button.text == "행동계획\n잠금", "The first compact CTA must explicitly lock the action plan.")
	_expect(board.combat_progress_button.size.x >= 88.0, "The plan-lock CTA must remain inside a usable compact timing-row width.")

	board.combat_progress_button.request_progress()
	await process_frame
	_expect(str(board.get_meta("presentation_state", "")) == "plan_locked", "The first CTA activation must lock the plan instead of resolving it.")
	_expect(int(board.get_meta("resolution_count", 0)) == 0, "Plan lock must not call the combat resolver.")
	_expect(board.combat_progress_button._button.text == "3수 실행", "Only a locked plan may expose the compact current-action execution CTA.")
	_expect(not board.action_selection_dock.switching_enabled, "Plan lock must prevent changing action-card sources.")
	_expect(bool(board.get_meta("inputs_locked", false)), "Plan lock must prevent timing and placement changes.")
	_expect(not board.planning_surface.visible and not board.action_selection_dock.visible and not board.action_timing_panel.visible, "A locked plan must remove the entire lower planning surface before the duel reveal, leaving only the top and middle combat presentation.")
	var duel_surface := board.get_node_or_null("DuelStageSurface") as Control
	_expect(duel_surface != null and duel_surface.get_global_rect().encloses(board.combat_progress_button.get_global_rect()), "The locked-plan execution CTA must move into the duel stage rather than remain in the hidden planning row.")
	_expect(duel_surface != null and duel_surface.get_global_rect().end.y >= board.get_global_rect().end.y - 1.0, "When the planning surface disappears, the duel stage must expand through the released space instead of leaving an empty black lower screen.")
	_expect(board.battle_background.get_global_rect().end.y >= board.get_global_rect().end.y - 1.0, "The locked-plan duel field must extend the grounded courtyard background through the released lower space.")

	board.combat_progress_button.request_progress()
	await process_frame
	_expect(int(board.get_meta("resolution_count", 0)) == 1, "The second CTA activation must resolve the locked bundle exactly once.")
	_expect(str(board.get_meta("presentation_state", "")) in ["committed", "resolving", "presenting_result"], "Second activation must enter the existing resolution presentation flow.")

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
