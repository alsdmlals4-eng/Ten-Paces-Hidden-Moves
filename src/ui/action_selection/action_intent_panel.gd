class_name ActionIntentPanel
extends Control

signal intent_selected(intent: Dictionary)

const ACTION_CHOICE_CARD_SCRIPT := preload("res://src/ui/action_selection/action_choice_card.gd")

var title_label: Label
var intent_grid: GridContainer
var intents: Array[Dictionary] = []
var intent_buttons: Array[ActionChoiceCard] = []
var interaction_enabled := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_content()
	visible = false

func set_intents(title: String, values: Array[Dictionary]) -> void:
	intents.clear()
	for value in values:
		intents.append(value.duplicate(true))
	if is_node_ready():
		title_label.text = title
		_rebuild_cards()

func clear_intents() -> void:
	intents.clear()
	if is_node_ready():
		_rebuild_cards()
	visible = false

func set_interaction_enabled(enabled: bool) -> void:
	interaction_enabled = enabled
	for button in intent_buttons:
		button.disabled = not enabled

func get_panel_snapshot() -> Dictionary:
	var ids: Array[String] = []
	for intent in intents:
		ids.append(str(intent.get("id", "")))
	return {
		"visible": visible,
		"intent_count": intents.size(),
		"intent_ids": ids,
		"interaction_enabled": interaction_enabled,
		"card_surface": str(get_meta("card_surface", "")),
		"illustration_policy": str(get_meta("illustration_policy", ""))
	}

func _build_content() -> void:
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override("separation", 6)
	add_child(column)
	title_label = Label.new()
	title_label.name = "IntentTitle"
	title_label.text = "행동 의도 선택"
	title_label.add_theme_color_override("font_color", Color("ead8b4"))
	title_label.add_theme_font_size_override("font_size", 15)
	column.add_child(title_label)
	intent_grid = GridContainer.new()
	intent_grid.name = "IntentCardGrid"
	intent_grid.columns = 2
	intent_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	intent_grid.add_theme_constant_override("h_separation", 6)
	intent_grid.add_theme_constant_override("v_separation", 6)
	column.add_child(intent_grid)
	set_meta("card_surface", "shared_action_card_grid")
	set_meta("illustration_policy", "forbidden")

func _rebuild_cards() -> void:
	for child in intent_grid.get_children():
		child.queue_free()
	intent_buttons.clear()
	for intent in intents:
		var button := ACTION_CHOICE_CARD_SCRIPT.new() as ActionChoiceCard
		button.configure_action(intent, "forbidden", str(intent.get("intent_summary", "")))
		button.disabled = not interaction_enabled
		button.pressed.connect(_on_intent_pressed.bind(intent.duplicate(true)))
		intent_grid.add_child(button)
		intent_buttons.append(button)
	visible = not intents.is_empty()

func _on_intent_pressed(intent: Dictionary) -> void:
	if interaction_enabled:
		intent_selected.emit(intent.duplicate(true))
