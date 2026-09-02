class_name ActionChoiceCard
extends Button

const PAPER_SURFACE := Color("d9ccb1")
const PAPER_HOVER := Color("eee2c9")
const CHARCOAL_INK := Color("211c17")
const RESTRAINED_GOLD := Color("b99254")

var action_definition: Dictionary = {}

func configure_action(definition: Dictionary, illustration_policy: String, status_text: String = "") -> void:
	action_definition = definition.duplicate(true)
	for child in get_children():
		child.queue_free()
	custom_minimum_size = Vector2(0.0, 138.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	focus_mode = Control.FOCUS_ALL
	text = ""
	tooltip_text = _tooltip_text(status_text)
	accessibility_name = _accessibility_name(status_text)
	accessibility_description = _accessibility_description(status_text)
	_apply_paper_style(_category(), bool(action_definition.get("locked", false)))
	set_meta("card_surface", "shared_action_card_grid")
	set_meta("illustration_policy", illustration_policy)
	set_meta("action_id", str(action_definition.get("id", "")))
	set_meta("locked", bool(action_definition.get("locked", false)))
	set_meta("keyboard_focus_ring", true)
	var has_illustration := illustration_policy in ["basic_atlas_only", "semantic_atlas"] and _has_illustration_spec()
	if has_illustration:
		_add_illustration()
	_add_name_label(has_illustration)
	_add_facts_label(has_illustration)
	_add_effect_or_tag_label(has_illustration, not status_text.is_empty())
	if not status_text.is_empty():
		_add_status_label(status_text)

func _add_illustration() -> void:
	var illustration := TextureRect.new()
	illustration.name = "CardIllustration"
	illustration.texture = _texture_from_spec(action_definition.get("illustration", {}))
	illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	illustration.modulate = Color(0.30, 0.27, 0.23, 0.94)
	illustration.set_anchors_preset(Control.PRESET_TOP_WIDE)
	illustration.offset_left = 7.0
	illustration.offset_top = 5.0
	illustration.offset_right = -7.0
	illustration.offset_bottom = 60.0
	add_child(illustration)

func _add_name_label(has_illustration: bool) -> void:
	var label := Label.new()
	label.name = "CardName"
	label.text = "%s  %d수" % [str(action_definition.get("name", "")), int(action_definition.get("action_slots", 1))]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", CHARCOAL_INK)
	label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE if has_illustration else Control.PRESET_TOP_WIDE)
	label.offset_left = 5.0
	label.offset_right = -5.0
	if has_illustration:
		label.offset_top = -72.0
		label.offset_bottom = -54.0
	else:
		label.offset_top = 7.0
		label.offset_bottom = 25.0
	add_child(label)

func _add_facts_label(has_illustration: bool) -> void:
	var label := Label.new()
	label.name = "CardFacts"
	label.text = _compact_card_facts()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color("4d4032"))
	label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE if has_illustration else Control.PRESET_TOP_WIDE)
	label.offset_left = 6.0
	label.offset_right = -6.0
	if has_illustration:
		label.offset_top = -54.0
		label.offset_bottom = -34.0
	else:
		label.offset_top = 26.0
		label.offset_bottom = 42.0
	add_child(label)

func _add_effect_or_tag_label(has_illustration: bool, has_status: bool) -> void:
	var label := Label.new()
	label.name = "CardEffectOrTag"
	label.text = _effect_or_tag_text()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color("5a4a37"))
	label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE if has_illustration else Control.PRESET_TOP_WIDE)
	label.offset_left = 6.0
	label.offset_right = -6.0
	if has_illustration:
		label.offset_top = -34.0
		label.offset_bottom = -18.0 if has_status else -6.0
	else:
		label.offset_top = 44.0
		label.offset_bottom = 74.0 if not has_status else 67.0
	add_child(label)

func _add_status_label(status_text: String) -> void:
	var label := Label.new()
	label.name = "CardStatus"
	label.text = status_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color("7e2f28") if not bool(action_definition.get("locked", false)) else Color("d2c6ab"))
	label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	label.offset_left = 6.0
	label.offset_top = -18.0
	label.offset_right = -6.0
	label.offset_bottom = -3.0
	add_child(label)

func _compact_card_facts() -> String:
	var facts := PackedStringArray([
		str(action_definition.get("source_label", "행동")),
		_category_label(),
		"기력 %d" % int(action_definition.get("stamina_cost", 0)),
		"내력 %d" % int(action_definition.get("internal_cost", 0))
	])
	if _shows_range_fact():
		facts.append("사거리 %s" % _range_fact_text())
	var momentum := int(action_definition.get("momentum_cost", 0))
	if momentum > 0:
		facts.append("기세 %d" % momentum)
	return " · ".join(facts)

func _shows_range_fact() -> bool:
	return _category() == "attack" and not bool(action_definition.get("hide_range", false))

func _range_fact_text() -> String:
	if bool(action_definition.get("hide_range", false)):
		return "의도"
	var range_text := str(action_definition.get("range_text", "")).strip_edges()
	if not range_text.is_empty() and range_text != "-":
		return range_text
	match _category():
		"move":
			return "1"
		"response", "observation", "recovery", "strengthen":
			return "자신"
		_:
			return "제한 없음"

func _effect_or_tag_text() -> String:
	var detail: Dictionary = action_definition.get("detail", {}) as Dictionary
	var effect_text := str(detail.get("effect_text", action_definition.get("effect_text", "")))
	if not effect_text.is_empty():
		return effect_text
	var tags: Array = action_definition.get("tags", []) as Array
	if typeof(tags) == TYPE_ARRAY and not tags.is_empty():
		return str(tags[0])
	return "효과 정보 없음"

func _tooltip_text(status_text: String) -> String:
	var state: String = status_text if not status_text.is_empty() else (str(action_definition.get("lock_reason", "")) if bool(action_definition.get("locked", false)) else "사용 가능")
	return "%s · %s · %d수 · %s" % [
		str(action_definition.get("name", "")),
		str(action_definition.get("source_label", "행동")),
		int(action_definition.get("action_slots", 1)),
		state
	]

func _accessibility_name(status_text: String) -> String:
	var state: String = status_text if not status_text.is_empty() else (str(action_definition.get("lock_reason", "")) if bool(action_definition.get("locked", false)) else "사용 가능")
	var parts := PackedStringArray([
		str(action_definition.get("name", "")),
		str(action_definition.get("source_label", "행동")),
		_category_label(),
		"%d수" % int(action_definition.get("action_slots", 1)),
		"기력 %d" % int(action_definition.get("stamina_cost", 0)),
		"내력 %d" % int(action_definition.get("internal_cost", 0))
	])
	if _shows_range_fact():
		parts.append("사거리 %s" % _range_fact_text())
	var momentum := int(action_definition.get("momentum_cost", 0))
	if momentum > 0:
		parts.append("기세 %d" % momentum)
	parts.append(state)
	return ", ".join(parts)

func _accessibility_description(status_text: String) -> String:
	var state: String = status_text if not status_text.is_empty() else (str(action_definition.get("lock_reason", "")) if bool(action_definition.get("locked", false)) else "선택하면 현재 묶음에 자동 배치")
	return "%s. %s." % [_effect_or_tag_text(), state]

func _category_label() -> String:
	var explicit_label := str(action_definition.get("category_label", "")).strip_edges()
	if not explicit_label.is_empty():
		return explicit_label
	match _category():
		"move":
			return "이동"
		"attack":
			return "공격"
		"response":
			return "대응"
		"observation":
			return "관찰"
		"recovery":
			return "회복"
		"strengthen":
			return "강화"
		_:
			return "행동"

func _texture_from_spec(spec: Dictionary) -> Texture2D:
	var path := str(spec.get("atlas", ""))
	var region: Array = spec.get("region", [])
	if path.is_empty() or region.size() != 4 or not ResourceLoader.exists(path):
		return null
	var texture := AtlasTexture.new()
	texture.atlas = load(path) as Texture2D
	texture.region = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	return texture

func _has_illustration_spec() -> bool:
	var illustration: Dictionary = action_definition.get("illustration", {}) as Dictionary
	var atlas_path := str(illustration.get("atlas", ""))
	var region: Array = illustration.get("region", []) as Array
	return not atlas_path.is_empty() and region.size() == 4 and ResourceLoader.exists(atlas_path)

func _apply_paper_style(category: String, locked: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = PAPER_SURFACE if not locked else Color("777064")
	normal.border_color = _category_accent(category) if not locked else Color("5d5448")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(3)
	normal.content_margin_left = 8.0
	normal.content_margin_right = 8.0
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = PAPER_HOVER
	hover.border_color = RESTRAINED_GOLD
	hover.set_border_width_all(3)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("c8b68f")
	pressed.border_color = CHARCOAL_INK
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("777064")
	disabled.border_color = Color("5d5448")
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color(1.0, 1.0, 1.0, 0.08)
	focus.border_color = Color.WHITE
	focus.set_border_width_all(2)
	focus.set_corner_radius_all(3)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed)
	add_theme_stylebox_override("disabled", disabled)
	add_theme_stylebox_override("focus", focus)
	add_theme_color_override("font_color", CHARCOAL_INK)
	add_theme_color_override("font_hover_color", CHARCOAL_INK)
	add_theme_color_override("font_pressed_color", CHARCOAL_INK)
	add_theme_color_override("font_disabled_color", Color("d2c6ab"))

func _category() -> String:
	return str(action_definition.get("category", ""))

func _category_accent(category: String) -> Color:
	match category:
		"move":
			return Color("3f7f5b")
		"attack":
			return Color("9a443d")
		"response":
			return Color("3f668d")
		"recovery":
			return Color("a37a32")
		"strengthen":
			return Color("705184")
		_:
			return RESTRAINED_GOLD
