extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const VIEWPORT_SIZE := Vector2(1440.0, 900.0)
const TARGET_TOP_OVERLAY_RATIO := 0.20
const TARGET_PLANNING_TOP_RATIO := 0.60

var failures: Array[String] = []
var art_oracles: Dictionary = {}
var source_hashes: Dictionary = {}
var ordinary_reference_result: Dictionary = {}

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
	await _verify_current_bundle_only(board)
	_verify_distant_frontal_duel(board)

	board.queue_free()
	await process_frame
	for viewport in [Vector2(1280, 720), Vector2(1280, 800), Vector2(1920, 1080)]:
		await _verify_measured_execution(packed, viewport)
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
	_expect(not top_surface.visible and duel_rect.encloses(board.top_hud.get_global_rect()), "HUD floats over the upper battle surface without a separate opaque strip.")
	_expect(duel_rect.end.y <= planning_rect.position.y + 0.5, "Duel stage must end before the planning surface begins.")
	_expect(absf(top_rect.size.y / board.size.y - TARGET_TOP_OVERLAY_RATIO) <= 0.035, "Top status overlay must occupy about 20 percent of the preparation view.")
	_expect(absf((planning_rect.position.y - board.global_position.y) / board.size.y - TARGET_PLANNING_TOP_RATIO) <= 0.045, "The expanded 5 by 2 summary-card surface must preserve a bounded lower preparation split.")
	# Sep02 stage-only owner supersedes these old behind-HUD fixture expectations.
	_expect(_rect_near(board.battle_background.get_global_rect(), duel_rect), "Courtyard background must equal the active duel stage, excluding HUD/planning.")
	_expect(_rect_near(board.duel_foreground_banner.get_global_rect(), duel_rect), "Banner must equal the stage-only background.")
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
	_expect(player_rect.size.x / maxf(1.0, player_rect.size.y) >= 2.1, "Player portrait HUD preserves a wide readable resource lane.")
	_expect(enemy_rect.size.x / maxf(1.0, enemy_rect.size.y) >= 2.1, "Enemy portrait HUD preserves the same resource lane.")
	_expect(absf((round_rect.get_center().x - board.global_position.x) - board.size.x * 0.5) <= 4.0, "Round information must remain centered between the two wide status frames.")
	_expect(round_rect.size.x <= minf(player_rect.size.x, enemy_rect.size.x) * 0.62, "Round information must be a compact center marker, not a third full-width panel.")
	_expect(is_instance_valid(hud.player_momentum) and not hud.player_momentum.visible, "Momentum must live inside the player status frame, not in a detached top panel.")
	_expect(is_instance_valid(hud.enemy_momentum) and not hud.enemy_momentum.visible, "Momentum must live inside the enemy status frame, not in a detached top panel.")
	if is_instance_valid(hud.player_panel):
		_expect(hud.player_panel._portrait.visible, "Player HUD shows the current battler portrait.")
		_expect(player_rect.encloses(hud.player_panel._health_label.get_global_rect()), "Player resource label stays inside the status panel.")
	if is_instance_valid(hud.enemy_panel):
		_expect(hud.enemy_panel._portrait.visible, "Enemy HUD shows the current battler portrait.")
		_expect(enemy_rect.encloses(hud.enemy_panel._health_label.get_global_rect()), "Enemy resource label stays inside the status panel.")

	var planning_rect := board.planning_surface.get_global_rect() if is_instance_valid(board.planning_surface) else Rect2()
	var timing_rect := board.action_timing_panel.get_global_rect() if is_instance_valid(board.action_timing_panel) else Rect2()
	var progress_rect := board.combat_progress_button.get_global_rect() if is_instance_valid(board.combat_progress_button) else Rect2()
	_expect(timing_rect.size.x <= planning_rect.size.x * 0.55, "Current plan occupies the left column and leaves detail/observation lanes.")
	var observation := board.observation_reveal_panel.get_global_rect()
	_expect(absf(progress_rect.position.x - observation.position.x) <= 1.0 and progress_rect.position.y >= observation.end.y, "Execution is aligned below the right observation column.")
	_expect(not board.sound_toggle_button.visible and not board.sound_volume_slider.visible and not board.fast_replay_button.visible and not board.combat_log_panel.visible and board.reduced_motion_button.visible, "Only the player-facing reduced-motion preference remains exposed.")

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
	_expect(content_rect.position.x >= board.global_position.x + 10.0, "Current-plan cards keep a bounded viewport inset.")
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
	_expect(observation_rect.size.x >= planning_rect.size.x * 0.23 and observation_rect.size.y >= planning_rect.size.y * 0.65, "Observation has a substantial dedicated column rather than a narrow strip.")
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
	_expect(enemy_foot.x - player_foot.x >= board.size.x * 0.27, "Combatants retain distinct positions at the current public distance.")
	var duel_surface := board.get_node_or_null("DuelStageSurface") as Control
	if is_instance_valid(duel_surface):
		for actor in [board.player_character, board.enemy_character]:
			_expect(actor.has_method("get_visible_art_bounds_global"), "Renderer must expose occupied art bounds, not Control-size evidence.")
			if actor.has_method("get_visible_art_bounds_global"):
				_verify_ink(board, actor, true)

func _rect_near(a: Rect2, b: Rect2, tolerance: float = 0.5) -> bool:
	return a.position.distance_to(b.position) <= tolerance and a.size.distance_to(b.size) <= tolerance

func _independent_ink(actor: CombatCharacterPlaceholder, motion: bool = true) -> Rect2:
	var path := str(actor.get_meta("character_art_path", ""))
	if not source_hashes.has(path):
		source_hashes[path] = FileAccess.get_sha256(path)
	var texture := actor.get_render_texture()
	var key := ((texture as AtlasTexture).atlas.resource_path + str((texture as AtlasTexture).region)) if texture is AtlasTexture else path
	if not art_oracles.has(key):
		# Inspect the selected source frame, not the entire multi-pose sheet.
		# Derive keyed visible bounds independently from source pixels.
		var image := texture.get_image()
		_expect(image != null and not image.is_empty(), "Source art must load for independent alpha bounds: " + path)
		if image == null or image.is_empty():
			return Rect2()
		var foot := clampf(float(image.get_used_rect().end.y) / image.get_height(), 0.70, 1.0)
		var used := image.get_used_rect()
		if texture is AtlasTexture:
			var minimum := Vector2i(image.get_width(), image.get_height())
			var maximum := Vector2i(-1, -1)
			for row in range(image.get_height()):
				for column in range(image.get_width()):
					var sample := image.get_pixel(column, row)
					if sample.a > 0.01 and sample.g - maxf(sample.r, sample.b) < 0.42:
						minimum = minimum.min(Vector2i(column, row))
						maximum = maximum.max(Vector2i(column, row))
			used = Rect2i(minimum, maximum - minimum + Vector2i.ONE)
			var found := false
			for y in range(image.get_height() - 1, -1, -1):
				for x in range(image.get_width()):
					var pixel := image.get_pixel(x, y)
					if pixel.a > 0.5 and pixel.g - maxf(pixel.r, pixel.b) < 0.1:
						foot = float(y + 1) / image.get_height()
						found = true
						break
				if found:
					break
		art_oracles[key] = {"used": used, "size": image.get_size(), "foot":foot, "hash": FileAccess.get_sha256(path)}
	var source: Dictionary = art_oracles[key]
	var used: Rect2 = Rect2(source.used)
	var dimensions: Vector2 = Vector2(source.size)
	var h := actor.size.y * 1.08
	var foot_ratio := float(source.foot)
	var width := h * (dimensions.aspect() if texture is AtlasTexture else 1.0)
	var origin := Vector2((actor.size.x - width) / 2.0, actor.size.y - h * foot_ratio)
	var pivot := Vector2(actor.size.x / 2.0, actor.size.y)
	var scale_value := actor.visual_scale if motion else 1.0
	var mirror := -1.0 if actor.role == "enemy" and actor.facing < 0 and path.ends_with("dogyeom_combat_battler_01_v1.png") else 1.0
	var result := Rect2()
	var first := true
	for corner in [used.position, Vector2(used.end.x, used.position.y), used.end, Vector2(used.position.x, used.end.y)]:
		var local: Vector2 = origin + corner / dimensions * Vector2(width, h)
		local = pivot + (local - pivot) * Vector2(mirror, 1.0) * scale_value + (actor.visual_offset if motion else Vector2.ZERO)
		var point: Vector2 = actor.get_global_transform() * local
		result = Rect2(point, Vector2.ZERO) if first else result.expand(point)
		first = false
	return result

func _verify_ink(board: CombatBoardPreview, actor: CombatCharacterPlaceholder, idle: bool = false) -> void:
	var stage := board.duel_stage_surface.get_global_rect()
	var ink := _independent_ink(actor)
	_expect(ink.has_area() and stage.grow(0.5).encloses(ink), "Occupied ink must remain in stage: %s / %s (%s)" % [ink, stage, actor.role])
	# Authored poses change silhouette height, unlike the old one-image scale tween.
	# Keep a bounded ceiling as well as the stricter actual stage containment below.
	_expect(ink.size.y <= stage.size.y * 0.75 + 0.5, "Authored pose exceeds the bounded battle-first envelope: ratio=%s role=%s frame=%s scale=%s" % [ink.size.y / stage.size.y, actor.role, actor.get_meta("pose_frame", -1), actor.visual_scale])
	if idle:
		_expect(absf(ink.size.y / stage.size.y - 0.58) <= 0.002, "Idle source bounds must reach 58 percent at reference viewport, got %s" % (ink.size.y / stage.size.y))
		_expect(ink.size.y * 1.12 <= stage.size.y * 0.66 + 0.5, "Complete motion envelope stays within the enlarged battle-first stage.")
		var foot: Vector2 = actor.get_global_transform() * actor.get_foot_anchor_local()
		var peak := Rect2(foot + (ink.position - foot) * 1.12, ink.size * 1.12)
		# Conservative union of every unchanged horizontal visual offset (max .22w).
		var envelope := peak.grow_individual(actor.size.x * 0.22, 0.0, actor.size.x * 0.22, 0.0)
		_expect(stage.grow(0.5).encloses(envelope), "Complete scale plus visual-offset envelope stays within the stage.")
	if actor.has_method("get_visible_art_bounds_global"):
		_expect(_rect_near(actor.call("get_visible_art_bounds_global", true), ink), "Renderer bounds must match independent source alpha/draw/global transform oracle.")
		_expect(_rect_near(actor.call("get_visible_art_bounds_global", false), _independent_ink(actor, false)), "Idle getter must exclude motion without changing node transform/mirroring.")

func _verify_authored_peak_envelope(board: CombatBoardPreview, actor: CombatCharacterPlaceholder) -> void:
	# Exercise every source pose at the real ultimate tween peak. Ordinary
	# frame sampling can miss a brief overshoot on a faster/slower machine.
	actor.play_ultimate_motion(1.0)
	actor.set_process(false)
	var tween := actor._motion_tween
	tween.pause()
	tween.custom_step(0.60)
	_expect(actor.visual_scale > 1.0, "Peak envelope probe must advance the actual ultimate tween.")
	for frame_index in range(7 if actor.role == "player" else 8):
		actor._set_pose_frame(frame_index)
		_verify_ink(board, actor)
	actor._stop_motion_tween()
	actor.set_idle()

func _verify_stage(board: CombatBoardPreview, expanded: bool) -> void:
	var stage := board.duel_stage_surface.get_global_rect()
	_expect(stage.has_area(), "Active stage must be positive.")
	for surface in [board.battle_background, board.duel_foreground_banner, board._background_readability_tint]:
		_expect(_rect_near(surface.get_global_rect(), stage), "Every background/banner/tint consumer must equal the final active stage.")
	_expect(stage.encloses(board.top_hud.get_global_rect()), "HUD floats inside the active battle stage.")
	if expanded:
		_expect(absf(stage.end.y - (board.global_position.y + board.size.y)) <= 0.5, "CTA and every timing must use the full remaining execution stage.")
	else:
		_expect(absf(board.planning_surface.position.y / board.size.y - 0.60) <= 0.002, "Next planning restores the 60 percent split.")
	for role in ["player", "enemy"]:
		_expect(absf(board.get_character_foot_anchor(role).y - board.battle_background.get_duel_floor_y(board.size)) <= 0.5, "Feet must use displayed background floor, not hidden timing/tile anchor.")

func _verify_measured_execution(packed: PackedScene, viewport: Vector2) -> void:
	var board := packed.instantiate() as CombatBoardPreview
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.position = Vector2(17, 23)
	board.size = viewport
	root.add_child(board)
	for _frame in range(6):
		await process_frame
	_verify_stage(board, false)
	for actor in [board.player_character, board.enemy_character]:
		for method in ["get_visible_art_bounds_local", "get_visible_art_bounds_global", "get_idle_art_height_per_node_height", "get_existing_motion_peak_scale"]:
			_expect(actor.has_method(method), "Missing measured-art renderer interface: " + method)
		_verify_ink(board, actor, true)
		_verify_authored_peak_envelope(board, actor)
	# A real actor binding selects Dogyeom; no substitute texture or altered art.
	board.combat_state.enemy["candidate_id"] = "slot1_dogyeom"
	board._layout_board()
	_verify_ink(board, board.enemy_character, true)
	var baseline := board.get_combat_state_snapshot()
	var move: Dictionary = {}
	for card in board.basic_card_tray.cards:
		if str(card.definition.get("id", "")) == "basic_move":
			move = card.definition.duplicate(true)
	board._on_product_action_selected(move)
	_expect(board._targeting_anchor == 1, "Actual dock movement must request its semantic intent.")
	board._on_product_intent_selected({"intent": "approach", "resolver_direction": 1, "steps": 1})
	for _index in range(2):
		board.action_selection_dock.basic_panel.buttons[2].emit_signal("pressed")
		await process_frame
	_expect(board.action_timing_panel.is_current_bundle_complete(), "Actual dock fills an executable three-slot bundle.")
	board.combat_progress_button.request_progress()
	_verify_stage(board, true)
	var count := 0
	var actual_move_checked := false
	var seen_timings: Dictionary = {}
	while board._inputs_locked() and count < 1200:
		await process_frame
		var reveal: Dictionary = board.action_reveal_overlay.get_snapshot()
		if board.action_reveal_overlay.visible:
			seen_timings[int(reveal.get("timing", 0))] = true
		if board.player_character.motion_state == "move" and not actual_move_checked:
			actual_move_checked = true
			var moving_actor := board.player_character
			var sequence := moving_actor._motion_sequence_id
			var before_layout := board.get_combat_state_snapshot()
			board._layout_board()
			_expect(moving_actor.motion_state == "move" and moving_actor._motion_sequence_id == sequence, "Real resolver MOVE survives direct same-size layout.")
			board._apply_combat_state_to_view()
			await process_frame
			_expect(moving_actor.motion_state == "move" and moving_actor._motion_sequence_id == sequence, "Real resolver MOVE survives deferred same-size layout.")
			if viewport.y == 800:
				board.size += Vector2(16, 16)
				board._layout_board()
				_expect(moving_actor.motion_state == "idle", "Real resolver MOVE snaps on a genuinely different final stage rect.")
			_expect(board.get_combat_state_snapshot() == before_layout, "Actual movement relayout cannot change authoritative snapshot.")
			if viewport.y == 1080:
				board._skip_presentation()
		_verify_stage(board, board._inputs_locked())
		for actor in [board.player_character, board.enemy_character]:
			_verify_ink(board, actor)
		count += 1
	_expect(count < 1200 and int(board.get_meta("resolution_count", 0)) == 1, "Ordinary CTA must complete exactly one resolution.")
	_expect(actual_move_checked, "Ordinary dock/CTA fixture must observe an actual resolver-produced MOVE, not only a sparse snapshot.")
	if viewport.y != 1080:
		_expect(seen_timings.has(1) and seen_timings.has(2) and seen_timings.has(3), "Non-skipped CTA must present all three actual timings.")
	for _frame in range(3):
		await process_frame
	_verify_stage(board, false)
	_expect(board.planning_surface.visible and board.action_selection_dock.visible, "Normal completion restores actual planning controls.")
	# Isolated presentation samples do not resolve or alter the domain.
	var resolved := board.get_combat_state_snapshot()
	if ordinary_reference_result.is_empty():
		ordinary_reference_result = resolved.duplicate(true)
	else:
		_expect(resolved == ordinary_reference_result, "Same actual plan produces identical resources/positions/context with resize or skip.")
	board._set_resolution_surface_visible(false)
	_verify_invalid_layout_dependencies(board)
	await _verify_non_settling_motion_bound(board)
	for actor in [board.player_character, board.enemy_character]:
		for method in ["play_attack_motion", "play_evade_motion", "play_block_motion", "play_hit_motion", "play_ultimate_motion"]:
			actor.call(method, 0.18)
			var sampled := await _sample_motion_until_idle(board, actor, method)
			_expect(sampled.settled and sampled.frames > 0, sampled.message)
		actor.play_clash_motion(actor.get_foot_anchor_global() + Vector2(20, 0), 0.18)
		var clash_sampled := await _sample_motion_until_idle(board, actor, "play_clash_motion")
		_expect(clash_sampled.settled and clash_sampled.frames > 0, clash_sampled.message)
	# The masked source is independently sampled too; restore actual Dogyeom
	# binding before domain-parity checks and the separate movement fixture.
	board.combat_state.enemy["candidate_id"] = ""
	board._layout_board()
	board.enemy_character.play_ultimate_motion(0.18)
	var masked_sampled := await _sample_motion_until_idle(board, board.enemy_character, "masked_play_ultimate_motion")
	_expect(masked_sampled.settled and masked_sampled.frames > 0, masked_sampled.message)
	board.combat_state.enemy["candidate_id"] = "slot1_dogyeom"
	board._layout_board()
	# Bounds must include real parent/node transforms, not global_position alone.
	board.scale = Vector2(0.95, 1.05)
	board.rotation = 0.03
	for actor in [board.player_character, board.enemy_character]:
		if actor.has_method("get_visible_art_bounds_global"):
			_expect(_rect_near(actor.call("get_visible_art_bounds_global"), _independent_ink(actor)), "Parent-transformed occupied bounds agree with independently transformed source corners.")
	board.scale = Vector2.ONE
	board.rotation = 0.0
	_expect(board.get_combat_state_snapshot() == resolved, "Geometry and motion must not mutate resolved domain state.")
	await _verify_snapshot_movement(board)
	_expect(FileAccess.get_sha256(board.player_character.PLAYER_ART_PATH) == source_hashes[board.player_character.PLAYER_ART_PATH], "Layout leaves source art bytes unchanged.")
	_expect(not baseline.is_empty(), "Immutable initial domain baseline retained.")
	board.queue_free()
	await process_frame

func _sample_motion_until_idle(board: CombatBoardPreview, actor: CombatCharacterPlaceholder, motion: String, max_frames: int = 600, timeout_ms: int = 5000) -> Dictionary:
	var frames := 0
	var deadline := Time.get_ticks_msec() + timeout_ms
	while actor.motion_state != "idle" and frames < max_frames and Time.get_ticks_msec() < deadline:
		await process_frame
		_verify_ink(board, actor)
		frames += 1
	return {
		"settled": actor.motion_state == "idle", "frames": frames,
		"message": "Motion must sample and settle within %d frames/%dms: role=%s motion=%s viewport=%s actual=%s frames=%d" % [max_frames, timeout_ms, actor.role, motion, board.size, actor.motion_state, frames],
	}

func _verify_non_settling_motion_bound(board: CombatBoardPreview) -> void:
	# Deliberately stop the real tween without changing its non-idle state.
	# The same sampling helper must reject it rather than waiting forever.
	var actor := board.player_character
	actor.play_attack_motion(0.18)
	actor._stop_motion_tween()
	var bounded := await _sample_motion_until_idle(board, actor, "non_settling_attack", 3, 5000)
	_expect(not bounded.settled and bounded.frames == 3 and actor.motion_state == "attack", "Non-settling motion must exhaust exactly the three-frame probe budget.")
	_expect(str(bounded.message).contains("role=player") and str(bounded.message).contains("motion=non_settling_attack") and str(bounded.message).contains("viewport=" + str(board.size)), "Timeout failure identifies the actual role, requested motion and viewport.")
	var expired := await _sample_motion_until_idle(board, actor, "expired_deadline_attack", 600, 0)
	_expect(not expired.settled and expired.frames == 0, "Expired wall-clock deadline rejects a non-settling motion before another sample.")
	print("BOUNDED_MOTION_NEGATIVE_OK role=%s viewport=%s frame_limit=%d deadline_samples=%d" % [actor.role, board.size, bounded.frames, expired.frames])
	actor.set_idle()

func _verify_invalid_layout_dependencies(board: CombatBoardPreview) -> void:
	# Synchronously detach only the references, retaining live nodes for safe
	# restoration before any frame/deferred layout callback can run.
	for dependency in ["battle_background", "duel_foreground_banner", "_background_readability_tint"]:
		var retained: Object = board.get(dependency)
		var actor := board.player_character
		actor.animate_move_to(board.get_character_foot_anchor("player") + Vector2(24, 0), 0.22)
		var sequence := actor._motion_sequence_id
		var tween := actor._motion_tween
		var actor_position := actor.position
		var stage := board.duel_stage_surface.get_rect()
		var baseline: Rect2 = board.get("_last_applied_active_duel_rect")
		var has_baseline: bool = board.get("_has_applied_active_duel_rect")
		var hud_position := board.top_hud.position
		var state := board.get_combat_state_snapshot()
		board.top_hud.position.y += 8.0
		board.set(dependency, null)
		board.call("_apply_state_derived_product_layout")
		_expect(board.duel_stage_surface.get_rect() == stage, "Invalid %s leaves stage untouched at %s." % [dependency, board.size])
		_expect(board.get("_last_applied_active_duel_rect") == baseline and board.get("_has_applied_active_duel_rect") == has_baseline, "Invalid %s preserves last successful baseline at %s." % [dependency, board.size])
		_expect(actor.motion_state == "move" and actor._motion_sequence_id == sequence and actor._motion_tween == tween and tween.is_running() and actor.position == actor_position, "Invalid %s preserves live MOVE/tween/position at %s." % [dependency, board.size])
		_expect(board.get_combat_state_snapshot() == state, "Invalid dependency must not mutate domain state.")
		board.top_hud.position = hud_position
		board.set(dependency, retained)
		board.call("_apply_state_derived_product_layout")
		_expect(board.duel_stage_surface.get_rect() == stage and actor.motion_state == "move" and actor._motion_sequence_id == sequence, "Restoring %s safely retains the successful geometry and MOVE." % dependency)
		actor.snap_move_for_relayout(board.get_character_foot_anchor("player"))

func _verify_snapshot_movement(board: CombatBoardPreview) -> void:
	# Separate presentation-fixture boundary probes; the preceding CTA above
	# supplies real resolver movement and resize/skip parity evidence.
	board._set_resolution_surface_visible(true)
	board.combat_state.player.tile = 4
	board.combat_state.enemy.tile = 6
	board._apply_combat_state_to_view()
	for _frame in range(3):
		await process_frame
	var free_actor := board.player_character
	free_actor.animate_move_to(board.get_character_foot_anchor("player") + Vector2(24, 0), 0.22)
	await create_timer(0.04).timeout
	var in_flight := free_actor.position
	board._layout_board()
	_expect(free_actor.motion_state == "move" and free_actor.position.distance_to(in_flight) < 0.1, "Routine planning layout preserves actual MOVE position even outside snapshot-defer mode.")
	await create_timer(0.24).timeout
	board._layout_board()
	board._set_resolution_surface_visible(false)
	var changed := board.get_combat_state_snapshot()
	changed.player.tile = 5
	changed.enemy.tile = 6
	var resolution_count := int(board.get_meta("resolution_count", 0))
	board._apply_timing_snapshot(changed)
	for _frame in range(3):
		await process_frame
	var actor := board.player_character
	_expect(actor.motion_state == "move", "Actual changed timing snapshot must animate towards frontal anchors.")
	var sequence := actor._motion_sequence_id
	board._layout_board()
	_expect(actor.motion_state == "move" and actor._motion_sequence_id == sequence, "Same-size direct layout must preserve in-flight MOVE.")
	board._apply_combat_state_to_view()
	await process_frame
	_expect(actor.motion_state == "move" and actor._motion_sequence_id == sequence, "Same-size deferred state layout must preserve MOVE, despite super's transient planning rect.")
	board.size += Vector2(0.005, 0.005)
	board._layout_board()
	_expect(actor.motion_state == "move" and actor._motion_sequence_id == sequence, "Sub-tolerance final geometry change must not cancel MOVE.")
	board.size += Vector2(16, 16)
	board._layout_board()
	_expect(actor.motion_state == "idle", "Real geometry change must snap only the in-flight MOVE.")
	_verify_stage(board, true)
	await create_timer(0.30).timeout
	_verify_stage(board, true)
	_expect(board.get_combat_state_snapshot() == changed and int(board.get_meta("resolution_count", 0)) == resolution_count, "Resize and original continuation cannot resolve again or alter timing domain state.")
	_expect(absf((board.get_character_foot_anchor("enemy").x - board.get_character_foot_anchor("player").x) / board.size.x - (0.27 + 0.31 / 9.0)) < 0.001, "Distance1 uses the continuous full 0 through 9 mapping.")
	changed.player.tile = 6
	board._reduced_motion = true
	await board._apply_timing_snapshot(changed)
	_expect(absf((board.get_character_foot_anchor("enemy").x - board.get_character_foot_anchor("player").x) / board.size.x - 0.27) < 0.001, "Contact uses the closest distinct actor anchors.")
	_verify_stage(board, true)

func _expect(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
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
