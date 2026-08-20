extends SceneTree

const RUN_STATE_PATH := "res://src/run/vertical_slice_run_state.gd"

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
    _expect_eq(run.get_current_screen(), "MAIN", "A new run state must begin at MAIN.")
    _expect_eq(run.duel_index, 1, "The first duel slot must be active before a new run starts.")

    _expect_true(run.start_new_run(), "MAIN must enter SETUP through start_new_run().")
    _expect_eq(run.get_current_screen(), "SETUP", "New run must enter SETUP.")
    _expect_true(run.advance(), "SETUP must advance to INTRO.")
    _expect_eq(run.get_current_screen(), "INTRO", "SETUP must lead to INTRO.")
    _expect_true(run.advance(), "INTRO must advance to BRIEFING.")
    _expect_eq(run.get_current_screen(), "BRIEFING", "INTRO must lead to BRIEFING.")

    for expected_duel in range(1, 6):
        _expect_eq(run.duel_index, expected_duel, "Duel index must remain synchronized with the current briefing.")
        _expect_true(run.advance(), "BRIEFING must advance to COMBAT.")
        _expect_eq(run.get_current_screen(), "COMBAT", "Briefing must lead to COMBAT.")
        _expect_false(run.advance(), "COMBAT may not skip directly to REVIEW without a terminal combat result.")
        _expect_eq(run.get_current_screen(), "COMBAT", "Blocked COMBAT advance must preserve COMBAT.")

        var result := {
            "outcome": "win",
            "duel_index": expected_duel,
            "review_tags": ["test_duel_%d" % expected_duel]
        }
        _expect_true(run.mark_combat_finished(result), "Terminal combat result must enter REVIEW.")
        _expect_eq(run.get_current_screen(), "REVIEW", "Combat terminal result must enter REVIEW overlay state first.")
        _expect_eq(int(run.last_combat_result.get("duel_index", 0)), expected_duel, "Run state must retain the terminal duel result.")

        _expect_true(run.advance(), "REVIEW must advance to RESULT.")
        _expect_eq(run.get_current_screen(), "RESULT", "REVIEW and RESULT must be distinct states.")

        if expected_duel < 5:
            _expect_true(run.advance(), "RESULT must advance to the first Route node before the next duel.")
            _expect_eq(run.get_current_screen(), "ROUTE_GROWTH", "The first Route node must be Growth/Recovery.")
            _expect_true(run.advance(), "Growth/Recovery must advance to Information/Preparation.")
            _expect_eq(run.get_current_screen(), "ROUTE_INFO", "The second Route node must be Information/Preparation.")
            _expect_true(run.advance(), "Information/Preparation must advance to the next BRIEFING.")
            _expect_eq(run.get_current_screen(), "BRIEFING", "Route completion must return to BRIEFING.")
            _expect_eq(run.duel_index, expected_duel + 1, "Route completion must increment the duel slot exactly once.")
        else:
            _expect_true(run.advance(), "The fifth RESULT must advance directly to COMPLETION.")
            _expect_eq(run.get_current_screen(), "COMPLETION", "No Route nodes may occur after Duel 5.")

    _expect_true(run.is_complete(), "Five completed duels must mark the run complete.")
    _expect_eq(run.route_visits, 8, "Four inter-duel intervals must create exactly eight Route visits.")
    _expect_eq(run.completed_duels, 5, "The run must record exactly five completed duels.")

    var history: Array = run.get_flow_history()
    _expect_eq(history.count("REVIEW"), 5, "Each duel must visit REVIEW exactly once.")
    _expect_eq(history.count("RESULT"), 5, "Each duel must visit RESULT exactly once.")
    _expect_eq(history.count("ROUTE_GROWTH"), 4, "Only Duels 1-4 may enter Growth/Recovery Route.")
    _expect_eq(history.count("ROUTE_INFO"), 4, "Only Duels 1-4 may enter Information/Preparation Route.")
    _expect_eq(history[history.size() - 1], "COMPLETION", "The full run must terminate at COMPLETION.")

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
        print("VERTICAL_SLICE_RUN_STATE_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_RUN_STATE_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
