extends SceneTree

func _initialize() -> void: call_deferred("run_check")

func run_check() -> void:
    root.size = Vector2i(960,640)
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    assert(not shell.session.enabled, "Script UI fixture must not touch player saves")
    shell.run_state.start_new_giyun_run(99,"ui-fixture")
    shell.run_state._current_screen = "JIANGHU"
    shell.run_state.duel_index = 1
    shell.run_state.completed_duels = 1
    shell.run_state._next_opponent_id = shell.run_state._opponent_catalog.select_campaign_candidate_id(2)
    var rules = load("res://src/run/giyun_rules.gd").new()
    for item in rules.catalog.giyun: shell.run_state._giyun.owned.append(item.id)
    shell.run_state._giyun.pending_event = rules.event_for(99,1,0)
    shell._render_current_screen()
    for frame in range(8): await process_frame
    var scroll: ScrollContainer = shell._route_scroll
    assert(scroll != null and root.get_visible_rect().encloses(scroll.get_global_rect()), "Route must stay inside logical viewport")
    assert(shell.get_route_option_count() == 3, "All event choices present")
    scroll.ensure_control_visible(shell.route_options_container.get_child(2))
    for frame in range(3): await process_frame
    var last: Control = shell.route_options_container.get_child(2)
    assert(scroll.get_global_rect().encloses(last.get_global_rect()), "Last event choice reachable by scrolling")
    if DisplayServer.get_name() != "headless":
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png("res://output/blueprint/giyun-route-960x640.png")
    print("GIYUN_UI: PASS (fixture, not a played campaign)")
    shell.queue_free()
    await process_frame
    quit()
