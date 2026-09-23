extends SceneTree
## Captures the actual scene. No alternate game rules or repainted UI.
var board
var shots: Array = []

func _initialize() -> void:
	call_deferred("capture")

func save_frame(label: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "res://docs/blueprint/evidence/current-ui/" + label + ".png"
	var error := root.get_texture().get_image().save_png(path)
	assert(error == OK)
	shots.append({"path": path, "size": [root.size.x, root.size.y], "kind": "GODOT_RENDERED_FIXTURE"})

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/blueprint/evidence/current-ui")
	board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	await create_timer(1.0).timeout
	if not is_instance_valid(board.top_hud) or not is_instance_valid(board.player_character):
		push_error("Incomplete scene; capture rejected")
		quit(1)
		return
	var definition: Dictionary = board.resolution_engine.get_actor_card_definition("basic_heavy_attack", "player")
	board.action_selection_dock.request_detail(definition, true)
	await create_timer(0.3).timeout
	await save_frame("planning-1440")
	board._set_presentation_state("presenting_result")
	board._set_resolution_surface_visible(false)
	var event := {"type": "clash", "actor": "player", "card_id": "basic_heavy_attack",
		"card_name": definition.get("name"), "category": "attack", "outcome": "clash_win", "damage": 6}
	board._present_resolved_event_feedback(event)
	await create_timer(0.15).timeout
	await save_frame("clash-1440")
	await create_timer(1.5).timeout
	board._set_presentation_state("selecting")
	root.size = Vector2i(960, 600)
	await create_timer(0.5).timeout
	await save_frame("planning-960")
	var file := FileAccess.open("res://output/blueprint/current-ui-capture.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine": Engine.get_version_info().string, "project": ProjectSettings.globalize_path("res://"), "shots": shots}, "\t"))
	file.close()
	print("CURRENT_UI_CAPTURE_PASS ", shots.size())
	board.queue_free()
	await process_frame
	quit()
