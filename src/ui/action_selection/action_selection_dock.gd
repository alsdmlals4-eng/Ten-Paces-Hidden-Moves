class_name ActionSelectionDock
extends Control

signal action_selected(definition: Dictionary)
signal detail_requested(definition: Dictionary, pinned: bool)
signal detail_cleared()
signal source_changed(source: String)

const SOURCES := ["basic", "martial", "ultimate"]
const LOCKED_STATES := ["targeting", "committed", "resolving", "presenting_result", "review"]
const BASIC_PANEL_SCENE := preload("res://scenes/ui/action_selection/basic_action_panel.tscn")
const MARTIAL_PANEL_SCENE := preload("res://scenes/ui/action_selection/martial_action_panel.tscn")
const ULTIMATE_PANEL_SCENE := preload("res://scenes/ui/action_selection/ultimate_action_panel.tscn")
const DETAIL_PANEL_SCENE := preload("res://scenes/ui/action_selection/action_detail_panel.tscn")

@onready var basic_tab: Button = %BasicTab
@onready var martial_tab: Button = %MartialTab
@onready var ultimate_tab: Button = %UltimateTab
@onready var content_host: Control = %ContentHost
@onready var detail_host: Control = %DetailHost

var active_source := "basic"
var interaction_state := "planning"
var runtime_context: Dictionary = {}
var switching_enabled := true
var basic_panel: BasicActionPanel
var martial_panel: MartialActionPanel
var ultimate_panel: UltimateActionPanel
var action_detail_panel: ActionDetailPanel

func _ready() -> void:
    basic_tab.pressed.connect(func(): set_active_source("basic"))
    martial_tab.pressed.connect(func(): set_active_source("martial"))
    ultimate_tab.pressed.connect(func(): set_active_source("ultimate"))
    _build_source_panels()
    _build_detail_panel()
    _apply_state()
    set_meta("manual_is_not_directly_placeable", true)
    set_meta("virtual_combo_enabled", false)

func set_active_source(source: String) -> void:
    if not switching_enabled or source not in SOURCES or source == active_source:
        return
    active_source = source
    _refresh_tabs()
    _refresh_source_content()
    source_changed.emit(active_source)

func set_interaction_state(state: String) -> void:
    interaction_state = state
    if interaction_state == "new_combat":
        active_source = "basic"
        interaction_state = "planning"
        clear_detail()
    switching_enabled = interaction_state not in LOCKED_STATES
    _apply_state()

func set_runtime_context(context: Dictionary) -> void:
    runtime_context = context.duplicate(true)
    if is_instance_valid(ultimate_panel):
        var current := 0
        var maximum := 5
        var momentum_value = runtime_context.get("momentum", runtime_context.get("ultimate_momentum", 0))
        if typeof(momentum_value) == TYPE_ARRAY and (momentum_value as Array).size() >= 2:
            current = int((momentum_value as Array)[0])
            maximum = int((momentum_value as Array)[1])
        else:
            current = int(momentum_value)
            maximum = int(runtime_context.get("momentum_maximum", 5))
        ultimate_panel.set_momentum(current, maximum)
        var reservation_values: Array[Dictionary] = []
        for value in runtime_context.get("ultimate_reservations", []):
            if typeof(value) == TYPE_DICTIONARY:
                reservation_values.append((value as Dictionary).duplicate(true))
        ultimate_panel.set_reservations(reservation_values)
    set_meta("runtime_context", runtime_context)

func request_action(definition: Dictionary) -> void:
    if definition.is_empty() or not switching_enabled:
        return
    action_selected.emit(definition.duplicate(true))

func request_detail(value: Dictionary, pinned: bool = false) -> void:
    if value.is_empty():
        clear_detail()
        return
    if is_instance_valid(action_detail_panel):
        if value.has("manual_id") and not value.has("id"):
            action_detail_panel.show_manual(value, pinned)
        else:
            action_detail_panel.show_action(value, pinned)
    detail_requested.emit(value.duplicate(true), pinned)

func clear_detail() -> void:
    if is_instance_valid(action_detail_panel):
        action_detail_panel.clear_detail()
    detail_cleared.emit()

func get_dock_snapshot() -> Dictionary:
    return {
        "sources": SOURCES.duplicate(),
        "active_source": active_source,
        "interaction_state": interaction_state,
        "switching_enabled": switching_enabled,
        "content_host_ready": is_instance_valid(content_host),
        "detail_host_ready": is_instance_valid(detail_host),
        "basic_panel_ready": is_instance_valid(basic_panel),
        "martial_panel_ready": is_instance_valid(martial_panel),
        "ultimate_panel_ready": is_instance_valid(ultimate_panel),
        "action_detail_panel_ready": is_instance_valid(action_detail_panel),
        "selected_manual_id": martial_panel.get_selected_manual_id() if is_instance_valid(martial_panel) else "",
        "ultimate_snapshot": ultimate_panel.get_panel_snapshot() if is_instance_valid(ultimate_panel) else {},
        "detail_snapshot": action_detail_panel.get_detail_snapshot() if is_instance_valid(action_detail_panel) else {},
        "runtime_context": runtime_context.duplicate(true)
    }

func _build_source_panels() -> void:
    basic_panel = BASIC_PANEL_SCENE.instantiate() as BasicActionPanel
    basic_panel.name = "BasicActionPanel"
    _fill_host(basic_panel)
    content_host.add_child(basic_panel)
    basic_panel.action_selected.connect(request_action)
    basic_panel.detail_requested.connect(request_detail)
    basic_panel.detail_cleared.connect(clear_detail)

    martial_panel = MARTIAL_PANEL_SCENE.instantiate() as MartialActionPanel
    martial_panel.name = "MartialActionPanel"
    _fill_host(martial_panel)
    content_host.add_child(martial_panel)
    martial_panel.technique_selected.connect(request_action)
    martial_panel.detail_requested.connect(request_detail)
    martial_panel.detail_cleared.connect(clear_detail)

    ultimate_panel = ULTIMATE_PANEL_SCENE.instantiate() as UltimateActionPanel
    ultimate_panel.name = "UltimateActionPanel"
    _fill_host(ultimate_panel)
    content_host.add_child(ultimate_panel)
    ultimate_panel.ultimate_selected.connect(request_action)
    ultimate_panel.detail_requested.connect(request_detail)
    ultimate_panel.detail_cleared.connect(clear_detail)

func _build_detail_panel() -> void:
    action_detail_panel = DETAIL_PANEL_SCENE.instantiate() as ActionDetailPanel
    action_detail_panel.name = "ActionDetailPanel"
    _fill_host(action_detail_panel)
    detail_host.add_child(action_detail_panel)
    action_detail_panel.custom_minimum_size = Vector2(220.0, 0.0)

func _fill_host(panel: Control) -> void:
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    panel.grow_vertical = Control.GROW_DIRECTION_BOTH

func _apply_state() -> void:
    if not is_node_ready():
        return
    basic_tab.disabled = not switching_enabled
    martial_tab.disabled = not switching_enabled
    ultimate_tab.disabled = not switching_enabled
    if is_instance_valid(basic_panel):
        basic_panel.set_interaction_enabled(switching_enabled)
    if is_instance_valid(martial_panel):
        martial_panel.set_interaction_enabled(switching_enabled)
    if is_instance_valid(ultimate_panel):
        ultimate_panel.set_interaction_enabled(switching_enabled)
    _refresh_tabs()
    _refresh_source_content()
    set_meta("active_source", active_source)
    set_meta("interaction_state", interaction_state)
    set_meta("switching_enabled", switching_enabled)

func _refresh_tabs() -> void:
    if not is_node_ready():
        return
    _set_tab_state(basic_tab, "basic", "기초")
    _set_tab_state(martial_tab, "martial", "무공")
    _set_tab_state(ultimate_tab, "ultimate", "절초")
    set_meta("active_source", active_source)

func _refresh_source_content() -> void:
    if is_instance_valid(basic_panel):
        basic_panel.visible = active_source == "basic"
    if is_instance_valid(martial_panel):
        martial_panel.visible = active_source == "martial"
    if is_instance_valid(ultimate_panel):
        ultimate_panel.visible = active_source == "ultimate"
    set_meta("visible_source", active_source)

func _set_tab_state(button: Button, source: String, label: String) -> void:
    var selected := active_source == source
    button.button_pressed = selected
    button.text = ("● " if selected else "○ ") + label
    button.accessibility_name = "%s 탭%s" % [label, " 선택됨" if selected else ""]
