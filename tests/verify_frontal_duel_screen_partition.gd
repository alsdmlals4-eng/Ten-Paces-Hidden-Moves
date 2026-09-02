extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const VIEWPORT_SIZE := Vector2(1440.0, 900.0)

var failures: Array[String] = []

func _initialize() -> void:
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
	_expect(top_rect.end.y <= duel_rect.position.y + 0.5, "Top status surface must end before the duel stage begins.")
	_expect(duel_rect.end.y <= planning_rect.position.y + 0.5, "Duel stage must end before the planning surface begins.")
	_expect(board.battle_background.get_global_rect().encloses(duel_rect) and duel_rect.encloses(board.battle_background.get_global_rect()), "Courtyard background must be clipped to the middle duel stage only.")
	_expect(board.duel_foreground_banner.get_global_rect().encloses(duel_rect) and duel_rect.encloses(board.duel_foreground_banner.get_global_rect()), "Banner foreground must frame the middle duel stage only.")
	_expect(planning_rect.encloses(board.action_timing_panel.get_global_rect()), "Action bundle display must sit on the lower planning surface.")
	var dock := board.get_node_or_null("ActionSelectionDock") as Control
	if is_instance_valid(dock) and not planning_rect.encloses(dock.get_global_rect()):
		print("PARTITION_DIAGNOSTIC planning=%s dock=%s" % [str(planning_rect), str(dock.get_global_rect())])
	_expect(is_instance_valid(dock) and planning_rect.encloses(dock.get_global_rect()), "Action tabs and card selection must sit on the lower planning surface.")
	_expect(top_rect.encloses(board.top_hud.get_global_rect()), "Status and round HUD must sit on the top information surface.")

func _verify_current_bundle_only(board: CombatBoardPreview) -> void:
	var timing := board.action_timing_panel
	_expect(timing != null and timing.has_method("get_visible_timing_indices"), "Timing panel must expose only the visible current-bundle indices.")
	if timing == null or not timing.has_method("get_visible_timing_indices"):
		return
	_expect(timing.call("get_visible_timing_indices") == PackedInt32Array([1, 2, 3]), "Bundle 1 must show only its current three action slots.")
	_expect(timing._title_label.text.contains("1묶음") and timing._title_label.text.contains("3수"), "Bundle display must name the current first bundle and its three actions.")
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
	_expect(isolated_timing._title_label.text.contains("2묶음") and isolated_timing._title_label.text.contains("3수"), "Bundle display must rename the second current bundle without rendering future slots.")
	isolation_safe_advance(isolated_timing)
	_expect(isolated_timing.call("get_visible_timing_indices") == PackedInt32Array([7, 8, 9, 10]), "Bundle 3 must reveal only its current four action slots.")
	_expect(isolated_timing._title_label.text.contains("3묶음") and isolated_timing._title_label.text.contains("4수"), "Bundle display must name the four-action final bundle.")
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
