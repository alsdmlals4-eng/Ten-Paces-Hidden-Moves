class_name RoundHudPanel
extends Control

const PANEL := Color(0.07, 0.058, 0.045, 0.96)
const PAPER := Color("e0cfaa")
const GOLD := Color("c79a50")
const MUTED := Color("ad9d84")

var round_data: Dictionary = {}

var _round_label: Label
var _bundle_label: Label
var _selection_label: Label
var _order_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _round_label = _make_label(20, PAPER)
    _bundle_label = _make_label(14, GOLD)
    _selection_label = _make_label(14, PAPER)
    _order_label = _make_label(13, MUTED)
    resized.connect(_layout)
    _refresh()
    _layout()

func configure(value: Dictionary) -> void:
    round_data = value.duplicate(true)
    if is_inside_tree():
        _refresh()
        _layout()
    queue_redraw()

func _make_label(font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    add_child(label)
    return label

func _refresh() -> void:
    if _round_label == null:
        return
    var round_number := int(round_data.get("round_number", 1))
    var bundle_index := int(round_data.get("bundle_index", 1))
    var bundle_total := int(round_data.get("bundle_total", 3))
    _round_label.text = "제 %d 라운드" % round_number
    _bundle_label.text = "행동 묶음  %d/%d" % [bundle_index, bundle_total]
    _selection_label.text = str(round_data.get("selection_text", "1수 · 2수 · 3수 선택"))
    _order_label.text = str(round_data.get("resolution_order", "대응 → 속공 → 이동 → 일반 공격"))

func _layout() -> void:
    if _round_label == null:
        return
    var width := maxf(1.0, size.x - 16.0)
    _round_label.position = Vector2(8.0, 8.0)
    _round_label.size = Vector2(width, 28.0)
    _bundle_label.position = Vector2(8.0, 35.0)
    _bundle_label.size = Vector2(width, 20.0)
    _selection_label.position = Vector2(8.0, 57.0)
    _selection_label.size = Vector2(width, 22.0)
    _order_label.position = Vector2(8.0, maxf(84.0, size.y - 30.0))
    _order_label.size = Vector2(width, 20.0)
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(GOLD, 0.70), false, 2.0)
    draw_line(Vector2(size.x * 0.12, 82.0), Vector2(size.x * 0.88, 82.0), Color(GOLD, 0.52), 1.0)
    draw_line(Vector2(size.x * 0.5 - 28.0, 4.0), Vector2(size.x * 0.5 + 28.0, 4.0), GOLD, 3.0)
