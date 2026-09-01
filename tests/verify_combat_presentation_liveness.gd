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
    _stabilize_three_bundle_test_state(board)

    await _plan_first_bundle(board)
    await _wait_for_review_then_next_bundle(board, "first")
    await _plan_second_bundle(board)
    await _wait_for_review_then_next_bundle(board, "second")
    await _plan_final_bundle(board)

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
    await process_frame
    if str(board.get_meta("presentation_state", "")) != "plan_locked":
        failures.append("First bundle must visibly lock its plan before reveal playback.")
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
    var quick_placement := board.action_timing_panel.get_placement(4)
    if str(quick_placement.get("targeting_mode", "")) != "none" or not bool(quick_placement.get("target_ready", false)):
        failures.append("Second bundle quick attack must be immediately ready against the public opponent.")
        return
    if board._begin_targeting_for_anchor(4):
        failures.append("Second bundle quick attack must not reopen a direction-selection surface.")
        return
    if not board.action_timing_panel.place_card(meditate, 5) or not board.action_timing_panel.place_card(meditate, 6):
        failures.append("Second bundle recovery placement failed.")
        return
    if not board.combat_progress_button.progress_enabled:
        failures.append("Second bundle progress did not enable.")
        return
    board.combat_progress_button.request_progress()
    await process_frame
    if str(board.get_meta("presentation_state", "")) != "plan_locked":
        failures.append("Second bundle must visibly lock its plan before reveal playback.")
        return
    board.combat_progress_button.request_progress()

func _plan_final_bundle(board: CombatBoardPreview) -> void:
    if str(board.get_meta("presentation_state", "")) != "next_bundle_ready":
        failures.append("Final four-action bundle requires next_bundle_ready after second review confirmation.")
        return
    var quick := _card(board, "basic_quick_attack")
    var meditate := _card(board, "basic_meditate")
    if not board.action_timing_panel.place_card(quick, 7):
        failures.append("Final bundle quick-attack placement failed.")
        return
    for anchor in [8, 9, 10]:
        if not board.action_timing_panel.place_card(meditate, anchor):
            failures.append("Final bundle recovery placement failed at timing %d." % anchor)
            return
    if not board.action_timing_panel.is_current_bundle_complete() or not board.combat_progress_button.progress_enabled:
        failures.append("Final four-action bundle must enable the plan-lock CTA only after all four actions are ready.")
        return
    if board.combat_progress_button.get_button_text() != "행동계획\n잠금":
        failures.append("Final bundle must still start with the compact plan-lock CTA.")
        return
    var resolution_before := int(board.get_layout_snapshot().get("resolution_count", 0))
    board.combat_progress_button.request_progress()
    await process_frame
    if str(board.get_meta("presentation_state", "")) != "plan_locked":
        failures.append("Final four-action bundle must visibly lock before execution.")
        return
    if int(board.get_layout_snapshot().get("resolution_count", 0)) != resolution_before:
        failures.append("Final bundle plan lock must not resolve any action.")
        return
    if board.combat_progress_button.get_button_text() != "4수 실행":
        failures.append("Final locked bundle must expose exactly the current four-action count.")
        return
    board.combat_progress_button.request_progress()
    await process_frame
    if int(board.get_layout_snapshot().get("resolution_count", 0)) != resolution_before + 1:
        failures.append("Final four-action bundle second CTA must invoke exactly one resolution.")

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
        failures.append("%s bundle must enter review_ready before reopening planning input (last state=%s)." % [bundle_name, str(board.get_meta("presentation_state", ""))])
    else:
        failures.append("%s bundle must reopen planning input after explicit review confirmation." % bundle_name)

func _card(board: CombatBoardPreview, card_id: String) -> Dictionary:
    for card in board.basic_card_tray.cards:
        if str(card.definition.get("id", "")) == card_id:
            return card.definition.duplicate(true)
    return {}

func _stabilize_three_bundle_test_state(board: CombatBoardPreview) -> void:
    # This verifier needs to cross all 3/3/4 planning bundles.  Raise only the
    # disposable product-test resource pools so an ordinary early terminal
    # result cannot skip the final CTA transition under test.
    for actor_key in ["player", "enemy"]:
        var actor: Dictionary = (board.combat_state.get(actor_key, {}) as Dictionary).duplicate(true)
        actor["health"] = [240, 240]
        actor["stamina"] = [40, 40]
        actor["internal"] = [40, 40]
        board.combat_state[actor_key] = actor
    board._apply_combat_state_to_view()

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_PRESENTATION_LIVENESS_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_PRESENTATION_LIVENESS_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
