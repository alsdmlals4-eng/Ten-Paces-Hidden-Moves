extends SceneTree

const ENGINE_SCRIPT := preload("res://src/combat/combat_resolution_engine.gd")
const ADAPTER_SCRIPT := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
const CARD_SCRIPT := preload("res://src/ui/action_selection/action_choice_card.gd")
const MARTIAL_REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")
const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_verify_engine_preview_is_actor_backed_and_pure()
	_verify_martial_attack_previews_never_invent_zero()
	_verify_shared_preview_engine()
	_verify_card_contract_and_unknown_actor_fallback()
	await _verify_board_context_and_geometry(Vector2(1280.0, 720.0))
	await _verify_board_context_and_geometry(Vector2(1280.0, 800.0))
	_finish()

func _verify_engine_preview_is_actor_backed_and_pure() -> void:
	var engine := ENGINE_SCRIPT.new() as CombatResolutionEngine
	var definition := _find_action(ADAPTER_SCRIPT.new().build_basic_actions(), "basic_quick_attack")
	var low_actor := {"stats": {"external": 4}}
	var high_actor := {"stats": {"external": 10}}
	var low_before := low_actor.duplicate(true)
	var high_before := high_actor.duplicate(true)
	var low: Dictionary = engine.preview_attack_damage(definition, low_actor)
	var high: Dictionary = engine.preview_attack_damage(definition, high_actor)
	_check(bool(low.get("available", false)), "Known player stats must produce an attack preview.")
	_check(int(high.get("value", -1)) > int(low.get("value", -1)), "Changing the player's actual attack stat must change preview power.")
	_check(low_actor == low_before and high_actor == high_before, "Attack preview must not mutate actor state.")
	_check(not bool(engine.preview_attack_damage(definition, {}).get("available", true)), "Unknown actor stats must fail to a truthful formula fallback.")


func _verify_martial_attack_previews_never_invent_zero() -> void:
	var engine := ENGINE_SCRIPT.new() as CombatResolutionEngine
	var registry := MARTIAL_REGISTRY_SCRIPT.new() as MartialManualRegistry
	var actor := {"stats": {"external": 8, "constitution": 8, "agility": 8, "internal_power": 8, "insight": 8}, "attack_power": 8}
	var saw_single_attack := false
	var saw_conditional_multi_hit := false
	for manual_id in registry.get_manual_ids():
		for definition_value in registry.build_unlocked_cards(manual_id, 10):
			var definition: Dictionary = definition_value
			if str(definition.get("category", "")) != "attack":
				continue
			var preview: Dictionary = engine.preview_attack_damage(definition, actor)
			if bool(preview.get("available", false)):
				saw_single_attack = true
				_check(int(preview.get("value", 0)) > 0, "%s must never expose a false zero attack preview." % str(definition.get("id", "martial attack")))
			else:
				saw_conditional_multi_hit = true
				_check(not str(preview.get("reason", "")).is_empty(), "%s must explain why one exact aggregate preview is unavailable." % str(definition.get("id", "martial attack")))
			var card := CARD_SCRIPT.new() as ActionChoiceCard
			card.configure_action(definition, "semantic_atlas", "", actor)
			var text := _descendant_label_text(card.find_child("CardSummary", false, false))
			_check(not text.contains("예상 위력 0"), "%s card must not render an invented zero magnitude." % str(definition.get("id", "martial attack")))
			if not bool(preview.get("available", false)):
				_check(text.contains("상세 확인"), "%s card must name the truthful non-aggregate fallback." % str(definition.get("id", "martial attack")))
			card.queue_free()
	_check(saw_single_attack, "The real martial catalog must exercise an exact single-attack preview.")
	_check(saw_conditional_multi_hit, "The real martial catalog must exercise a truthful conditional or multi-hit fallback.")


func _verify_shared_preview_engine() -> void:
	var first = ENGINE_SCRIPT.shared_preview_engine()
	var second = ENGINE_SCRIPT.shared_preview_engine()
	_check(is_instance_valid(first) and first == second, "Card and hover-detail previews must share one lazy engine instance.")
	var detail_source := FileAccess.get_file_as_string("res://src/ui/action_selection/action_detail_panel.gd")
	_check(not detail_source.contains("RESOLUTION_ENGINE_SCRIPT.new().preview"), "Hover detail must not reload combat JSON and AI for every preview.")


func _verify_card_contract_and_unknown_actor_fallback() -> void:
	var adapter := ADAPTER_SCRIPT.new() as ActionViewModelAdapter
	var definitions := [
		_find_action(adapter.build_basic_actions(), "basic_quick_attack"),
		_find_action(adapter.build_basic_actions(), "basic_move"),
		_find_action(adapter.build_ultimate_actions(5), "ultimate_ten_paces_wave")
	]
	for definition in definitions:
		_check(not definition.is_empty(), "Focused basic, movement, and ultimate definitions must exist.")
		if definition.is_empty():
			continue
		var card := CARD_SCRIPT.new() as ActionChoiceCard
		card.configure_action(definition, "semantic_atlas", "", {"stats": {"external": 8, "internal_power": 8}, "attack_power": 8})
		var summary := card.find_child("CardSummary", false, false) as VBoxContainer
		_check(is_instance_valid(summary), "Every preparation card must contain an always-visible summary.")
		var text := _descendant_label_text(summary)
		_check(text.contains("수") and text.contains("기력") and text.contains("내력"), "Card summary must always show slot, stamina, and internal costs.")
		_check(text.contains("거리"), "Card summary must always show range.")
		_check(text.contains("예상 위력") or text.contains("이동") or text.contains("효과"), "Card summary must show a primary magnitude, movement, or truthful effect fallback.")
		_check(card.find_child("CardIllustration", false, false) != null, "Always-visible summaries must preserve illustrations.")
		_check(card.custom_minimum_size.y <= 100.0, "Summary cards must remain within the bounded two-row geometry budget.")
		for summary_label in summary.find_children("*", "Label", true, false):
			_check((summary_label as Label).get_combined_minimum_size().x <= 128.0, "Always-visible summary text must fit the 128px card lane without clipping.")
		card.queue_free()

	var unknown := CARD_SCRIPT.new() as ActionChoiceCard
	unknown.configure_action(definitions[0], "semantic_atlas", "", {})
	var unknown_text := _descendant_label_text(unknown.find_child("CardSummary", false, false))
	_check(unknown_text.contains("위력식") and not unknown_text.contains("예상 위력"), "Unknown actors must show a formula/baseline label instead of invented preview damage.")
	unknown.queue_free()

func _verify_board_context_and_geometry(viewport_size: Vector2) -> void:
	var board := BOARD_SCENE.instantiate() as CombatBoardPreview
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = viewport_size
	root.add_child(board)
	for _frame in range(5):
		await process_frame
	var dock := board.action_selection_dock as ActionSelectionDock
	var host_rect := dock.content_host.get_global_rect()
	_check(typeof(dock.runtime_context.get("preview_actor", {})) == TYPE_DICTIONARY and not (dock.runtime_context.get("preview_actor", {}) as Dictionary).is_empty(), "Combat board must connect the current player snapshot to card previews.")
	var cards := dock.basic_panel.buttons
	_check(cards.size() == 10, "The existing 5 by 2 basic grid must remain intact.")
	for button in cards:
		var rect := (button as Control).get_global_rect()
		_check(rect.position.x >= host_rect.position.x - 0.5 and rect.end.x <= host_rect.end.x + 0.5 and rect.position.y >= host_rect.position.y - 0.5 and rect.end.y <= host_rect.end.y + 0.5, "Every summary card must remain inside the in-viewport content host at %s." % str(viewport_size))
		var summary := (button as Control).find_child("CardSummary", false, false) as VBoxContainer
		_check(is_instance_valid(summary), "Rendered cards must retain the summary container.")
		if is_instance_valid(summary):
			var prior_bottom := -INF
			for summary_label in summary.find_children("*", "Label", true, false):
				var label_rect := (summary_label as Label).get_global_rect()
				_check(rect.encloses(label_rect), "Every rendered summary line must stay inside its card border at %s." % str(viewport_size))
				_check(label_rect.position.y >= prior_bottom - 0.5, "Rendered summary lines must not overlap each other at %s." % str(viewport_size))
				prior_bottom = label_rect.end.y
	dock.set_active_source("martial")
	for _frame in range(3):
		await process_frame
	var martial := dock.martial_panel as MartialActionPanel
	_check(is_instance_valid(martial) and martial.manual_buttons.size() == 4, "The actual four-manual horizontal selector must render in the martial source.")
	if is_instance_valid(martial):
		var manual_viewport_rect := martial.manual_scroll.get_global_rect()
		_check(host_rect.encloses(manual_viewport_rect), "The real manual selector viewport must stay inside the content host at %s." % str(viewport_size))
		_check(martial.manual_scroll.clip_contents, "The horizontal manual selector must clip offscreen choices at %s." % str(viewport_size))
		if not martial.manual_buttons.is_empty():
			var first_manual := martial.manual_buttons.front() as Control
			_check(manual_viewport_rect.encloses(first_manual.get_global_rect()), "The first real manual must be fully visible without left clipping at %s." % str(viewport_size))
			var horizontal_bar := martial.manual_scroll.get_h_scroll_bar()
			_check(horizontal_bar.max_value > horizontal_bar.page, "Four real manuals must remain horizontally scrollable at %s." % str(viewport_size))
			martial.manual_scroll.scroll_horizontal = int(horizontal_bar.max_value)
			await process_frame
			var last_manual := martial.manual_buttons.back() as Control
			_check(manual_viewport_rect.encloses(last_manual.get_global_rect()), "The last real manual must be fully reachable inside the selector viewport at %s." % str(viewport_size))
		for button in martial.technique_buttons:
			var technique_rect := (button as Control).get_global_rect()
			_check(host_rect.encloses(technique_rect), "Every real martial technique card must stay inside the content host at %s." % str(viewport_size))
			var summary := (button as Control).find_child("CardSummary", false, false) as VBoxContainer
			if is_instance_valid(summary):
				for summary_label in summary.find_children("*", "Label", true, false):
					_check((summary_label as Label).get_combined_minimum_size().x <= technique_rect.size.x + 0.5, "Martial fallback text must fit its actual card lane without clipping at %s." % str(viewport_size))
	_check(dock.get_global_rect().position.y >= board.top_hud.get_global_rect().end.y, "Planning UI must not overlap the resource HUD.")
	var duel_surface := board.get_node_or_null("DuelStageSurface") as Control
	_check(is_instance_valid(duel_surface) and duel_surface.get_global_rect().end.y <= board.planning_surface.get_global_rect().position.y + 1.0, "Planning UI must not overlap the battlefield partition.")
	board.queue_free()
	await process_frame

func _find_action(actions: Array[Dictionary], action_id: String) -> Dictionary:
	for action in actions:
		if str(action.get("id", "")) == action_id:
			return action.duplicate(true)
	return {}

func _descendant_label_text(node: Node) -> String:
	if node == null:
		return ""
	var parts := PackedStringArray()
	for child in node.find_children("*", "Label", true, false):
		parts.append((child as Label).text)
	return " ".join(parts)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("verify_action_card_summary: PASS")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("verify_action_card_summary: FAIL count=%d" % failures.size())
	quit(1)
