class_name CombatActionRevealOverlay
extends Control

const INK := Color("17120f")
const INK_SOFT := Color(0.08, 0.06, 0.045, 0.42)
const PAPER := Color("ddd0ae")
const PAPER_DARK := Color("b6a17b")
const GOLD := Color("d7b66b")
const MUTED := Color("655543")
const PLAYER_ACCENT := Color("6f9db5")
const ENEMY_ACCENT := Color("b65d51")

var _heading: Label
var _phase: Label
var _versus: Label
var _result: Label
var _ink_veil: ColorRect
var _player_widgets: Dictionary = {}
var _enemy_widgets: Dictionary = {}
var _snapshot: Dictionary = {}
var _presentation_rect := Rect2()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	resized.connect(_layout_cards)
	hide_reveal()

func show_timing(timing: int, phase: String, events_value: Array, reduced_motion: bool) -> void:
	var player_events := _actor_events(events_value, "player")
	var enemy_events := _actor_events(events_value, "enemy")
	_fill_callout(_player_widgets, player_events, "강호낭인", PLAYER_ACCENT)
	_fill_callout(_enemy_widgets, enemy_events, "상대", ENEMY_ACCENT)
	_heading.text = "대응" if phase == "response" else "%d번째 행동 공개" % timing
	_phase.text = "대응 확인" if phase == "response" else "한 수씩 겨룬다"
	_result.text = _result_text(player_events, enemy_events)
	_snapshot = {
		"timing": timing,
		"phase": phase,
		"event_count": player_events.size() + enemy_events.size(),
		"player_action_count": player_events.size(),
		"enemy_action_count": enemy_events.size(),
		"future_action_visible": false,
		"selection_cards_visible": false,
		"action_callouts_visible": true,
		"result_text": _result.text
	}
	visible = true
	modulate = Color.WHITE
	if not reduced_motion:
		modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.14)
	_layout_cards()

func hide_reveal() -> void:
	visible = false
	modulate = Color.WHITE

func get_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)

func configure_presentation_rect(value: Rect2) -> void:
	_presentation_rect = value
	_layout_cards()

func get_reveal_rect() -> Rect2:
	var local_rect := _resolved_presentation_rect()
	return Rect2(global_position + local_rect.position, local_rect.size)

func _build() -> void:
	_ink_veil = ColorRect.new()
	_ink_veil.name = "InkVeil"
	_ink_veil.color = INK_SOFT
	_ink_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ink_veil.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	add_child(_ink_veil)

	_heading = Label.new()
	_heading.name = "RevealHeading"
	_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_heading.add_theme_font_size_override("font_size", 28)
	_heading.add_theme_color_override("font_color", GOLD)
	_heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_heading)

	_phase = Label.new()
	_phase.name = "RevealPhase"
	_phase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_phase.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_phase.add_theme_font_size_override("font_size", 15)
	_phase.add_theme_color_override("font_color", Color("eadbb9"))
	_phase.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_phase)

	_player_widgets = _make_action_callout("PlayerActionCallout")
	_enemy_widgets = _make_action_callout("EnemyActionCallout")
	add_child(_player_widgets["panel"])
	add_child(_enemy_widgets["panel"])

	_versus = Label.new()
	_versus.name = "RevealVersus"
	_versus.text = "VS"
	_versus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_versus.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_versus.add_theme_font_size_override("font_size", 32)
	_versus.add_theme_color_override("font_color", GOLD)
	_versus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_versus)

	_result = Label.new()
	_result.name = "RevealResult"
	_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result.add_theme_font_size_override("font_size", 16)
	_result.add_theme_color_override("font_color", Color("f0e5ca"))
	_result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_result)

func _make_action_callout(node_name: String) -> Dictionary:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(INK, 0.84)
	style.border_color = PAPER_DARK
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 4
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 5.0
	style.content_margin_bottom = 5.0
	panel.add_theme_stylebox_override("panel", style)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 3)
	panel.add_child(column)

	var side := Label.new()
	side.name = "Side"
	side.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	side.add_theme_font_size_override("font_size", 13)
	side.add_theme_color_override("font_color", MUTED)
	side.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(side)

	var action_name := Label.new()
	action_name.name = "ActionName"
	action_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_name.add_theme_font_size_override("font_size", 17)
	action_name.add_theme_color_override("font_color", PAPER)
	action_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(action_name)

	var facts := Label.new()
	facts.name = "Facts"
	facts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	facts.add_theme_font_size_override("font_size", 11)
	facts.add_theme_color_override("font_color", Color("c4b391"))
	facts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(facts)

	var outcome := Label.new()
	outcome.name = "Outcome"
	outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outcome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outcome.add_theme_font_size_override("font_size", 11)
	outcome.add_theme_color_override("font_color", Color("e8d8b7"))
	outcome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(outcome)

	return {"panel": panel, "style": style, "side": side, "name": action_name, "facts": facts, "outcome": outcome}

func _fill_callout(widgets: Dictionary, events: Array, side_name: String, accent: Color) -> void:
	var style := widgets.get("style") as StyleBoxFlat
	if style != null:
		style.border_color = accent
	var side := widgets.get("side") as Label
	var action_name := widgets.get("name") as Label
	var facts := widgets.get("facts") as Label
	var outcome := widgets.get("outcome") as Label
	if side != null:
		side.text = side_name
	if events.is_empty():
		if action_name != null:
			action_name.text = "행동 없음"
		if facts != null:
			facts.text = "이번 수에는 드러난 행동이 없습니다"
		if outcome != null:
			outcome.text = "상대의 다음 수는 공개하지 않습니다"
		return
	var first: Dictionary = events[0]
	if action_name != null:
		action_name.text = str(first.get("card_name", "행동"))
	if facts != null:
		facts.text = "%s · %d수" % [str(first.get("category_label", first.get("category", "행동"))), int(first.get("action_slots", 1))]
		if str(first.get("category", "")) == "attack":
			facts.text += " · 사거리 %s" % str(first.get("range_text", "-"))
	if outcome != null:
		outcome.text = _event_outcome(first)
		if events.size() > 1:
			outcome.text += "\n같은 수 추가 행동 %d개" % (events.size() - 1)

func _actor_events(events_value: Array, actor: String) -> Array:
	var result: Array = []
	for value in events_value:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var event: Dictionary = value
		if str(event.get("type", "")) not in ["action_result", "clash"]:
			continue
		if str(event.get("actor", "")) == actor:
			result.append(event.duplicate(true))
	return result

func _result_text(player_events: Array, enemy_events: Array) -> String:
	var outcome_parts := PackedStringArray()
	for event in player_events:
		outcome_parts.append("나 · %s" % _event_outcome(event as Dictionary))
	for event in enemy_events:
		outcome_parts.append("상대 · %s" % _event_outcome(event as Dictionary))
	return "교전 결과 · %s" % " / ".join(outcome_parts) if not outcome_parts.is_empty() else "교전 결과 · 이번 수에는 판정할 행동이 없습니다"

func _event_outcome(event: Dictionary) -> String:
	var outcome := str(event.get("outcome", ""))
	if outcome == "clash_draw":
		return "합 상쇄"
	if outcome == "clash_win":
		return "합 승리 · 피해 %d" % int(event.get("damage", 0))
	if outcome == "clash_loss":
		return "합 패배 · 피해 %d" % int(event.get("damage", 0))
	if outcome == "interrupted":
		return "중단"
	if outcome == "miss_direction":
		return "방향 실패"
	if outcome == "miss_range":
		return "사거리 실패"
	if str(event.get("defense_outcome", "")) == "block":
		return "막기 · 피해 경감"
	if str(event.get("defense_outcome", "")) == "evade":
		return "회피 · 피해 없음"
	if int(event.get("damage", 0)) > 0:
		return "피해 %d" % int(event.get("damage", 0))
	return "실행"

func _layout_cards() -> void:
	if size.x <= 0.0 or size.y <= 0.0 or _heading == null:
		return
	var region := _resolved_presentation_rect()
	if is_instance_valid(_ink_veil):
		_ink_veil.position = region.position
		_ink_veil.size = region.size
	var card_width := clampf(region.size.x * 0.17, 146.0, 214.0)
	var card_height := clampf(region.size.y * 0.20, 64.0, 86.0)
	var center_x := region.position.x + region.size.x * 0.5
	var card_y := clampf(region.position.y + region.size.y * 0.18, region.position.y + 76.0, region.end.y - card_height - 54.0)
	var side_gap := clampf(region.size.x * 0.055, 38.0, 72.0)
	(_player_widgets.get("panel") as Control).position = Vector2(center_x - side_gap - card_width, card_y)
	(_player_widgets.get("panel") as Control).size = Vector2(card_width, card_height)
	(_enemy_widgets.get("panel") as Control).position = Vector2(center_x + side_gap, card_y)
	(_enemy_widgets.get("panel") as Control).size = Vector2(card_width, card_height)
	_heading.position = Vector2(region.position.x + region.size.x * 0.30, region.position.y + maxf(12.0, region.size.y * 0.06))
	_heading.size = Vector2(region.size.x * 0.40, 38.0)
	_phase.position = Vector2(size.x * 0.30, _heading.position.y + 39.0)
	_phase.position.x = region.position.x + region.size.x * 0.30
	_phase.size = Vector2(region.size.x * 0.40, 24.0)
	_versus.position = Vector2(center_x - 32.0, card_y + card_height * 0.10)
	_versus.size = Vector2(64.0, 42.0)
	_result.position = Vector2(region.position.x + region.size.x * 0.20, card_y + card_height + 6.0)
	_result.size = Vector2(region.size.x * 0.60, 34.0)

func _resolved_presentation_rect() -> Rect2:
	if _presentation_rect.size.x > 0.0 and _presentation_rect.size.y > 0.0:
		return _presentation_rect
	return Rect2(Vector2.ZERO, size)
