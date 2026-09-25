extends "res://src/run/vertical_slice_metrics_combat_resolution_engine.gd"

const FRAME_RULES_PATH := "res://data/combat/frame_timeline.json"
const FRAME_PROGRAM = preload("res://src/combat/frame_effect_program.gd")
const ACTORS := ["player", "enemy"]
var frame_rules: Dictionary = {}
var _frame_program = FRAME_PROGRAM.new()

func _init() -> void:
    super()
    frame_rules = _normalized_numbers(_load_json(FRAME_RULES_PATH, "frame timeline"))
    variable_opponent_rules = true

func configure(player_loadout: Array, player_mastery: Dictionary, enemy_loadout: Array, enemy_mastery: Dictionary, enemy_binding: Dictionary, constraints: Array = [], giyun: Array = []) -> bool:
    if not configure_giyun(giyun) or not configure_bimu_constraints(constraints, player_loadout, enemy_loadout): return false
    if not enemy_binding.is_empty() and not configure_enemy_runtime_binding(enemy_binding): return false
    if enemy_binding.is_empty():
        _enemy_runtime_binding.clear()
        ai_planner.clear_runtime_binding()
    clear_locked_enemy_bundle()
    return configure_martial_loadouts(player_loadout, player_mastery, enemy_loadout, get_bimu_enemy_mastery(enemy_mastery))

func get_actor_card_definition(card_id: String, actor_key: String) -> Dictionary:
    var definition := super.get_actor_card_definition(card_id, actor_key)
    if definition.is_empty() or frame_rules.is_empty(): return definition
    var timing: Dictionary = frame_rules.get("cards", {}).get(card_id, {}).duplicate(true)
    if timing.is_empty():
        var profile := "martial_response_timing_by_slots" if definition.get("category") == "response" else "martial_timing_by_slots"
        timing = frame_rules.get(profile, {}).get(str(clampi(int(definition.get("action_slots", 1)), 1, 3)), {}).duplicate(true)
    timing["total"] = int(timing.get("startup", 0)) + int(timing.get("active", 0)) + int(timing.get("recovery", 0))
    definition["frame_timing"] = timing
    if frame_rules.get("effect_text_overrides", {}).has(card_id): definition["effect_text"] = frame_rules.effect_text_overrides[card_id]
    return definition

func cards_for(actor: String) -> Array:
    var ids: Array = get_actor_cards_by_id(actor).keys()
    ids.sort()
    var result: Array = []
    for id in ids:
        var card := get_actor_card_definition(str(id), actor)
        if actor == "enemy" and bool(card.get("player_only", false)): continue
        if not card.is_empty():
            card["lock_reason"] = get_action_lock_reason(str(id)) if actor == "player" else ""
            result.append(card)
    return result

func make_initial_state(hud_data: Dictionary, player_tile: int = 4, enemy_tile: int = 6) -> Dictionary:
    var state := super.make_initial_state(hud_data, player_tile, enemy_tile)
    state["ai_enabled"] = true
    state["frame"] = {"version": 1, "window_index": 0, "time_tick": 0,
        "carry": {"player": {}, "enemy": {}}, "enemy_queue": [], "enemy_locked_until_tick": 0,
        "observation_level": 0, "reveal_from_tick": 0, "reveal_until_tick": 0, "revealed_enemy_actions": []}
    return state

func validate_plan(plan: Array, state: Dictionary, actor: String = "player") -> Dictionary:
    if actor not in ACTORS or not state.has("frame"): return _plan_failure("INVALID_STATE_OR_ACTOR")
    var frame: Dictionary = state.frame
    var carry: Dictionary = frame.get("carry", {}).get(actor, {})
    if plan.is_empty() and carry.is_empty(): return _plan_failure("EMPTY_PLAN")
    if plan.size() > 100: return _plan_failure("PLAN_TOO_LARGE")
    var normalized: Array = []
    for value in plan:
        if typeof(value) != TYPE_DICTIONARY: return _plan_failure("INVALID_PLAN_ENTRY")
        var entry: Dictionary = value
        if typeof(entry.get("card_id")) != TYPE_STRING or not _integer(entry.get("start_tick")): return _plan_failure("INVALID_PLAN_ENTRY")
        var card := get_actor_card_definition(str(entry.card_id), actor)
        if card.is_empty() or (actor == "enemy" and bool(card.get("player_only", false))): return _plan_failure("UNKNOWN_OR_UNOWNED_CARD")
        if actor == "player" and not get_action_lock_reason(str(entry.card_id)).is_empty(): return _plan_failure("BIMU_CONSTRAINT_FORBIDDEN_ACTION")
        var tick := int(entry.start_tick)
        if tick < 0 or tick >= 100: return _plan_failure("START_OUTSIDE_WINDOW")
        if not _integer(entry.get("direction", 0)) or int(entry.get("direction", 0)) not in [-1, 0, 1]: return _plan_failure("INVALID_DIRECTION")
        if not _integer(entry.get("move_steps", 1)): return _plan_failure("INVALID_MOVE_STEPS")
        var steps := int(entry.get("move_steps", 1))
        if steps < 1 or steps > maxi(1, int(card.get("move_range", 1))): return _plan_failure("INVALID_MOVE_STEPS")
        normalized.append({"card_id": str(entry.card_id), "start_tick": tick, "direction": int(entry.get("direction", 0)), "move_steps": steps})
    normalized.sort_custom(func(a, b): return int(a.start_tick) < int(b.start_tick))
    var occupied_until := maxi(0, int(carry.get("end_tick", int(frame.time_tick))) - int(frame.time_tick))
    var projected: Dictionary = state[actor].duplicate(true)
    for entry in normalized:
        if int(entry.start_tick) < occupied_until: return _plan_failure("ACTION_OVERLAP")
        var card := get_actor_card_definition(str(entry.card_id), actor)
        occupied_until = int(entry.start_tick) + int(card.frame_timing.total)
        for resource in ["stamina", "internal", "momentum"]:
            var cost := int(card.get(resource + "_cost", 0))
            var pair := _resource_pair(projected, resource)
            if pair.x < cost: return _plan_failure("RESOURCE_INSUFFICIENT")
            _set_resource(projected, resource, pair.x - cost, pair.y)
        _preview_guaranteed_restore(projected, card)
    return {"ok": true, "reason": "", "plan": normalized}

func lock_enemy_plan(state: Dictionary) -> Dictionary:
    var result: Dictionary = _normalized_numbers(state)
    if not result.has("frame"): return result
    var frame: Dictionary = result.frame
    var target := int(frame.time_tick) + int(frame_rules.get("enemy_lock_ahead_ticks", 200))
    var cursor := maxi(int(frame.time_tick), int(frame.get("enemy_locked_until_tick", 0)))
    if cursor >= target: return result
    var queue: Array = frame.enemy_queue
    for action in queue: cursor = maxi(cursor, int(action.end_tick))
    var carry: Dictionary = frame.carry.enemy
    cursor = maxi(cursor, int(carry.get("end_tick", cursor)))
    var projected := _public_ai_state(result)
    for action in queue:
        if int(action.start_tick) >= int(frame.time_tick): _preview_enemy_action(projected, action)
    while cursor < target:
        projected.ai_decision_seed = int(result.get("ai_decision_seed", 0)) + cursor * 7919
        projected.round_number = int(cursor / 100) + 1
        var candidates: Array = ai_planner.build_bundle_actions(projected, 3, get_actor_cards_by_id("enemy"))
        var chosen: Dictionary = candidates[0] if not candidates.is_empty() else {"card_id": "basic_meditate"}
        var id := str(chosen.get("card_id", "basic_meditate"))
        var card := get_actor_card_definition(id, "enemy")
        if card.is_empty() or bool(card.get("player_only", false)) or not _can_pay(projected.enemy, card):
            id = "basic_meditate"
            card = get_actor_card_definition(id, "enemy")
        var action := _schedule({"card_id": id, "start_tick": cursor, "direction": int(chosen.get("direction", 0)), "move_steps": maxi(1, int(card.get("move_range", 1)))}, "enemy", 0)
        queue.append(action)
        _preview_enemy_action(projected, action)
        cursor = int(action.end_tick)
    frame.enemy_queue = queue
    frame.enemy_locked_until_tick = cursor
    return result

func public_enemy_plan(state: Dictionary) -> Array:
    if not state.has("frame"): return []
    var result: Array = []
    var now := int(state.frame.time_tick)
    for value in state.frame.get("revealed_enemy_actions", []):
        var record: Dictionary = value
        if int(record.absolute_end_tick) <= now: continue
        # These are clipped display intervals, not executable scheduled actions.
        var public := record.duplicate(true)
        public.start_tick = int(public.absolute_start_tick) - now
        public.active_tick = int(public.absolute_active_tick) - now
        public.end_tick = int(public.absolute_end_tick) - now
        result.append(public)
    return result

func resolve_window(state: Dictionary, plan: Array) -> Dictionary:
    var state_check := validate_state(state)
    if not state_check.ok: return _resolution_failure(state, str(state_check.reason))
    if _terminal(state): return _resolution_failure(state, "BATTLE_ALREADY_TERMINAL")
    var checked := validate_plan(plan, state)
    if not checked.ok: return _resolution_failure(state, str(checked.reason))
    var current := lock_enemy_plan(state)
    var frame: Dictionary = current.frame
    var start := int(frame.time_tick)
    var stop := start + 100
    var window_index := int(frame.window_index)
    var actions: Array = []
    var seen := {}
    for actor in ACTORS:
        var carry: Dictionary = frame.carry[actor]
        if not carry.is_empty():
            actions.append(carry.duplicate(true))
            seen[str(carry.uid)] = true
    for value in checked.plan: actions.append(_schedule(value, "player", start))
    for action in frame.enemy_queue:
        if int(action.start_tick) < stop and int(action.end_tick) > start and not seen.has(str(action.uid)):
            actions.append(action.duplicate(true))
    actions.sort_custom(func(a, b): return int(a.start_tick) < int(b.start_tick) if int(a.start_tick) != int(b.start_tick) else str(a.actor) < str(b.actor))
    var events: Array = []
    var samples: Array = []
    var records: Array = []
    var logs: Array[String] = []
    var actual_end := stop
    for tick in range(start, stop):
        var before := _actors_snapshot(current)
        _complete_at(current, actions, tick, start, events, records)
        for action in actions:
            if int(action.start_tick) == tick:
                var cost_before := _actors_snapshot(current)
                var card := get_actor_card_definition(str(action.card_id), str(action.actor))
                if not _can_pay(current[str(action.actor)], card):
                    action.cancelled = true
                    action["failure_reason"] = "resource_insufficient"
                else:
                    _charge(current[str(action.actor)], card)
                    action.cost_paid = true
                    _consume_prepare(current, action, card)
                var record := _frame_record(action, tick, "startup" if action.cost_paid else "resource_insufficient")
                record.action_stage = "startup"
                _emit(events, records, current, cost_before, action, tick, start, "action_start", record)
                var prefix_count := int(frame_rules.get("startup_effect_prefix_by_card", {}).get(str(action.card_id), 0))
                if bool(action.cost_paid) and prefix_count > 0:
                    var prefix_before := _actors_snapshot(current)
                    var prefix_context := _program_context(current, action, [], tick)
                    prefix_context["stop_after_step"] = prefix_count
                    var prefix_result: Dictionary = _frame_program.advance(card, current, action, prefix_context)
                    action["startup_effect_applied"] = true
                    action["fortitude"] = bool(action.get("fortitude", false)) or bool(current[str(action.actor)].get("fortitude_next_attack", false))
                    current[str(action.actor)].fortitude_next_attack = false
                    current[str(action.actor)].get("status_counts", {}).erase("fortitude")
                    _emit_program(events, records, current, prefix_before, action, prefix_result, tick, start)
        var active: Array = _active_actions(actions, tick)
        _activate_actions(current, active, tick, start, events, records)
        _resolve_active_programs(current, active, tick, start, events, records)
        _interrupt_after_tick(current, actions, before, tick, start, events, records)
        samples.append({"tick": tick, "window_tick": tick - start, "before": before, "after": _actors_snapshot(current), "actions": _phase_records(actions, tick)})
        if _terminal(current):
            actual_end = tick + 1
            break
    if not _terminal(current): _complete_at(current, actions, actual_end, start, events, records)
    var terminal := _terminal(current)
    frame.time_tick = actual_end
    frame.window_index = window_index + 1
    frame.carry = {"player": {}, "enemy": {}}
    for action in actions:
        if int(action.end_tick) > actual_end and int(action.start_tick) < actual_end and not terminal:
            frame.carry[str(action.actor)] = action.duplicate(true)
    var future: Array = []
    for action in frame.enemy_queue:
        if int(action.start_tick) >= actual_end: future.append(action.duplicate(true))
    frame.enemy_queue = future if not terminal else []
    current["round_number"] = window_index + 2
    current["bundle_index"] = 1
    if terminal: current["outcome"] = battle_outcome(current)
    _append_public_resolution_history(current, records, window_index + 1, 1)
    var boundary_before := _actors_snapshot(current)
    if not terminal:
        for actor in ACTORS: _grant_momentum(current, actor, int(frame_rules.get("window_momentum_gain", 1)), logs, "[10초 완료]")
    var compatibility := {"state": current, "resolved_actions": records, "logs": logs, "round_number": window_index + 1}
    _giyun_rules.apply_bundle(giyun_ids, state, compatibility)
    current.battle_metrics = battle_metrics.accumulate(current.get("battle_metrics", {}), state, compatibility)
    if boundary_before != _actors_snapshot(current):
        events.append({"tick": actual_end, "window_tick": actual_end - start, "type": "window_end", "actor": "", "card_id": "", "outcome": "resources", "before": boundary_before, "after": _actors_snapshot(current), "actions": [], "text": "10초 판정 완료"})
    for event in events:
        if not str(event.text).is_empty(): logs.append(str(event.text))
    var review := {"window_index": window_index, "start_tick": start, "end_tick": actual_end, "events": events, "actions": records, "logs": logs, "outcome": str(current.get("outcome", "ongoing"))}
    return {"ok": true, "reason": "", "state": current, "events": events, "samples": samples, "review": review, "terminal": terminal}

func _activate_actions(state: Dictionary, active: Array, tick: int, start: int, events: Array, records: Array) -> void:
    var movement: Array = []
    for action in active:
        if bool(action.effect_applied): continue
        var card := get_actor_card_definition(str(action.card_id), str(action.actor))
        var before := _actors_snapshot(state)
        action.effect_applied = true
        if card.get("category") == "move":
            movement.append(action)
            continue
        if bool(card.get("dash_before_attack", false)): _move_one(state, action, 1)
        if card.get("source") == "martial_manual":
            var context := _program_context(state, action, active, tick)
            context["pause_before_attack"] = true
            var result: Dictionary = _frame_program.advance(card, state, action, context)
            _emit_program(events, records, state, before, action, result, tick, start)
        elif card.get("category") == "attack":
            pass
        elif str(card.id) in ["basic_guard", "basic_evade", "basic_observe"]:
            _emit(events, records, state, before, action, tick, start, "action_active", _frame_record(action, tick, "active"))
        else:
            var unused_logs: Array[String] = []
            _execute_utility(state, {"actor": action.actor, "definition": card}, unused_logs, tick)
            if card.id == "basic_stance": state[str(action.actor)]["prepare_active"] = true
            if card.id == "basic_meditate" and bool(action.get("prepared", false)):
                _grant_momentum(state, str(action.actor), int(rules.get("prepare_meditate_momentum", 1)), unused_logs, "준비 명상")
            _emit(events, records, state, before, action, tick, start, "action_active", _frame_record(action, tick, "executed"))
    if movement.is_empty(): return
    var before := _actors_snapshot(state)
    var proposals := {}
    for action in movement:
        var actor := str(action.actor)
        var target := _other_actor(actor)
        var from := int(state[actor].tile)
        var direction := int(action.direction)
        if direction == 0: direction = signi(int(state[target].tile) - from)
        var to := clampi(from + direction * int(action.move_steps), 1, 10)
        if (from < int(state[target].tile) and to > int(state[target].tile)) or (from > int(state[target].tile) and to < int(state[target].tile)): to = int(state[target].tile)
        proposals[actor] = to
    if proposals.size() == 2 and proposals.player == state.enemy.tile and proposals.enemy == state.player.tile:
        proposals.player = state.player.tile
        proposals.enemy = state.enemy.tile
    for action in movement: state[str(action.actor)].tile = proposals[str(action.actor)]
    for action in movement: _emit(events, records, state, before, action, tick, start, "move", _frame_record(action, tick, "move"))

func _resolve_active_programs(state: Dictionary, active: Array, tick: int, start: int, events: Array, records: Array) -> void:
    var contexts := {}
    for action in active: contexts[str(action.uid)] = _program_context(state, action, active, tick)
    for action in active:
        if bool(action.get("attack_resolved", false)): continue
        var card := get_actor_card_definition(str(action.card_id), str(action.actor))
        if card.get("source") != "martial_manual" and card.get("category") != "attack": continue
        if card.get("source") == "martial_manual" and not _program_waits_for_attack(action, card): continue
        var before := _actors_snapshot(state)
        var result: Dictionary = _frame_program.advance(_attack_program_card(card, state[str(action.actor)]), state, action, contexts[str(action.uid)])
        action["attack_resolved"] = not bool(result.get("awaiting_contact", false))
        _register_defense_results(state, active, action, result)
        _emit_program(events, records, state, before, action, result, tick, start)
    for action in active:
        if not bool(action.get("evade_succeeded", false)): continue
        var card := get_actor_card_definition(str(action.card_id), str(action.actor))
        if card.get("source") != "martial_manual" or not _program_waits_for_attack(action, card): continue
        var before := _actors_snapshot(state)
        var context := _program_context(state, action, active, tick)
        context.clash = false
        var result: Dictionary = _frame_program.advance(card, state, action, context)
        action["attack_resolved"] = not bool(result.get("awaiting_contact", false))
        _register_defense_results(state, active, action, result)
        _emit_program(events, records, state, before, action, result, tick, start)

func _register_defense_results(state: Dictionary, active: Array, action: Dictionary, result: Dictionary) -> void:
    var target := _other_actor(str(action.actor))
    var logs: Array[String] = []
    for event in result.get("events", []):
        if bool(event.get("clash", false)) and str(event.get("clash_outcome", "")) in ["clash_draw", "clash_loss"]: continue
        var outcome := str(event.get("defense_outcome", ""))
        if outcome == "evade": _grant_momentum(state, target, _momentum_award_amount("evade"), logs, "회피")
        elif outcome in ["block", "sure_hit_block"] and int(event.get("raw_power", 0)) > int(event.get("health_damage", 0)):
            _grant_momentum(state, target, _momentum_award_amount("guard"), logs, "막기")
        if str(event.get("clash_outcome", "")) == "clash_win" and bool(event.get("clash", false)):
            _grant_momentum(state, str(action.actor), _momentum_award_amount("clash_win"), logs, "합 승리")
        for defense in active:
            if str(defense.actor) != target: continue
            if outcome == "evade": defense["evade_succeeded"] = true
            if outcome in ["block", "sure_hit_block"] and int(event.get("health_damage", 0)) == 0: defense["full_absorb"] = true

func _program_context(state: Dictionary, action: Dictionary, active: Array, tick: int) -> Dictionary:
    var actor := str(action.actor)
    var target := _other_actor(actor)
    var card := get_actor_card_definition(str(action.card_id), actor)
    var target_guard := 0
    var target_evade := false
    var guard_active := false
    var opponent_power := 0
    var opponent_attack_power := 0
    var opponent_card_id := ""
    var clash := false
    for other in active:
        if str(other.actor) != target: continue
        var defense_card := get_actor_card_definition(str(other.card_id), target)
        if defense_card.id == "basic_guard":
            guard_active = true
            target_guard = int(rules.get("guard_block", 4))
            if bool(other.get("prepared", false)): target_guard = int(ceil(float(target_guard) * float(rules.get("stance_response_defense_multiplier", 1.5))))
        if defense_card.id == "basic_evade" or bool(other.get("program", {}).get("runtime", {}).get("frame_evade", false)): target_evade = true
        if not bool(other.get("attack_resolved", false)) and _program_waits_for_attack(other, defense_card):
            opponent_power = _first_attack_power(state, other, defense_card)
            opponent_attack_power = _first_attack_raw_power(state, other, defense_card)
            opponent_card_id = str(other.card_id)
            clash = opponent_power > 0 and _first_attack_power(state, action, card) > 0 and (str(card.get("category")) == "attack" or _contact_required(action, card)) and (str(defense_card.get("category")) == "attack" or _contact_required(other, defense_card))
    var direction := int(action.direction)
    var relative := signi(int(state[target].tile) - int(state[actor].tile))
    var active_end := int(action.active_tick) + int(card.frame_timing.active)
    return {"tile_count": 10, "timing": tick, "target_guard": target_guard, "target_guard_active": guard_active,
        "can_wait_for_contact": tick + 1 < active_end, "attack_interval_closed": tick >= active_end,
        "guard_multiplier": float(rules.get("guard_same_timing_damage_multiplier", 0.5)), "target_evade": target_evade,
        "opponent_clash_power": opponent_power, "opponent_attack_power": opponent_attack_power, "opponent_card_id": opponent_card_id, "clash": clash, "clash_bonus": int(state[actor].get("status_counts", {}).get("clash_power_bonus", 0)), "sure_hit": "필중" in card.get("tags", []),
        "miss_direction": direction != 0 and relative != 0 and direction != relative,
        "attack_bonus": int(action.get("attack_bonus", 0)), "defense_loss_bonus": _defense_loss_bonus(state, action, card), "evade_succeeded": bool(action.get("evade_succeeded", false)), "full_absorb": bool(action.get("full_absorb", false))}

func _defense_loss_bonus(state: Dictionary, action: Dictionary, card: Dictionary) -> int:
    if str(card.id) not in frame_rules.get("defense_loss_bonus_cards", []): return 0
    var recorded := int(action.get("program", {}).get("runtime", {}).get("defense_record_start", -1))
    if recorded < 0: return 0
    for step in card.get("effect_steps", []):
        if step.get("op") == "END_DEFENSE_LOSS_RECORD":
            return mini(int(step.get("bonus_cap", 0)), maxi(0, recorded - int(state[str(action.actor)].get("defense", 0))))
    return 0

func _first_attack_power(state: Dictionary, action: Dictionary, card: Dictionary) -> int:
    var raw := _first_attack_raw_power(state, action, card)
    # The canonical overlay specifies a clash bonus, not raw attack damage.
    # Its owner defines no expiry; retain the original status lifetime.
    return raw + int(state[str(action.actor)].get("status_counts", {}).get("clash_power_bonus", 0)) if raw > 0 else 0

func _first_attack_raw_power(state: Dictionary, action: Dictionary, card: Dictionary) -> int:
    var actor: Dictionary = state[str(action.actor)]
    var target: Dictionary = state[_other_actor(str(action.actor))]
    var distance := absi(int(actor.tile) - int(target.tile))
    var direction := int(action.direction)
    if direction != 0 and signi(int(target.tile) - int(actor.tile)) not in [0, direction]: return 0
    if card.get("source") != "martial_manual":
        if card.get("category") != "attack": return 0
        var reach := _attack_range(card)
        if distance > reach.y or (distance != 0 and distance < reach.x): return 0
        return _calculate_attack_damage(card, actor) + int(action.get("attack_bonus", 0))
    var steps: Array = card.get("effect_steps", [])
    var index := int(action.get("program", {}).get("index", 0))
    for i in range(index, steps.size()):
        var step: Dictionary = steps[i]
        var op := str(step.get("op", ""))
        if op not in ["ATTACK", "INDEPENDENT_ATTACK", "SPECIAL_CLASH"]: continue
        var reach: Dictionary = card.get("range", {})
        var min_range := int(step.get("min_range", reach.get("min", 0)))
        var max_range := int(step.get("max_range", reach.get("max", 0)))
        if distance > max_range or (distance != 0 and distance < min_range): return 0
        var power := int(step.get("power", 0))
        if op == "SPECIAL_CLASH" and not str(step.get("stat", "")).is_empty():
            var stat_key := str(_frame_program.STAT_KEYS.get(str(step.stat), ""))
            power += int(floor(float(actor.get("stats", {}).get(stat_key, 0)) * float(step.get("coefficient", 0))))
        var first_attempt := int(action.get("program", {}).get("runtime", {}).get("attack_attempts", 0)) == 0
        return power + (int(action.get("attack_bonus", 0)) + _defense_loss_bonus(state, action, card) if first_attempt else 0)
    return 0

func _program_waits_for_attack(action: Dictionary, card: Dictionary) -> bool:
    if bool(action.get("attack_resolved", false)): return false
    if card.get("source") != "martial_manual": return card.get("category") == "attack"
    var steps: Array = card.get("effect_steps", [])
    var index := int(action.get("program", {}).get("index", 0))
    if index >= steps.size(): return false
    var op := str(steps[index].get("op", ""))
    return op in ["ATTACK", "INDEPENDENT_ATTACK", "SPECIAL_CLASH"] or (op == "REQUIRE_EVADE_SUCCESS" and bool(action.get("evade_succeeded", false)))

func _attack_program_card(card: Dictionary, actor: Dictionary) -> Dictionary:
    if card.get("source") == "martial_manual": return card
    var reach := _attack_range(card)
    return {"effect_steps": [{"op": "ATTACK", "power": _calculate_attack_damage(card, actor), "min_range": reach.x, "max_range": reach.y}]}

func _contact_required(action: Dictionary, card: Dictionary) -> bool:
    var steps: Array = card.get("effect_steps", [])
    var index := int(action.get("program", {}).get("index", 0))
    return index < steps.size() and steps[index].get("op") == "SPECIAL_CLASH" and bool(steps[index].get("requires_contact", false))

func _complete_at(state: Dictionary, actions: Array, tick: int, start: int, events: Array, records: Array) -> void:
    for action in actions:
        if int(action.end_tick) != tick or bool(action.get("completed", false)): continue
        action["completed"] = true
        if bool(action.cancelled) or not bool(action.cost_paid): continue
        var before := _actors_snapshot(state)
        var card := get_actor_card_definition(str(action.card_id), str(action.actor))
        if action.has("program"):
            var context := _program_context(state, action, [], tick)
            var program_card := _attack_program_card(card, state[str(action.actor)]) if card.get("category") == "attack" else card
            var result: Dictionary = _frame_program.advance(program_card, state, action, context, true)
            _emit_program(events, records, state, before, action, result, tick, start)
        var observation := int(card.get("observation_points", 0))
        if str(action.actor) == "player":
            var counts: Dictionary = state.player.get("status_counts", {})
            observation += int(counts.get("observation", 0))
            counts.erase("observation")
            state.player["status_counts"] = counts
            if observation > 0: _observe_completed(state, tick, observation)
        _emit(events, records, state, before, action, tick, start, "action_complete", _frame_record(action, tick, "complete"))
        if observation > 0 and str(action.actor) == "player":
            var event: Dictionary = events.back()
            var public_state := state.duplicate(true)
            public_state.frame.time_tick = tick
            event["public_enemy_actions"] = public_enemy_plan(public_state)
            event["observation_level"] = int(state.frame.observation_level)
            event["reveal_until_tick"] = int(state.frame.reveal_until_tick)

func _observe_completed(state: Dictionary, tick: int, points: int) -> void:
    var frame: Dictionary = state.frame
    frame.observation_level = mini(int(frame_rules.observation_max_level), int(frame.observation_level) + points)
    frame.reveal_from_tick = tick
    frame.reveal_until_tick = tick + int(frame.observation_level) * int(frame_rules.observation_ticks_per_level)
    var revealed: Array = frame.revealed_enemy_actions
    var ids := {}
    for i in range(revealed.size()): ids[str(revealed[i].uid)] = i
    var observable: Array = frame.enemy_queue.duplicate(true)
    if not frame.carry.enemy.is_empty(): observable.append(frame.carry.enemy)
    for action in observable:
        if int(action.end_tick) <= tick or int(action.start_tick) >= int(frame.reveal_until_tick): continue
        var card := get_actor_card_definition(str(action.card_id), "enemy")
        var previous: Dictionary = revealed[int(ids[str(action.uid)])] if ids.has(str(action.uid)) else {}
        var record := _revealed_action(action, card, tick, int(frame.observation_level), previous)
        if previous.is_empty():
            ids[str(action.uid)] = revealed.size()
            revealed.append(record)
        else:
            revealed[int(ids[str(action.uid)])] = record
    frame.revealed_enemy_actions = revealed

func _revealed_action(action: Dictionary, card: Dictionary, tick: int, level: int, previous: Dictionary = {}) -> Dictionary:
    var first_reveal := int(previous.get("first_revealed_at_tick", tick))
    var horizon := tick + level * int(frame_rules.observation_ticks_per_level)
    var begin := maxi(int(action.start_tick), first_reveal)
    var end := mini(int(action.end_tick), horizon)
    var active := clampi(int(action.active_tick), begin, end)
    var recovery := clampi(int(action.active_tick) + int(action.frame_timing.active), begin, end)
    # Canonical timing remains in the private queue. Every public timing field
    # below is a display boundary intersected with actual observed knowledge.
    var record := {"uid": str(action.uid), "card_id": str(action.card_id), "name": str(card.get("name", "")), "category": str(card.get("category", "")),
        "frame_timing": {"startup": active - begin, "active": recovery - active, "recovery": end - recovery, "total": end - begin},
        "direction": int(action.direction), "move_steps": int(action.move_steps), "known_start_tick": int(action.start_tick),
        "absolute_start_tick": begin, "absolute_active_tick": active, "absolute_end_tick": end,
        "visible_from_tick": begin, "visible_until_tick": end, "view_only": true,
        "clipped_start": begin > int(action.start_tick), "clipped_end": end < int(action.end_tick),
        "first_revealed_at_tick": first_reveal, "revealed_at_tick": tick, "observation_level": level}
    if int(action.active_tick) < horizon: record["actual_active_tick"] = int(action.active_tick)
    if int(action.end_tick) <= horizon: record["actual_end_tick"] = int(action.end_tick)
    return record

func _interrupt_after_tick(state: Dictionary, actions: Array, before: Dictionary, tick: int, start: int, events: Array, records: Array) -> void:
    for actor in ACTORS:
        if int(state[actor].health[0]) >= int(before[actor].health[0]): continue
        var defeated := int(state[actor].health[0]) <= 0
        for action in actions:
            if str(action.actor) != actor or bool(action.cancelled): continue
            if not defeated and (int(action.start_tick) > tick or int(action.active_tick) <= tick): continue
            if defeated and int(action.end_tick) <= tick: continue
            var card := get_actor_card_definition(str(action.card_id), actor)
            if not defeated and bool(action.get("fortitude", false)) and card.get("category") == "attack":
                action.fortitude = false
                _emit(events, records, state, _actors_snapshot(state), action, tick, start, "fortitude", _frame_record(action, tick, "fortitude"))
                continue
            action.cancelled = true
            action["failure_reason"] = "defeat" if defeated else "startup_damage"
            _emit(events, records, state, _actors_snapshot(state), action, tick, start, "interruption", _frame_record(action, tick, "interrupted"))

func _consume_prepare(state: Dictionary, action: Dictionary, card: Dictionary) -> void:
    var actor: Dictionary = state[str(action.actor)]
    if card.get("category") == "move" or card.id == "basic_stance": return
    var prepared := bool(actor.get("prepare_active", false))
    action["prepared"] = prepared
    if card.get("category") == "attack":
        action["fortitude"] = bool(actor.get("fortitude_next_attack", false))
        actor.fortitude_next_attack = false
        var counts: Dictionary = actor.get("status_counts", {})
        counts.erase("fortitude")
        actor["status_counts"] = counts
        action["attack_bonus"] = int(actor.get("next_attack_bonus", 0))
        if card.get("source") == "basic":
            action.attack_bonus += int(actor.get("giyun_attack_bonus", 0))
            actor["giyun_attack_bonus"] = 0
        actor.next_attack_bonus = 0
    elif prepared:
        actor.next_attack_bonus = 0
        actor.fortitude_next_attack = false
    actor.prepare_active = false

func _move_one(state: Dictionary, action: Dictionary, steps: int) -> void:
    var actor := str(action.actor)
    var target := _other_actor(actor)
    var direction := int(action.direction)
    if direction == 0: direction = signi(int(state[target].tile) - int(state[actor].tile))
    var distance := absi(int(state[target].tile) - int(state[actor].tile))
    if direction == signi(int(state[target].tile) - int(state[actor].tile)): steps = mini(steps, distance)
    state[actor].tile = clampi(int(state[actor].tile) + direction * steps, 1, 10)

func _schedule(entry: Dictionary, actor: String, offset: int) -> Dictionary:
    var card := get_actor_card_definition(str(entry.card_id), actor)
    var timing: Dictionary = card.frame_timing
    var start := offset + int(entry.start_tick)
    return {"uid": "%s:%d:%s" % [actor, start, str(entry.card_id)], "actor": actor, "card_id": str(entry.card_id), "start_tick": start, "active_tick": start + int(timing.startup), "end_tick": start + int(timing.total), "frame_timing": timing.duplicate(true), "direction": int(entry.get("direction", 0)), "move_steps": int(entry.get("move_steps", 1)), "cost_paid": false, "effect_applied": false, "cancelled": false}

func _active_actions(actions: Array, tick: int) -> Array:
    var result: Array = []
    for action in actions:
        if not bool(action.cancelled) and bool(action.cost_paid) and tick >= int(action.active_tick) and tick < int(action.active_tick) + int(action.frame_timing.active): result.append(action)
    return result

func _phase_records(actions: Array, tick: int) -> Array:
    var result: Array = []
    for action in actions:
        if tick < int(action.start_tick) or tick >= int(action.end_tick): continue
        var phase := "startup" if tick < int(action.active_tick) else ("active" if tick < int(action.active_tick) + int(action.frame_timing.active) else "recovery")
        result.append({"uid": str(action.uid), "actor": str(action.actor), "card_id": str(action.card_id), "phase": "interrupted" if bool(action.cancelled) else phase, "start_tick": int(action.start_tick), "active_tick": int(action.active_tick), "end_tick": int(action.end_tick)})
    return result

func _frame_record(action: Dictionary, tick: int, outcome: String) -> Dictionary:
    var card := get_actor_card_definition(str(action.card_id), str(action.actor))
    var record := _resolved_record({"actor": action.actor, "definition": card, "direction": action.direction}, tick, outcome)
    record["tick"] = tick
    record["uid"] = str(action.uid)
    record["start_tick"] = int(action.start_tick)
    record["active_tick"] = int(action.active_tick)
    record["end_tick"] = int(action.end_tick)
    record["frame_timing"] = action.frame_timing.duplicate(true)
    return record

func _emit_program(events: Array, records: Array, state: Dictionary, before: Dictionary, action: Dictionary, result: Dictionary, tick: int, start: int) -> void:
    var operations: Array = result.get("events", [])
    if operations.is_empty(): return
    var record := _frame_record(action, tick, "martial_completed" if result.get("failure_reason", "") == "" else "martial_failed")
    record["martial_events"] = operations.duplicate(true)
    record["failure_reason"] = str(result.get("failure_reason", ""))
    record["target"] = _other_actor(str(action.actor))
    record["damage"] = maxi(0, int(before[str(record.target)].health[0]) - int(state[str(record.target)].health[0]))
    record["actual_hp_hits"] = 0
    record["evade_succeeded"] = bool(result.get("evade_succeeded", false))
    record["clash_won"] = false
    for operation in operations:
        if int(operation.get("health_damage", 0)) > 0: record.actual_hp_hits += 1
        if operation.has("raw_power"): record["raw_damage"] = int(operation.raw_power)
        if operation.has("defense_outcome"): record["defense_outcome"] = str(operation.defense_outcome)
        if operation.has("damage_after_block"): record["damage_after_block"] = int(operation.damage_after_block)
        if bool(operation.get("clash", false)):
            record.outcome = str(operation.clash_outcome)
            record.clash_won = record.outcome == "clash_win"
            record["motion_cue"] = "clash"
            record["clash_power"] = int(operation.get("power", operation.get("raw_power", 0)))
            record["opponent_clash_power"] = int(operation.get("opponent_power", 0))
            record["opponent_card_id"] = str(operation.get("opponent_card_id", ""))
        if operation.get("status") == "SKIPPED_OUT_OF_RANGE": record.outcome = "miss_range"
        if operation.get("status") == "SKIPPED_DIRECTION": record.outcome = "miss_direction"
    _emit(events, records, state, before, action, tick, start, "action_effect", record)

func _emit(events: Array, records: Array, state: Dictionary, before: Dictionary, action: Dictionary, tick: int, start: int, type: String, record: Dictionary) -> void:
    if type == "action_complete":
        record.action_stage = "completion"
    elif type == "action_effect" and tick < int(action.active_tick):
        record.action_stage = "preparation"
    elif type not in ["action_start", "interruption", "fortitude"]:
        record.action_stage = "effect" if bool(action.get("execution_recorded", false)) else "execution"
        action["execution_recorded"] = true
    var outcome := str(record.get("outcome", ""))
    var text := "%s · %s" % [str(record.get("card_name", action.card_id)), str(frame_rules.get("outcome_labels", {}).get(outcome, "실행"))]
    if int(record.get("damage", 0)) > 0: text += " · 피해 %d" % int(record.damage)
    records.append(record)
    events.append({"tick": tick, "window_tick": tick - start, "type": type, "actor": str(action.actor), "card_id": str(action.card_id), "outcome": str(record.outcome), "before": before, "after": _actors_snapshot(state), "actions": [record], "text": text})

func _actors_snapshot(state: Dictionary) -> Dictionary:
    return {"player": state.player.duplicate(true), "enemy": state.enemy.duplicate(true)}

func _public_ai_state(state: Dictionary) -> Dictionary:
    var result := {"round_number": int(state.get("round_number", 1)), "bundle_index": 3, "ai_decision_seed": int(state.get("ai_decision_seed", 0)), "public_resolution_history": state.get("public_resolution_history", []).duplicate(true)}
    for actor in ACTORS:
        var public := {}
        for key in ["tile", "health", "stamina", "internal", "momentum", "stats", "attack_power", "defense", "statuses"]:
            if state[actor].has(key): public[key] = state[actor][key].duplicate(true) if typeof(state[actor][key]) in [TYPE_ARRAY, TYPE_DICTIONARY] else state[actor][key]
        result[actor] = public
    return result

func _preview_enemy_action(projected: Dictionary, action: Dictionary) -> void:
    var card := get_actor_card_definition(str(action.card_id), "enemy")
    if not _can_pay(projected.enemy, card): return
    _charge(projected.enemy, card)
    _preview_guaranteed_restore(projected.enemy, card)
    if card.get("category") == "move": _move_one(projected, action, int(action.move_steps))

func _preview_guaranteed_restore(actor: Dictionary, card: Dictionary) -> void:
    var restore: Dictionary = card.get("restore", {})
    for key in restore:
        var pair := _resource_pair(actor, str(key))
        _set_resource(actor, str(key), pair.x + int(restore[key]), pair.y)
    for step in card.get("effect_steps", []):
        if step.get("op") == "GAIN_RESOURCE" and str(step.get("condition", "")).is_empty() and str(step.get("resource", "")) in ["stamina", "internal"]:
            var key := str(step.resource)
            var pair := _resource_pair(actor, key)
            _set_resource(actor, key, pair.x + int(step.get("amount", 0)), pair.y)

func _can_pay(actor: Dictionary, card: Dictionary) -> bool:
    for key in ["stamina", "internal", "momentum"]:
        if _resource_pair(actor, key).x < int(card.get(key + "_cost", 0)): return false
    return true

func _charge(actor: Dictionary, card: Dictionary) -> void:
    for key in ["stamina", "internal", "momentum"]:
        var pair := _resource_pair(actor, key)
        _set_resource(actor, key, pair.x - int(card.get(key + "_cost", 0)), pair.y)

func _terminal(state: Dictionary) -> bool:
    return int(state.player.health[0]) <= 0 or int(state.enemy.health[0]) <= 0

func _integer(value) -> bool:
    return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and float(value) == floor(float(value))

func _normalized_numbers(value):
    if typeof(value) == TYPE_FLOAT and _integer(value): return int(value)
    if typeof(value) == TYPE_ARRAY:
        var result: Array = []
        for item in value: result.append(_normalized_numbers(item))
        return result
    if typeof(value) == TYPE_DICTIONARY:
        var result := {}
        for key in value: result[key] = _normalized_numbers(value[key])
        return result
    return value

func _plan_failure(reason: String) -> Dictionary:
    return {"ok": false, "reason": reason, "plan": []}

func _resolution_failure(state: Dictionary, reason: String) -> Dictionary:
    return {"ok": false, "reason": reason, "state": state.duplicate(true), "events": [], "samples": [], "review": {}, "terminal": false}

func validate_state(state: Dictionary) -> Dictionary:
    for actor in ACTORS:
        if typeof(state.get(actor)) != TYPE_DICTIONARY: return {"ok": false, "reason": "MISSING_ACTOR"}
        for resource in ["health", "stamina", "internal", "momentum"]:
            var pair = state[actor].get(resource)
            if typeof(pair) != TYPE_ARRAY or pair.size() != 2: return {"ok": false, "reason": "INVALID_RESOURCE"}
            if not _integer(pair[0]) or not _integer(pair[1]) or int(pair[0]) < 0 or int(pair[0]) > int(pair[1]) or int(pair[1]) > 100000: return {"ok": false, "reason": "INVALID_RESOURCE"}
        if not _integer(state[actor].get("tile")) or int(state[actor].tile) < 1 or int(state[actor].tile) > 10: return {"ok": false, "reason": "INVALID_TILE"}
        if typeof(state[actor].get("stats")) != TYPE_DICTIONARY: return {"ok": false, "reason": "INVALID_STATS"}
        for stat in ["external", "constitution", "agility", "internal_power", "insight"]:
            if not _integer(state[actor].stats.get(stat)) or int(state[actor].stats[stat]) < 0 or int(state[actor].stats[stat]) > 100000: return {"ok": false, "reason": "INVALID_STATS"}
        for amount in ["defense", "next_attack_bonus", "giyun_attack_bonus", "attack_power"]:
            if state[actor].has(amount) and (not _integer(state[actor][amount]) or int(state[actor][amount]) < 0 or int(state[actor][amount]) > 100000): return {"ok": false, "reason": "INVALID_ACTOR_AMOUNT"}
    if typeof(state.get("frame")) != TYPE_DICTIONARY: return {"ok": false, "reason": "MISSING_FRAME"}
    var frame: Dictionary = state.frame
    for key in ["version", "window_index", "time_tick", "enemy_locked_until_tick", "observation_level", "reveal_from_tick", "reveal_until_tick"]:
        if not _integer(frame.get(key)) or int(frame[key]) < 0 or int(frame[key]) > 100000000: return {"ok": false, "reason": "INVALID_FRAME_TICK"}
    if int(frame.version) != 1 or int(frame.observation_level) > 3 or int(frame.reveal_until_tick) - int(frame.reveal_from_tick) != int(frame.observation_level) * 30: return {"ok": false, "reason": "INVALID_FRAME_RULES"}
    if not _terminal(state) and int(frame.time_tick) != int(frame.window_index) * 100: return {"ok": false, "reason": "INVALID_WINDOW_BOUNDARY"}
    if typeof(frame.get("carry")) != TYPE_DICTIONARY or typeof(frame.get("enemy_queue")) != TYPE_ARRAY or typeof(frame.get("revealed_enemy_actions")) != TYPE_ARRAY: return {"ok": false, "reason": "INVALID_FRAME_COLLECTION"}
    if frame.enemy_queue.size() > 100 or frame.revealed_enemy_actions.size() > 10000: return {"ok": false, "reason": "FRAME_COLLECTION_TOO_LARGE"}
    for actor in ACTORS:
        var carry = frame.carry.get(actor)
        if typeof(carry) != TYPE_DICTIONARY: return {"ok": false, "reason": "INVALID_CARRY"}
        if not carry.is_empty():
            if not _valid_action(carry, actor) or int(carry.start_tick) >= int(frame.time_tick) or int(carry.end_tick) <= int(frame.time_tick): return {"ok": false, "reason": "INVALID_CARRY"}
            if not bool(carry.cost_paid) and not bool(carry.cancelled): return {"ok": false, "reason": "INVALID_CARRY_COST"}
            if not bool(carry.cancelled) and bool(carry.effect_applied) != (int(carry.active_tick) < int(frame.time_tick)): return {"ok": false, "reason": "INVALID_CARRY_PHASE"}
    var occupied := int(frame.carry.enemy.get("end_tick", frame.time_tick))
    for action in frame.enemy_queue:
        if typeof(action) != TYPE_DICTIONARY or not _valid_action(action, "enemy") or int(action.start_tick) < occupied: return {"ok": false, "reason": "INVALID_ENEMY_QUEUE"}
        if bool(action.cost_paid) or bool(action.effect_applied) or bool(action.cancelled) or action.has("program"): return {"ok": false, "reason": "INVALID_ENEMY_QUEUE_FLAGS"}
        occupied = int(action.end_tick)
    for item in frame.revealed_enemy_actions:
        if typeof(item) != TYPE_DICTIONARY or typeof(item.get("card_id")) != TYPE_STRING or get_actor_card_definition(str(item.card_id), "enemy").is_empty(): return {"ok": false, "reason": "INVALID_REVEAL"}
        for key in ["known_start_tick", "first_revealed_at_tick", "absolute_start_tick", "absolute_active_tick", "absolute_end_tick", "revealed_at_tick", "observation_level", "direction", "move_steps"]:
            if key == "direction":
                if not _integer(item.get(key)) or int(item[key]) not in [-1, 0, 1]: return {"ok": false, "reason": "INVALID_REVEAL"}
                continue
            if not _integer(item.get(key)) or int(item[key]) < 0: return {"ok": false, "reason": "INVALID_REVEAL"}
        var card := get_actor_card_definition(str(item.card_id), "enemy")
        if int(item.observation_level) < 1 or int(item.observation_level) > int(frame.observation_level) or int(item.revealed_at_tick) > int(frame.time_tick): return {"ok": false, "reason": "INVALID_REVEAL"}
        if int(item.first_revealed_at_tick) > int(item.revealed_at_tick) or int(item.known_start_tick) >= int(item.revealed_at_tick) + int(item.observation_level) * 30 or int(item.absolute_end_tick) <= int(item.absolute_start_tick): return {"ok": false, "reason": "INVALID_REVEAL"}
        if int(item.move_steps) < 1 or int(item.move_steps) > maxi(1, int(card.get("move_range", 1))): return {"ok": false, "reason": "INVALID_REVEAL"}
        var action := _schedule({"card_id": str(item.card_id), "start_tick": int(item.known_start_tick), "direction": int(item.direction), "move_steps": int(item.move_steps)}, "enemy", 0)
        if _normalized_numbers(item) != _revealed_action(action, card, int(item.revealed_at_tick), int(item.observation_level), item): return {"ok": false, "reason": "INVALID_REVEAL_TIMING"}
    return {"ok": true, "reason": ""}

func _valid_action(action: Dictionary, actor: String) -> bool:
    if str(action.get("actor", "")) != actor or typeof(action.get("card_id")) != TYPE_STRING: return false
    var card := get_actor_card_definition(str(action.card_id), actor)
    if card.is_empty(): return false
    for key in ["start_tick", "active_tick", "end_tick", "direction", "move_steps"]:
        if not _integer(action.get(key)): return false
    if int(action.start_tick) < 0 or int(action.active_tick) != int(action.start_tick) + int(card.frame_timing.startup) or int(action.end_tick) != int(action.start_tick) + int(card.frame_timing.total): return false
    if _normalized_numbers(action.get("frame_timing")) != card.frame_timing or str(action.get("uid", "")) != "%s:%d:%s" % [actor, int(action.start_tick), str(action.card_id)]: return false
    for key in ["cost_paid", "effect_applied", "cancelled"]:
        if typeof(action.get(key)) != TYPE_BOOL: return false
    if int(action.direction) not in [-1, 0, 1] or int(action.move_steps) < 1 or int(action.move_steps) > maxi(1, int(card.get("move_range", 1))): return false
    if bool(action.effect_applied) and not bool(action.cost_paid): return false
    for flag in ["attack_resolved", "completed", "execution_recorded", "evade_succeeded", "full_absorb", "prepared", "fortitude", "startup_effect_applied"]:
        if action.has(flag) and typeof(action[flag]) != TYPE_BOOL: return false
    if action.has("attack_bonus") and (not _integer(action.attack_bonus) or int(action.attack_bonus) < 0 or int(action.attack_bonus) > 100000): return false
    if action.has("program") and not _valid_program(action, card): return false
    return true

func _valid_program(action: Dictionary, card: Dictionary) -> bool:
    if (not bool(action.effect_applied) and not bool(action.get("startup_effect_applied", false))) or typeof(action.program) != TYPE_DICTIONARY: return false
    var program: Dictionary = action.program
    var count := (card.get("effect_steps", []) as Array).size() if card.get("source") == "martial_manual" else 1
    if not _integer(program.get("index")) or int(program.index) < 0 or int(program.index) > count: return false
    if typeof(program.get("runtime")) != TYPE_DICTIONARY or typeof(program.get("events")) != TYPE_ARRAY or program.events.size() > count: return false
    for flag in ["gate_open", "complete"]:
        if typeof(program.get(flag)) != TYPE_BOOL: return false
    if not _integer(program.get("pending_momentum")) or int(program.pending_momentum) < 0 or int(program.pending_momentum) > 100: return false
    for key in ["actual_hp_hits", "attack_attempts", "attacks_landed", "move_attempts", "moves_succeeded"]:
        if not _integer(program.runtime.get(key)) or int(program.runtime[key]) < 0 or int(program.runtime[key]) > count: return false
    for key in ["first_attack_hit", "second_attack_executed", "range_valid", "at_max_range", "clash_won", "evade_succeeded", "counter_attempted", "status_consumed", "low_resource", "low_resource_at_start"]:
        if typeof(program.runtime.get(key)) != TYPE_BOOL: return false
    if str(program.runtime.get("actor_key", "")) != str(action.actor) or str(program.runtime.get("target_key", "")) != _other_actor(str(action.actor)): return false
    return _safe_program_value(program, 0)

func _safe_program_value(value, depth: int) -> bool:
    if depth > 8: return false
    if typeof(value) in [TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING]: return true
    if typeof(value) == TYPE_FLOAT: return is_finite(value)
    if typeof(value) == TYPE_ARRAY:
        if value.size() > 100: return false
        for child in value:
            if not _safe_program_value(child, depth + 1): return false
        return true
    if typeof(value) == TYPE_DICTIONARY:
        if value.size() > 100: return false
        for key in value:
            if typeof(key) != TYPE_STRING or not _safe_program_value(value[key], depth + 1): return false
        return true
    return false
