class_name ActionTimingSlot
extends Control

const PANEL := Color(0.075, 0.062, 0.048, 0.96)
const PANEL_ACTIVE := Color(0.13, 0.10, 0.055, 0.98)
const PAPER := Color("e0cfaa")
const GOLD := Color("c79a50")
const MUTED := Color("8e8372")
const LOCKED := Color("4f4940")

var timing_index := 1
var bundle_index := 1
var local_index := 1
var slot_state := "locked"

var _timing_label: Label
var _placeholder_label: Label
var _status_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _timing_label = _make_label(13, PAPER)
    _placeholder_label = _make_label(22, MUTED)
    _status_label = _make_label(11, MUTED)
    resized.connect(_layout)
    _refresh()
    _layout()

func configure(global_index: int, group_index: int, timing_in_group: int, state: String) -> void:
    timing_index = global_index
    bundle_index = group_index
    local_index = timing_in_group
    slot_state = state
    set_meta("timing_index", timing_index)
    set_meta("bundle_index", bundle_index)
    set_meta("local_index", local_index)
    set_meta("slot_state", slot_state)
    set_meta("card_content", false)
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
    label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    add_child(label)
    return label

func _refresh() -> void:
    if _timing_label == null:
        return
    _timing_label.text = "%d수" % local_index
    _placeholder_label.text = "—"
    _status_label.text = _state_text()
    var accent := _state_color()
    _timing_label.add_theme_color_override("font_color", PAPER if slot_state != "locked" else MUTED)
    _placeholder_label.add_theme_color_override("font_color", accent)
    _status_label.add_theme_color_override("font_color", accent)

func _state_text() -> String:
    match slot_state:
        "passed":
            return "경과"
        "current":
            return "현재"
        "available":
            return "선택"
        _:
            return "잠김"

func _state_color() -> Color:
    match slot_state:
        "passed":
            return MUTED
        "current":
            return GOLD
        "available":
            return Color("d8bd7c")
        _:
            return LOCKED

func _layout() -> void:
    if _timing_label == null:
        return
    var width := maxf(1.0, size.x - 8.0)
    _timing_label.position = Vector2(4.0, 3.0)
    _timing_label.size = Vector2(width, 20.0)
    _placeholder_label.position = Vector2(4.0, 21.0)
    _placeholder_label.size = Vector2(width, maxf(20.0, size.y - 45.0))
    _status_label.position = Vector2(4.0, maxf(39.0, size.y - 22.0))
    _status_label.size = Vector2(width, 18.0)
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    var accent := _state_color()
    var fill := PANEL_ACTIVE if slot_state == "current" else PANEL
    if slot_state == "locked":
        fill = Color(PANEL, 0.72)
    draw_rect(Rect2(Vector2.ZERO, size), fill, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(accent, 0.78), false, 2.0)
    if slot_state == "current":
        draw_line(Vector2(8.0, 3.0), Vector2(maxf(8.0, size.x - 8.0), 3.0), GOLD, 3.0)
