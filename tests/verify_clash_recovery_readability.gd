extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(1280, 800)
	var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	for i in range(5):
		await process_frame
	var before: Dictionary = board.combat_state.duplicate(true)
	var event := {"type":"clash", "actor":"player", "card_id":"basic_quick_attack", "outcome":"clash_win", "damage":3}
	if board._effective_event_presentation_duration(event) < 0.7:
		push_error("CLASH_RECOVERY_TOO_FAST_TO_READ")
		quit(1)
		return
	for actor in ["player", "enemy"]:
		event.actor = actor
		var player_start: Vector2 = board.player_character.position
		var enemy_start: Vector2 = board.enemy_character.position
		board._play_character_action_motion(event, 0.9)
		var winner = board.player_character if actor == "player" else board.enemy_character
		var loser = board.enemy_character if actor == "player" else board.player_character
		if winner.get_meta("clash_role", "") != "win" or loser.get_meta("clash_role", "") != "loss":
			push_error("CLASH_ROLES_NOT_SEPARATED")
			quit(1)
			return
		await create_timer(0.55).timeout
		if winner.motion_phase == loser.motion_phase or loser.visual_scale >= winner.visual_scale:
			push_error("CLASH_RECOVERY_HAS_IDENTICAL_REACTIONS")
			quit(1)
			return
		await create_timer(0.48).timeout
		assert(board.player_character.position.distance_to(player_start) < 0.5)
		assert(board.enemy_character.position.distance_to(enemy_start) < 0.5)
		assert(winner.motion_state == "idle" and loser.motion_state == "idle")
	assert(board.combat_state == before, "Presentation must not move logical tiles or apply damage")
	board.free()
	print("CLASH_RECOVERY_READABILITY_PASS")
	quit(0)
