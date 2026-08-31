extends SceneTree

const DOCK_SCENE := preload("res://scenes/ui/action_selection/action_selection_dock.tscn")
const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")
const ADAPTER_SCRIPT := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
const ACTION_CHOICE_CARD_SCRIPT := preload("res://src/ui/action_selection/action_choice_card.gd")
const HUA_MANUAL := "mount_hua_plum_blossom_sword"

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var dock := DOCK_SCENE.instantiate() as ActionSelectionDock
	root.add_child(dock)
	await process_frame
	var adapter := ADAPTER_SCRIPT.new() as ActionViewModelAdapter
	dock.martial_panel.set_manuals(adapter.build_owned_manuals([HUA_MANUAL], {HUA_MANUAL: 3}))
	dock.ultimate_panel.set_martial_context([HUA_MANUAL], {HUA_MANUAL: 3})
	await process_frame

	_verify_source_card_surfaces(dock)
	_verify_martial_and_ultimate_are_illustrated(dock)
	_verify_common_card_information_hierarchy()

	dock.queue_free()
	await process_frame
	await _verify_semantic_intent_runtime_surface()
	_finish()

func _verify_source_card_surfaces(dock: ActionSelectionDock) -> void:
	var basic: Dictionary = dock.basic_panel.get_panel_snapshot()
	var martial: Dictionary = dock.martial_panel.get_panel_snapshot()
	var ultimate: Dictionary = dock.ultimate_panel.get_panel_snapshot()
	_check(basic.get("card_surface", "") == "shared_action_card_grid", "Basic actions must publish the shared card grid surface.")
	_check(martial.get("card_surface", "") == "shared_action_card_grid", "Martial techniques must publish the shared card grid surface.")
	_check(ultimate.get("card_surface", "") == "shared_action_card_grid", "Ultimate techniques must publish the shared card grid surface.")
	_check(basic.get("illustration_policy", "") == "basic_atlas_only", "Basic action cards must retain their approved atlas.")
	_check(martial.get("illustration_policy", "") == "semantic_atlas", "Martial cards must use the approved semantic atlas.")
	_check(ultimate.get("illustration_policy", "") == "semantic_atlas", "Ultimate cards must use the approved semantic atlas.")

func _verify_martial_and_ultimate_are_illustrated(dock: ActionSelectionDock) -> void:
	_check(
		not dock.martial_panel.find_children("*", "TextureRect", true, false).is_empty(),
		"Martial cards must instantiate semantic illustration nodes."
	)
	_check(
		not dock.ultimate_panel.find_children("*", "TextureRect", true, false).is_empty(),
		"Ultimate cards must instantiate semantic illustration nodes."
	)

func _verify_common_card_information_hierarchy() -> void:
	var adapter := ADAPTER_SCRIPT.new() as ActionViewModelAdapter
	var basic_move := _find_action(adapter.build_basic_actions(), "basic_move")
	var basic_meditate := _find_action(adapter.build_basic_actions(), "basic_meditate")
	var manuals := adapter.build_owned_manuals([HUA_MANUAL], {HUA_MANUAL: 3})
	var martial: Dictionary = {}
	if not manuals.is_empty():
		martial = _find_action((manuals[0] as Dictionary).get("techniques", []) as Array[Dictionary], "mount_hua_plum_blossom_sword_star3")
	var ultimate := _find_action(adapter.build_ultimate_actions(5), "ultimate_ten_paces_wave")
	_verify_card_text_hierarchy(basic_move, "basic_atlas_only", "기초 · 이동", "접근 또는 후퇴", "basic move")
	_verify_card_text_hierarchy(basic_meditate, "basic_atlas_only", "기초 · 회복", "기력과 내력을", "basic meditate")
	_verify_card_text_hierarchy(martial, "semantic_atlas", "[화산파] 매화검결 · 공격", "연속", "tagless martial attack")
	_verify_card_text_hierarchy(ultimate, "semantic_atlas", "기본 절초 · 공격", "기본 피해 8", "ultimate")

func _verify_card_text_hierarchy(definition: Dictionary, illustration_policy: String, expected_facts: String, expected_effect: String, label: String) -> void:
	_check(not definition.is_empty(), "%s definition must exist." % label)
	if definition.is_empty():
		return
	var card := ACTION_CHOICE_CARD_SCRIPT.new() as ActionChoiceCard
	card.configure_action(definition, illustration_policy)
	var facts := card.find_child("CardFacts", false, false) as Label
	var effect := card.find_child("CardEffectOrTag", false, false) as Label
	var illustration := card.find_child("CardIllustration", false, false) as TextureRect
	_check(is_instance_valid(facts) and facts.text.contains(expected_facts), "%s must expose source, Korean category, and cost/range facts." % label)
	_check(is_instance_valid(facts) and facts.text.contains("사거리"), "%s must always expose its range meaning in the shared card facts." % label)
	_check(is_instance_valid(facts) and facts.text.contains("기력") and facts.text.contains("내력"), "%s must always expose stamina and internal-cost facts, including zero cost." % label)
	_check(is_instance_valid(effect) and effect.text.contains(expected_effect), "%s must expose its effect text or tag on the common card." % label)
	_check(is_instance_valid(effect) and effect.text != "절초", "%s must expose an actionable effect summary rather than the generic ultimate tag." % label)
	_check(is_instance_valid(illustration) == (illustration_policy != "forbidden"), "%s illustration presence must match the card policy." % label)
	_check(card.custom_minimum_size.y >= 132.0, "%s card must reserve enough vertical space for illustration, facts, and effect text." % label)
	_check(is_instance_valid(facts) and not facts.clip_text and is_instance_valid(effect) and not effect.clip_text, "%s card facts and effect must not silently clip inside the common card." % label)
	_check(not card.accessibility_name.strip_edges().is_empty(), "%s must expose an accessibility name." % label)
	_check(not card.accessibility_description.strip_edges().is_empty(), "%s must expose an accessibility description." % label)
	card.queue_free()

func _verify_semantic_intent_runtime_surface() -> void:
	var board := BOARD_SCENE.instantiate() as CombatBoardPreview
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = Vector2(1440.0, 900.0)
	root.add_child(board)
	for _frame in range(4):
		await process_frame
	_check(board.action_selection_dock.visible, "The unified selection dock must be visible in combat.")
	for tile in board.tiles:
		_check(not tile.visible, "The logical tile layer must remain hidden during all selection states.")
	var move := _find_action(board.action_selection_dock.basic_panel.actions, "basic_move")
	_check(not move.is_empty(), "Basic move must be available through the shared card grid.")
	if not move.is_empty():
		board._on_product_action_selected(move)
		await process_frame
		_check(board._targeting_mode == "move_intent", "Movement must request semantic intent cards rather than board tiles.")
		_check(board.action_selection_dock.action_intent_panel.visible, "Movement must reveal the intent-card surface.")
		_check(board.action_selection_dock.action_intent_panel.intent_buttons.size() >= 2, "Movement must offer approach and retreat cards.")
		for tile in board.tiles:
			_check(not tile.visible, "Logical board tiles must remain hidden while choosing a movement intent.")
		if not board.action_selection_dock.action_intent_panel.intent_buttons.is_empty():
			board.action_selection_dock.action_intent_panel.intent_buttons[0].emit_signal("pressed")
			await process_frame
			var placement := board.action_timing_panel.get_placement(1)
			_check(bool(placement.get("target_ready", false)), "Choosing a movement intent must finalize the reserved action.")
			_check(str(placement.get("target_text", "")).begins_with("접근") or str(placement.get("target_text", "")).begins_with("후퇴"), "Movement summary must preserve the chosen semantic intent.")
			_check(board.action_timing_panel.are_current_bundle_targets_ready(), "Resolved intent cards must satisfy current-bundle readiness.")
	var heavy := _find_action(board.action_selection_dock.basic_panel.actions, "basic_heavy_attack")
	if not heavy.is_empty():
		board._on_product_action_selected(heavy)
		await process_frame
		_check(board._targeting_mode == "" and int(board.get_meta("targeting_anchor", 0)) == 0, "Attack must lock against the public opponent without a direction-selection surface.")
		_check(not board.action_selection_dock.action_intent_panel.visible, "Attack must not open an intent-card surface.")
		var heavy_placement := board.action_timing_panel.get_placement(2)
		_check(bool(heavy_placement.get("target_ready", false)), "Auto-targeted attacks must be immediately ready for current-bundle execution.")
	board.queue_free()
	await process_frame

func _find_action(actions: Array[Dictionary], action_id: String) -> Dictionary:
	for action in actions:
		if str(action.get("id", "")) == action_id:
			return action.duplicate(true)
	return {}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("verify_action_card_source_unification: PASS")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
		print("ACTION_CARD_SOURCE_UNIFICATION_FAILURE %s" % failure)
	print("verify_action_card_source_unification: FAIL count=%d" % failures.size())
	quit(1)
