extends SceneTree

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
    var shell = SHELL_SCENE.instantiate()
    root.add_child(shell)
    if shell is Control:
        shell.set_anchors_preset(Control.PRESET_TOP_LEFT)
        shell.size = Vector2(1440.0, 900.0)
    for _index in range(3):
        await process_frame

    _expect_true(shell.start_new_run(), "Route test run must start.")
    for manual_id in DEFAULT_STARTERS:
        _expect_true(shell.toggle_setup_manual(manual_id), "Starter selection must succeed: %s" % manual_id)
    _expect_true(shell.advance_noncombat(), "SETUP → INTRO")
    _expect_true(shell.advance_noncombat(), "INTRO → BRIEFING")
    _expect_true(shell.advance_noncombat(), "BRIEFING → COMBAT")
    await process_frame

    var duel_one_opponent: Dictionary = shell.run_state.get_current_opponent()
    var terminal_result := {
        "terminal": true,
        "outcome": "win",
        "player_health": 12,
        "enemy_health": 0,
        "player_resources": {
            "health": [12, 40],
            "stamina": [2, 5],
            "internal": [1, 4]
        },
        "battle_metrics": {
            "successful_dodges": 1,
            "clash_wins": 1,
            "player_health_lost": 28,
            "rounds_elapsed": 3,
            "ultimate_uses": 0
        },
        "review_summary": {"cause_code": "clash", "review_focus": "합의 원인"},
        "presentation_state": "review_ready"
    }
    _expect_true(shell.complete_combat_for_runtime(terminal_result), "Terminal result must enter REVIEW.")
    _expect_eq(shell.run_state.get_player_run_resources(), terminal_result["player_resources"], "RunState must persist terminal player health/stamina/internal pairs.")
    _expect_true(shell.complete_review_for_runtime(), "REVIEW → RESULT")
    _expect_true(shell.select_result_reward("focused_training", DEFAULT_STARTERS[0]), "Focused result reward must be selectable.")
    _expect_true(shell.advance_noncombat(), "Reward-confirmed RESULT → R1 Growth/Recovery.")
    await process_frame

    _expect_eq(shell.run_state.get_current_screen(), "ROUTE_GROWTH", "Run must enter Growth/Recovery Route first.")
    var progression: Dictionary = shell.run_state.get_progression_snapshot()
    _expect_eq(int(progression.get("free_training_pool", -1)), 3, "Focused Duel reward must apply +3 free training before Route renders.")
    _expect_eq(int((progression.get("training_by_manual", {}) as Dictionary).get(DEFAULT_STARTERS[0], -1)), 5, "Focused Duel reward must apply +5 to its selected manual exactly once.")
    _expect_eq(int((progression.get("mastery_by_manual", {}) as Dictionary).get(DEFAULT_STARTERS[0], -1)), 5, "Five invested points from mastery 3 must cross 4★(2) and 5★(+3).")
    _expect_eq(shell.get_route_option_count(), 3, "Growth/Recovery Route must expose exactly three choices.")
    _expect_false(shell.primary_button.disabled == false, "Growth Route CTA must remain disabled until one route choice is selected.")

    _expect_true(shell.select_growth_route("recovery"), "R1 recovery option must be selectable.")
    var recovered: Dictionary = shell.run_state.get_player_run_resources()
    _expect_eq(recovered.get("health", []), [22, 40], "25% of max 40 must restore 10 health without exceeding max.")
    _expect_eq(recovered.get("stamina", []), [3, 5], "Recovery must restore stamina +1 with cap.")
    _expect_eq(recovered.get("internal", []), [2, 4], "Recovery must restore internal +1 with cap.")
    _expect_true(shell.advance_noncombat(), "Confirmed R1 choice must advance to R2 Info/Preparation.")
    await process_frame

    _expect_eq(shell.run_state.get_current_screen(), "ROUTE_INFO", "Growth Route must lead to Info Route.")
    var locked_next: Dictionary = shell.run_state.get_route_target_opponent()
    var locked_id := str(locked_next.get("candidate_id", ""))
    _expect_true(not locked_id.is_empty(), "Info Route must target the already-locked next opponent.")
    _expect_eq(int(locked_next.get("duel_slot", 0)), 2, "R2 must target Slot 2 opponent after Duel 1.")
    _expect_eq(shell.get_route_option_count(), 3, "Info Route must expose exactly three public-info choices.")
    _expect_true(shell.select_info_route("MANUAL_RUMOR"), "R2 MANUAL_RUMOR must be selectable.")
    var intel: Dictionary = shell.run_state.get_pending_route_intel()
    _expect_eq(str(intel.get("candidate_id", "")), locked_id, "Route intel must remain scoped to the locked opponent.")
    _expect_eq(str(intel.get("category", "")), "MANUAL_RUMOR", "Selected info category must be recorded.")
    var intel_text := str(intel.get("text", ""))
    _expect_true(not intel_text.is_empty(), "Selected Route intel must produce player-facing public text.")
    _expect_false(intel_text.contains(str(locked_next.get("behavior_focus", ""))), "Route intel must not expose internal behavior keys.")
    _expect_false(intel_text.contains("AI 가중치"), "Route intel must not expose AI weights.")
    _expect_false(intel_text.contains("현재 계획"), "Route intel must not expose the hidden current plan.")

    _expect_true(shell.advance_noncombat(), "Confirmed R2 choice must advance to Duel 2 Briefing.")
    await process_frame
    _expect_eq(shell.run_state.get_current_screen(), "BRIEFING", "Info Route must advance to next Briefing.")
    _expect_eq(str(shell.run_state.get_current_opponent().get("candidate_id", "")), locked_id, "Route target must promote without reroll.")
    var briefing_text := "%s\n%s" % [shell.title_label.text, shell.description_label.text]
    _expect_true(briefing_text.contains(intel_text), "Next Briefing must include the chosen Route intel as one acquired clue.")
    _expect_false(briefing_text.contains(str(locked_next.get("behavior_focus", ""))), "Briefing must still hide internal behavior keys after Route intel.")

    _expect_true(shell.advance_noncombat(), "Duel 2 Briefing → Combat")
    await process_frame
    await process_frame
    var resources_snapshot: Dictionary = shell.get_active_combat_resource_snapshot()
    _expect_eq(resources_snapshot.get("health", []), [22, 40], "Duel 2 combat must start from persisted/recovered health.")
    _expect_eq(resources_snapshot.get("stamina", []), [3, 5], "Duel 2 combat must start from persisted/recovered stamina.")
    _expect_eq(resources_snapshot.get("internal", []), [2, 4], "Duel 2 combat must start from persisted/recovered internal.")

    var route_history: Array = shell.run_state.get_route_history()
    _expect_eq(route_history.size(), 2, "R1 and R2 must each record exactly one confirmed route receipt.")
    _expect_eq(str((route_history[0] as Dictionary).get("node_id", "")), "R1", "First confirmed Route receipt must be R1.")
    _expect_eq(str((route_history[1] as Dictionary).get("node_id", "")), "R2", "Second confirmed Route receipt must be R2.")
    _expect_eq(str(duel_one_opponent.get("candidate_id", "")), str((shell.run_state.get_reward_history()[0] as Dictionary).get("opponent_candidate_id", "")), "Duel reward history must remain associated with Duel 1 opponent.")

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
        print("VERTICAL_SLICE_ROUTE_STATE_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_ROUTE_STATE_VERIFY_FAILED count=%d" % failures.size())
    quit(1)