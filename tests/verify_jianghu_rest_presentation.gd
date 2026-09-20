extends SceneTree

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    shell.start_new_run()
    for manual in ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]:
        shell.toggle_setup_manual(manual)
    for step in range(3):
        shell.advance_noncombat()
    # Terminal injection is a UI fixture, not evidence of a won duel.
    shell.complete_combat_for_runtime({
        "outcome": "win",
        "player_resources": {"health": [12, 40], "stamina": [2, 5], "internal": [1, 4]}
    })
    shell.complete_review_for_runtime()
    check(not shell.description_label.text.contains("다음 Phase"), "Reward copy must not falsely defer implemented progression.")
    shell.select_result_reward("free_training")
    shell.advance_noncombat()
    root.content_scale_size = Vector2i.ZERO
    for viewport in [Vector2i(960,640), Vector2i(1280,720), Vector2i(1920,1080)]:
        root.size = viewport
        for frame in range(4): await process_frame
        check(root.get_visible_rect().encloses(shell.primary_button.get_global_rect()), "Route CTA fits %s" % viewport)
        for button in shell.route_options_container.get_children():
            check(shell.content_panel.get_global_rect().encloses(button.get_global_rect()), "Route choice fits %s" % viewport)
    root.size = Vector2i(1280,720)
    for frame in range(4): await process_frame
    var capture_args := OS.get_cmdline_user_args()
    if DisplayServer.get_name() != "headless" and not capture_args.is_empty():
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(capture_args[0].get_basename() + "-choices.png")
    for step in range(2):
        var options: Array = shell.run_state.get_jianghu_options()
        var choice: Button = shell.find_child("Jianghu_" + str(options[0]["id"]), true, false)
        choice.grab_focus()
        await enter()
        check(root.gui_get_focus_owner() == shell.primary_button, "A successful route choice must focus continuation.")
        if root.gui_get_focus_owner() != shell.primary_button:
            shell.queue_free()
            await process_frame
            finish()
            return
        await enter()
        check(root.gui_get_focus_owner() == shell.route_options_container.get_child(0), "Next route step must focus its first visible choice.")
    var before_rest: Dictionary = shell.run_state.get_player_run_resources()
    check(before_rest == {"health": [12, 40], "stamina": [2, 5], "internal": [1, 4]}, "Rest fixture must reach the inn with damaged valid resources.")
    shell.menu_button.grab_focus()
    shell.set_session_paused(true)
    shell._choose_jianghu("rest", 2)
    check(root.gui_get_focus_owner() == shell.menu_button, "Rejected suspended choice must not steal focus.")
    check(shell.run_state.get_pending_jianghu().is_empty() and shell.run_state.get_player_run_resources() == before_rest, "Suspended route choice must not apply rest.")
    shell.set_session_paused(false)
    shell.find_child("Jianghu_rest", true, false).grab_focus()
    await enter()
    await process_frame
    var backdrop = shell.get_node("ShellBackdrop")
    check(backdrop.texture.resource_path == "res://assets/backgrounds/jianghu_rest_inn_v1.png", "Rest must consume the original inn illustration.")
    check(shell.content_panel.anchor_left >= 0.5, "Rest text must leave the seated traveller visible.")
    check(not shell.route_options_container.visible, "Resolved rest must not retain disabled choice cards.")
    check(not shell.primary_button.disabled, "Rest must expose a working continuation.")
    var resources: Dictionary = shell.run_state.get_player_run_resources()
    check(shell.description_label.text.contains("실제 적용") and shell.description_label.text.contains("체력 +10"), "Rest shows actual domain gain")
    for viewport in [Vector2i(960,640), Vector2i(1280,720), Vector2i(1920,1080)]:
        root.size = viewport
        for frame in range(4): await process_frame
        check(root.get_visible_rect().encloses(shell.primary_button.get_global_rect()), "Rest CTA fits %s" % viewport)
        check(shell.content_panel.get_global_rect().encloses(shell.description_label.get_global_rect()), "Rest explanation fits %s" % viewport)
    root.size = Vector2i(1280,720)
    for frame in range(4): await process_frame
    check(resources == {"health": [22, 40], "stamina": [3, 5], "internal": [2, 4]}, "One rest must heal 25% max health and restore one stamina and internal power exactly once.")
    check(resources["health"][0] < resources["health"][1], "Rest fixture health must remain below cap before duplicate input.")
    check(resources["stamina"][0] < resources["stamina"][1], "Rest fixture stamina must remain below cap before duplicate input.")
    check(resources["internal"][0] < resources["internal"][1], "Rest fixture internal power must remain below cap before duplicate input.")
    var args := OS.get_cmdline_user_args()
    if DisplayServer.get_name() != "headless" and not args.is_empty():
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(args[0])
    shell._choose_jianghu("rest", 2)
    check(shell.run_state.get_player_run_resources() == resources, "Duplicate rest must not heal again.")
    check(root.gui_get_focus_owner() == shell.primary_button, "Rest outcome must keep a usable continuation focus after rejected duplicate input.")
    await enter()
    await process_frame
    check(backdrop.texture.resource_path == "res://assets/backgrounds/jianghu_blue_ink_landscape_v1.png", "Next choice must restore the mountain route backdrop, not the duel courtyard.")
    check(is_equal_approx(shell.content_panel.anchor_left, 0.14), "Next choice must restore the full choice layout.")
    check(shell.route_options_container.visible and shell.get_route_option_count() == 3, "Next step must expose three choices.")
    var final_options: Array = shell.run_state.get_jianghu_options()
    shell._choose_jianghu(str(final_options[0]["id"]), 3)
    shell.advance_noncombat()
    check(backdrop.texture.resource_path == "res://assets/backgrounds/atlas_blue_ink_courtyard_v1.png", "Briefing must restore its own duel backdrop.")
    shell.queue_free()
    await process_frame
    await create_timer(0.1).timeout
    finish()

func enter() -> void:
    var event := InputEventKey.new()
    event.keycode = KEY_ENTER
    event.pressed = true
    root.push_input(event)
    await process_frame
    event = InputEventKey.new()
    event.keycode = KEY_ENTER
    root.push_input(event)
    await process_frame

func finish() -> void:
    for failure in failures:
        push_error(failure)
    print("JIANGHU_REST_PRESENTATION_OK" if failures.is_empty() else "JIANGHU_REST_PRESENTATION_FAILED")
    print("JIANGHU_ROUTE_FOCUS checks=", checks)
    quit(0 if failures.is_empty() else 1)

func check(value: bool, message: String) -> void:
    checks += 1
    if not value:
        failures.append(message)
