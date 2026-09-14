extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    root.size = Vector2i(1280, 800)
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    await process_frame
    board._set_presentation_state("presenting_result")
    board._set_resolution_surface_visible(false)
    await process_frame
    board._place_feedback_vfx({"actor":"player"}, "clash")
    var center: Vector2 = board.presentation_vfx.position + board.presentation_vfx.size * 0.5
    var feet: float = board.player_character.get_foot_anchor_global().y
    if center.y > feet - board.player_character.size.y * 0.45:
        push_error("VFX_IS_AT_FEET_NOT_WEAPON_CONTACT")
        board.free()
        quit(1)
        return
    if board.action_reveal_overlay.find_child("ActionIllustration", true, false) == null:
        push_error("REVEAL_CARD_ILLUSTRATION_MISSING")
        board.free()
        quit(1)
        return
    board.free()
    print("EXECUTION_VISUAL_CONTRACT_PASS")
    quit(0)
