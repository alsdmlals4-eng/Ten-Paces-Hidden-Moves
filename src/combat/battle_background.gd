class_name BattleBackground
extends TextureRect

const BACKGROUND_SOURCE_PATH := "res://assets/backgrounds/ink_mist_valley_duel_01_v1.png"
const BACKGROUND_TEXTURE := preload("res://assets/backgrounds/ink_mist_valley_duel_01_v1.png")

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
	set_meta("art_direction", "original_ink_mist_valley_hanji_wuxia_duel")
	set_meta("contrast_role", "below_board_and_characters")
	set_meta("source_mode", "user_final_locked_ai_generated_project_raster_png")

	if texture != null:
		set_meta("texture_width", texture.get_width())
		set_meta("texture_height", texture.get_height())
