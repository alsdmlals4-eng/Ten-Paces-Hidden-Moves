extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    for i in range(6):
        await process_frame
    for panel in [board.top_hud.player_panel, board.top_hud.enemy_panel]:
        var name_rect: Rect2 = panel._name_label.get_rect()
        if name_rect.position.y < 16.0 or name_rect.end.y > panel._health_label.position.y:
            push_error("HUD_NAME_CROSSES_DECORATIVE_FRAME_OR_HEALTH")
            board.free()
            quit(1)
            return
        var portrait = panel.get_node("CombatantInkPortrait")
        if not portrait.visible or portrait.texture == null:
            push_error("CURRENT_BATTLER_PORTRAIT_MISSING")
            board.free()
            quit(1)
            return
        for rect in panel.get_resource_layout_snapshot().label_rects:
            if portrait.get_rect().intersects(rect):
                push_error("PORTRAIT_COVERS_RESOURCE_TEXT")
                board.free()
                quit(1)
                return
    if board.top_hud.enemy_panel.get_visible_resource_ratio("health") != -1.0:
        push_error("PORTRAIT_HUD_LEAKED_PRIVATE_RESOURCE")
        board.free()
        quit(1)
        return
    board.free()
    print("PORTRAIT_HUD_PASS")
    quit(0)
