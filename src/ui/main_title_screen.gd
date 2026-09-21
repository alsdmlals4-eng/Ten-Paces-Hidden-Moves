class_name MainTitleScreen
extends Control

signal start_requested
signal continue_requested
signal reread_requested
signal settings_requested

const PAPER := Color("eadfc9")
const INK := Color("211c17")
const GOLD := Color("b99254")

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_surface()
    resized.connect(_fit_title)
    _fit_title()

func _build_surface() -> void:
    var matte := ColorRect.new()
    matte.color = Color("111614")
    matte.mouse_filter = Control.MOUSE_FILTER_IGNORE
    matte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(matte)
    var background := TextureRect.new()
    background.name = "JourneyTitleArtwork"
    background.texture = load("res://assets/ui/logo/journey_title_reference_v1.png")
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)
    for item in [["MainStartButton","새 여정"],["MainContinueButton","이어하기"],["MainSettingsButton","설정"]]:
        var button := Button.new()
        button.name = item[0]
        button.text = item[1]
        button.accessibility_name = item[1]
        _apply_start_style(button)
        add_child(button)
    get_node("MainStartButton").pressed.connect(func(): start_requested.emit())
    get_node("MainContinueButton").pressed.connect(func():
        if get_node("MainContinueButton").get_meta("read_retry",false): reread_requested.emit()
        else: continue_requested.emit())
    get_node("MainSettingsButton").pressed.connect(func(): settings_requested.emit())
    var notice := _make_label("",14,PAPER)
    notice.name = "SaveContinueNotice"
    notice.visible = false
    notice.anchor_left = 0.08
    notice.anchor_right = 0.92
    notice.anchor_top = 0.93
    notice.anchor_bottom = 1.0
    notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(notice)

func _fit_title() -> void:
    # Retain the user-selected composition. Buttons are live, keyboard accessible
    # controls covering the reference labels; the image never handles input.
    var scale_factor := minf(size.x / 525.0,size.y / 282.0)
    var origin := (size - Vector2(525,282) * scale_factor) * 0.5
    var names := ["MainStartButton","MainContinueButton","MainSettingsButton"]
    for i in range(names.size()):
        var button := get_node_or_null(names[i]) as Button
        if button == null: continue
        button.position = origin + Vector2(249,153 + 35*i) * scale_factor
        button.size = Vector2(124,31) * scale_factor
        button.add_theme_font_size_override("font_size",int(clampf(17*scale_factor,18,36)))
        button.focus_next = button.get_path_to(get_node(names[(i+1)%3]))
        button.focus_previous = button.get_path_to(get_node(names[(i+2)%3]))

func configure_continue(payload: Dictionary, status: String) -> void:
    var button := find_child("MainContinueButton", true, false) as Button
    var notice := find_child("SaveContinueNotice", true, false) as Label
    button.set_meta("read_retry", status == "IO_FAILURE")
    button.visible = true
    button.disabled = payload.is_empty() and status != "IO_FAILURE"
    (find_child("MainStartButton", true, false) as Button).disabled = false
    var location := ""
    if not payload.is_empty():
        var run: Dictionary = payload.run_state
        var place := "비무 %d" % int(run.duel_index)
        if run.current_screen == "JIANGHU": place += " · 행로 %d/4" % (int(run.jianghu_step) + 1)
        elif not payload.combat_checkpoint.is_empty(): place += " · %d번째 묶음" % int(payload.combat_checkpoint.state.bundle_index)
        button.text = "이어하기"
        location = place
        notice.text = "마지막으로 확정된 진행부터 이어집니다.\n확정 전 배치는 다시 고릅니다."
        if run.current_screen == "COMPLETION":
            button.text = "완주 기록 보기"
            notice.text = "열 번의 비무와 성장 기록을 다시 봅니다.\n새 여정을 확정하면 현재 완주 기록을 교체합니다."
        if status == "RECOVERED_BACKUP": notice.text = "백업에서 진행을 복구했습니다.\n" + notice.text
    else:
        button.text = "저장 다시 읽기" if status == "IO_FAILURE" else "이어하기"
        var notices := {"CORRUPT": "저장 기록을 읽을 수 없습니다. 새 여정을 선택하면 진단 사본을 보존합니다.", "INCOMPATIBLE": "이 버전에서 사용할 수 없는 저장 기록입니다. 원본을 보존합니다.", "IO_FAILURE": "저장 위치를 읽지 못했습니다. 파일 접근 상태를 확인해 주세요."}
        notice.text = str(notices.get(status, ""))
    notice.visible = status in ["CORRUPT","INCOMPATIBLE","IO_FAILURE","RECOVERED_BACKUP"]
    button.tooltip_text = (location + "\n" if not location.is_empty() else "") + notice.text
    button.accessibility_description = button.tooltip_text

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
    normal.bg_color = Color("161b19")
    normal.border_color = GOLD
    normal.set_border_width_all(3)
    normal.set_corner_radius_all(4)
    normal.content_margin_left = 8.0
    normal.content_margin_right = 8.0
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color("30362e")
    hover.border_color = PAPER
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("9c7844")
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("disabled", normal)
    button.add_theme_color_override("font_disabled_color", Color("77756b"))
    button.add_theme_color_override("font_color", PAPER)
    button.add_theme_color_override("font_hover_color", PAPER)
    button.add_theme_color_override("font_pressed_color", PAPER)
