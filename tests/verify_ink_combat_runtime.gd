extends SceneTree
var failures: Array[String] = []
var board: CombatBoardPreview
var capture := false
var recording := false
var frames := 0
var captures := {}

func _initialize() -> void:
	capture = OS.get_cmdline_user_args().has("--capture")
	call_deferred("run")

func run() -> void:
	board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	for i in range(5): await process_frame
	board._sound_muted = true
	board._fast_replay = not capture
	var fixture = JSON.parse_string(FileAccess.get_file_as_string("res://docs/visual-assets/candidates/TEN-INK-STYLES-20260924/clash-v2/bundle-fixtures.json"))
	var engine = load("res://src/combat/combat_resolution_engine.gd").new()
	board.resolution_engine = engine
	var selection_rect: Rect2 = board.action_selection_dock.get_rect()
	if capture:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://output/ink-runtime/frames"))
		RenderingServer.frame_post_draw.connect(capture_frame)
		save_image("preparation-before")
	for item in fixture.bundles:
		board.combat_state = item.input.before.duplicate(true)
		board._committed_state_before = item.input.before.duplicate(true)
		board._committed_player_plan_snapshot = item.input.placements.duplicate(true)
		engine.rules["enemy_bundles"] = {str(int(item.result.bundle_index)):item.input.enemy_plan}
		engine.clear_locked_enemy_bundle()
		board._set_presentation_state("committed")
		recording = capture
		await board._resolve_and_present(item.input.context)
		recording = false
		var history: Array = board.get_meta("ink_timing_history",[])
		check(history.size() == [3,3,4][int(item.result.bundle_index)-1], "Full 3/3/4 bundle reached current scene")
		for entry in history:
			for slot in entry.slots:
				if slot.timing > entry.timing: check(slot.enemy == "미공개","Future enemy action hidden at runtime")
		check(not board.ink_presentation.visible,"Presentation released after entire bundle")
		check(board.action_selection_dock.visible,"Existing planning dock restored")
		check(board.action_selection_dock.get_rect() == selection_rect,"Planning geometry unchanged")
		check(int(board.combat_state.enemy.health[0]) == int(item.result.state.enemy.health[0]),"Actual resolver damage preserved: %s vs %s" % [board.combat_state.enemy.health,item.result.state.enemy.health])
		check(board._presentation_state == "next_bundle_ready","Planning returns after whole bundle")
		if capture: save_image("bundle-%d-complete" % item.result.bundle_index)
	if capture:
		var file := FileAccess.open("res://output/ink-runtime/capture.json",FileAccess.WRITE)
		file.store_string(JSON.stringify({"frames":frames,"fps":24,"engine":Engine.get_version_info().string,"source":"Actual CombatBoardPreview with actual resolver fixed plans; not offline compositing","captures":captures},"\t"))
	# Reduced motion keeps the same content and suppresses moving brush/camera.
	var first: Dictionary = fixture.bundles[0]
	board.ink_presentation.begin(load("res://src/ui/ink/ink_resolution_model.gd").build(first.result,first.input.before,first.input.placements,engine.cards_by_id),board)
	board.ink_presentation.begin_step(1)
	check(board.ink_presentation.controls.get_child(0).has_focus(),"Playback controls receive keyboard focus")
	board.ink_presentation.controls.get_child(2).emit_signal("pressed")
	check(not board._sound_muted,"Visible sound control reaches existing sound preference")
	board.ink_presentation.controls.get_child(2).emit_signal("pressed")
	board.ink_presentation.volume.value = 0.35
	check(is_equal_approx(board._sound_volume,0.35),"Visible volume uses existing audio adapter")
	board.ink_presentation.stage.begin({"kind":"clash","actor":"player","event":{},"contact":true})
	board.ink_presentation.stage.sample(0.65,true)
	check(board.ink_presentation.stage.effect_time < 0,"Reduced motion disables ink trail")
	board.ink_presentation.stage.begin({"kind":"pressure","actor":"enemy","family":"palm","event":{},"contact":false})
	board.ink_presentation.stage.sample(0.5,false)
	await process_frame
	check(board.ink_presentation.stage.effect_time < 0,"Energy clash has no sword-contact flash")
	board._skip_presentation()
	check(not board.ink_presentation.visible,"Skip hides ink synchronously")
	board.restart_combat()
	check(board._presentation_state == "planning" and not board.ink_presentation.visible,"Restart clears presentation")
	board.combat_state = first.input.before.duplicate(true)
	board._committed_state_before = first.input.before.duplicate(true)
	board._committed_player_plan_snapshot = first.input.placements.duplicate(true)
	engine.rules["enemy_bundles"] = {"1":first.input.enemy_plan}
	engine.clear_locked_enemy_bundle()
	board._fast_replay = false
	board.call_deferred("_resolve_and_present",first.input.context)
	for i in range(5): await process_frame
	board.session_suspended = true
	await process_frame
	var held: float = board.ink_presentation.stage.progress
	await create_timer(0.08).timeout
	check(board.ink_presentation.stage.progress == held,"Pause freezes ink timeline")
	board.session_suspended = false
	board.restart_combat()
	await create_timer(0.12).timeout
	check(board._presentation_state == "planning" and not board.ink_presentation.visible,"Cancelled coroutine cannot overwrite restarted battle")
	board.queue_free()
	await process_frame
	for failure in failures: push_error(failure)
	print("INK_COMBAT_RUNTIME failures=%d frames=%d" % [failures.size(),frames])
	quit(0 if failures.is_empty() else 1)

func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)

func capture_frame() -> void:
	if not recording or not is_instance_valid(board.ink_presentation) or not board.ink_presentation.visible: return
	# Capture is launched with --fixed-fps 24; keep every rendered frame.
	var img := root.get_texture().get_image()
	img.save_jpg("res://output/ink-runtime/frames/%05d.jpg" % frames,0.88)
	frames += 1
	var stage: Control = board.ink_presentation.stage
	var kind: String = stage.cue.get("kind","")
	var name := ""
	if kind == "clash" and stage.effect_time > 1.37 and stage.effect_time < 1.46: name = "clash-contact"
	if kind == "clash" and stage.effect_time > 2.51 and stage.effect_time < 2.65: name = "clash-keyshot"
	if kind == "attack" and board.ink_presentation.applied: name = "resolved-damage"
	if board.ink_presentation.bundle.index == 3 and board.ink_presentation.current == 2: name = "four-slots"
	if not name.is_empty() and not captures.has(name): save_image(name)

func save_image(name: String) -> void:
	root.get_texture().get_image().save_png("res://output/ink-runtime/"+name+".png")
	captures[name] = frames
