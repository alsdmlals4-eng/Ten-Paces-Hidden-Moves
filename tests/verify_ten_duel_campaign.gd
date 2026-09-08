extends SceneTree

const RunStateScript := preload("res://src/run/vertical_slice_run_state.gd")
const CatalogScript := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const BindingScript := preload("res://src/run/vertical_slice_opponent_runtime_binding.gd")
const STARTERS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear"
]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    _verify_campaign_catalog_bindings()
    _verify_invalid_outcomes_fail_closed()
    _verify_reward_selection_is_idempotent()
    _verify_complete_campaign()
    _finish()


func _verify_campaign_catalog_bindings() -> void:
    var catalog = CatalogScript.new()
    var binding = BindingScript.new()
    _expect_true(catalog.is_valid(), "The campaign catalog must load without contract errors.")
    _expect_true(binding.is_valid(), "The runtime binding catalog must load.")
    var seen := {}
    for duel_number in range(1, 11):
        var candidate_id := str(catalog.select_campaign_candidate_id(duel_number))
        _expect_true(not candidate_id.is_empty(), "Campaign Duel %d must resolve an opponent." % duel_number)
        _expect_false(seen.has(candidate_id), "The ten-duel campaign must not repeat candidate %s." % candidate_id)
        seen[candidate_id] = true
        var candidate: Dictionary = catalog.get_candidate(candidate_id)
        _expect_true(not candidate.is_empty(), "Campaign candidate %s must resolve from the approved catalog." % candidate_id)
        _expect_true(bool(binding.build(candidate).get("valid", false)), "Campaign candidate %s must retain a valid combat binding." % candidate_id)
        _expect_eq(int(candidate.get("duel_slot", 0)), int((duel_number + 1) / 2), "Campaign order must preserve the original difficulty-slot cadence.")
    _expect_eq(seen.size(), 10, "Campaign order must contain ten distinct valid bindings.")
    _expect_eq(catalog.select_campaign_candidate_id(0), "", "Campaign lookup must reject Duel 0.")
    _expect_eq(catalog.select_campaign_candidate_id(11), "", "Campaign lookup must reject a post-final duel.")


func _verify_invalid_outcomes_fail_closed() -> void:
    for invalid_outcome in ["", "victory", "timeout", "WIN"]:
        var run = _new_combat_run()
        _expect_false(run.mark_combat_finished({"outcome": invalid_outcome}), "Invalid terminal outcome must be rejected: %s" % invalid_outcome)
        _expect_eq(run.get_current_screen(), "COMBAT", "Rejected outcome must leave the current combat active.")
        _expect_eq(run.completed_duels, 0, "Rejected outcome must not complete a duel.")
        _expect_true(run.get_duel_history().is_empty(), "Rejected outcome must not append duel history.")
    var malformed_resources_run = _new_combat_run()
    _expect_false(malformed_resources_run.mark_combat_finished({"outcome": "win", "player_resources": {"health": []}}), "A terminal result with malformed resource pairs must fail closed.")
    _expect_eq(malformed_resources_run.get_current_screen(), "COMBAT", "Malformed terminal resources must leave Combat active.")
    _expect_true(malformed_resources_run.get_duel_history().is_empty(), "Malformed terminal resources must not append duel history.")
    var draw_run = _new_combat_run()
    _expect_true(draw_run.mark_combat_finished({"outcome": "draw"}), "The canonical simultaneous-KO draw must remain a valid terminal result.")
    _expect_eq(draw_run.completed_duels, 1, "A valid draw must retain the existing completed-duel semantics.")


func _verify_reward_selection_is_idempotent() -> void:
    var run = _new_combat_run()
    _expect_true(run.mark_combat_finished({"outcome": "win"}), "Reward idempotence fixture must finish one duel.")
    _expect_true(run.advance(), "Winning Review must enter Result.")
    var first_reward := {"reward_type": "free_training", "free_training": 6}
    _expect_true(run.set_pending_result_reward(first_reward), "The first valid reward choice must be accepted.")
    _expect_false(run.set_pending_result_reward({"reward_type": "free_training", "free_training": 99}), "A second reward choice must not replace the pending receipt.")
    _expect_eq(run.get_pending_result_reward(), first_reward, "Rejected duplicate reward input must preserve the first receipt.")
    _expect_true(run.advance(), "The first reward receipt must commit once.")
    _expect_eq(run.get_reward_history().size(), 1, "Reward confirmation must append exactly one receipt.")
    _expect_eq(int(run.get_progression_snapshot().get("free_training_pool", -1)), 6, "Only the first reward amount may apply.")


func _verify_complete_campaign() -> void:
    var state = _new_combat_run()
    var enemies: Array[String] = []
    for duel_number in range(1, 11):
        _expect_eq(state.get_current_screen(), "COMBAT", "Campaign fixture must reach Combat %d." % duel_number)
        var enemy: Dictionary = state.get_current_opponent()
        var enemy_id := str(enemy.get("candidate_id", ""))
        _expect_true(not enemy_id.is_empty(), "Opponent must exist for Duel %d." % duel_number)
        _expect_false(enemy_id in enemies, "Campaign opponent must not repeat: %s" % enemy_id)
        enemies.append(enemy_id)
        _expect_true(state.mark_combat_finished({"outcome": "win"}), "Duel %d terminal result must be accepted once." % duel_number)
        _expect_false(state.mark_combat_finished({"outcome": "win"}), "Duplicate Duel %d terminal result must be rejected." % duel_number)
        _expect_true(state.advance(), "Duel %d Review must enter Result." % duel_number)
        _expect_true(state.set_pending_result_reward({"reward_type": "free_training", "free_training": 6}), "Duel %d reward must be selectable." % duel_number)
        _expect_true(state.advance(), "Duel %d reward must advance once." % duel_number)
        if duel_number == 10:
            _expect_true(state.is_complete(), "The tenth reward must complete the campaign.")
            _expect_eq(state.get_current_screen(), "COMPLETION", "The final result must not create a post-final Route.")
            _expect_true(state.get_jianghu_options().is_empty(), "Completion must expose no Jianghu candidates.")
            _expect_false(state.advance(), "Completion must be terminal for the campaign state model.")
            break
        _expect_eq(state.get_current_screen(), "JIANGHU", "Each non-final duel must enter the four-choice Jianghu interval.")
        var locked_target_id := str(state.get_route_target_opponent().get("candidate_id", ""))
        _expect_true(not locked_target_id.is_empty(), "Each Jianghu interval must lock its next opponent before selection.")
        for step in range(4):
            var options: Array = state.get_jianghu_options()
            _expect_eq(options.size(), 3, "Each Jianghu step must expose exactly three candidates.")
            if options.size() != 3:
                continue
            var option_ids: Array[String] = []
            for option_value in options:
                if typeof(option_value) == TYPE_DICTIONARY:
                    option_ids.append(str((option_value as Dictionary).get("id", "")))
            _expect_eq(option_ids.size(), 3, "All three Jianghu candidates must be structured choices.")
            _expect_eq(_unique_count(option_ids), 3, "A Jianghu step must show three distinct choices.")
            _expect_false(state.advance(), "Jianghu Step %d may not be skipped." % step)
            var selected_id := option_ids[0] if not option_ids.is_empty() else ""
            _expect_true(state.select_jianghu_node(selected_id, step), "One offered Jianghu candidate must be selectable at Step %d." % step)
            _expect_false(state.select_jianghu_node(selected_id, step), "Double selection must be rejected at Step %d." % step)
            _expect_eq(str(state.get_route_target_opponent().get("candidate_id", "")), locked_target_id, "Jianghu choices must not reroll the locked opponent.")
            _expect_true(state.advance(), "Selected Jianghu Step %d must confirm." % step)
        _expect_eq(state.get_current_screen(), "BRIEFING", "The fourth choice must enter the next Briefing.")
        _expect_true(state.advance(), "The next Briefing must enter Combat.")
    _expect_eq(enemies.size(), 10, "The campaign must visit ten distinct opponents.")
    _expect_eq(state.get_duel_history().size(), 10, "Campaign completion must retain ten duel receipts.")
    _expect_eq(state.get_reward_history().size(), 10, "Campaign completion must retain ten reward receipts.")
    _expect_eq(state.get_route_history().size(), 36, "Nine intervals must retain exactly thirty-six Route receipts.")
    _expect_eq(state.route_visits, 36, "Route visit count must equal the thirty-six committed choices.")


func _new_combat_run():
    var run = RunStateScript.new()
    var catalog = CatalogScript.new()
    _expect_true(run.configure_opponents(catalog, 20260908), "Campaign fixture must configure the opponent catalog.")
    _expect_true(run.start_new_run(), "Campaign fixture must enter Setup.")
    _expect_true(run.confirm_setup_loadout(STARTERS, _starter_mastery()), "Campaign fixture must accept four starter manuals.")
    _expect_true(run.advance(), "Campaign fixture Setup must enter Intro.")
    _expect_true(run.advance(), "Campaign fixture Intro must enter Briefing.")
    _expect_true(run.advance(), "Campaign fixture Briefing must enter Combat.")
    return run


func _starter_mastery() -> Dictionary:
    var result := {}
    for manual_id in STARTERS:
        result[manual_id] = 3
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
        print("TEN_DUEL_CAMPAIGN_STATE_OK (synthetic terminal results; not full battle playthrough)")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("TEN_DUEL_CAMPAIGN_STATE_FAILED count=%d" % failures.size())
    quit(1)
