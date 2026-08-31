extends SceneTree

const METRICS_SCRIPT_PATH := "res://src/run/vertical_slice_battle_metrics.gd"
const REVIEW_BUILDER_SCRIPT := preload("res://src/combat/combat_review_summary_builder.gd")
const REVIEW_PANEL_SCENE := preload("res://scenes/ui/combat_review_panel.tscn")
const SHELL_SCENE := preload("res://scenes/run/vertical_slice_shell.tscn")
const DEFAULT_STARTERS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear"
]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    await _verify_neutral_review_contract()
    _verify_battle_metrics_contract()
    await _verify_result_and_reward_contract()
    _finish()


func _verify_neutral_review_contract() -> void:
    var builder = REVIEW_BUILDER_SCRIPT.new()
    var summary: Dictionary = builder.build_summary(
        {
            "state": {
                "player": {"tile": 4},
                "enemy": {"tile": 5}
            },
            "presentation_events": [
                {
                    "type": "clash",
                    "actor": "player",
                    "outcome": "clash_win",
                    "clash": true,
                    "timing": 2,
                    "card_name": "속공"
                },
                {
                    "type": "clash",
                    "actor": "enemy",
                    "outcome": "clash_loss",
                    "clash": true,
                    "timing": 2,
                    "card_name": "강공"
                }
            ]
        },
        [],
        {"id": "quick_attack", "label": "속공", "recorded": true},
        {
            "player": {"tile": 4},
            "enemy": {"tile": 7}
        }
    )
    _expect_true(summary.has("review_focus"), "Review summary must expose a neutral review_focus field.")
    var focus := str(summary.get("review_focus", ""))
    _expect_false(focus.contains("다음 묶음에서는"), "Review focus may not instruct the next action.")
    _expect_false(focus.contains("한다."), "Review focus should describe what to inspect rather than command the player.")

    var panel := REVIEW_PANEL_SCENE.instantiate() as CombatReviewPanel
    root.add_child(panel)
    panel.size = Vector2(520.0, 360.0)
    panel.show_summary(summary, true)
    await process_frame
    var display := panel.get_display_text()
    _expect_true(display.contains("검토 관점"), "Review UI must label the neutral inspection field as 검토 관점.")
    _expect_false(display.contains("다음 검토"), "Review UI must no longer present a direct next-step recommendation heading.")
    _expect_false(display.contains("다음 묶음에서는"), "Review UI must not include prescriptive next-bundle copy.")
    panel.queue_free()
    await process_frame


func _verify_battle_metrics_contract() -> void:
    var metrics_script := load(METRICS_SCRIPT_PATH)
    if metrics_script == null:
        failures.append("Vertical Slice battle metrics helper is missing: %s" % METRICS_SCRIPT_PATH)
        return
    var metrics = metrics_script.new()
    var initial: Dictionary = metrics.make_initial_metrics()
    var state_before := {
        "player": {"health": [10, 10]},
        "battle_metrics": initial
    }
    var result := {
        "round_number": 2,
        "state": {"player": {"health": [7, 10]}},
        "resolved_actions": [
            {
                "actor": "enemy",
                "outcome": "hit",
                "defense_outcome": "evade",
                "action_stage": "execution",
                "card_id": "basic_quick_attack"
            },
            {
                "actor": "player",
                "outcome": "clash_win",
                "defense_outcome": "hit",
                "action_stage": "execution",
                "card_id": "basic_quick_attack"
            },
            {
                "actor": "player",
                "outcome": "hit",
                "action_stage": "execution",
                "card_id": "ultimate_ten_paces_wave"
            }
        ]
    }
    var next: Dictionary = metrics.accumulate(initial, state_before, result)
    _expect_eq(int(next.get("successful_dodges", -1)), 1, "Successful player evades must be counted from resolved outcomes.")
    _expect_eq(int(next.get("clash_wins", -1)), 1, "Player clash wins must be counted from resolved outcomes.")
    _expect_eq(int(next.get("player_health_lost", -1)), 3, "Player health lost must accumulate from actual before/after health.")
    _expect_eq(int(next.get("rounds_elapsed", -1)), 2, "Round metric must preserve the furthest resolved round.")
    _expect_eq(int(next.get("ultimate_uses", -1)), 1, "Executed player ultimates must be counted.")


func _verify_result_and_reward_contract() -> void:
    var shell = SHELL_SCENE.instantiate()
    root.add_child(shell)
    if shell is Control:
        shell.set_anchors_preset(Control.PRESET_TOP_LEFT)
        shell.size = Vector2(1440.0, 900.0)
    for _index in range(3):
        await process_frame

    _expect_true(shell.start_new_run(), "Shell must start a run.")
    for manual_id in DEFAULT_STARTERS:
        _expect_true(shell.toggle_setup_manual(manual_id), "Starter selection must succeed: %s" % manual_id)
    _expect_true(shell.advance_noncombat(), "SETUP → INTRO")
    _expect_true(shell.advance_noncombat(), "INTRO → BRIEFING")
    var opponent: Dictionary = shell.run_state.get_current_opponent()
    _expect_true(shell.advance_noncombat(), "BRIEFING → COMBAT")

    var review_summary := {
        "hypothesis": {"id": "none", "label": "기록한 가설 없음", "recorded": false},
        "opponent_actual": "속공",
        "cause_code": "clash",
        "cause_label": "[합]에서 공격력 차이가 승부를 갈랐다.",
        "decisive_timing": 2,
        "distance_before": 3,
        "distance_after": 1,
        "review_focus": "같은 수에서 양측 원공격력 차이와 최종 피해의 관계",
        "player_plan_count": 3
    }
    var terminal_result := {
        "terminal": true,
        "outcome": "win",
        "player_health": 7,
        "enemy_health": 0,
        "battle_metrics": {
            "successful_dodges": 1,
            "clash_wins": 2,
            "player_health_lost": 3,
            "rounds_elapsed": 2,
            "ultimate_uses": 1
        },
        "review_summary": review_summary,
        "presentation_state": "review_ready"
    }
    _expect_true(shell.complete_combat_for_runtime(terminal_result), "Terminal result must enter REVIEW.")
    _expect_true(shell.complete_review_for_runtime(), "REVIEW must enter RESULT.")
    await process_frame

    _expect_eq(shell.run_state.get_current_screen(), "RESULT", "Run must render a separate Result screen.")
    var snapshot: Dictionary = shell.get_result_snapshot()
    _expect_eq(str(snapshot.get("outcome", "")), "win", "Result must preserve the terminal outcome.")
    _expect_eq(str(snapshot.get("grade_status", "")), "FORMULA_PENDING", "Result must not fabricate S/A/B/C before the formula exists.")
    _expect_eq(str(snapshot.get("final_grade", "")), "", "No final grade letter may be emitted while thresholds are TBD.")
    _expect_eq((snapshot.get("battle_metrics", {}) as Dictionary), terminal_result["battle_metrics"], "Result must preserve the five approved raw grade metrics.")
    _expect_eq((snapshot.get("reward_options", []) as Array).size(), 3, "Result must expose the three approved reward choices.")
    _expect_true(shell.primary_button.disabled, "Result CTA must remain disabled until one reward is selected.")

    var result_text := "%s\n%s" % [shell.title_label.text, shell.description_label.text]
    for label in ["회피 성공", "합 승리", "잃은 체력", "전투 라운드", "절초 사용"]:
        _expect_true(result_text.contains(label), "Result must show approved raw metric label: %s" % label)
    _expect_true(result_text.contains("산식 미확정"), "Result must explain that S/A/B/C formula is pending.")
    _expect_false(result_text.contains("다음에는"), "Result must not auto-prescribe the next action.")

    var focus_manual := DEFAULT_STARTERS[0]
    _expect_true(shell.select_result_reward("focused_training", focus_manual), "Focused training reward must be selectable for an owned manual.")
    var receipt: Dictionary = shell.run_state.get_pending_result_reward()
    _expect_eq(str(receipt.get("reward_type", "")), "focused_training", "RunState must retain selected reward type.")
    _expect_eq(str(receipt.get("target_manual_id", "")), focus_manual, "Focused reward must retain its selected manual target.")
    _expect_eq(int(receipt.get("focused_training", 0)), 5, "Focused reward must preserve the approved +5 target value.")
    _expect_eq(int(receipt.get("free_training", 0)), 3, "Focused reward must preserve the approved +3 free value.")
    _expect_false(shell.primary_button.disabled, "Result CTA must enable after a valid reward selection.")

    _expect_true(shell.advance_noncombat(), "Confirmed Result reward must advance to Growth/Recovery Route.")
    _expect_eq(shell.run_state.get_current_screen(), "ROUTE_GROWTH", "Result must leave for the first Route node.")
    _expect_eq(shell.run_state.get_reward_history().size(), 1, "Confirmed reward receipt must move into RunState history exactly once.")
    var next_opponent: Dictionary = shell.run_state.get_route_target_opponent()
    _expect_true(not next_opponent.is_empty(), "Next opponent must lock when confirmed Result leaves for Route.")
    _expect_eq(int(next_opponent.get("duel_slot", 0)), 2, "After Duel 1 Result the locked Route target must be Slot 2.")
    _expect_eq(str(opponent.get("candidate_id", "")), str(shell.run_state.get_current_opponent().get("candidate_id", "")), "Current opponent must remain Duel 1 until Route promotion.")

    shell.queue_free()
    await process_frame


func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)


func _expect_false(value: bool, message: String) -> void:
    if value:
        failures.append(message)


func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])


func _finish() -> void:
    if failures.is_empty():
        print("VERTICAL_SLICE_REVIEW_RESULT_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_REVIEW_RESULT_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
