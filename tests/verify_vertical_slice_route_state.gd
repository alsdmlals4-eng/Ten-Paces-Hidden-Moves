extends SceneTree

const RunStateScript := preload("res://src/run/vertical_slice_run_state.gd")
const CatalogScript := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const RouteModelScript := preload("res://src/run/vertical_slice_route_model.gd")
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
    _verify_route_model_boundaries()
    _verify_route_effects_and_receipts()
    _finish()


func _verify_route_model_boundaries() -> void:
    var model = RouteModelScript.new()
    _expect_true(model.has_method("get_jianghu_options"), "Route model must own Jianghu candidate generation.")
    if not model.has_method("get_jianghu_options"):
        return
    for completed_duels in range(1, 10):
        for step in range(4):
            var options: Array = model.get_jianghu_options(completed_duels, step)
            _expect_eq(options.size(), 3, "Every one of four Jianghu steps in Interval %d must expose three choices." % completed_duels)
            _expect_eq(_option_ids(options).size(), 3, "Every Jianghu choice must have a non-empty ID.")
            _expect_eq(_unique_count(_option_ids(options)), 3, "Each Jianghu step must expose three distinct choices.")
    for invalid_pair in [[0, 0], [10, 0], [1, -1], [1, 4]]:
        _expect_true(model.get_jianghu_options(invalid_pair[0], invalid_pair[1]).is_empty(), "Route model must reject interval/step outside the 9×4 campaign boundary.")


func _verify_route_effects_and_receipts() -> void:
    var run = _new_combat_run()
    var duel_one_opponent_id := str(run.get_current_opponent().get("candidate_id", ""))
    var terminal_result := {
        "outcome": "win",
        "player_resources": {"health": [12, 40], "stamina": [2, 5], "internal": [1, 4]},
        "battle_metrics": {"successful_dodges": 1, "clash_wins": 1, "player_health_lost": 28, "rounds_elapsed": 3, "ultimate_uses": 0},
        "review_summary": {"cause_code": "clash", "review_focus": "합의 원인"}
    }
    _expect_true(run.mark_combat_finished(terminal_result), "Terminal result must enter Review.")
    _expect_eq(run.get_player_run_resources(), terminal_result["player_resources"], "RunState must persist terminal player resources.")
    _expect_true(run.advance(), "Review must enter Result.")
    _expect_true(run.set_pending_result_reward({"reward_type": "focused_training", "target_manual_id": STARTERS[0], "focused_training": 5, "free_training": 3}), "Focused result reward must be selectable.")
    _expect_true(run.advance(), "Reward-confirmed Result must enter Jianghu.")
    _expect_eq(run.get_current_screen(), "JIANGHU", "The new Route is one four-step Jianghu interval.")
    var rewarded: Dictionary = run.get_progression_snapshot()
    _expect_eq(int(rewarded.get("free_training_pool", -1)), 3, "Focused duel reward must apply +3 free training before Jianghu renders.")
    _expect_eq(int((rewarded.get("training_by_manual", {}) as Dictionary).get(STARTERS[0], -1)), 5, "Focused duel reward must apply +5 exactly once.")
    var locked_next: Dictionary = run.get_route_target_opponent()
    var locked_id := str(locked_next.get("candidate_id", ""))
    _expect_true(not locked_id.is_empty(), "Jianghu must target an already-locked next opponent.")
    _expect_eq(int(locked_next.get("duel_slot", 0)), 1, "Duel 2 uses the second distinct Slot-1 binding in the ten-duel cadence.")

    for step in range(4):
        var options: Array = run.get_jianghu_options()
        _expect_eq(options.size(), 3, "Jianghu Step %d must expose exactly three choices." % step)
        if options.size() != 3:
            continue
        var choice_id: String = str(FIRST_INTERVAL_CHOICES[step])
        _expect_true(choice_id in _option_ids(options), "The deterministic first interval must offer %s at Step %d." % [choice_id, step])
        var before: Dictionary = run.get_progression_snapshot()
        _expect_true(run.select_jianghu_node(choice_id, step), "The offered %s Route must be selectable." % choice_id)
        var once: Dictionary = run.get_progression_snapshot()
        _expect_false(run.select_jianghu_node(choice_id, step), "A selected Route effect must reject duplicate input.")
        _expect_eq(run.get_progression_snapshot(), once, "Duplicate input must not apply %s twice." % choice_id)
        if choice_id == "recon":
            var pending_intel: Dictionary = run.get_pending_jianghu()
            var intel_text := str(pending_intel.get("text", ""))
            _expect_true(not intel_text.is_empty(), "Recon must produce one public clue.")
            _expect_eq(str(pending_intel.get("candidate_id", "")), locked_id, "Recon clue must remain scoped to the locked opponent.")
            _expect_false(intel_text.contains(str(locked_next.get("behavior_focus", ""))), "Recon must not expose internal behavior keys.")
            _expect_false(intel_text.contains("AI 가중치") or intel_text.contains("현재 계획"), "Recon must not expose weights or hidden plans.")
            _expect_eq(before, once, "Recon must not mutate player progression.")
        else:
            _expect_true(before != once, "%s must apply its documented progression effect." % choice_id)
        _expect_true(run.advance(), "A selected Route receipt must confirm once.")
        if step < 3:
            _expect_false(run.advance(), "A confirmed step must wait for the next choice.")
        _expect_eq(run.get_progression_snapshot(), once, "Receipt confirmation must not reapply %s." % choice_id)
        _expect_eq(run.get_route_history().size(), step + 1, "Each confirmed step must append exactly one Route receipt.")
        var receipt: Dictionary = run.get_route_history()[step] if run.get_route_history().size() > step else {}
        _expect_eq(str(receipt.get("node_id", "")), "J1-%d" % (step + 1), "Route receipt must preserve its exact interval-step identity.")

    _expect_eq(run.get_current_screen(), "BRIEFING", "The fourth confirmed choice must enter Duel 2 Briefing.")
    _expect_eq(str(run.get_current_opponent().get("candidate_id", "")), locked_id, "The locked Route target must promote without reroll.")
    _expect_eq(run.get_progression_snapshot().get("player_resources", {}), {"health": [22, 40], "stamina": [3, 5], "internal": [3, 4]}, "Event and rest effects must apply once with resource caps.")
    _expect_eq(int(run.get_progression_snapshot().get("free_training_pool", -1)), 8, "Focused reward +3, training +3, and event +2 must apply once each.")
    _expect_eq(str((run.get_reward_history()[0] as Dictionary).get("opponent_candidate_id", "")), duel_one_opponent_id, "Duel reward history must remain associated with Duel 1 opponent.")


func _new_combat_run():
    var run = RunStateScript.new()
    var catalog = CatalogScript.new()
    _expect_true(run.configure_opponents(catalog, 20260908), "Route fixture must configure opponents.")
    _expect_true(run.start_new_run(), "Route fixture must start.")
    _expect_true(run.confirm_setup_loadout(STARTERS, _starter_mastery()), "Route fixture must accept starter manuals.")
    _expect_true(run.advance(), "Setup must enter Intro.")
    _expect_true(run.advance(), "Intro must enter Briefing.")
    _expect_true(run.advance(), "Briefing must enter Combat.")
    return run


func _starter_mastery() -> Dictionary:
    var result := {}
    for manual_id in STARTERS:
        result[manual_id] = 3
    return result


func _option_ids(options: Array) -> Array[String]:
    var result: Array[String] = []
    for value in options:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var option_id := str((value as Dictionary).get("id", ""))
        if not option_id.is_empty():
            result.append(option_id)
    return result


func _unique_count(values: Array[String]) -> int:
    var seen := {}
    for value in values:
        seen[value] = true
    return seen.size()


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
        print("VERTICAL_SLICE_ROUTE_STATE_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_ROUTE_STATE_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
