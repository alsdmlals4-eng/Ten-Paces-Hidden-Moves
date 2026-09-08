extends SceneTree
func _initialize() -> void:
    call_deferred("verify")
func verify() -> void:
    var shell = preload("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    if shell.session.enabled or shell.session.store != null:
        printerr("SCRIPT_ENTRY_ISOLATION FAIL")
        quit(1)
        return
    shell.start_new_run()
    if not shell.session.last_durable.is_empty():
        printerr("SCRIPT_ENTRY_ISOLATION FAIL wrote a checkpoint")
        quit(1)
        return
    print("SCRIPT_ENTRY_ISOLATION PASS")
    shell.queue_free()
    await process_frame
    quit(0)
