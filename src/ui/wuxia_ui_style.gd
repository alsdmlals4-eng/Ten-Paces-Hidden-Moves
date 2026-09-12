class_name WuxiaUiStyle
extends RefCounted

static var _heading_font: SystemFont
static var _paper_style: StyleBoxTexture

static func paper_surface() -> StyleBoxTexture:
	if _paper_style == null:
		var texture := AtlasTexture.new()
		texture.atlas = preload("res://assets/ui/duel/technique_detail_frame_01_v1.png")
		# Reuse the approved frame's blank lower panel, never its baked sub-wells.
		texture.region = Rect2(104, 923, 836, 449)
		texture.filter_clip = true
		_paper_style = StyleBoxTexture.new()
		_paper_style.texture = texture
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			_paper_style.set_texture_margin(side, 20.0)
			_paper_style.set_content_margin(side, 8.0)
	return _paper_style

static func heading_font() -> SystemFont:
	if _heading_font == null:
		_heading_font = SystemFont.new()
		_heading_font.font_names = PackedStringArray(["Batang", "Noto Serif CJK KR", "Noto Serif", "serif"])
	return _heading_font

static func ink_heading(label: Label, font_size: int = 16) -> void:
	label.add_theme_font_override("font", heading_font())
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("ead8b4"))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	var surface := StyleBoxFlat.new()
	surface.bg_color = Color("211c17")
	surface.border_color = Color("a7854a")
	surface.border_width_bottom = 1
	surface.content_margin_left = 5
	surface.content_margin_right = 5
	label.add_theme_stylebox_override("normal", surface)
