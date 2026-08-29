# 첫 5전 후보 데이터를 검증된 전투별 런타임 binding으로 변환하는 계약을 검증한다.
extends SceneTree

const BindingScript := preload("res://src/run/vertical_slice_opponent_runtime_binding.gd")
const CatalogScript := preload("res://src/run/vertical_slice_opponent_catalog.gd")
const RuntimeEngineScript := preload("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd")
const HUD_PATH := "res://data/combat/combat_hud_preview.json"

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
    _verify_per_combat_engine_binding(binding, catalog)
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

func _verify_per_combat_engine_binding(binding, catalog) -> void:
    var first := _start_locked_candidate_combat(binding, catalog, "slot3_seolha")
    _expect_eq(str((first.get("binding", {}) as Dictionary).get("archetype_id", "")), "range_control", "Slot 3 candidate must reach its approved runtime archetype.")
    _expect_eq(_sum_stats((first.get("combat_state", {}).get("enemy", {}) as Dictionary).get("stats", {})), 24, "Slot 3 enemy stat sum must equal its locked seed.")
    _expect_eq(str((first.get("trace", {}) as Dictionary).get("runtime_archetype_id", "")), "range_control", "The per-combat planner must receive the locked range-control binding.")
    _expect_true(_trace_uses_only_public_data(first.get("trace", {})), "Integrated AI trace must exclude current player plan and UI state.")

    var retry := _start_locked_candidate_combat(binding, catalog, "slot3_seolha")
    _expect_eq(retry.get("combat_state", {}), first.get("combat_state", {}), "A same-candidate retry rebuild must reproduce isolated initial state.")
    _expect_eq(retry.get("actions", []), first.get("actions", []), "A same-candidate retry rebuild must reproduce public actions.")
    _expect_eq(retry.get("trace", {}), first.get("trace", {}), "A same-candidate retry rebuild must reproduce the public trace.")

    var second := _start_locked_candidate_combat(binding, catalog, "slot1_dogyeom")
    _expect_eq(str((second.get("binding", {}) as Dictionary).get("archetype_id", "")), "stabilize_then_pressure", "A second combat must bind its own candidate archetype.")
    _expect_eq(_sum_stats((second.get("combat_state", {}).get("enemy", {}) as Dictionary).get("stats", {})), 20, "A second combat must use its own candidate stat seed.")
    _expect_eq(str((second.get("trace", {}) as Dictionary).get("runtime_archetype_id", "")), "stabilize_then_pressure", "A second engine must not retain the first engine archetype.")
    _expect_true(second.get("combat_state", {}) != first.get("combat_state", {}) or second.get("trace", {}) != first.get("trace", {}), "Separate candidate combats must not leak the first binding state into the second engine.")

    var counter_history := [
        {"round_number": 1, "bundle_index": 1, "actor": "player", "card_id": "basic_quick_attack", "category": "attack", "outcome": "completed"},
        {"round_number": 1, "bundle_index": 1, "actor": "player", "card_id": "basic_palm", "category": "attack", "outcome": "completed"}
    ]
    var counter := _start_locked_candidate_combat(binding, catalog, "slot4_cheongheo", counter_history)
    _expect_eq(int((counter.get("trace", {}) as Dictionary).get("public_history_count", -1)), 2, "Counter profile may consume only the two resolved player history records supplied by combat state.")
    _expect_true(_trace_uses_only_public_data(counter.get("trace", {})), "Counter trace must expose no plan, UI, focus, or observation field.")

func _start_locked_candidate_combat(binding, catalog, candidate_id: String, public_history: Array = []) -> Dictionary:
    var candidate: Dictionary = catalog.get_candidate(candidate_id)
    var runtime_binding: Dictionary = binding.build(candidate)
    if not bool(runtime_binding.get("valid", false)):
        failures.append("Integrated candidate must build a valid binding: %s" % candidate_id)
        return {}
    var engine = RuntimeEngineScript.new()
    if not engine.configure_enemy_runtime_binding(runtime_binding):
        failures.append("Runtime engine must accept the validated binding before combat initialization: %s" % candidate_id)
        return {}
    var manual_id := str(candidate.get("signature_manual_id", ""))
    engine.configure_martial_loadouts([], {}, [manual_id], {manual_id: int(candidate.get("signature_star_seed", 0))})
    var state: Dictionary = engine.make_initial_state(_load_json(HUD_PATH), 4, 6)
    state["ai_enabled"] = true
    state["ai_decision_seed"] = 0
    if not public_history.is_empty():
        state["public_resolution_history"] = public_history.duplicate(true)
    state["debug_hidden_player_plan"] = [{"card_id": "ultimate_void_sword_qi", "target_tile": 10}]
    state["pointer_focus"] = "must_not_leak"
    state["uncommitted_target_preview"] = {"direction": 1, "tile": 10}
    state["observation_answer"] = "must_not_leak"
    var actions: Array = engine.ai_planner.build_bundle_actions(state, 1, engine.get_enemy_ai_cards_by_id())
    return {
        "binding": runtime_binding.duplicate(true),
        "combat_state": state.duplicate(true),
        "actions": actions.duplicate(true),
        "trace": engine.ai_planner.get_last_trace()
    }

func _trace_uses_only_public_data(value) -> bool:
    var forbidden_tokens := ["placement", "player_plan", "uncommitted", "reserved_ultimate", "preview_resource", "pointer", "focus", "target_preview", "observation"]
    if typeof(value) == TYPE_DICTIONARY:
        for key_value in (value as Dictionary).keys():
            var key_text := str(key_value).to_lower()
            for token in forbidden_tokens:
                if token in key_text:
                    return false
            if not _trace_uses_only_public_data((value as Dictionary)[key_value]):
                return false
    elif typeof(value) == TYPE_ARRAY:
        for child in (value as Array):
            if not _trace_uses_only_public_data(child):
                return false
    return true

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


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
