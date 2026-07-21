class_name BattleBackground
extends TextureRect

const BACKGROUND_TEXTURE := preload("res://assets/backgrounds/step3_mountain_fortress.svg")

func _ready() -> void:
    name = "BattleBackground"
    texture = BACKGROUND_TEXTURE
    expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    modulate = Color(0.82, 0.80, 0.76, 1.0)
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    set_meta("step", 3)
    set_meta("art_direction", "approved_ink_wash_mountain_fortress")
    set_meta("contrast_role", "below_board_and_characters")
