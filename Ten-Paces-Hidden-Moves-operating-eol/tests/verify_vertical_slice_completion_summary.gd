extends SceneTree

const RUN_STATE_SCRIPT := preload("res://src/run/vertical_slice_run_state.gd")
const OPPONENT_CATALOG_SCRIPT := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const COMPLETION_MODEL_PATH := "res://src/run/vertical_slice_completion_model.gd"
const SHELL_SCENE_PATH := "res://scenes/run/vertical_slice_shell.tscn"
const STARTERS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear"
]
const REVIEW_CAUSES := ["clash", "range", "clash", "order", "range"]

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
    _expect_true(run.confirm_setup_loadout(STARTERS, _starter_mastery()), "Completion run must preserve exact-four starter setup.")
    _expect_true(run.advance(), "SETUP → INTRO")
    _expect_true(run.advance(), "INTRO → BRIEFING")

    for duel in range(1, 6):
        _expect_true(run.advance(), "BRIEFING → COMBAT for Duel %d" % duel)
        var opponent := run.get_current_opponent()
        var result := {
            "terminal": true,
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
        _expect_true(run.advance(), "Duel %d Review → Result." % duel)

        if duel == 1 or duel == 4:
            _expect_true(run.set_pending_result_reward({
                "reward_type": "focused_training",
                "target_manual_id": STARTERS[0],
                "focused_training": 5,
                "free_training": 3
            }), "Focused reward receipt must be accepted.")
        else:
            _expect_true(run.set_pending_result_reward({"reward_type": "free_training", "free_training": 6}), "Free reward receipt must be accepted.")

        if duel < 5:
            _expect_true(run.advance(), "Duel %d Result → Growth Route." % duel)
            _expect_true(run.select_growth_route("focused_training", STARTERS[1]), "Growth Route focus must be selectable.")
            _expect_true(run.advance(), "Growth Route → Info Route.")
            var info_options: Array = run.get_info_route_options()
            _expect_eq(info_options.size(), 3, "Info Route must keep exactly three options.")
            if info_options.size() == 3:
                _expect_true(run.select_info_route(str((info_options[0] as Dictionary).get("category", ""))), "One public Route clue must be selectable.")
            _expect_true(run.advance(), "Info Route → next Briefing.")
        else:
            _expect_true(run.advance(), "Duel 5 Result → Completion.")

        _expect_eq(str(opponent.get("candidate_id", "")), str((run.get_duel_history()[duel - 1] as Dictionary).get("opponent_candidate_id", "")), "Each duel history row must retain its actual opponent.")

    _expect_true(run.is_complete(), "Five-duel run must reach Completion.")
    _expect_eq(run.get_duel_history().size(), 5, "Completion requires exactly five retained duel-history rows.")
    _expect_eq(run.get_reward_history().size(), 5, "Completion must retain five reward receipts.")
    _expect_eq(run.get_route_history().size(), 8, "Completion must retain eight Route receipts.")

    var model = completion_script.new()
    var snapshot: Dictionary = model.build_snapshot(
        run.get_duel_history(),
        run.get_reward_history(),
        run.get_route_history(),
        run.get_progression_snapshot()
    )
    _expect_eq(str(snapshot.get("status", "")), "STRUCTURED_RUN_SUMMARY", "Completion snapshot must identify itself as a structured run summary.")
    _expect_eq((snapshot.get("duel_rows", []) as Array).size(), 5, "Completion must summarize five duel outcomes/opponents.")
    _expect_eq((snapshot.get("route_choices", []) as Array).size(), 8, "Completion must summarize all eight Route choices.")
    _expect_eq((snapshot.get("reward_history", []) as Array).size(), 5, "Completion must summarize all five Duel rewards.")

    var top_causes: Array = snapshot.get("top_review_causes", [])
    _expect_true(top_causes.size() >= 2 and top_causes.size() <= 3, "Completion must show only the top 2-3 Review causes.")
    if top_causes.size() >= 2:
        _expect_eq(int((top_causes[0] as Dictionary).get("count", 0)), 2, "Most common Review causes must retain actual counts.")
        _expect_eq(int((top_causes[1] as Dictionary).get("count", 0)), 2, "Second common Review cause must retain actual counts.")

    var focused_growth: Array = snapshot.get("focused_growth", [])
    _expect_true(focused_growth.size() >= 1 and focused_growth.size() <= 2, "Completion must show only 1-2 most-grown manuals.")
    _expect_true(not str(snapshot.get("peer_closing_line", "")).is_empty(), "Completion must include the approved brief recurring-peer ending beat.")

    var serialized := JSON.stringify(snapshot)
    for forbidden in ["공격형 플레이어", "정답 빌드", "다음 회차의 정답", "ai_weight", "selector_seed", "hidden_plan"]:
        _expect_false(serialized.contains(forbidden), "Completion must not expose diagnosis, answer-build advice, or hidden implementation data: %s" % forbidden)

    var packed := load(SHELL_SCENE_PATH) as PackedScene
    _expect_true(packed != null, "Completion shell scene must remain loadable.")
    if packed != null:
        var shell = packed.instantiate()
        root.add_child(shell)
        for _index in range(3):
            await process_frame
        _expect_true(shell.has_method("get_completion_snapshot"), "Runtime shell must expose its structured Completion snapshot.")
        _expect_eq(str(shell.get_meta("completion_visual_status", "")), "STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL", "Completion UI must not claim final visual approval.")
        shell.queue_free()
        await process_frame

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
