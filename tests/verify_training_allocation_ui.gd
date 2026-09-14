extends SceneTree
var failures: Array[String] = []
var checks := 0

func check(value: bool, label: String) -> bool:
    checks += 1
    if not value: failures.append(label); push_error(label)
    return value

func _initialize() -> void:
    create_timer(90).timeout.connect(func(): printerr("TRAINING_UI_TIMEOUT"); quit(1))
    call_deferred("_run")

func key(code: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    Input.parse_input_event(event)
    await process_frame
    event = InputEventKey.new()
    event.keycode = code
    Input.parse_input_event(event)
    await process_frame

func _run() -> void:
    if not check(FileAccess.file_exists("res://src/ui/training_allocation_panel.gd"), "training has actual player panel"):
        print("TRAINING_UI checks=%d failures=%d" % [checks,failures.size()]); quit(1); return
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    check(shell.start_new_run(), "title starts new run")
    check(shell.run_state.is_growth_run(), "title uses new growth contract")
    var ids: Array = load("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0,4)
    shell._setup_selected_manual_ids.assign(ids)
    check(shell.advance_noncombat() and shell.advance_noncombat() and shell.advance_noncombat(), "first combat")
    check(shell.run_state.mark_combat_finished({"outcome":"win","player_health":30,"enemy_health":0,"player_resources":shell.run_state.get_player_run_resources()}), "synthetic accounting terminal")
    check(shell.run_state.advance(), "result")
    var reward: Dictionary = load("res://src/run/vertical_slice_result_model.gd").new().build_reward_receipt("free_training", "", ids, shell.run_state.get_current_opponent())
    check(shell.run_state.set_pending_result_reward(reward) and shell.run_state.advance(), "reward to route")
    shell._publish_session_screen()
    await process_frame
    var before: Dictionary = shell.run_state.export_snapshot()
    shell.training_button.grab_focus()
    await key(KEY_ENTER)
    var panel = shell.training_panel
    check(panel.visible and shell.primary_button.disabled, "native entry blocks background")
    var row: Dictionary = panel.manual_rows[ids[0]]
    row.plus.grab_focus()
    await key(KEY_ENTER)
    await key(KEY_ENTER)
    check(panel.allocations[ids[0]] == 2, "native plus allocation")
    check(shell.run_state.export_snapshot() == before, "draft does not mutate run")
    check(row.status.text.contains("4성"), "preview shows fourth star")
    await key(KEY_ESCAPE)
    check(not panel.visible and shell.run_state.export_snapshot() == before, "Esc cancels without spending")
    shell.training_button.grab_focus()
    await key(KEY_ENTER)
    row = panel.manual_rows[ids[0]]
    row.next.grab_focus()
    await key(KEY_ENTER)
    check(panel.allocations[ids[0]] == 2, "domain next-star amount")
    for viewport in [Vector2i(1280,720),Vector2i(1920,1080)]:
        root.content_scale_size = viewport
        root.size = viewport
        for i in range(4): await process_frame
        check(Rect2(Vector2.ZERO,Vector2(viewport)).encloses(panel.panel.get_global_rect()), "panel within viewport")
        for control in [panel.scroll,panel.apply_button,panel.cancel_button]:
            check(panel.panel.get_global_rect().encloses(control.get_global_rect()), "control stays in panel " + control.name)
    for i in range(18):
        await key(KEY_TAB)
        check(panel.is_ancestor_of(root.gui_get_focus_owner()), "focus stays in allocation panel")
    panel.apply_button.grab_focus()
    await key(KEY_ENTER)
    check(not panel.visible, "apply closes draft")
    var progress: Dictionary = shell.run_state.get_progression_snapshot()
    check(progress.free_training_pool == 4 and progress.mastery_by_manual[ids[0]] == 4, "actual applied growth")
    check(shell.run_state.validate_snapshot(shell.run_state.export_snapshot()).ok, "UI transaction preserves valid ledger")
    check(shell.run_state.route_visits == before.route_visits and shell.run_state.completed_duels == before.completed_duels, "management does not spend route or duel")
    for step in range(4):
        var options: Array = shell.run_state.get_jianghu_options()
        var selected: String = options[0].id
        for preferred in ["training","event","investigate"]:
            if options.any(func(option): return option.id == preferred):
                selected = preferred
                break
        check(shell.run_state.select_jianghu_node(selected,step) and shell.run_state.advance(), "legitimate route accrual")
    shell._publish_session_screen()
    shell.training_button.grab_focus()
    await key(KEY_ENTER)
    row = panel.manual_rows[ids[0]]
    row.next.grab_focus()
    for i in range(3): await key(KEY_ENTER)
    check(panel.allocations.get(ids[0]) == 12 and row.status.text.contains("7성"), "next-star draft reaches actual new technique tier")
    var args := OS.get_cmdline_user_args()
    if DisplayServer.get_name() != "headless" and args.size() >= 2 and args[0] == "--capture":
        root.content_scale_size = Vector2i(1280,720)
        root.size = Vector2i(1280,720)
        for i in range(4): await process_frame
        await RenderingServer.frame_post_draw
        check(root.get_texture().get_image().save_png(args[1]) == OK, "capture real training screen")
    panel.apply_button.grab_focus()
    await key(KEY_ENTER)
    check(shell.advance_noncombat(), "trained next combat")
    var bridge = shell._combat_view
    var card_id: String = shell.manual_registry.get_manual(ids[0]).cards.star7.id
    var dock = bridge.action_selection_dock
    dock.martial_tab.grab_focus()
    await key(KEY_ENTER)
    var technique: Button
    for button in dock.find_children("*","Button",true,false):
        if button.is_visible_in_tree() and button.get_meta("action_id","") == card_id: technique = button; break
    if check(technique != null and not technique.disabled, "trained seventh-star technique actually selectable"):
        technique.grab_focus()
        await key(KEY_ENTER)
        var placed: Dictionary = bridge.action_timing_panel.get_placement(1)
        check(placed.get("card_id") == card_id, "native input places newly unlocked technique")
        if not placed.get("target_ready",true):
            dock.action_intent_panel.intent_buttons[0].grab_focus()
            await key(KEY_ENTER)
        dock.basic_tab.grab_focus()
        await key(KEY_ENTER)
        for slot in range(1,4):
            if not bridge.action_timing_panel.get_placement(slot).is_empty(): continue
            for button in dock.find_children("*","Button",true,false):
                if button.is_visible_in_tree() and button.get_meta("action_id","") == "basic_guard":
                    button.grab_focus(); await key(KEY_ENTER); break
        var count: int = bridge.get_meta("resolution_count",0)
        bridge.combat_progress_button._button.grab_focus()
        await key(KEY_ENTER)
        check(int(bridge.get_meta("resolution_count",0)) == count+1, "newly unlocked plan reaches actual resolver")
        var deadline := Time.get_ticks_msec()+15000
        while bridge._presentation_state not in ["next_bundle_ready","terminal_result_ready"] and Time.get_ticks_msec()<deadline: await process_frame
        check(bridge._presentation_state in ["next_bundle_ready","terminal_result_ready"], "new technique presentation finishes")
        check(load("res://src/run/run_checkpoint_codec.gd").new().validate_payload(shell.run_state.export_snapshot(),bridge.get_last_stable_checkpoint()).ok, "grown combat checkpoint remains valid")
    shell.queue_free()
    await process_frame
    print("TRAINING_UI checks=%d failures=%d" % [checks,failures.size()])
    quit(0 if failures.is_empty() else 1)
