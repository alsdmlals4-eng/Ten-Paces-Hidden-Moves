extends SceneTree

const VALIDATOR_SCRIPT := preload("res://src/validation/ten_manual_product_scenario_validator.gd")
const CONTRACT_PATH := "res://docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json"
const DEFAULT_OUTPUT_PATH := "res://artifacts/ten-manual-product-validation/product_scenarios.json"

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var contract := _load_json(CONTRACT_PATH)
    if contract.is_empty():
        quit(1)
        return
    var report: Dictionary = VALIDATOR_SCRIPT.new().run(contract)
    if not _write_json(_evidence_output_path(), report):
        quit(1)
        return
    var failures: Array = report.get("failures", [])
    if failures.is_empty() and int(report.get("scenario_count", 0)) == 50 and int(report.get("failed", -1)) == 0:
        print("TEN_MANUAL_PRODUCT_GATE_50_SCENARIOS_OK")
        quit(0)
        return
    for failure in failures:
        push_error(str(failure))
    quit(1)

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Could not open JSON: %s" % path)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("JSON root must be a Dictionary: %s" % path)
        return {}
    return parsed as Dictionary

func _evidence_output_path() -> String:
    var evidence_dir := OS.get_environment("TEN_MANUAL_EVIDENCE_DIR").strip_edges()
    if evidence_dir.is_empty():
        return DEFAULT_OUTPUT_PATH
    return evidence_dir.path_join("product_scenarios.json")

func _write_json(path: String, value: Dictionary) -> bool:
    var absolute_path := path
    if path.begins_with("res://") or path.begins_with("user://"):
        absolute_path = ProjectSettings.globalize_path(path)
    var error := DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
    if error != OK and error != ERR_ALREADY_EXISTS:
        push_error("Could not create evidence directory: %s" % error)
        return false
    var file := FileAccess.open(absolute_path, FileAccess.WRITE)
    if file == null:
        push_error("Could not write evidence JSON: %s" % absolute_path)
        return false
    file.store_string(JSON.stringify(value, "  ") + "\n")
    return true
