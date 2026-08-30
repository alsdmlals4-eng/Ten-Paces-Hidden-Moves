class_name CombatActionRevealOverlay
extends Control

const INK := Color("17120f")
const INK_SOFT := Color(0.08, 0.06, 0.045, 0.86)
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
var _player_widgets: Dictionary = {}
var _enemy_widgets: Dictionary = {}
var _snapshot: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	resized.connect(_layout_cards)
	hide_reveal()

func show_timing(timing: int, phase: String, events_value: Array, reduced_motion: bool) -> void:
	var player_events := _actor_events(events_value, "player")
	var enemy_events := _actor_events(events_value, "enemy")
	_fill_card(_player_widgets, player_events, "강호낭인", PLAYER_ACCENT)
	_fill_card(_enemy_widgets, enemy_events, "상대", ENEMY_ACCENT)
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

func _build() -> void:
	var dim := ColorRect.new()
	dim.name = "InkVeil"
	dim.color = INK_SOFT
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

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

	_player_widgets = _make_action_card("PlayerActionCard")
	_enemy_widgets = _make_action_card("EnemyActionCard")
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

func _make_action_card(node_name: String) -> Dictionary:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(PAPER, 0.98)
	style.border_color = PAPER_DARK
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 8
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
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

	var art := TextureRect.new()
	art.name = "Illustration"
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.custom_minimum_size = Vector2(118.0, 82.0)
	art.modulate = Color(0.32, 0.29, 0.25, 0.96)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(art)

	var action_name := Label.new()
	action_name.name = "ActionName"
	action_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_name.add_theme_font_size_override("font_size", 20)
	action_name.add_theme_color_override("font_color", INK)
	action_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(action_name)

	var facts := Label.new()
	facts.name = "Facts"
	facts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	facts.add_theme_font_size_override("font_size", 12)
	facts.add_theme_color_override("font_color", MUTED)
	facts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(facts)

	var outcome := Label.new()
	outcome.name = "Outcome"
	outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outcome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outcome.add_theme_font_size_override("font_size", 13)
	outcome.add_theme_color_override("font_color", INK)
	outcome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(outcome)

	return {"panel": panel, "style": style, "side": side, "art": art, "name": action_name, "facts": facts, "outcome": outcome}

func _fill_card(widgets: Dictionary, events: Array, side_name: String, accent: Color) -> void:
	var style := widgets.get("style") as StyleBoxFlat
	if style != null:
		style.border_color = accent
	var side := widgets.get("side") as Label
	var art := widgets.get("art") as TextureRect
	var action_name := widgets.get("name") as Label
	var facts := widgets.get("facts") as Label
	var outcome := widgets.get("outcome") as Label
	if side != null:
		side.text = side_name
	if events.is_empty():
		if art != null:
			art.texture = null
		if action_name != null:
			action_name.text = "행동 없음"
		if facts != null:
			facts.text = "이번 수에는 드러난 행동이 없습니다"
		if outcome != null:
			outcome.text = "상대의 다음 수는 공개하지 않습니다"
		return
	var first: Dictionary = events[0]
	if art != null:
		art.texture = _texture_from_spec(first.get("illustration", {}))
	if action_name != null:
		action_name.text = str(first.get("card_name", "행동"))
	if facts != null:
		facts.text = "%s · 거리 %s · %d수" % [str(first.get("category_label", first.get("category", "행동"))), str(first.get("range_text", "-")), int(first.get("action_slots", 1))]
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

func _texture_from_spec(spec_value) -> Texture2D:
	if typeof(spec_value) != TYPE_DICTIONARY:
		return null
	var spec: Dictionary = spec_value
	var path := str(spec.get("atlas", ""))
	var region: Array = spec.get("region", [])
	if path.is_empty() or region.size() != 4 or not ResourceLoader.exists(path):
		return null
	var texture := AtlasTexture.new()
	texture.atlas = load(path) as Texture2D
	texture.region = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	return texture

func _layout_cards() -> void:
	if size.x <= 0.0 or size.y <= 0.0 or _heading == null:
		return
	var card_width := clampf(size.x * 0.25, 235.0, 340.0)
	var card_height := clampf(size.y * 0.43, 228.0, 312.0)
	var center_x := size.x * 0.5
	var card_y := clampf(size.y * 0.28, 118.0, size.y - card_height - 68.0)
	var side_gap := clampf(size.x * 0.11, 100.0, 164.0)
	(_player_widgets.get("panel") as Control).position = Vector2(center_x - side_gap - card_width, card_y)
	(_player_widgets.get("panel") as Control).size = Vector2(card_width, card_height)
	(_enemy_widgets.get("panel") as Control).position = Vector2(center_x + side_gap, card_y)
	(_enemy_widgets.get("panel") as Control).size = Vector2(card_width, card_height)
	_heading.position = Vector2(size.x * 0.30, maxf(18.0, size.y * 0.09))
	_heading.size = Vector2(size.x * 0.40, 42.0)
	_phase.position = Vector2(size.x * 0.30, _heading.position.y + 39.0)
	_phase.size = Vector2(size.x * 0.40, 26.0)
	_versus.position = Vector2(center_x - 44.0, card_y + card_height * 0.42)
	_versus.size = Vector2(88.0, 56.0)
	_result.position = Vector2(size.x * 0.18, card_y + card_height + 12.0)
	_result.size = Vector2(size.x * 0.64, 46.0)
