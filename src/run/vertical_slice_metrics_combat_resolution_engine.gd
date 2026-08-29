class_name VerticalSliceMetricsCombatResolutionEngine
extends TenManualCombatResolutionEngine

const METRICS_SCRIPT := preload("res://src/run/vertical_slice_battle_metrics.gd")

var battle_metrics: VerticalSliceBattleMetrics
var _enemy_runtime_binding: Dictionary = {}


func _init() -> void:
    super()
    battle_metrics = METRICS_SCRIPT.new()


func configure_enemy_runtime_binding(binding: Dictionary) -> bool:
    if not _is_valid_enemy_runtime_binding(binding):
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
    state["battle_metrics"] = battle_metrics.make_initial_metrics()
    return state


func resolve_bundle(player_placements: Array, context: Dictionary, state_value: Dictionary) -> Dictionary:
    var before := state_value.duplicate(true)
    var current: Dictionary = state_value.get("battle_metrics", battle_metrics.make_initial_metrics())
    var result := super.resolve_bundle(player_placements, context, state_value)
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
