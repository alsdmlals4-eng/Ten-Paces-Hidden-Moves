extends SceneTree

const RUN_STATE_SCRIPT := preload("res://src/run/vertical_slice_run_state.gd")
const OPPONENT_CATALOG_SCRIPT := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const COMPLETION_MODEL_PATH := "res://src/run/vertical_slice_completion_model.gd"
const STARTERS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear"
]
const REVIEW_CAUSES := ["clash", "range", "clash", "order", "range", "clash", "timing", "range", "order", "timing"]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var completion_script := load(COMPLETION_MODEL_PATH)
    if completion_script == null:
        failures.append("Completion summary model is missing: %s" % COMPLETION_MODEL_PATH)
        _finish()
        return

    var run = RUN_STATE_SCRIPT.new()
    var catalog = OPPONENT_CATALOG_SCRIPT.new()
    _expect_true(catalog.is_valid(), "Opponent catalog must remain valid for completion history.")
    _expect_true(run.configure_opponents(catalog, 20260820), "Completion run must configure deterministic opponents.")
    _expect_true(run.start_new_run(), "Completion run must start.")
    _expect_true(run.confirm_setup_loadout(STARTERS, _starter_mastery()), "Completion run must preserve exact-four starter Setup.")
    _expect_true(run.advance(), "Setup must enter Intro.")
    _expect_true(run.advance(), "Intro must enter Briefing.")

    for duel in range(1, 11):
        _expect_true(run.advance(), "Briefing must enter Combat for Duel %d." % duel)
        var opponent := run.get_current_opponent()
        var result := {
            "outcome": "loss" if duel == 3 else "win",
            "player_resources": {
                "health": [maxi(1, 30 - duel * 2), 30],
                "stamina": [maxi(0, 5 - duel % 3), 5],
                "internal": [maxi(0, 4 - duel % 2), 4]
            },
            "review_summary": {
                "cause_code": REVIEW_CAUSES[duel - 1],
                "cause_label": "test cause %s" % REVIEW_CAUSES[duel - 1],
                "review_focus": "test focus %s" % REVIEW_CAUSES[duel - 1]
            }
        }
        _expect_true(run.mark_combat_finished(result), "Duel %d terminal result must enter Review." % duel)
        _expect_true(run.advance(), "Duel %d Review must advance." % duel)
        if duel == 3:
            _expect_eq(run.get_current_screen(), "FAILURE_RETRY", "The first loss must offer its free retry before Result.")
            _expect_true(run.retry_failed_duel(), "Completion history must retry the loss from the same pre-battle state.")
            var retry_result := result.duplicate(true)
            retry_result["outcome"] = "win"
            _expect_true(run.mark_combat_finished(retry_result), "Retry win must commit the duel once.")
            _expect_true(run.advance(), "Retry Review must enter Result.")
        else:
            _expect_eq(run.get_current_screen(), "RESULT", "Winning Review must enter Result.")

        if duel == 1 or duel == 4:
            _expect_true(run.set_pending_result_reward({"reward_type": "focused_training", "target_manual_id": STARTERS[0], "focused_training": 5, "free_training": 3}), "Focused reward receipt must be accepted.")
        else:
            _expect_true(run.set_pending_result_reward({"reward_type": "free_training", "free_training": 6}), "Free reward receipt must be accepted.")
        _expect_true(run.advance(), "Duel %d reward must advance." % duel)

        if duel < 10:
            _expect_eq(run.get_current_screen(), "JIANGHU", "Every non-final Duel must enter Jianghu.")
            for step in range(4):
                var options: Array = run.get_jianghu_options()
                _expect_eq(options.size(), 3, "Completion fixture Jianghu Step %d must expose three choices." % step)
                if options.size() != 3:
                    continue
                var option_id := str((options[0] as Dictionary).get("id", ""))
                _expect_true(run.select_jianghu_node(option_id, step), "Completion fixture must choose one offered Route.")
                _expect_true(run.advance(), "Completion fixture must confirm each Route choice.")
        else:
            _expect_eq(run.get_current_screen(), "COMPLETION", "Duel 10 Result must enter Completion without another Route.")

        var history: Array = run.get_duel_history()
        _expect_true(history.size() >= duel, "Duel history must contain the completed row before it is inspected.")
        if history.size() >= duel:
            _expect_eq(str((history[duel - 1] as Dictionary).get("opponent_candidate_id", "")), str(opponent.get("candidate_id", "")), "Each duel row must retain its actual opponent.")

    _expect_true(run.is_complete(), "Ten-duel campaign must reach Completion.")
    _expect_eq(run.get_duel_history().size(), 10, "Completion requires ten duel-history rows.")
    _expect_eq(run.get_reward_history().size(), 10, "Completion must retain ten reward receipts.")
    _expect_eq(run.get_route_history().size(), 36, "Completion must retain thirty-six Route receipts.")

    var model = completion_script.new()
    var snapshot: Dictionary = model.build_snapshot(run.get_duel_history(), run.get_reward_history(), run.get_route_history(), run.get_progression_snapshot())
    _expect_eq(str(snapshot.get("status", "")), "STRUCTURED_RUN_SUMMARY", "Completion snapshot must identify itself as a structured run summary.")
    _expect_eq((snapshot.get("duel_rows", []) as Array).size(), 10, "Completion must summarize ten duel outcomes and opponents.")
    _expect_eq((snapshot.get("route_choices", []) as Array).size(), 36, "Completion must summarize all thirty-six Route choices.")
    _expect_eq((snapshot.get("reward_history", []) as Array).size(), 10, "Completion must summarize all ten Duel rewards.")
    var top_causes: Array = snapshot.get("top_review_causes", [])
    _expect_true(top_causes.size() >= 2 and top_causes.size() <= 3, "Completion must show only the top 2-3 Review causes.")
    if top_causes.size() >= 2:
        _expect_eq(int((top_causes[0] as Dictionary).get("count", 0)), 3, "Most common Review cause must retain its actual count.")
        _expect_eq(int((top_causes[1] as Dictionary).get("count", 0)), 3, "Second common Review cause must retain its actual count.")
    var focused_growth: Array = snapshot.get("focused_growth", [])
    _expect_true(focused_growth.size() >= 1 and focused_growth.size() <= 2, "Completion must show only 1-2 most-grown manuals.")
    _expect_true(str(snapshot.get("peer_closing_line", "")).contains("열 번"), "Completion closing copy must describe the ten-duel campaign, not the superseded five-duel slice.")
    var serialized := JSON.stringify(snapshot)
    for forbidden in ["공격형 플레이어", "정답 빌드", "다음 회차의 정답", "ai_weight", "selector_seed", "hidden_plan"]:
        _expect_false(serialized.contains(forbidden), "Completion must not expose diagnosis, answer-build advice, or hidden implementation data: %s" % forbidden)

    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    shell.run_state = run
    shell._render_current_screen()
    var completion_text: String = shell.description_label.text
    _expect_true(completion_text.contains("[합]에서 공격력 차이가 승부를 갈랐다. · 3회"), "Completion must connect counted clashes to canonical player-readable explanation.")
    _expect_true(completion_text.contains("실행 순간 거리가 공격 사거리 밖이었다. · 3회"), "Completion must connect counted ranges to canonical player-readable explanation.")
    _expect_false(completion_text.contains("clash ·"), "Completion must not display raw cause identifiers.")
    _expect_eq(shell.get_completion_snapshot(), snapshot, "Rendering must preserve the original counted history.")
    root.content_scale_size = Vector2i(1280, 720)
    root.size = Vector2i(1280, 720)
    for i in range(5): await process_frame
    _expect_true(root.get_visible_rect().encloses(shell.content_panel.get_global_rect()), "Completion panel must remain within 720p viewport.")
    _expect_true(root.get_visible_rect().encloses(shell.primary_button.get_global_rect()), "Completion footer must remain within 720p viewport.")
    _expect_true(shell.description_label.get_parent() is ScrollContainer, "Long completion history must remain scrollable.")
    if shell.description_label.get_parent() is ScrollContainer:
        var scroll: ScrollContainer = shell.description_label.get_parent()
        scroll.scroll_vertical = 10000
        await process_frame
        _expect_true(scroll.scroll_vertical > 0, "All ten duel rows and closing line must be reachable by scrolling.")
    var capture_args := OS.get_cmdline_user_args()
    if DisplayServer.get_name() != "headless" and not capture_args.is_empty():
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(capture_args[0])
    shell._set_content("Other screen", "Restored description", "Continue")
    _expect_eq(shell.description_label.get_parent(), shell.primary_button.get_parent(), "Leaving completion must restore the shared description parent.")
    shell.queue_free()
    await process_frame

    var malformed_snapshot: Dictionary = model.build_snapshot([null, [], {"outcome": "win"}], [null, []], [null, []], {})
    _expect_eq((malformed_snapshot.get("duel_rows", []) as Array).size(), 1, "Completion sanitization must skip unexpected array members without indexing them.")
    _expect_true((malformed_snapshot.get("reward_history", []) as Array).is_empty(), "Malformed reward rows must be skipped safely.")
    _expect_true((malformed_snapshot.get("route_choices", []) as Array).is_empty(), "Malformed Route rows must be skipped safely.")
    _finish()


func _starter_mastery() -> Dictionary:
    var result := {}
    for manual_id in STARTERS:
        result[manual_id] = 3
    return result


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
