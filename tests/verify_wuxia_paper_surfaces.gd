extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	await process_frame
	var detail = board.action_selection_dock.action_detail_panel
	if not detail.get_theme_stylebox("panel") is StyleBoxTexture:
		push_error("DETAIL_BACKGROUND_STILL_FLAT_FILL")
		quit(1)
		return
	var paper = board.observation_reveal_panel.get_node("ObservationPaperSurface")
	assert(paper.get_theme_stylebox("panel") is StyleBoxTexture)
	assert(detail.get_theme_stylebox("panel").texture != null)
	board.free()
	print("WUXIA_PAPER_SURFACES_PASS")
	quit(0)
