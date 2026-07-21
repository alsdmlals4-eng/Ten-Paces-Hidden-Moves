class_name BasicCardTray
extends Control

const DATA_PATH := "res://data/cards/basic_cards.json"
const CARD_SCENE := preload("res://scenes/ui/basic_card_tray_item.tscn")

const PANEL := Color(0.045, 0.038, 0.030, 0.98)
const PAPER := Color("e0cfaa")
const GOLD := Color("c79a50")
const MUTED := Color("9b8c76")

var card_data: Dictionary = {}
var cards: Array[BasicCardTrayItem] = []

var _title_label: Label
var _status_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    card_data = _load_data()
    _build_content()
    resized.connect(_layout)
    _layout()

func _load_data() -> Dictionary:
    if not FileAccess.file_exists(DATA_PATH):
        push_error("STEP 6 basic card data was not found: %s" % DATA_PATH)
        return {}
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    if file == null:
        push_error("STEP 6 basic card data could not be opened: %s" % DATA_PATH)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("STEP 6 basic card data root must be a Dictionary.")
        return {}
    return parsed

func _build_content() -> void:
    _title_label = _make_label(15, PAPER, HORIZONTAL_ALIGNMENT_LEFT)
    _title_label.name = "BasicCardTrayTitle"
    _title_label.text = "기초 행동"

    _status_label = _make_label(12, MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
    _status_label.name = "BasicCardTrayStatus"
    _status_label.text = "7종 · 표시 전용"

    var definitions: Array = card_data.get("cards", [])
    for definition_value in definitions:
        if typeof(definition_value) != TYPE_DICTIONARY:
            continue
        var card := CARD_SCENE.instantiate() as BasicCardTrayItem
        card.name = "BasicCard%02d" % (cards.size() + 1)
        card.configure(definition_value as Dictionary)
        add_child(card)
        cards.append(card)

    set_meta("step", 6)
    set_meta("layout_role", "bottom_lower")
    set_meta("card_count", cards.size())
    set_meta("card_ids", "|".join(get_card_ids()))
    set_meta("data_path", DATA_PATH)
    set_meta("compact_variant", true)
    set_meta("interactions_enabled", false)
    set_meta("action_timing_above", true)

func _make_label(font_size: int, color: Color, alignment: int) -> Label:
    var label := Label.new()
    label.horizontal_alignment = alignment
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.clip_text = true
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    add_child(label)
    return label

func _layout() -> void:
    if _title_label == null or cards.is_empty():
        return

    var side_margin := 10.0
    var width := maxf(1.0, size.x - side_margin * 2.0)
    _title_label.position = Vector2(side_margin, 3.0)
    _title_label.size = Vector2(width * 0.45, 23.0)
    _status_label.position = Vector2(side_margin + width * 0.55, 3.0)
    _status_label.size = Vector2(width * 0.45, 23.0)

    var gap := clampf(size.x * 0.005, 4.0, 8.0)
    var total_gap := gap * float(cards.size() - 1)
    var card_width := maxf(108.0, (width - total_gap) / float(cards.size()))
    var card_y := 29.0
    var card_height := maxf(96.0, size.y - card_y - 8.0)
    var x := side_margin

    for card in cards:
        card.position = Vector2(x, card_y)
        card.size = Vector2(card_width, card_height)
        x += card_width + gap

    queue_redraw()

func get_card_ids() -> PackedStringArray:
    var ids := PackedStringArray()
    for card in cards:
        ids.append(str(card.definition.get("id", "")))
    return ids

func get_tray_snapshot() -> Dictionary:
    return {
        "step": 6,
        "layout_role": "bottom_lower",
        "card_count": cards.size(),
        "card_ids": get_card_ids(),
        "source": "basic",
        "compact_variant": true,
        "interactions_enabled": false,
        "action_timing_above": true
    }

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(GOLD, 0.72), false, 2.0)
    draw_line(Vector2(10.0, 27.0), Vector2(maxf(10.0, size.x - 10.0), 27.0), Color(GOLD, 0.30), 1.0)
