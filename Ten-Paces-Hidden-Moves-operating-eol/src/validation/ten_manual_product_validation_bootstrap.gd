extends Node

const VALIDATOR_SCRIPT := preload("res://src/validation/ten_manual_product_scenario_validator.gd")
const ENABLE_ENV := "TEN_MANUAL_PRODUCT_VALIDATION"
const OUTPUT_DIR_ENV := "TEN_MANUAL_EVIDENCE_DIR"

func _ready() -> void:
    if OS.get_environment(ENABLE_ENV).strip_edges() != "1":
        return
    call_deferred("_run_validation")

func _run_validation() -> void:
    var validator = VALIDATOR_SCRIPT.new()
    var report: Dictionary = validator.run(validator.build_runtime_contract())
    var output_dir := OS.get_environment(OUTPUT_DIR_ENV).strip_edges()
    if output_dir.is_empty():
        push_error("%s must be set for exported product validation." % OUTPUT_DIR_ENV)
        get_tree().quit(1)
        return
    var output_path := output_dir.path_join("product_scenarios.json")
    if not _write_json(output_path, report):
        get_tree().quit(1)
        return
    var failures: Array = report.get("failures", [])
    if failures.is_empty() and int(report.get("scenario_count", 0)) == 50 and int(report.get("failed", -1)) == 0:
        print("TEN_MANUAL_EXPORTED_PRODUCT_VALIDATION_OK")
        get_tree().quit(0)
        return
    for failure in failures:
        push_error(str(failure))
    get_tree().quit(1)

func _write_json(path: String, value: Dictionary) -> bool:
    var error := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
    if error != OK and error != ERR_ALREADY_EXISTS:
        push_error("Could not create exported evidence directory: %s" % error)
        return false
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        push_error("Could not write exported product evidence: %s" % path)
        return false
    file.store_string(JSON.stringify(value, "  ") + "\n")
    return true
