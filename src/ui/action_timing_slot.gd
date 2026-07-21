class_name ActionTimingSlot
extends Control

signal slot_clicked(timing_index: int)

const PANEL := Color(0.075, 0.062, 0.048, 0.96)
const PANEL_ACTIVE := Color(0.13, 0.10, 0.055, 0.98)
const PAPER := Color("e0cfaa")
const GOLD := Color("c79a50")
const MUTED := Color("8e8372")
const LOCKED := Color("4f4940")
const TARGET_PENDING := Color("e6a84f")
const RESOURCE_BLOCKED := Color("b85a4a")

var timing_index := 1
var bundle_index := 1
var local_index := 1
var slot_state := "locked"
var assigned_definition: Dictionary = {}
var assignment_anchor_index := 0
var assignment_span := 0
var assignment_part_index := 0
var target_text := ""
var target_ready := true
var targeting_mode := "none"
var resource_ready := true
var resource_text := ""
var _hovered := false

var _timing_label: Label
var _placeholder_label: Label
var _status_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    gui_input.connect(_on_gui_input)
    _timing_label = _make_label(13, PAPER)
    _placeholder_label = _make_label(16, MUTED)
    _status_label = _make_label(11, MUTED)
    resized.connect(_layout)
    _refresh()
    _layout()

func configure(global_index: int, group_index: int, timing_in_group: int, state: String) -> void:
    timing_index = global_index
    bundle_index = group_index
    local_index = timing_in_group
    slot_state = state
    set_meta("timing_index", timing_index)
    set_meta("bundle_index", bundle_index)
    set_meta("local_index", local_index)
    set_meta("slot_state", slot_state)
    set_meta("card_content", has_assignment())
    set_meta("placement_enabled", can_receive_placement())
    if is_inside_tree():
        _refresh()
        _layout()
    queue_redraw()

func can_receive_placement() -> bool:
    return slot_state == "current" or slot_state == "available"

func has_assignment() -> bool:
    return not assigned_definition.is_empty()

func set_assignment(definition: Dictionary, anchor_index: int, span: int, part_index: int) -> void:
    assigned_definition = definition.duplicate(true)
    assignment_anchor_index = anchor_index
    assignment_span = span
    assignment_part_index = part_index
    target_text = ""
    target_ready = true
    targeting_mode = "none"
    resource_ready = true
    resource_text = ""
    set_meta("card_content", true)
    set_meta("card_id", str(assigned_definition.get("id", "")))
    set_meta("card_name", str(assigned_definition.get("name", "")))
    set_meta("assignment_anchor_index", assignment_anchor_index)
    set_meta("assignment_span", assignment_span)
    set_meta("assignment_part_index", assignment_part_index)
    set_meta("resource_ready", true)
    _refresh()
    queue_redraw()

func set_target_info(value_text: String, value_ready: bool, value_mode: String) -> void:
    target_text = value_text
    target_ready = value_ready
    targeting_mode = value_mode
    set_meta("target_text", target_text)
    set_meta("target_ready", target_ready)
    set_meta("targeting_mode", targeting_mode)
    _refresh()
    queue_redraw()

func set_resource_info(value_ready: bool, value_text: String = "") -> void:
    resource_ready = value_ready
    resource_text = value_text
    set_meta("resource_ready", resource_ready)
    set_meta("resource_text", resource_text)
    _refresh()
    queue_redraw()

func clear_assignment() -> void:
    assigned_definition.clear()
    assignment_anchor_index = 0
    assignment_span = 0
    assignment_part_index = 0
    target_text = ""
    target_ready = true
    targeting_mode = "none"
    resource_ready = true
    resource_text = ""
    set_meta("card_content", false)
    set_meta("card_id", "")
    set_meta("card_name", "")
    set_meta("assignment_anchor_index", 0)
    set_meta("assignment_span", 0)
    set_meta("assignment_part_index", 0)
    set_meta("target_text", "")
    set_meta("target_ready", true)
    set_meta("targeting_mode", "none")
    set_meta("resource_ready", true)
    set_meta("resource_text", "")
    _refresh()
    queue_redraw()

func _on_mouse_entered() -> void:
    _hovered = true
    queue_redraw()

func _on_mouse_exited() -> void:
    _hovered = false
    queue_redraw()

func _on_gui_input(event: InputEvent) -> void:
    if not event is InputEventMouseButton:
        return
    var mouse_event := event as InputEventMouseButton
    if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
        return
    if not can_receive_placement() and not has_assignment():
        return
    slot_clicked.emit(timing_index)
    accept_event()

func _make_label(font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.clip_text = true
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    add_child(label)
    return label

func _refresh() -> void:
    if _timing_label == null:
        return
    _timing_label.text = "%d수" % local_index
    if has_assignment():
        var card_name := str(assigned_definition.get("name", ""))
        _placeholder_label.text = card_name if assignment_part_index == 0 else "↳ %s" % card_name
        if not resource_ready:
            _status_label.text = resource_text if not resource_text.is_empty() else "자원 부족"
        elif not target_ready and targeting_mode != "none":
            _status_label.text = "대상 선택"
        elif not target_text.is_empty():
            _status_label.text = target_text
        else:
            _status_label.text = "%d슬롯" % assignment_span if assignment_part_index == 0 else "연결"
    else:
        _placeholder_label.text = "＋" if can_receive_placement() else "—"
        _status_label.text = _state_text()
    var accent := _display_color()
    _timing_label.add_theme_color_override("font_color", PAPER if slot_state != "locked" else MUTED)
    _placeholder_label.add_theme_color_override("font_color", accent)
    _status_label.add_theme_color_override("font_color", accent)
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if can_receive_placement() or has_assignment() else Control.CURSOR_ARROW

func _state_text() -> String:
    match slot_state:
        "passed":
            return "경과"
        "current", "available":
            return "배치"
        _:
            return "잠김"

func _state_color() -> Color:
    match slot_state:
        "passed":
            return MUTED
        "current":
            return GOLD
        "available":
            return Color("d8bd7c")
        _:
            return LOCKED

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
            return GOLD

func _display_color() -> Color:
    if has_assignment() and not resource_ready:
        return RESOURCE_BLOCKED
    if has_assignment() and not target_ready and targeting_mode != "none":
        return TARGET_PENDING
    if has_assignment():
        return _category_color(str(assigned_definition.get("category", "")))
    return _state_color()

func _layout() -> void:
    if _timing_label == null:
        return
    var width := maxf(1.0, size.x - 8.0)
    _timing_label.position = Vector2(4.0, 3.0)
    _timing_label.size = Vector2(width, 20.0)
    _placeholder_label.position = Vector2(4.0, 21.0)
    _placeholder_label.size = Vector2(width, maxf(20.0, size.y - 45.0))
    _status_label.position = Vector2(4.0, maxf(39.0, size.y - 22.0))
    _status_label.size = Vector2(width, 18.0)
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    var accent := _display_color()
    var fill := PANEL_ACTIVE if slot_state == "current" else PANEL
    if slot_state == "locked":
        fill = Color(PANEL, 0.72)
    if has_assignment():
        fill = Color(accent, 0.26)
    draw_rect(Rect2(Vector2.ZERO, size), fill, true)
    var border_alpha := 1.0 if _hovered else 0.78
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(accent, border_alpha), false, 3.0 if _hovered else 2.0)
    if slot_state == "current" or (has_assignment() and assignment_part_index == 0):
        draw_line(Vector2(8.0, 3.0), Vector2(maxf(8.0, size.x - 8.0), 3.0), accent, 3.0)
    if has_assignment() and assignment_part_index > 0:
        draw_line(Vector2(3.0, 8.0), Vector2(3.0, maxf(8.0, size.y - 8.0)), accent, 3.0)
