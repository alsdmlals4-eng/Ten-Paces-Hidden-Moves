extends PanelContainer
signal closed
signal preferences_changed
var preferences
var notice: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    offset_left = -290
    offset_right = 290
    offset_top = -235
    offset_bottom = 235
    var style := StyleBoxFlat.new()
    style.bg_color = Color("eee5d2")
    style.border_color = Color("413b30")
    style.set_border_width_all(2)
    style.content_margin_left = 28
    style.content_margin_right = 28
    style.content_margin_top = 24
    style.content_margin_bottom = 24
    add_theme_stylebox_override("panel", style)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 17)
    add_child(stack)
    var title := Label.new()
    title.text = "감상 설정"
    title.add_theme_font_size_override("font_size", 28)
    stack.add_child(title)
    for item in [["sound", "효과음"], ["reduced_motion", "모션 감소 · 확대와 흔들림 줄이기"], ["fast_replay", "빠른 재생 · 결과를 빠르게 확인"]]:
        var button := CheckButton.new()
        button.name = "Setting_" + item[0]
        button.text = item[1]
        button.button_pressed = bool(preferences.values[item[0]])
        button.custom_minimum_size.y = 42
        button.toggled.connect(func(enabled):
            preferences.values[item[0]] = enabled
            _save())
        stack.add_child(button)
    var label := Label.new()
    label.text = "효과음 크기"
    stack.add_child(label)
    var volume := HSlider.new()
    volume.name = "Setting_volume"
    volume.min_value = 0
    volume.max_value = 1
    volume.step = 0.05
    volume.value = float(preferences.values.volume)
    volume.custom_minimum_size.y = 32
    volume.accessibility_name = "효과음 크기"
    volume.value_changed.connect(func(value):
        preferences.values.volume = value
        _save())
    stack.add_child(volume)
    notice = Label.new()
    notice.text = "변경하면 자동으로 저장됩니다."
    notice.add_theme_font_size_override("font_size", 14)
    stack.add_child(notice)
    var close := Button.new()
    close.name = "SettingsClose"
    close.text = "돌아가기 · Esc"
    close.custom_minimum_size.y = 44
    close.pressed.connect(func(): closed.emit())
    stack.add_child(close)

func _save() -> void:
    notice.text = "설정을 저장했습니다." if preferences.save() == OK else "설정을 저장하지 못했습니다. 이번 실행에는 적용됩니다."
    preferences_changed.emit()

func _unhandled_key_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        closed.emit()
