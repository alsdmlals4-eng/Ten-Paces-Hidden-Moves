class_name BasicActionPanel
extends Control

signal action_selected(definition: Dictionary)
signal detail_requested(definition: Dictionary, pinned: bool)
signal detail_cleared()

const ADAPTER_SCRIPT := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
const ACTION_CHOICE_CARD_SCRIPT := preload("res://src/ui/action_selection/action_choice_card.gd")
const COLUMNS := 5

@onready var title_label: Label = $PanelColumn/Title
@onready var action_grid: GridContainer = %ActionGrid

var actions: Array[Dictionary] = []
var buttons: Array[Button] = []
var interaction_enabled := true

func _ready() -> void:
	action_grid.columns = COLUMNS
	title_label.add_theme_color_override("font_color", Color("ead8b4"))
	title_label.add_theme_font_size_override("font_size", 12)
	actions = ADAPTER_SCRIPT.new().build_basic_actions()
	_rebuild()
	set_meta("presentation_surface", "paper_ink_r1")

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
		"interaction_enabled": interaction_enabled,
		"card_surface": "shared_action_card_grid",
		"illustration_policy": "basic_atlas_only"
	}

func _rebuild() -> void:
	for child in action_grid.get_children():
		child.queue_free()
	buttons.clear()

	for definition in actions:
		var button := ACTION_CHOICE_CARD_SCRIPT.new() as ActionChoiceCard
		button.configure_action(definition, "basic_atlas_only")
		button.mouse_entered.connect(_on_action_hovered.bind(definition))
		button.mouse_exited.connect(_on_action_unhovered)
		button.focus_entered.connect(_on_action_hovered.bind(definition))
		button.focus_exited.connect(_on_action_unhovered)
		button.pressed.connect(_on_action_pressed.bind(definition))
		action_grid.add_child(button)
		buttons.append(button)

	set_interaction_enabled(interaction_enabled)
	set_meta("layout", "grid_5_by_2_compact")
	set_meta("action_count", actions.size())
	set_meta("card_art_enabled", true)
	set_meta("card_surface", "shared_action_card_grid")
	set_meta("illustration_policy", "basic_atlas_only")
	set_meta("presentation_surface", "paper_ink_r1")

func _on_action_hovered(definition: Dictionary) -> void:
	detail_requested.emit(definition.duplicate(true), false)

func _on_action_unhovered() -> void:
	detail_cleared.emit()

func _on_action_pressed(definition: Dictionary) -> void:
	if not interaction_enabled:
		return
	detail_requested.emit(definition.duplicate(true), true)
	action_selected.emit(definition.duplicate(true))

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
