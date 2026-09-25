extends Control
## Spatial view of offered route choices; selection stays in the run model.
signal node_selected(id: String)
const GOLD := Color("c5a36c")
var _points: Array[Vector2] = []
var _buttons: Array[Button] = []
var _choices: Array = []
var _origin := "산길 · 현재 위치"
var _selected := ""

func configure(choices: Array, origin: String, selected: String = "") -> void:
    _choices = choices.duplicate(true)
    _origin = origin
    _selected = selected
    for child in get_children():
        remove_child(child)
        child.queue_free()
    _buttons.clear()
    var origin_button := Button.new()
    origin_button.text = _origin
    origin_button.disabled = true
    origin_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    origin_button.add_theme_font_size_override("font_size", 20)
    origin_button.custom_minimum_size = Vector2(130, 86)
    add_child(origin_button)
    _buttons.append(origin_button)
    for option in _choices:
        var button := Button.new()
        button.name = "JourneyNode_" + str(option.id)
        button.text = str(option.label)
        button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.custom_minimum_size = Vector2(142, 90)
        button.add_theme_font_size_override("font_size", 21)
        var picture := "rest" if str(option.id) == "rest" else "setup" if str(option.id) == "training" else "journey"
        button.icon = load("res://assets/backgrounds/ink_wuxia/" + picture + ".png")
        button.expand_icon = true
        button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
        button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
        button.add_theme_constant_override("icon_max_width", 88)
        button.tooltip_text = str(option.get("effect", ""))
        button.accessibility_name = str(option.label) + " · 이동할 길 선택"
        button.disabled = bool(option.get("disabled", false))
        var box := StyleBoxFlat.new()
        box.bg_color = Color("eee3cb") if str(option.id) != _selected else Color("d6b771")
        box.border_color = GOLD
        box.set_border_width_all(3 if str(option.id) == _selected else 1)
        box.set_corner_radius_all(42)
        box.content_margin_left = 12
        box.content_margin_right = 12
        button.add_theme_stylebox_override("normal", box)
        button.pressed.connect(func(): node_selected.emit(str(option.id)))
        add_child(button)
        _buttons.append(button)
    if not resized.is_connected(_layout): resized.connect(_layout)
    _layout()

func _layout() -> void:
    _points.clear()
    if _buttons.is_empty(): return
    _points.append(Vector2(size.x * 0.20, size.y * 0.5))
    for i in range(_choices.size()):
        var y := float(i + 1) / float(_choices.size() + 1)
        _points.append(Vector2(size.x * 0.70, size.y * y))
    for i in range(_buttons.size()):
        var node_height := clampf(size.y / float(_choices.size() + 1) - 16.0, 92, 146)
        var node_size := Vector2(clampf(size.x * 0.30, 144, 190), node_height if i > 0 else 90)
        if i > 0:
            _buttons[i].add_theme_font_size_override("font_size", 17 if size.x < 500 else 21)
            _buttons[i].add_theme_constant_override("icon_max_width", 68 if node_height < 110 else 88)
        _buttons[i].size = node_size
        _buttons[i].position = _points[i] - node_size / 2.0
    queue_redraw()

func _draw() -> void:
    if _points.is_empty(): return
    for i in range(1, _points.size()):
        draw_dashed_line(_points[0], _points[i], GOLD, 3.0, 9.0)
    draw_circle(_points[0], 7.0, GOLD)
