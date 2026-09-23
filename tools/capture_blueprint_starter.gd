extends SceneTree
## Actual setup screen only; isolated fixture storage never touches the player save.
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
	shell._save_storage_override = "res://output/blueprint/starter-capture-save.json"
	root.add_child(shell)
	await create_timer(0.7).timeout
	assert(shell.start_new_run(true))
	await create_timer(0.5).timeout
	assert(shell.run_state.get_current_screen() == VerticalSliceRunState.SCREEN_SETUP)
	await RenderingServer.frame_post_draw
	var path := "res://docs/blueprint/evidence/current-ui/starter-selection-1280.png"
	assert(root.get_texture().get_image().save_png(path) == OK)
	var receipt := {"engine": Engine.get_version_info().string,
		"project": ProjectSettings.globalize_path("res://"), "screen": shell.run_state.get_current_screen(),
		"path": path, "kind": "GODOT_RENDERED_SETUP_FIXTURE", "size": [root.size.x, root.size.y],
		"save_isolation": shell._save_storage_override}
	var output := FileAccess.open("res://output/blueprint/starter-capture.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(receipt, "\t"))
	output.close()
	print("STARTER_CAPTURE_PASS")
	quit()
