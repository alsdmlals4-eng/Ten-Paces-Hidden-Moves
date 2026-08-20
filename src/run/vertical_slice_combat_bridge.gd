class_name VerticalSliceCombatBridge
extends "res://src/combat/combat_board_preview_ten_manuals_auto.gd"

const VERTICAL_SLICE_ENGINE_SCRIPT := preload("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd")
const BATTLE_METRICS_SCRIPT := preload("res://src/run/vertical_slice_battle_metrics.gd")

signal terminal_review_ready(result: Dictionary)
signal terminal_review_confirmed(result: Dictionary)

var _vertical_slice_terminal_result: Dictionary = {}
var _vertical_slice_loadout_snapshot: Dictionary = {}
var _battle_metrics_helper: VerticalSliceBattleMetrics


func _ready() -> void:
    _battle_metrics_helper = BATTLE_METRICS_SCRIPT.new()
    super._ready()
    set_meta("vertical_slice_bridge", true)
    set_meta("bridge_scope", "TERMINAL_REVIEW_TO_RUN_RESULT_RUNTIME_LOADOUT_AND_RAW_METRICS")


func configure_vertical_slice_loadouts(
    player_loadout,
    player_mastery_by_manual: Dictionary,
    enemy_loadout,
    enemy_mastery_by_manual: Dictionary,
    enemy_candidate_id: String
) -> bool:
    var player_ids := _string_values(player_loadout)
    var enemy_ids := _string_values(enemy_loadout)
    if player_ids.size() != 4 or enemy_ids.size() != 1 or enemy_candidate_id.is_empty():
        return false
    for manual_id_value in player_ids:
        var manual_id := str(manual_id_value)
        if int(player_mastery_by_manual.get(manual_id, 0)) <= 0:
            return false
    for manual_id_value in enemy_ids:
        var manual_id := str(manual_id_value)
        if int(enemy_mastery_by_manual.get(manual_id, 0)) <= 0:
            return false

    _ten_manual_loadout_data = {
        "authority": "VERTICAL_SLICE_PHASE_IV_RUNTIME_LOADOUT_AND_RAW_METRICS",
        "player": {
            "loadout": player_ids.duplicate(),
            "mastery_by_manual": player_mastery_by_manual.duplicate(true)
        },
        "enemy": {
            "loadout": enemy_ids.duplicate(),
            "mastery_by_manual": enemy_mastery_by_manual.duplicate(true),
            "candidate_id": enemy_candidate_id
        }
    }

    var engine: VerticalSliceMetricsCombatResolutionEngine = VERTICAL_SLICE_ENGINE_SCRIPT.new()
    engine.configure_martial_loadouts(
        player_ids,
        player_mastery_by_manual.duplicate(true),
        enemy_ids,
        enemy_mastery_by_manual.duplicate(true)
    )
    resolution_engine = engine
    combat_state = resolution_engine.make_initial_state(top_hud.hud_data, _player_tile, _enemy_tile)
    combat_state["ai_enabled"] = true
    _configure_ultimate_menu()
    _sync_action_placement_controller_state()
    _sync_runtime_context()
    _apply_combat_state_to_view()
    _refresh_ultimate_menu()
    _sync_action_selection_dock()

    _vertical_slice_loadout_snapshot = {
        "player_loadout": player_ids.duplicate(),
        "player_mastery_by_manual": player_mastery_by_manual.duplicate(true),
        "enemy_candidate_id": enemy_candidate_id,
        "enemy_loadout": enemy_ids.duplicate(),
        "enemy_mastery_by_manual": enemy_mastery_by_manual.duplicate(true)
    }
    set_meta("vertical_slice_runtime_loadout_bound", true)
    set_meta("vertical_slice_enemy_candidate_id", enemy_candidate_id)
    set_meta("vertical_slice_battle_metrics_bound", true)
    return true


func get_vertical_slice_loadout_snapshot() -> Dictionary:
    return _vertical_slice_loadout_snapshot.duplicate(true)


func _show_review_panel(terminal: bool) -> void:
    super._show_review_panel(terminal)
    if not terminal:
        return
    _vertical_slice_terminal_result = _build_vertical_slice_terminal_result()
    terminal_review_ready.emit(_vertical_slice_terminal_result.duplicate(true))


func _on_review_continue_requested() -> void:
    if _presentation_state != "review_ready":
        return
    if _review_terminal:
        if _vertical_slice_terminal_result.is_empty():
            _vertical_slice_terminal_result = _build_vertical_slice_terminal_result()
        terminal_review_confirmed.emit(_vertical_slice_terminal_result.duplicate(true))
        return
    super._on_review_continue_requested()


func _build_vertical_slice_terminal_result() -> Dictionary:
    var player_health := _current_health("player")
    var enemy_health := _current_health("enemy")
    var outcome := "draw"
    if enemy_health <= 0 and player_health > 0:
        outcome = "win"
    elif player_health <= 0 and enemy_health > 0:
        outcome = "loss"

    var metrics := _battle_metrics_helper.make_initial_metrics() if _battle_metrics_helper != null else {}
    if combat_state.has("battle_metrics") and typeof(combat_state.get("battle_metrics")) == TYPE_DICTIONARY:
        metrics = _battle_metrics_helper.normalize(combat_state.get("battle_metrics", {})) if _battle_metrics_helper != null else (combat_state.get("battle_metrics", {}) as Dictionary).duplicate(true)

    return {
        "terminal": true,
        "outcome": outcome,
        "player_health": player_health,
        "enemy_health": enemy_health,
        "battle_metrics": metrics.duplicate(true),
        "review_summary": _last_review_summary.duplicate(true),
        "presentation_state": _presentation_state
    }


func _current_health(actor_key: String) -> int:
    var actor: Dictionary = combat_state.get(actor_key, {})
    var health = actor.get("health", [0, 0])
    if typeof(health) == TYPE_ARRAY and health.size() >= 1:
        return int(health[0])
    if typeof(health) == TYPE_PACKED_INT32_ARRAY and health.size() >= 1:
        return int(health[0])
    return 0
