# Phase 2 defeat retry plus ten-duel campaign reset boundaries.
extends SceneTree

const RunStateScript := preload("res://src/run/vertical_slice_run_state.gd")
const OpponentCatalogScript := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const STARTERS := ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    _verify_malformed_retry_snapshot_is_atomic()
    _verify_retry_restores_exact_attempt_boundary()
    _verify_failed_run_returns_to_clean_main_state()
    _finish()


func _verify_malformed_retry_snapshot_is_atomic() -> void:
    var run = _new_combat_run()
    var before: Dictionary = run.get_progression_snapshot()
    var altered_progression := before.duplicate(true)
    altered_progression["free_training_pool"] = 77
    var malformed_snapshot := {
        "progression": altered_progression,
        "duel_history": "not-an-array",
        "reward_history": [],
        "route_history": [],
        "intel_by_candidate": {}
    }
    _expect_false(bool(run.call("_restore_pre_battle_snapshot", malformed_snapshot)), "Malformed retry arrays must reject the entire snapshot.")
    _expect_eq(run.get_progression_snapshot(), before, "Rejected retry snapshot must not partially mutate progression.")


func _verify_retry_restores_exact_attempt_boundary() -> void:
    var run = _new_combat_run()
    var initial_opponent := str(run.get_current_opponent().get("candidate_id", ""))
    var initial_seed := int(run.get_run_seed())
    var initial_resources: Dictionary = run.get_player_run_resources()
    _expect_true(run.mark_combat_finished({"outcome": "loss", "review_causes": [{"event": "miss_range"}]}), "First loss must enter Review.")
    _expect_eq(run.get_current_screen(), "REVIEW", "First loss must expose Review before Failure Result.")
    _expect_eq(run.completed_duels, 0, "A loss must not complete its duel.")
    _expect_true(run.get_duel_history().is_empty() and run.get_reward_history().is_empty(), "A loss must not commit history or rewards.")
    _expect_true(run.advance(), "First loss Review must enter Failure Result.")
    _expect_eq(run.get_current_screen(), "FAILURE_RETRY", "First loss must enter the failure retry screen.")
    _expect_eq(run.get_retry_remaining(), 1, "First loss must expose one free retry.")
    _expect_true(run.retry_failed_duel(), "First loss must retry from its pre-battle snapshot.")
    _expect_false(run.retry_failed_duel(), "Retry activation must be idempotent for the same failure receipt.")
    _expect_eq(run.get_current_screen(), "COMBAT", "Retry must recreate Combat state.")
    _expect_true(int(run.get_run_seed()) == initial_seed and str(run.get_current_opponent().get("candidate_id", "")) == initial_opponent, "Retry must preserve seed and opponent.")
    _expect_eq(run.get_player_run_resources(), initial_resources, "Retry must restore pre-battle resources.")
    _expect_true(run.mark_combat_finished({"outcome": "win"}), "Retry win must enter Review.")
    _expect_eq(run.completed_duels, 1, "Retry win must commit the duel once.")
    _expect_eq(run.get_duel_history().size(), 1, "Retry win must append one duel receipt.")


func _verify_failed_run_returns_to_clean_main_state() -> void:
    var run = _new_combat_run()
    _expect_true(run.mark_combat_finished({"outcome": "win"}), "Reset fixture Duel 1 must finish.")
    _expect_true(run.advance(), "Reset fixture Review must enter Result.")
    _expect_true(run.set_pending_result_reward({"reward_type": "free_training", "free_training": 6}), "Reset fixture reward must be selected.")
    _expect_true(run.advance(), "Reset fixture must enter Jianghu.")
    for step in range(4):
        var options: Array = run.get_jianghu_options()
        _expect_eq(options.size(), 3, "Reset fixture Jianghu step must expose three choices.")
        if options.size() != 3:
            continue
        var option_id := str((options[0] as Dictionary).get("id", ""))
        _expect_true(run.select_jianghu_node(option_id, step), "Reset fixture Route choice must apply.")
        _expect_true(run.advance(), "Reset fixture Route choice must confirm.")
    _expect_eq(run.get_current_screen(), "BRIEFING", "Reset fixture must reach Duel 2 Briefing.")
    _expect_true(run.advance(), "Reset fixture Duel 2 must enter Combat.")
    _expect_true(run.mark_combat_finished({"outcome": "loss", "review_causes": [{"event": "miss_range"}]}), "Duel 2 first loss must resolve.")
    _expect_true(run.advance(), "Duel 2 first loss must enter Failure Result.")
    _expect_true(run.retry_failed_duel(), "Duel 2 first loss retry must be available.")
    _expect_true(run.mark_combat_finished({"outcome": "loss", "review_causes": [{"event": "interrupted"}]}), "Duel 2 second loss must resolve.")
    _expect_true(run.advance(), "Duel 2 second loss must enter exhausted Failure Result.")
    _expect_eq(run.get_retry_remaining(), 0, "Second loss must exhaust the free retry.")
    _expect_true(run.end_failed_run(), "Exhausted failure must return to Main.")
    _expect_eq(run.get_current_screen(), "MAIN", "Ending an exhausted run must return to Main.")
    _expect_eq(run.duel_index, 1, "Ended run must reset the duel index.")
    _expect_eq(run.completed_duels, 0, "Ended run must clear completed duels.")
    _expect_eq(run.route_visits, 0, "Ended run must clear Route visits.")
    _expect_true(run.get_duel_history().is_empty(), "Ended run must clear duel history.")
    _expect_true(run.get_reward_history().is_empty(), "Ended run must clear reward history.")
    _expect_true(run.get_route_history().is_empty(), "Ended run must clear Route history.")
    _expect_true(run.get_pending_jianghu().is_empty(), "Ended run must clear pending Jianghu state.")
    _expect_eq(run.jianghu_step, 0, "Ended run must reset the Jianghu counter.")
    _expect_true(run.get_player_manual_loadout().is_empty(), "Ended run must clear the prior setup loadout.")
    _expect_true(run.get_current_opponent().is_empty(), "Ended run must not retain the failed opponent on Main.")
    _expect_true(run.start_new_run(), "A clean Main state must be able to start a new campaign.")
    _expect_eq(str(run.get_current_opponent().get("candidate_id", "")), "slot1_dogyeom", "Restart must bind the first campaign opponent again.")


func _new_combat_run():
    var run = RunStateScript.new()
    var catalog = OpponentCatalogScript.new()
    _expect_true(run.configure_opponents(catalog, 20260828), "Failure fixture must configure opponents.")
    _expect_true(run.start_new_run(), "Failure fixture must start.")
    var mastery := {}
    for manual_id in STARTERS:
        mastery[manual_id] = 3
    _expect_true(run.confirm_setup_loadout(STARTERS, mastery), "Failure fixture must accept Setup.")
    _expect_true(run.advance(), "Failure fixture Setup must enter Intro.")
    _expect_true(run.advance(), "Failure fixture Intro must enter Briefing.")
    _expect_true(run.advance(), "Failure fixture Briefing must enter Combat.")
    return run


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
        print("VERTICAL_SLICE_FAILURE_RETRY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_FAILURE_RETRY_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
