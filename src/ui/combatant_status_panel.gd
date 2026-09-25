class_name CombatantStatusPanel
extends Control

const PANEL := Color(0.055, 0.047, 0.039, 0.94)
const PAPER := Color("dbc9a4")
const MUTED := Color("a7977e")
const PLAYER_ACCENT := Color("377fb2")
const ENEMY_ACCENT := Color("b44d43")
const HEALTH_COLOR := Color("b54d44")
const STAMINA_COLOR := Color("4c74a9")
const INTERNAL_COLOR := Color("398d91")
const PLAYER_PORTRAIT := preload("res://assets/portraits/player_wanderer_ink_v1.png")
const ENEMY_PORTRAIT := preload("res://assets/portraits/enemy_masked_ink_v1.png")
const DOGYEOM_STATUS_PORTRAIT := preload("res://assets/portraits/dogyeom_status_portrait_01_v1.png")
const DOGYEOM_CANDIDATE_ID := "slot1_dogyeom"
const STATUS_HUD_FRAME := preload("res://assets/ui/duel/status_hud_frame_01_v1.png")

var side: String = "player"
var combatant: Dictionary = {}
var momentum := Vector2i(0, 5)

var _name_label: Label
var _epithet_label: Label
var _health_label: Label
var _stamina_label: Label
var _internal_label: Label
var _status_labels: Array[Label] = []
var _portrait: TextureRect
var _status_hud_frame: TextureRect
var show_numeric_values := true

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _status_hud_frame = TextureRect.new()
    _status_hud_frame.name = "StatusHudFrame"
    _status_hud_frame.show_behind_parent = true
    _status_hud_frame.visible = false
    _status_hud_frame.texture = STATUS_HUD_FRAME
    _status_hud_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _status_hud_frame.stretch_mode = TextureRect.STRETCH_SCALE
    _status_hud_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _status_hud_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_status_hud_frame)
    _portrait = TextureRect.new()
    _portrait.name = "CombatantInkPortrait"
    _portrait.visible = false
    _portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    _portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_portrait)
    _name_label = _make_label(18, PAPER)
    _epithet_label = _make_label(12, MUTED)
    _health_label = _make_label(13, PAPER)
    _stamina_label = _make_label(13, PAPER)
    _internal_label = _make_label(13, PAPER)
    resized.connect(_layout)
    _refresh()
    _layout()

func configure(value_side: String, value_combatant: Dictionary, value_momentum: Array = []) -> void:
    side = value_side
    show_numeric_values = side == "player"
    combatant = value_combatant.duplicate(true)
    var momentum_value = value_momentum if value_momentum.size() >= 2 else combatant.get("momentum", [0, 5])
    if typeof(momentum_value) == TYPE_ARRAY and momentum_value.size() >= 2:
        momentum = Vector2i(clampi(int(momentum_value[0]), 0, maxi(1, int(momentum_value[1]))), maxi(1, int(momentum_value[1])))
    else:
        momentum = Vector2i(0, 5)
    if is_inside_tree():
        _refresh()
        _layout()
    queue_redraw()
    set_meta("status_hud_frame_path", "res://assets/ui/duel/status_hud_frame_01_v1.png")
    set_meta("status_hud_frame_loaded", STATUS_HUD_FRAME != null)
    set_meta("numeric_values_visible", show_numeric_values)

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

    if is_instance_valid(_portrait):
        _portrait.texture = _portrait_for_current_combatant()
    if is_instance_valid(_status_hud_frame):
        _status_hud_frame.flip_h = side == "enemy"

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
            if str(status.get("kind", "")) == "fortitude":
                chip.add_theme_font_size_override("font_size", 10)
            chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
            chip.set_meta("kind", str(status.get("kind", "neutral")))
            chip.tooltip_text = str(status.get("description", chip.text))
            chip.accessibility_name = "%s 상태" % chip.text
            chip.accessibility_description = chip.tooltip_text
            _status_labels.append(chip)

func _portrait_for_current_combatant() -> Texture2D:
    if side == "player":
        return PLAYER_PORTRAIT
    if str(combatant.get("candidate_id", "")) == DOGYEOM_CANDIDATE_ID:
        return DOGYEOM_STATUS_PORTRAIT
    return ENEMY_PORTRAIT

func _format_resource(label: String, key: String) -> String:
    var pair := _resource_pair(key)
    return "%s  %d/%d" % [label, pair.x, pair.y] if show_numeric_values else "%s  ?/?" % label

func get_visible_resource_ratio(key: String) -> float:
    if not show_numeric_values:
        return -1.0
    var pair := _resource_pair(key)
    return clampf(float(pair.x) / float(maxi(1, pair.y)), 0.0, 1.0)

func _resource_pair(key: String) -> Vector2i:
    var value = combatant.get(key, [0, 0])
    if typeof(value) == TYPE_ARRAY and value.size() >= 2:
        return Vector2i(int(value[0]), maxi(1, int(value[1])))
    return Vector2i.ZERO

func _layout() -> void:
    if _name_label == null:
        return

    if bool(get_meta("reference_preparation", false)):
        _layout_reference_preparation()
        return
    if bool(get_meta("ink_preparation", false)):
        _layout_ink_preparation()
        return
    # Keep legacy portrait resources addressable, but the live status surface
    # reserves its width for actual resources instead of a baked portrait frame.
    var portrait_size := minf(size.x * 0.232, size.y * 0.70)
    var portrait_x := size.x * 0.105 if side == "player" else size.x - size.x * 0.105 - portrait_size
    var resource_layout := get_resource_layout_snapshot()
    var resource_x := float(resource_layout.get("resource_x", 0.0))
    var resource_width := float(resource_layout.get("resource_width", 0.0))
    var label_rects: Array = resource_layout.get("label_rects", [])

    if is_instance_valid(_portrait):
        _portrait.position = Vector2(portrait_x, size.y * 0.125)
        _portrait.size = Vector2(portrait_size, minf(size.y * 0.72, portrait_size * 1.10))

    _name_label.visible = true
    _name_label.position = Vector2(16.0, 5.0)
    _name_label.size = Vector2(size.x - 32.0, 22.0)
    _name_label.add_theme_font_size_override("font_size", 16)
    _epithet_label.visible = false

    var labels := [_health_label, _stamina_label, _internal_label]
    for index in range(labels.size()):
        var label: Label = labels[index]
        var label_rect: Rect2 = label_rects[index] as Rect2
        label.position = label_rect.position
        label.size = label_rect.size
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if side == "player" else HORIZONTAL_ALIGNMENT_RIGHT
        label.add_theme_font_size_override("font_size", 12)

    var chip_y := size.y - 24.0
    for index in range(_status_labels.size()):
        var chip := _status_labels[index]
        var chip_width := 34.0
        var chip_gap := 4.0
        var chip_x := resource_x + 18.0 + float(index) * (chip_width + chip_gap) if side == "player" else resource_x + resource_width - 18.0 - chip_width - float(index) * (chip_width + chip_gap)
        chip.position = Vector2(chip_x, chip_y)
        chip.size = Vector2(chip_width, 17.0)

    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    if bool(get_meta("reference_preparation", false)):
        _draw_reference_preparation()
        return
    if bool(get_meta("ink_preparation", false)):
        _draw_ink_preparation()
        return
    # Native live UI, not an illustration: no baked values or duplicate wells.
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.045, 0.06, 0.94))
    draw_rect(Rect2(Vector2.ONE, size - Vector2(2.0, 2.0)), Color("ae8c55"), false, 1.0)
    var resource_layout := get_resource_layout_snapshot()
    var resource_x := float(resource_layout.get("resource_x", 0.0))
    var resource_width := float(resource_layout.get("resource_width", 0.0))
    var bar_rects: Array = resource_layout.get("bar_rects", [])

    _draw_resource_bar(bar_rects[0] as Rect2, "health", HEALTH_COLOR)
    _draw_resource_bar(bar_rects[1] as Rect2, "stamina", STAMINA_COLOR)
    _draw_resource_bar(bar_rects[2] as Rect2, "internal", INTERNAL_COLOR)
    _draw_momentum(resource_x, resource_x + resource_width)

func get_resource_layout_snapshot() -> Dictionary:
    if bool(get_meta("reference_preparation", false)):
        var x := 139.0 if side == "player" else 2.0
        return {"resource_x":x, "resource_width":191.0,
            "label_rects":[_health_label.get_rect(), _stamina_label.get_rect(), _internal_label.get_rect()],
            "bar_rects":[Rect2(x,84,191,5),Rect2(x,111,191,5),Rect2(x,138,191,5)]}
    if bool(get_meta("ink_preparation", false)):
        var x := 100.0 if side == "player" else 0.0
        var width := size.x - 102.0
        return {"resource_x":x, "resource_width":width,
            "label_rects":[_health_label.get_rect(), _stamina_label.get_rect(), _internal_label.get_rect()],
            "bar_rects":[Rect2(x,44,width,2),Rect2(x,61,width,2),Rect2(x,78,width,2)]}
    var resource_x := 16.0
    var resource_width := maxf(30.0, size.x - 32.0)
    var label_rects: Array[Rect2] = []
    var bar_rects: Array[Rect2] = []
    for index in range(3):
        var label_y := 29.0 + float(index) * 20.0
        label_rects.append(Rect2(resource_x, label_y, resource_width, 13.0))
        bar_rects.append(Rect2(resource_x, label_y + 15.0, resource_width, 5.0))
    return {
        "resource_x": resource_x,
        "resource_width": resource_width,
        "label_rects": label_rects,
        "bar_rects": bar_rects
    }

func get_momentum_rect() -> Rect2:
    var center_y := minf(116.0, size.y - 30.0)
    return Rect2(16.0, center_y - 7.0, maxf(30.0, size.x - 32.0), 12.0)

func _draw_momentum(content_x: float, content_right: float) -> void:
    var center_y := get_momentum_rect().position.y + 7.0
    var label_position := Vector2(content_x, center_y + 3.0) if side == "player" else Vector2(content_right - 58.0, center_y + 3.0)
    draw_string(get_theme_default_font(), label_position, "절초 기세", HORIZONTAL_ALIGNMENT_LEFT, 58.0, 10, PAPER)
    var dot_gap := 17.0
    var total_width := float(maxi(1, momentum.y) - 1) * dot_gap + 12.0
    var start_x := content_x + 61.0 if side == "player" else content_right - 61.0 - total_width
    for index in range(momentum.y):
        var center := Vector2(start_x + float(index) * dot_gap + 6.0, center_y)
        var filled := index < momentum.x
        draw_circle(center, 5.0, Color("c79a50") if filled else Color("392f26"))
        draw_arc(center, 5.0, 0.0, TAU, 16, Color("e0b768"), 1.0)

func _draw_resource_bar(rect: Rect2, key: String, color: Color) -> void:
    draw_rect(rect, Color(0.18, 0.16, 0.13, 0.92), true)
    var ratio := get_visible_resource_ratio(key)
    if ratio >= 0.0:
        draw_rect(Rect2(rect.position, Vector2(rect.size.x * ratio, rect.size.y)), color, true)

func _status_color(kind: String) -> Color:
    match kind:
        "defense":
            return Color("4d7f9e")
        "offense":
            return Color("a24d45")
        "fortitude":
            return Color("c79a50")
        _:
            return Color("8a795f")

func _layout_ink_preparation() -> void:
    var left := side == "player"
    var x := 100.0 if left else 0.0
    var width := size.x - 102.0
    _portrait.visible = true
    var path := "res://assets/combat/ink_wuxia/player-0.png"
    if not left:
        path = "res://assets/combat/ink_wuxia/slot1_dogyeom/enemy-0.png" if str(combatant.get("candidate_id", "")) == DOGYEOM_CANDIDATE_ID else "res://assets/combat/ink_wuxia/enemy-0.png"
    if ResourceLoader.exists(path):
        var original := load(path) as Texture2D
        var portrait := AtlasTexture.new()
        portrait.atlas = original
        portrait.region = Rect2(original.get_width()*0.30, original.get_height()*0.07, original.get_width()*0.50, original.get_height()*0.50)
        _portrait.texture = portrait
    _portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _portrait.position = Vector2(0 if left else size.x - 98, -7)
    _portrait.size = Vector2(98, 120)
    _name_label.position = Vector2(x, 0)
    _name_label.size = Vector2(width, 24)
    _name_label.add_theme_font_size_override("font_size", 18)
    _epithet_label.hide()
    var labels := [_health_label, _stamina_label, _internal_label]
    for i in range(3):
        labels[i].position = Vector2(x, 27 + i * 17)
        labels[i].size = Vector2(width, 16)
        labels[i].add_theme_font_size_override("font_size", 11)
    for label in [_name_label, _health_label, _stamina_label, _internal_label]:
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT
        label.add_theme_color_override("font_color", Color("242820"))
        label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
    for i in range(_status_labels.size()):
        var label: Label = _status_labels[i]
        label.position = Vector2(x + i * 38, 90)
        label.size = Vector2(36, 16)
        label.add_theme_color_override("font_color", Color("242820"))
        label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
    queue_redraw()

func _draw_ink_preparation() -> void:
    var x := 100.0 if side == "player" else 0.0
    var width := size.x - 102.0
    # Translucent paper supports native values without a heavy enclosing box.
    draw_rect(Rect2(x - 5, 0, width + 10, 87), Color(0.90, 0.87, 0.79, 0.90))
    var keys := ["health", "stamina", "internal"]
    var colors := [HEALTH_COLOR, STAMINA_COLOR, INTERNAL_COLOR]
    for i in range(3):
        var rect := Rect2(x, 44 + i * 17, width, 2)
        draw_rect(rect, Color("8f8a7d"))
        var ratio := get_visible_resource_ratio(keys[i])
        if ratio >= 0:
            rect.size.x *= ratio
            draw_rect(rect, colors[i])
    for i in range(momentum.y):
        draw_circle(Vector2(x + 7 + i * 12, 84), 3, Color("a78947") if i < momentum.x else Color("77715f"))

func _layout_reference_preparation() -> void:
    var skin = preload("res://src/ui/ink/reference_preparation_skin.gd")
    var left := side == "player"
    var x := 139.0 if left else 2.0
    _portrait.show()
    _portrait.texture = skin.character(side, str(combatant.get("candidate_id","")), true)
    _portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _portrait.position = Vector2(-22 if left else 208, -4)
    _portrait.size = Vector2(161,213)
    if _portrait.material == null:
        _portrait.material = skin.portrait_material()
    _name_label.position = Vector2(x,21)
    _name_label.size = Vector2(197,35)
    _name_label.add_theme_font_size_override("font_size",27)
    _epithet_label.hide()
    var labels := [_health_label, _stamina_label, _internal_label]
    for i in range(3):
        labels[i].position = Vector2(x,61 + i * 27)
        var resource_font_size := 20
        labels[i].add_theme_font_size_override("font_size",resource_font_size)
        # Fit actual fallback-font metrics to the reference's text-above-bar lane.
        while labels[i].get_combined_minimum_size().y > 23.0 and resource_font_size > 12:
            resource_font_size -= 1
            labels[i].add_theme_font_size_override("font_size",resource_font_size)
        labels[i].size = Vector2(193,23)
    for label in [_name_label,_health_label,_stamina_label,_internal_label]:
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT
        label.add_theme_color_override("font_color",Color("25251f"))
        label.add_theme_color_override("font_shadow_color",Color.TRANSPARENT)
    for i in range(_status_labels.size()):
        _status_labels[i].position = Vector2(x + i*47,155)
        _status_labels[i].size = Vector2(44,24)
        _status_labels[i].add_theme_font_size_override("font_size",18)
        _status_labels[i].add_theme_color_override("font_color",Color("35352b"))
        _status_labels[i].add_theme_color_override("font_shadow_color",Color.TRANSPARENT)
    queue_redraw()

func _draw_reference_preparation() -> void:
    var x := 139.0 if side == "player" else 2.0
    var bars: Array = get_resource_layout_snapshot().bar_rects
    for i in range(3):
        var rect: Rect2 = bars[i]
        draw_rect(rect,Color("898579"))
        var ratio := get_visible_resource_ratio(["health","stamina","internal"][i])
        if ratio >= 0:
            rect.size.x *= ratio
            draw_rect(rect,[HEALTH_COLOR,STAMINA_COLOR,INTERNAL_COLOR][i])
    for i in range(momentum.y):
        draw_circle(Vector2(x+6+i*16,148),4,Color("987c42") if i < momentum.x else Color("7a7464"))
