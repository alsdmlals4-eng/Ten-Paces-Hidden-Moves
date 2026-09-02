class_name ObservationRevealPanel
extends Control

const FRAME := preload("res://assets/ui/duel/observation_reveal_frame_01_v1.png")
const ALLOWED_TYPES = ["전조", "이동", "공격", "방어", "회피", "준비", "자원", "관찰"]
const MAX_VISIBLE_TYPES := 3

var _frame: TextureRect
var _title: Label
var _hint: Label
var _rows: Array[Label] = []
var _revealed_types: Array[String] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame = TextureRect.new()
	_frame.name = "ObservationRevealFrame"
	_frame.texture = FRAME
	_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_frame.stretch_mode = TextureRect.STRETCH_SCALE
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_frame)

	_title = _make_label(16, Color("ead8b4"))
	_title.name = "ObservationTitle"
	_title.text = "상대 행동 관찰"
	_hint = _make_label(11, Color("aa977c"))
	_hint.name = "ObservationHint"
	_hint.text = "공개된 행동 유형만 표시"
	for index in range(MAX_VISIBLE_TYPES):
		var row := _make_label(14, Color("f0dfbc"))
		row.name = "ObservationType%02d" % (index + 1)
		_rows.append(row)
	set_meta("observation_frame_path", "res://assets/ui/duel/observation_reveal_frame_01_v1.png")
	set_meta("observation_frame_loaded", FRAME != null)
	set_meta("observation_private_fields_visible", false)
	resized.connect(_layout)
	_refresh()
	_layout()

func set_revealed_types(value: Array) -> void:
	_revealed_types.clear()
	_append_safe_types(value)
	_refresh()

func clear_revealed_types() -> void:
	_revealed_types.clear()
	_refresh()

func has_revealed_types() -> bool:
	return not _revealed_types.is_empty()

func get_observation_snapshot() -> Dictionary:
	return {
		"frame_loaded": FRAME != null,
		"revealed_types": _revealed_types.duplicate(),
		"private_fields_visible": false,
		"allowed_types": ALLOWED_TYPES.duplicate(),
		"max_visible_types": MAX_VISIBLE_TYPES
	}

func _append_safe_types(value) -> void:
	if _revealed_types.size() >= MAX_VISIBLE_TYPES:
		return
	if typeof(value) == TYPE_ARRAY:
		for nested in value:
			_append_safe_types(nested)
			if _revealed_types.size() >= MAX_VISIBLE_TYPES:
				return
		return
	if typeof(value) != TYPE_STRING:
		return
	var action_type := str(value).strip_edges()
	if action_type in ALLOWED_TYPES and action_type not in _revealed_types:
		_revealed_types.append(action_type)

func _make_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.clip_text = true
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(label)
	return label

func _refresh() -> void:
	for index in range(_rows.size()):
		var row := _rows[index]
		row.text = "[%s]" % _revealed_types[index] if index < _revealed_types.size() else ""
		row.visible = index < _revealed_types.size()
	tooltip_text = "상대의 잠긴 행동 유형만 표시합니다. 기술명, 목표, 피해, 방향, 비용, 숨은 계획은 공개하지 않습니다."
	accessibility_name = "상대 행동 관찰"
	accessibility_description = tooltip_text
	set_meta("revealed_types", _revealed_types.duplicate())
	set_meta("observation_private_fields_visible", false)

func _layout() -> void:
	if _title == null:
		return
	var width := maxf(1.0, size.x)
	var height := maxf(1.0, size.y)
	_title.position = Vector2(width * 0.17, height * 0.09)
	_title.size = Vector2(width * 0.66, height * 0.14)
	_hint.position = Vector2(width * 0.16, height * 0.22)
	_hint.size = Vector2(width * 0.68, height * 0.10)
	for index in range(_rows.size()):
		var row := _rows[index]
		row.position = Vector2(width * 0.20, height * (0.37 + float(index) * 0.18))
		row.size = Vector2(width * 0.60, height * 0.13)
