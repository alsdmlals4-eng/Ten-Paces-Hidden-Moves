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
    set_meta("bridge_scope", "TERMINAL_REVIEW_RESULT_LOADOUT_RAW_METRICS_AND_RUN_RESOURCE_PERSISTENCE")


func configure_vertical_slice_loadouts(
    player_loadout,
    player_mastery_by_manual: Dictionary,
    enemy_loadout,
    enemy_mastery_by_manual: Dictionary,
    enemy_candidate_id: String,
    enemy_identity: Dictionary = {}
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
        "authority": "VERTICAL_SLICE_PHASE_V_RUNTIME_LOADOUT_METRICS_AND_RESOURCE_PERSISTENCE",
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
    var enemy_state: Dictionary = (combat_state.get("enemy", {}) as Dictionary).duplicate(true)
    enemy_state["candidate_id"] = enemy_candidate_id
    var enemy_name := str(enemy_identity.get("name", ""))
    if not enemy_name.is_empty():
        enemy_state["name"] = enemy_name
    var enemy_epithet := str(enemy_identity.get("epithet", ""))
    if not enemy_epithet.is_empty():
        enemy_state["epithet"] = enemy_epithet
    combat_state["enemy"] = enemy_state
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
    set_meta("vertical_slice_run_resources_bound", true)
    return true


func apply_vertical_slice_player_resources(resources: Dictionary) -> bool:
    if not _valid_resource_pairs(resources):
        return false
    var player: Dictionary = (combat_state.get("player", {}) as Dictionary).duplicate(true)
    for key in ["health", "stamina", "internal"]:
        var pair: Array = (resources.get(key, []) as Array).duplicate()
        var maximum := maxi(0, int(pair[1]))
        var current := clampi(int(pair[0]), 0, maximum)
        player[key] = [current, maximum]
    combat_state["player"] = player
    _sync_runtime_context()
    _apply_combat_state_to_view()
    _refresh_ultimate_menu()
    _sync_action_selection_dock()
    return true


func get_vertical_slice_player_resources() -> Dictionary:
    return _player_resource_snapshot()


func get_vertical_slice_loadout_snapshot() -> Dictionary:
    return _vertical_slice_loadout_snapshot.duplicate(true)


func _show_review_panel(terminal: bool) -> void:
    super._show_review_panel(terminal)
    if not terminal:
        return
    if combat_review_panel != null:
        var continue_button := combat_review_panel.get_continue_button()
        if continue_button != null:
            continue_button.text = "결과 확인"
            continue_button.accessibility_description = "복기를 확인하고 별도 비무 결과 화면으로 이동합니다."
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
        "player_resources": _player_resource_snapshot(),
        "battle_metrics": metrics.duplicate(true),
        "review_summary": _last_review_summary.duplicate(true),
        "presentation_state": _presentation_state
    }


func _player_resource_snapshot() -> Dictionary:
    var player: Dictionary = combat_state.get("player", {})
    var result := {}
    for key in ["health", "stamina", "internal"]:
        var pair = player.get(key, [0, 0])
        if typeof(pair) == TYPE_ARRAY and pair.size() >= 2:
            result[key] = [int(pair[0]), int(pair[1])]
        elif typeof(pair) == TYPE_PACKED_INT32_ARRAY and pair.size() >= 2:
            result[key] = [int(pair[0]), int(pair[1])]
        else:
            result[key] = [0, 0]
    return result


func _valid_resource_pairs(resources: Dictionary) -> bool:
    for key in ["health", "stamina", "internal"]:
        var pair = resources.get(key, null)
        if typeof(pair) != TYPE_ARRAY or pair.size() < 2:
            return false
    return true


func _current_health(actor_key: String) -> int:
    var actor: Dictionary = combat_state.get(actor_key, {})
    var health = actor.get("health", [0, 0])
    if typeof(health) == TYPE_ARRAY and health.size() >= 1:
        return int(health[0])
    if typeof(health) == TYPE_PACKED_INT32_ARRAY and health.size() >= 1:
        return int(health[0])
    return 0
