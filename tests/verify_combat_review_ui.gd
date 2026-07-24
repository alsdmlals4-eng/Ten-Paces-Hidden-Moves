extends SceneTree

const REVIEW_SCENE := preload("res://scenes/ui/combat_review_panel.tscn")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel := REVIEW_SCENE.instantiate() as CombatReviewPanel
    root.add_child(panel)
    await process_frame
    var summary := {
        "hypothesis": {"id": "none", "label": "기록한 가설 없음", "recorded": false},
        "enemy_actions": ["basic_heavy_attack"],
        "decisive_timing": 2,
        "cause_text": "같은 수의 합 차이가 결과를 갈랐습니다.",
        "distance_before": 3,
        "distance_after": 1,
        "next_review_dimension": "같은 수 충돌과 중단 위험"
    }
    panel.set_continue_enabled(false)
    panel.apply_summary(summary, false)
    await process_frame
    var rendered := panel.review_text()
    for token in ["기록한 가설 없음", "basic_heavy_attack", "2수", "3 → 1", "상세 기록", "다음 묶음 또는 재시작"]:
        if token not in rendered:
            push_error("Review text missing: %s" % token)
            quit(1)
            return
    if panel.current_summary() != summary:
        push_error("Review panel mutated or replaced summary data.")
        quit(1)
        return
    panel.apply_summary(summary, true)
    await process_frame
    var continue_button := panel.get_node("Margin/Column/Buttons/ContinueButton") as Button
    if continue_button.text != "결전 다시 시작" or continue_button.disabled:
        push_error("Combat-ended review must lead to restart after reading.")
        quit(1)
        return
    if "candidate_scores" in rendered or "selected_card_id" in rendered:
        push_error("Review UI leaked AI internal trace.")
        quit(1)
        return
    print("COMBAT_REVIEW_UI_VERIFY_OK")
    quit(0)
