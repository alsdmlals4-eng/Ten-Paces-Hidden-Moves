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
	var fixture := [{"type":"clash", "actor":"player", "card_name":"매우 긴 이름의 실제 검증 공격", "category":"attack", "category_label":"공격", "action_slots":1, "outcome":"clash_win", "raw_damage":15, "clash_opponent_raw_damage":10, "clash_difference":5, "damage":5, "stamina_cost":2}]
	for viewport_size in [Vector2(1280, 720), Vector2(1280, 800), Vector2(1920, 1080)]:
		board.size = viewport_size
		overlay.size = viewport_size
		overlay.configure_presentation_rect(Rect2(Vector2.ZERO, viewport_size * Vector2(1.0, 0.62)))
		overlay.show_timing(1, "대응", fixture, true)
		for _frame in range(2):
			await process_frame
		var player_column: Node = overlay.get_node("PlayerActionCallout").get_child(0)
		var facts := str(player_column.get_node("Facts").text)
		var outcome := str(player_column.get_node("Outcome").text)
		_expect(facts.contains("15") and facts.contains("10") and facts.contains("차이 5"), "Clash displays authoritative 15 vs 10 and difference 5")
		_expect(outcome.contains("피해 5"), "Clash displays actual damage 5")
		_expect(facts.contains("기력2") and not facts.contains("내력0"), "Only present cost fields are rendered")
		_expect(bool(overlay.get_meta("layout_bounded", false)), "Reveal cards and result are bounded at %s" % viewport_size)
		var player_rect: Rect2 = overlay.get_node("PlayerActionCallout").get_rect()
		var enemy_rect: Rect2 = overlay.get_node("EnemyActionCallout").get_rect()
		var result_rect: Rect2 = overlay.get_node("RevealResult").get_rect()
		_expect(not result_rect.intersects(player_rect) and not result_rect.intersects(enemy_rect), "Actual result rect does not intersect callouts")
		_expect(not bool(overlay.get_snapshot().get("future_action_visible", true)), "Fixture retains future-action guard")
		overlay.hide_reveal()
	var evade_fixture := [{"type":"action_result", "actor":"player", "card_name":"회피 확인", "category":"attack", "category_label":"공격", "action_slots":1, "damage":0, "defense_outcome":"evade"}]
	overlay.show_timing(1, "response", evade_fixture, true)
	var evade_column: Node = overlay.get_node("PlayerActionCallout").get_child(0)
	_expect(str(evade_column.get_node("Outcome").text).contains("회피 · 피해 없음"), "Evade displays authoritative actual zero-damage outcome")

	board.queue_free()
	await process_frame
	if failures.is_empty():
		print("INLINE_COMBAT_RESULTS_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
