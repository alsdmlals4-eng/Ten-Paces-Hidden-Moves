extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 1 or not args[0].is_absolute_path():
        quit(1)
        return
    DirAccess.make_dir_recursive_absolute(args[0])
    root.size = Vector2i(1280, 800)
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    for i in range(8):
        await process_frame
    var dock = board.action_selection_dock
    for card in board.basic_card_tray.cards:
        if str(card.definition.get("id", "")) == "basic_quick_attack":
            dock.request_detail(card.definition, true)
            break
    for i in range(8):
        await process_frame
    await RenderingServer.frame_post_draw
    var error := root.get_texture().get_image().save_png(args[0].path_join("preparation-basic.png"))
    dock.set_active_source("martial")
    for i in range(8):
        await process_frame
    await RenderingServer.frame_post_draw
    error = maxi(error, root.get_texture().get_image().save_png(args[0].path_join("preparation-martial.png")))
    dock.set_active_source("basic")
    var wanted := ["basic_quick_attack", "basic_guard", "basic_evade"]
    for index in range(wanted.size()):
        for card in board.basic_card_tray.cards:
            if str(card.definition.get("id", "")) == wanted[index]:
                board.action_timing_panel.place_card(card.definition, index + 1)
                break
    for i in range(8):
        await process_frame
    await RenderingServer.frame_post_draw
    error = maxi(error, root.get_texture().get_image().save_png(args[0].path_join("preparation-plan.png")))
    board.free()
    print("PREPARATION_CAPTURE ", error)
    quit(0 if error == OK else 1)
