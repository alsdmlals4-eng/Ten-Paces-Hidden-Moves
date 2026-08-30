class_name MartialActionPanel
extends Control

signal technique_selected(definition: Dictionary)
signal manual_focused(manual: Dictionary)
signal detail_requested(definition: Dictionary, pinned: bool)
signal detail_cleared()

const ADAPTER_SCRIPT := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
const ACTION_CHOICE_CARD_SCRIPT := preload("res://src/ui/action_selection/action_choice_card.gd")
const TECHNIQUE_COLUMNS := 3
const PAPER_SURFACE := Color("d9ccb1")
const PAPER_HOVER := Color("eee2c9")
const CHARCOAL_INK := Color("211c17")
const RESTRAINED_GOLD := Color("b99254")

@onready var title_label: Label = $PanelColumn/Title
@onready var manual_row: HBoxContainer = %ManualRow
@onready var selected_manual_title: Label = %SelectedManualTitle
@onready var technique_list: GridContainer = %TechniqueList

var manuals: Array[Dictionary] = []
var manual_buttons: Array[Button] = []
var technique_buttons: Array[Button] = []
var selected_manual_id := ""
var interaction_enabled := true

func _ready() -> void:
    title_label.add_theme_color_override("font_color", Color("ead8b4"))
    title_label.add_theme_font_size_override("font_size", 15)
    selected_manual_title.add_theme_color_override("font_color", Color("d6b36c"))
    selected_manual_title.add_theme_font_size_override("font_size", 14)
    set_manuals(ADAPTER_SCRIPT.new().build_owned_manuals())
    set_meta("presentation_surface", "paper_ink_r1")

func set_manuals(values: Array[Dictionary]) -> void:
    manuals.clear()
    for value in values:
        manuals.append(value.duplicate(true))
    if manuals.is_empty():
        selected_manual_id = ""
    elif not _has_manual(selected_manual_id):
        selected_manual_id = str(manuals[0].get("manual_id", ""))
    _rebuild_manuals()
    _rebuild_techniques()

func select_manual(manual_id: String) -> bool:
    if not interaction_enabled or not _has_manual(manual_id):
        return false
    selected_manual_id = manual_id
    _refresh_manual_selection()
    _rebuild_techniques()
    var manual := _selected_manual()
    if not manual.is_empty():
        manual_focused.emit(manual.duplicate(true))
        detail_requested.emit(manual.duplicate(true), false)
    return true

func get_selected_manual_id() -> String:
    return selected_manual_id

func set_interaction_enabled(enabled: bool) -> void:
    interaction_enabled = enabled
    for button in manual_buttons:
        button.disabled = not interaction_enabled
    for button in technique_buttons:
        button.disabled = not interaction_enabled or bool(button.get_meta("locked", false))
    set_meta("interaction_enabled", interaction_enabled)

func activate_technique(technique_id: String) -> bool:
    if not interaction_enabled:
        return false
    var technique := _find_selected_technique(technique_id)
    if technique.is_empty() or bool(technique.get("locked", false)):
        return false
    detail_requested.emit(technique.duplicate(true), true)
    technique_selected.emit(technique.duplicate(true))
    return true

func get_panel_snapshot() -> Dictionary:
    var manual_ids: Array[String] = []
    for manual in manuals:
        manual_ids.append(str(manual.get("manual_id", "")))
    var unlocked_count := 0
    var locked_count := 0
    var technique_ids: Array[String] = []
    for technique in _ordered_selected_techniques():
        technique_ids.append(str(technique.get("id", "")))
        if bool(technique.get("locked", false)):
            locked_count += 1
        else:
            unlocked_count += 1
    return {
        "manual_count": manuals.size(),
        "manual_ids": manual_ids,
        "selected_manual_id": selected_manual_id,
        "technique_ids": technique_ids,
        "unlocked_technique_count": unlocked_count,
        "locked_technique_count": locked_count,
        "interaction_enabled": interaction_enabled,
        "layout": "manual_row_then_card_grid",
        "presentation_surface": str(get_meta("presentation_surface", "")),
        "card_surface": "shared_action_card_grid",
        "illustration_policy": "forbidden",
        "technique_columns": TECHNIQUE_COLUMNS
    }

func _rebuild_manuals() -> void:
    if not is_node_ready():
        return
    for child in manual_row.get_children():
        child.queue_free()
    manual_buttons.clear()
    for manual in manuals:
        var button := Button.new()
        button.custom_minimum_size = Vector2(148.0, 62.0)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.focus_mode = Control.FOCUS_ALL
        button.toggle_mode = true
        button.text = _manual_button_text(manual)
        button.tooltip_text = _manual_tooltip(manual)
        button.accessibility_name = _manual_accessibility_name(manual)
        _apply_manual_paper_style(button, false)
        button.set_meta("manual_id", str(manual.get("manual_id", "")))
        button.pressed.connect(_on_manual_pressed.bind(str(manual.get("manual_id", ""))))
        button.mouse_entered.connect(_on_manual_focused.bind(manual))
        button.focus_entered.connect(_on_manual_focused.bind(manual))
        button.mouse_exited.connect(_on_detail_unfocused)
        button.focus_exited.connect(_on_detail_unfocused)
        manual_row.add_child(button)
        manual_buttons.append(button)
    _refresh_manual_selection()
    set_interaction_enabled(interaction_enabled)

func _rebuild_techniques() -> void:
    if not is_node_ready():
        return
    for child in technique_list.get_children():
        child.queue_free()
    technique_buttons.clear()
    technique_list.columns = TECHNIQUE_COLUMNS
    var manual := _selected_manual()
    selected_manual_title.text = "선택 무공서 없음" if manual.is_empty() else "%s · %d성" % [
        str(manual.get("name", "")),
        int(manual.get("mastery", 0))
    ]
    for technique in _ordered_selected_techniques():
        var locked := bool(technique.get("locked", false))
        var button := ACTION_CHOICE_CARD_SCRIPT.new() as ActionChoiceCard
        button.configure_action(technique, "forbidden", _locked_technique_text(technique) if locked else "사용 가능")
        button.disabled = locked or not interaction_enabled
        button.set_meta("technique_id", str(technique.get("id", "")))
        button.set_meta("locked", locked)
        button.pressed.connect(_on_technique_pressed.bind(str(technique.get("id", ""))))
        button.mouse_entered.connect(_on_technique_focused.bind(technique))
        button.focus_entered.connect(_on_technique_focused.bind(technique))
        button.mouse_exited.connect(_on_detail_unfocused)
        button.focus_exited.connect(_on_detail_unfocused)
        technique_list.add_child(button)
        technique_buttons.append(button)
    set_meta("selected_manual_id", selected_manual_id)
    set_meta("technique_count", technique_buttons.size())
    set_meta("card_surface", "shared_action_card_grid")
    set_meta("illustration_policy", "forbidden")

func _refresh_manual_selection() -> void:
    for button in manual_buttons:
        var selected := str(button.get_meta("manual_id", "")) == selected_manual_id
        button.button_pressed = selected
        button.text = ("● " if selected else "○ ") + _manual_button_text(_find_manual(str(button.get_meta("manual_id", ""))))
        _apply_manual_paper_style(button, selected)

func _apply_manual_paper_style(button: Button, selected: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = PAPER_SURFACE
    normal.border_color = RESTRAINED_GOLD if selected else CHARCOAL_INK
    normal.set_border_width_all(3 if selected else 2)
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
    _apply_button_theme(button, normal, hover, pressed, disabled)

func _apply_technique_paper_style(button: Button, locked: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = PAPER_SURFACE if not locked else Color("777064")
    normal.border_color = Color("3f668d") if not locked else Color("5d5448")
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(3)
    normal.content_margin_left = 10.0
    normal.content_margin_right = 10.0
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
    _apply_button_theme(button, normal, hover, pressed, disabled)

func _apply_button_theme(button: Button, normal: StyleBoxFlat, hover: StyleBoxFlat, pressed: StyleBoxFlat, disabled: StyleBoxFlat) -> void:
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

func _on_manual_pressed(manual_id: String) -> void:
    select_manual(manual_id)

func _on_manual_focused(manual: Dictionary) -> void:
    manual_focused.emit(manual.duplicate(true))
    detail_requested.emit(manual.duplicate(true), false)

func _on_technique_pressed(technique_id: String) -> void:
    activate_technique(technique_id)

func _on_technique_focused(technique: Dictionary) -> void:
    detail_requested.emit(technique.duplicate(true), false)

func _on_detail_unfocused() -> void:
    detail_cleared.emit()

func _has_manual(manual_id: String) -> bool:
    return not _find_manual(manual_id).is_empty()

func _find_manual(manual_id: String) -> Dictionary:
    for manual in manuals:
        if str(manual.get("manual_id", "")) == manual_id:
            return manual
    return {}

func _selected_manual() -> Dictionary:
    return _find_manual(selected_manual_id)

func _find_selected_technique(technique_id: String) -> Dictionary:
    var manual := _selected_manual()
    for value in manual.get("techniques", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var technique: Dictionary = value
        if str(technique.get("id", "")) == technique_id:
            return technique
    return {}

func _ordered_selected_techniques() -> Array[Dictionary]:
    var unlocked: Array[Dictionary] = []
    var locked: Array[Dictionary] = []
    var manual := _selected_manual()
    for value in manual.get("techniques", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var technique: Dictionary = value
        if bool(technique.get("locked", false)):
            locked.append(technique)
        else:
            unlocked.append(technique)
    unlocked.append_array(locked)
    return unlocked

func _manual_button_text(manual: Dictionary) -> String:
    var techniques: Array = manual.get("techniques", [])
    var unlocked_count := 0
    for value in techniques:
        if typeof(value) == TYPE_DICTIONARY and not bool((value as Dictionary).get("locked", false)):
            unlocked_count += 1
    var tags := _join_tags(manual.get("role_tags", []), 2)
    var ultimate_text := "절초 해금" if bool(manual.get("ultimate_unlocked", false)) else "절초 미해금"
    return "%s · %d성\n%s · 기술 %d/%d · %s" % [
        str(manual.get("name", "")),
        int(manual.get("mastery", 0)),
        tags,
        unlocked_count,
        techniques.size(),
        ultimate_text
    ]

func _manual_tooltip(manual: Dictionary) -> String:
    return "%s · 현재 %d성 · %s" % [
        str(manual.get("name", "")),
        int(manual.get("mastery", 0)),
        _join_tags(manual.get("role_tags", []), 2)
    ]

func _manual_accessibility_name(manual: Dictionary) -> String:
    return "%s 무공서, 현재 %d성, 역할 %s" % [
        str(manual.get("name", "")),
        int(manual.get("mastery", 0)),
        _join_tags(manual.get("role_tags", []), 2)
    ]

func _unlocked_technique_text(technique: Dictionary) -> String:
    var resource_text := "기력 %d · 내력 %d" % [
        int(technique.get("stamina_cost", 0)),
        int(technique.get("internal_cost", 0))
    ]
    return "%s · %d수 · %s · 거리 %s · %s" % [
        str(technique.get("name", "")),
        int(technique.get("action_slots", 1)),
        resource_text,
        str(technique.get("range_text", "-")),
        _join_tags(technique.get("tags", []), 2)
    ]

func _locked_technique_text(technique: Dictionary) -> String:
    return "%s · %d성 해금 · 현재 %d성" % [
        str(technique.get("name", "")),
        int(technique.get("unlock_mastery", 0)),
        int(technique.get("current_mastery", 0))
    ]

func _technique_tooltip(technique: Dictionary) -> String:
    if bool(technique.get("locked", false)):
        return _locked_technique_text(technique)
    return "%s · %d수 · 전조 %d · 실행 %d" % [
        str(technique.get("name", "")),
        int(technique.get("action_slots", 1)),
        int(technique.get("telegraph_count", 0)),
        int(technique.get("execution_count", 1))
    ]

func _technique_accessibility_name(technique: Dictionary) -> String:
    if bool(technique.get("locked", false)):
        return "%s, 잠김, %d성 해금, 현재 %d성" % [
            str(technique.get("name", "")),
            int(technique.get("unlock_mastery", 0)),
            int(technique.get("current_mastery", 0))
        ]
    return "%s, %s 무공 기술, %d수, 기력 %d, 내력 %d, 거리 %s" % [
        str(technique.get("name", "")),
        str(technique.get("source_label", "")),
        int(technique.get("action_slots", 1)),
        int(technique.get("stamina_cost", 0)),
        int(technique.get("internal_cost", 0)),
        str(technique.get("range_text", "-"))
    ]

func _join_tags(values, limit: int) -> String:
    var parts := PackedStringArray()
    if typeof(values) == TYPE_ARRAY or typeof(values) == TYPE_PACKED_STRING_ARRAY:
        for value in values:
            if parts.size() >= limit:
                break
            parts.append(str(value))
    return " · ".join(parts) if not parts.is_empty() else "역할 없음"
