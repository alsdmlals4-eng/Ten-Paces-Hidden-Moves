class_name VerticalSliceBalanceReportRunner
extends RefCounted

const REPORT_SCHEMA_VERSION := 2
const CONTRACT_ID := "TEN-DEC-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-EXTENSION-01"


func build_full_report(instrumentation) -> Dictionary:
    return build_report(instrumentation, instrumentation.build_scenarios())


func build_report(instrumentation, scenario_values: Array) -> Dictionary:
    var errors: Array[String] = []
    var expected_count := scenario_values.size()
    var rows: Array = []
    for scenario_value in scenario_values:
        if typeof(scenario_value) != TYPE_DICTIONARY:
            errors.append("report scenarios must be Dictionaries")
            continue
        var scenario: Dictionary = scenario_value
        var result: Dictionary = instrumentation.run_scenario(scenario)
        if not bool(result.get("valid", false)):
            errors.append("scenario %s did not resolve: %s" % [str(scenario.get("scenario_id", "")), str(result.get("errors", []))])
            continue
        var row_value = result.get("row", {})
        if typeof(row_value) != TYPE_DICTIONARY or (row_value as Dictionary).is_empty():
            errors.append("scenario %s did not return a normalized report row" % str(scenario.get("scenario_id", "")))
            continue
        rows.append((row_value as Dictionary).duplicate(true))
    if not errors.is_empty():
        return {"valid": false, "report": {}, "errors": errors}

    rows.sort_custom(_row_before)
    if _has_duplicate_scenario_ids(rows):
        return {"valid": false, "report": {}, "errors": ["report scenarios must have unique scenario IDs"]}
    var route_context_id := ""
    if not rows.is_empty():
        route_context_id = str((rows[0] as Dictionary).get("route_context_id", ""))
    return {
        "valid": true,
        "report": {
            "schema_version": REPORT_SCHEMA_VERSION,
            "contract_id": CONTRACT_ID,
            "route_context_id": route_context_id,
            "scenario_count_expected": expected_count,
            "scenario_count_completed": rows.size(),
            "scenario_count": rows.size(),
            "rows": rows
        },
        "errors": []
    }


func serialize_report(report_value: Dictionary) -> String:
    return JSON.stringify(report_value, "  ", true) + "\n"


func write_report(output_path: String, report_value: Dictionary) -> Dictionary:
    if output_path.is_empty():
        return {"valid": false, "errors": ["report output path is required"]}
    var file := FileAccess.open(output_path, FileAccess.WRITE)
    if file == null:
        return {"valid": false, "errors": ["report output could not be opened: %s" % output_path]}
    file.store_string(serialize_report(report_value))
    file.close()
    return {"valid": true, "errors": []}


func _row_before(left: Dictionary, right: Dictionary) -> bool:
    return str(left.get("scenario_id", "")) < str(right.get("scenario_id", ""))


func _has_duplicate_scenario_ids(rows: Array) -> bool:
    var previous_id := ""
    for row_value in rows:
        if typeof(row_value) != TYPE_DICTIONARY:
            return true
        var scenario_id := str((row_value as Dictionary).get("scenario_id", ""))
        if scenario_id.is_empty() or scenario_id == previous_id:
            return true
        previous_id = scenario_id
    return false
