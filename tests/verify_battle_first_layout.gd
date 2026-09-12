extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for viewport_size in [Vector2(1280, 720), Vector2(1280, 800), Vector2(1920, 1080)]:
        var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
        board.set_anchors_preset(Control.PRESET_TOP_LEFT)
        root.add_child(board)
        board.size = viewport_size
        for i in range(5):
            await process_frame
        var stage: Rect2 = board.get_duel_stage_rect()
        for timing_index in board.action_timing_panel.get_visible_timing_indices():
            var slot = board.action_timing_panel.get_slot(timing_index)
            if slot.position.y + slot.size.y > board.action_timing_panel.size.y:
                push_error("TIMING_SLOT_CLIPPED")
                quit(1)
                return
        if stage.size.y < viewport_size.y * 0.55:
            push_error("BATTLE_NOT_PRIMARY: stage ratio %s" % (stage.size.y / viewport_size.y))
            quit(1)
            return
        if board.player_character.size.y < viewport_size.y * 0.26:
            push_error("BATTLER_TOO_SMALL")
            quit(1)
            return
        if board.action_selection_dock.position.y + board.action_selection_dock.size.y > viewport_size.y + 1:
            push_error("ACTION_DOCK_OUTSIDE_VIEWPORT")
            quit(1)
            return
        board.free()
    print("BATTLE_FIRST_LAYOUT_PASS")
    quit(0)
