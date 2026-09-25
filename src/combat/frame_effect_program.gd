extends "res://src/combat/martial_effect_pipeline.gd"

# Executes the canonical operation vocabulary, retaining its program counter while
# a response awaits a real evade or the active interval's defense-loss result.
func advance(definition: Dictionary, state: Dictionary, action: Dictionary, context: Dictionary, finishing: bool = false) -> Dictionary:
    var actor_key := str(action.actor)
    var target_key := "enemy" if actor_key == "player" else "player"
    if not action.has("program"):
        for step in definition.get("effect_steps", []):
            if step.get("op") == "SPECIAL_CLASH" and not _valid_stat_reference(step, state[actor_key]):
                return {"completed": false, "failure_reason": "INVALID_STAT_REFERENCE", "events": []}
        action["program"] = {"index": 0, "runtime": _initial_runtime(state, actor_key, target_key, context), "events": [], "gate_open": true, "pending_momentum": 0, "complete": false}
    var program: Dictionary = action.program
    var runtime: Dictionary = program.runtime
    runtime["frame_context"] = context.duplicate(true)
    runtime["evade_succeeded"] = bool(runtime.get("evade_succeeded", false)) or bool(action.get("evade_succeeded", false))
    var steps: Array = definition.get("effect_steps", [])
    var emitted: Array = []
    var awaiting_contact := false
    while int(program.index) < steps.size():
        if context.has("stop_after_step") and int(program.index) >= int(context.stop_after_step): break
        var step: Dictionary = steps[int(program.index)]
        var op := str(step.get("op", ""))
        if op not in ALLOWED_OPS:
            return {"completed": false, "failure_reason": "UNKNOWN_EFFECT_OP", "events": emitted}
        if bool(context.get("pause_before_attack", false)) and op in ["ATTACK", "INDEPENDENT_ATTACK", "SPECIAL_CLASH"]:
            break
        if op == "REQUIRE_EVADE_SUCCESS" and not runtime.evade_succeeded and not finishing:
            break
        if (op == "END_DEFENSE_LOSS_RECORD" or str(step.get("condition", "")) == "FULL_ABSORB") and not finishing:
            break
        var event: Dictionary
        if not bool(program.gate_open):
            event = _event(op, "SKIPPED_REQUIREMENT")
        elif not _condition_met(str(step.get("condition", "")), state, actor_key, target_key, runtime, context):
            event = _event(op, "SKIPPED_CONDITION")
        elif op in ["ATTACK", "INDEPENDENT_ATTACK", "SPECIAL_CLASH"] and bool(context.get("attack_interval_closed", false)):
            event = _event(op, "SKIPPED_ACTIVE_EXPIRED")
        else:
            if op in ["ATTACK", "INDEPENDENT_ATTACK", "SPECIAL_CLASH"]:
                var contact := _contact_available(step, definition, state, actor_key, target_key, runtime, context)
                if not contact and bool(context.get("can_wait_for_contact", false)):
                    # Retain this operation, never replay already-applied movement,
                    # defense or resource grants when contact becomes possible.
                    awaiting_contact = true
                    break
            if op == "END_DEFENSE_LOSS_RECORD" and runtime.has("defense_loss_at_attack"):
                context["recorded_defense_loss"] = int(runtime.defense_loss_at_attack)
            var result: Dictionary = _execute_operation(op, step, state, actor_key, target_key, runtime, context)
            event = result.get("event", _event(op, "APPLIED"))
            if bool(result.get("requirement_failed", false)):
                program.gate_open = false
            program.pending_momentum = int(program.pending_momentum) + int(result.get("pending_completion_momentum", 0))
            if not str(result.get("failure_reason", "")).is_empty():
                program.index = steps.size() - 1
                program["failure_reason"] = str(result.failure_reason)
                program.gate_open = false
        program.index = int(program.index) + 1
        program.events.append(event)
        emitted.append(event)
    if finishing and not bool(program.complete):
        program.complete = true
        if str(program.get("failure_reason", "")).is_empty() and int(program.pending_momentum) > 0:
            _gain_resource(state[actor_key], "momentum", int(program.pending_momentum), context)
    return {"completed": bool(program.complete), "failure_reason": str(program.get("failure_reason", "")), "events": emitted, "awaiting_contact": awaiting_contact, "actual_hp_hits": int(runtime.actual_hp_hits), "clash_won": bool(runtime.clash_won), "evade_succeeded": bool(runtime.evade_succeeded)}

func _contact_available(step: Dictionary, definition: Dictionary, state: Dictionary, actor_key: String, target_key: String, runtime: Dictionary, context: Dictionary) -> bool:
    var reach: Dictionary = definition.get("range", {})
    var minimum := maxi(0, int(step.get("min_range", reach.get("min", 0))))
    var maximum := maxi(minimum, int(step.get("max_range", reach.get("max", minimum))))
    var distance := _distance(state, actor_key, target_key)
    runtime.range_valid = (distance == 0 or distance >= minimum) and distance <= maximum
    runtime.at_max_range = distance == maximum
    return bool(runtime.range_valid) and not bool(context.get("miss_direction", false)) and (step.get("op") != "SPECIAL_CLASH" or not bool(step.get("requires_contact", false)) or bool(context.get("clash", false)))

func _execute_operation(op: String, step: Dictionary, state: Dictionary, actor_key: String, target_key: String, runtime: Dictionary, context: Dictionary) -> Dictionary:
    if op == "GAIN_STATUS" and step.get("status") == "evade":
        runtime["frame_evade"] = true
        return {"event": _event(op, "APPLIED", {"status_name": "evade", "amount": int(step.get("amount", 1))})}
    if op == "RECHECK_RANGE" and _distance(state, actor_key, target_key) == 0:
        runtime.range_valid = true
        return {"event": _event(op, "IN_RANGE", {"distance": 0, "min": int(step.get("min", 0)), "max": int(step.get("max", 0))})}
    return super._execute_operation(op, step, state, actor_key, target_key, runtime, context)

func _execute_attack(op: String, step: Dictionary, state: Dictionary, actor_key: String, target_key: String, runtime: Dictionary) -> Dictionary:
    runtime.attack_attempts = int(runtime.attack_attempts) + 1
    var attempt := int(runtime.attack_attempts)
    if bool(step.get("counter", false)): runtime.counter_attempted = true
    var distance := _distance(state, actor_key, target_key)
    var minimum := maxi(0, int(step.get("min_range", 0)))
    var maximum := maxi(minimum, int(step.get("max_range", minimum)))
    runtime.at_max_range = distance == maximum
    var context: Dictionary = runtime.frame_context
    if (distance != 0 and distance < minimum) or distance > maximum:
        return _event(op, "SKIPPED_OUT_OF_RANGE", {"attempt": attempt, "distance": distance})
    if bool(context.get("miss_direction", false)):
        return _event(op, "SKIPPED_DIRECTION", {"attempt": attempt, "distance": distance})
    var raw := maxi(0, int(step.get("power", 0)))
    if attempt == 1:
        raw += int(context.get("attack_bonus", 0)) + int(context.get("defense_loss_bonus", 0))
        if context.has("defense_loss_bonus"): runtime["defense_loss_at_attack"] = int(context.defense_loss_bonus)
    var damage_power := raw
    var clash := bool(context.get("clash", false)) and not bool(runtime.get("clash_consumed", false))
    var clash_outcome := ""
    var clash_power := raw + int(context.get("clash_bonus", 0))
    if clash:
        var opponent_power := int(context.get("opponent_clash_power", 0))
        damage_power = maxi(0, raw - int(context.get("opponent_attack_power", opponent_power))) if clash_power > opponent_power else 0
        clash_outcome = "clash_win" if clash_power > opponent_power else ("clash_loss" if clash_power < opponent_power else "clash_draw")
        runtime.clash_won = clash_power > opponent_power
        runtime["clash_consumed"] = true
    var target: Dictionary = state[target_key]
    var defense := maxi(0, int(target.get("defense", 0))) + int(context.get("target_guard", 0))
    var after_block := maxi(0, damage_power - defense)
    var damage := after_block
    var sure_hit := bool(context.get("sure_hit", false))
    var outcome := "block" if defense > 0 else "hit"
    if bool(context.get("target_evade", false)) and not sure_hit:
        damage = 0
        outcome = "evade"
    elif bool(context.get("target_guard_active", false)):
        damage = int(floor(float(after_block) * float(context.get("guard_multiplier", 0.5))))
    if sure_hit: outcome = "sure_hit_block" if defense > 0 else "sure_hit"
    if outcome != "evade" and (not clash or clash_outcome == "clash_win"):
        runtime.attacks_landed = int(runtime.attacks_landed) + 1
        if attempt == 1: runtime.first_attack_hit = true
    if attempt >= 2: runtime.second_attack_executed = true
    if damage > 0:
        var health := _resource_pair(target, "health")
        _set_resource(target, "health", health.x - damage, health.y)
        runtime.actual_hp_hits = int(runtime.actual_hp_hits) + 1
    return _event(op, "HIT" if damage > 0 else ("EVADED" if outcome == "evade" else "BLOCKED"), {"attempt": attempt, "raw_power": raw, "power": clash_power, "defense": defense, "damage_after_block": after_block, "health_damage": damage, "distance": distance, "defense_outcome": outcome, "clash": clash, "clash_outcome": clash_outcome, "opponent_power": int(context.get("opponent_clash_power", 0)), "opponent_card_id": str(context.get("opponent_card_id", ""))})

func _execute_clash(step: Dictionary, state: Dictionary, actor_key: String, target_key: String, runtime: Dictionary, context: Dictionary) -> Dictionary:
    if not bool(runtime.get("range_valid", true)) or bool(context.get("miss_direction", false)) or (bool(step.get("requires_contact", false)) and not bool(context.get("clash", false))):
        runtime.clash_won = false
        return _event("SPECIAL_CLASH", "OUT_OF_RANGE_OR_NO_CONTACT")
    var effective_step := step.duplicate(true)
    effective_step.power = int(step.get("power", 0)) + int(context.get("clash_bonus", 0)) + int(context.get("attack_bonus", 0))
    var event := super._execute_clash(effective_step, state, actor_key, target_key, runtime, context)
    runtime["clash_consumed"] = true
    event["clash"] = bool(context.get("clash", false))
    event["clash_outcome"] = "clash_win" if event.status == "WIN" else ("clash_draw" if event.status == "DRAW" else "clash_loss")
    event["opponent_card_id"] = str(context.get("opponent_card_id", ""))
    return event

func _move_actor(state: Dictionary, actor_key: String, target_key: String, tiles: int, toward: bool, context: Dictionary) -> Dictionary:
    if toward:
        tiles = mini(tiles, _distance(state, actor_key, target_key))
    return super._move_actor(state, actor_key, target_key, tiles, toward, context)
