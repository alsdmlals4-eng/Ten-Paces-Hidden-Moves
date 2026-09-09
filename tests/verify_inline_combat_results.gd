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
	var short_fixture := [{"type":"action_result", "actor":"player", "card_name":"짧은 공격", "category":"attack", "category_label":"공격", "action_slots":1, "outcome":"hit", "damage":1}]
	var fixture := [{"type":"clash", "actor":"player", "card_name":"매우 긴 이름의 실제 검증 공격", "category":"attack", "category_label":"공격", "action_slots":1, "outcome":"clash_win", "raw_damage":15, "clash_opponent_raw_damage":10, "clash_difference":5, "damage":5, "stamina_cost":2}]
	for viewport_size in [Vector2(1280, 720), Vector2(1280, 800), Vector2(1920, 1080)]:
		board.size = viewport_size
		overlay.size = viewport_size
		overlay.configure_presentation_rect(Rect2(Vector2.ZERO, viewport_size * Vector2(1.0, 0.62)))
		overlay.show_timing(1, "대응", fixture, true)
		for _frame in range(4):
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
		var heading_rect: Rect2 = overlay.get_node("RevealHeading").get_rect()
		var phase_rect: Rect2 = overlay.get_node("RevealPhase").get_rect()
		var versus_rect: Rect2 = overlay.get_node("RevealVersus").get_rect()
		var region := Rect2(Vector2.ZERO, viewport_size * Vector2(1.0, 0.62))
		for entry in [{"name":"heading", "rect":heading_rect}, {"name":"phase", "rect":phase_rect}, {"name":"player", "rect":player_rect}, {"name":"enemy", "rect":enemy_rect}, {"name":"VS", "rect":versus_rect}, {"name":"result", "rect":result_rect}]:
			var rect: Rect2 = entry["rect"]
			_expect(region.encloses(rect), "Reveal %s actual rect stays within region at %s" % [entry["name"], viewport_size])
		_expect(not result_rect.intersects(player_rect) and not result_rect.intersects(enemy_rect), "Actual result rect does not intersect callouts")
		_expect(not player_rect.intersects(enemy_rect) and not versus_rect.intersects(player_rect) and not versus_rect.intersects(enemy_rect), "Callouts and VS do not intrude on each other")
		_expect(not heading_rect.intersects(phase_rect) and not phase_rect.intersects(player_rect) and not phase_rect.intersects(enemy_rect), "Heading, phase and callouts retain separate rows")
		_expect(not bool(overlay.get_snapshot().get("future_action_visible", true)), "Fixture retains future-action guard")
		overlay.show_timing(1, "대응", short_fixture, true)
		for _frame in range(4):
			await process_frame
		var initial_short_height: float = (overlay.get_node("PlayerActionCallout") as Control).size.y
		overlay.show_timing(1, "대응", fixture, true)
		for _frame in range(4):
			await process_frame
		overlay.show_timing(1, "대응", short_fixture, true)
		for _frame in range(4):
			await process_frame
		var reset_short_height: float = (overlay.get_node("PlayerActionCallout") as Control).size.y
		_expect(reset_short_height <= initial_short_height + 1.0, "Short callout height resets after long content at %s: initial=%s reset=%s" % [viewport_size, initial_short_height, reset_short_height])
		_expect(reset_short_height < 180.0, "Short four-line callout does not retain captured 325px height at %s" % viewport_size)
		overlay.hide_reveal()
	var evade_fixture := [{"type":"action_result", "actor":"player", "card_name":"회피 확인", "category":"attack", "category_label":"공격", "action_slots":1, "damage":0, "defense_outcome":"evade"}]
	overlay.show_timing(1, "response", evade_fixture, true)
	var evade_column: Node = overlay.get_node("PlayerActionCallout").get_child(0)
	_expect(str(evade_column.get_node("Outcome").text).contains("회피 · 피해 없음"), "Evade displays authoritative actual zero-damage outcome")

	board.inline_result_label.visible = true
	board.inline_result_label.text = "실제 해결 원인 · 전진 공격이 거리를 좁혔습니다"
	for viewport_size in [Vector2(1280, 720), Vector2(1280, 800), Vector2(1920, 1080)]:
		board.size = viewport_size
		board._layout_board()
		for _frame in range(3):
			await process_frame
		var inline_rect: Rect2 = board.inline_result_label.get_global_rect()
		_expect(board.inline_result_label.is_visible_in_tree(), "Valid nonterminal inline cause remains visible at %s" % viewport_size)
		_expect(not inline_rect.intersects(board.action_timing_panel.get_global_rect()), "Inline result causal lane does not intersect timing panel at %s" % viewport_size)
		_expect(not inline_rect.intersects(board.combat_progress_button.get_global_rect()), "Inline result causal lane does not intersect progress controls at %s" % viewport_size)
		var dock = board.action_selection_dock
		_expect(bool(board.get_meta("inline_result_row_bounded", false)), "Inline result owns a bounded row at %s" % viewport_size)
		_expect(not inline_rect.intersects(dock.get_global_rect()), "Inline result does not intersect actual ActionSelectionDock at %s" % viewport_size)
		for tab in [dock.basic_tab, dock.martial_tab, dock.ultimate_tab]:
			_expect(not inline_rect.intersects(tab.get_global_rect()), "Inline result does not intersect an actual source tab at %s" % viewport_size)
		_expect(dock.basic_panel.buttons.size() == 10, "All ten basic product action cards exist at %s" % viewport_size)
		for button in dock.basic_panel.buttons:
			_expect(button.is_visible_in_tree(), "Each basic product action card remains visible at %s" % viewport_size)
			_expect(not inline_rect.intersects(button.get_global_rect()), "Inline result does not intersect a visible product action card at %s" % viewport_size)
			_expect(Rect2(Vector2.ZERO, viewport_size).encloses(button.get_global_rect()), "Visible product action card stays wholly inside viewport at %s" % viewport_size)
		# Current-only planning retains hidden past/future nodes, not their old
		# geometry as visible obstacles. Prove the exact live set before overlap.
		var expected_indices: PackedInt32Array = board.action_timing_panel.get_visible_timing_indices()
		_expect(expected_indices == PackedInt32Array([4, 5, 6]), "The completed first bundle exposes exactly the three second-bundle slots")
		var tested_visible := 0
		for slot in board.action_timing_panel.slots:
			var expected_visible: bool = slot.timing_index in expected_indices
			_expect(slot.is_visible_in_tree() == expected_visible, "Slot visibility matches the actual current bundle at %s" % viewport_size)
			if slot.is_visible_in_tree():
				tested_visible += 1
				_expect(not inline_rect.intersects(slot.get_global_rect()), "Inline result does not intersect visible timing slots at %s" % viewport_size)
		_expect(tested_visible == 3 and tested_visible == expected_indices.size(), "Overlap checks cover every expected visible slot, never an empty set")

	board.queue_free()
	await process_frame
	if failures.is_empty():
		print("INLINE_COMBAT_RESULTS_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
