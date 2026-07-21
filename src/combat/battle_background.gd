class_name BattleBackground
extends TextureRect

const BACKGROUND_SOURCE_PATH := "res://assets/backgrounds/step3_mountain_fortress.svg"
const BACKGROUND_TEXTURE := preload("res://assets/backgrounds/step3_mountain_fortress.svg")

func _ready() -> void:
	name = "BattleBackground"
	texture = BACKGROUND_TEXTURE
	if texture == null:
		push_error("STEP 3 battle background texture could not be loaded from: %s" % BACKGROUND_SOURCE_PATH)

	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate = Color(0.86, 0.84, 0.80, 1.0)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_meta("step", 3)
	set_meta("art_direction", "approved_ink_wash_mountain_fortress")
	set_meta("contrast_role", "below_board_and_characters")
	set_meta("source_mode", "direct_vector_svg")

	if texture != null:
		set_meta("texture_width", texture.get_width())
		set_meta("texture_height", texture.get_height())
