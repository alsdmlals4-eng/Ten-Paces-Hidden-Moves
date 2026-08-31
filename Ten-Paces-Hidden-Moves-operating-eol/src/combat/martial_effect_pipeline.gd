class_name MartialEffectPipeline
extends RefCounted

const ALLOWED_OPS := [
    "GAIN_STATUS",
    "GAIN_RESOURCE",
    "CONSUME_STATUS",
    "CONSUME_ONCE_PER_BATTLE",
    "MOVE_TOWARD",
    "MOVE_AWAY",
    "RECHECK_RANGE",
    "ATTACK",
    "INDEPENDENT_ATTACK",
    "SPECIAL_CLASH",
    "BREAK_DEFENSE",
    "PUSH_TARGET",
    "REQUIRE_ACTUAL_HP_HITS",
    "REQUIRE_DEFENSE_ZERO",
    "REQUIRE_CLASH_WIN",
    "REQUIRE_EVADE_SUCCESS",
    "GAIN_MOMENTUM_ON_COMPLETE",
    "START_DEFENSE_LOSS_RECORD",
    "END_DEFENSE_LOSS_RECORD"
]

func execute(definition: Dictionary, state_value: Dictionary, actor_key: String, context_value: Dictionary = {}) -> Dictionary:
    var original_state := state_value.duplicate(true)
    var state := state_value.duplicate(true)
    var context := context_value.duplicate(true)
    var target_key := "enemy" if actor_key == "player" else "player"
    if not state.has(actor_key) or not state.has(target_key):
        return _failure(original_state, [], "MISSING_COMBATANT")

    var events: Array = []
    var runtime := _initial_runtime(state, actor_key, target_key, context)
    var pending_completion_momentum := 0
    var gate_open := true
    var steps_value = definition.get("effect_steps", [])
    if typeof(steps_value) != TYPE_ARRAY:
        return _failure(original_state, [], "INVALID_EFFECT_STEPS")
    var steps: Array = steps_value

    for index in range(steps.size()):
        var step_value = steps[index]
        if typeof(step_value) != TYPE_DICTIONARY:
            return _failure(original_state, events, "INVALID_EFFECT_STEP")
        var step: Dictionary = step_value
        var op := str(step.get("op", ""))
        if op not in ALLOWED_OPS:
            return _failure(original_state, events, "UNKNOWN_EFFECT_OP")

        if not gate_open:
            events.append(_event(op, "SKIPPED_REQUIREMENT"))
        elif not _condition_met(str(step.get("condition", "")), state, actor_key, target_key, runtime, context):
            events.append(_event(op, "SKIPPED_CONDITION"))
        else:
            var operation_result := _execute_operation(op, step, state, actor_key, target_key, runtime, context)
            var event: Dictionary = operation_result.get("event", _event(op, "APPLIED"))
            events.append(event)
            if bool(operation_result.get("requirement_failed", false)):
                gate_open = false
            pending_completion_momentum += int(operation_result.get("pending_completion_momentum", 0))
            if str(operation_result.get("failure_reason", "")) != "":
                return _failure(original_state, events, str(operation_result.get("failure_reason", "")))

        var interrupt_after_step := int(context.get("interrupt_after_step", 0))
        if interrupt_after_step > 0 and index + 1 >= interrupt_after_step:
            return {
                "state": state,
                "events": events,
                "completed": false,
                "failure_reason": "INTERRUPTED",
                "actual_hp_hits": int(runtime.get("actual_hp_hits", 0)),
                "clash_won": bool(runtime.get("clash_won", false)),
                "evade_succeeded": bool(runtime.get("evade_succeeded", false))
            }

    if pending_completion_momentum > 0:
        var actor: Dictionary = state.get(actor_key, {})
        _gain_resource(actor, "momentum", pending_completion_momentum, context)
        state[actor_key] = actor

    return {
        "state": state,
        "events": events,
        "completed": true,
        "failure_reason": "",
        "actual_hp_hits": int(runtime.get("actual_hp_hits", 0)),
        "clash_won": bool(runtime.get("clash_won", false)),
        "evade_succeeded": bool(runtime.get("evade_succeeded", false))
    }

func _initial_runtime(state: Dictionary, actor_key: String, target_key: String, context: Dictionary) -> Dictionary:
    var actor: Dictionary = state.get(actor_key, {})
    return {
        "actual_hp_hits": 0,
        "attack_attempts": 0,
        "attacks_landed": 0,
        "first_attack_hit": false,
        "second_attack_executed": false,
        "move_attempts": 0,
        "moves_succeeded": 0,
        "range_valid": true,
        "at_max_range": false,
        "clash_won": false,
        "evade_succeeded": bool(context.get("evade_succeeded", false)),
        "counter_attempted": false,
        "status_consumed": false,
        "consumed_status": "",
        "low_resource": _is_low_resource(actor),
        "low_resource_at_start": _is_low_resource(actor),
        "defense_record_start": -1,
        "actor_key": actor_key,
        "target_key": target_key
    }

func _execute_operation(op: String, step: Dictionary, state: Dictionary, actor_key: String, target_key: String, runtime: Dictionary, context: Dictionary) -> Dictionary:
    match op:
        "GAIN_STATUS":
            var actor: Dictionary = state.get(actor_key, {})
            var status := str(step.get("status", ""))
            var amount := maxi(0, int(step.get("amount", 1)))
            _gain_status(actor, status, amount)
            state[actor_key] = actor
            return {"event": _event(op, "APPLIED", {"status_name": status, "amount": amount})}
        "GAIN_RESOURCE":
            var actor: Dictionary = state.get(actor_key, {})
            var resource := str(step.get("resource", ""))
            var amount := maxi(0, int(step.get("amount", 0)))
            _gain_resource(actor, resource, amount, context)
            state[actor_key] = actor
            return {"event": _event(op, "APPLIED", {"resource": resource, "amount": amount})}
        "CONSUME_STATUS":
            var actor: Dictionary = state.get(actor_key, {})
            var status := str(step.get("status", ""))
            var consumed := _consume_status(actor, status)
            state[actor_key] = actor
            runtime["status_consumed"] = consumed
            runtime["consumed_status"] = status if consumed else ""
            if not consumed and not bool(step.get("optional", false)):
                return {"event": _event(op, "MISSING_STATUS", {"status_name": status}), "failure_reason": "MISSING_REQUIRED_STATUS"}
            return {"event": _event(op, "CONSUMED" if consumed else "OPTIONAL_MISSING", {"status_name": status})}
        "CONSUME_ONCE_PER_BATTLE":
            var actor: Dictionary = state.get(actor_key, {})
            var key := str(step.get("key", ""))
            var uses: Dictionary = actor.get("battle_uses", {})
            if uses.has(key) and not bool(uses.get(key, false)):
                return {"event": _event(op, "ALREADY_USED", {"key": key}), "failure_reason": "ALREADY_USED"}
            uses[key] = false
            actor["battle_uses"] = uses
            state[actor_key] = actor
            return {"event": _event(op, "CONSUMED", {"key": key})}
        "MOVE_TOWARD", "MOVE_AWAY":
            var move_result := _move_actor(state, actor_key, target_key, maxi(0, int(step.get("tiles", 0))), op == "MOVE_TOWARD", context)
            runtime["move_attempts"] = int(runtime.get("move_attempts", 0)) + 1
            if bool(move_result.get("moved", false)):
                runtime["moves_succeeded"] = int(runtime.get("moves_succeeded", 0)) + 1
            return {"event": _event(op, "MOVED" if bool(move_result.get("moved", false)) else "STAYED", move_result)}
        "RECHECK_RANGE":
            var distance := _distance(state, actor_key, target_key)
            var minimum := maxi(0, int(step.get("min", 0)))
            var maximum := maxi(minimum, int(step.get("max", minimum)))
            var valid := distance >= minimum and distance <= maximum
            runtime["range_valid"] = valid
            runtime["at_max_range"] = distance == maximum
            return {"event": _event(op, "IN_RANGE" if valid else "OUT_OF_RANGE", {"distance": distance, "min": minimum, "max": maximum})}
        "ATTACK", "INDEPENDENT_ATTACK":
            return {"event": _execute_attack(op, step, state, actor_key, target_key, runtime)}
        "SPECIAL_CLASH":
            return {"event": _execute_clash(step, state, actor_key, target_key, runtime, context)}
        "BREAK_DEFENSE":
            var target: Dictionary = state.get(target_key, {})
            var amount := maxi(0, int(step.get("amount", 0)))
            var before := maxi(0, int(target.get("defense", 0)))
            target["defense"] = maxi(0, before - amount)
            state[target_key] = target
            return {"event": _event(op, "APPLIED", {"amount": amount, "before": before, "after": int(target.get("defense", 0))})}
        "PUSH_TARGET":
            var push_result := _push_target(state, actor_key, target_key, maxi(0, int(step.get("tiles", 0))), context)
            return {"event": _event(op, "MOVED" if bool(push_result.get("moved", false)) else "STAYED", push_result)}
        "REQUIRE_ACTUAL_HP_HITS":
            var required := maxi(0, int(step.get("count", 1)))
            var passed := int(runtime.get("actual_hp_hits", 0)) >= required
            return {"event": _event(op, "PASSED" if passed else "FAILED", {"required": required, "actual": int(runtime.get("actual_hp_hits", 0))}), "requirement_failed": not passed}
        "REQUIRE_DEFENSE_ZERO":
            var target: Dictionary = state.get(target_key, {})
            var passed := int(target.get("defense", 0)) <= 0
            return {"event": _event(op, "PASSED" if passed else "FAILED", {"defense": int(target.get("defense", 0))}), "requirement_failed": not passed}
        "REQUIRE_CLASH_WIN":
            var passed := bool(runtime.get("clash_won", false))
            return {"event": _event(op, "PASSED" if passed else "FAILED"), "requirement_failed": not passed}
        "REQUIRE_EVADE_SUCCESS":
            var passed := bool(runtime.get("evade_succeeded", false))
            return {"event": _event(op, "PASSED" if passed else "FAILED"), "requirement_failed": not passed}
        "GAIN_MOMENTUM_ON_COMPLETE":
            var amount := maxi(0, int(step.get("amount", 0)))
            return {"event": _event(op, "QUEUED", {"amount": amount}), "pending_completion_momentum": amount}
        "START_DEFENSE_LOSS_RECORD":
            var actor: Dictionary = state.get(actor_key, {})
            runtime["defense_record_start"] = maxi(0, int(actor.get("defense", 0)))
            return {"event": _event(op, "STARTED", {"defense": int(runtime.get("defense_record_start", 0))})}
        "END_DEFENSE_LOSS_RECORD":
            var actor: Dictionary = state.get(actor_key, {})
            var start := maxi(0, int(runtime.get("defense_record_start", int(actor.get("defense", 0)))))
            var current := maxi(0, int(actor.get("defense", 0)))
            var recorded := maxi(0, int(context.get("recorded_defense_loss", start - current)))
            var cap := maxi(0, int(step.get("bonus_cap", recorded)))
            return {"event": _event(op, "ENDED", {"recorded_loss": mini(recorded, cap), "bonus_cap": cap})}
    return {"event": _event(op, "UNKNOWN"), "failure_reason": "UNKNOWN_EFFECT_OP"}

func _execute_attack(op: String, step: Dictionary, state: Dictionary, actor_key: String, target_key: String, runtime: Dictionary) -> Dictionary:
    runtime["attack_attempts"] = int(runtime.get("attack_attempts", 0)) + 1
    var attempt := int(runtime.get("attack_attempts", 0))
    if bool(step.get("counter", false)):
        runtime["counter_attempted"] = true
    var distance := _distance(state, actor_key, target_key)
    var minimum := maxi(0, int(step.get("min_range", 0)))
    var maximum := maxi(minimum, int(step.get("max_range", minimum)))
    runtime["at_max_range"] = distance == maximum
    if distance < minimum or distance > maximum:
        return _event(op, "SKIPPED_OUT_OF_RANGE", {"attempt": attempt, "distance": distance, "min": minimum, "max": maximum})

    runtime["attacks_landed"] = int(runtime.get("attacks_landed", 0)) + 1
    if attempt == 1:
        runtime["first_attack_hit"] = true
    if attempt >= 2:
        runtime["second_attack_executed"] = true
    var target: Dictionary = state.get(target_key, {})
    var raw_power := maxi(0, int(step.get("power", 0)))
    var defense := maxi(0, int(target.get("defense", 0)))
    var health_damage := maxi(0, raw_power - defense)
    if health_damage > 0:
        var health := _resource_pair(target, "health")
        _set_resource(target, "health", maxi(0, health.x - health_damage), health.y)
        runtime["actual_hp_hits"] = int(runtime.get("actual_hp_hits", 0)) + 1
    state[target_key] = target
    return _event(op, "HIT" if health_damage > 0 else "BLOCKED", {"attempt": attempt, "raw_power": raw_power, "defense": defense, "health_damage": health_damage, "distance": distance})

func _execute_clash(step: Dictionary, state: Dictionary, actor_key: String, _target_key: String, runtime: Dictionary, context: Dictionary) -> Dictionary:
    var actor: Dictionary = state.get(actor_key, {})
    var power := maxi(0, int(step.get("power", 0)))
    var stat_name := str(step.get("stat", ""))
    var stats: Dictionary = actor.get("stats", {})
    var coefficient := float(step.get("coefficient", 0.0))
    power += int(floor(float(stats.get(stat_name, 0)) * coefficient))
    var opponent := maxi(0, int(context.get("opponent_clash_power", 0)))
    var won := power > opponent
    runtime["clash_won"] = won
    runtime["at_max_range"] = _distance(state, actor_key, "enemy" if actor_key == "player" else "player") == int((step.get("max_range", -1))) if step.has("max_range") else bool(runtime.get("at_max_range", false))
    return _event("SPECIAL_CLASH", "WIN" if won else ("DRAW" if power == opponent else "LOSS"), {"power": power, "opponent_power": opponent})

func _move_actor(state: Dictionary, actor_key: String, target_key: String, tiles: int, toward: bool, context: Dictionary) -> Dictionary:
    var actor: Dictionary = state.get(actor_key, {})
    var target: Dictionary = state.get(target_key, {})
    var from_tile := int(actor.get("tile", 1))
    var target_tile := int(target.get("tile", 1))
    var direction := signi(target_tile - from_tile)
    if not toward:
        direction *= -1
    var board_size := maxi(1, int(context.get("tile_count", 10)))
    var to_tile := clampi(from_tile + direction * tiles, 1, board_size)
    actor["tile"] = to_tile
    state[actor_key] = actor
    return {"from": from_tile, "to": to_tile, "tiles": absi(to_tile - from_tile), "moved": to_tile != from_tile}

func _push_target(state: Dictionary, actor_key: String, target_key: String, tiles: int, context: Dictionary) -> Dictionary:
    var actor: Dictionary = state.get(actor_key, {})
    var target: Dictionary = state.get(target_key, {})
    var from_tile := int(target.get("tile", 1))
    var direction := signi(from_tile - int(actor.get("tile", 1)))
    var board_size := maxi(1, int(context.get("tile_count", 10)))
    var to_tile := clampi(from_tile + direction * tiles, 1, board_size)
    target["tile"] = to_tile
    state[target_key] = target
    return {"from": from_tile, "to": to_tile, "tiles": absi(to_tile - from_tile), "moved": to_tile != from_tile}

func _condition_met(condition: String, state: Dictionary, actor_key: String, target_key: String, runtime: Dictionary, context: Dictionary) -> bool:
    if condition.is_empty():
        return true
    var target: Dictionary = state.get(target_key, {})
    match condition:
        "FULL_ABSORB":
            return bool(context.get("full_absorb", false))
        "ACTUAL_HP_HIT":
            return int(runtime.get("actual_hp_hits", 0)) > 0
        "EVADE_SUCCESS":
            return bool(runtime.get("evade_succeeded", false))
        "EXACT_MAX_RANGE":
            return bool(runtime.get("at_max_range", false))
        "ACTUAL_HP_HIT_AT_MAX_RANGE":
            return int(runtime.get("actual_hp_hits", 0)) > 0 and bool(runtime.get("at_max_range", false))
        "ALL_ATTACKS_HIT":
            return int(runtime.get("attack_attempts", 0)) > 0 and int(runtime.get("attacks_landed", 0)) == int(runtime.get("attack_attempts", 0))
        "LOW_RESOURCE":
            return bool(runtime.get("low_resource", false))
        "LOW_RESOURCE_AT_START":
            return bool(runtime.get("low_resource_at_start", false))
        "ALL_MOVES_SUCCEEDED":
            return int(runtime.get("move_attempts", 0)) > 0 and int(runtime.get("moves_succeeded", 0)) == int(runtime.get("move_attempts", 0))
        "COUNTER_ATTEMPT":
            return bool(runtime.get("counter_attempted", false))
        "FIRST_ATTACK_HIT":
            return bool(runtime.get("first_attack_hit", false))
        "ANY_ATTACK_HIT":
            return int(runtime.get("attacks_landed", 0)) > 0
        "TARGET_DEFENSE_ZERO":
            return int(target.get("defense", 0)) <= 0
        "SECOND_ATTACK_EXECUTED":
            return bool(runtime.get("second_attack_executed", false))
        "STATUS_CONSUMED":
            return bool(runtime.get("status_consumed", false))
        "PREPARED_CONSUMED_BEFORE_CLASH":
            return str(runtime.get("consumed_status", "")) == "prepared"
        "CLASH_WIN":
            return bool(runtime.get("clash_won", false))
        "CLASH_WIN_AT_MAX_RANGE":
            return bool(runtime.get("clash_won", false)) and bool(runtime.get("at_max_range", false))
    return false

func _gain_status(actor: Dictionary, status: String, amount: int) -> void:
    if status.is_empty() or amount <= 0:
        return
    var counts: Dictionary = actor.get("status_counts", {})
    counts[status] = maxi(0, int(counts.get(status, 0))) + amount
    actor["status_counts"] = counts
    if status == "fortitude":
        actor["fortitude_next_attack"] = true

func _consume_status(actor: Dictionary, status: String) -> bool:
    var counts: Dictionary = actor.get("status_counts", {})
    var current := maxi(0, int(counts.get(status, 0)))
    if current <= 0:
        return false
    if current == 1:
        counts.erase(status)
    else:
        counts[status] = current - 1
    actor["status_counts"] = counts
    return true

func _gain_resource(actor: Dictionary, resource: String, amount: int, context: Dictionary) -> void:
    if amount <= 0:
        return
    if resource == "defense":
        var cap := maxi(0, int(context.get("defense_max", 10)))
        actor["defense"] = mini(cap, maxi(0, int(actor.get("defense", 0))) + amount)
        return
    var pair := _resource_pair(actor, resource)
    _set_resource(actor, resource, mini(pair.y, pair.x + amount), pair.y)

func _resource_pair(actor: Dictionary, key: String) -> Vector2i:
    var value = actor.get(key, [0, 0])
    if typeof(value) == TYPE_ARRAY and value.size() >= 2:
        return Vector2i(int(value[0]), int(value[1]))
    var scalar := maxi(0, int(value))
    return Vector2i(scalar, scalar)

func _set_resource(actor: Dictionary, key: String, current: int, maximum: int) -> void:
    actor[key] = [clampi(current, 0, maxi(0, maximum)), maxi(0, maximum)]

func _is_low_resource(actor: Dictionary) -> bool:
    var stamina := _resource_pair(actor, "stamina")
    var internal := _resource_pair(actor, "internal")
    return stamina.x * 2 <= stamina.y or internal.x * 2 <= internal.y

func _distance(state: Dictionary, actor_key: String, target_key: String) -> int:
    var actor: Dictionary = state.get(actor_key, {})
    var target: Dictionary = state.get(target_key, {})
    return absi(int(actor.get("tile", 1)) - int(target.get("tile", 1)))

func _event(op: String, status: String, extra: Dictionary = {}) -> Dictionary:
    var result := {"op": op, "status": status}
    for key in extra.keys():
        result[key] = extra[key]
    return result

func _failure(state: Dictionary, events: Array, reason: String) -> Dictionary:
    return {
        "state": state,
        "events": events,
        "completed": false,
        "failure_reason": reason,
        "actual_hp_hits": 0,
        "clash_won": false,
        "evade_succeeded": false
    }
