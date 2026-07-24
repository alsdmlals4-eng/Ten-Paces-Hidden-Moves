extends SceneTree

const BUILDER_SCRIPT := preload("res://src/combat/combat_review_summary_builder.gd")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var builder := BUILDER_SCRIPT.new() as CombatReviewSummaryBuilder
    _verify_cause(builder, "clash", [_event("clash_win"), _event("miss_range")])
    _verify_cause(builder, "interrupted", [_event("interrupted"), _event("block", "block")])
    _verify_cause(builder, "defense", [_event("general", "evade")])
    _verify_cause(builder, "defense", [_event("general", "sure_hit")])
    _verify_cause(builder, "direction", [_event("miss_direction")])
    _verify_cause(builder, "range", [_event("miss_range")])
    _verify_cause(builder, "resource", [_event("resource_insufficient")])

    var position_result := _result([], 5, 6)
    var position_summary := builder.build_summary(position_result, _plan(), _hypothesis("approach"), _state_before())
    _expect(str(position_summary.get("cause_code", "")) == "position", "Position change must produce position cause.")
    _expect(int(position_summary.get("distance_before", -1)) == 3, "Distance before must be three.")
    _expect(int(position_summary.get("distance_after", -1)) == 1, "Distance after must be one.")

    var order_result := _result([], 4, 7)
    var order_summary := builder.build_summary(order_result, _plan(), _hypothesis("none"), _state_before())
    _expect(str(order_summary.get("cause_code", "")) == "order", "Empty unchanged result must fall back to order.")
    _expect(not bool((order_summary.get("hypothesis", {}) as Dictionary).get("recorded", true)), "None hypothesis must remain unrecorded.")
    _expect(str(order_summary.get("opponent_actual", "")) == "행동 정보 없음", "Missing opponent action must not be invented.")

    var result_input := _result([_enemy_event("basic_quick_attack", "속공", "clash_loss")], 4, 7)
    var plan_input := _plan()
    var hypothesis_input := _hypothesis("quick_attack")
    var state_input := _state_before()
    var result_copy := result_input.duplicate(true)
    var plan_copy := plan_input.duplicate(true)
    var hypothesis_copy := hypothesis_input.duplicate(true)
    var state_copy := state_input.duplicate(true)
    var summary := builder.build_summary(result_input, plan_input, hypothesis_input, state_input)
    _expect(result_input == result_copy, "Summary builder mutated result input.")
    _expect(plan_input == plan_copy, "Summary builder mutated player plan input.")
    _expect(hypothesis_input == hypothesis_copy, "Summary builder mutated hypothesis input.")
    _expect(state_input == state_copy, "Summary builder mutated state input.")
    _expect(str(summary.get("opponent_actual", "")) == "속공", "Enemy actual action must use authoritative event name.")
    _expect(int(summary.get("player_plan_count", -1)) == 1, "Player plan snapshot count changed.")
    _expect(str(summary.get("review_dimension", "")).length() > 0, "Review dimension must be readable.")

    if failures.is_empty():
        print("COMBAT_REVIEW_SUMMARY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _verify_cause(builder: CombatReviewSummaryBuilder, expected: String, events: Array) -> void:
    var summary := builder.build_summary(_result(events, 4, 7), _plan(), _hypothesis("heavy_prepare"), _state_before())
    _expect(str(summary.get("cause_code", "")) == expected, "Expected cause %s, got %s." % [expected, str(summary.get("cause_code", ""))])

func _event(outcome: String, defense_outcome: String = "") -> Dictionary:
    return {
        "type": "clash" if outcome.begins_with("clash_") else "action_result",
        "timing": 2,
        "actor": "player",
        "card_id": "basic_heavy_attack",
        "card_name": "강공",
        "outcome": outcome,
        "defense_outcome": defense_outcome
    }

func _enemy_event(card_id: String, card_name: String, outcome: String) -> Dictionary:
    var value := _event(outcome)
    value["actor"] = "enemy"
    value["card_id"] = card_id
    value["card_name"] = card_name
    return value

func _result(events: Array, player_tile: int, enemy_tile: int) -> Dictionary:
    return {
        "presentation_events": events.duplicate(true),
        "state": {
            "player": {"tile": player_tile},
            "enemy": {"tile": enemy_tile}
        }
    }

func _plan() -> Array:
    return [{"card_id": "basic_guard", "anchor_index": 1, "span": 1}]

func _hypothesis(id_value: String) -> Dictionary:
    return {
        "id": id_value,
        "label": "기록한 가설 없음" if id_value == "none" else id_value,
        "recorded": id_value != "none"
    }

func _state_before() -> Dictionary:
    return {
        "player": {"tile": 4},
        "enemy": {"tile": 7}
    }

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
