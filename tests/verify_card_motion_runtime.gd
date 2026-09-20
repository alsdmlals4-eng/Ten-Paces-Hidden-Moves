extends SceneTree

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)

func _run() -> void:
	root.size = Vector2i(1280, 800)
	var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	for i in range(5):
		await process_frame
	board._sound_muted = true
	board._fast_replay = false
	board._reduced_motion = false
	board._set_presentation_state("presenting_result")
	board._set_resolution_surface_visible(false)
	for i in range(5):
		await process_frame
	var before: Dictionary = board.combat_state.duplicate(true)
	var start: Vector2 = board.player_character.position
	var enemy_start: Vector2 = board.enemy_character.position
	var event := {"type":"clash", "actor":"player", "timing":1, "card_id":"basic_heavy_attack", "card_name":"강공", "outcome":"clash_win", "damage":3, "raw_damage":8, "clash_opponent_raw_damage":5, "defense_outcome":"hit", "actor_tile_after_action":3, "target_tile_at_action":4}
	var other := event.duplicate(true)
	other.merge({"actor":"enemy", "card_id":"basic_quick_attack", "card_name":"속공", "outcome":"clash_loss", "raw_damage":5, "clash_opponent_raw_damage":8},true)
	var cues: Array = load("res://src/ui/combat_motion_sequence.gd").compile([event,other])
	expect(board._clash_has_physical_contact(cues[0]), "Verified sword pair permits contact.")
	board._play_character_action_motion(cues[0], .30)
	await create_timer(.36).timeout
	expect(board.player_character.motion_phase == "link", "Clash winner must hold the link pose.")
	expect(board.player_character.position.distance_to(start) > 1., "Winner must not return home before its follow-through.")
	var linked_pose: int = board.player_character._pose_frame
	board._play_character_action_motion(cues[1], .30)
	expect(board.player_character._pose_frame == linked_pose, "Follow-through must not flash the idle pose.")
	await create_timer(.37).timeout
	expect(board.player_character.position.distance_to(start) < .5, "End of action restores original anchor.")
	expect(board.player_character.motion_state == "idle", "Action completes at idle.")
	# Actual production entry point, two domain records -> two distinct visual phases.
	board.call_deferred("_present_timing_duel", [event,other],1,"timing")
	await create_timer(.56).timeout
	expect(board.get_meta("motion_cues",[]).size() == 2, "Actual timing consumer uses deduplicated cues.")
	await _capture("clash-result.png")
	expect(board.range_readout_panel.is_visible_in_tree() and not board.action_reveal_overlay._versus.is_visible_in_tree(), "Public distance stays visible without decorative VS overprint.")
	await create_timer(.50).timeout
	expect(board.player_character.motion_state != "idle", "Actual playback connects clash to attack without an idle interval.")
	await _capture("follow-through.png")
	await create_timer(1.0).timeout
	expect(board.player_character.position.distance_to(start) < .5 and board.enemy_character.position.distance_to(enemy_start) < .5, "Actual consumer settles both anchors: %s -> %s / %s -> %s" % [start,board.player_character.position,enemy_start,board.enemy_character.position])
	# Skip during the held clash immediately cancels all transforms and stale tweens.
	board._play_character_action_motion(cues[0], .3)
	await create_timer(.35).timeout
	board._skip_presentation()
	expect(board.player_character.position.distance_to(start) < .5 and board.player_character.motion_state == "idle", "Skip restores held origin synchronously.")
	board._presentation_skip_requested = false
	for outcome in ["clash_win", "clash_loss", "clash_draw"]:
		var early: Dictionary = cues[0].duplicate(true)
		early.outcome = outcome
		board._play_character_action_motion(early,.9)
		await create_timer(.2).timeout
		board._skip_presentation()
		expect(board.player_character.position.distance_to(start)<.5 and board.enemy_character.position.distance_to(enemy_start)<.5, "Early skip restores both participants: "+outcome)
		board._presentation_skip_requested = false
	var ranged: Dictionary = cues[0].duplicate(true)
	ranged.card_id = "basic_palm"
	expect(not board._clash_has_physical_contact(ranged), "Energy clash cannot become sword contact.")
	board._play_character_action_motion(ranged,.3)
	await create_timer(.15).timeout
	expect(board.player_character.position.distance_to(start) < .5, "Ranged caster remains at its logical anchor.")
	board._show_feedback_vfx(ranged,"clash",.15)
	expect(not board.presentation_vfx.visible, "Unapproved energy contact never borrows metal sparks.")
	board._reset_character_choreography()
	for mode in ["reduced", "fast"]:
		board._reduced_motion = mode == "reduced"
		board._fast_replay = mode == "fast"
		await board._present_timing_duel([event,other],1,"timing")
		expect(board.player_character.motion_state == "idle" and board.player_character.position.distance_to(start)<.5, mode+" replay settles actors")
		expect(board._impact_camera_strength == 0., mode+" replay has no lingering camera")
	expect(board.combat_state == before, "All choreography is domain-state invariant.")
	board.free()
	for failure in failures:
		push_error(failure)
	print("CARD_MOTION_RUNTIME checks=%d failures=%d" % [checks,failures.size()])
	quit(0 if failures.is_empty() else 1)

func _capture(name: String) -> void:
	var directory := OS.get_environment("TEN_MOTION_CAPTURE_DIR")
	if directory.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join(name))
