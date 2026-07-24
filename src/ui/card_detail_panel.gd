class_name CardDetailPanel
extends PanelContainer

var definition: Dictionary = {}
var pinned := false
var _built := false
var _title: Label
var _category: Label
var _mode: Label
var _content: VBoxContainer
var _scroll: ScrollContainer

func _ready() -> void:
    custom_minimum_size = Vector2(310.0, 350.0)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _build()
    _apply_definition()

func set_definition(value: Dictionary) -> void:
    show_definition(value, false)

func show_definition(value: Dictionary, value_pinned: bool = false) -> void:
    definition = value.duplicate(true)
    pinned = value_pinned
    if is_inside_tree():
        _build()
        _apply_definition()
    visible = not definition.is_empty()

func set_pinned(value: bool) -> void:
    pinned = value
    _refresh_mode_label()

func clear_definition() -> void:
    definition.clear()
    pinned = false
    if is_inside_tree():
        _apply_definition()
    visible = false

func _build() -> void:
    if _built:
        return
    _built = true
    add_theme_stylebox_override("panel", _panel_style())

    var column := VBoxContainer.new()
    column.name = "CardDetailColumn"
    column.add_theme_constant_override("separation", 7)
    add_child(column)

    var header := HBoxContainer.new()
    header.name = "CardDetailHeader"
    column.add_child(header)

    _title = Label.new()
    _title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _title.add_theme_font_size_override("font_size", 27)
    _title.add_theme_color_override("font_color", Color("ead8b4"))
    header.add_child(_title)

    _category = Label.new()
    _category.add_theme_font_size_override("font_size", 16)
    _category.add_theme_color_override("font_color", Color("d6b36c"))
    header.add_child(_category)

    _mode = Label.new()
    _mode.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    _mode.add_theme_font_size_override("font_size", 12)
    _mode.add_theme_color_override("font_color", Color("9f9484"))
    column.add_child(_mode)

    _scroll = ScrollContainer.new()
    _scroll.name = "CardDetailScroll"
    _scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    _scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    column.add_child(_scroll)

    _content = VBoxContainer.new()
    _content.name = "CardDetailContent"
    _content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _content.add_theme_constant_override("separation", 5)
    _scroll.add_child(_content)

    set_meta("step", 7)
    set_meta("layout_role", "left_overlay")
    set_meta("hover_preview", true)
    set_meta("click_pin", true)
    set_meta("blank_click_close", true)
    set_meta("action_placement_enabled", false)

func _apply_definition() -> void:
    if not _built:
        return
    for child in _content.get_children():
        child.free()
    if definition.is_empty():
        _title.text = "카드를 선택하세요"
        _category.text = ""
        _refresh_mode_label()
        return

    _title.text = str(definition.get("name", ""))
    _category.text = str(definition.get("category_label", ""))
    _add_row("소속", "[%s]" % str(definition.get("source_label", "")))
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
    _add_separator()
    _add_section("", str(definition.get("flavor", "")), true)
    _refresh_mode_label()

func _refresh_mode_label() -> void:
    if _mode == null:
        return
    if definition.is_empty():
        _mode.text = "카드에 마우스를 올려 상세 확인"
    elif pinned:
        _mode.text = "클릭 고정 · 같은 카드 또는 빈 공간 클릭으로 닫기"
    else:
        _mode.text = "마우스 보기 · 클릭하면 고정"
    set_meta("pinned", pinned)
    set_meta("card_id", str(definition.get("id", "")))

func _add_row(key: String, value: String) -> void:
    var row := HBoxContainer.new()
    var key_label := Label.new()
    key_label.custom_minimum_size = Vector2(88.0, 0.0)
    key_label.text = key
    key_label.add_theme_color_override("font_color", Color("cda960"))
    key_label.add_theme_font_size_override("font_size", 16)
    var value_label := Label.new()
    value_label.text = value
    value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    value_label.add_theme_color_override("font_color", Color("e9dfcd"))
    value_label.add_theme_font_size_override("font_size", 16)
    row.add_child(key_label)
    row.add_child(value_label)
    _content.add_child(row)

func _add_section(title: String, value: String, muted := false) -> void:
    if not title.is_empty():
        var label := Label.new()
        label.text = title
        label.add_theme_color_override("font_color", Color("cda960"))
        label.add_theme_font_size_override("font_size", 16)
        _content.add_child(label)
    var body := Label.new()
    body.text = value
    body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body.add_theme_font_size_override("font_size", 16)
    body.add_theme_color_override("font_color", Color("9f9484") if muted else Color("e9dfcd"))
    _content.add_child(body)

func _add_separator() -> void:
    var separator := HSeparator.new()
    separator.add_theme_color_override("separator", Color("5f492d"))
    _content.add_child(separator)

func get_detail_snapshot() -> Dictionary:
    return {
        "step": 7,
        "layout_role": "left_overlay",
        "visible": visible,
        "pinned": pinned,
        "card_id": str(definition.get("id", "")),
        "hover_preview": true,
        "click_pin": true,
        "blank_click_close": true,
        "action_placement_enabled": false
    }

func _panel_style() -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.035, 0.040, 0.043, 0.97)
    style.border_color = Color("8d6b35")
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.content_margin_left = 18
    style.content_margin_right = 18
    style.content_margin_top = 16
    style.content_margin_bottom = 16
    return style
