extends SceneTree

const CATALOG_SCRIPT_PATH := "res://src/run/vertical_slice_opponent_catalog.gd"
const DATA_PATH := "res://data/run/vertical_slice_opponents.json"
const MANUAL_REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")
const RUN_STATE_SCRIPT := preload("res://src/run/vertical_slice_run_state.gd")
const BASIC_CARDS_PATH := "res://data/cards/basic_cards.json"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var catalog_script := load(CATALOG_SCRIPT_PATH)
    if catalog_script == null:
        failures.append("Vertical Slice opponent catalog script is missing: %s" % CATALOG_SCRIPT_PATH)
        _finish()
        return
    var catalog = catalog_script.new()
    _expect_true(catalog.is_valid(), "Opponent catalog must load without errors: %s" % str(catalog.load_errors))
    _verify_catalog_shape(catalog)
    _verify_runtime_ids(catalog)
    _verify_selection_binding(catalog)
    _verify_run_lock_flow(catalog)
    _finish()

func _verify_catalog_shape(catalog) -> void:
    var all_candidates: Array = catalog.get_all_candidates()
    _expect_eq(all_candidates.size(), 15, "Vertical Slice must expose exactly 15 candidates.")
    var ids := {}
    var manual_ids := {}
    var expected_stat_total := {1: 20, 2: 22, 3: 24, 4: 26, 5: 28}
    var expected_star := {1: 3, 2: 7, 3: 7, 4: 7, 5: 9}
    for slot in range(1, 6):
        _expect_eq(catalog.get_candidates_for_slot(slot).size(), 3, "Each duel slot must have exactly three candidates.")
    for value in all_candidates:
        var candidate := value as Dictionary
        var candidate_id := str(candidate.get("candidate_id", ""))
        _expect_true(not candidate_id.is_empty(), "Candidate ID may not be empty.")
        _expect_false(ids.has(candidate_id), "Candidate IDs must be unique: %s" % candidate_id)
        ids[candidate_id] = true
        var slot := int(candidate.get("duel_slot", 0))
        _expect_eq(int(candidate.get("final_stat_total_seed", -1)), int(expected_stat_total.get(slot, -2)), "Candidate stat seed mismatch: %s" % candidate_id)
        var expected_mastery := 4 if candidate_id == "slot3_biyeon" else int(expected_star.get(slot, -1))
        _expect_eq(int(candidate.get("signature_star_seed", -1)), expected_mastery, "Candidate mastery seed mismatch: %s" % candidate_id)
        manual_ids[str(candidate.get("signature_manual_id", ""))] = true
    _expect_eq(manual_ids.size(), 10, "The 15-candidate slice must reuse all ten existing manual IDs at least once.")

func _verify_runtime_ids(catalog) -> void:
    var registry = MANUAL_REGISTRY_SCRIPT.new()
    _expect_true(registry.is_valid(), "Existing ten-manual runtime registry must be valid before opponent validation.")
    var runtime_manual_ids: PackedStringArray = registry.get_manual_ids()
    var basic_file := FileAccess.open(BASIC_CARDS_PATH, FileAccess.READ)
    var basic_parsed = JSON.parse_string(basic_file.get_as_text())
    var basic_ids := {}
    for value in (basic_parsed as Dictionary).get("cards", []):
        basic_ids[str((value as Dictionary).get("id", ""))] = true
    for value in catalog.get_all_candidates():
        var candidate := value as Dictionary
        var candidate_id := str(candidate.get("candidate_id", ""))
        var manual_id := str(candidate.get("signature_manual_id", ""))
        var mastery := int(candidate.get("signature_star_seed", 0))
        _expect_true(manual_id in runtime_manual_ids, "Candidate must reference an existing manual ID: %s" % candidate_id)
        var unlocked_ids := {}
        for card_value in registry.build_unlocked_cards(manual_id, mastery):
            unlocked_ids[str((card_value as Dictionary).get("id", ""))] = true
        for card_id_value in candidate.get("available_manual_card_ids", []):
            _expect_true(unlocked_ids.has(str(card_id_value)), "Candidate card must be legal at mastery seed: %s" % candidate_id)
        for basic_id_value in candidate.get("basic_action_focus_ids", []):
            _expect_true(basic_ids.has(str(basic_id_value)), "Candidate basic focus must use an existing basic card: %s" % candidate_id)
    var biyeon: Dictionary = catalog.get_candidate("slot3_biyeon")
    _expect_eq((biyeon.get("available_manual_card_ids", []) as Array), ["sichuan_tang_hidden_weapons_star3"], "Biyeon must expose only approved star3 hidden weapon technique.")

func _verify_selection_binding(catalog) -> void:
    for slot in range(1, 6):
        var allowed_ids := {}
        for value in catalog.get_candidates_for_slot(slot):
            allowed_ids[str((value as Dictionary).get("candidate_id", ""))] = true
        for seed in [0, 1, 2, 17, 99, 20260820]:
            var first := str(catalog.select_candidate_id(slot, seed))
            _expect_true(allowed_ids.has(first), "Selection binding must choose only from requested slot.")
            _expect_eq(first, str(catalog.select_candidate_id(slot, seed)), "Selection must be deterministic for same slot/seed.")

func _verify_run_lock_flow(catalog) -> void:
    var run = RUN_STATE_SCRIPT.new()
    _expect_true(run.configure_opponents(catalog, 20260820), "RunState must accept validated opponent catalog.")
    _expect_true(run.start_new_run(), "Configured RunState must start normally.")
    var first_opponent: Dictionary = run.get_current_opponent()
    _expect_eq(int(first_opponent.get("duel_slot", 0)), 1, "Duel 1 opponent must lock before Briefing.")
    _expect_true(run.advance(), "SETUP → INTRO")
    _expect_true(run.advance(), "INTRO → BRIEFING")
    _expect_true(run.advance(), "BRIEFING → COMBAT")
    _expect_true(run.mark_combat_finished({"outcome": "win", "duel_index": 1}), "Duel 1 result → REVIEW")
    _expect_true(run.advance(), "REVIEW → RESULT")
    _expect_true(run.get_route_target_opponent().is_empty(), "Next opponent must remain hidden through Result.")
    _expect_true(run.set_pending_result_reward({"reward_type": "free_training", "free_training": 6}), "Result must accept reward receipt.")
    _expect_true(run.advance(), "Confirmed Result → Growth Route")
    var locked_next: Dictionary = run.get_route_target_opponent()
    var locked_id := str(locked_next.get("candidate_id", ""))
    _expect_eq(int(locked_next.get("duel_slot", 0)), 2, "Locked Route target must belong to Slot 2.")
    _expect_false(run.advance(), "Growth Route may not advance without a choice.")
    _expect_true(run.select_growth_route("free_training"), "Growth Route must accept one legal choice.")
    _expect_true(run.advance(), "Growth Route → Info Route")
    _expect_eq(str(run.get_route_target_opponent().get("candidate_id", "")), locked_id, "Growth Route may not reroll locked opponent.")
    var options: Array = run.get_info_route_options()
    _expect_eq(options.size(), 3, "Info Route must expose three choices.")
    if options.size() == 3:
        _expect_true(run.select_info_route(str((options[0] as Dictionary).get("category", ""))), "Info Route must accept one legal public clue.")
    _expect_true(run.advance(), "Info Route → next Briefing")
    _expect_eq(str(run.get_current_opponent().get("candidate_id", "")), locked_id, "Locked target must promote without reroll.")
    _expect_true(run.get_route_target_opponent().is_empty(), "Pending next-opponent lock must clear after promotion.")

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
        print("VERTICAL_SLICE_OPPONENT_CATALOG_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_OPPONENT_CATALOG_VERIFY_FAILED count=%d" % failures.size())
    quit(1)