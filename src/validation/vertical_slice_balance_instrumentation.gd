class_name VerticalSliceBalanceInstrumentation
extends RefCounted

# approved balance measurement matrix: current candidates x legal starter selections x public policies x fixed AI seeds.
const MATRIX_PATH := "res://data/validation/vertical_slice_balance_instrumentation_matrix.json"
const HUD_PATH := "res://data/combat/combat_hud_preview.json"
const CONTRACT_ID := "TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01"
const EXPECTED_SCHEMA_VERSION := 1
const EXPECTED_ROUTE_CONTEXT_ID := "opening_no_route"
const EXPECTED_TIMING_SEQUENCE := [3, 3, 4]
const EXPECTED_CANDIDATE_COUNT := 15
const EXPECTED_STARTER_LOADOUT_COUNT := 15
const EXPECTED_SCENARIO_COUNT := 3375

const CatalogScript := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const BindingScript := preload("res://src/run/vertical_slice_opponent_runtime_binding.gd")
const StarterCatalogScript := preload("res://src/run/vertical_slice_starter_manual_catalog.gd")
const RuntimeEngineScript := preload("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd")
const PublicPolicyScript := preload("res://src/validation/vertical_slice_balance_public_policy.gd")


func build_matrix_contract() -> Dictionary:
    var errors: Array[String] = []
    var matrix := _load_json(MATRIX_PATH, errors)
    if matrix.is_empty():
        return _contract_result(errors, 0, 0, 0)

    if int(matrix.get("schema_version", 0)) != EXPECTED_SCHEMA_VERSION:
        errors.append("matrix schema_version must remain %d" % EXPECTED_SCHEMA_VERSION)
    if str(matrix.get("contract_id", "")) != CONTRACT_ID:
        errors.append("matrix contract_id must remain the approved balance contract")
    if str(matrix.get("route_context_id", "")) != EXPECTED_ROUTE_CONTEXT_ID:
        errors.append("v1 route context must remain opening_no_route")
    if not _is_valid_tile(int(matrix.get("player_tile", 0))) or not _is_valid_tile(int(matrix.get("enemy_tile", 0))):
        errors.append("matrix player and enemy tiles must be inside the current ten-tile board")
    if int(matrix.get("player_tile", 0)) == int(matrix.get("enemy_tile", 0)):
        errors.append("matrix opening tiles must preserve a nonzero starting distance")
    if _int_array(matrix.get("timing_sequence", [])) != EXPECTED_TIMING_SEQUENCE:
        errors.append("matrix timing sequence must remain [3, 3, 4]")
    if int(matrix.get("maximum_rounds", 0)) < 1:
        errors.append("matrix maximum_rounds must be positive")

    var configured_seeds := _int_array(matrix.get("ai_decision_seeds", []))
    if configured_seeds.is_empty() or configured_seeds.size() != (matrix.get("ai_decision_seeds", []) as Array).size() or _contains_duplicate_ints(configured_seeds):
        errors.append("matrix AI decision seeds must be a unique non-empty integer list")

    var configured_policies := _string_array(matrix.get("player_policy_ids", []))
    var expected_policies := PublicPolicyScript.get_policy_ids()
    if configured_policies != expected_policies:
        errors.append("matrix player policy IDs must remain the approved public-policy set")

    var catalog = CatalogScript.new()
    if not catalog.is_valid():
        errors.append("current opponent catalog must validate before measurement: %s" % str(catalog.load_errors))
    var starter_catalog = StarterCatalogScript.new()
    if not starter_catalog.is_valid():
        errors.append("current starter catalog must validate before measurement: %s" % str(starter_catalog.load_errors))

    var candidates := _sorted_candidates(catalog.get_all_candidates())
    var loadouts := _build_legal_starter_loadouts(starter_catalog)
    var calculated_count := candidates.size() * loadouts.size() * configured_policies.size() * configured_seeds.size()
    if candidates.size() != EXPECTED_CANDIDATE_COUNT or candidates.size() != int(matrix.get("expected_candidate_count", -1)):
        errors.append("matrix must cover exactly all 15 current opponent candidates")
    if loadouts.size() != EXPECTED_STARTER_LOADOUT_COUNT or loadouts.size() != int(matrix.get("expected_starter_loadout_count", -1)):
        errors.append("matrix must cover exactly every legal 4-of-6 starter selection")
    if calculated_count != EXPECTED_SCENARIO_COUNT or calculated_count != int(matrix.get("expected_scenario_count", -1)):
        errors.append("matrix must contain exactly 3,375 deterministic duels")

    return _contract_result(errors, candidates.size(), loadouts.size(), calculated_count)


func build_scenarios() -> Array:
    var contract := build_matrix_contract()
    if not bool(contract.get("valid", false)):
        return []
    var matrix_errors: Array[String] = []
    var matrix := _load_json(MATRIX_PATH, matrix_errors)
    if matrix.is_empty():
        return []
    var catalog = CatalogScript.new()
    var starter_catalog = StarterCatalogScript.new()
    var candidates := _sorted_candidates(catalog.get_all_candidates())
    var loadouts := _build_legal_starter_loadouts(starter_catalog)
    var policies := _string_array(matrix.get("player_policy_ids", []))
    var seeds := _int_array(matrix.get("ai_decision_seeds", []))
    var scenarios: Array = []
    for candidate_value in candidates:
        var candidate: Dictionary = candidate_value
        var candidate_id := str(candidate.get("candidate_id", ""))
        for loadout_value in loadouts:
            var loadout: Dictionary = loadout_value
            var loadout_id := str(loadout.get("starter_loadout_id", ""))
            for policy_id in policies:
                for seed in seeds:
                    scenarios.append({
                        "scenario_id": "%s|%s|%s|%d" % [candidate_id, loadout_id, policy_id, seed],
                        "candidate_id": candidate_id,
                        "starter_loadout_id": loadout_id,
                        "starter_manual_ids": (loadout.get("manual_ids", []) as Array).duplicate(),
                        "player_policy_id": policy_id,
                        "ai_decision_seed": seed,
                        "route_context_id": str(matrix.get("route_context_id", "")),
                        "player_tile": int(matrix.get("player_tile", 0)),
                        "enemy_tile": int(matrix.get("enemy_tile", 0)),
                        "timing_sequence": (matrix.get("timing_sequence", []) as Array).duplicate(),
                        "maximum_rounds": int(matrix.get("maximum_rounds", 0))
                    })
    return scenarios


func run_scenario(scenario_value: Dictionary) -> Dictionary:
    var errors: Array[String] = []
    var scenario := scenario_value.duplicate(true)
    var contract := build_matrix_contract()
    if not bool(contract.get("valid", false)):
        errors.append_array(_string_array(contract.get("errors", [])))
        return {"valid": false, "row": {}, "errors": errors}
    var matrix_errors: Array[String] = []
    var matrix := _load_json(MATRIX_PATH, matrix_errors)
    if matrix.is_empty():
        return {"valid": false, "row": {}, "errors": matrix_errors}
    _validate_scenario(scenario, matrix, errors)
    if not errors.is_empty():
        return {"valid": false, "row": {}, "errors": errors}

    var catalog = CatalogScript.new()
    var binding_builder = BindingScript.new()
    var starter_catalog = StarterCatalogScript.new()
    var candidate: Dictionary = catalog.get_candidate(str(scenario.get("candidate_id", "")))
    var runtime_binding: Dictionary = binding_builder.build(candidate)
    var player_loadout := _string_array(scenario.get("starter_manual_ids", []))
    var player_mastery := starter_catalog.build_mastery(player_loadout)
    if candidate.is_empty() or not bool(runtime_binding.get("valid", false)) or player_mastery.is_empty():
        return {"valid": false, "row": {}, "errors": ["scenario could not rebuild its current runtime candidate or starter loadout"]}

    var engine = RuntimeEngineScript.new()
    if not engine.configure_enemy_runtime_binding(runtime_binding):
        return {"valid": false, "row": {}, "errors": ["runtime engine rejected a validated opponent binding"]}
    var enemy_manual_id := str(candidate.get("signature_manual_id", ""))
    var enemy_mastery := {enemy_manual_id: int(candidate.get("signature_star_seed", 0))}
    engine.configure_martial_loadouts(player_loadout, player_mastery, [enemy_manual_id], enemy_mastery)

    var hud_errors: Array[String] = []
    var hud := _load_json(HUD_PATH, hud_errors)
    if hud.is_empty():
        return {"valid": false, "row": {}, "errors": hud_errors}
    var state: Dictionary = engine.make_initial_state(hud, int(scenario.get("player_tile", 4)), int(scenario.get("enemy_tile", 6)))
    state["ai_enabled"] = true
    state["ai_decision_seed"] = int(scenario.get("ai_decision_seed", 0))
    state["public_resolution_history"] = []

    var timing_sequence: Array = scenario.get("timing_sequence", []) as Array
    var maximum_rounds := int(scenario.get("maximum_rounds", 0))
    var bundles_resolved := 0
    var outcome := "timeout"
    for round_number in range(1, maximum_rounds + 1):
        for bundle_index in range(1, timing_sequence.size() + 1):
            var placements: Array = PublicPolicyScript.build_placements(
                str(scenario.get("player_policy_id", "")),
                state,
                engine.cards_by_id,
                engine.get_player_martial_card_ids(),
                bundle_index,
                timing_sequence
            )
            var preview := engine.preview_player_plan(state, placements)
            if not bool(preview.get("valid", false)):
                return {"valid": false, "row": {}, "errors": ["public policy produced an unaffordable placement at round %d bundle %d" % [round_number, bundle_index]]}
            var result := engine.resolve_bundle(placements, {
                "round_number": round_number,
                "bundle_index": bundle_index,
                "timing_sequence": timing_sequence
            }, state)
            state = (result.get("state", {}) as Dictionary).duplicate(true)
            bundles_resolved += 1
            outcome = _terminal_outcome(state)
            if outcome != "":
                return {"valid": true, "row": _build_public_row(scenario, outcome, bundles_resolved, state), "errors": []}
    return {"valid": true, "row": _build_public_row(scenario, outcome, bundles_resolved, state), "errors": []}


func _validate_scenario(scenario: Dictionary, matrix: Dictionary, errors: Array[String]) -> void:
    var candidate_id := str(scenario.get("candidate_id", ""))
    var catalog = CatalogScript.new()
    if candidate_id.is_empty() or catalog.get_candidate(candidate_id).is_empty():
        errors.append("scenario candidate_id must resolve through the current catalog")
    var starter_catalog = StarterCatalogScript.new()
    var manual_ids := _string_array(scenario.get("starter_manual_ids", []))
    if not starter_catalog.validate_selection(manual_ids):
        errors.append("scenario starter manual selection must remain a legal current 4-of-6 loadout")
    if str(scenario.get("starter_loadout_id", "")) != _loadout_id(manual_ids):
        errors.append("scenario starter_loadout_id must match its exact manual selection")
    if str(scenario.get("player_policy_id", "")) not in PublicPolicyScript.get_policy_ids():
        errors.append("scenario player policy must remain one of the approved public policies")
    if int(scenario.get("ai_decision_seed", 0)) not in _int_array(matrix.get("ai_decision_seeds", [])):
        errors.append("scenario AI decision seed must be listed in the matrix")
    if str(scenario.get("route_context_id", "")) != str(matrix.get("route_context_id", "")):
        errors.append("scenario route_context_id must match the immutable v1 matrix")
    if int(scenario.get("player_tile", 0)) != int(matrix.get("player_tile", 0)):
        errors.append("scenario player_tile must match the immutable v1 matrix")
    if int(scenario.get("enemy_tile", 0)) != int(matrix.get("enemy_tile", 0)):
        errors.append("scenario enemy_tile must match the immutable v1 matrix")
    if _int_array(scenario.get("timing_sequence", [])) != _int_array(matrix.get("timing_sequence", [])):
        errors.append("scenario timing_sequence must match the immutable v1 matrix")
    if int(scenario.get("maximum_rounds", 0)) != int(matrix.get("maximum_rounds", 0)):
        errors.append("scenario maximum_rounds must match the immutable v1 matrix")


func _build_public_row(scenario: Dictionary, outcome: String, bundles_resolved: int, state: Dictionary) -> Dictionary:
    var metrics: Dictionary = (state.get("battle_metrics", {}) as Dictionary).duplicate(true)
    return {
        "scenario_id": str(scenario.get("scenario_id", "")),
        "candidate_id": str(scenario.get("candidate_id", "")),
        "starter_loadout_id": str(scenario.get("starter_loadout_id", "")),
        "player_policy_id": str(scenario.get("player_policy_id", "")),
        "ai_decision_seed": int(scenario.get("ai_decision_seed", 0)),
        "route_context_id": str(scenario.get("route_context_id", "")),
        "outcome": outcome if outcome in ["win", "loss", "draw", "timeout"] else "timeout",
        "bundles_resolved": maxi(0, bundles_resolved),
        "battle_metrics": _normalized_metrics(metrics)
    }


func _terminal_outcome(state: Dictionary) -> String:
    var player_health := _current_health(state, "player")
    var enemy_health := _current_health(state, "enemy")
    if player_health <= 0 and enemy_health <= 0:
        return "draw"
    if enemy_health <= 0:
        return "win"
    if player_health <= 0:
        return "loss"
    return ""


func _normalized_metrics(metrics: Dictionary) -> Dictionary:
    return {
        "successful_dodges": maxi(0, int(metrics.get("successful_dodges", 0))),
        "clash_wins": maxi(0, int(metrics.get("clash_wins", 0))),
        "player_health_lost": maxi(0, int(metrics.get("player_health_lost", 0))),
        "rounds_elapsed": maxi(0, int(metrics.get("rounds_elapsed", 0))),
        "ultimate_uses": maxi(0, int(metrics.get("ultimate_uses", 0)))
    }


func _build_legal_starter_loadouts(starter_catalog) -> Array:
    var manual_ids: Array[String] = []
    for option_value in starter_catalog.get_options():
        if typeof(option_value) == TYPE_DICTIONARY:
            manual_ids.append(str((option_value as Dictionary).get("manual_id", "")))
    manual_ids.sort()
    var result: Array = []
    _append_combinations(manual_ids, 0, [], starter_catalog.REQUIRED_SELECTION_COUNT, result)
    result.sort_custom(_loadout_before)
    return result


func _append_combinations(source: Array[String], start_index: int, selected: Array[String], required_count: int, result: Array) -> void:
    if selected.size() == required_count:
        var manual_ids: Array[String] = selected.duplicate()
        result.append({"starter_loadout_id": _loadout_id(manual_ids), "manual_ids": manual_ids})
        return
    var remaining_needed := required_count - selected.size()
    for index in range(start_index, source.size() - remaining_needed + 1):
        var next_selected: Array[String] = selected.duplicate()
        next_selected.append(source[index])
        _append_combinations(source, index + 1, next_selected, required_count, result)


func _sorted_candidates(raw_candidates: Array) -> Array:
    var candidates: Array = []
    for value in raw_candidates:
        if typeof(value) == TYPE_DICTIONARY:
            candidates.append((value as Dictionary).duplicate(true))
    candidates.sort_custom(_candidate_before)
    return candidates


func _candidate_before(left: Dictionary, right: Dictionary) -> bool:
    return str(left.get("candidate_id", "")) < str(right.get("candidate_id", ""))


func _loadout_before(left: Dictionary, right: Dictionary) -> bool:
    return str(left.get("starter_loadout_id", "")) < str(right.get("starter_loadout_id", ""))


func _loadout_id(manual_ids: Array[String]) -> String:
    var normalized := manual_ids.duplicate()
    normalized.sort()
    return "+".join(normalized)


func _contract_result(errors: Array[String], candidate_count: int, starter_loadout_count: int, scenario_count: int) -> Dictionary:
    return {
        "valid": errors.is_empty(),
        "errors": errors.duplicate(),
        "candidate_count": candidate_count,
        "starter_loadout_count": starter_loadout_count,
        "scenario_count": scenario_count
    }


func _load_json(path: String, errors: Array[String]) -> Dictionary:
    if not FileAccess.file_exists(path):
        errors.append("required JSON is missing: %s" % path)
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        errors.append("required JSON cannot be opened: %s" % path)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        errors.append("required JSON root must be a Dictionary: %s" % path)
        return {}
    return (parsed as Dictionary).duplicate(true)


func _string_array(value) -> Array[String]:
    var result: Array[String] = []
    if typeof(value) != TYPE_ARRAY and typeof(value) != TYPE_PACKED_STRING_ARRAY:
        return result
    for item in value:
        result.append(str(item))
    return result


func _int_array(value) -> Array[int]:
    var result: Array[int] = []
    if typeof(value) != TYPE_ARRAY and typeof(value) != TYPE_PACKED_INT32_ARRAY:
        return result
    for item in value:
        if typeof(item) == TYPE_INT:
            result.append(int(item))
            continue
        if typeof(item) == TYPE_FLOAT and is_equal_approx(float(item), floor(float(item))):
            result.append(int(item))
            continue
        return []
    return result


func _contains_duplicate_ints(values: Array[int]) -> bool:
    var seen := {}
    for value in values:
        if seen.has(value):
            return true
        seen[value] = true
    return false


func _is_valid_tile(tile: int) -> bool:
    return tile >= 1 and tile <= 10


func _current_health(state: Dictionary, actor_key: String) -> int:
    var actor: Dictionary = state.get(actor_key, {}) as Dictionary
    var health = actor.get("health", [])
    if (typeof(health) == TYPE_ARRAY or typeof(health) == TYPE_PACKED_INT32_ARRAY) and health.size() >= 1:
        return int(health[0])
    return 0
