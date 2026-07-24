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
    _expect(panel.get_display_text().contains("내 가설"), "Review must show hypothesis heading.")
    _expect(panel.get_display_text().contains("속공"), "Review must show opponent actual action.")
    _expect(panel.get_display_text().contains("[합]"), "Review must show decisive cause.")
    _expect(panel.get_display_text().contains("3 → 1"), "Review must show before and after distance.")
    _expect(panel.get_continue_button().text == "다음 묶음", "Non-terminal review must continue to next bundle.")
    _expect(not panel.get_detail_button().accessibility_name.is_empty(), "Detail button needs accessibility name.")
    _expect(not panel.get_continue_button().accessibility_description.is_empty(), "Continue button needs accessibility description.")
    summary["opponent_actual"] = "mutated"
    _expect(not panel.get_display_text().contains("mutated"), "Panel must detach from caller summary.")
    panel.show_summary(_summary(), true)
    _expect(panel.get_continue_button().text == "결전 다시 시작", "Terminal review must offer restart.")
    panel.hide_review()
    _expect(not panel.visible, "hide_review must hide panel.")
    panel.queue_free()
    await process_frame

func _verify_board_gate() -> void:
    var board := BOARD_SCENE.instantiate() as CombatBoardPreview
    root.add_child(board)
    for _index in range(4):
        await process_frame
    board._last_review_summary = _summary()
    board._show_review_panel(false)
    await process_frame
    _expect(str(board.get_meta("presentation_state", "")) == "review_ready", "Board must enter review_ready.")
    _expect(bool(board.get_meta("inputs_locked", false)), "Planning inputs must remain locked during review.")
    _expect(board.combat_review_panel.visible, "Board review panel must be visible.")
    board._toggle_reduced_motion()
    board._toggle_sound()
    board._skip_presentation()
    _expect(board.combat_review_panel.get_display_text().contains("[합]"), "Review text must survive accessibility presentation options.")
    board._on_review_detail_requested()
    _expect(not board.combat_log_panel.collapsed, "Detail request must expand existing combat log.")
    board._on_review_continue_requested()
    await process_frame
    _expect(str(board.get_meta("presentation_state", "")) == "next_bundle_ready", "Continue must unlock the next bundle state.")
    _expect(not board.combat_review_panel.visible, "Continue must hide review panel.")

    board.combat_state["player"]["health"] = [0, 30]
    board._last_review_summary = _summary()
    board._show_review_panel(true)
    board._on_review_continue_requested()
    await process_frame
    _expect(str(board.get_meta("presentation_state", "")) == "planning", "Terminal continue must restart combat.")
    _expect(board._last_review_summary.is_empty(), "Restart must clear review summary.")
    board.queue_free()
    await process_frame

func _summary() -> Dictionary:
    return {
        "hypothesis": {"id": "quick_attack", "label": "속공", "recorded": true},
        "opponent_actual": "속공",
        "cause_code": "clash",
        "cause_label": "[합]에서 공격력 차이가 승부를 갈랐다.",
        "decisive_timing": 2,
        "distance_before": 3,
        "distance_after": 1,
        "review_dimension": "다음 묶음에서는 같은 수 공격력을 비교한다.",
        "player_plan_count": 3
    }

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
