extends SceneTree
## Read-only presentation demonstration, not a campaign or balance test.
## Uses the product scene and its existing event presentation without overrides.
var board
var records: Array = []
var frames: Array = []
var recording := false

func _initialize() -> void:
	RenderingServer.frame_post_draw.connect(capture_frame)
	call_deferred("record_clips")

func event(card: String, outcome: String, actor: String = "player", damage: int = 6) -> Dictionary:
	var definition: Dictionary = board.resolution_engine.get_actor_card_definition(card, actor)
	assert(not definition.is_empty(), "Capture requires a real card: " + card)
	return {"type": "action_result", "actor": actor, "card_id": card,
		"card_name": definition.get("name", card), "category": "attack", "outcome": outcome,
		"damage": damage, "defense_outcome": outcome if outcome in ["block", "evade"] else ""}

func record_clips() -> void:
	board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	await process_frame
	await process_frame
	if not is_instance_valid(board.player_character) or not is_instance_valid(board.top_hud):
		push_error("Incomplete product scene; capture rejected")
		quit(1)
		return
	recording = true
	board._reduced_motion = false
	board._sound_muted = false
	board._set_presentation_state("presenting_result")
	board._set_resolution_surface_visible(false)
	var attack := event("basic_heavy_attack", "hit")
	var incoming := event("basic_heavy_attack", "hit", "enemy")
	var win := attack.duplicate(true)
	win.merge({"type": "clash", "outcome": "clash_win"}, true)
	var loss := attack.duplicate(true)
	loss.merge({"type": "clash", "outcome": "clash_loss"}, true)
	await clip("clash-win", [win, attack])
	await clip("clash-lose", [loss, incoming])
	await clip("hit", [attack])
	await clip("block", [event("basic_heavy_attack", "block", "enemy", 2)])
	await clip("evade", [event("basic_quick_attack", "evade", "enemy", 0)])
	await clip("ultimate", [event("ultimate_void_sword_qi", "hit", "player", 12)])
	var selection = JSON.parse_string(FileAccess.get_file_as_string("res://docs/blueprint/ART_SELECTION.json"))
	for manual in selection.manuals:
		for star in [3, 7, 10]:
			await manual_clip(str(manual), star)
	recording = false
	var output := FileAccess.open("res://output/blueprint/motion-capture/frames.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"engine": Engine.get_version_info().string,
		"fps": 30, "frames": frames, "evidence_kind": "GODOT_PRESENTATION_FIXTURE_CAPTURE", "clips": records}, "\t"))
	output.close()
	print("BLUEPRINT_MOTION_CAPTURE_OK ", records.size())
	board.queue_free()
	await process_frame
	quit()

func clip(id: String, events: Array) -> void:
	board._clear_presentation_feedback_visuals()
	var start := frames.size()
	await create_timer(0.55).timeout
	for item in events:
		await board._present_resolved_event_feedback(item)
		await create_timer(0.28).timeout
	await create_timer(0.75).timeout
	records.append({"id": id, "start_frame": start, "end_frame": frames.size(), "events": events})

func capture_frame() -> void:
	if not recording:
		return
	var index := frames.size()
	var image := root.get_texture().get_image()
	var path := "res://output/blueprint/motion-capture/frame%06d.jpg" % index
	var error := image.save_jpg(path, 0.93)
	if error != OK:
		push_error("Capture write failed")
		quit(1)
	frames.append({"file": "frame%06d.jpg" % index, "ms": Time.get_ticks_msec()})

func manual_clip(manual: String, star: int) -> void:
	var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
	engine.configure_martial_loadouts([manual], {manual: star}, [], {})
	engine.rules["enemy_bundles"] = {}
	var actor := {"name": "연출 검수", "health": [100, 100], "stamina": [30, 30], "internal": [30, 30], "momentum": [5, 5],
		"stats": {"external": 10, "constitution": 10, "agility": 10, "internal_power": 10, "insight": 10}}
	var state: Dictionary = engine.make_initial_state({"player": actor, "enemy": actor}, 4, 5)
	state["ai_enabled"] = false
	var card := manual + "_star" + str(star)
	var definition: Dictionary = engine.get_actor_card_definition(card, "player")
	var placement := {"card_id": card, "definition": definition, "anchor_index": 1,
		"span": maxi(1, int(definition.get("action_slots", 1))), "target_ready": true,
		"direction": 1, "target_tile": 5, "origin_tile": 4}
	var result: Dictionary = engine.resolve_bundle([placement], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
	var events: Array = []
	for item in result.get("presentation_events", []):
		if str(item.get("card_id", "")) == card:
			events.append(item)
	if events.is_empty():
		push_error("Missing actual resolver presentation: " + card)
		quit(1)
		return
	board.resolution_engine = engine
	await clip(card, events)
