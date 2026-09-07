extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const VIEWPORT_SIZE := Vector2(1440.0, 900.0)
const TARGET_TOP_OVERLAY_RATIO := 0.20
const TARGET_PLANNING_TOP_RATIO := 0.60

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load(BOARD_SCENE_PATH) as PackedScene
	var board := packed.instantiate() as CombatBoardPreview if packed != null else null
	_expect(board != null, "Frontal duel partition requires the combat board scene.")
	if board == null:
		_finish()
		return
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = VIEWPORT_SIZE
	root.add_child(board)
	for _frame in range(5):
		await process_frame

	_verify_three_screen_surfaces(board)
	_verify_reference_preparation_hierarchy(board)
	await _verify_reference_information_columns(board)
	_verify_current_bundle_only(board)
	_verify_distant_frontal_duel(board)

	board.queue_free()
	await process_frame
	_finish()

func _verify_three_screen_surfaces(board: CombatBoardPreview) -> void:
	var top_surface := board.get_node_or_null("TopHudSurface") as Control
	var duel_surface := board.get_node_or_null("DuelStageSurface") as Control
	var planning_surface := board.get_node_or_null("PlanningSurface") as Control
	_expect(is_instance_valid(top_surface), "Top HUD must have an independent surface behind status and round information.")
	_expect(is_instance_valid(duel_surface), "Duel must have a dedicated middle-stage surface.")
	_expect(is_instance_valid(planning_surface), "Planning tabs and cards must have an independent lower surface.")
	if not is_instance_valid(top_surface) or not is_instance_valid(duel_surface) or not is_instance_valid(planning_surface):
		return
	var top_rect := top_surface.get_global_rect()
	var duel_rect := duel_surface.get_global_rect()
	var planning_rect := planning_surface.get_global_rect()
	var dock := board.get_node_or_null("ActionSelectionDock") as Control
	_expect(top_rect.end.y <= duel_rect.position.y + 0.5, "Top status surface must end before the semantic duel stage begins.")
	_expect(duel_rect.end.y <= planning_rect.position.y + 0.5, "Duel stage must end before the planning surface begins.")
	_expect(absf(top_rect.size.y / board.size.y - TARGET_TOP_OVERLAY_RATIO) <= 0.035, "Top status overlay must occupy about 20 percent of the preparation view.")
	_expect(absf((planning_rect.position.y - board.global_position.y) / board.size.y - TARGET_PLANNING_TOP_RATIO) <= 0.045, "The 5 by 2 card surface must begin at the reference preparation-screen split, not halfway up the combat view.")
	_expect(board.battle_background.get_global_rect().position.y <= 1.0 and board.battle_background.get_global_rect().end.y >= planning_rect.position.y - 1.0, "Courtyard background must continue behind the transparent top status overlay through the combat floor.")
	_expect(board.duel_foreground_banner.get_global_rect().position.y <= 1.0 and board.duel_foreground_banner.get_global_rect().end.y >= planning_rect.position.y - 1.0, "Banner foreground must share the full upper duel composition behind the status overlay.")
	_expect(planning_rect.encloses(board.action_timing_panel.get_global_rect()), "Action bundle display must sit on the lower planning surface.")
	if is_instance_valid(dock) and not planning_rect.encloses(dock.get_global_rect()):
		print("PARTITION_DIAGNOSTIC planning=%s dock=%s" % [str(planning_rect), str(dock.get_global_rect())])
	_expect(is_instance_valid(dock) and planning_rect.encloses(dock.get_global_rect()), "Action tabs and card selection must sit on the lower planning surface.")
	_expect(top_rect.encloses(board.top_hud.get_global_rect()), "Status and round HUD must sit on the top information surface.")

func _verify_reference_preparation_hierarchy(board: CombatBoardPreview) -> void:
	var hud := board.top_hud
	_expect(is_instance_valid(hud), "Reference preparation hierarchy requires the top combat HUD.")
	if not is_instance_valid(hud):
		return
	var player_rect := hud.player_panel.get_global_rect() if is_instance_valid(hud.player_panel) else Rect2()
	var enemy_rect := hud.enemy_panel.get_global_rect() if is_instance_valid(hud.enemy_panel) else Rect2()
	var round_rect := hud.round_panel.get_global_rect() if is_instance_valid(hud.round_panel) else Rect2()
	_expect(player_rect.size.x / maxf(1.0, player_rect.size.y) >= 2.55, "Player status frame must preserve its wide ink-brush aspect instead of compressing text over the portrait.")
	_expect(enemy_rect.size.x / maxf(1.0, enemy_rect.size.y) >= 2.55, "Enemy status frame must preserve its wide ink-brush aspect instead of compressing text over the portrait.")
	_expect(absf((round_rect.get_center().x - board.global_position.x) - board.size.x * 0.5) <= 4.0, "Round information must remain centered between the two wide status frames.")
	_expect(round_rect.size.x <= minf(player_rect.size.x, enemy_rect.size.x) * 0.62, "Round information must be a compact center marker, not a third full-width panel.")
	_expect(is_instance_valid(hud.player_momentum) and not hud.player_momentum.visible, "Momentum must live inside the player status frame, not in a detached top panel.")
	_expect(is_instance_valid(hud.enemy_momentum) and not hud.enemy_momentum.visible, "Momentum must live inside the enemy status frame, not in a detached top panel.")
	if is_instance_valid(hud.player_panel):
		_expect(hud.player_panel._portrait.get_global_rect().end.x + 6.0 <= hud.player_panel._health_label.get_global_rect().position.x, "Player status text must have a dedicated column to the right of the portrait.")
	if is_instance_valid(hud.enemy_panel):
		_expect(hud.enemy_panel._health_label.get_global_rect().end.x + 6.0 <= hud.enemy_panel._portrait.get_global_rect().position.x, "Enemy status text must have a dedicated column to the left of the portrait.")

	var planning_rect := board.planning_surface.get_global_rect() if is_instance_valid(board.planning_surface) else Rect2()
	var timing_rect := board.action_timing_panel.get_global_rect() if is_instance_valid(board.action_timing_panel) else Rect2()
	var progress_rect := board.combat_progress_button.get_global_rect() if is_instance_valid(board.combat_progress_button) else Rect2()
	_expect(timing_rect.size.x + progress_rect.size.x <= planning_rect.size.x * 0.66, "Current action bundle and lock must form one compact left planning group, leaving room for details and observation.")
	_expect(absf(progress_rect.get_center().y - timing_rect.get_center().y) <= 4.0 and progress_rect.position.x - timing_rect.end.x <= 12.0, "Action-plan lock must align immediately beside the current action bundle instead of floating at the far edge.")
	_expect(not board.sound_toggle_button.visible and not board.sound_volume_slider.visible and not board.fast_replay_button.visible and not board.reduced_motion_button.visible and not board.combat_log_panel.visible, "Preparation view must not expose debug playback, sound, or record panels absent from the approved reference screen.")

func _verify_reference_information_columns(board: CombatBoardPreview) -> void:
	var hud := board.top_hud
	_expect(is_instance_valid(hud), "Reference information columns require the top HUD.")
	if is_instance_valid(hud) and is_instance_valid(hud.player_panel) and is_instance_valid(hud.enemy_panel):
		_expect(hud.player_panel.has_method("get_resource_layout_snapshot"), "Player status HUD must expose label and gauge geometry for overlap regression checks.")
		_expect(hud.enemy_panel.has_method("get_resource_layout_snapshot"), "Enemy status HUD must expose label and gauge geometry for overlap regression checks.")
		if not hud.player_panel.has_method("get_resource_layout_snapshot") or not hud.enemy_panel.has_method("get_resource_layout_snapshot"):
			return
		var player_layout: Dictionary = hud.player_panel.get_resource_layout_snapshot()
		var enemy_layout: Dictionary = hud.enemy_panel.get_resource_layout_snapshot()
		_expect(float(player_layout.get("resource_width", 0.0)) >= hud.player_panel.size.x * 0.46, "Player resource bars must have the wide readable lane shown by the approved status reference.")
		_expect(float(enemy_layout.get("resource_width", 0.0)) >= hud.enemy_panel.size.x * 0.46, "Enemy resource bars must have the same readable lane without numeric leakage.")
		for label_rect in player_layout.get("label_rects", []):
			_expect((label_rect as Rect2).end.y <= (player_layout.get("bar_rects", []) as Array)[(player_layout.get("label_rects", []) as Array).find(label_rect)].position.y, "Player resource text must sit above its gauge instead of overlapping the fill.")
		for label_rect in enemy_layout.get("label_rects", []):
			_expect((label_rect as Rect2).end.y <= (enemy_layout.get("bar_rects", []) as Array)[(enemy_layout.get("label_rects", []) as Array).find(label_rect)].position.y, "Enemy resource text must sit above its gauge instead of overlapping the fill.")

	var dock := board.get_node_or_null("ActionSelectionDock") as ActionSelectionDock
	var observation := board.observation_reveal_panel as Control
	_expect(is_instance_valid(dock), "Preparation reference requires the shared action dock.")
	_expect(is_instance_valid(observation), "Preparation reference requires a separate observation information column.")
	if not is_instance_valid(dock) or not is_instance_valid(observation):
		return
	var planning_rect := board.planning_surface.get_global_rect()
	var content_rect := dock.content_host.get_global_rect()
	var detail_rect := dock.detail_host.get_global_rect()
	var observation_rect := observation.get_global_rect()
	_expect(content_rect.position.x >= board.global_position.x + board.size.x * 0.07, "Current-plan cards must begin on the same intentional inset as the reference, not at the viewport edge.")
	_expect(content_rect.size.x <= planning_rect.size.x * 0.66, "The five-by-two card grid must leave a dedicated right-side detail and observation area.")
	_expect(detail_rect.position.x >= content_rect.end.x + 6.0 and detail_rect.size.x >= planning_rect.size.x * 0.13, "Technique detail must occupy its own readable column beside the card grid.")
	var detail_panel := dock.detail_host.get_node_or_null("ActionDetailPanel") as ActionDetailPanel
	_expect(is_instance_valid(detail_panel) and not detail_panel.visible, "The detail column must reserve its geometry but keep an empty card detail hidden until the player hovers or pins a real action.")
	if is_instance_valid(detail_panel):
		var empty_detail: Dictionary = detail_panel.get_detail_snapshot()
		_expect(str(empty_detail.get("mode", "")) == "empty" and str(empty_detail.get("title", "")) == "" and bool(empty_detail.get("hover_preview", false)), "An idle detail panel must reserve the hover target without pretending an unselected action is planned.")
		_expect(detail_panel.has_method("get_layout_snapshot"), "Detail panel must expose its compact text safe-area geometry for the approved frame regression check.")
		if detail_panel.has_method("get_layout_snapshot"):
			detail_panel.show_action({
				"id": "layout_probe",
				"name": "속공",
				"source_label": "기초",
				"category": "attack",
				"action_slots": 1,
				"stamina_cost": 1,
				"internal_cost": 0,
				"range_text": "1",
				"damage_formula": {"base": 3}
			})
			await process_frame
			var detail_layout: Dictionary = detail_panel.get_layout_snapshot()
			var detail_body_rect: Rect2 = detail_layout.get("body_rect", Rect2()) as Rect2
			_expect(detail_body_rect.size.x >= 200.0, "Compact technique detail needs one full-width readable text lane for cost, effect, and range instead of collapsing values into ornamental space.")
			_expect(detail_body_rect.end.x <= detail_rect.end.x - 8.0, "Compact technique detail text must keep a deliberate inset inside its own right-side panel.")
			detail_panel.clear_detail()
	_expect(observation.visible and planning_rect.encloses(observation_rect), "Observation must remain a visible lower-planning column even before a safe action type has been revealed.")
	_expect(observation_rect.position.x >= detail_rect.end.x + 6.0, "Observation must sit beside, not on top of, the technique detail column.")
	_expect(observation_rect.size.x / maxf(1.0, observation_rect.size.y) <= 1.02, "Observation must preserve the approved vertical frame instead of horizontally squeezing its text rows.")
	var detail_scene := load("res://scenes/ui/action_selection/action_detail_panel.tscn") as PackedScene
	var reusable_detail := detail_scene.instantiate() as ActionDetailPanel if detail_scene != null else null
	_expect(is_instance_valid(reusable_detail), "Technique detail must remain a reusable action-panel component.")
	if is_instance_valid(reusable_detail):
		_expect(reusable_detail.custom_minimum_size.x <= detail_rect.size.x and reusable_detail.custom_minimum_size.y <= detail_rect.size.y, "Technique detail scene minimum size must fit the allocated right-hand detail column.")
		reusable_detail.queue_free()

func _verify_current_bundle_only(board: CombatBoardPreview) -> void:
	var timing := board.action_timing_panel
	_expect(timing != null and timing.has_method("get_visible_timing_indices"), "Timing panel must expose only the visible current-bundle indices.")
	if timing == null or not timing.has_method("get_visible_timing_indices"):
		return
	_expect(timing.call("get_visible_timing_indices") == PackedInt32Array([1, 2, 3]), "Bundle 1 must show only its current three action slots.")
	_expect(int(timing.get_timing_snapshot().get("current_bundle", 0)) == 1 and timing._title_label.text.contains("현재 계획") and timing._title_label.text.contains("3수"), "Bundle display must identify the current first bundle while showing only its three actions.")
	var timing_scene := load("res://scenes/ui/action_timing_panel.tscn") as PackedScene
	var isolated_timing := timing_scene.instantiate() as ActionTimingPanel if timing_scene != null else null
	_expect(is_instance_valid(isolated_timing), "Current-bundle display needs an independently reusable timing panel.")
	if not is_instance_valid(isolated_timing):
		return
	isolated_timing.size = Vector2(800.0, 120.0)
	root.add_child(isolated_timing)
	await process_frame
	var first_advance: Dictionary = isolated_timing.advance_after_resolution()
	_expect(int(first_advance.get("current_bundle", 0)) == 2, "Advancing must move the logical plan to bundle 2.")
	_expect(isolated_timing.call("get_visible_timing_indices") == PackedInt32Array([4, 5, 6]), "Bundle 2 must reveal only its three action slots.")
	_expect(int(isolated_timing.get_timing_snapshot().get("current_bundle", 0)) == 2 and isolated_timing._title_label.text.contains("현재 계획") and isolated_timing._title_label.text.contains("3수"), "Bundle display must advance to the second current bundle without rendering future slots.")
	isolation_safe_advance(isolated_timing)
	_expect(isolated_timing.call("get_visible_timing_indices") == PackedInt32Array([7, 8, 9, 10]), "Bundle 3 must reveal only its current four action slots.")
	_expect(int(isolated_timing.get_timing_snapshot().get("current_bundle", 0)) == 3 and isolated_timing._title_label.text.contains("현재 계획") and isolated_timing._title_label.text.contains("4수"), "Bundle display must identify the four-action final bundle.")
	isolation_safe_free(isolated_timing)

func isolation_safe_advance(timing: ActionTimingPanel) -> void:
	timing.advance_after_resolution()

func isolation_safe_free(timing: ActionTimingPanel) -> void:
	timing.queue_free()

func _verify_distant_frontal_duel(board: CombatBoardPreview) -> void:
	_expect(str(board.get_meta("character_scale_profile", "")) == "distant_frontal_duel", "Frontal combat must declare its distant character-scale profile.")
	var player_foot := board.get_character_foot_anchor("player")
	var enemy_foot := board.get_character_foot_anchor("enemy")
	_expect(enemy_foot.x - player_foot.x >= board.size.x * 0.42, "Combatants must retain a readable distant frontal separation instead of a close-up confrontation.")
	var duel_surface := board.get_node_or_null("DuelStageSurface") as Control
	if is_instance_valid(duel_surface):
		_expect(board.player_character.size.y <= duel_surface.size.y * 0.52, "Player battler must remain scaled for a distant stage view.")
		_expect(board.enemy_character.size.y <= duel_surface.size.y * 0.52, "Enemy battler must remain scaled for a distant stage view.")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("FRONTAL_DUEL_SCREEN_PARTITION_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("FRONTAL_DUEL_SCREEN_PARTITION_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
