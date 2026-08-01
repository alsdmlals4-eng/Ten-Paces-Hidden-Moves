class_name BasicActionPanel
extends Control

signal action_selected(definition: Dictionary)
signal detail_requested(definition: Dictionary, pinned: bool)
signal detail_cleared()

const ADAPTER_SCRIPT := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
const COLUMNS := 4

@onready var action_grid: GridContainer = %ActionGrid

var actions: Array[Dictionary] = []
var buttons: Array[Button] = []
var interaction_enabled := true

func _ready() -> void:
    action_grid.columns = COLUMNS
    actions = ADAPTER_SCRIPT.new().build_basic_actions()
    _rebuild()

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
        button.custom_minimum_size = Vector2(136.0, 58.0)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.focus_mode = Control.FOCUS_ALL
        button.text = _button_text(definition)
        button.tooltip_text = _tooltip_text(definition)
        button.accessibility_name = _accessibility_name(definition)
        button.mouse_entered.connect(_on_action_hovered.bind(definition))
        button.mouse_exited.connect(_on_action_unhovered)
        button.focus_entered.connect(_on_action_hovered.bind(definition))
        button.focus_exited.connect(_on_action_unhovered)
        button.pressed.connect(_on_action_pressed.bind(definition))
        action_grid.add_child(button)
        buttons.append(button)

    set_interaction_enabled(interaction_enabled)
    set_meta("layout", "grid_4_by_2")
    set_meta("action_count", actions.size())

func _on_action_hovered(definition: Dictionary) -> void:
    detail_requested.emit(definition.duplicate(true), false)

func _on_action_unhovered() -> void:
    detail_cleared.emit()

func _on_action_pressed(definition: Dictionary) -> void:
    if not interaction_enabled:
        return
    detail_requested.emit(definition.duplicate(true), true)
    action_selected.emit(definition.duplicate(true))

func _button_text(definition: Dictionary) -> String:
    var resource_parts := PackedStringArray()
    var stamina := int(definition.get("stamina_cost", 0))
    var internal := int(definition.get("internal_cost", 0))
    if stamina > 0:
        resource_parts.append("기력 %d" % stamina)
    if internal > 0:
        resource_parts.append("내력 %d" % internal)
    if resource_parts.is_empty():
        resource_parts.append("비용 없음")
    return "%s  ·  %d수\n%s  ·  거리 %s" % [
        str(definition.get("name", "")),
        int(definition.get("action_slots", 1)),
        " / ".join(resource_parts),
        str(definition.get("range_text", "-"))
    ]

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
