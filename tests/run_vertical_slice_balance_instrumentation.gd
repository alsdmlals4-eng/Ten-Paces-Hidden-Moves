extends SceneTree

const InstrumentationScript := preload("res://src/validation/vertical_slice_balance_instrumentation.gd")
const ReportRunnerScript := preload("res://src/validation/vertical_slice_balance_report_runner.gd")
const EXPECTED_SCENARIO_COUNT := 4500


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var output_path := _parse_output_path(OS.get_cmdline_user_args())
    if output_path.is_empty():
        push_error("BALANCE_REPORT_OUTPUT_ARGUMENT_INVALID")
        quit(1)
        return
    var absolute_output := ProjectSettings.globalize_path(output_path)
    var parent_directory := absolute_output.get_base_dir()
    if DirAccess.make_dir_recursive_absolute(parent_directory) != OK:
        push_error("BALANCE_REPORT_OUTPUT_DIRECTORY_UNAVAILABLE")
        quit(1)
        return

    var instrumentation = InstrumentationScript.new()
    var runner = ReportRunnerScript.new()
    var result: Dictionary = runner.build_full_report(instrumentation)
    if not bool(result.get("valid", false)):
        push_error("BALANCE_REPORT_BUILD_FAILED: %s" % str(result.get("errors", [])))
        quit(1)
        return
    var report: Dictionary = result.get("report", {})
    if int(report.get("scenario_count_expected", -1)) != EXPECTED_SCENARIO_COUNT or int(report.get("scenario_count_completed", -1)) != EXPECTED_SCENARIO_COUNT:
        push_error("BALANCE_REPORT_COVERAGE_INVALID")
        quit(1)
        return
    var write_result: Dictionary = runner.write_report(output_path, report)
    if not bool(write_result.get("valid", false)):
        push_error("BALANCE_REPORT_WRITE_FAILED: %s" % str(write_result.get("errors", [])))
        quit(1)
        return
    print("VERTICAL_SLICE_BALANCE_INSTRUMENTATION_OK scenarios=%d" % EXPECTED_SCENARIO_COUNT)
    quit(0)


func _parse_output_path(arguments: PackedStringArray) -> String:
    if arguments.is_empty():
        return "user://vertical_slice_balance_report.json"
    if arguments.size() != 2 or str(arguments[0]) != "--output":
        return ""
    var output_path := str(arguments[1]).strip_edges()
    return output_path
