class_name TenManualProductScenarioValidator
extends RefCounted

const REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")
const PIPELINE_SCRIPT := preload("res://src/combat/martial_effect_pipeline.gd")

func run(contract: Dictionary) -> Dictionary:
    var started := Time.get_ticks_msec()
    var failures: Array[String] = []
    var results: Array[Dictionary] = []
    var registry = REGISTRY_SCRIPT.new()
    if not registry.is_valid():
        failures.append("MartialManualRegistry must load exactly ten manuals: %s" % registry.load_errors)
        return _build_report(registry, contract, results, failures, started)
    if not registry.has_method("build_product_validation_snapshot"):
        failures.append("MartialManualRegistry must expose build_product_validation_snapshot.")
        return _build_report(registry, contract, results, failures, started)

    for row_value in contract.get("scenario_matrix", []):
        if typeof(row_value) != TYPE_DICTIONARY:
            failures.append("Scenario row must be a Dictionary.")
            continue
        _verify_scenario(registry, row_value as Dictionary, results, failures)
    if results.size() != 50:
        failures.append("Exactly 50 product scenarios must execute, got %d." % results.size())
    return _build_report(registry, contract, results, failures, started)

func _verify_scenario(registry, row: Dictionary, results: Array[Dictionary], failures: Array[String]) -> void:
    var manual_id := str(row.get("manual_id", ""))
    var mastery := int(row.get("mastery", 0))
    var scenario_id := str(row.get("scenario_id", ""))
    var before_count := failures.size()
    var snapshot: Dictionary = registry.build_product_validation_snapshot(manual_id, mastery)
    _expect(not snapshot.is_empty(), "%s snapshot must exist." % scenario_id, failures)
    if snapshot.is_empty():
        results.append({"scenario_id": scenario_id, "passed": false})
        return

    var cards: Array = snapshot.get("cards", [])
    var card_ids: Array[String] = []
    for card_value in cards:
        if typeof(card_value) == TYPE_DICTIONARY:
            card_ids.append(str((card_value as Dictionary).get("id", "")))
    _expect(int(snapshot.get("mastery", -1)) == mastery, "%s mastery mismatch." % scenario_id, failures)
    _expect(str(snapshot.get("manual_id", "")) == manual_id, "%s manual ID mismatch." % scenario_id, failures)
    _expect(bool(snapshot.get("star3_unlocked", false)), "%s must unlock star3." % scenario_id, failures)
    _expect(bool(snapshot.get("star7_unlocked", false)) == (mastery >= 7), "%s star7 unlock drift." % scenario_id, failures)
    _expect(bool(snapshot.get("star10_unlocked", false)) == (mastery >= 10), "%s star10 unlock drift." % scenario_id, failures)
    _expect(int(snapshot.get("star5_overlay_count", -1)) == (1 if mastery >= 5 else 0), "%s star5 overlay count drift." % scenario_id, failures)
    _expect(int(snapshot.get("star9_overlay_count", -1)) == (1 if mastery >= 9 else 0), "%s star9 overlay count drift." % scenario_id, failures)
    _expect(int(snapshot.get("card_count", -1)) == (1 + (1 if mastery >= 7 else 0) + (1 if mastery >= 10 else 0)), "%s card count drift." % scenario_id, failures)
    for card_value in cards:
        if typeof(card_value) != TYPE_DICTIONARY:
            failures.append("%s contains a non-Dictionary card." % scenario_id)
            continue
        _execute_card_program(scenario_id, card_value as Dictionary, failures)
    results.append({
        "scenario_id": scenario_id,
        "manual_id": manual_id,
        "mastery": mastery,
        "card_ids": card_ids,
        "passed": failures.size() == before_count
    })

func _execute_card_program(scenario_id: String, card: Dictionary, failures: Array[String]) -> void:
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
    _expect(reason not in ["MISSING_COMBATANT", "INVALID_EFFECT_STEPS", "INVALID_EFFECT_STEP", "UNKNOWN_EFFECT_OP"], "%s card %s failed structurally: %s" % [scenario_id, card.get("id", ""), reason], failures)
    _expect((result.get("events", []) as Array).size() > 0, "%s card %s must emit effect events." % [scenario_id, card.get("id", "")], failures)

func _build_report(registry, contract: Dictionary, results: Array[Dictionary], failures: Array[String], started: int) -> Dictionary:
    var passed := 0
    for result in results:
        if bool(result.get("passed", false)):
            passed += 1
    return {
        "decision_id": "TEN_MANUAL_PRODUCT_VALIDATION_GATE",
        "scenario_count": results.size(),
        "passed": passed,
        "failed": results.size() - passed,
        "manuals": registry.get_manual_ids().size() if registry != null and registry.is_valid() else 0,
        "mastery_levels": contract.get("mastery_levels", []),
        "elapsed_ms": Time.get_ticks_msec() - started,
        "results": results,
        "failures": failures
    }

func _expect(condition: bool, message: String, failures: Array[String]) -> void:
    if not condition:
        failures.append(message)
