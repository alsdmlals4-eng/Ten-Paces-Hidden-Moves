class_name VerticalSliceBattleMetrics
extends RefCounted

const METRIC_KEYS := [
    "successful_dodges",
    "clash_wins",
    "player_health_lost",
    "rounds_elapsed",
    "ultimate_uses"
]


func make_initial_metrics() -> Dictionary:
    return {
        "successful_dodges": 0,
        "clash_wins": 0,
        "player_health_lost": 0,
        "rounds_elapsed": 0,
        "ultimate_uses": 0
    }


func normalize(value: Dictionary) -> Dictionary:
    var result := make_initial_metrics()
    for key in METRIC_KEYS:
        result[key] = maxi(0, int(value.get(key, 0)))
    return result


func accumulate(current_value: Dictionary, state_before: Dictionary, result_value: Dictionary) -> Dictionary:
    var next := normalize(current_value)
    var state_after: Dictionary = result_value.get("state", {})
    next["player_health_lost"] = int(next["player_health_lost"]) + maxi(
        0,
        _current_health(state_before, "player") - _current_health(state_after, "player")
    )
    next["rounds_elapsed"] = maxi(int(next["rounds_elapsed"]), int(result_value.get("round_number", 0)))

    for value in result_value.get("resolved_actions", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var action: Dictionary = value
        var actor := str(action.get("actor", ""))
        var outcome := str(action.get("outcome", ""))
        var defense_outcome := str(action.get("defense_outcome", ""))

        if actor == "player" and (outcome == "clash_win" or bool(action.get("clash_won", false))):
            next["clash_wins"] = int(next["clash_wins"]) + 1

        if actor == "enemy" and defense_outcome == "evade":
            if not outcome.begins_with("clash_") or outcome == "clash_win":
                next["successful_dodges"] = int(next["successful_dodges"]) + 1

        if actor == "player" and _is_executed_ultimate(action):
            next["ultimate_uses"] = int(next["ultimate_uses"]) + 1

    return next


func _is_executed_ultimate(action: Dictionary) -> bool:
    if str(action.get("action_stage", "execution")) != "execution":
        return false
    var outcome := str(action.get("outcome", ""))
    if outcome in ["interrupted", "resource_insufficient", "insufficient", "martial_failed"]:
        return false
    var card_id := str(action.get("card_id", ""))
    return card_id.begins_with("ultimate_") or card_id.ends_with("_star10")


func _current_health(state: Dictionary, actor_key: String) -> int:
    var actor: Dictionary = state.get(actor_key, {})
    var health = actor.get("health", [0, 0])
    if (typeof(health) == TYPE_ARRAY or typeof(health) == TYPE_PACKED_INT32_ARRAY) and health.size() >= 1:
        return int(health[0])
    return 0
