extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 1 or not args[0].is_absolute_path():
        quit(1)
        return
    var output: String = args[0]
    DirAccess.make_dir_recursive_absolute(output)
    root.size = Vector2i(1280, 800)
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    for i in range(8):
        await process_frame
    var move := _card(board, "basic_move")
    var quick := _card(board, "basic_quick_attack")
    if not board.action_timing_panel.place_card(move, 1):
        quit(1)
        return
    board._begin_targeting_for_anchor(1)
    board._on_board_tile_clicked(5)
    if not board.action_timing_panel.place_card(quick, 2) or not board.action_timing_panel.place_card(quick, 3) or not board.combat_progress_button.progress_enabled:
        quit(1)
        return
    var before: Dictionary = board.combat_state.duplicate(true)
    var images: Array[Image] = []
    var records: Array = []
    # Same player-facing execution command as the button, no synthetic outcomes.
    board.combat_progress_button.request_progress()
    var start := Time.get_ticks_msec()
    var last_sample := 0
    var revealed := false
    var vfx_seen := false
    while Time.get_ticks_msec() - start < 12000 and images.size() < 240:
        await process_frame
        if Time.get_ticks_msec() - last_sample < 33:
            continue
        await RenderingServer.frame_post_draw
        last_sample = Time.get_ticks_msec()
        var reveal_visible: bool = board.action_reveal_overlay.visible
        var vfx_visible: bool = board.presentation_vfx.visible and board.presentation_vfx.modulate.a > 0.05
        revealed = revealed or reveal_visible
        vfx_seen = vfx_seen or (reveal_visible and vfx_visible)
        images.append(root.get_texture().get_image())
        records.append({"file":"execution-%03d.png" % (images.size()-1), "usec":Time.get_ticks_usec(), "state":board.get_meta("presentation_state", ""), "reveal":reveal_visible, "vfx":vfx_visible, "kind":board.get_meta("presentation_feedback_kind", ""), "vfx_layout":board.get_meta("presentation_vfx_layout_status", ""), "timing":board.action_reveal_overlay.get_snapshot().get("timing", 0)})
        if revealed and str(board.get_meta("presentation_state", "")) == "next_bundle_ready":
            break
    for i in range(images.size()):
        if images[i].save_png(output.path_join(records[i].file)) != OK:
            quit(1)
            return
    var manifest := FileAccess.open(output.path_join("capture.json"), FileAccess.WRITE)
    manifest.store_string(JSON.stringify({"evidence":"ACTUAL_BOARD_EXECUTE_COMMAND_REAL_RESOLVER_DEFAULT_AI_NOT_FULL_CAMPAIGN", "before":before, "after":board.combat_state, "revealed":revealed, "vfx_seen_with_reveal":vfx_seen, "frames":records}, "  "))
    manifest.close()
    board.free()
    print("EXECUTED_COMBAT_CAPTURE reveal=", revealed, " vfx=", vfx_seen, " frames=", images.size())
    quit(0 if revealed and vfx_seen else 1)

func _card(board, id: String) -> Dictionary:
    for card in board.basic_card_tray.cards:
        if str(card.definition.get("id", "")) == id:
            return card.definition.duplicate(true)
    return {}
