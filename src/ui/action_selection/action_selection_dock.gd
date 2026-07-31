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

func _ready() -> void:
    basic_tab.pressed.connect(func(): set_active_source("basic"))
    martial_tab.pressed.connect(func(): set_active_source("martial"))
    ultimate_tab.pressed.connect(func(): set_active_source("ultimate"))
    _build_source_panels()
    _apply_state()

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
    switching_enabled = interaction_state not in LOCKED_STATES
    _apply_state()

func set_runtime_context(context: Dictionary) -> void:
    runtime_context = context.duplicate(true)
    set_meta("runtime_context", runtime_context)

func request_action(definition: Dictionary) -> void:
    if definition.is_empty() or not switching_enabled:
        return
    action_selected.emit(definition.duplicate(true))

func request_detail(definition: Dictionary, pinned: bool = false) -> void:
    if definition.is_empty():
        detail_cleared.emit()
        return
    detail_requested.emit(definition.duplicate(true), pinned)

func clear_detail() -> void:
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
        "selected_manual_id": martial_panel.get_selected_manual_id() if is_instance_valid(martial_panel) else "",
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
    set_meta("visible_source", active_source)

func _set_tab_state(button: Button, source: String, label: String) -> void:
    var selected := active_source == source
    button.button_pressed = selected
    button.text = ("● " if selected else "○ ") + label
    button.accessibility_name = "%s 탭%s" % [label, " 선택됨" if selected else ""]
