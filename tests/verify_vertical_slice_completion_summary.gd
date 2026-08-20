extends SceneTree

const SHELL_SCENE := preload("res://scenes/run/vertical_slice_shell.tscn")
const COMPLETION_MODEL_PATH := "res://src/run/vertical_slice_completion_model.gd"
const DEFAULT_STARTERS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear"
]
const REVIEW_CAUSES := ["clash", "range", "clash", "defense", "clash"]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    if not ResourceLoader.exists(COMPLETION_MODEL_PATH):
        failures.append("Completion Summary model is missing: %s" % COMPLETION_MODEL_PATH)
        _finish()
        return

    var shell = SHELL_SCENE.instantiate()
    root.add_child(shell)
    if shell is Control:
        shell.set_anchors_preset(Control.PRESET_TOP_LEFT)
        shell.size = Vector2(1440.0, 900.0)
    for _index in range(3):
        await process_frame

    _expect_true(shell.has_method("get_completion_snapshot"), "Completion shell must expose a read-only completion snapshot.")
    _expect_true(shell.start_new_run(), "Completion test run must start.")
    for manual_id in DEFAULT_STARTERS:
        _expect_true(shell.toggle_setup_manual(manual_id), "Starter selection must succeed: %s" % manual_id)
    _expect_true(shell.advance_noncombat(), "SETUP → INTRO")
    _expect_true(shell.advance_noncombat(), "INTRO → BRIEFING")

    for duel_index in range(1, 6):
        _expect_true(shell.advance_noncombat(), "Briefing → Combat for Duel %d" % duel_index)
        await process_frame
        var cause_code := REVIEW_CAUSES[duel_index - 1]
        var terminal_result := {
            "terminal": true,
            "outcome": "win" if duel_index != 4 else "loss",
            "player_health": 30,
            "enemy_health": 0 if duel_index != 4 else 10,
            "player_resources": {
                "health": [30, 30],
                "stamina": [5, 5],
                "internal": [4, 4]
            },
            "battle_metrics": {
                "successful_dodges": 0,
                "clash_wins": 1 if cause_code == "clash" else 0,
                "player_health_lost": 0,
                "rounds_elapsed": 2,
                "ultimate_uses": 0
            },
            "review_summary": {
                "cause_code": cause_code,
                "cause_label": cause_code,
                "review_focus": "test_%s" % cause_code
            },
            "presentation_state": "review_ready"
        }
        _expect_true(shell.complete_combat_for_runtime(terminal_result), "Duel %d terminal result must enter Review." % duel_index)
        _expect_true(shell.complete_review_for_runtime(), "Duel %d Review must enter Result." % duel_index)

        if duel_index == 1:
            _expect_true(shell.select_result_reward("focused_training", DEFAULT_STARTERS[0]), "Duel 1 must select focused training reward.")
        else:
            _expect_true(shell.select_result_reward("free_training"), "Duel %d must select free training reward." % duel_index)
        _expect_true(shell.advance_noncombat(), "Duel %d confirmed Result must advance." % duel_index)

        if duel_index < 5:
            if duel_index == 1:
                _expect_true(shell.select_growth_route("focused_training", DEFAULT_STARTERS[0]), "R1 must focus the same starter manual.")
            else:
                _expect_true(shell.select_growth_route("free_training"), "Later Growth Route uses legal free training in this regression.")
            _expect_true(shell.advance_noncombat(), "Growth Route must advance to Info Route after one choice.")
            var info_options: Array = shell.run_state.get_info_route_options()
            _expect_eq(info_options.size(), 3, "Every Info Route must expose exactly three choices.")
            if info_options.size() == 3:
                _expect_true(shell.select_info_route(str((info_options[0] as Dictionary).get("category", ""))), "One public Route clue must be selected.")
            _expect_true(shell.advance_noncombat(), "Info Route must advance to the next Briefing.")

    _expect_eq(shell.run_state.get_current_screen(), "COMPLETION", "Fifth confirmed Result must end at Completion.")
    _expect_true(shell.run_state.is_complete(), "RunState must report five-duel completion.")

    var snapshot: Dictionary = shell.call("get_completion_snapshot")
    _expect_eq((snapshot.get("duels", []) as Array).size(), 5, "Completion must summarize exactly five duel outcomes.")
    _expect_eq((snapshot.get("rewards", []) as Array).size(), 5, "Completion must summarize exactly five confirmed Duel rewards.")
    _expect_eq((snapshot.get("route_info", []) as Array).size(), 4, "Completion must summarize the four chosen Info Route categories.")

    var top_causes: Array = snapshot.get("top_review_causes", [])
    _expect_true(top_causes.size() >= 1 and top_causes.size() <= 3, "Completion must expose at most three frequent Review causes.")
    if not top_causes.is_empty():
        _expect_eq(str((top_causes[0] as Dictionary).get("cause_code", "")), "clash", "Most frequent Review cause must be derived from actual five-duel history.")
        _expect_eq(int((top_causes[0] as Dictionary).get("count", 0)), 3, "Clash must be counted three times from the supplied history.")

    var focused_manuals: Array = snapshot.get("focused_manuals", [])
    _expect_true(not focused_manuals.is_empty(), "Completion must surface at least one actually trained manual when training occurred.")
    if not focused_manuals.is_empty():
        _expect_eq(str((focused_manuals[0] as Dictionary).get("manual_id", "")), DEFAULT_STARTERS[0], "Most-trained manual must come from actual progression history.")
        _expect_eq(int((focused_manuals[0] as Dictionary).get("training_points", 0)), 6, "Duel1 +5 and R1 +1 must total six focused training points.")

    _expect_eq(str(snapshot.get("peer_comment", "")), "다섯 번 싸워서 다섯 명을 안 건 아니겠지. 네가 어떤 수를 두는 사람인지는 조금 알았을 테고.", "Completion must reuse the approved short final peer beat.")
    _expect_eq(str(snapshot.get("diagnosis_status", "")), "NOT_GENERATED", "Completion must not generate a personality/playstyle diagnosis.")

    var rendered_text := "%s\n%s" % [shell.title_label.text, shell.description_label.text]
    _expect_true(rendered_text.contains("비무행 완주"), "Completion screen must identify the five-duel run as complete.")
    for forbidden in ["공격형 플레이어", "정답 빌드", "추천 빌드", "AI 가중치", "승률"]:
        _expect_false(rendered_text.contains(forbidden), "Completion must not contain forbidden diagnosis/internal-answer text: %s" % forbidden)
    _expect_true(bool(shell.get_meta("completion_visual_status", "") == "STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL"), "Completion must remain functional UI, not final visual evidence.")

    shell.queue_free()
    await process_frame
    _finish()


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
        print("VERTICAL_SLICE_COMPLETION_SUMMARY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_COMPLETION_SUMMARY_VERIFY_FAILED count=%d" % failures.size())
    quit(1)