extends SceneTree

var failures: Array[String] = []
func _initialize() -> void:
    call_deferred("run")

func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func run() -> void:
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    await process_frame
    var title = shell.main_title_screen
    title.configure_continue({}, "ABSENT")
    check(title.find_child("MainContinueButton", true, false).visible, "Continue stays visible without a save")
    for name in ["MainLibraryButton", "MainSettingsButton", "MainExitButton"]:
        check(title.find_child(name, true, false) != null, "Working main menu entry: " + name)
    if title.has_method("_open_front_page"):
        title._open_front_page("MainLibraryButton")
        await process_frame
        var library = title._front_page
        check(library.grid.get_child_count() == 10 and library.illustration.texture != null, "Codex opens ten illustrated basic actions")
        library._show_manuals()
        check(library.grid.get_child_count() == 10 and library.illustration.texture != null, "Codex switches to all ten manual entries")
        var escape := InputEventKey.new()
        escape.keycode = KEY_ESCAPE
        escape.pressed = true
        library._unhandled_key_input(escape)
        await process_frame
        check(not is_instance_valid(title._front_page), "Escape closes codex without using a detached viewport")
        var path := "user://feedback-preferences-%d.cfg" % OS.get_process_id()
        title.preferences = load("res://src/ui/ink/ink_preferences.gd").new(path)
        title._open_front_page("MainSettingsButton")
        await process_frame
        var settings = title._front_page
        settings.find_child("Setting_reduced_motion", true, false).button_pressed = true
        settings.find_child("Setting_volume", true, false).value = 0.25
        var saved = load("res://src/ui/ink/ink_preferences.gd").new(path)
        check(saved.values.reduced_motion and is_equal_approx(saved.values.volume, 0.25), "Settings controls save and reload their own preferences")
        check(saved.values.sound and not saved.values.fast_replay, "Changing motion preference cannot change another setting")
        settings._unhandled_key_input(escape)
        await process_frame
        check(not is_instance_valid(title._front_page), "Escape closes settings without using a detached viewport")
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    shell.run_state.start_new_giyun_run(20260820, "legacy-ink-feedback-fixture")
    for button in shell._setup_buttons.values():
        var art = button.find_child("ManualIllustration", true, false)
        check(art != null and art.texture != null, "Each starter choice has approved illustration")
    var ids: Array = shell._setup_buttons.keys()
    for i in range(4): check(shell._set_setup_manual_selected(ids[i], true), "Four illustrated choices retain selection")
    check(not shell._set_setup_manual_selected(ids[4], true), "Fifth choice remains rejected")
    for i in range(3): shell.advance_noncombat()
    await process_frame
    var board = shell._combat_view
    if is_instance_valid(board):
        check(board._reduced_motion and is_equal_approx(board._sound_volume,0.25), "Next combat actually consumes selected preferences")
        board.size = Vector2(1280,720)
        board._layout_board()
        var p: Vector2 = board._presentation_anchor_for_actor("player")
        var e: Vector2 = board._presentation_anchor_for_actor("enemy")
        check(p.x < e.x and p.y > e.y + 15, "Preparation has foreground player and distant enemy")
        check(board.player_character.size.y > board.enemy_character.size.y * 1.15, "Perspective separates actor scale")
        check(board.observation_reveal_panel.get_rect().end.y <= board.action_selection_dock.position.y, "Observation lives beside confrontation above action dock")
        board.action_selection_dock.basic_panel.buttons[2].emit_signal("pressed")
        await process_frame
        var placed = board.find_child("LinkedActionBlock01", true, false)
        check(placed != null and placed.action_label.get_theme_color("font_color").get_luminance() < 0.2, "Placed action stays legible against the new parchment planning strip")
    shell.queue_free()
    await process_frame
    for message in failures: push_error(message)
    print("INK_FEEDBACK: %s (%d failures)" % ["PASS" if failures.is_empty() else "FAIL", failures.size()])
    quit(0 if failures.is_empty() else 1)
