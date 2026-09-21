extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
    create_timer(60).timeout.connect(func(): push_error("FEEDBACK_UI_TIMEOUT"); quit(1))
    call_deferred("run")
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
func capture(file: String) -> void:
    for i in range(4): await process_frame
    var directory := OS.get_environment("TEN_FEEDBACK_CAPTURE_DIR")
    if not directory.is_empty() and DisplayServer.get_name() != "headless":
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(directory.path_join(file))
func run() -> void:
    root.size = Vector2i(1280,800)
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await capture("title.png")
    shell.main_title_screen.get_node("MainSettingsButton").grab_focus()
    await key(KEY_ENTER)
    if not shell.game_menu.visible: failures.append("Title settings does not open")
    shell.close_game_menu()
    for i in range(3): await process_frame
    shell.main_title_screen.get_node("MainStartButton").grab_focus()
    await key(KEY_ENTER)
    if shell.run_state.get_current_screen() != shell.run_state.SCREEN_SETUP: failures.append("New journey did not reach setup")
    await capture("setup-800.png")
    for id in shell.starter_manual_catalog.STARTER_MANUAL_IDS.slice(0,4):
        shell._setup_buttons[id].grab_focus()
        await key(KEY_ENTER)
    await capture("setup-selected.png")
    root.size = Vector2i(1280,720)
    root.content_scale_size = Vector2i(1280,720)
    await capture("setup-720.png")
    if not root.get_visible_rect().encloses(shell.primary_button.get_global_rect()): failures.append("Start action outside 720p viewport")
    shell.free()
    for failure in failures: push_error(failure)
    print("FEEDBACK_NATIVE_UI failures=%d" % failures.size())
    quit(0 if failures.is_empty() else 1)
