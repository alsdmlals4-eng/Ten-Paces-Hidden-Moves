extends SceneTree
var checks := 0
var failures: Array[String] = []
func check(ok: bool, label: String) -> bool:
    checks += 1
    if not ok: failures.append(label); push_error(label)
    return ok
func _initialize() -> void:
    create_timer(90).timeout.connect(func(): quit(1))
    call_deferred("_run")
func key(code: Key) -> void:
    var e := InputEventKey.new()
    e.keycode = code
    e.pressed = true
    Input.parse_input_event(e)
    await process_frame
    e = InputEventKey.new()
    e.keycode = code
    Input.parse_input_event(e)
    await process_frame
func _run() -> void:
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    check(shell.start_new_run() and shell.run_state.is_stat_growth_run(), "actual title selects v4")
    var ids: Array = shell.starter_manual_catalog.STARTER_MANUAL_IDS.slice(0,4)
    for id in ids:
        shell._setup_buttons[id].grab_focus()
        await key(KEY_ENTER)
    var panel = shell.starting_stats_panel
    check(shell.get_setup_selected_manual_ids() == ids and not shell.primary_button.disabled, "keyboard selects starters with recommended allocation")
    var before: Dictionary = shell.run_state.export_snapshot()
    var selected_key := ""
    for stat in panel.rows:
        if not panel.rows[stat].minus.disabled: selected_key = stat; break
    panel.rows[selected_key].minus.grab_focus()
    await key(KEY_ENTER)
    check(shell.primary_button.disabled and not shell.advance_noncombat(), "unspent point blocks both button and command")
    check(shell.run_state.export_snapshot() == before, "draft edits never mutate durable setup")
    panel.rows[selected_key].plus.grab_focus()
    await key(KEY_ENTER)
    check(not shell.primary_button.disabled, "spent sixth point restores start")
    for viewport in [Vector2i(1280,720),Vector2i(1920,1080)]:
        root.content_scale_size = viewport
        root.size = viewport
        for i in range(5): await process_frame
        var bounds := Rect2(Vector2.ZERO,Vector2(viewport))
        for control in [shell.content_panel,panel.get_parent(),shell.primary_button,panel.recommend]:
            check(bounds.encloses(control.get_global_rect()), "setup stays on screen " + control.name)
        check(shell.content_panel.get_global_rect().encloses(shell.primary_button.get_global_rect()), "continue stays within content")
        panel.get_parent().ensure_control_visible(panel.get_node("StatEffects"))
        for i in range(3): await process_frame
        check(panel.get_parent().get_global_rect().intersects(panel.get_node("StatEffects").get_global_rect()), "stat effects reachable by scrolling")
        panel.get_parent().scroll_vertical = 0
    root.content_scale_size = Vector2i(1280,720)
    root.size = Vector2i(1280,720)
    for i in range(4): await process_frame
    var args := OS.get_cmdline_user_args()
    if DisplayServer.get_name() != "headless" and args.size() >= 2 and args[0] == "--capture":
        await RenderingServer.frame_post_draw
        check(root.get_texture().get_image().save_png(args[1]) == OK, "native setup capture")
    if "--hold" in args: await create_timer(45).timeout
    check(shell.advance_noncombat() and shell.advance_noncombat() and shell.advance_noncombat(), "actual setup through combat")
    var bridge = shell._combat_view
    check(bridge.combat_state.player.stats == shell.run_state.get_player_growth_stats(),"runtime actor matches selected stats")
    var codec = load("res://src/run/run_checkpoint_codec.gd").new()
    var checkpoint: Dictionary = bridge.get_last_stable_checkpoint()
    check(codec.validate_payload(shell.run_state.export_snapshot(),checkpoint).ok,"growth combat checkpoint validates")
    var tampered: Dictionary = checkpoint.duplicate(true)
    tampered.binding.player_growth_stats.external += 1
    check(not codec.validate_payload(shell.run_state.export_snapshot(),tampered).ok,"cannot forge permanent growth in combat binding")
    tampered = checkpoint.duplicate(true)
    tampered.binding.erase("player_growth_stats")
    check(not codec.validate_payload(shell.run_state.export_snapshot(),tampered).ok,"v4 requires growth binding")
    tampered = checkpoint.duplicate(true)
    tampered.state.player.stats.external = 999
    check(not codec.validate_payload(shell.run_state.export_snapshot(),tampered).ok,"reject forged actual actor stats even with honest binding")
    var prior: Dictionary = bridge.combat_state.duplicate(true)
    var restored: Dictionary = bridge.restore_combat_checkpoint(checkpoint)
    check(restored.ok and bridge.combat_state.player.stats == prior.player.stats,"restore combat without another stat grant: " + str(restored))
    shell.queue_free()
    await process_frame
    print("PLAYER_GROWTH_UI checks=%d failures=%d" % [checks,failures.size()])
    quit(0 if failures.is_empty() else 1)
