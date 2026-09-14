extends SceneTree

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
    create_timer(80.0).timeout.connect(func(): printerr("PREFERENCES_RUNTIME TIMEOUT"); quit(1))
    call_deferred("verify")

func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok: failures.append(label)

func key(control: Control, code: Key) -> void:
    control.grab_focus()
    await process_frame
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    Input.parse_input_event(event)
    await process_frame
    event = InputEventKey.new()
    event.keycode = code
    event.pressed = false
    Input.parse_input_event(event)
    await process_frame

func check_board(board) -> void:
    check(board._sound_muted and board._reduced_motion, "flags restored before first action")
    check(is_equal_approx(board._sound_volume, 0.25), "volume restored")
    check(board.sound_toggle_button.text == "소리: 끔" and board.reduced_motion_button.text == "모션 감소: 켬", "initial control labels agree")
    check(is_equal_approx(board.sound_volume_slider.value, 0.25), "initial slider agrees")
    check(is_equal_approx(board.procedural_sfx_player.volume_linear, 0.25) and is_equal_approx(board.momentum_sfx_player.volume_linear, 0.25), "both sound channels initialized")
    check(not board.procedural_sfx_player.playing and not board.momentum_sfx_player.playing, "no startup sound while muted")

func start_combat(shell) -> void:
    check(shell.start_new_run(), "new run")
    shell._setup_selected_manual_ids.assign(["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"])
    check(shell.advance_noncombat() and shell.advance_noncombat() and shell.advance_noncombat(), "setup to combat")
    await process_frame

func verify() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 2 or args[0] not in ["write", "read"]:
        printerr("PREFERENCES_RUNTIME requires write/read and isolated settings path")
        quit(1)
        return
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    shell.configure_presentation_storage(args[1])
    root.add_child(shell)
    await process_frame
    check(not shell.session.enabled, "run persistence remains isolated")
    await start_combat(shell)
    var board = shell._combat_view
    if args[0] == "write":
        var before: Dictionary = shell.run_state.export_snapshot().duplicate(true)
        var combat_before: Dictionary = board.combat_state.duplicate(true)
        await key(board.sound_toggle_button, KEY_ENTER)
        await key(board.reduced_motion_button, KEY_ENTER)
        for i in range(8): await key(board.sound_volume_slider, KEY_LEFT)
        check(board.combat_state == combat_before and shell.run_state.export_snapshot() == before, "native preference controls leave run and combat unchanged")
        check(FileAccess.file_exists(args[1]), "controls persist to isolated disk")
    check_board(board)
    if DisplayServer.get_name() != "headless":
        await process_frame
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(args[1].get_base_dir().path_join("preferences-restored.png"))
    shell._discard_combat_view()
    shell._ensure_combat_view()
    check_board(shell._combat_view)
    shell.queue_free()
    await process_frame
    # Returning to the application title constructs a fresh shell.
    shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    shell.configure_presentation_storage(args[1])
    root.add_child(shell)
    await process_frame
    check(shell.run_state.get_current_screen() == "MAIN", "fresh title")
    await start_combat(shell)
    check_board(shell._combat_view)
    shell.queue_free()
    await process_frame
    print("PREFERENCES_RUNTIME ", "PASS" if failures.is_empty() else "FAIL", " mode=", args[0], " checks=", checks, " failures=", failures)
    quit(0 if failures.is_empty() else 1)
