extends SceneTree
func _initialize():
    create_timer(90.0).timeout.connect(func(): printerr("verify_variable_shell TIMEOUT"); quit(1))
    call_deferred("verify")
func verify():
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    assert(shell.start_new_run())
    assert(shell.run_state.export_snapshot().has("resolved_encounters"), "Title new run must use v2 approved roster")
    var starters = ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]
    shell._setup_selected_manual_ids.assign(starters)
    assert(shell.advance_noncombat())
    assert(shell.advance_noncombat())
    assert(shell.run_state.get_current_screen() == "BRIEFING")
    assert(shell._approved_portrait.texture != null)
    if "--capture" in OS.get_cmdline_user_args():
        await process_frame
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png("res://tmp/variable-briefing.png")
    assert(shell.advance_noncombat())
    assert(shell._combat_view.get_meta("vertical_slice_runtime_loadout_bound"))
    var dto: Dictionary = shell._combat_view.get_last_stable_checkpoint()
    assert(dto.binding.enemy_loadout.size() >= 2)
    var result: Dictionary = load("res://src/run/run_checkpoint_codec.gd").new().validate_payload(shell.run_state.export_snapshot(), dto)
    if not result.ok: print(result)
    assert(result.ok)
    if "--capture" in OS.get_cmdline_user_args():
        await process_frame
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png("res://tmp/variable-combat.png")
    print("VARIABLE_SHELL_START_BRIEFING_COMBAT_CHECKPOINT_PASS")
    shell.queue_free()
    await process_frame
    quit()
