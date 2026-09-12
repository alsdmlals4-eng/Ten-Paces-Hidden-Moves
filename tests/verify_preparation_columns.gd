extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for viewport in [Vector2i(1280, 720), Vector2i(1280, 800), Vector2i(1920, 1080)]:
        root.size = viewport
        var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
        board.set_anchors_preset(Control.PRESET_TOP_LEFT)
        root.add_child(board)
        board.size = Vector2(viewport)
        board.position = Vector2.ZERO
        for i in range(8):
            await process_frame
        var observation: Rect2 = board.observation_reveal_panel.get_global_rect()
        var detail: Rect2 = board.action_selection_dock.detail_host.get_global_rect()
        print("PREPARATION_GEOMETRY ", viewport, " board=", board.size, " observation=", observation, " detail=", detail)
        if observation.size.x < viewport.x * 0.21 or absf(observation.position.y - viewport.y * 0.6) > 12:
            push_error("OBSERVATION_MUST_FILL_RIGHT_PREPARATION_COLUMN")
            board.free()
            quit(1)
            return
        if detail.intersects(observation) or absf(detail.position.y - observation.position.y) > 2:
            push_error("DETAIL_AND_OBSERVATION_MUST_ALIGN_WITHOUT_OVERLAP")
            board.free()
            quit(1)
            return
        var progress: Rect2 = board.combat_progress_button.get_global_rect()
        if not board.get_global_rect().encloses(progress) or progress.intersects(observation):
            push_error("EXECUTE_BUTTON_CLIPPED_OR_COVERS_OBSERVATION")
            board.free()
            quit(1)
            return
        var grid = board.action_selection_dock.basic_panel.get_node("PanelColumn/ActionGrid")
        var art = grid.get_child(0).get_node("CardIllustration")
        print("CARD_GEOMETRY card=", grid.get_child(0).size, " art=", art.size, " summary=", grid.get_child(0).get_node("CardSummary").size)
        if art.size.y < grid.get_child(0).size.y * 0.40:
            push_error("CARD_ART_IS_ONLY_A_THIN_STRIP")
            board.free()
            quit(1)
            return
        if grid.columns != 5 or grid.get_global_rect().end.y > viewport.y + 1:
            push_error("TWO_CARD_ROWS_OUTSIDE_PREPARATION_SCREEN")
            board.free()
            quit(1)
            return
        board.free()
    print("PREPARATION_COLUMNS_PASS")
    quit(0)
