class_name CardDetailPanel
extends PanelContainer

var definition: Dictionary = {}
var _built := false
var _title: Label
var _category: Label
var _content: VBoxContainer

func _ready() -> void:
    custom_minimum_size = Vector2(370, 650)
    _build()
    _apply_definition()

func set_definition(value: Dictionary) -> void:
    definition = value.duplicate(true)
    if is_inside_tree():
        _build()
        _apply_definition()

func _build() -> void:
    if _built: return
    _built = true
    add_theme_stylebox_override("panel", _panel_style())
    var column := VBoxContainer.new(); column.add_theme_constant_override("separation", 10); add_child(column)
    var header := HBoxContainer.new(); column.add_child(header)
    _title = Label.new(); _title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _title.add_theme_font_size_override("font_size", 34); _title.add_theme_color_override("font_color", Color("ead8b4")); header.add_child(_title)
    _category = Label.new(); _category.add_theme_font_size_override("font_size", 20)
    _category.add_theme_color_override("font_color", Color("d6b36c")); header.add_child(_category)
    _content = VBoxContainer.new(); _content.add_theme_constant_override("separation", 8); column.add_child(_content)

func _apply_definition() -> void:
    if not _built: return
    for child in _content.get_children(): child.queue_free()
    if definition.is_empty():
        _title.text = "카드를 선택하세요"; _category.text = ""; return
    _title.text = str(definition.get("name", "")); _category.text = str(definition.get("category_label", ""))
    _add_row("소속", str(definition.get("source_label", "")))
    _add_row("대상", str(definition.get("target", "")))
    _add_row("사거리", str(definition.get("range_text", "-")))
    _add_row("피해", str(definition.get("damage", "없음")))
    _add_row("조건", str(definition.get("condition", "없음")))
    _add_section("효과", str(definition.get("effect_text", "")))
    var tags: Array = definition.get("tags", [])
    _add_row("태그", "없음" if tags.is_empty() else " · ".join(tags))
    _add_separator()
    _add_row("행동 슬롯", str(definition.get("action_slots", 0)))
    _add_row("기력", str(definition.get("stamina_cost", 0)))
    _add_row("내력", str(definition.get("internal_cost", 0)))
    _add_separator(); _add_section("", str(definition.get("flavor", "")), true)

func _add_row(key: String, value: String) -> void:
    var row := HBoxContainer.new()
    var key_label := Label.new(); key_label.custom_minimum_size = Vector2(105, 0); key_label.text = key
    key_label.add_theme_color_override("font_color", Color("cda960")); key_label.add_theme_font_size_override("font_size", 20)
    var value_label := Label.new(); value_label.text = value; value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; value_label.add_theme_color_override("font_color", Color("e9dfcd")); value_label.add_theme_font_size_override("font_size", 20)
    row.add_child(key_label); row.add_child(value_label); _content.add_child(row); _add_separator()

func _add_section(title: String, value: String, muted := false) -> void:
    if not title.is_empty():
        var label := Label.new(); label.text = title; label.add_theme_color_override("font_color", Color("cda960")); label.add_theme_font_size_override("font_size", 20); _content.add_child(label)
    var body := Label.new(); body.text = value; body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body.add_theme_font_size_override("font_size", 20); body.add_theme_color_override("font_color", Color("9f9484") if muted else Color("e9dfcd")); _content.add_child(body)

func _add_separator() -> void:
    var separator := HSeparator.new(); separator.add_theme_color_override("separator", Color("5f492d")); _content.add_child(separator)

func _panel_style() -> StyleBoxFlat:
    var style := StyleBoxFlat.new(); style.bg_color = Color("0b0d0e"); style.border_color = Color("8d6b35")
    style.set_border_width_all(2); style.set_corner_radius_all(8)
    style.content_margin_left = 22; style.content_margin_right = 22; style.content_margin_top = 22; style.content_margin_bottom = 22
    return style
