extends "res://tests/verify_vertical_slice_completion_summary.gd"

var return_checks := 0

func _finish() -> void:
    if not failures.is_empty() or completed_run_snapshot.is_empty():
        super._finish()
        return
    var path := "user://completion-return-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()]
    var store = load("res://src/run/run_save_store.gd").new(path)
    var saved: Dictionary = store.replace_run("completed-fixture", "completed-checkpoint", completed_run_snapshot, {})
    _check(saved.ok, "ten-duel checkpoint fixture must validate")
    if not saved.ok:
        _done()
        return
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    shell.configure_save_storage(path)
    shell.configure_presentation_storage(path.path_join("preferences.cfg"))
    root.add_child(shell)
    current_scene = shell
    await process_frame
    if "--dialog-baseline" in OS.get_cmdline_user_args():
        shell.start_new_run()
        for i in range(4): await process_frame
        _check(shell._replacement_dialog.visible, "baseline opens existing replacement dialog")
        shell._replacement_dialog.get_cancel_button().grab_focus()
        await _key(KEY_ENTER, shell._replacement_dialog)
        _check(not shell._replacement_dialog.visible, "unchanged title replacement cancellation")
        shell.queue_free()
        await process_frame
        _done()
        return
    _check(shell.continue_saved_run(), "load actual completed checkpoint")
    _check(shell.has_method("return_to_title"), "player can leave completion without replacing its save")
    if not shell.has_method("return_to_title"):
        shell.queue_free()
        await process_frame
        _done()
        return
    var before: Dictionary = store.load_checkpoint().payload
    _check(shell.presentation_preferences.update(true, 0.25, true) == OK, "isolated preferences saved before return")
    shell.set_session_paused(true)
    _check(not shell.return_to_title(), "paused return rejected")
    shell.set_session_paused(false)
    shell.session.store.io_guard = func(_operation: String, _path: String): return false
    _check(not shell.return_to_title(), "failed stable flush rejects return")
    _check(current_scene == shell and shell.session.blocked, "save failure keeps old scene and recovery state")
    _check(store.load_checkpoint().payload == before, "failed return leaves original checkpoint unchanged")
    shell.session.store.io_guard = Callable()
    _check(await shell.retry_durable_save(), "existing recovery retries without replaying completion")
    _check(shell.return_to_title(), "return queued before late suspension")
    shell.set_session_paused(true)
    for i in range(3): await process_frame
    _check(current_scene == shell, "late suspension cancels deferred scene replacement")
    if current_scene != shell:
        current_scene.queue_free()
        await process_frame
        _done()
        return
    shell.set_session_paused(false)
    shell.primary_button.grab_focus()
    await _key(KEY_ENTER)
    for i in range(4): await process_frame
    shell = current_scene
    _check(shell.run_state.get_current_screen() == "MAIN", "fresh shell opens title")
    _check(shell.presentation_preferences.sound_muted and is_equal_approx(shell.presentation_preferences.sound_volume, 0.25) and shell.presentation_preferences.reduced_motion, "preferences survive scene replacement")
    _check(store.load_checkpoint().payload == before, "title return preserves exact saved completion")
    var review_button: Button = shell.main_title_screen.find_child("MainContinueButton", true, false)
    _check(review_button.visible and review_button.text.contains("완주 기록"), "title clearly offers completed record review")
    _check(root.gui_get_focus_owner() == review_button, "title focus selects safe record review")
    for viewport in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
        root.content_scale_size = viewport
        root.size = viewport
        for i in range(4): await process_frame
        _check(root.get_visible_rect().encloses(review_button.get_global_rect()), "record button fits viewport")
        var output := ""
        for argument in OS.get_cmdline_user_args():
            if argument.begins_with("--capture-dir="): output = argument.trim_prefix("--capture-dir=")
        if DisplayServer.get_name() != "headless" and not output.is_empty():
            DirAccess.make_dir_recursive_absolute(output)
            await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png(output.path_join("completed-title-%dx%d.png" % [viewport.x, viewport.y]))
    review_button.grab_focus()
    await _key(KEY_ENTER)
    _check(shell.run_state.get_current_screen() == "COMPLETION", "native record review restores completion")
    _check(shell.run_state.get_reward_history().size() == 10, "review does not grant rewards again")
    _check(store.load_checkpoint().payload == before, "review does not rewrite or regenerate saved history")
    shell.presentation_preferences.configure(path.path_join("missing/preferences.cfg"))
    _check(shell.presentation_preferences.update(false, 0.4, false) != OK, "preference write failure is real")
    _check(shell.return_to_title(), "second return accepted")
    _check(not shell.return_to_title(), "duplicate return rejected")
    for i in range(4): await process_frame
    shell = current_scene
    var start: Button = shell.main_title_screen.find_child("MainStartButton", true, false)
    _check(not shell.presentation_preferences.sound_muted and is_equal_approx(shell.presentation_preferences.sound_volume, 0.4), "session preference fallback survives title replacement")
    start.grab_focus()
    await _key(KEY_ENTER)
    _check(shell._replacement_dialog.visible, "new journey uses existing player replacement confirmation")
    _check(store.load_checkpoint().payload == before, "opening replacement prompt preserves completion")
    shell._replacement_dialog.get_cancel_button().grab_focus()
    print("RETURN_CANCEL_INPUT window=", shell._replacement_dialog.get_window_id(), " focus=", shell._replacement_dialog.gui_get_focus_owner(), " root_focus=", root.gui_get_focus_owner())
    await _key(KEY_ENTER, shell._replacement_dialog)
    _check(not shell._replacement_dialog.visible, "cancel returns to title")
    _check(store.load_checkpoint().payload == before, "cancelling preserves completion")
    start.grab_focus()
    await _key(KEY_ENTER)
    shell._replacement_dialog.get_ok_button().grab_focus()
    await _key(KEY_ENTER, shell._replacement_dialog)
    _check(shell.run_state.get_current_screen() == "SETUP", "confirmed replacement starts normal setup")
    _check(store.load_checkpoint().payload.save_id != before.save_id, "only confirmation creates new save generation")
    _check(shell.run_state.get_reward_history().is_empty(), "new journey starts with no old rewards")
    _check(not shell.return_to_title(), "unfinished journey cannot use completion return")
    shell.queue_free()
    await process_frame
    _done()

func _key(code: Key, target: Window = null) -> void:
    if target != null: print("POPUP_INPUT begin visible=", target.visible, " embed=", target.is_embedded(), " exclusive=", target.exclusive, " transient=", target.transient)
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    if target != null:
        event.window_id = target.get_window_id()
    root.push_input(event)
    if target != null: print("POPUP_INPUT pressed visible=", target.visible)
    await process_frame
    event = InputEventKey.new()
    event.keycode = code
    event.pressed = false
    if target != null:
        event.window_id = target.get_window_id()
    root.push_input(event)
    if target != null: print("POPUP_INPUT released visible=", target.visible)
    await process_frame

func _check(ok: bool, message: String) -> void:
    return_checks += 1
    if not ok: failures.append(message)

func _done() -> void:
    print("COMPLETION_RETURN ", "PASS" if failures.is_empty() else "FAIL", " checks=", return_checks, " variable=", "--variable-fixture" in OS.get_cmdline_user_args(), " failures=", failures)
    quit(0 if failures.is_empty() else 1)
