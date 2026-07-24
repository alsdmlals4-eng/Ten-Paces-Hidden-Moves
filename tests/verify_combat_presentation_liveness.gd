# 두 묶음 연속 판정에서 review_ready 복기 확인 뒤 planning 입력이 다시 열리는지를 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(6):
        await process_frame

    await _plan_first_bundle(board)
    await _wait_for_review_then_next_bundle(board, "first")
    await _plan_second_bundle(board)
    await _wait_for_review_then_next_bundle(board, "second")

    board.queue_free()
    await process_frame
    _finish()

func _plan_first_bundle(board: CombatBoardPreview) -> void:
    var move := _card(board, "basic_move")
    var meditate := _card(board, "basic_meditate")
    if not board.action_timing_panel.place_card(move, 1):
        failures.append("First bundle move placement failed.")
        return
    if not board._begin_targeting_for_anchor(1):
        failures.append("First bundle move targeting did not start.")
        return
    board._on_board_tile_clicked(5)
    if not board.action_timing_panel.place_card(meditate, 2) or not board.action_timing_panel.place_card(meditate, 3):
        failures.append("First bundle recovery placement failed.")
        return
    if not board.combat_progress_button.progress_enabled:
        failures.append("First bundle progress did not enable.")
        return
    board.combat_progress_button.request_progress()

func _plan_second_bundle(board: CombatBoardPreview) -> void:
    if str(board.get_meta("presentation_state", "")) != "next_bundle_ready":
        failures.append("Second bundle planning requires next_bundle_ready after review confirmation.")
        return
    var quick := _card(board, "basic_quick_attack")
    var meditate := _card(board, "basic_meditate")
    if not board.action_timing_panel.place_card(quick, 4):
        failures.append("Second bundle quick-attack placement failed.")
        return
    if not board._begin_targeting_for_anchor(4):
        failures.append("Second bundle quick-attack targeting did not start.")
        return
    board._on_board_tile_clicked(6)
    if not board.action_timing_panel.place_card(meditate, 5) or not board.action_timing_panel.place_card(meditate, 6):
        failures.append("Second bundle recovery placement failed.")
        return
    if not board.combat_progress_button.progress_enabled:
        failures.append("Second bundle progress did not enable.")
        return
    board.combat_progress_button.request_progress()

func _wait_for_review_then_next_bundle(board: CombatBoardPreview, bundle_name: String) -> void:
    var review_seen := false
    for _attempt in range(120):
        var state_value := str(board.get_meta("presentation_state", ""))
        if state_value == "review_ready":
            review_seen = true
            if not bool(board.get_meta("inputs_locked", false)):
                failures.append("%s bundle review must keep planning input locked." % bundle_name)
            if board.combat_review_panel == null or not board.combat_review_panel.visible:
                failures.append("%s bundle review panel must be visible." % bundle_name)
            board._on_review_continue_requested()
            await process_frame
            if str(board.get_meta("presentation_state", "")) == "next_bundle_ready":
                return
        await create_timer(0.05).timeout
    if not review_seen:
        failures.append("%s bundle must enter review_ready before reopening planning input." % bundle_name)
    else:
        failures.append("%s bundle must reopen planning input after explicit review confirmation." % bundle_name)

func _card(board: CombatBoardPreview, card_id: String) -> Dictionary:
    for card in board.basic_card_tray.cards:
        if str(card.definition.get("id", "")) == card_id:
            return card.definition.duplicate(true)
    return {}

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_PRESENTATION_LIVENESS_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_PRESENTATION_LIVENESS_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
