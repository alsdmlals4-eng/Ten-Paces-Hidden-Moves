class_name BattleBackground
extends TextureRect

const BACKGROUND_SOURCE_PATH := "res://assets/backgrounds/frontal_courtyard_duel_background_02_v1.png"
const BACKGROUND_TEXTURE := preload("res://assets/backgrounds/frontal_courtyard_duel_background_02_v1.png")
# Foreground stone band where both frontal-duel battlers make visual contact.
const DUEL_FLOOR_IMAGE_RATIO := 0.46

func _ready() -> void:
	name = "BattleBackground"
	texture = BACKGROUND_TEXTURE
	if texture == null:
		push_error("Battle background texture could not be loaded from: %s" % BACKGROUND_SOURCE_PATH)

	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate = Color(0.82, 0.76, 0.66, 1.0)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_meta("step", 3)
	set_meta("art_direction", "original_frontal_courtyard_animated_wuxia_duel")
	set_meta("contrast_role", "below_board_and_characters")
	set_meta("source_mode", "user_final_locked_ai_generated_project_raster_png")

	if texture != null:
		set_meta("texture_width", texture.get_width())
		set_meta("texture_height", texture.get_height())
	set_meta("duel_floor_image_ratio", DUEL_FLOOR_IMAGE_RATIO)

func set_stage_rect(value: Rect2) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = value.position
	size = value.size
	set_meta("stage_rect", value)

func get_duel_floor_y(viewport_size: Vector2) -> float:
	var rendered_viewport := size if size.x > 0.0 and size.y > 0.0 else viewport_size
	if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
		return position.y + rendered_viewport.y * DUEL_FLOOR_IMAGE_RATIO
	var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
	var scale := maxf(rendered_viewport.x / texture_size.x, rendered_viewport.y / texture_size.y)
	var rendered_size := texture_size * scale
	var vertical_crop := (rendered_size.y - rendered_viewport.y) * 0.5
	var image_floor_y := rendered_size.y * DUEL_FLOOR_IMAGE_RATIO - vertical_crop
	# A wide central stage crops much of the original vertical image. Keep the
	# contact line in the visible foreground stone band rather than letting the
	# battlers drift into the horizon after that crop.
	var foreground_floor_y := rendered_viewport.y * 0.72
	return position.y + maxf(image_floor_y, foreground_floor_y)
