extends SceneTree

const RUN_STATE_PATH := "res://src/run/vertical_slice_run_state.gd"
const OPPONENT_CATALOG_SCRIPT := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const STARTERS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear"
]
const FIRST_INTERVAL_CHOICES := ["training", "recon", "event", "rest"]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var script := load(RUN_STATE_PATH)
    if script == null:
        failures.append("Vertical Slice run-state script is missing: %s" % RUN_STATE_PATH)
        _finish()
        return

    var run = script.new()
    var opponent_catalog = OPPONENT_CATALOG_SCRIPT.new()
    _expect_true(opponent_catalog.is_valid(), "Opponent catalog must be valid for the full campaign flow.")
    _expect_true(run.configure_opponents(opponent_catalog, 20260820), "Full campaign flow must configure deterministic opponent locks.")
    _expect_eq(run.get_current_screen(), "MAIN", "A new run state must begin at Main.")
    _expect_eq(run.duel_index, 1, "The first duel must be active before a new run starts.")
    _expect_true(run.start_new_run(), "Main must enter Setup through start_new_run().")
    var setup_before: Dictionary = run.get_progression_snapshot()
    var invented := ["invented_one", "invented_two", "invented_three", "invented_four"]
    _expect_false(run.confirm_setup_loadout(invented, _mastery_for(invented)), "Setup must reject four invented manual IDs even when their mastery values are 3.")
    _expect_eq(run.get_progression_snapshot(), setup_before, "Rejected invented IDs must not partially mutate progression.")
    _expect_true(run.get_player_manual_loadout().is_empty(), "Rejected invented IDs must not partially mutate the retained loadout.")
    var mixed_invalid := STARTERS.duplicate()
    mixed_invalid[3] = "invented_mixed_manual"
    _expect_false(run.confirm_setup_loadout(mixed_invalid, _mastery_for(mixed_invalid)), "Setup must reject a mixed selection containing one non-starter ID.")
    _expect_eq(run.get_progression_snapshot(), setup_before, "Rejected mixed IDs must not partially mutate progression.")
    _expect_true(run.get_player_manual_loadout().is_empty(), "Rejected mixed IDs must not partially mutate the retained loadout.")
    _expect_true(run.confirm_setup_loadout(STARTERS, _starter_mastery()), "Setup must accept exactly four starter manuals at mastery 3.")
    _expect_true(run.advance(), "Setup must advance to Intro.")
    _expect_true(run.advance(), "Intro must advance to Briefing.")

    for expected_duel in range(1, 11):
        _expect_eq(run.get_current_screen(), "BRIEFING", "Campaign Duel %d must begin at Briefing." % expected_duel)
        _expect_eq(run.duel_index, expected_duel, "Duel index must remain synchronized with the current Briefing.")
        _expect_true(run.advance(), "Briefing must advance to Combat.")
        _expect_false(run.advance(), "Combat may not skip directly to Review without a terminal result.")
        var result := {"outcome": "win", "duel_index": expected_duel}
        if expected_duel == 1:
            result["player_resources"] = {"health": [12, 40], "stamina": [2, 5], "internal": [1, 4]}
        _expect_true(run.mark_combat_finished(result), "Duel %d terminal result must enter Review." % expected_duel)
        _expect_eq(run.get_current_screen(), "REVIEW", "Combat result must enter Review first.")
        _expect_true(run.advance(), "Review must advance to Result.")
        _expect_false(run.advance(), "Result may not advance before one reward is selected.")
        _expect_true(run.set_pending_result_reward({"reward_type": "free_training", "free_training": 6}), "Result must accept one valid reward receipt.")
        _expect_true(run.advance(), "A confirmed reward must advance once.")

        if expected_duel == 10:
            _expect_eq(run.get_current_screen(), "COMPLETION", "The tenth result must advance directly to Completion.")
            _expect_false(run.advance(), "Completion must not create an eleventh duel or post-final Route.")
            break

        _expect_eq(run.get_current_screen(), "JIANGHU", "Every non-final result must enter one Jianghu interval.")
        var locked_target_id := str(run.get_route_target_opponent().get("candidate_id", ""))
        _expect_true(not locked_target_id.is_empty(), "Jianghu must target the locked next opponent.")
        for step in range(4):
            var options: Array = run.get_jianghu_options()
            _expect_eq(options.size(), 3, "Jianghu Step %d must expose exactly three choices." % step)
            if options.size() != 3:
                continue
            var requested_id: String = str(FIRST_INTERVAL_CHOICES[step]) if expected_duel == 1 else str((options[0] as Dictionary).get("id", ""))
            _expect_true(_contains_option(options, requested_id), "Requested Jianghu fixture choice must be offered: %s" % requested_id)
            var before: Dictionary = run.get_progression_snapshot()
            _expect_true(run.select_jianghu_node(requested_id, step), "Offered Jianghu choice must apply at Step %d." % step)
            var after_first: Dictionary = run.get_progression_snapshot()
            _expect_false(run.select_jianghu_node(requested_id, step), "The same Jianghu step may not apply twice.")
            _expect_eq(run.get_progression_snapshot(), after_first, "Rejected duplicate input must not apply its effect again.")
            _expect_true(run.advance(), "A selected Jianghu step must confirm.")
            if step < 3:
                _expect_false(run.advance(), "A confirmed Jianghu step may not advance again without a new choice.")
                _expect_eq(str(run.get_route_target_opponent().get("candidate_id", "")), locked_target_id, "Locked target must remain stable throughout the interval.")
            _expect_eq(run.get_progression_snapshot(), after_first, "Confirming a route receipt must not reapply the already-selected effect.")
            if expected_duel == 1:
                _expect_true(before != after_first or requested_id == "recon", "Each non-intel first-interval fixture choice must cause its documented state change.")

        if expected_duel == 1:
            var first_interval: Dictionary = run.get_progression_snapshot()
            _expect_eq(int(first_interval.get("free_training_pool", -1)), 11, "Reward +6, training +3, and event +2 must each apply exactly once.")
            _expect_eq(first_interval.get("player_resources", {}), {"health": [22, 40], "stamina": [3, 5], "internal": [3, 4]}, "Event and rest recovery must each apply once with caps.")
        _expect_eq(run.get_current_screen(), "BRIEFING", "The fourth Jianghu choice must enter the next Briefing.")
        _expect_eq(run.duel_index, expected_duel + 1, "The interval must increment the duel index exactly once.")
        _expect_eq(str(run.get_current_opponent().get("candidate_id", "")), locked_target_id, "The locked target must promote without reroll.")

    _expect_true(run.is_complete(), "Ten completed duels must mark the campaign complete.")
    _expect_eq(run.route_visits, 36, "Nine intervals must create exactly thirty-six committed Route visits.")
    _expect_eq(run.completed_duels, 10, "The campaign must record exactly ten completed duels.")
    _expect_eq(run.get_reward_history().size(), 10, "Each duel must confirm exactly one reward receipt.")
    _expect_eq(run.get_route_history().size(), 36, "Each Jianghu choice must confirm exactly one route receipt.")
    var history: Array = run.get_flow_history()
    _expect_eq(history.count("REVIEW"), 10, "Each duel must visit Review exactly once.")
    _expect_eq(history.count("RESULT"), 10, "Each duel must visit Result exactly once.")
    _expect_eq(history.count("JIANGHU"), 9, "Only the nine inter-duel intervals enter Jianghu.")
    _expect_eq(history[history.size() - 1] if not history.is_empty() else "", "COMPLETION", "The campaign must terminate at Completion.")
    _finish()


func _contains_option(options: Array, option_id: String) -> bool:
    for value in options:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("id", "")) == option_id:
            return true
    return false


func _starter_mastery() -> Dictionary:
    var result := {}
    for manual_id in STARTERS:
        result[manual_id] = 3
    return result


func _mastery_for(manual_ids: Array) -> Dictionary:
    var result := {}
    for manual_id in manual_ids:
        result[str(manual_id)] = 3
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
        print("VERTICAL_SLICE_RUN_STATE_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_RUN_STATE_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
