class_name CombatCharacterPlaceholder
extends Control

const PLAYER_COLOR := Color("315d76")
const PLAYER_OUTLINE := Color("6aa6c8")
const ENEMY_COLOR := Color("b9b4a8")
const ENEMY_OUTLINE := Color("bd6558")
const INK := Color("1d1a17")
const PAPER := Color("d8c9aa")
const GOLD := Color("b99254")

var role: String = "player"
var facing: int = 1
var tile_index: int = 1
var character_height_ratio: float = 1.5
var character_body_width_ratio: float = 0.72

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func configure(
    value_role: String,
    value_facing: int,
    value_tile_index: int,
    tile_width: float,
    height_ratio: float,
    body_width_ratio: float
) -> void:
    role = value_role
    facing = 1 if value_facing >= 0 else -1
    tile_index = value_tile_index
    character_height_ratio = height_ratio
    character_body_width_ratio = body_width_ratio
    set_meta("role", role)
    set_meta("tile_index", tile_index)
    set_meta("character_height_ratio", character_height_ratio)
    set_meta("character_body_width_ratio", character_body_width_ratio)
    set_dimensions(tile_width)

func set_dimensions(tile_width: float) -> void:
    var new_size := Vector2(
        tile_width * character_body_width_ratio,
        tile_width * character_height_ratio
    )
    custom_minimum_size = new_size
    size = new_size
    queue_redraw()

func place_foot_at(anchor: Vector2) -> void:
    position = anchor - Vector2(size.x * 0.5, size.y)
    set_meta("foot_anchor", anchor)

func get_foot_anchor_local() -> Vector2:
    return Vector2(size.x * 0.5, size.y)

func get_foot_anchor_global() -> Vector2:
    return global_position + get_foot_anchor_local()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    var fill := PLAYER_COLOR if role == "player" else ENEMY_COLOR
    var outline := PLAYER_OUTLINE if role == "player" else ENEMY_OUTLINE
    var width := size.x
    var height := size.y
    var foot_y := height - 2.0

    var head_center := Vector2(width * 0.5, height * 0.18)
    var head_radius := width * 0.13
    draw_circle(head_center, head_radius * 1.18, INK)
    draw_circle(head_center, head_radius, PAPER)
    draw_circle(head_center + Vector2(0.0, -head_radius * 0.9), head_radius * 0.45, INK)

    var shoulder_y := height * 0.31
    var waist_y := height * 0.59
    var robe_points := PackedVector2Array([
        Vector2(width * 0.26, shoulder_y),
        Vector2(width * 0.74, shoulder_y),
        Vector2(width * 0.82, waist_y),
        Vector2(width * 0.68, height * 0.88),
        Vector2(width * 0.32, height * 0.88),
        Vector2(width * 0.18, waist_y)
    ])
    draw_colored_polygon(robe_points, fill)
    var robe_outline := PackedVector2Array(robe_points)
    robe_outline.append(robe_points[0])
    draw_polyline(robe_outline, outline, 3.0, true)

    draw_line(Vector2(width * 0.24, shoulder_y + height * 0.06), Vector2(width * 0.05, height * 0.48), fill, width * 0.14, true)
    draw_line(Vector2(width * 0.76, shoulder_y + height * 0.04), Vector2(width * 0.95, height * 0.39), fill, width * 0.14, true)

    var left_foot := Vector2(width * 0.34, foot_y)
    var right_foot := Vector2(width * 0.66, foot_y)
    draw_line(Vector2(width * 0.42, height * 0.78), left_foot, INK, width * 0.12, true)
    draw_line(Vector2(width * 0.58, height * 0.78), right_foot, INK, width * 0.12, true)
    draw_line(left_foot + Vector2(-width * 0.10, 0.0), left_foot + Vector2(width * 0.10, 0.0), INK, 5.0, true)
    draw_line(right_foot + Vector2(-width * 0.10, 0.0), right_foot + Vector2(width * 0.10, 0.0), INK, 5.0, true)

    var sword_hand := Vector2(width * (0.88 if facing > 0 else 0.12), height * 0.41)
    var sword_end := sword_hand + Vector2(width * 0.45 * facing, -height * 0.06)
    draw_line(sword_hand, sword_end, Color("d8d4c9"), 3.0, true)
    draw_line(sword_hand + Vector2(-7.0 * facing, -5.0), sword_hand + Vector2(7.0 * facing, 5.0), GOLD, 3.0, true)

    var anchor := get_foot_anchor_local()
    draw_line(anchor + Vector2(-10.0, 0.0), anchor + Vector2(10.0, 0.0), GOLD, 2.0)
    draw_line(anchor + Vector2(0.0, -10.0), anchor + Vector2(0.0, 2.0), GOLD, 2.0)
