extends SceneTree

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
    if not FileAccess.file_exists("res://src/ui/game_menu.gd"):
        printerr("GAME_MENU FAIL: player-accessible menu is missing")
        quit(1)
        return
    create_timer(90.0).timeout.connect(func(): printerr("GAME_MENU TIMEOUT"); quit(1))
    call_deferred("verify")

func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok: failures.append(label)

func key(code: Key, echo := false) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    event.echo = echo
    Input.parse_input_event(event)
    await process_frame
    event = InputEventKey.new()
    event.keycode = code
    event.pressed = false
    Input.parse_input_event(event)
    await process_frame

func verify() -> void:
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    var start: Button = shell.main_title_screen.find_child("MainStartButton", true, false)
    start.grab_focus()
    await key(KEY_ESCAPE)
    var menu = shell.game_menu
    check(menu.visible and paused and shell.session.suspended, "Esc opens menu and pauses isolated shell")
    check(start.disabled, "background action disabled")
    check(not shell.start_new_run(), "paused command gate rejects domain change")
    await key(KEY_ESCAPE, true)
    check(menu.visible, "key repeat does not close menu")
    menu.mute_button.grab_focus()
    await key(KEY_ENTER)
    menu.motion_button.grab_focus()
    await key(KEY_ENTER)
    menu.volume_slider.grab_focus()
    await key(KEY_LEFT)
    check(shell.presentation_preferences.sound_muted and shell.presentation_preferences.reduced_motion, "title preferences editable")
    check(is_equal_approx(shell.presentation_preferences.sound_volume, 0.6), "title volume editable")
    menu.guide_button.grab_focus()
    await key(KEY_ENTER)
    check(menu.guide_scroll.visible, "optional guide opens")
    check(menu.guide_label.text.contains("3수") and menu.guide_label.text.contains("4수") and menu.guide_label.text.contains("밀착"), "guide explains existing core")
    check(menu.guide_label.text.contains("확정 전") and menu.guide_label.text.contains("공개"), "guide explains save and information boundaries")
    for viewport in [Vector2i(1280, 720), Vector2i(1440, 900), Vector2i(1920, 1080)]:
        root.content_scale_size = viewport
        root.size = viewport
        for i in range(4): await process_frame
        var bounds := Rect2(Vector2.ZERO, Vector2(viewport))
        check(bounds.encloses(menu.panel.get_global_rect()), "menu stays in viewport %s" % str(viewport))
        for control in [menu.mute_button, menu.motion_button, menu.volume_slider, menu.guide_button, menu.guide_scroll, menu.resume_button]:
            check(menu.panel.get_global_rect().encloses(control.get_global_rect()), "menu control fits %s %s" % [control.name, str(viewport)])
        check(menu.guide_scroll.size.y >= 80, "guide keeps readable scroll area")
        if DisplayServer.get_name() != "headless" and not OS.get_cmdline_user_args().is_empty():
            await RenderingServer.frame_post_draw
            var output_dir := OS.get_cmdline_user_args()[0]
            DirAccess.make_dir_recursive_absolute(output_dir)
            root.get_texture().get_image().save_png(output_dir.path_join("game-menu-%dx%d.png" % [viewport.x, viewport.y]))
    for i in range(12):
        await key(KEY_TAB)
        check(menu.is_ancestor_of(root.gui_get_focus_owner()), "focus stays inside menu")
    await key(KEY_ESCAPE)
    check(not menu.visible and not paused and not shell.session.suspended, "Esc closes and resumes")
    check(root.gui_get_focus_owner() == start, "title focus restored")
    check(shell.start_new_run(), "new run after closing menu")
    shell._setup_selected_manual_ids.assign(["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"])
    check(shell.advance_noncombat() and shell.advance_noncombat() and shell.advance_noncombat(), "enter first combat")
    var board = shell._combat_view
    check(board._sound_muted and board._reduced_motion and is_equal_approx(board._sound_volume, 0.6), "title settings reach first combat")
    var before: Dictionary = board.combat_state.duplicate(true)
    var run_before: Dictionary = shell.run_state.export_snapshot().duplicate(true)
    shell.menu_button.grab_focus()
    await key(KEY_ENTER)
    check(menu.visible and board.session_suspended, "native menu button pauses combat")
    for i in range(5): await process_frame
    check(board.combat_state == before and shell.run_state.export_snapshot() == run_before, "paused frames preserve combat and run")
    menu.mute_button.grab_focus()
    await key(KEY_ENTER)
    menu.motion_button.grab_focus()
    await key(KEY_ENTER)
    await key(KEY_ESCAPE)
    check(not board._sound_muted and not board._reduced_motion, "menu preferences apply to existing board before resume")
    check(board.sound_toggle_button.text == "소리: 켬" and board.reduced_motion_button.text == "모션 감소: 끔", "combat controls agree after menu")
    check(board.combat_state == before and shell.run_state.export_snapshot() == run_before, "menu does not change domain")
    # Closing an explicit menu must not override a simultaneous application suspension.
    shell.toggle_game_menu()
    shell._application_suspended = true
    shell._update_session_suspension()
    shell.close_game_menu()
    check(paused and shell.session.suspended, "application suspension survives menu close")
    shell._application_suspended = false
    shell._update_session_suspension()
    check(not paused, "focus return resumes after menu has closed")
    shell.presentation_preferences.configure("user://missing-menu-test-%s/settings.cfg" % Time.get_ticks_usec())
    shell.toggle_game_menu()
    menu.mute_button.grab_focus()
    await key(KEY_ENTER)
    check(menu.status_label.text.contains("저장 실패") and board._sound_muted, "failed disk write stays usable and visible: text=%s muted=%s focus=%s" % [menu.status_label.text, board._sound_muted, root.gui_get_focus_owner()])
    check(board.combat_state == before and shell.run_state.export_snapshot() == run_before, "write failure preserves domain")
    # Free while the menu owns pause; later scenes must remain usable.
    shell.queue_free()
    await process_frame
    check(not paused, "closing shell does not leave tree paused")
    print("GAME_MENU ", "PASS" if failures.is_empty() else "FAIL", " checks=", checks, " failures=", failures)
    quit(0 if failures.is_empty() else 1)
