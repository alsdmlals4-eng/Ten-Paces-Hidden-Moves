class_name ActionSelectionDock
extends Control

signal action_selected(definition: Dictionary)
signal detail_requested(definition: Dictionary, pinned: bool)
signal detail_cleared()
signal source_changed(source: String)
signal intent_selected(intent: Dictionary)

const SOURCES := ["basic", "martial", "ultimate"]
const LOCKED_STATES := ["targeting", "ultimate_reserved", "plan_locked", "committed", "resolving", "presenting_result", "review"]
const BASIC_PANEL_SCENE := preload("res://scenes/ui/action_selection/basic_action_panel.tscn")
const MARTIAL_PANEL_SCENE := preload("res://scenes/ui/action_selection/martial_action_panel.tscn")
const ULTIMATE_PANEL_SCENE := preload("res://scenes/ui/action_selection/ultimate_action_panel.tscn")
const DETAIL_PANEL_SCENE := preload("res://scenes/ui/action_selection/action_detail_panel.tscn")
const ACTION_INTENT_PANEL_SCRIPT := preload("res://src/ui/action_selection/action_intent_panel.gd")
const ADAPTER_SCRIPT := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
const PAPER_SURFACE := Color("d9ccb1")
const PAPER_HOVER := Color("eee2c9")
const CHARCOAL_INK := Color("211c17")
const CHARCOAL_SOFT := Color("382f27")
const RESTRAINED_GOLD := Color("b99254")

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
var action_intent_panel: ActionIntentPanel
var _backdrop: Panel

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS
    _build_backdrop()
    basic_tab.pressed.connect(func(): set_active_source("basic"))
    martial_tab.pressed.connect(func(): set_active_source("martial"))
    ultimate_tab.pressed.connect(func(): set_active_source("ultimate"))
    _build_source_panels()
    _build_detail_panel()
    _apply_state()
    resized.connect(queue_redraw)
    set_meta("manual_is_not_directly_placeable", true)
    set_meta("virtual_combo_enabled", false)
    set_meta("presentation_surface", "paper_ink_r1")

func _build_backdrop() -> void:
    if is_instance_valid(_backdrop):
        return
    _backdrop = Panel.new()
    _backdrop.name = "DockBackground"
    _backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(CHARCOAL_INK, 0.97)
    style.border_color = Color(RESTRAINED_GOLD, 0.78)
    style.set_border_width_all(2)
    style.set_corner_radius_all(4)
    _backdrop.add_theme_stylebox_override("panel", style)
    add_child(_backdrop)
    move_child(_backdrop, 0)

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
    var loadout: Array = []
    var mastery_by_manual: Dictionary = {}
    if runtime_context.has("martial_loadout"):
        for value in runtime_context.get("martial_loadout", []):
            loadout.append(str(value))
    if typeof(runtime_context.get("martial_mastery_by_manual", {})) == TYPE_DICTIONARY:
        mastery_by_manual = (runtime_context.get("martial_mastery_by_manual", {}) as Dictionary).duplicate(true)
    if runtime_context.has("martial_loadout") or runtime_context.has("martial_mastery_by_manual"):
        if is_instance_valid(martial_panel):
            martial_panel.set_manuals(ADAPTER_SCRIPT.new().build_owned_manuals(loadout, mastery_by_manual))
        if is_instance_valid(ultimate_panel):
            ultimate_panel.set_martial_context(loadout, mastery_by_manual)
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

func set_targeting_intents(title: String, values: Array[Dictionary]) -> void:
    if not is_instance_valid(action_intent_panel):
        return
    action_intent_panel.set_intents(title, values)
    action_intent_panel.set_interaction_enabled(interaction_state == "targeting")
    _refresh_source_content()
    set_meta("intent_card_count", values.size())

func clear_targeting_intents() -> void:
    if not is_instance_valid(action_intent_panel):
        return
    action_intent_panel.clear_intents()
    _refresh_source_content()
    set_meta("intent_card_count", 0)

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
        "intent_panel_ready": is_instance_valid(action_intent_panel),
        "action_detail_panel_ready": is_instance_valid(action_detail_panel),
        "presentation_surface": str(get_meta("presentation_surface", "")),
        "selected_manual_id": martial_panel.get_selected_manual_id() if is_instance_valid(martial_panel) else "",
        "martial_snapshot": martial_panel.get_panel_snapshot() if is_instance_valid(martial_panel) else {},
        "ultimate_snapshot": ultimate_panel.get_panel_snapshot() if is_instance_valid(ultimate_panel) else {},
        "intent_snapshot": action_intent_panel.get_panel_snapshot() if is_instance_valid(action_intent_panel) else {},
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

    action_intent_panel = ACTION_INTENT_PANEL_SCRIPT.new() as ActionIntentPanel
    action_intent_panel.name = "ActionIntentPanel"
    _fill_host(action_intent_panel)
    content_host.add_child(action_intent_panel)
    action_intent_panel.intent_selected.connect(_on_intent_selected)

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
    if is_instance_valid(action_intent_panel):
        action_intent_panel.set_interaction_enabled(interaction_state == "targeting")
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
    var showing_intents := is_instance_valid(action_intent_panel) and action_intent_panel.visible
    if is_instance_valid(basic_panel):
        basic_panel.visible = not showing_intents and active_source == "basic"
    if is_instance_valid(martial_panel):
        martial_panel.visible = not showing_intents and active_source == "martial"
    if is_instance_valid(ultimate_panel):
        ultimate_panel.visible = not showing_intents and active_source == "ultimate"
    set_meta("visible_source", "intent" if showing_intents else active_source)

func _on_intent_selected(intent: Dictionary) -> void:
    intent_selected.emit(intent.duplicate(true))

func _set_tab_state(button: Button, source: String, label: String) -> void:
    var selected := active_source == source
    button.button_pressed = selected
    button.text = ("● " if selected else "○ ") + label
    button.accessibility_name = "%s 탭%s" % [label, " 선택됨" if selected else ""]
    _apply_tab_presentation(button, selected)

func _apply_tab_presentation(button: Button, selected: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = PAPER_SURFACE if selected else CHARCOAL_SOFT
    normal.border_color = CHARCOAL_INK if selected else Color(RESTRAINED_GOLD, 0.68)
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(4)
    normal.content_margin_left = 12.0
    normal.content_margin_right = 12.0
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = PAPER_HOVER if selected else Color("4a3c2f")
    hover.border_color = RESTRAINED_GOLD
    hover.set_border_width_all(3)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("c9b78f") if selected else Color("2b241d")
    pressed.border_color = RESTRAINED_GOLD
    var disabled := normal.duplicate() as StyleBoxFlat
    disabled.bg_color = Color("4a4238")
    disabled.border_color = Color("82745f")
    var focus := StyleBoxFlat.new()
    focus.bg_color = Color(1.0, 1.0, 1.0, 0.07)
    focus.border_color = Color.WHITE
    focus.set_border_width_all(2)
    focus.set_corner_radius_all(4)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("disabled", disabled)
    button.add_theme_stylebox_override("focus", focus)
    button.add_theme_color_override("font_color", CHARCOAL_INK if selected else Color("e7d9bc"))
    button.add_theme_color_override("font_hover_color", CHARCOAL_INK if selected else Color.WHITE)
    button.add_theme_color_override("font_pressed_color", CHARCOAL_INK if selected else Color("f4e7c7"))
    button.add_theme_color_override("font_disabled_color", Color("a99d89"))
    button.set_meta("keyboard_focus_ring", true)

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        if is_instance_valid(_backdrop):
            _backdrop.queue_redraw()
