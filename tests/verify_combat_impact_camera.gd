extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    await process_frame
    if not board.reduced_motion_button.is_visible_in_tree():
        push_error("MOTION_OPTION_NOT_REACHABLE")
        board.free()
        quit(1)
        return
    if not board.has_method("_start_impact_camera"):
        push_error("IMPACT_CAMERA_MISSING")
        board.free()
        quit(1)
        return
    var before: Dictionary = board.combat_state.duplicate(true)
    var hud_position: Vector2 = board.top_hud.position
    var target_position: Vector2 = board.player_character.position
    var hit := {"type": "action_result", "actor": "player", "category": "attack", "damage": 5}
    if not board.player_character.has_method("hold_impact_pose"):
        push_error("LOCAL_IMPACT_HOLD_MISSING")
        board.free()
        quit(1)
        return
    board.player_character.play_attack_motion(0.3)
    board.player_character.hold_impact_pose(0.06)
    var pose_time: float = board.player_character._pose_elapsed
    board.player_character._process(0.02)
    assert(board.player_character._pose_elapsed == pose_time, "Hold must freeze source frames")
    assert(not board.player_character._motion_tween.is_running(), "Hold must freeze visual tween")
    assert(Engine.time_scale == 1.0 and not root.get_tree().paused, "Hold is local, not global pause")
    board.player_character.release_impact_pose()
    assert(board.player_character._motion_tween.is_running(), "Release resumes motion")
    board._show_presentation_impact(hit, "attack", 0.20)
    board._process(0.02)
    assert(board.get_meta("impact_camera_offset", Vector2.ZERO).length() > 0.1, "Real impact consumer must start camera feedback")
    assert(board.top_hud.position == hud_position, "HUD must not shake")
    assert(board.player_character.position == target_position, "Camera must not mutate actor placement")
    assert(board.combat_state == before, "Camera must not mutate combat state")
    board._skip_presentation()
    assert(board.get_meta("impact_camera_offset") == Vector2.ZERO, "Skip must clear camera")
    board._presentation_skip_requested = false
    for event in [{"outcome":"evaded", "damage":0}, {"action_stage":"preparation", "damage":5}, {"outcome":"miss_range", "damage":0}]:
        board._start_impact_camera(event, "attack")
        board._process(0.02)
        assert(board.get_meta("impact_camera_offset") == Vector2.ZERO, "No false contact")
    board._reduced_motion = true
    board._start_impact_camera(hit, "attack")
    board._process(0.02)
    assert(board.get_meta("impact_camera_offset") == Vector2.ZERO, "Reduced motion disables shake")
    board._reduced_motion = false
    board._play_clash_motion(0.34)
    board.player_character._motion_tween.custom_step(0.34 * 0.38)
    board.enemy_character._motion_tween.custom_step(0.34 * 0.38)
    var contact_gap: float = board.enemy_character.get_foot_anchor_global().x - board.player_character.get_foot_anchor_global().x
    if contact_gap < minf(board.player_character.size.x, board.enemy_character.size.x) * 0.8:
        push_error("CLASH_BODIES_COLLAPSE_AT_CONTACT")
        board.free()
        quit(1)
        return
    board._start_impact_camera(hit, "attack")
    board._process(1.0)
    assert(board.get_meta("impact_camera_offset") == Vector2.ZERO, "Camera must settle exactly")
    board.free()
    print("COMBAT_IMPACT_CAMERA_PASS")
    quit(0)
