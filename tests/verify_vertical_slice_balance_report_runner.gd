extends SceneTree

const InstrumentationScript := preload("res://src/validation/vertical_slice_balance_instrumentation.gd")
const ReportRunnerScript := preload("res://src/validation/vertical_slice_balance_report_runner.gd")

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
    var scenarios: Array = instrumentation.build_scenarios()
    _expect_true(scenarios.size() >= 2, "Runner test needs materialized matrix scenarios.")
    if scenarios.size() >= 2:
        var sample := [scenarios[1], scenarios[0]]
        var runner = ReportRunnerScript.new()
        var first_result: Dictionary = runner.build_report(instrumentation, sample)
        var retry_result: Dictionary = runner.build_report(instrumentation, sample)
        _expect_true(bool(first_result.get("valid", false)), "A sampled report must resolve from actual instrumentation: %s" % str(first_result.get("errors", [])))
        _expect_eq(retry_result, first_result, "The same report input must normalize to an identical report result.")
        var report: Dictionary = first_result.get("report", {})
        _expect_eq(int(report.get("schema_version", 0)), 3, "Representative-policy report schema version must be explicit.")
        _expect_eq(str(report.get("contract_id", "")), "TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01", "Report must identify its approved representative-policy measurement contract.")
        _expect_eq(int(report.get("scenario_count", -1)), 2, "Sampled report must preserve its resolved scenario count.")
        _expect_eq(int(report.get("scenario_count_expected", -1)), 2, "Report must state the exact scenario input count.")
        _expect_eq(int(report.get("scenario_count_completed", -1)), 2, "Report must state the exact completed scenario count.")
        var rows: Array = report.get("rows", [])
        _expect_eq(rows.size(), 2, "Sampled report must expose one public row for each input scenario.")
        if rows.size() == 2:
            _expect_true(str((rows[0] as Dictionary).get("scenario_id", "")) < str((rows[1] as Dictionary).get("scenario_id", "")), "Runner must sort report rows by stable scenario ID.")
        _expect_eq(runner.serialize_report(report), runner.serialize_report(retry_result.get("report", {})), "Report serialization must be byte-stable for identical normalized report data.")
        _expect_false(_contains_forbidden_data(report), "Serialized report data must exclude private planner, placement, UI, and observation data.")

    if failures.is_empty():
        print("VERTICAL_SLICE_BALANCE_REPORT_RUNNER_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)


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
        for child in value:
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
