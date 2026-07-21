class_name BasicCardTrayItem
extends Control

signal detail_hovered(definition)
signal detail_unhovered(card_id)
signal detail_clicked(definition)

const PAPER := Color("e0cfaa")
const INK := Color("1d1915")
const PANEL := Color(0.80, 0.72, 0.58, 0.97)
const MUTED := Color("665b4b")
const GOLD := Color("c79a50")

var definition: Dictionary = {}
var _hovered := false
var _pinned := false
var _selected_for_placement := false

var _source_label: Label
var _range_label: Label
var _category_label: Label
var _name_label: Label
var _cost_label: Label
var _art: TextureRect

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    gui_input.connect(_on_gui_input)
    _build()
    resized.connect(_layout)
    _apply_definition()
    _layout()

func configure(value: Dictionary) -> void:
    definition = value.duplicate(true)
    if is_inside_tree():
        _build()
        _apply_definition()
        _layout()
    queue_redraw()

func set_pinned(value: bool) -> void:
    _pinned = value
    set_meta("detail_pinned", _pinned)
    queue_redraw()

func set_selected_for_placement(value: bool) -> void:
    _selected_for_placement = value
    set_meta("selected_for_placement", _selected_for_placement)
    queue_redraw()

func _on_mouse_entered() -> void:
    _hovered = true
    set_meta("detail_hovered", true)
    detail_hovered.emit(definition.duplicate(true))
    queue_redraw()

func _on_mouse_exited() -> void:
    _hovered = false
    set_meta("detail_hovered", false)
    detail_unhovered.emit(str(definition.get("id", "")))
    queue_redraw()

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton
        if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
            detail_clicked.emit(definition.duplicate(true))
            accept_event()

func _build() -> void:
    if _source_label != null:
        return

    _source_label = _make_label(11, INK, HORIZONTAL_ALIGNMENT_LEFT)
    _source_label.name = "SourceLabel"
    _range_label = _make_label(11, INK, HORIZONTAL_ALIGNMENT_CENTER)
    _range_label.name = "RangeLabel"
    _category_label = _make_label(11, PAPER, HORIZONTAL_ALIGNMENT_CENTER)
    _category_label.name = "CategoryLabel"
    _name_label = _make_label(18, INK, HORIZONTAL_ALIGNMENT_CENTER)
    _name_label.name = "CardNameLabel"
    _cost_label = _make_label(11, INK, HORIZONTAL_ALIGNMENT_CENTER)
    _cost_label.name = "CostLabel"

    _art = TextureRect.new()
    _art.name = "Illustration"
    _art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    _art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _art.modulate = Color(0.92, 0.90, 0.84, 0.78)
    add_child(_art)

func _make_label(font_size: int, color: Color, alignment: int) -> Label:
    var label := Label.new()
    label.horizontal_alignment = alignment
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.clip_text = true
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    add_child(label)
    return label

func _apply_definition() -> void:
    if _source_label == null or definition.is_empty():
        return

    var category := str(definition.get("category", "move"))
    var category_color := _category_color(category)
    var category_style := StyleBoxFlat.new()
    category_style.bg_color = Color(category_color, 0.92)
    category_style.border_color = Color(PAPER, 0.36)
    category_style.set_border_width_all(1)
    category_style.set_corner_radius_all(4)
    _category_label.add_theme_stylebox_override("normal", category_style)

    _source_label.text = "[%s]" % str(definition.get("source_label", "기초"))
    _range_label.text = "사거리 %s" % str(definition.get("range_text", "-"))
    _category_label.text = str(definition.get("category_label", ""))
    _name_label.text = str(definition.get("name", ""))
    _cost_label.text = "슬롯 %d  ·  기력 %d  ·  내력 %d" % [
        int(definition.get("action_slots", 0)),
        int(definition.get("stamina_cost", 0)),
        int(definition.get("internal_cost", 0))
    ]
    _art.texture = _texture_from_spec(definition.get("illustration", {}))

    set_meta("card_id", str(definition.get("id", "")))
    set_meta("source", str(definition.get("source", "")))
    set_meta("category", category)
    set_meta("information_interactions_enabled", true)
    set_meta("action_placement_enabled", true)
    set_meta("interactions_enabled", true)
    set_meta("selected_for_placement", false)
    tooltip_text = "%s · %s · 사거리 %s · 클릭 후 슬롯 배치" % [
        str(definition.get("source_label", "기초")),
        str(definition.get("category_label", "")),
        str(definition.get("range_text", "-"))
    ]
    queue_redraw()

func _texture_from_spec(spec: Dictionary) -> Texture2D:
    var path := str(spec.get("atlas", ""))
    var region: Array = spec.get("region", [])
    if path.is_empty() or region.size() != 4 or not ResourceLoader.exists(path):
        return null
    var texture := AtlasTexture.new()
    texture.atlas = load(path) as Texture2D
    texture.region = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
    return texture

func _category_color(category: String) -> Color:
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
            return Color("62594d")

func _layout() -> void:
    if _source_label == null:
        return
    var width := maxf(1.0, size.x)
    var height := maxf(1.0, size.y)
    var top_width := width / 3.0

    _source_label.position = Vector2(7.0, 4.0)
    _source_label.size = Vector2(maxf(1.0, top_width - 7.0), 18.0)
    _range_label.position = Vector2(top_width, 4.0)
    _range_label.size = Vector2(top_width, 18.0)
    _category_label.position = Vector2(top_width * 2.0 + 3.0, 4.0)
    _category_label.size = Vector2(maxf(1.0, top_width - 10.0), 18.0)

    _name_label.position = Vector2(6.0, 23.0)
    _name_label.size = Vector2(maxf(1.0, width - 12.0), 25.0)
    _art.position = Vector2(7.0, 50.0)
    _art.size = Vector2(maxf(1.0, width - 14.0), maxf(20.0, height - 78.0))
    _cost_label.position = Vector2(5.0, maxf(70.0, height - 25.0))
    _cost_label.size = Vector2(maxf(1.0, width - 10.0), 20.0)
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    var accent := _category_color(str(definition.get("category", "move")))
    var border_width := 5.0 if _selected_for_placement else (4.0 if _pinned else (3.0 if _hovered else 2.0))
    var highlight := GOLD if _selected_for_placement else (Color(PAPER, 0.95) if _pinned else Color(accent, 1.0 if _hovered else 0.95))
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), highlight, false, border_width)
    if _pinned:
        draw_rect(Rect2(Vector2(4.0, 3.0), Vector2(maxf(1.0, size.x - 8.0), 4.0)), Color(PAPER, 0.90), true)
    if _selected_for_placement:
        draw_rect(Rect2(Vector2(5.0, maxf(4.0, size.y - 8.0)), Vector2(maxf(1.0, size.x - 10.0), 4.0)), GOLD, true)
    draw_line(Vector2(6.0, 48.0), Vector2(maxf(6.0, size.x - 6.0), 48.0), Color(INK, 0.30), 1.0)
    draw_line(Vector2(6.0, maxf(72.0, size.y - 27.0)), Vector2(maxf(6.0, size.x - 6.0), maxf(72.0, size.y - 27.0)), Color(INK, 0.30), 1.0)
