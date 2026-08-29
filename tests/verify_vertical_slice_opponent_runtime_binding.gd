# 첫 5전 후보 데이터를 검증된 전투별 런타임 binding으로 변환하는 계약을 검증한다.
extends SceneTree

const BindingScript := preload("res://src/run/vertical_slice_opponent_runtime_binding.gd")
const CatalogScript := preload("res://src/run/vertical_slice_opponent_catalog.gd")

const EXPECTED_BINDING_KEYS := [
    "valid",
    "candidate_id",
    "archetype_id",
    "ai_profile",
    "basic_action_focus_ids",
    "stats",
    "final_stat_total_seed"
]
const EXPECTED_STAT_ORDER := ["external", "constitution", "agility", "internal_power", "insight"]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var binding = BindingScript.new()
    var catalog = CatalogScript.new()
    _expect_true(binding.is_valid(), "Archetype data must load before a candidate can bind: %s" % str(binding.get_load_errors()))
    _expect_true(catalog.is_valid(), "Catalog must reject candidates without a valid runtime archetype: %s" % str(catalog.load_errors))

    var dogyeom: Dictionary = catalog.get_candidate("slot1_dogyeom")
    var dogyeom_binding: Dictionary = binding.build(dogyeom)
    _expect_true(bool(dogyeom_binding.get("valid", false)), "Dogyeom must produce a valid runtime binding.")
    _expect_eq(str(dogyeom_binding.get("archetype_id", "")), "stabilize_then_pressure", "Dogyeom must use the approved reusable archetype.")
    _expect_eq(dogyeom_binding.get("stats", {}), {"external": 4, "constitution": 6, "agility": 3, "internal_power": 4, "insight": 3}, "A total-20 stabilize profile must allocate its exact five stats.")
    _expect_eq(int(dogyeom_binding.get("final_stat_total_seed", 0)), 20, "Binding must retain the candidate stat total seed.")
    _expect_binding_shape(dogyeom_binding)

    for candidate_value in catalog.get_all_candidates():
        if typeof(candidate_value) != TYPE_DICTIONARY:
            failures.append("Catalog candidates must remain Dictionaries.")
            continue
        var candidate: Dictionary = candidate_value
        var result: Dictionary = binding.build(candidate)
        _expect_true(bool(result.get("valid", false)), "Every approved candidate must bind: %s" % str(candidate.get("candidate_id", "")))
        var stats: Dictionary = result.get("stats", {})
        _expect_eq(_sum_stats(stats), int(candidate.get("final_stat_total_seed", -1)), "Derived stats must sum to the locked total: %s" % str(candidate.get("candidate_id", "")))
        for stat_id in EXPECTED_STAT_ORDER:
            _expect_true(int(stats.get(stat_id, 0)) >= 1, "Derived stats must remain positive: %s -> %s" % [str(candidate.get("candidate_id", "")), stat_id])

    _expect_false(bool(binding.build({"candidate_id": "bad"}).get("valid", true)), "Missing archetype, focus, and total data must fail closed.")
    if failures.is_empty():
        print("VERTICAL_SLICE_OPPONENT_RUNTIME_BINDING_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)


func _expect_binding_shape(binding: Dictionary) -> void:
    var keys: Array[String] = []
    for key_value in binding.keys():
        keys.append(str(key_value))
    keys.sort()
    var expected := EXPECTED_BINDING_KEYS.duplicate()
    expected.sort()
    _expect_eq(keys, expected, "A valid binding must expose only the approved runtime fields.")


func _sum_stats(stats: Dictionary) -> int:
    var total := 0
    for stat_id in EXPECTED_STAT_ORDER:
        total += int(stats.get(stat_id, 0))
    return total


func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)


func _expect_false(value: bool, message: String) -> void:
    if value:
        failures.append(message)


func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])
