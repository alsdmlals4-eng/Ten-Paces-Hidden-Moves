class_name BasicActionPanel
extends Control

signal action_selected(definition: Dictionary)
signal detail_requested(definition: Dictionary, pinned: bool)
signal detail_cleared()

const ADAPTER_SCRIPT := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
const COLUMNS := 5
const PAPER_SURFACE := Color("d9ccb1")
const PAPER_HOVER := Color("eee2c9")
const CHARCOAL_INK := Color("211c17")
const RESTRAINED_GOLD := Color("b99254")

@onready var title_label: Label = $PanelColumn/Title
@onready var action_grid: GridContainer = %ActionGrid

var actions: Array[Dictionary] = []
var buttons: Array[Button] = []
var interaction_enabled := true

func _ready() -> void:
    action_grid.columns = COLUMNS
    title_label.add_theme_color_override("font_color", Color("ead8b4"))
    title_label.add_theme_font_size_override("font_size", 15)
    actions = ADAPTER_SCRIPT.new().build_basic_actions()
    _rebuild()
    set_meta("presentation_surface", "paper_ink_r1")

func set_interaction_enabled(enabled: bool) -> void:
    interaction_enabled = enabled
    for button in buttons:
        button.disabled = not interaction_enabled
    set_meta("interaction_enabled", interaction_enabled)

func get_panel_snapshot() -> Dictionary:
    var ids: Array[String] = []
    for definition in actions:
        ids.append(str(definition.get("id", "")))
    return {
        "action_count": actions.size(),
        "columns": COLUMNS,
        "action_ids": ids,
        "scrolling_enabled": false,
        "interaction_enabled": interaction_enabled
    }

func _rebuild() -> void:
    for child in action_grid.get_children():
        child.queue_free()
    buttons.clear()

    for definition in actions:
        var button := Button.new()
        button.custom_minimum_size = Vector2(0.0, 96.0)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.focus_mode = Control.FOCUS_ALL
        button.text = ""
        button.tooltip_text = _tooltip_text(definition)
        button.accessibility_name = _accessibility_name(definition)
        _apply_ink_paper_style(button, str(definition.get("category", "")))
        _add_card_content(button, definition)
        button.mouse_entered.connect(_on_action_hovered.bind(definition))
        button.mouse_exited.connect(_on_action_unhovered)
        button.focus_entered.connect(_on_action_hovered.bind(definition))
        button.focus_exited.connect(_on_action_unhovered)
        button.pressed.connect(_on_action_pressed.bind(definition))
        action_grid.add_child(button)
        buttons.append(button)

    set_interaction_enabled(interaction_enabled)
    set_meta("layout", "grid_5_by_2")
    set_meta("action_count", actions.size())
    set_meta("card_art_enabled", true)
    set_meta("presentation_surface", "paper_ink_r1")

func _add_card_content(button: Button, definition: Dictionary) -> void:
    var illustration := TextureRect.new()
    illustration.name = "CardIllustration"
    illustration.texture = _texture_from_spec(definition.get("illustration", {}))
    illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
    illustration.modulate = Color(0.30, 0.27, 0.23, 0.94)
    illustration.set_anchors_preset(Control.PRESET_TOP_WIDE)
    illustration.offset_left = 7.0
    illustration.offset_top = 5.0
    illustration.offset_right = -7.0
    illustration.offset_bottom = 62.0
    button.add_child(illustration)

    var name_label := Label.new()
    name_label.name = "CardName"
    name_label.text = "%s  %d수" % [str(definition.get("name", "")), int(definition.get("action_slots", 1))]
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    name_label.clip_text = true
    name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    name_label.add_theme_font_size_override("font_size", 14)
    name_label.add_theme_color_override("font_color", CHARCOAL_INK)
    name_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    name_label.offset_left = 5.0
    name_label.offset_top = -31.0
    name_label.offset_right = -5.0
    name_label.offset_bottom = -15.0
    button.add_child(name_label)

    var facts_label := Label.new()
    facts_label.name = "CardFacts"
    facts_label.text = _compact_card_facts(definition)
    facts_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    facts_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    facts_label.clip_text = true
    facts_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    facts_label.add_theme_font_size_override("font_size", 10)
    facts_label.add_theme_color_override("font_color", Color("4d4032"))
    facts_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    facts_label.offset_left = 5.0
    facts_label.offset_top = -16.0
    facts_label.offset_right = -5.0
    facts_label.offset_bottom = -2.0
    button.add_child(facts_label)

func _compact_card_facts(definition: Dictionary) -> String:
    var costs := PackedStringArray()
    var stamina := int(definition.get("stamina_cost", 0))
    var internal := int(definition.get("internal_cost", 0))
    if stamina > 0:
        costs.append("기%d" % stamina)
    if internal > 0:
        costs.append("내%d" % internal)
    if costs.is_empty():
        costs.append("비용 없음")
    return "%s · 거리 %s" % [" ".join(costs), str(definition.get("range_text", "-"))]

func _texture_from_spec(spec: Dictionary) -> Texture2D:
    var path := str(spec.get("atlas", ""))
    var region: Array = spec.get("region", [])
    if path.is_empty() or region.size() != 4 or not ResourceLoader.exists(path):
        return null
    var texture := AtlasTexture.new()
    texture.atlas = load(path) as Texture2D
    texture.region = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
    return texture

func _apply_ink_paper_style(button: Button, category: String) -> void:
    var accent := _category_accent(category)
    var normal := StyleBoxFlat.new()
    normal.bg_color = PAPER_SURFACE
    normal.border_color = accent
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(3)
    normal.content_margin_left = 8.0
    normal.content_margin_right = 8.0
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = PAPER_HOVER
    hover.border_color = RESTRAINED_GOLD
    hover.set_border_width_all(3)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("c8b68f")
    pressed.border_color = CHARCOAL_INK
    var disabled := normal.duplicate() as StyleBoxFlat
    disabled.bg_color = Color("777064")
    disabled.border_color = Color("5d5448")
    var focus := StyleBoxFlat.new()
    focus.bg_color = Color(1.0, 1.0, 1.0, 0.08)
    focus.border_color = Color.WHITE
    focus.set_border_width_all(2)
    focus.set_corner_radius_all(3)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("disabled", disabled)
    button.add_theme_stylebox_override("focus", focus)
    button.add_theme_color_override("font_color", CHARCOAL_INK)
    button.add_theme_color_override("font_hover_color", CHARCOAL_INK)
    button.add_theme_color_override("font_pressed_color", CHARCOAL_INK)
    button.add_theme_color_override("font_disabled_color", Color("d2c6ab"))
    button.set_meta("keyboard_focus_ring", true)

func _category_accent(category: String) -> Color:
    match category:
        "move":
            return Color("3f7f5b")
        "attack":
            return Color("9a443d")
        "response":
            return Color("3f668d")
        "recovery":
            return Color("a37a32")
        "strengthen":
            return Color("705184")
        _:
            return RESTRAINED_GOLD

func _on_action_hovered(definition: Dictionary) -> void:
    detail_requested.emit(definition.duplicate(true), false)

func _on_action_unhovered() -> void:
    detail_cleared.emit()

func _on_action_pressed(definition: Dictionary) -> void:
    if not interaction_enabled:
        return
    detail_requested.emit(definition.duplicate(true), true)
    action_selected.emit(definition.duplicate(true))

func _tooltip_text(definition: Dictionary) -> String:
    return "%s · %s · %d수" % [
        str(definition.get("name", "")),
        str(definition.get("source_label", "기초")),
        int(definition.get("action_slots", 1))
    ]

func _accessibility_name(definition: Dictionary) -> String:
    return "%s, 기초 행동, %d수, 기력 %d, 내력 %d, 거리 %s" % [
        str(definition.get("name", "")),
        int(definition.get("action_slots", 1)),
        int(definition.get("stamina_cost", 0)),
        int(definition.get("internal_cost", 0)),
        str(definition.get("range_text", "-"))
    ]
