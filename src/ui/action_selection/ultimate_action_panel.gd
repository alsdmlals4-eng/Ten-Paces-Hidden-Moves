class_name UltimateActionPanel
extends Control

signal ultimate_selected(definition: Dictionary)
signal detail_requested(definition: Dictionary, pinned: bool)
signal detail_cleared()

const ADAPTER_SCRIPT := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
const PAPER_SURFACE := Color("d9ccb1")
const PAPER_HOVER := Color("eee2c9")
const CHARCOAL_INK := Color("211c17")
const RESTRAINED_GOLD := Color("b99254")

@onready var momentum_label: Label = %MomentumLabel
@onready var segment_row: HBoxContainer = %SegmentRow
@onready var action_list: VBoxContainer = %ActionList

var momentum_current := 0
var momentum_maximum := 5
var martial_loadout: Array = []
var martial_mastery_by_manual: Dictionary = {}
var actions: Array[Dictionary] = []
var reservations: Array[Dictionary] = []
var action_buttons: Array[Button] = []
var interaction_enabled := true

func _ready() -> void:
    momentum_label.add_theme_color_override("font_color", Color("ead8b4"))
    momentum_label.add_theme_font_size_override("font_size", 15)
    set_momentum(momentum_current, momentum_maximum)
    set_meta("presentation_surface", "paper_ink_r1")

func set_martial_context(loadout: Array, mastery_by_manual: Dictionary) -> void:
    martial_loadout.clear()
    for value in loadout:
        martial_loadout.append(str(value))
    martial_mastery_by_manual = mastery_by_manual.duplicate(true)
    actions = ADAPTER_SCRIPT.new().build_ultimate_actions(momentum_current, martial_loadout, martial_mastery_by_manual)
    _rebuild_actions()

func set_momentum(current: int, maximum: int) -> void:
    momentum_maximum = maxi(1, maximum)
    momentum_current = clampi(current, 0, momentum_maximum)
    actions = ADAPTER_SCRIPT.new().build_ultimate_actions(momentum_current, martial_loadout, martial_mastery_by_manual)
    _rebuild_segments()
    _rebuild_actions()

func set_reservations(values: Array[Dictionary]) -> void:
    reservations.clear()
    for value in values:
        reservations.append(value.duplicate(true))
    _rebuild_actions()

func set_interaction_enabled(enabled: bool) -> void:
    interaction_enabled = enabled
    for button in action_buttons:
        var action_id := str(button.get_meta("action_id", ""))
        var action := get_action(action_id)
        button.disabled = not interaction_enabled or bool(action.get("locked", false)) or _is_reserved(action_id)
    set_meta("interaction_enabled", interaction_enabled)

func activate_ultimate(action_id: String) -> bool:
    if not interaction_enabled:
        return false
    var action := get_action(action_id)
    if action.is_empty() or bool(action.get("locked", false)) or _is_reserved(action_id):
        return false
    detail_requested.emit(action.duplicate(true), true)
    ultimate_selected.emit(action.duplicate(true))
    return true

func get_action(action_id: String) -> Dictionary:
    for action in actions:
        if str(action.get("id", "")) == action_id:
            return action
    return {}

func get_action_button(action_id: String) -> Button:
    for button in action_buttons:
        if str(button.get_meta("action_id", "")) == action_id:
            return button
    return null

func get_panel_snapshot() -> Dictionary:
    var enabled_count := 0
    var martial_count := 0
    var action_ids: Array[String] = []
    for action in actions:
        var action_id := str(action.get("id", ""))
        action_ids.append(action_id)
        if str(action.get("source", "")) == "martial_manual":
            martial_count += 1
        if not bool(action.get("locked", false)) and not _is_reserved(action_id):
            enabled_count += 1
    return {
        "momentum_current": momentum_current,
        "momentum_maximum": momentum_maximum,
        "segment_count": momentum_maximum,
        "action_count": actions.size(),
        "martial_ultimate_count": martial_count,
        "action_ids": action_ids,
        "enabled_count": enabled_count,
        "reservation_count": reservations.size(),
        "interaction_enabled": interaction_enabled,
        "martial_loadout": martial_loadout.duplicate(),
        "martial_mastery_by_manual": martial_mastery_by_manual.duplicate(true),
        "presentation_surface": str(get_meta("presentation_surface", ""))
    }

func _rebuild_segments() -> void:
    if not is_node_ready():
        return
    momentum_label.text = "절초기세 %d/%d" % [momentum_current, momentum_maximum]
    for child in segment_row.get_children():
        child.queue_free()
    for index in range(momentum_maximum):
        var segment := Label.new()
        segment.text = "●" if index < momentum_current else "○"
        segment.accessibility_name = "절초기세 %d번째, %s" % [index + 1, "충전" if index < momentum_current else "비어 있음"]
        segment.add_theme_font_size_override("font_size", 18)
        segment.add_theme_color_override("font_color", RESTRAINED_GOLD if index < momentum_current else Color("817461"))
        segment_row.add_child(segment)
    set_meta("momentum", [momentum_current, momentum_maximum])

func _rebuild_actions() -> void:
    if not is_node_ready():
        return
    for child in action_list.get_children():
        child.queue_free()
    action_buttons.clear()
    for action in actions:
        var action_id := str(action.get("id", ""))
        var button := Button.new()
        button.custom_minimum_size = Vector2(0.0, 50.0)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.focus_mode = Control.FOCUS_ALL
        button.text = _action_button_text(action)
        button.tooltip_text = _action_tooltip(action)
        button.accessibility_name = _action_accessibility_name(action)
        _apply_ultimate_paper_style(button, bool(action.get("locked", false)))
        button.set_meta("action_id", action_id)
        button.set_meta("locked", bool(action.get("locked", false)))
        button.set_meta("reserved", _is_reserved(action_id))
        button.disabled = not interaction_enabled or bool(action.get("locked", false)) or _is_reserved(action_id)
        button.pressed.connect(_on_action_pressed.bind(action_id))
        button.mouse_entered.connect(_on_action_focused.bind(action))
        button.focus_entered.connect(_on_action_focused.bind(action))
        button.mouse_exited.connect(_on_detail_unfocused)
        button.focus_exited.connect(_on_detail_unfocused)
        action_list.add_child(button)
        action_buttons.append(button)
    set_interaction_enabled(interaction_enabled)

func _apply_ultimate_paper_style(button: Button, locked: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = PAPER_SURFACE if not locked else Color("777064")
    normal.border_color = RESTRAINED_GOLD if not locked else Color("5d5448")
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(3)
    normal.content_margin_left = 10.0
    normal.content_margin_right = 10.0
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = PAPER_HOVER
    hover.border_color = Color("7e2f28")
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

func _on_action_pressed(action_id: String) -> void:
    activate_ultimate(action_id)

func _on_action_focused(action: Dictionary) -> void:
    detail_requested.emit(action.duplicate(true), false)

func _on_detail_unfocused() -> void:
    detail_cleared.emit()

func _action_button_text(action: Dictionary) -> String:
    var action_id := str(action.get("id", ""))
    var status := ""
    var reservation := _get_reservation(action_id)
    if not reservation.is_empty():
        status = "%d~%d수 예약" % [
            int(reservation.get("start_timing", 0)),
            int(reservation.get("end_timing", 0))
        ]
    elif bool(action.get("locked", false)):
        status = str(action.get("lock_reason", "잠김"))
    else:
        status = "사용 가능"
    return "%s · %s · %d수 · 기세 %d\n거리 %s · %s" % [
        str(action.get("source_label", "절초")),
        str(action.get("name", "")),
        int(action.get("action_slots", 1)),
        int(action.get("momentum_cost", 5)),
        str(action.get("range_text", "-")),
        status
    ]

func _action_tooltip(action: Dictionary) -> String:
    return "%s · 전조 %d · 실행 %d · %s" % [
        str(action.get("name", "")),
        int(action.get("telegraph_count", 0)),
        int(action.get("execution_count", 1)),
        str(action.get("lock_reason", "사용 가능")) if bool(action.get("locked", false)) else "사용 가능"
    ]

func _action_accessibility_name(action: Dictionary) -> String:
    var action_id := str(action.get("id", ""))
    var state := ""
    var reservation := _get_reservation(action_id)
    if not reservation.is_empty():
        state = "%d수부터 %d수까지 예약" % [
            int(reservation.get("start_timing", 0)),
            int(reservation.get("end_timing", 0))
        ]
    elif bool(action.get("locked", false)):
        state = "잠김, %s" % str(action.get("lock_reason", ""))
    else:
        state = "사용 가능"
    return "%s, %s 절초, %d수, 절초기세 %d, 거리 %s, %s" % [
        str(action.get("name", "")),
        str(action.get("source_label", "")),
        int(action.get("action_slots", 1)),
        int(action.get("momentum_cost", 5)),
        str(action.get("range_text", "-")),
        state
    ]

func _get_reservation(action_id: String) -> Dictionary:
    for reservation in reservations:
        if str(reservation.get("action_id", "")) == action_id:
            return reservation
    return {}

func _is_reserved(action_id: String) -> bool:
    return not _get_reservation(action_id).is_empty()
