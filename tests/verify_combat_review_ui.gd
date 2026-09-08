extends SceneTree

const PANEL_SCENE := preload("res://scenes/ui/combat_review_panel.tscn")
const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    await _verify_panel()
    await _verify_board_gate()
    if failures.is_empty():
        print("COMBAT_REVIEW_UI_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _verify_panel() -> void:
    var panel := PANEL_SCENE.instantiate() as CombatReviewPanel
    root.add_child(panel)
    panel.size = Vector2(520.0, 360.0)
    var summary := _summary()
    panel.show_summary(summary, false)
    await process_frame
    _expect(panel.visible, "Review panel must become visible.")
    _expect(not panel.get_display_text().contains("내 가설"), "Review must not surface the retired player-intention hypothesis.")
    _expect(panel.get_display_text().contains("속공"), "Review must show opponent actual action.")
    _expect(panel.get_display_text().contains("[합]"), "Review must show decisive cause.")
    _expect(panel.get_display_text().contains("3 → 1"), "Review must show before and after distance.")
    _expect(panel.get_display_text().contains("검토 관점"), "Review must expose a neutral inspection focus.")
    _expect(not panel.get_display_text().contains("다음 묶음에서는"), "Review must not prescribe the next bundle action.")
    _expect(panel.get_continue_button().text == "다음 묶음", "Non-terminal review must continue to next bundle.")
    _expect(not panel.get_detail_button().accessibility_name.is_empty(), "Detail button needs accessibility name.")
    _expect(not panel.get_continue_button().accessibility_description.is_empty(), "Continue button needs accessibility description.")
    summary["opponent_actual"] = "mutated"
    _expect(not panel.get_display_text().contains("mutated"), "Panel must detach from caller summary.")
    panel.show_summary(_summary(), true)
    _expect(panel.get_continue_button().text == "결전 다시 시작", "Legacy terminal review outside the Vertical Slice bridge must still offer restart.")
    panel.hide_review()
    _expect(not panel.visible, "hide_review must hide panel.")
    panel.queue_free()
    await process_frame

func _verify_board_gate() -> void:
    var board := BOARD_SCENE.instantiate() as CombatBoardPreview
    root.add_child(board)
    for _index in range(8):
        await process_frame
    board._reduced_motion = true
    for _index in range(3):
        board.action_selection_dock.basic_panel.buttons[2].emit_signal("pressed")
        await process_frame
    board.combat_progress_button.request_progress()
    var deadline := Time.get_ticks_msec() + 15000
    while str(board.get_meta("presentation_state", "")) != "next_bundle_ready" and Time.get_ticks_msec() < deadline:
        await process_frame
    _expect(str(board.get_meta("presentation_state", "")) == "next_bundle_ready", "Board must continue without a standalone review gate.")
    _expect(not bool(board.get_meta("inputs_locked", true)), "Planning inputs must unlock for the next bundle.")
    _expect(not board.combat_review_panel.visible, "Legacy review panel must remain hidden in active board integration.")
    _expect(board.inline_result_label.is_visible_in_tree(), "Active board must retain the resolved cause inline.")
    _expect(not str(board.get_meta("inline_result_cause", "")).is_empty(), "Inline result must consume the actual review summary cause.")
    board._toggle_reduced_motion()
    board._toggle_sound()
    board._skip_presentation()
    _expect(not board.combat_review_panel.visible, "Presentation options must not restore the legacy overlay.")
    board.queue_free()
    await process_frame

func _summary() -> Dictionary:
    return {
        "opponent_actual": "속공",
        "cause_code": "clash",
        "cause_label": "[합]에서 공격력 차이가 승부를 갈랐다.",
        "decisive_timing": 2,
        "distance_before": 3,
        "distance_after": 1,
        "review_focus": "같은 수에서 양측 원공격력 차이와 최종 피해의 관계",
        "review_dimension": "같은 수에서 양측 원공격력 차이와 최종 피해의 관계",
        "player_plan_count": 3
    }

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
