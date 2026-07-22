class_name CombatantStatusPanel
extends Control

const PANEL := Color(0.055, 0.047, 0.039, 0.94)
const PAPER := Color("dbc9a4")
const MUTED := Color("a7977e")
const PLAYER_ACCENT := Color("377fb2")
const ENEMY_ACCENT := Color("b44d43")
const HEALTH_COLOR := Color("b54d44")
const STAMINA_COLOR := Color("4c9a91")
const INTERNAL_COLOR := Color("8a63a9")

var side: String = "player"
var combatant: Dictionary = {}

var _name_label: Label
var _epithet_label: Label
var _health_label: Label
var _stamina_label: Label
var _internal_label: Label
var _status_labels: Array[Label] = []

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _name_label = _make_label(18, PAPER)
    _epithet_label = _make_label(12, MUTED)
    _health_label = _make_label(13, PAPER)
    _stamina_label = _make_label(13, PAPER)
    _internal_label = _make_label(13, PAPER)
    resized.connect(_layout)
    _refresh()
    _layout()

func configure(value_side: String, value_combatant: Dictionary) -> void:
    side = value_side
    combatant = value_combatant.duplicate(true)
    if is_inside_tree():
        _refresh()
        _layout()
    queue_redraw()

func _make_label(font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    add_child(label)
    return label

func _refresh() -> void:
    if _name_label == null:
        return
    _name_label.text = str(combatant.get("name", "이름 미정"))
    _epithet_label.text = "[%s]" % str(combatant.get("epithet", "이명 미정"))
    _health_label.text = _format_resource("체력", "health")
    _stamina_label.text = _format_resource("기력", "stamina")
    _internal_label.text = _format_resource("내력", "internal")

    for label in _status_labels:
        label.queue_free()
    _status_labels.clear()

    var statuses = combatant.get("statuses", [])
    if typeof(statuses) == TYPE_ARRAY:
        for raw_status in statuses:
            if typeof(raw_status) != TYPE_DICTIONARY:
                continue
            var status: Dictionary = raw_status
            var chip := _make_label(12, PAPER)
            chip.text = str(status.get("label", "?"))
            chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
            chip.set_meta("kind", str(status.get("kind", "neutral")))
            _status_labels.append(chip)

func _format_resource(label: String, key: String) -> String:
    var pair := _resource_pair(key)
    return "%s  %d/%d" % [label, pair.x, pair.y]

func _resource_pair(key: String) -> Vector2i:
    var value = combatant.get(key, [0, 0])
    if typeof(value) == TYPE_ARRAY and value.size() >= 2:
        return Vector2i(int(value[0]), maxi(1, int(value[1])))
    return Vector2i.ZERO

func _layout() -> void:
    if _name_label == null:
        return

    var portrait_size := minf(84.0, maxf(56.0, size.y - 26.0))
    var portrait_x := 12.0 if side == "player" else size.x - portrait_size - 12.0
    var content_x := portrait_x + portrait_size + 14.0 if side == "player" else 12.0
    var content_right := size.x - 12.0 if side == "player" else portrait_x - 14.0
    var content_width := maxf(120.0, content_right - content_x)

    _name_label.position = Vector2(content_x, 10.0)
    _name_label.size = Vector2(content_width, 24.0)
    _name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if side == "player" else HORIZONTAL_ALIGNMENT_RIGHT

    _epithet_label.position = Vector2(content_x, 31.0)
    _epithet_label.size = Vector2(content_width, 18.0)
    _epithet_label.horizontal_alignment = _name_label.horizontal_alignment

    var labels := [_health_label, _stamina_label, _internal_label]
    for index in range(labels.size()):
        var label: Label = labels[index]
        label.position = Vector2(content_x, 50.0 + float(index) * 21.0)
        label.size = Vector2(content_width, 18.0)
        label.horizontal_alignment = _name_label.horizontal_alignment

    var chip_y := maxf(100.0, size.y - 22.0)
    for index in range(_status_labels.size()):
        var chip := _status_labels[index]
        var chip_x := portrait_x + 8.0 + float(index) * 25.0 if side == "player" else portrait_x + portrait_size - 30.0 - float(index) * 25.0
        chip.position = Vector2(chip_x, chip_y)
        chip.size = Vector2(22.0, 20.0)

    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    var accent := PLAYER_ACCENT if side == "player" else ENEMY_ACCENT
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(accent, 0.72), false, 2.0)
    draw_rect(Rect2(Vector2(0.0, 0.0), Vector2(size.x, 4.0)), accent, true)

    var portrait_size := minf(84.0, maxf(56.0, size.y - 26.0))
    var portrait_x := 12.0 if side == "player" else size.x - portrait_size - 12.0
    var portrait_rect := Rect2(Vector2(portrait_x, 14.0), Vector2(portrait_size, portrait_size))
    draw_circle(portrait_rect.get_center(), portrait_size * 0.5, Color(0.02, 0.018, 0.016, 0.92))
    draw_arc(portrait_rect.get_center(), portrait_size * 0.48, 0.0, TAU, 48, accent, 3.0, true)
    draw_circle(portrait_rect.get_center() + Vector2(0.0, -portrait_size * 0.12), portrait_size * 0.13, Color(PAPER, 0.70))
    var body := PackedVector2Array([
        portrait_rect.get_center() + Vector2(-portrait_size * 0.22, portrait_size * 0.31),
        portrait_rect.get_center() + Vector2(0.0, portrait_size * 0.04),
        portrait_rect.get_center() + Vector2(portrait_size * 0.22, portrait_size * 0.31)
    ])
    draw_colored_polygon(body, Color(PAPER, 0.58))

    var content_x := portrait_x + portrait_size + 14.0 if side == "player" else 12.0
    var content_right := size.x - 12.0 if side == "player" else portrait_x - 14.0
    var bar_width := maxf(48.0, content_right - content_x - 78.0)
    var bar_x := content_right - bar_width if side == "player" else content_x

    _draw_resource_bar(Rect2(bar_x, 66.0, bar_width, 5.0), _resource_pair("health"), HEALTH_COLOR)
    _draw_resource_bar(Rect2(bar_x, 87.0, bar_width, 5.0), _resource_pair("stamina"), STAMINA_COLOR)
    _draw_resource_bar(Rect2(bar_x, 108.0, bar_width, 5.0), _resource_pair("internal"), INTERNAL_COLOR)

    for chip in _status_labels:
        var kind := str(chip.get_meta("kind", "neutral"))
        var chip_color := _status_color(kind)
        draw_rect(Rect2(chip.position, chip.size), Color(chip_color, 0.42), true)
        draw_rect(Rect2(chip.position + Vector2.ONE, chip.size - Vector2(2.0, 2.0)), chip_color, false, 1.0)

func _draw_resource_bar(rect: Rect2, pair: Vector2i, color: Color) -> void:
    draw_rect(rect, Color(0.18, 0.16, 0.13, 0.92), true)
    var ratio := clampf(float(pair.x) / float(maxi(1, pair.y)), 0.0, 1.0)
    draw_rect(Rect2(rect.position, Vector2(rect.size.x * ratio, rect.size.y)), color, true)

func _status_color(kind: String) -> Color:
    match kind:
        "defense":
            return Color("4d7f9e")
        "offense":
            return Color("a24d45")
        _:
            return Color("8a795f")
