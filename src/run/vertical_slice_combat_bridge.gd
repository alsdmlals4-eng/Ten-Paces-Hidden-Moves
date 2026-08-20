class_name VerticalSliceCombatBridge
extends "res://src/combat/combat_board_preview_ten_manuals_auto.gd"

signal terminal_review_ready(result: Dictionary)
signal terminal_review_confirmed(result: Dictionary)

var _vertical_slice_terminal_result: Dictionary = {}


func _ready() -> void:
    super._ready()
    set_meta("vertical_slice_bridge", true)
    set_meta("bridge_scope", "TERMINAL_REVIEW_TO_RUN_RESULT")


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

    return {
        "terminal": true,
        "outcome": outcome,
        "player_health": player_health,
        "enemy_health": enemy_health,
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
