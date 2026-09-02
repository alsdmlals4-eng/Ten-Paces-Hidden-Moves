class_name DuelForegroundBanner
extends Control

# Reusable, non-interactive foreground framing for frontal-duel surfaces.
# The paired TextureRects deliberately share one transparent source asset so that
# future screens can alter placement or opacity without duplicating banner bytes.
const DEFAULT_BANNER_PATH := "res://assets/foregrounds/frontal_courtyard_banner_overlay_01_v1.png"
const DEFAULT_OPACITY := 0.62
const SIDE_EXTENT := 0.36
const TOP_INSET := 0.015
const BOTTOM_INSET := 0.055

var banner_path := DEFAULT_BANNER_PATH
var banner_opacity := DEFAULT_OPACITY

func _ready() -> void:
	name = "DuelForegroundBanner" if name.is_empty() else name
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_meta("visual_role", "reusable_frontal_duel_foreground_banner")
	set_meta("asset_path", banner_path)
	set_meta("input_policy", "ignore")
	_rebuild_banner_pair()

func configure_overlay(value_banner_path: String = DEFAULT_BANNER_PATH, value_opacity: float = DEFAULT_OPACITY) -> void:
	banner_path = value_banner_path
	banner_opacity = clampf(value_opacity, 0.0, 1.0)
	set_meta("asset_path", banner_path)
	if is_inside_tree():
		_rebuild_banner_pair()

func set_stage_rect(value: Rect2) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = value.position
	size = value.size
	set_meta("stage_rect", value)

func _rebuild_banner_pair() -> void:
	for child in get_children():
		child.queue_free()
	var banner_texture := load(banner_path) as Texture2D
	if banner_texture == null:
		push_error("Duel foreground banner texture could not be loaded from: %s" % banner_path)
		return
	_add_banner("LeftBanner", banner_texture, true)
	_add_banner("RightBanner", banner_texture, false)

func _add_banner(node_name: String, banner_texture: Texture2D, is_left: bool) -> void:
	var banner := TextureRect.new()
	banner.name = node_name
	banner.texture = banner_texture
	banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	banner.flip_h = not is_left
	banner.modulate = Color(1.0, 1.0, 1.0, banner_opacity)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	banner.anchor_left = 0.0 if is_left else 1.0 - SIDE_EXTENT
	banner.anchor_top = TOP_INSET
	banner.anchor_right = SIDE_EXTENT if is_left else 1.0
	banner.anchor_bottom = 1.0 - BOTTOM_INSET
	banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	banner.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(banner)
