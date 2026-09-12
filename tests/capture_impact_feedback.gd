extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 1 or not args[0].is_absolute_path():
        push_error("Provide absolute capture output directory")
        quit(1)
        return
    var output: String = args[0]
    DirAccess.make_dir_recursive_absolute(output)
    root.size = Vector2i(1280, 800)
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    for i in range(8):
        await process_frame
    var events := [
        {"type":"action_result", "actor":"player", "category":"attack", "outcome":"hit", "damage":5, "card_name":"검격"},
        {"type":"clash", "actor":"player", "outcome":"clash_win", "damage":5},
        {"type":"action_result", "actor":"enemy", "category":"attack", "outcome":"hit", "damage":5, "card_name":"상대 검격"}
    ]
    var index := 0
    var receipt: Array = []
    var images: Array[Image] = []
    for event in events:
        board._presentation_skip_requested = false
        board._present_resolved_event_feedback(event)
        for sample in range(18):
            await process_frame
            await RenderingServer.frame_post_draw
            var path := output.path_join("impact-%03d.png" % index)
            images.append(root.get_texture().get_image())
            receipt.append({"file":path.get_file(), "usec":Time.get_ticks_usec(), "event":event, "camera_offset":str(board.get_meta("impact_camera_offset", Vector2.ZERO)), "phase":board.get_meta("presentation_feedback_phase", "")})
            index += 1
        board._clear_presentation_feedback_visuals()
    # Encode after sampling: synchronous PNG compression would miss short impacts.
    for image_index in range(images.size()):
        if images[image_index].save_png(output.path_join("impact-%03d.png" % image_index)) != OK:
            push_error("Capture failed")
            quit(1)
            return
    var manifest := FileAccess.open(output.path_join("capture.json"), FileAccess.WRITE)
    manifest.store_string(JSON.stringify({"evidence":"ACTUAL_BOARD_RENDER_SEEDED_PRESENTATION_EVENTS_NOT_FULL_GAMEPLAY", "frames":receipt}, "  "))
    manifest.close()
    board.free()
    print("IMPACT_RENDER_CAPTURE_PASS frames=", index)
    quit(0)
