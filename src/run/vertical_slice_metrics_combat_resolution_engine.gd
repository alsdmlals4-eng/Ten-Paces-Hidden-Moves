class_name VerticalSliceMetricsCombatResolutionEngine
extends TenManualCombatResolutionEngine

const METRICS_SCRIPT := preload("res://src/run/vertical_slice_battle_metrics.gd")
const CONSTRAINT_SCRIPT := preload("res://src/run/bimu_constraint_model.gd")

var battle_metrics: VerticalSliceBattleMetrics
var _enemy_runtime_binding: Dictionary = {}
var _bimu_model = CONSTRAINT_SCRIPT.new()
var _bimu_receipt: Dictionary = {}


func configure_bimu_constraints(selection: Array, player_manual_ids: Array, enemy_manual_ids: Array) -> bool:
    for id in player_manual_ids + enemy_manual_ids:
        if typeof(id) != TYPE_STRING or martial_registry.get_manual(id).is_empty():
            return false
    var receipt: Dictionary = _bimu_model.validate_selection(selection, player_manual_ids, enemy_manual_ids)
    if not receipt.get("valid", false):
        return false
    _bimu_receipt = receipt.duplicate(true)
    return true


func get_bimu_receipt() -> Dictionary:
    return _bimu_receipt.duplicate(true)


func get_bimu_enemy_mastery(masteries: Dictionary) -> Dictionary:
    return _bimu_model.enemy_mastery_overlay(masteries, _bimu_receipt)


func get_action_lock_reason(card_id: String) -> String:
    if card_id not in get_player_martial_card_ids():
        return ""
    return _bimu_model.action_lock_reason(get_actor_card_definition(card_id, "player"), _bimu_receipt)


func _constraint_plan_rejection(placements: Array) -> Dictionary:
    var anchors := PackedInt32Array()
    var reasons: Array[String] = []
    for value in placements:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var placement: Dictionary = value
        var definition_value = placement.get("definition", {})
        var definition: Dictionary = definition_value if typeof(definition_value) == TYPE_DICTIONARY else {}
        # Check both identities: caller-provided metadata must never disguise a sealed ID.
        for id in [str(placement.get("card_id", "")), str(definition.get("id", ""))]:
            var reason := get_action_lock_reason(id)
            if not reason.is_empty():
                anchors.append(int(placement.get("anchor_index", 1)))
                reasons.append(reason)
                break
    return {"invalid_anchors": anchors, "reasons": reasons}


func preview_player_plan(state_value: Dictionary, placements: Array) -> Dictionary:
    var actor_rejection := _martial_plan_rejection(placements, state_value)
    if not actor_rejection.is_empty():
        return actor_rejection
    var rejection := _constraint_plan_rejection(placements)
    if not rejection["reasons"].is_empty():
        return {"valid": false, "state": state_value.duplicate(true), "invalid_anchors": rejection["invalid_anchors"], "events": [], "constraint_reasons": rejection["reasons"]}
    return super.preview_player_plan(state_value, placements)


func resolve_martial_card(card_id: String, state: Dictionary, actor_key: String, context: Dictionary = {}) -> Dictionary:
    var reason := get_action_lock_reason(card_id) if actor_key == "player" else ""
    if not reason.is_empty():
        return _martial_failure(state, reason)
    return super.resolve_martial_card(card_id, state, actor_key, context)


func _init() -> void:
    super()
    battle_metrics = METRICS_SCRIPT.new()


func configure_enemy_runtime_binding(binding: Dictionary) -> bool:
    if not _is_valid_enemy_runtime_binding(binding):
        return false
    if ai_planner == null or not ai_planner.has_method("set_runtime_binding"):
        return false
    var focus_ids: Array[String] = []
    for focus_value in binding.get("basic_action_focus_ids", []):
        focus_ids.append(str(focus_value))
    if not ai_planner.set_runtime_binding(
        str(binding.get("archetype_id", "")),
        (binding.get("ai_profile", {}) as Dictionary).duplicate(true),
        focus_ids
    ):
        return false
    _enemy_runtime_binding = binding.duplicate(true)
    return true


func make_initial_state(hud_data: Dictionary, player_tile: int, enemy_tile: int) -> Dictionary:
    var state := super.make_initial_state(hud_data, player_tile, enemy_tile)
    if not _enemy_runtime_binding.is_empty():
        var enemy: Dictionary = (state.get("enemy", {}) as Dictionary).duplicate(true)
        enemy["candidate_id"] = str(_enemy_runtime_binding.get("candidate_id", ""))
        enemy["stats"] = (_enemy_runtime_binding.get("stats", {}) as Dictionary).duplicate(true)
        state["enemy"] = enemy
    state["enemy"] = _bimu_model.enemy_state_overlay(state.get("enemy", {}), _bimu_receipt)
    state["battle_metrics"] = battle_metrics.make_initial_metrics()
    return state


func resolve_bundle(player_placements: Array, context: Dictionary, state_value: Dictionary) -> Dictionary:
    var actor_rejection := _martial_plan_rejection(player_placements, state_value)
    if not actor_rejection.is_empty():
        actor_rejection["rejected"] = true
        return actor_rejection
    var rejection := _constraint_plan_rejection(player_placements)
    if not rejection["reasons"].is_empty():
        return {"rejected": true, "valid": false, "failure_reason": "BIMU_CONSTRAINT_FORBIDDEN_ACTION", "constraint_reasons": rejection["reasons"], "invalid_anchors": rejection["invalid_anchors"], "state": state_value.duplicate(true), "resolved_actions": [], "logs": [], "presentation_events": []}
    var before := state_value.duplicate(true)
    var current: Dictionary = state_value.get("battle_metrics", battle_metrics.make_initial_metrics())
    var result := super.resolve_bundle(player_placements, context, state_value)
    if bool(result.get("rejected", false)):
        return result
    var next_metrics := battle_metrics.accumulate(current, before, result)
    var next_state: Dictionary = result.get("state", {})
    next_state["battle_metrics"] = next_metrics.duplicate(true)
    result["state"] = next_state
    result["battle_metrics"] = next_metrics.duplicate(true)
    return result


func _is_valid_enemy_runtime_binding(binding: Dictionary) -> bool:
    if not bool(binding.get("valid", false)):
        return false
    if str(binding.get("candidate_id", "")).is_empty() or str(binding.get("archetype_id", "")).is_empty():
        return false
    if typeof(binding.get("ai_profile", {})) != TYPE_DICTIONARY or typeof(binding.get("basic_action_focus_ids", [])) != TYPE_ARRAY:
        return false
    var stats = binding.get("stats", {})
    if typeof(stats) != TYPE_DICTIONARY:
        return false
    var stat_total := 0
    for stat_id in ["external", "constitution", "agility", "internal_power", "insight"]:
        if int((stats as Dictionary).get(stat_id, 0)) < 1:
            return false
        stat_total += int((stats as Dictionary).get(stat_id, 0))
    return stat_total == int(binding.get("final_stat_total_seed", 0))


# Legacy v1 execution is unchanged; v2 excludes whole forbidden definitions.
var variable_opponent_rules := false

func _enemy_information_forbidden(definition: Dictionary) -> bool:
    if definition.get("category") == "observation" or int(definition.get("observation_points", 0)) > 0: return true
    for step in definition.get("effect_steps", []):
        if step is Dictionary and step.get("status", step.get("resource", "")) in ["observation", "observation_points"]: return true
    return false

func get_actor_card_definition(card_id: String, actor_key: String) -> Dictionary:
    var definition := super.get_actor_card_definition(card_id, actor_key)
    if variable_opponent_rules and actor_key == "enemy" and _enemy_information_forbidden(definition): return {}
    return definition

func get_actor_cards_by_id(actor_key: String) -> Dictionary:
    var definitions := super.get_actor_cards_by_id(actor_key)
    if variable_opponent_rules and actor_key == "enemy":
        for id in definitions.keys():
            if _enemy_information_forbidden(definitions[id]): definitions.erase(id)
    return definitions
