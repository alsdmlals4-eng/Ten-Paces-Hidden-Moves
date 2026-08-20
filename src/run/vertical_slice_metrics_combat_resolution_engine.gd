class_name VerticalSliceMetricsCombatResolutionEngine
extends TenManualCombatResolutionEngine

const METRICS_SCRIPT := preload("res://src/run/vertical_slice_battle_metrics.gd")

var battle_metrics: VerticalSliceBattleMetrics


func _init() -> void:
    super()
    battle_metrics = METRICS_SCRIPT.new()


func make_initial_state(hud_data: Dictionary, player_tile: int, enemy_tile: int) -> Dictionary:
    var state := super.make_initial_state(hud_data, player_tile, enemy_tile)
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
