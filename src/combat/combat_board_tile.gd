class_name CombatBoardTile
extends PanelContainer

const DEFAULT_FILL := Color("62584c")
const DEFAULT_BORDER := Color("332d27")
const PLAYER_BORDER := Color("5f9bc2")
const ENEMY_BORDER := Color("bd6558")
const GOLD := Color("b99254")

var tile_index: int = 0
var occupied_role: String = ""
var foot_anchor_y_ratio: float = 0.68
var _number_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _number_label = Label.new()
    _number_label.name = "TileNumber"
    _number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _number_label.add_theme_font_size_override("font_size", 20)
    _number_label.add_theme_color_override("font_color", Color("e2c98e"))
    _number_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    _number_label.offset_top = -34.0
    _number_label.offset_bottom = -4.0
    add_child(_number_label)
    _refresh_visuals()

func configure(index: int, anchor_ratio: float) -> void:
    tile_index = index
    foot_anchor_y_ratio = clampf(anchor_ratio, 0.0, 1.0)
    set_meta("tile_index", tile_index)
    set_meta("foot_anchor_y_ratio", foot_anchor_y_ratio)
    _refresh_visuals()

func set_occupied(role: String) -> void:
    occupied_role = role
    set_meta("occupied_role", occupied_role)
    _refresh_visuals()

func get_foot_anchor_local() -> Vector2:
    return Vector2(size.x * 0.5, size.y * foot_anchor_y_ratio)

func get_foot_anchor_global() -> Vector2:
    return global_position + get_foot_anchor_local()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    var center := Vector2(size.x * 0.5, size.y * 0.39)
    var radius := minf(size.x, size.y) * 0.24
    draw_circle(center, radius, Color(0.12, 0.10, 0.08, 0.18))
    draw_arc(center, radius, 0.0, TAU, 48, Color(0.20, 0.17, 0.14, 0.72), 2.0)

    var anchor := get_foot_anchor_local()
    draw_line(anchor + Vector2(-8.0, 0.0), anchor + Vector2(8.0, 0.0), GOLD, 2.0)
    draw_line(anchor + Vector2(0.0, -8.0), anchor + Vector2(0.0, 8.0), GOLD, 2.0)

    if occupied_role == "player":
        draw_string(ThemeDB.fallback_font, Vector2(10.0, 24.0), "P", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, PLAYER_BORDER)
    elif occupied_role == "enemy":
        draw_string(ThemeDB.fallback_font, Vector2(10.0, 24.0), "E", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, ENEMY_BORDER)

func _refresh_visuals() -> void:
    if is_instance_valid(_number_label):
        _number_label.text = str(tile_index)

    var border_color := DEFAULT_BORDER
    var border_width := 3
    if occupied_role == "player":
        border_color = PLAYER_BORDER
        border_width = 5
    elif occupied_role == "enemy":
        border_color = ENEMY_BORDER
        border_width = 5

    var style := StyleBoxFlat.new()
    style.bg_color = DEFAULT_FILL
    style.border_color = border_color
    style.set_border_width_all(border_width)
    style.set_corner_radius_all(9)
    style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
    style.shadow_size = 5
    add_theme_stylebox_override("panel", style)
    queue_redraw()
