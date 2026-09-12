class_name MainTitleScreen
extends Control

signal start_requested
signal continue_requested
signal reread_requested

const BACKGROUND_PATH := "res://assets/backgrounds/atlas_blue_ink_courtyard_v1.png"
const POSES := preload("res://src/combat/character_pose_library.gd")
const PLAYER_PATH := POSES.PLAYER_PATH
const ENEMY_PATH := POSES.ENEMY_PATH
const TITLE_LOGO_PATH := "res://assets/ui/logo/ten_paces_hidden_moves_title_logo_01_v1.png"
const DUEL_FOREGROUND_BANNER_SCRIPT := preload("res://src/ui/duel_foreground_banner.gd")
const PAPER := Color("eadfc9")
const INK := Color("211c17")
const GOLD := Color("b99254")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_surface()
	resized.connect(_fit_title)
	_fit_title()

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
	shade.color = Color(0.025, 0.045, 0.065, 0.20)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var foreground_banner := DUEL_FOREGROUND_BANNER_SCRIPT.new() as DuelForegroundBanner
	foreground_banner.name = "DuelForegroundBanner"
	foreground_banner.visible = false
	add_child(foreground_banner)
	_add_battler("PlayerTitleBattler", PLAYER_PATH, true)
	_add_battler("EnemyTitleBattler", ENEMY_PATH, false)
	var center := VBoxContainer.new()
	center.name = "TitleCenter"
	center.anchor_left = 0.28
	center.anchor_top = 0.06
	center.anchor_right = 0.72
	center.anchor_bottom = 0.94
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 8)
	add_child(center)
	var eyebrow := _make_label("숨은 수로 겨루는 일대일 비무", 16, Color("e7d9bc"))
	eyebrow.name = "TitleEyebrow"
	center.add_child(eyebrow)
	var title_logo := TextureRect.new()
	title_logo.name = "GameTitleLogo"
	title_logo.texture = load(TITLE_LOGO_PATH) as Texture2D
	title_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_logo.custom_minimum_size = Vector2(0.0, 210.0)
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
	start_button.text = "새 여정"
	start_button.custom_minimum_size = Vector2(286.0, 58.0)
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_button.accessibility_name = "비무행 시작"
	start_button.accessibility_description = "무공을 고르고 첫 비무를 시작합니다."
	_apply_start_style(start_button)
	start_button.pressed.connect(func(): start_requested.emit())
	center.add_child(start_button)
	var continue_button := Button.new()
	continue_button.name = "MainContinueButton"
	continue_button.text = "이어하기"
	continue_button.custom_minimum_size = Vector2(286.0, 48.0)
	continue_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_apply_start_style(continue_button)
	continue_button.pressed.connect(func():
		if continue_button.get_meta("read_retry", false): reread_requested.emit()
		else: continue_requested.emit())
	continue_button.visible = false
	center.add_child(continue_button)
	var save_notice := _make_label("", 14, PAPER)
	save_notice.name = "SaveContinueNotice"
	save_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center.add_child(save_notice)
	var hint := _make_label("거리와 공개된 행동 기록으로 다음 수를 읽습니다", 13, Color("d6c4a2"))
	hint.name = "TitleHint"
	center.add_child(hint)

func _fit_title() -> void:
	var logo := find_child("GameTitleLogo", true, false) as TextureRect
	if logo != null: logo.custom_minimum_size.y = clampf(size.y * 0.24, 128.0, 210.0)

func configure_continue(payload: Dictionary, status: String) -> void:
	var button := find_child("MainContinueButton", true, false) as Button
	var notice := find_child("SaveContinueNotice", true, false) as Label
	button.set_meta("read_retry", status == "IO_FAILURE")
	button.visible = not payload.is_empty() or status == "IO_FAILURE"
	button.disabled = payload.is_empty() and status != "IO_FAILURE"
	(find_child("MainStartButton", true, false) as Button).disabled = false
	if not payload.is_empty():
		var run: Dictionary = payload.run_state
		var place := "비무 %d" % int(run.duel_index)
		if run.current_screen == "JIANGHU": place += " · 행로 %d/4" % (int(run.jianghu_step) + 1)
		elif not payload.combat_checkpoint.is_empty(): place += " · %d번째 묶음" % int(payload.combat_checkpoint.state.bundle_index)
		button.text = "이어하기 · " + place
		notice.text = "마지막으로 확정된 진행부터 이어집니다.\n확정 전 배치는 다시 고릅니다."
		if status == "RECOVERED_BACKUP": notice.text = "백업에서 진행을 복구했습니다.\n" + notice.text
	else:
		button.text = "저장 다시 읽기"
		var notices := {"CORRUPT": "저장 기록을 읽을 수 없습니다. 새 여정을 선택하면 진단 사본을 보존합니다.", "INCOMPATIBLE": "이 버전에서 사용할 수 없는 저장 기록입니다. 원본을 보존합니다.", "IO_FAILURE": "저장 위치를 읽지 못했습니다. 파일 접근 상태를 확인해 주세요."}
		notice.text = str(notices.get(status, ""))

func _add_battler(node_name: String, path: String, is_left: bool) -> void:
	var battler := TextureRect.new()
	battler.name = node_name
	battler.texture = POSES.frame(path)
	battler.material = POSES.chroma_material()
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
