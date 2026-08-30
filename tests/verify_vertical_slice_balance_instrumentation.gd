extends SceneTree

const InstrumentationScript := preload("res://src/validation/vertical_slice_balance_instrumentation.gd")

const EXPECTED_METRIC_KEYS := [
    "clash_wins",
    "player_health_lost",
    "rounds_elapsed",
    "successful_dodges",
    "ultimate_uses"
]
const FORBIDDEN_TOKENS := [
    "ai_profile",
    "weight",
    "trace",
    "locked_enemy",
    "pending",
    "preview",
    "pointer",
    "focus",
    "observation"
]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var instrumentation = InstrumentationScript.new()
    var contract: Dictionary = instrumentation.build_matrix_contract()
    _expect_true(bool(contract.get("valid", false)), "Current balance matrix must validate: %s" % str(contract.get("errors", [])))
    _expect_eq(int(contract.get("candidate_count", -1)), 15, "All 15 current candidates must be covered.")
    _expect_eq(int(contract.get("starter_loadout_count", -1)), 15, "Every legal current 4-of-6 starter selection must be covered.")
    _expect_eq(int(contract.get("scenario_count", -1)), 3375, "The first balance matrix must contain exactly 3,375 duels.")

    var scenarios: Array = instrumentation.build_scenarios()
    _expect_eq(scenarios.size(), 3375, "Every matrix scenario must materialize from current source data.")
    if not scenarios.is_empty():
        var first: Dictionary = scenarios[0]
        var first_again: Dictionary = first.duplicate(true)
        var first_result: Dictionary = instrumentation.run_scenario(first)
        var retry_result: Dictionary = instrumentation.run_scenario(first_again)
        _expect_true(bool(first_result.get("valid", false)), "A valid first matrix scenario must resolve through the actual engine: %s" % str(first_result.get("errors", [])))
        _expect_eq(retry_result, first_result, "The same scenario must produce an identical normalized result row.")
        _verify_public_row(first_result.get("row", {}))

        if scenarios.size() > 1:
            var second: Dictionary = scenarios[1]
            var second_result: Dictionary = instrumentation.run_scenario(second)
            _expect_true(bool(second_result.get("valid", false)), "A second scenario must start from its own fresh engine state.")
            _expect_eq(str((second_result.get("row", {}) as Dictionary).get("candidate_id", "")), str(second.get("candidate_id", "")), "A later scenario must not retain the prior candidate binding.")

        var invalid: Dictionary = first.duplicate(true)
        invalid["candidate_id"] = "missing_candidate"
        var invalid_result: Dictionary = instrumentation.run_scenario(invalid)
        _expect_false(bool(invalid_result.get("valid", true)), "An unknown candidate must fail closed instead of producing a partial row.")
        _expect_true((invalid_result.get("row", {}) as Dictionary).is_empty(), "An invalid scenario must not produce a result row.")

    if failures.is_empty():
        print("VERTICAL_SLICE_BALANCE_INSTRUMENTATION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)


func _verify_public_row(value) -> void:
    _expect_true(typeof(value) == TYPE_DICTIONARY, "A successful scenario must expose one normalized result Dictionary.")
    if typeof(value) != TYPE_DICTIONARY:
        return
    var row: Dictionary = value
    _expect_eq(str(row.get("route_context_id", "")), "opening_no_route", "v1 must not inject Route recovery into a single duel.")
    _expect_true(str(row.get("outcome", "")) in ["win", "loss", "draw", "timeout"], "Outcome must be a normalized terminal value.")
    _expect_true(int(row.get("bundles_resolved", -1)) >= 0, "Resolved-bundle count must be nonnegative.")
    var metrics: Dictionary = row.get("battle_metrics", {})
    var metric_keys: Array[String] = []
    for key_value in metrics.keys():
        metric_keys.append(str(key_value))
    metric_keys.sort()
    _expect_eq(metric_keys, EXPECTED_METRIC_KEYS, "Rows must preserve exactly the existing five battle metrics.")
    _expect_false(_contains_forbidden_data(row), "Normalized report rows must exclude private planner, placement, UI, and observation data.")


func _contains_forbidden_data(value) -> bool:
    if typeof(value) == TYPE_DICTIONARY:
        for key_value in (value as Dictionary).keys():
            var key_text := str(key_value).to_lower()
            for token in FORBIDDEN_TOKENS:
                if token in key_text:
                    return true
            if _contains_forbidden_data((value as Dictionary)[key_value]):
                return true
    elif typeof(value) == TYPE_ARRAY:
        for child in (value as Array):
            if _contains_forbidden_data(child):
                return true
    return false


func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)


func _expect_false(value: bool, message: String) -> void:
    if value:
        failures.append(message)


func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])
