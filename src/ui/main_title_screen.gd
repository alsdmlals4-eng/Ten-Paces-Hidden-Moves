class_name MainTitleScreen
extends Control

signal start_requested

const BACKGROUND_PATH := "res://assets/backgrounds/frontal_courtyard_duel_background_02_v1.png"
const PLAYER_PATH := "res://assets/characters/player_wanderer_battler_rgba_v2.png"
const ENEMY_PATH := "res://assets/characters/enemy_masked_battler_rgba_v2.png"
const TITLE_LOGO_PATH := "res://assets/ui/logo/ten_paces_hidden_moves_title_logo_01_v1.png"
const DUEL_FOREGROUND_BANNER_SCRIPT := preload("res://src/ui/duel_foreground_banner.gd")
const PAPER := Color("eadfc9")
const INK := Color("211c17")
const GOLD := Color("b99254")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_surface()

func _build_surface() -> void:
	for child in get_children():
		child.queue_free()
	var background := TextureRect.new()
	background.name = "CourtyardBackdrop"
	background.texture = load(BACKGROUND_PATH) as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var shade := ColorRect.new()
	shade.name = "InkVeil"
	shade.color = Color(0.08, 0.055, 0.035, 0.35)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var foreground_banner := DUEL_FOREGROUND_BANNER_SCRIPT.new() as DuelForegroundBanner
	foreground_banner.name = "DuelForegroundBanner"
	add_child(foreground_banner)
	_add_battler("PlayerTitleBattler", PLAYER_PATH, true)
	_add_battler("EnemyTitleBattler", ENEMY_PATH, false)
	var center := VBoxContainer.new()
	center.name = "TitleCenter"
	center.anchor_left = 0.28
	center.anchor_top = 0.20
	center.anchor_right = 0.72
	center.anchor_bottom = 0.82
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 14)
	add_child(center)
	var eyebrow := _make_label("숨은 수로 겨루는 일대일 비무", 16, Color("e7d9bc"))
	eyebrow.name = "TitleEyebrow"
	center.add_child(eyebrow)
	var title_logo := TextureRect.new()
	title_logo.name = "GameTitleLogo"
	title_logo.texture = load(TITLE_LOGO_PATH) as Texture2D
	title_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_logo.custom_minimum_size = Vector2(0.0, 280.0)
	title_logo.size_flags_horizontal = Control.SIZE_FILL
	title_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_logo.accessibility_name = "십보강호: 숨은 수의 비무"
	title_logo.accessibility_description = "열 걸음 안에서 숨은 수를 읽는 일대일 비무."
	center.add_child(title_logo)
	var promise := _make_label("세 수를 고르고, 한 수씩 드러나는 승부를 읽으십시오.", 17, Color("eadfc9"))
	promise.name = "GamePromise"
	promise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	promise.custom_minimum_size = Vector2(0.0, 46.0)
	center.add_child(promise)
	var start_button := Button.new()
	start_button.name = "MainStartButton"
	start_button.text = "비무행 시작"
	start_button.custom_minimum_size = Vector2(286.0, 58.0)
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_button.accessibility_name = "비무행 시작"
	start_button.accessibility_description = "무공을 고르고 첫 비무를 시작합니다."
	_apply_start_style(start_button)
	start_button.pressed.connect(func(): start_requested.emit())
	center.add_child(start_button)
	var hint := _make_label("거리와 공개된 행동 기록으로 다음 수를 읽습니다", 13, Color("d6c4a2"))
	hint.name = "TitleHint"
	center.add_child(hint)

func _add_battler(node_name: String, path: String, is_left: bool) -> void:
	var battler := TextureRect.new()
	battler.name = node_name
	battler.texture = load(path) as Texture2D
	battler.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	battler.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	battler.mouse_filter = Control.MOUSE_FILTER_IGNORE
	battler.modulate = Color(1.0, 1.0, 1.0, 0.90)
	battler.anchor_left = 0.0 if is_left else 0.56
	battler.anchor_top = 0.18
	battler.anchor_right = 0.44 if is_left else 1.0
	battler.anchor_bottom = 0.90
	battler.grow_horizontal = Control.GROW_DIRECTION_BOTH
	battler.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(battler)

func _make_label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _apply_start_style(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("c2a16a")
	normal.border_color = INK
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(4)
	normal.content_margin_left = 20.0
	normal.content_margin_right = 20.0
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("d5b87f")
	hover.border_color = PAPER
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("9c7844")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", PAPER)
