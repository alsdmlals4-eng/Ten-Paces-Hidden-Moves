class_name ActionDetailPanel
extends PanelContainer

var definition: Dictionary = {}
var manual_definition: Dictionary = {}
var pinned := false
var detail_mode := "empty"

var _built := false
var _title: Label
var _source: Label
var _mode_label: Label
var _content: VBoxContainer
var _scroll: ScrollContainer
var _rows: Dictionary = {}
var _row_keys: Array[String] = []
var _section_titles: Array[String] = []
var _lineage_text := ""

func _ready() -> void:
    custom_minimum_size = Vector2(310.0, 350.0)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _build()
    _apply_content()
    if detail_mode == "empty":
        visible = false

func show_action(value: Dictionary, value_pinned: bool = false) -> void:
    definition = value.duplicate(true)
    manual_definition.clear()
    pinned = value_pinned
    detail_mode = "action" if not definition.is_empty() else "empty"
    if is_inside_tree():
        _build()
        _apply_content()
    visible = detail_mode != "empty"

func show_manual(value: Dictionary, value_pinned: bool = false) -> void:
    manual_definition = value.duplicate(true)
    definition.clear()
    pinned = value_pinned
    detail_mode = "manual" if not manual_definition.is_empty() else "empty"
    if is_inside_tree():
        _build()
        _apply_content()
    visible = detail_mode != "empty"

func clear_detail() -> void:
    definition.clear()
    manual_definition.clear()
    pinned = false
    detail_mode = "empty"
    if is_inside_tree():
        _apply_content()
    visible = false

func set_definition(value: Dictionary) -> void:
    show_action(value, false)

func show_definition(value: Dictionary, value_pinned: bool = false) -> void:
    show_action(value, value_pinned)

func set_pinned(value: bool) -> void:
    pinned = value
    _refresh_mode_label()

func clear_definition() -> void:
    clear_detail()

func get_detail_snapshot() -> Dictionary:
    return {
        "step": 7,
        "layout_role": "left_overlay",
        "mode": detail_mode,
        "visible": visible,
        "pinned": pinned,
        "title": _current_title(),
        "card_id": str(definition.get("id", "")),
        "manual_id": str(manual_definition.get("manual_id", "")),
        "row_keys": _row_keys.duplicate(),
        "rows": _rows.duplicate(true),
        "section_titles": _section_titles.duplicate(),
        "lineage_text": _lineage_text,
        "hover_preview": true,
        "click_pin": true,
        "blank_click_close": true,
        "action_placement_enabled": false
    }

func _build() -> void:
    if _built:
        return
    _built = true
    add_theme_stylebox_override("panel", _panel_style())

    var column := VBoxContainer.new()
    column.name = "ActionDetailColumn"
    column.add_theme_constant_override("separation", 7)
    add_child(column)

    var header := HBoxContainer.new()
    header.name = "ActionDetailHeader"
    column.add_child(header)

    _title = Label.new()
    _title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _title.add_theme_font_size_override("font_size", 25)
    _title.add_theme_color_override("font_color", Color("ead8b4"))
    _title.clip_text = true
    header.add_child(_title)

    _source = Label.new()
    _source.add_theme_font_size_override("font_size", 14)
    _source.add_theme_color_override("font_color", Color("d6b36c"))
    _source.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    header.add_child(_source)

    _mode_label = Label.new()
    _mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    _mode_label.add_theme_font_size_override("font_size", 12)
    _mode_label.add_theme_color_override("font_color", Color("9f9484"))
    column.add_child(_mode_label)

    _scroll = ScrollContainer.new()
    _scroll.name = "ActionDetailScroll"
    _scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    _scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    column.add_child(_scroll)

    _content = VBoxContainer.new()
    _content.name = "ActionDetailContent"
    _content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _content.add_theme_constant_override("separation", 5)
    _scroll.add_child(_content)

    set_meta("step", 7)
    set_meta("layout_role", "left_overlay")
    set_meta("hover_preview", true)
    set_meta("click_pin", true)
    set_meta("blank_click_close", true)
    set_meta("action_placement_enabled", false)

func _apply_content() -> void:
    if not _built:
        return
    for child in _content.get_children():
        child.free()
    _rows.clear()
    _row_keys.clear()
    _section_titles.clear()
    _lineage_text = ""

    match detail_mode:
        "action":
            _apply_action()
        "manual":
            _apply_manual()
        _:
            _title.text = "행동을 선택하세요"
            _source.text = ""
    _refresh_mode_label()
    set_meta("detail_mode", detail_mode)
    set_meta("pinned", pinned)
    set_meta("card_id", str(definition.get("id", "")))
    set_meta("manual_id", str(manual_definition.get("manual_id", "")))

func _apply_action() -> void:
    _title.text = str(definition.get("name", "행동"))
    _source.text = str(definition.get("source_label", definition.get("category_label", "")))
    var source_kind := str(definition.get("source_kind", definition.get("source", "")))
    var detail: Dictionary = definition.get("detail", {})

    _add_row("출처", str(definition.get("source_label", "-")))
    if not str(definition.get("category_label", "")).is_empty() or not str(definition.get("category", "")).is_empty():
        _add_row("계열", str(definition.get("category_label", definition.get("category", "-"))))
    _add_row("수 점유", "%d수" % maxi(1, int(definition.get("action_slots", 1))))
    _add_row("전조", "%d수" % maxi(0, int(definition.get("telegraph_count", maxi(0, int(definition.get("action_slots", 1)) - 1)))))
    _add_row("실행", "%d수" % maxi(1, int(definition.get("execution_count", 1))))
    _add_row("기력", str(maxi(0, int(definition.get("stamina_cost", 0)))))
    _add_row("내력", str(maxi(0, int(definition.get("internal_cost", 0)))))
    if source_kind == "ultimate" or int(definition.get("momentum_cost", 0)) > 0:
        _add_row("절초기세", str(maxi(0, int(definition.get("momentum_cost", 5)))))
    _add_row("사거리", str(definition.get("range_text", "-")))

    var target := str(detail.get("target", definition.get("target", "")))
    if not target.is_empty():
        _add_row("대상", target)
    var hits := maxi(0, int(detail.get("hits", definition.get("hits", 0))))
    if hits > 0:
        _add_row("타격", "%d회" % hits)
    var movement_timing := _movement_timing_text(definition)
    if not movement_timing.is_empty():
        _add_row("이동 시점", movement_timing)
    if definition.has("unlock_mastery"):
        _add_row("해금 성급", "%d성" % maxi(0, int(definition.get("unlock_mastery", 0))))
    if definition.has("current_mastery"):
        _add_row("현재 성급", "%d성" % maxi(0, int(definition.get("current_mastery", 0))))
    if bool(definition.get("reserved", false)) or not str(definition.get("reservation_text", "")).is_empty():
        _add_row("예약 상태", str(definition.get("reservation_text", "예약됨")))
    if source_kind == "ultimate":
        _add_row("진행 전 환불", "가능" if bool(definition.get("refund_before_commit", true)) else "불가")

    var effect_text := str(detail.get("effect_text", definition.get("effect_text", "")))
    if not effect_text.is_empty():
        _add_section("효과", effect_text)
    var condition := str(detail.get("condition", definition.get("condition", "")))
    if not condition.is_empty() and condition != "없음":
        _add_section("조건", condition)
    var tags := _string_list(definition.get("tags", []))
    if not tags.is_empty():
        _add_row("태그", " · ".join(tags))
    var flavor := str(detail.get("flavor", definition.get("flavor", "")))
    if not flavor.is_empty():
        _add_separator()
        _add_section("", flavor, true)

func _apply_manual() -> void:
    _title.text = str(manual_definition.get("name", "무공서"))
    _source.text = "무공서"
    var mastery := maxi(0, int(manual_definition.get("mastery", 0)))
    var techniques: Array = manual_definition.get("techniques", [])
    var unlocked_count := 0
    var technique_lines := PackedStringArray()
    for value in techniques:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var technique: Dictionary = value
        var locked := bool(technique.get("locked", false))
        if not locked:
            unlocked_count += 1
        technique_lines.append("%s · %s" % [
            str(technique.get("name", "기술")),
            str(technique.get("lock_reason", "해금")) if locked else "사용 가능"
        ])

    _add_row("현재 성급", "%d성" % mastery)
    var roles := _string_list(manual_definition.get("role_tags", []))
    if not roles.is_empty():
        _add_row("역할", " · ".join(roles))
    _add_row("해금 기술", "%d/%d" % [unlocked_count, techniques.size()])
    _add_row("절초", "해금" if bool(manual_definition.get("ultimate_unlocked", false)) else "10성 미해금")
    if not technique_lines.is_empty():
        _add_section("기술", "\n".join(technique_lines))

    _lineage_text = "\n".join(PackedStringArray([
        "1성 패시브",
        "3성 기술 1",
        "5성 기술 1 강화",
        "7성 기술 2",
        "9성 기술 2 강화",
        "10성 절초 또는 진의"
    ]))
    _add_section("성급 계보", _lineage_text)

func _movement_timing_text(value: Dictionary) -> String:
    var explicit := str(value.get("move_timing", ""))
    if not explicit.is_empty():
        return explicit
    if bool(value.get("dash_before_attack", false)):
        return "공격 전"
    if int(value.get("move_range", 0)) > 0 or str(value.get("category", "")) == "move":
        return "실행 시"
    return ""

func _refresh_mode_label() -> void:
    if _mode_label == null:
        return
    if detail_mode == "empty":
        _mode_label.text = "행동에 마우스를 올려 상세 확인"
    elif pinned:
        _mode_label.text = "클릭 고정 · 빈 공간 클릭으로 닫기"
    else:
        _mode_label.text = "마우스 보기 · 클릭하면 고정"

func _add_row(key: String, value: String) -> void:
    _rows[key] = value
    _row_keys.append(key)
    var row := HBoxContainer.new()
    var key_label := Label.new()
    key_label.custom_minimum_size = Vector2(96.0, 0.0)
    key_label.text = key
    key_label.add_theme_color_override("font_color", Color("cda960"))
    key_label.add_theme_font_size_override("font_size", 15)
    var value_label := Label.new()
    value_label.text = value
    value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    value_label.add_theme_color_override("font_color", Color("e9dfcd"))
    value_label.add_theme_font_size_override("font_size", 15)
    row.add_child(key_label)
    row.add_child(value_label)
    _content.add_child(row)

func _add_section(title: String, value: String, muted := false) -> void:
    if not title.is_empty():
        _section_titles.append(title)
        var label := Label.new()
        label.text = title
        label.add_theme_color_override("font_color", Color("cda960"))
        label.add_theme_font_size_override("font_size", 15)
        _content.add_child(label)
    var body := Label.new()
    body.text = value
    body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body.add_theme_font_size_override("font_size", 15)
    body.add_theme_color_override("font_color", Color("9f9484") if muted else Color("e9dfcd"))
    _content.add_child(body)

func _add_separator() -> void:
    var separator := HSeparator.new()
    separator.add_theme_color_override("separator", Color("5f492d"))
    _content.add_child(separator)

func _current_title() -> String:
    if detail_mode == "manual":
        return str(manual_definition.get("name", ""))
    return str(definition.get("name", ""))

func _string_list(values) -> Array[String]:
    var result: Array[String] = []
    if typeof(values) != TYPE_ARRAY and typeof(values) != TYPE_PACKED_STRING_ARRAY:
        return result
    for value in values:
        result.append(str(value))
    return result

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
