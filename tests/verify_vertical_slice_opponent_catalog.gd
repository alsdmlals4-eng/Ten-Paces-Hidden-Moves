extends SceneTree

const CATALOG_SCRIPT_PATH := "res://src/run/vertical_slice_opponent_catalog.gd"
const DATA_PATH := "res://data/run/vertical_slice_opponents.json"
const MANUAL_MANIFEST_PATH := "res://data/cards/martial_manual_cards.json"
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
    if not FileAccess.file_exists(DATA_PATH):
        failures.append("Vertical Slice opponent data is missing: %s" % DATA_PATH)
        _finish()
        return

    var catalog = catalog_script.new()
    _expect_true(catalog.is_valid(), "Opponent catalog must load without errors: %s" % str(catalog.load_errors))
    _verify_catalog_shape(catalog)
    _verify_shared_player_ai_martial_pool(catalog)
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
    var required_fields := [
        "candidate_id",
        "duel_slot",
        "working_name",
        "martial_identity",
        "readable_habit",
        "ambiguity_or_counterexample",
        "public_briefing_hook",
        "short_personality_hook",
        "review_tags",
        "signature_manual_id",
        "available_manual_card_ids",
        "basic_action_focus_ids",
        "behavior_focus",
        "final_stat_total_seed",
        "signature_star_seed"
    ]

    for slot in range(1, 6):
        _expect_eq(catalog.get_candidates_for_slot(slot).size(), 3, "Each duel slot must have exactly three candidates.")

    for value in all_candidates:
        _expect_true(typeof(value) == TYPE_DICTIONARY, "Each candidate must be a Dictionary.")
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var candidate := value as Dictionary
        for field in required_fields:
            _expect_true(candidate.has(field), "Candidate %s is missing required field %s." % [str(candidate.get("candidate_id", "?")), field])
        var candidate_id := str(candidate.get("candidate_id", ""))
        _expect_true(not candidate_id.is_empty(), "Candidate ID may not be empty.")
        _expect_false(ids.has(candidate_id), "Candidate IDs must be unique: %s" % candidate_id)
        ids[candidate_id] = true

        var slot := int(candidate.get("duel_slot", 0))
        _expect_true(slot >= 1 and slot <= 5, "Candidate duel_slot must be 1..5: %s" % candidate_id)
        if expected_stat_total.has(slot):
            _expect_eq(int(candidate.get("final_stat_total_seed", -1)), int(expected_stat_total[slot]), "Candidate stat-total seed must match the approved slot seed: %s" % candidate_id)
        var expected_mastery := int(expected_star.get(slot, -1))
        if candidate_id == "slot3_biyeon":
            expected_mastery = 4
        _expect_eq(int(candidate.get("signature_star_seed", -1)), expected_mastery, "Candidate signature mastery seed must match the approved slot seed: %s" % candidate_id)

        manual_ids[str(candidate.get("signature_manual_id", ""))] = true
        _expect_true((candidate.get("review_tags", []) as Array).size() >= 1, "Candidate must have at least one implementation review tag: %s" % candidate_id)
        _expect_true((candidate.get("available_manual_card_ids", []) as Array).size() >= 1, "Candidate must expose at least one existing manual card: %s" % candidate_id)
        _expect_true((candidate.get("basic_action_focus_ids", []) as Array).size() >= 1, "Candidate must reference at least one existing basic action: %s" % candidate_id)

    _expect_eq(manual_ids.size(), 10, "The 15-candidate slice must reuse all ten existing manual IDs at least once.")


func _verify_shared_player_ai_martial_pool(catalog) -> void:
    var manifest_file := FileAccess.open(MANUAL_MANIFEST_PATH, FileAccess.READ)
    _expect_true(manifest_file != null, "Martial manual manifest must be readable for player/AI pool validation.")
    if manifest_file == null:
        return
    var parsed = JSON.parse_string(manifest_file.get_as_text())
    _expect_true(typeof(parsed) == TYPE_DICTIONARY, "Martial manual manifest must parse as a Dictionary.")
    if typeof(parsed) != TYPE_DICTIONARY:
        return
    var manifest := parsed as Dictionary

    _expect_eq(str(manifest.get("availability_policy", "")), "PLAYER_LEARNABLE_SHARED_WITH_AI", "Martial manuals must be a player-learnable shared pool rather than an enemy-only pool.")
    _expect_false(bool(manifest.get("enemy_exclusive_manuals_allowed", true)), "Enemy-exclusive martial manuals are forbidden.")
    _expect_false(bool(manifest.get("enemy_exclusive_techniques_allowed", true)), "Enemy-exclusive martial techniques are forbidden.")

    var files_value = manifest.get("manual_files", {})
    _expect_true(typeof(files_value) == TYPE_DICTIONARY, "Martial manual manifest manual_files must be a Dictionary.")
    if typeof(files_value) != TYPE_DICTIONARY:
        return
    var manual_files := files_value as Dictionary

    var learnable_value = manifest.get("player_learnable_manual_ids", [])
    _expect_true(typeof(learnable_value) == TYPE_ARRAY, "player_learnable_manual_ids must be an Array.")
    if typeof(learnable_value) != TYPE_ARRAY:
        return
    var learnable_ids := {}
    for manual_id_value in learnable_value as Array:
        var manual_id := str(manual_id_value)
        _expect_false(manual_id.is_empty(), "Player-learnable manual ID may not be empty.")
        _expect_false(learnable_ids.has(manual_id), "Player-learnable manual IDs must be unique: %s" % manual_id)
        learnable_ids[manual_id] = true

    _expect_eq(learnable_ids.size(), manual_files.size(), "Every current martial manual must be player-learnable when acquired.")
    for manual_key in manual_files.keys():
        var manual_id := str(manual_key)
        _expect_true(learnable_ids.has(manual_id), "Current martial manual must be player-learnable: %s" % manual_id)

    for value in catalog.get_all_candidates():
        var candidate := value as Dictionary
        var candidate_id := str(candidate.get("candidate_id", ""))
        var manual_id := str(candidate.get("signature_manual_id", ""))
        _expect_true(learnable_ids.has(manual_id), "Opponent may only use a player-learnable faction manual: %s -> %s" % [candidate_id, manual_id])


func _verify_runtime_ids(catalog) -> void:
    var registry = MANUAL_REGISTRY_SCRIPT.new()
    _expect_true(registry.is_valid(), "Existing ten-manual runtime registry must be valid before opponent validation.")
    var runtime_manual_ids: PackedStringArray = registry.get_manual_ids()

    var basic_file := FileAccess.open(BASIC_CARDS_PATH, FileAccess.READ)
    _expect_true(basic_file != null, "Basic card data must be readable.")
    if basic_file == null:
        return
    var basic_parsed = JSON.parse_string(basic_file.get_as_text())
    _expect_true(typeof(basic_parsed) == TYPE_DICTIONARY, "Basic card data must parse as a Dictionary.")
    if typeof(basic_parsed) != TYPE_DICTIONARY:
        return
    var basic_ids := {}
    for value in (basic_parsed as Dictionary).get("cards", []):
        if typeof(value) == TYPE_DICTIONARY:
            basic_ids[str((value as Dictionary).get("id", ""))] = true

    for value in catalog.get_all_candidates():
        var candidate := value as Dictionary
        var candidate_id := str(candidate.get("candidate_id", ""))
        var manual_id := str(candidate.get("signature_manual_id", ""))
        var mastery := int(candidate.get("signature_star_seed", 0))
        _expect_true(manual_id in runtime_manual_ids, "Candidate must reference an existing manual ID: %s -> %s" % [candidate_id, manual_id])

        var unlocked: Array = registry.build_unlocked_cards(manual_id, mastery)
        var unlocked_ids := {}
        for card_value in unlocked:
            if typeof(card_value) == TYPE_DICTIONARY:
                unlocked_ids[str((card_value as Dictionary).get("id", ""))] = true
        for card_id_value in candidate.get("available_manual_card_ids", []):
            var card_id := str(card_id_value)
            _expect_true(unlocked_ids.has(card_id), "Candidate card must be legal at its mastery seed: %s -> %s at %d" % [candidate_id, card_id, mastery])

        for basic_id_value in candidate.get("basic_action_focus_ids", []):
            var basic_id := str(basic_id_value)
            _expect_true(basic_ids.has(basic_id), "Candidate basic-action focus must reference existing basic card data: %s -> %s" % [candidate_id, basic_id])

    var biyeon: Dictionary = catalog.get_candidate("slot3_biyeon")
    _expect_eq(int(biyeon.get("signature_star_seed", 0)), 4, "Biyeon must stay below the enemy-forbidden star5 observation overlay.")
    _expect_eq((biyeon.get("available_manual_card_ids", []) as Array), ["sichuan_tang_hidden_weapons_star3"], "Biyeon must expose only the approved star3 hidden-weapon technique in this slice.")


func _verify_selection_binding(catalog) -> void:
    for slot in range(1, 6):
        var slot_candidates: Array = catalog.get_candidates_for_slot(slot)
        var allowed_ids := {}
        for value in slot_candidates:
            allowed_ids[str((value as Dictionary).get("candidate_id", ""))] = true
        for seed in [0, 1, 2, 17, 99, 20260820]:
            var first := str(catalog.select_candidate_id(slot, seed))
            var second := str(catalog.select_candidate_id(slot, seed))
            _expect_true(allowed_ids.has(first), "Selection binding must choose only from the requested slot.")
            _expect_eq(first, second, "Selection binding must be deterministic for the same slot and run seed.")
    _expect_eq(str(catalog.select_candidate_id(0, 1)), "", "Invalid duel slot must not select a candidate.")
    _expect_eq(str(catalog.select_candidate_id(6, 1)), "", "Invalid duel slot must not select a candidate.")


func _verify_run_lock_flow(catalog) -> void:
    var run = RUN_STATE_SCRIPT.new()
    _expect_true(run.configure_opponents(catalog, 20260820), "RunState must accept the validated opponent catalog before a run starts.")
    _expect_true(run.start_new_run(), "Configured RunState must start normally.")

    var first_opponent: Dictionary = run.get_current_opponent()
    _expect_eq(int(first_opponent.get("duel_slot", 0)), 1, "Duel 1 opponent must be locked before the first Briefing.")
    _expect_true(str(first_opponent.get("candidate_id", "")).length() > 0, "Duel 1 must have a current opponent ID.")
    _expect_true(run.get_route_target_opponent().is_empty(), "No next opponent may be exposed before Duel 1 result settlement.")

    _expect_true(run.advance(), "SETUP → INTRO")
    _expect_true(run.advance(), "INTRO → BRIEFING")
    _expect_true(run.advance(), "BRIEFING → COMBAT")
    _expect_true(run.mark_combat_finished({"outcome": "win", "duel_index": 1}), "Duel 1 terminal result must enter REVIEW.")
    _expect_true(run.advance(), "REVIEW → RESULT")
    _expect_eq(run.get_current_screen(), "RESULT", "Run must be at RESULT before next-opponent lock transition.")
    _expect_true(run.get_route_target_opponent().is_empty(), "Next opponent must not be route-visible before Duel 1 result settlement.")
    _expect_false(run.advance(), "Result without a reward receipt may not lock or reveal the next opponent.")
    _expect_true(run.get_route_target_opponent().is_empty(), "Blocked Result advance must not pre-lock the next opponent.")
    _expect_true(run.set_pending_result_reward({"reward_type": "free_training", "free_training": 6}), "Result must accept one valid reward receipt before Route.")

    _expect_true(run.advance(), "Reward-confirmed RESULT → ROUTE_GROWTH must lock next opponent first.")
    _expect_eq(run.get_current_screen(), "ROUTE_GROWTH", "Result must enter Growth/Recovery Route.")
    var locked_next: Dictionary = run.get_route_target_opponent()
    var locked_id := str(locked_next.get("candidate_id", ""))
    _expect_true(not locked_id.is_empty(), "Next opponent must be locked before the first Route node renders.")
    _expect_eq(int(locked_next.get("duel_slot", 0)), 2, "The locked Route target after Duel 1 must belong to Slot 2.")

    _expect_false(run.advance(), "ROUTE_GROWTH may not advance without an explicit choice.")
    _expect_true(run.select_growth_route("free_training"), "ROUTE_GROWTH must accept one legal explicit choice.")
    _expect_true(run.advance(), "Confirmed ROUTE_GROWTH → ROUTE_INFO")
    _expect_eq(str(run.get_route_target_opponent().get("candidate_id", "")), locked_id, "Growth Route may not reroll the locked opponent.")
    _expect_false(run.advance(), "ROUTE_INFO may not advance without an explicit public-info choice.")
    var options: Array = run.get_info_route_options()
    _expect_eq(options.size(), 3, "Info Route must expose exactly three approved public-info choices.")
    if options.size() == 3:
        _expect_true(run.select_info_route(str((options[0] as Dictionary).get("category", ""))), "Info Route must accept one legal public clue category.")
    _expect_true(run.advance(), "Confirmed ROUTE_INFO → next BRIEFING")
    _expect_eq(run.get_current_screen(), "BRIEFING", "Information Route must lead to the next Briefing.")
    _expect_eq(run.duel_index, 2, "Duel slot must increment exactly once after the two Route nodes.")
    _expect_eq(str(run.get_current_opponent().get("candidate_id", "")), locked_id, "The locked Route target must become the current Briefing opponent.")
    _expect_true(run.get_route_target_opponent().is_empty(), "Pending next-opponent lock must clear after promotion to current opponent.")


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