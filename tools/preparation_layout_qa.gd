extends Control
## Real shell navigation with its own save. Never touches the player's checkpoint.
func _ready() -> void:
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    shell._save_storage_override = "res://output/prep-layout/live-qa-%d.json" % OS.get_process_id()
    add_child(shell)
    shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    await get_tree().process_frame
    assert(shell.session.transact(func(): return shell.run_state.start_new_giyun_run(1, shell.session.save_id), true))
    for manual in ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]:
        shell.toggle_setup_manual(manual)
    shell.advance_noncombat()
    shell.advance_noncombat()
    shell.advance_noncombat()
