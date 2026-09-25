extends SceneTree

func _initialize() -> void:
    call_deferred("capture")
func capture() -> void:
    DirAccess.make_dir_recursive_absolute("res://output/prep-layout")
    root.content_scale_size = Vector2i.ZERO
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    board.theme = load("res://src/ui/ink/ink_screen_art.gd").theme()
    root.add_child(board)
    for resolution in [Vector2i(1280,800), Vector2i(1280,720), Vector2i(960,640), Vector2i(1920,1080)]:
        root.size = resolution
        await create_timer(0.35).timeout
        board._layout_board()
        await process_frame
        await RenderingServer.frame_post_draw
        var result := root.get_texture().get_image().save_png("res://output/prep-layout/preparation-%dx%d.png" % [resolution.x,resolution.y])
        assert(result == OK)
    root.size = Vector2i(1280,800)
    await create_timer(0.2).timeout
    var card: Dictionary = board.resolution_engine.get_actor_card_definition("basic_guard", "player")
    board.action_selection_dock.request_action(card)
    await create_timer(0.2).timeout
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("res://output/prep-layout/preparation-placed.png")
    board.queue_free()
    await process_frame
    print("PREPARATION_CAPTURE_PASS")
    quit()
