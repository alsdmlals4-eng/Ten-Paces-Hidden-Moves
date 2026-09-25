extends PanelContainer
signal closed
const ART = preload("res://src/ui/approved_blueprint_art.gd")
var grid: GridContainer
var illustration: TextureRect
var description: RichTextLabel

func _ready() -> void:
    anchor_left = 0.07
    anchor_right = 0.93
    anchor_top = 0.05
    anchor_bottom = 0.95
    var style := StyleBoxFlat.new()
    style.bg_color = Color("eee5d2")
    style.border_color = Color("413b30")
    style.set_border_width_all(2)
    for edge in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(edge, 20)
    add_theme_stylebox_override("panel", style)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 12)
    add_child(column)
    var header := HBoxContainer.new()
    column.add_child(header)
    var title := Label.new()
    title.text = "강호 도감"
    title.add_theme_font_size_override("font_size", 28)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close := Button.new()
    close.name = "LibraryClose"
    close.text = "돌아가기 · Esc"
    close.pressed.connect(func(): closed.emit())
    header.add_child(close)
    var tabs := HBoxContainer.new()
    column.add_child(tabs)
    for label in ["기초 행동", "무공과 절초"]:
        var tab := Button.new()
        tab.text = label
        tab.custom_minimum_size = Vector2(150, 40)
        tab.pressed.connect(_show_basics if label == "기초 행동" else _show_manuals)
        tabs.add_child(tab)
    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 24)
    column.add_child(body)
    var scroll := ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    body.add_child(scroll)
    grid = GridContainer.new()
    grid.columns = 2
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    scroll.add_child(grid)
    var detail := VBoxContainer.new()
    detail.custom_minimum_size.x = 320
    detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_child(detail)
    illustration = TextureRect.new()
    illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    illustration.custom_minimum_size.y = 205
    detail.add_child(illustration)
    description = RichTextLabel.new()
    description.size_flags_vertical = Control.SIZE_EXPAND_FILL
    description.bbcode_enabled = false
    detail.add_child(description)
    _show_basics()

func _clear() -> void:
    for child in grid.get_children():
        grid.remove_child(child)
        child.queue_free()

func _choice(title: String, texture: Texture2D, content: String) -> void:
    var button := Button.new()
    button.text = title
    button.icon = texture
    button.expand_icon = true
    button.add_theme_constant_override("icon_max_width", 72)
    button.custom_minimum_size = Vector2(180, 108)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.pressed.connect(func():
        illustration.texture = texture
        description.text = content)
    grid.add_child(button)
    if grid.get_child_count() == 1: button.pressed.emit()

func _show_basics() -> void:
    _clear()
    for action in preload("res://src/ui/action_selection/action_view_model_adapter.gd").new().build_basic_actions():
        var art := AtlasTexture.new()
        var spec: Dictionary = action.illustration
        art.atlas = load(spec.atlas)
        art.region = Rect2(spec.region[0], spec.region[1], spec.region[2], spec.region[3])
        _choice(action.name, art, "%s\n\n%d수 · 기력 %d · 내력 %d\n거리 %s\n\n%s" % [action.name, action.action_slots, action.stamina_cost, action.internal_cost, action.range_text, action.effect_text])

func _show_manuals() -> void:
    _clear()
    var registry = preload("res://src/combat/martial_manual_registry.gd").new()
    for id in registry.get_manual_ids():
        var manual: Dictionary = registry.get_manual(id)
        var lines := PackedStringArray(["[%s] %s" % [manual.faction, manual.manual_name], "주 능력치 %s / 보조 능력치 %s" % [manual.primary_stat, manual.secondary_stat], ""])
        for stage in ["star3", "star7", "star10"]:
            var card: Dictionary = manual.cards[stage]
            lines.append("%d성 · %s\n%d수 · 기력 %d · 내력 %d\n%s\n" % [card.unlock_star, card.name, card.action_slots, card.stamina_cost, card.internal_cost, card.get("effect_text", card.get("condition", ""))])
        _choice(manual.manual_name, ART.manual_illustration(id, 3), "\n".join(lines))

func _unhandled_key_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        closed.emit()
