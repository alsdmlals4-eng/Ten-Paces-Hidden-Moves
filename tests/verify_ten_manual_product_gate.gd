extends SceneTree

const REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")
const PIPELINE_SCRIPT := preload("res://src/combat/martial_effect_pipeline.gd")
const CONTRACT_PATH := "res://docs/planning-data/approved_20260806_ten_manual_product_validation_gate_contract.json"
const DEFAULT_OUTPUT_PATH := "res://artifacts/ten-manual-product-validation/product_scenarios.json"

var failures: Array[String] = []
var results: Array[Dictionary] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var started := Time.get_ticks_msec()
    var contract := _load_json(CONTRACT_PATH)
    var registry = REGISTRY_SCRIPT.new()
    if not registry.is_valid():
        _fail_now("MartialManualRegistry must load exactly ten manuals: %s" % registry.load_errors)
        return
    if not registry.has_method("build_product_validation_snapshot"):
        _fail_now("MartialManualRegistry must expose build_product_validation_snapshot.")
        return
    for row_value in contract.get("scenario_matrix", []):
        if typeof(row_value) != TYPE_DICTIONARY:
            failures.append("Scenario row must be a Dictionary.")
            continue
        _verify_scenario(registry, row_value as Dictionary)
    _expect(results.size() == 50, "Exactly 50 product scenarios must execute, got %d." % results.size())
    var passed := 0
    for result in results:
        if bool(result.get("passed", false)):
            passed += 1
    _write_json(_evidence_output_path(), {
        "decision_id": "TEN_MANUAL_PRODUCT_VALIDATION_GATE",
        "scenario_count": results.size(),
        "passed": passed,
        "failed": results.size() - passed,
        "manuals": registry.get_manual_ids().size(),
        "mastery_levels": contract.get("mastery_levels", []),
        "elapsed_ms": Time.get_ticks_msec() - started,
        "results": results
    })
    _finish()

func _verify_scenario(registry, row: Dictionary) -> void:
    var manual_id := str(row.get("manual_id", ""))
    var mastery := int(row.get("mastery", 0))
    var scenario_id := str(row.get("scenario_id", ""))
    var before_count := failures.size()
    var snapshot: Dictionary = registry.build_product_validation_snapshot(manual_id, mastery)
    _expect(not snapshot.is_empty(), "%s snapshot must exist." % scenario_id)
    if snapshot.is_empty():
        results.append({"scenario_id": scenario_id, "passed": false})
        return
    var cards: Array = snapshot.get("cards", [])
    var card_ids: Array[String] = []
    for card_value in cards:
        if typeof(card_value) == TYPE_DICTIONARY:
            card_ids.append(str((card_value as Dictionary).get("id", "")))
    _expect(int(snapshot.get("mastery", -1)) == mastery, "%s mastery mismatch." % scenario_id)
    _expect(str(snapshot.get("manual_id", "")) == manual_id, "%s manual ID mismatch." % scenario_id)
    _expect(bool(snapshot.get("star3_unlocked", false)), "%s must unlock star3." % scenario_id)
    _expect(bool(snapshot.get("star7_unlocked", false)) == (mastery >= 7), "%s star7 unlock drift." % scenario_id)
    _expect(bool(snapshot.get("star10_unlocked", false)) == (mastery >= 10), "%s star10 unlock drift." % scenario_id)
    _expect(int(snapshot.get("star5_overlay_count", -1)) == (1 if mastery >= 5 else 0), "%s star5 overlay count drift." % scenario_id)
    _expect(int(snapshot.get("star9_overlay_count", -1)) == (1 if mastery >= 9 else 0), "%s star9 overlay count drift." % scenario_id)
    _expect(int(snapshot.get("card_count", -1)) == (1 + (1 if mastery >= 7 else 0) + (1 if mastery >= 10 else 0)), "%s card count drift." % scenario_id)
    for card_value in cards:
        if typeof(card_value) != TYPE_DICTIONARY:
            failures.append("%s contains a non-Dictionary card." % scenario_id)
            continue
        _execute_card_program(scenario_id, card_value as Dictionary)
    results.append({
        "scenario_id": scenario_id,
        "manual_id": manual_id,
        "mastery": mastery,
        "card_ids": card_ids,
        "passed": failures.size() == before_count
    })

func _execute_card_program(scenario_id: String, card: Dictionary) -> void:
    var pipeline = PIPELINE_SCRIPT.new()
    var state := {
        "player": {"position": 4, "health": [30, 30], "stamina": [10, 10], "internal": [10, 10], "momentum": [5, 5], "defense": 4, "statuses": {"prepared": 1, "evade": 1, "fortitude": 1}, "once_per_battle": {}},
        "enemy": {"position": 5, "health": [30, 30], "stamina": [10, 10], "internal": [10, 10], "momentum": [5, 5], "defense": 2, "statuses": {}, "once_per_battle": {}}
    }
    var result: Dictionary = pipeline.execute(card, state, "player", {
        "direction": 1,
        "clash_won": true,
        "evade_succeeded": true,
        "resource_maximums": {"health": 30, "stamina": 10, "internal": 10, "momentum": 5},
        "stats": {"외공": 4, "근골": 4, "신법": 4, "내공": 4, "심안": 4}
    })
    var reason := str(result.get("failure_reason", ""))
    _expect(reason not in ["MISSING_COMBATANT", "INVALID_EFFECT_STEPS", "INVALID_EFFECT_STEP", "UNKNOWN_EFFECT_OP"], "%s card %s failed structurally: %s" % [scenario_id, card.get("id", ""), reason])
    _expect((result.get("events", []) as Array).size() > 0, "%s card %s must emit effect events." % [scenario_id, card.get("id", "")])

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _fail_now(message: String) -> void:
    push_error(message)
    quit(1)

func _finish() -> void:
    if failures.is_empty():
        print("TEN_MANUAL_PRODUCT_GATE_50_SCENARIOS_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        failures.append("Could not open JSON: %s" % path)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        failures.append("JSON root must be a Dictionary: %s" % path)
        return {}
    return parsed as Dictionary

func _evidence_output_path() -> String:
    var evidence_dir := OS.get_environment("TEN_MANUAL_EVIDENCE_DIR").strip_edges()
    if evidence_dir.is_empty():
        return DEFAULT_OUTPUT_PATH
    return evidence_dir.path_join("product_scenarios.json")

func _write_json(path: String, value: Dictionary) -> void:
    var absolute_path := path
    if path.begins_with("res://") or path.begins_with("user://"):
        absolute_path = ProjectSettings.globalize_path(path)
    var absolute_dir := absolute_path.get_base_dir()
    var error := DirAccess.make_dir_recursive_absolute(absolute_dir)
    if error != OK and error != ERR_ALREADY_EXISTS:
        failures.append("Could not create evidence directory: %s" % error)
        return
    var file := FileAccess.open(absolute_path, FileAccess.WRITE)
    if file == null:
        failures.append("Could not write evidence JSON: %s" % absolute_path)
        return
    file.store_string(JSON.stringify(value, "  ") + "\n")
