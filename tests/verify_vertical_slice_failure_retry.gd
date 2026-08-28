# Phase 2 첫 패배의 동일 시드 무료 재도전과 무보상 종료 경계를 검증한다.
extends SceneTree

const RunStateScript := preload("res://src/run/vertical_slice_run_state.gd")
const OpponentCatalogScript := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const STARTERS := ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var run = _new_combat_run()
    var initial_opponent := str(run.get_current_opponent().get("candidate_id", ""))
    var initial_seed := int(run.get_run_seed())
    var initial_resources: Dictionary = run.get_player_run_resources()
    _expect(run.mark_combat_finished({"outcome": "loss", "review_causes": [{"event": "miss_range"}]}), "First loss must enter Review.")
    _expect(run.get_current_screen() == "REVIEW", "First loss must expose Review before Failure Result.")
    _expect(run.completed_duels == 0 and run.get_duel_history().is_empty() and run.get_reward_history().is_empty(), "First loss must not commit duel history or rewards.")
    _expect(run.advance(), "First loss Review must enter Failure Result.")
    _expect(run.get_current_screen() == "FAILURE_RETRY", "First loss must enter the failure retry screen.")
    _expect(run.get_retry_remaining() == 1, "First loss must expose one free retry.")
    _expect(run.retry_failed_duel(), "First loss must retry from its pre-battle snapshot.")
    _expect(run.get_current_screen() == "COMBAT", "Retry must recreate Combat state.")
    _expect(int(run.get_run_seed()) == initial_seed and str(run.get_current_opponent().get("candidate_id", "")) == initial_opponent, "Retry must preserve seed and opponent.")
    _expect(run.get_player_run_resources() == initial_resources, "Retry must restore pre-battle resources.")
    _expect(run.mark_combat_finished({"outcome": "win"}), "Retry win must enter Review.")
    _expect(run.completed_duels == 1 and run.get_duel_history().size() == 1, "Retry win must commit exactly one duel.")

    var exhausted = _new_combat_run()
    _expect(exhausted.mark_combat_finished({"outcome": "loss", "review_causes": [{"event": "miss_range"}]}), "First loss must resolve.")
    _expect(exhausted.advance(), "First loss must enter Failure Result.")
    _expect(exhausted.retry_failed_duel(), "First loss retry must be available.")
    _expect(exhausted.mark_combat_finished({"outcome": "loss", "review_causes": [{"event": "interrupted"}]}), "Second loss must resolve.")
    _expect(exhausted.advance(), "Second loss Review must enter exhausted Failure Result.")
    _expect(exhausted.get_retry_remaining() == 0 and exhausted.get_reward_history().is_empty() and exhausted.get_duel_history().is_empty(), "Second loss must have no retry, reward, or duel commit.")
    _expect(exhausted.end_failed_run(), "Failure Result must return to Main.")
    _expect(exhausted.get_current_screen() == "MAIN", "Ending an exhausted run must return to Main.")
    if failures.is_empty():
        print("VERTICAL_SLICE_FAILURE_RETRY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _new_combat_run():
    var run = RunStateScript.new()
    var catalog = OpponentCatalogScript.new()
    run.configure_opponents(catalog, 20260828)
    run.start_new_run()
    var mastery := {}
    for manual_id in STARTERS:
        mastery[manual_id] = 3
    run.confirm_setup_loadout(STARTERS, mastery)
    run.advance()
    run.advance()
    run.advance()
    return run

func _expect(value: bool, message: String) -> void:
    if not value:
        failures.append(message)
