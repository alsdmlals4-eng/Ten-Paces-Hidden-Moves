class_name MomentumGauge
extends Control

const PANEL := Color(0.055, 0.047, 0.039, 0.94)
const GOLD := Color("e6a933")
const EMPTY := Color("4b4030")
const PAPER := Color("dbc9a4")
const MUTED := Color("a7977e")

var side: String = "player"
var current_value: int = 0
var maximum_value: int = 6

var _title_label: Label
var _value_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _title_label = Label.new()
    _title_label.text = "절초 기세"
    _title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _title_label.add_theme_font_size_override("font_size", 14)
    _title_label.add_theme_color_override("font_color", PAPER)
    add_child(_title_label)

    _value_label = Label.new()
    _value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _value_label.add_theme_font_size_override("font_size", 14)
    _value_label.add_theme_color_override("font_color", MUTED)
    add_child(_value_label)

    resized.connect(_layout)
    _refresh()
    _layout()

func configure(value_side: String, values: Array, fallback_maximum: int = 6) -> void:
    side = value_side
    maximum_value = maxi(1, fallback_maximum)
    if values.size() >= 2:
        current_value = clampi(int(values[0]), 0, int(values[1]))
        maximum_value = maxi(1, int(values[1]))
    if is_inside_tree():
        _refresh()
        _layout()
    queue_redraw()

func _refresh() -> void:
    if _value_label == null:
        return
    _value_label.text = "%d/%d" % [current_value, maximum_value]

func _layout() -> void:
    if _title_label == null:
        return
    _title_label.position = Vector2(4.0, 10.0)
    _title_label.size = Vector2(maxf(1.0, size.x - 8.0), 20.0)
    _value_label.position = Vector2(4.0, maxf(82.0, size.y - 28.0))
    _value_label.size = Vector2(maxf(1.0, size.x - 8.0), 20.0)
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(GOLD, 0.52), false, 2.0)

    var count := maxi(1, maximum_value)
    var available_width := maxf(24.0, size.x - 24.0)
    var spacing := available_width / float(count)
    var radius := minf(10.0, spacing * 0.31)
    var center_y := minf(size.y * 0.52, 65.0)

    for index in range(count):
        var center := Vector2(12.0 + spacing * (float(index) + 0.5), center_y)
        var is_filled := index < current_value
        var fill := GOLD if is_filled else EMPTY
        draw_circle(center, radius + 3.0, Color(0.02, 0.018, 0.014, 0.95))
        draw_circle(center, radius, fill)
        draw_arc(center, radius + 1.0, 0.0, TAU, 24, Color(GOLD, 0.92 if is_filled else 0.48), 2.0, true)
        if is_filled:
            draw_circle(center + Vector2(-radius * 0.25, -radius * 0.25), radius * 0.25, Color(1.0, 0.91, 0.58, 0.78))
