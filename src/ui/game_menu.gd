extends Control
## Optional menu only; the shell owns suspension and durable progress.
signal close_requested
signal preferences_changed(muted: bool, volume: float, reduced_motion: bool)

const GUIDE := "거리와 수읽기\n처음 거리는 2입니다. 거리 0은 [밀착]입니다. 기술 상세의 사거리와 기력·내력 비용을 확인하세요.\n\n한 라운드의 흐름\n3수 → 해결 → 3수 → 해결 → 4수 → 해결 순서입니다. 현재 해금된 기술을 수에 배치하고, 확정한 뒤 한 수씩 드러나는 결과를 읽습니다.\n\n상대를 읽는 근거\n공개 상태, 관찰로 드러난 행동 종류, 이미 해결된 행동 이력으로 추론합니다. 미공개 기술 배치나 다음 수의 정답을 알려 주는 안내가 아닙니다.\n\n비무 사이의 선택\n비무 결과를 확인하고 보상·행로의 효과를 비교하세요. 휴식·사건·조사·수련으로 다음 비무를 준비합니다. 성장으로 파훼 선택지를 넓히되 거리와 대응을 함께 판단하세요.\n\n저장과 이어하기\n메뉴를 열어도 현재 화면의 배치는 유지됩니다. 앱을 다시 실행해 이어할 때는 마지막으로 확정된 진행부터 복원하며, 확정 전 배치는 다시 고릅니다.\n\n조작과 설정\nTab으로 이동하고 Enter로 선택합니다. 음량은 좌우 화살표로 조절합니다. Esc 또는 돌아가기로 메뉴를 닫습니다. 소리·음량·모션 감소는 여정 진행과 별도로 유지됩니다."

var mute_button: Button
var motion_button: Button
var volume_slider: HSlider
var guide_button: Button
var resume_button: Button
var guide_scroll: ScrollContainer
var guide_label: Label
var status_label: Label
var volume_label: Label
var panel: PanelContainer

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    mouse_filter = Control.MOUSE_FILTER_STOP
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var shade := ColorRect.new()
    shade.color = Color(0.015, 0.02, 0.025, 0.88)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    panel = PanelContainer.new()
    panel.add_theme_stylebox_override("panel", WuxiaUiStyle.paper_surface())
    add_child(panel)
    var margin := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 16)
    panel.add_child(margin)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 8)
    margin.add_child(stack)
    var heading := Label.new()
    heading.text = "잠시 쉬어가기"
    WuxiaUiStyle.ink_heading(heading, 24)
    stack.add_child(heading)
    var toggles := HBoxContainer.new()
    toggles.add_theme_constant_override("separation", 12)
    stack.add_child(toggles)
    mute_button = _button("소리", "MenuSoundButton")
    motion_button = _button("모션 감소", "MenuMotionButton")
    toggles.add_child(mute_button)
    toggles.add_child(motion_button)
    volume_label = _label("효과음 음량")
    stack.add_child(volume_label)
    volume_slider = HSlider.new()
    volume_slider.name = "MenuVolumeSlider"
    volume_slider.min_value = 0.0
    volume_slider.max_value = 1.0
    volume_slider.step = 0.05
    volume_slider.custom_minimum_size.y = 36
    volume_slider.accessibility_name = "효과음 음량"
    stack.add_child(volume_slider)
    status_label = _label("")
    status_label.custom_minimum_size.y = 42
    stack.add_child(status_label)
    guide_button = _button("비무 안내 보기", "MenuGuideButton")
    stack.add_child(guide_button)
    guide_scroll = ScrollContainer.new()
    guide_scroll.name = "MenuGuideScroll"
    guide_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    guide_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    guide_scroll.custom_minimum_size.y = 80
    guide_scroll.focus_mode = Control.FOCUS_ALL
    guide_scroll.accessibility_name = "비무 규칙과 조작 안내"
    stack.add_child(guide_scroll)
    guide_label = _label(GUIDE)
    guide_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    guide_scroll.add_child(guide_label)
    guide_scroll.hide()
    resume_button = _button("돌아가기 · Esc", "MenuResumeButton")
    stack.add_child(resume_button)
    mute_button.pressed.connect(func(): _request_preferences(not bool(mute_button.get_meta("muted", false)), volume_slider.value, bool(motion_button.get_meta("reduced", false))))
    motion_button.pressed.connect(func(): _request_preferences(bool(mute_button.get_meta("muted", false)), volume_slider.value, not bool(motion_button.get_meta("reduced", false))))
    volume_slider.value_changed.connect(func(value: float): _request_preferences(bool(mute_button.get_meta("muted", false)), value, bool(motion_button.get_meta("reduced", false))))
    guide_button.pressed.connect(_toggle_guide)
    resume_button.pressed.connect(func(): close_requested.emit())
    resized.connect(_layout_panel)
    _layout_panel()
    _set_focus_cycle()
    hide()

func _label(text: String) -> Label:
    var label := Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", Color("211c17"))
    return label

func _button(text: String, node_name: String) -> Button:
    var button := Button.new()
    button.name = node_name
    button.text = text
    button.custom_minimum_size.y = 44
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.focus_mode = Control.FOCUS_ALL
    return button

func sync_preferences(preferences: RefCounted, message: String = "설정은 여정 진행과 별도로 저장됩니다.") -> void:
    mute_button.set_meta("muted", preferences.sound_muted)
    motion_button.set_meta("reduced", preferences.reduced_motion)
    mute_button.text = "소리: %s" % ("끔" if preferences.sound_muted else "켬")
    motion_button.text = "모션 감소: %s" % ("켬" if preferences.reduced_motion else "끔")
    volume_slider.set_value_no_signal(preferences.sound_volume)
    volume_label.text = "효과음 음량 · %d%%" % roundi(preferences.sound_volume * 100.0)
    status_label.text = message

func _request_preferences(muted: bool, volume: float, reduced: bool) -> void:
    preferences_changed.emit(muted, volume, reduced)

func _toggle_guide() -> void:
    guide_scroll.visible = not guide_scroll.visible
    guide_button.text = "비무 안내 접기" if guide_scroll.visible else "비무 안내 보기"
    _layout_panel()
    _set_focus_cycle()
    if guide_scroll.visible: guide_scroll.grab_focus()

func _layout_panel() -> void:
    if panel == null: return
    panel.size = Vector2(minf(680.0, maxf(280.0, size.x - 32.0)), minf(640.0 if guide_scroll.visible else 410.0, size.y - 32.0))
    panel.position = (size - panel.size) * 0.5

func _set_focus_cycle() -> void:
    var controls: Array[Control] = [mute_button, motion_button, volume_slider, guide_button]
    if guide_scroll.visible: controls.append(guide_scroll)
    controls.append(resume_button)
    for i in controls.size():
        var current := controls[i]
        current.focus_next = current.get_path_to(controls[(i + 1) % controls.size()])
        current.focus_previous = current.get_path_to(controls[(i - 1 + controls.size()) % controls.size()])
        current.focus_neighbor_bottom = current.focus_next
        current.focus_neighbor_top = current.focus_previous
