extends SceneTree
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	for i in range(5): await process_frame
	var fixture = JSON.parse_string(FileAccess.get_file_as_string("res://docs/visual-assets/candidates/TEN-INK-STYLES-20260924/clash-v2/bundle-fixtures.json"))
	var first: Dictionary = fixture.bundles[0]
	var overlay = board.ink_presentation
	if overlay == null:
		overlay = load("res://src/ui/ink/ink_combat_presentation.gd").new()
		board.add_child(overlay)
	var model = load("res://src/ui/ink/ink_resolution_model.gd")
	overlay.begin(model.build(first.result, first.input.before, first.input.placements, board.resolution_engine.cards_by_id),board)
	overlay.begin_step(1)
	for viewport in [Vector2(960,640),Vector2(1280,720),Vector2(1440,900),Vector2(1920,1080)]:
		overlay.set_anchors_preset(Control.PRESET_TOP_LEFT)
		overlay.size = viewport
		overlay.layout()
		check(overlay.comparison.get_theme_font_size("font_size") >= 30,"Comparison must be readable without enlarging video")
		check(overlay.result_label.get_theme_font_size("font_size") >= 20,"Resource result must be prominent")
		check(overlay.stage.get_rect().end.y <= overlay.slots[0].position.y,"Stage cannot cover action history")
		check(not overlay.result_label.get_rect().intersects(overlay.comparison.get_rect()),"Results and verdict occupy separate rows")
		check(overlay.result_label.get_rect().end.y <= overlay.controls.position.y,"Playback controls cannot cover result")
		check(overlay.result_label.size.y >= 54,"Long resource changes have two readable lines")
	check(board.get_node("BattleBackground").texture.resource_path == "res://assets/combat/ink_wuxia/background.png","Preparation uses the same ink world as resolution")
	overlay.stage.configure_opponent("slot1_dogyeom")
	check(overlay.stage.unarmed_enemy and overlay.stage.hero == null,"Dogyeom never receives a sword or a masked face cut-in")
	check(overlay.stage.textures.enemy[0].resource_path.contains("slot1_dogyeom"),"First actual enemy uses his own pose family")
	overlay.stage.configure_opponent("masked_baekmujin")
	check(not overlay.stage.unarmed_enemy and overlay.stage.hero != null,"Masked swordsman retains the matching clash art")
	overlay.stage.configure_opponent("slot1_yeongyo")
	check(overlay.stage.textures.enemy[0].resource_path == "res://assets/combat/ink_wuxia/enemy-0.png","Other enemy bindings remain unchanged")
	board.queue_free()
	await process_frame
	for message in failures: push_error(message)
	print("INK_SCREEN_REFRESH failures=%d" % failures.size())
	quit(0 if failures.is_empty() else 1)

func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
