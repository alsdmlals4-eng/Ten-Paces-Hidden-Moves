class_name CardView
extends PanelContainer

signal card_selected(card_id: String)

const COST_ATLAS := "res://assets/ui/cards/cost_icon_atlas.svg"
const SLOT_SPEC := {"atlas": COST_ATLAS, "region": [9, 7, 65, 70]}
const STAMINA_SPEC := {"atlas": COST_ATLAS, "region": [91, 7, 70, 70]}
const INTERNAL_SPEC := {"atlas": COST_ATLAS, "region": [175, 7, 70, 70]}

var definition: Dictionary = {}
var _built := false
var _source: TextureRect
var _range: Label
var _category: TextureRect
var _name: Label
var _art: TextureRect
var _slot: Label
var _stamina: Label
var _internal: Label

func _ready() -> void:
    custom_minimum_size = Vector2(250, 420)
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    gui_input.connect(_on_gui_input)
    _build()
    _apply_definition()

func set_definition(value: Dictionary) -> void:
    definition = value.duplicate(true)
    if is_inside_tree():
        _build()
        _apply_definition()

func _build() -> void:
    if _built: return
    _built = true
    add_theme_stylebox_override("panel", _card_style())
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    add_child(column)
    var header := HBoxContainer.new()
    header.alignment = BoxContainer.ALIGNMENT_CENTER
    header.add_theme_constant_override("separation", 14)
    column.add_child(header)
    _source = _texture_rect(Vector2(58, 66)); header.add_child(_source)
    var range_panel := PanelContainer.new()
    range_panel.custom_minimum_size = Vector2(72, 38)
    range_panel.add_theme_stylebox_override("panel", _range_style())
    _range = Label.new(); _range.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _range.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _range.add_theme_font_size_override("font_size", 22)
    range_panel.add_child(_range); header.add_child(range_panel)
    _category = _texture_rect(Vector2(62, 62)); header.add_child(_category)
    _name = Label.new(); _name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _name.add_theme_font_size_override("font_size", 34)
    _name.add_theme_color_override("font_color", Color("211c17")); column.add_child(_name)
    column.add_child(HSeparator.new())
    _art = _texture_rect(Vector2(0, 265)); _art.size_flags_vertical = Control.SIZE_EXPAND_FILL
    _art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED; column.add_child(_art)
    var footer := HBoxContainer.new(); footer.alignment = BoxContainer.ALIGNMENT_CENTER
    footer.add_theme_constant_override("separation", 14); column.add_child(footer)
    _slot = _add_cost(footer, SLOT_SPEC, "행동 슬롯")
    _stamina = _add_cost(footer, STAMINA_SPEC, "기력")
    _internal = _add_cost(footer, INTERNAL_SPEC, "내력")

func _apply_definition() -> void:
    if not _built or definition.is_empty(): return
    _source.texture = _texture_from_spec(definition.source_badge)
    _category.texture = _texture_from_spec(definition.category_badge)
    _art.texture = _texture_from_spec(definition.illustration)
    _range.text = str(definition.get("range_text", "-"))
    _name.text = str(definition.get("name", ""))
    _slot.text = str(definition.get("action_slots", 0))
    _stamina.text = str(definition.get("stamina_cost", 0))
    _internal.text = str(definition.get("internal_cost", 0))
    tooltip_text = "%s · %s · 사거리 %s" % [definition.source_label, definition.category_label, definition.range_text]

func _add_cost(parent: HBoxContainer, spec: Dictionary, hint: String) -> Label:
    var box := VBoxContainer.new(); box.custom_minimum_size = Vector2(64, 64)
    var icon := _texture_rect(Vector2(36, 36)); icon.texture = _texture_from_spec(spec); box.add_child(icon)
    var value := Label.new(); value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    value.add_theme_font_size_override("font_size", 22); value.tooltip_text = hint
    box.add_child(value); parent.add_child(box); return value

func _texture_rect(minimum: Vector2) -> TextureRect:
    var result := TextureRect.new(); result.custom_minimum_size = minimum
    result.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    result.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    result.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return result

func _texture_from_spec(spec: Dictionary) -> Texture2D:
    var path := str(spec.get("atlas", "")); var region: Array = spec.get("region", [])
    if path.is_empty() or region.size() != 4 or not ResourceLoader.exists(path): return null
    var texture := AtlasTexture.new(); texture.atlas = load(path) as Texture2D
    texture.region = Rect2(region[0], region[1], region[2], region[3]); return texture

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        card_selected.emit(str(definition.get("id", "")))

func _card_style() -> StyleBoxFlat:
    var style := StyleBoxFlat.new(); style.bg_color = Color("d8c39c"); style.border_color = Color("8d6b35")
    style.set_border_width_all(3); style.set_corner_radius_all(10)
    style.content_margin_left = 12; style.content_margin_right = 12; style.content_margin_top = 12; style.content_margin_bottom = 12
    return style

func _range_style() -> StyleBoxFlat:
    var style := StyleBoxFlat.new(); style.bg_color = Color("211b17"); style.border_color = Color("9c773d")
    style.set_border_width_all(2); style.set_corner_radius_all(8); return style
