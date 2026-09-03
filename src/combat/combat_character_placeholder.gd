class_name CombatCharacterPlaceholder
extends Control

const PLAYER_COLOR := Color("315d76")
const PLAYER_OUTLINE := Color("6aa6c8")
const ENEMY_COLOR := Color("b9b4a8")
const ENEMY_OUTLINE := Color("bd6558")
const INK := Color("1d1a17")
const PAPER := Color("d8c9aa")
const GOLD := Color("b99254")
const PLAYER_ART_PATH := "res://assets/characters/player_wanderer_battler_rgba_v2.png"
const ENEMY_ART_PATH := "res://assets/characters/enemy_masked_battler_rgba_v2.png"
const DOGYEOM_ART_PATH := "res://assets/characters/dogyeom_combat_battler_01_v1.png"

var role: String = "player"
var facing: int = 1
var tile_index: int = 1
var candidate_id := ""
var character_height_ratio: float = 1.5
var character_body_width_ratio: float = 0.72
var motion_state := "idle"
var motion_phase := "idle"
var visual_offset := Vector2.ZERO
var visual_scale := 1.0
var character_sprite: Texture2D
var _character_art_path := ""
var _sprite_foot_ratio := 0.94
var _motion_tween: Tween
var _motion_sequence_id := 0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(false)
    queue_redraw()

func configure(
    value_role: String,
    value_facing: int,
    value_tile_index: int,
    tile_width: float,
    height_ratio: float,
    body_width_ratio: float,
    value_candidate_id: String = ""
) -> void:
    role = value_role
    facing = 1 if value_facing >= 0 else -1
    tile_index = value_tile_index
    candidate_id = value_candidate_id
    character_height_ratio = height_ratio
    character_body_width_ratio = body_width_ratio
    set_meta("role", role)
    set_meta("tile_index", tile_index)
    set_meta("candidate_id", candidate_id)
    set_meta("character_height_ratio", character_height_ratio)
    set_meta("character_body_width_ratio", character_body_width_ratio)
    _load_character_art()
    set_dimensions(tile_width)

func get_render_texture() -> Texture2D:
    _load_character_art()
    return character_sprite


func is_character_art_horizontally_mirrored() -> bool:
    _load_character_art()
    return role == "enemy" and facing < 0 and _character_art_path == DOGYEOM_ART_PATH


func _load_character_art() -> void:
    var next_path := PLAYER_ART_PATH if role == "player" else _enemy_art_path()
    if _character_art_path == next_path and character_sprite != null:
        return
    _character_art_path = next_path
    character_sprite = load(_character_art_path) as Texture2D
    _sprite_foot_ratio = 0.94
    if character_sprite != null:
        var image := character_sprite.get_image()
        if image != null:
            var used := image.get_used_rect()
            if used.size.y > 0:
                _sprite_foot_ratio = clampf(float(used.position.y + used.size.y) / float(image.get_height()), 0.70, 1.0)
    set_meta("character_art_path", _character_art_path)
    set_meta("character_art_loaded", character_sprite != null)
    set_meta("character_art_horizontally_mirrored", is_character_art_horizontally_mirrored())


func _enemy_art_path() -> String:
    return DOGYEOM_ART_PATH if candidate_id == "slot1_dogyeom" else ENEMY_ART_PATH

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

func animate_move_to(anchor: Vector2, duration: float = 0.22) -> void:
    _begin_motion("move", "active")
    var target_position := anchor - Vector2(size.x * 0.5, size.y)
    var safe_duration := maxf(0.12, duration)
    var tween := create_tween()
    _motion_tween = tween
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "position", target_position, safe_duration * 0.68)
    tween.parallel().tween_property(self, "visual_scale", 1.035, safe_duration * 0.68)
    tween.tween_callback(func(): _set_motion_phase("recovery"))
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "visual_scale", 1.0, safe_duration * 0.32)
    tween.tween_callback(set_idle)

func play_attack_motion(duration: float = 0.28) -> void:
    _play_windup_motion(
        "attack",
        Vector2(-size.x * 0.045 * float(facing), 0.0),
        Vector2(size.x * 0.15 * float(facing), 0.0),
        0.97,
        1.06,
        duration
    )

func play_evade_motion(duration: float = 0.24) -> void:
    _play_offset_motion("evade", Vector2(-size.x * 0.16 * float(facing), 0.0), 0.96, duration)

func play_block_motion(duration: float = 0.22) -> void:
    _play_offset_motion("block", Vector2(-size.x * 0.035 * float(facing), 0.0), 0.93, duration)

func play_hit_motion(duration: float = 0.24) -> void:
    _play_offset_motion("hit", Vector2(-size.x * 0.12 * float(facing), 0.0), 0.98, duration)

func play_ultimate_motion(duration: float = 0.42) -> void:
    _play_windup_motion(
        "ultimate",
        Vector2(-size.x * 0.075 * float(facing), 0.0),
        Vector2(size.x * 0.22 * float(facing), 0.0),
        0.94,
        1.12,
        duration
    )

func play_clash_motion(clash_anchor: Vector2, duration: float = 0.34) -> void:
    _begin_motion("clash", "windup")
    var start_position := position
    var horizontal_travel := clash_anchor.x - get_foot_anchor_global().x
    var target_position := Vector2(start_position.x + horizontal_travel, start_position.y)
    set_meta("last_clash_anchor", clash_anchor)
    set_meta("last_clash_target_position", target_position)
    var tween := create_tween()
    _motion_tween = tween
    var safe_duration := maxf(0.16, duration)
    var approach_duration := safe_duration * 0.38
    var contact_hold_duration := safe_duration * 0.18
    var return_duration := safe_duration - approach_duration - contact_hold_duration
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "position", target_position, approach_duration)
    tween.parallel().tween_property(self, "visual_scale", 1.07, approach_duration)
    tween.tween_callback(func(): _set_motion_phase("active"))
    tween.tween_interval(contact_hold_duration)
    tween.tween_callback(func(): _set_motion_phase("recovery"))
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "position", start_position, return_duration)
    tween.parallel().tween_property(self, "visual_scale", 1.0, return_duration)
    tween.tween_callback(set_idle)

func _play_offset_motion(next_state: String, offset: Vector2, peak_scale: float, duration: float) -> void:
    _begin_motion(next_state, "active")
    var safe_duration := maxf(0.12, duration)
    var tween := create_tween()
    _motion_tween = tween
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "visual_offset", offset, safe_duration * 0.42)
    tween.parallel().tween_property(self, "visual_scale", peak_scale, safe_duration * 0.42)
    tween.tween_callback(func(): _set_motion_phase("recovery"))
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "visual_offset", Vector2.ZERO, safe_duration * 0.58)
    tween.parallel().tween_property(self, "visual_scale", 1.0, safe_duration * 0.58)
    tween.tween_callback(set_idle)

func _play_windup_motion(
    next_state: String,
    windup_offset: Vector2,
    active_offset: Vector2,
    windup_scale: float,
    active_scale: float,
    duration: float
) -> void:
    _begin_motion(next_state, "windup")
    var safe_duration := maxf(0.12, duration)
    var windup_duration := safe_duration * 0.24
    var active_duration := safe_duration * 0.36
    var recovery_duration := safe_duration - windup_duration - active_duration
    var tween := create_tween()
    _motion_tween = tween
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "visual_offset", windup_offset, windup_duration)
    tween.parallel().tween_property(self, "visual_scale", windup_scale, windup_duration)
    tween.tween_callback(func(): _set_motion_phase("active"))
    tween.tween_property(self, "visual_offset", active_offset, active_duration)
    tween.parallel().tween_property(self, "visual_scale", active_scale, active_duration)
    tween.tween_callback(func(): _set_motion_phase("recovery"))
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "visual_offset", Vector2.ZERO, recovery_duration)
    tween.parallel().tween_property(self, "visual_scale", 1.0, recovery_duration)
    tween.tween_callback(set_idle)

func _begin_motion(next_state: String, next_phase: String) -> void:
    _stop_motion_tween()
    _motion_sequence_id += 1
    motion_state = next_state
    visual_offset = Vector2.ZERO
    visual_scale = 1.0
    _set_motion_phase(next_phase)
    set_process(true)

func _set_motion_phase(next_phase: String) -> void:
    motion_phase = next_phase
    set_meta("motion_state", motion_state)
    set_meta("motion_phase", motion_phase)
    set_meta("motion_sequence_id", _motion_sequence_id)

func get_motion_snapshot() -> Dictionary:
    return {
        "state": motion_state,
        "phase": motion_phase,
        "sequence_id": _motion_sequence_id,
        "visual_offset": visual_offset,
        "visual_scale": visual_scale,
        "grounded": is_zero_approx(visual_offset.y)
    }

func _stop_motion_tween() -> void:
    if is_instance_valid(_motion_tween):
        _motion_tween.kill()
    _motion_tween = null

func set_idle() -> void:
    _motion_tween = null
    motion_state = "idle"
    visual_offset = Vector2.ZERO
    visual_scale = 1.0
    _set_motion_phase("idle")
    set_process(false)
    queue_redraw()

func _process(_delta: float) -> void:
    queue_redraw()

func get_foot_anchor_local() -> Vector2:
    return Vector2(size.x * 0.5, size.y)

func get_foot_anchor_global() -> Vector2:
    return global_position + get_foot_anchor_local()

func get_foot_position() -> Vector2:
    return get_foot_anchor_global()

func get_shadow_contact_y() -> float:
    return global_position.y + size.y - 3.0

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    var fill := PLAYER_COLOR if role == "player" else ENEMY_COLOR
    var outline := PLAYER_OUTLINE if role == "player" else ENEMY_OUTLINE
    var width := size.x
    var height := size.y
    var foot_y := height - 2.0

    var sprite := get_render_texture()
    if sprite != null:
        _draw_contact_shadow(width, foot_y)
        var ground_pivot := Vector2(width * 0.5, height)
        var draw_scale := Vector2.ONE * visual_scale
        if is_character_art_horizontally_mirrored():
            draw_scale.x *= -1.0
        draw_set_transform(visual_offset + ground_pivot, 0.0, draw_scale)
        var sprite_height := height * 1.08
        var sprite_rect := Rect2(
            Vector2((width - sprite_height) * 0.5, height - sprite_height * _sprite_foot_ratio) - ground_pivot,
            Vector2(sprite_height, sprite_height)
        )
        draw_texture_rect(sprite, sprite_rect, false, Color.WHITE)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        return

    _draw_contact_shadow(width, foot_y)
    draw_set_transform(visual_offset, 0.0, Vector2.ONE * visual_scale)

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

    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_contact_shadow(width: float, foot_y: float) -> void:
    draw_set_transform(Vector2(width * 0.5, foot_y - 1.0), 0.0, Vector2(1.0, 0.22))
    draw_circle(Vector2.ZERO, width * 0.42, Color(INK, 0.42))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
