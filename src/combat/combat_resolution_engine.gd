class_name CombatResolutionEngine
extends RefCounted

const RULES_PATH := "res://data/combat/combat_resolution_preview.json"
const CARDS_PATH := "res://data/cards/basic_cards.json"
const ULTIMATES_PATH := "res://data/cards/ultimate_cards.json"
const CombatAiPlannerScript := preload("res://src/combat/combat_ai_planner.gd")

var rules: Dictionary = {}
var cards_by_id: Dictionary = {}
var ai_planner: CombatAiPlanner

func _init() -> void:
    ai_planner = CombatAiPlannerScript.new()
    rules = _load_json(RULES_PATH, "STEP 10 resolution rules")
    var card_data := _load_json(CARDS_PATH, "basic cards")
    var cards: Array = card_data.get("cards", [])
    for value in cards:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var definition: Dictionary = value
        cards_by_id[str(definition.get("id", ""))] = definition.duplicate(true)
    var ultimate_data := _load_json(ULTIMATES_PATH, "ultimate cards")
    for value in ultimate_data.get("cards", []):
        if typeof(value) == TYPE_DICTIONARY:
            var ultimate: Dictionary = value
            cards_by_id[str(ultimate.get("id", ""))] = ultimate.duplicate(true)

func _load_json(path: String, label: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_error("%s file was not found: %s" % [label, path])
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("%s file could not be opened: %s" % [label, path])
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("%s root must be a Dictionary." % label)
        return {}
    return parsed

func make_initial_state(hud_data: Dictionary, player_tile: int, enemy_tile: int) -> Dictionary:
    var player := _prepare_combatant_start(hud_data.get("player", {}))
    var enemy := _prepare_combatant_start(hud_data.get("enemy", {}))
    player["tile"] = player_tile
    enemy["tile"] = enemy_tile
    player["next_attack_bonus"] = 0
    enemy["next_attack_bonus"] = 0
    return {
        "round_number": int((hud_data.get("round", {}) as Dictionary).get("round_number", 1)),
        "bundle_index": int((hud_data.get("round", {}) as Dictionary).get("bundle_index", 1)),
        "player": player,
        "enemy": enemy,
        "ai_decision_seed": 0
    }

func _prepare_combatant_start(source_value) -> Dictionary:
    var actor: Dictionary = {}
    if typeof(source_value) == TYPE_DICTIONARY:
        actor = (source_value as Dictionary).duplicate(true)
    var penalties: Dictionary = {}
    if typeof(actor.get("start_penalties", {})) == TYPE_DICTIONARY:
        penalties = actor.get("start_penalties", {})
    for resource_key in ["health", "stamina", "internal"]:
        var pair := _resource_pair(actor, resource_key)
        var penalty := maxi(0, int(penalties.get(resource_key, 0)))
        _set_resource(actor, resource_key, maxi(0, pair.y - penalty), pair.y)
    return actor

func preview_player_plan(state_value: Dictionary, placements: Array) -> Dictionary:
    var state := state_value.duplicate(true)
    var actor: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
    var actions := _build_player_actions(placements)
    actions.sort_custom(_sort_actions_by_timing)
    var invalid_anchors := PackedInt32Array()
    var resource_events: Array = []
    for action in actions:
        var definition: Dictionary = action.get("definition", {})
        var timing := int(action.get("execution_timing", action.get("anchor_index", 0)))
        var anchor := int(action.get("anchor_index", 0))
        var stamina_cost := maxi(0, int(definition.get("stamina_cost", 0)))
        var internal_cost := maxi(0, int(definition.get("internal_cost", 0)))
        var stamina := _resource_pair(actor, "stamina")
        var internal := _resource_pair(actor, "internal")
        if stamina.x < stamina_cost or internal.x < internal_cost:
            invalid_anchors.append(anchor)
            resource_events.append({
                "timing": timing,
                "anchor_index": anchor,
                "card_name": str(definition.get("name", "행동")),
                "status": "insufficient"
            })
            continue
        _set_resource(actor, "stamina", stamina.x - stamina_cost, stamina.y)
        _set_resource(actor, "internal", internal.x - internal_cost, internal.y)
        if _base_card_id(definition) == "basic_meditate":
            var stamina_after := _resource_pair(actor, "stamina")
            var internal_after := _resource_pair(actor, "internal")
            _set_resource(actor, "stamina", mini(stamina_after.y, stamina_after.x + int(rules.get("meditate_stamina_restore", 2))), stamina_after.y)
            _set_resource(actor, "internal", mini(internal_after.y, internal_after.x + int(rules.get("meditate_internal_restore", 1))), internal_after.y)
        resource_events.append({
            "timing": timing,
            "anchor_index": anchor,
            "card_name": str(definition.get("name", "행동")),
            "status": "applied"
        })
    state["player"] = actor
    return {
        "valid": invalid_anchors.is_empty(),
        "state": state,
        "invalid_anchors": invalid_anchors,
        "events": resource_events
    }

func _sort_actions_by_timing(a: Dictionary, b: Dictionary) -> bool:
    return int(a.get("execution_timing", 0)) < int(b.get("execution_timing", 0))

func resolve_bundle(player_placements: Array, context: Dictionary, state_value: Dictionary) -> Dictionary:
    var state := state_value.duplicate(true)
    var state_before_resolution := state.duplicate(true)
    var logs: Array[String] = []
    var resolved_actions: Array = []
    var timing_results: Array = []
    var round_number := int(context.get("round_number", state.get("round_number", 1)))
    var bundle_index := int(context.get("bundle_index", state.get("bundle_index", 1)))
    var sequence: Array = context.get("timing_sequence", [3, 3, 4])
    var bounds := _bundle_bounds(bundle_index, sequence)
    var bundle_start := bounds.x
    var bundle_end := bounds.y

    state["round_number"] = round_number
    state["bundle_index"] = bundle_index
    logs.append("[%d라운드 %d묶음 판정]" % [round_number, bundle_index])
    logs.append("판정 순서: %s" % str(rules.get("resolution_order_label", "대응 → 속공 → 이동 → 일반 공격")))

    var actions := _build_player_actions(player_placements)
    actions.append_array(_build_enemy_actions(bundle_index, state))
    var state_before_response := state.duplicate(true)
    var response_action_start := resolved_actions.size()
    var response_log_start := logs.size()
    var defenses := _prepare_bundle_defenses(state, actions, logs, resolved_actions)
    var response_actions: Array = []
    var response_logs: Array[String] = []
    for index in range(response_action_start, resolved_actions.size()):
        response_actions.append(resolved_actions[index])
    for index in range(response_log_start, logs.size()):
        response_logs.append(logs[index])
    if not response_actions.is_empty():
        timing_results.append({
            "timing": 0,
            "phase": "response",
            "state": state.duplicate(true),
            "events": _build_presentation_events(state_before_response, state, response_actions, response_logs, false)
        })

    for timing in range(bundle_start, bundle_end + 1):
        var state_before_timing := state.duplicate(true)
        var action_start := resolved_actions.size()
        var log_start := logs.size()
        var timing_actions := _actions_for_timing(actions, timing)
        if timing_actions.is_empty():
            logs.append("[%d수] 양측 모두 행동하지 않았다." % timing)
            continue

        var deferred_attacks: Array = []
        var quick_actions := _filter_phase(timing_actions, "quick_attack")
        _execute_attack_phase(state, quick_actions, defenses, logs, timing, "속공", resolved_actions, actions, deferred_attacks)

        var move_actions := _filter_phase(timing_actions, "move")
        _execute_move_phase(state, move_actions, logs, timing, resolved_actions)

        var general_actions := _filter_phase(timing_actions, "general")
        var normal_attacks: Array = []
        var utility_actions: Array = []
        for action in general_actions:
            var definition: Dictionary = action.get("definition", {})
            if str(definition.get("category", "")) == "attack":
                normal_attacks.append(action)
            else:
                utility_actions.append(action)
        _execute_attack_phase(state, normal_attacks, defenses, logs, timing, "일반 공격", resolved_actions, actions, deferred_attacks)
        _resolve_timing_attacks(state, deferred_attacks, defenses, logs, timing, actions)
        for action in utility_actions:
            if bool(action.get("cancelled", false)):
                resolved_actions.append(_resolved_record(action, timing, "interrupted"))
                continue
            if not _pay_action_cost(state, action, logs, timing):
                continue
            action["executed"] = true
            _execute_utility(state, action, logs, timing)
            resolved_actions.append(_resolved_record(action, timing, "general"))

        var timing_resolved_actions: Array = []
        var timing_logs: Array[String] = []
        for index in range(action_start, resolved_actions.size()):
            timing_resolved_actions.append(resolved_actions[index])
        for index in range(log_start, logs.size()):
            timing_logs.append(logs[index])
        timing_results.append({
            "timing": timing,
            "phase": "timing",
            "state": state.duplicate(true),
            "events": _build_presentation_events(state_before_timing, state, timing_resolved_actions, timing_logs, false)
        })

    _award_bundle_momentum(state, logs)
    var result := {
        "state": state,
        "logs": logs,
        "resolved_actions": resolved_actions,
        "round_number": round_number,
        "bundle_index": bundle_index,
        "bundle_start": bundle_start,
        "bundle_end": bundle_end,
        "resolution_order": rules.get("resolution_order", ["response", "quick_attack", "move", "general"]),
        "defenses": defenses,
        "timing_results": timing_results
    }
    result["presentation_events"] = _build_presentation_events(state_before_resolution, state, resolved_actions, logs)
    return result

func _bundle_bounds(bundle_index: int, sequence: Array) -> Vector2i:
    var start := 1
    for index in range(maxi(0, bundle_index - 1)):
        if index < sequence.size():
            start += int(sequence[index])
    var count := int(sequence[bundle_index - 1]) if bundle_index >= 1 and bundle_index <= sequence.size() else 1
    return Vector2i(start, start + count - 1)

func _build_player_actions(placements: Array) -> Array:
    var result: Array = []
    for value in placements:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var placement: Dictionary = value
        var definition: Dictionary = (placement.get("definition", {}) as Dictionary).duplicate(true)
        if definition.is_empty():
            var card_id := str(placement.get("card_id", ""))
            definition = (cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
        if definition.is_empty():
            continue
        var anchor := int(placement.get("anchor_index", 1))
        var span := maxi(1, int(placement.get("span", definition.get("action_slots", 1))))
        result.append({
            "actor": "player",
            "anchor_index": anchor,
            "span": span,
            "execution_timing": anchor + span - 1,
            "definition": definition,
            "targeting_mode": str(placement.get("targeting_mode", "none")),
            "target_ready": bool(placement.get("target_ready", true)),
            "target_tile": int(placement.get("target_tile", 0)),
            "direction": int(placement.get("direction", 0)),
            "origin_tile": int(placement.get("origin_tile", 0))
        })
    return result

func _build_enemy_actions(bundle_index: int, state: Dictionary = {}) -> Array:
    var result: Array = []
    var bundles: Dictionary = rules.get("enemy_bundles", {})
    var plan: Array = bundles.get(str(bundle_index), [])
    if plan.is_empty() and bool(state.get("ai_enabled", false)) and str(rules.get("enemy_plan_source", "fixture")) == "public_state_ai" and ai_planner != null:
        plan = ai_planner.build_bundle_actions(state, bundle_index, cards_by_id)
    for value in plan:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var entry: Dictionary = value
        var card_id := str(entry.get("card_id", ""))
        var definition: Dictionary = (cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
        if definition.is_empty():
            continue
        var anchor := int(entry.get("timing", 1))
        var span := maxi(1, int(definition.get("action_slots", 1)))
        if str(definition.get("source", "")) == "ultimate":
            var enemy: Dictionary = state.get("enemy", {})
            var momentum := _resource_pair(enemy, "momentum")
            if momentum.x != momentum.y:
                continue
            _set_resource(enemy, "momentum", 0, momentum.y)
            state["enemy"] = enemy
        result.append({
            "actor": "enemy",
            "anchor_index": anchor,
            "span": span,
            "execution_timing": anchor + span - 1,
            "definition": definition,
            "targeting_mode": str(entry.get("targeting_mode", "none")),
            "target_ready": true,
            "target_tile": int(entry.get("target_tile", 0)),
            "direction": clampi(int(entry.get("direction", -1)), -1, 1),
            "origin_tile": 0,
            "ai_reason": str(entry.get("ai_reason", "fixture")),
            "ai_seed": int(entry.get("ai_seed", state.get("ai_decision_seed", 0)))
        })
    return result

func _actions_for_timing(actions: Array, timing: int) -> Array:
    var result: Array = []
    for action in actions:
        if int(action.get("execution_timing", 0)) == timing:
            result.append(action)
    return result

func _filter_phase(actions: Array, phase: String) -> Array:
    var result: Array = []
    for action in actions:
        if _phase_for_definition(action.get("definition", {})) == phase:
            result.append(action)
    return result

func _phase_for_definition(definition_value) -> String:
    if typeof(definition_value) != TYPE_DICTIONARY:
        return "general"
    var definition: Dictionary = definition_value
    var category := str(definition.get("category", ""))
    var explicit_phase := str(definition.get("resolution_phase", ""))
    if explicit_phase in ["quick_attack", "move", "general"]:
        return explicit_phase
    var tags: Array = definition.get("tags", [])
    if category == "response":
        return "response"
    if category == "attack" and "속공" in tags:
        return "quick_attack"
    if category == "move":
        return "move"
    return "general"

func _prepare_bundle_defenses(state: Dictionary, actions: Array, logs: Array[String], resolved_actions: Array) -> Dictionary:
    var profiles := {
        "player": _empty_defense_profile(),
        "enemy": _empty_defense_profile()
    }
    for action in actions:
        var definition: Dictionary = action.get("definition", {})
        if str(definition.get("category", "")) != "response":
            continue
        var timing := int(action.get("execution_timing", 0))
        if not _pay_action_cost(state, action, logs, timing):
            continue
        var actor_key := str(action.get("actor", "player"))
        var actor: Dictionary = state.get(actor_key, {})
        var profile: Dictionary = (profiles.get(actor_key, _empty_defense_profile()) as Dictionary).duplicate(true)
        var card_id := _base_card_id(definition)
        var stance_combo := bool(definition.get("stance_response_combo", false))
        if card_id == "basic_evade":
            if stance_combo:
                profile["evade_bundle"] = true
                logs.append("[%d수 · 대응 강화] %s이(가) 태세와 회피를 결합해 현재 묶음 전체를 완전 회피한다." % [timing, _actor_name(actor)])
            else:
                var evade_timings: PackedInt32Array = profile.get("evade_timings", PackedInt32Array())
                if timing not in evade_timings:
                    evade_timings.append(timing)
                profile["evade_timings"] = evade_timings
                logs.append("[%d수 · 대응] %s이(가) 같은 수의 공격을 완전 회피한다." % [timing, _actor_name(actor)])
        else:
            var block := maxi(0, int(rules.get("guard_block", 4)))
            if stance_combo:
                block = int(ceil(float(block) * float(rules.get("stance_response_defense_multiplier", 1.5))))
                profile["guard_bundle_enhanced"] = true
                logs.append("[%d수 · 대응 강화] %s이(가) 태세와 막기를 결합해 현재 묶음 전체에 방어도 %d를 적용한다." % [timing, _actor_name(actor), block])
            else:
                logs.append("[%d수 · 대응] %s이(가) 현재 묶음에 방어도 %d를 준비했다." % [timing, _actor_name(actor), block])
            profile["guard_block"] = maxi(int(profile.get("guard_block", 0)), block)
            var guard_timings: PackedInt32Array = profile.get("guard_timings", PackedInt32Array())
            if timing not in guard_timings:
                guard_timings.append(timing)
            profile["guard_timings"] = guard_timings
        profiles[actor_key] = profile
        resolved_actions.append(_resolved_record(action, timing, "response_combo" if stance_combo else "response"))
    return profiles

func _empty_defense_profile() -> Dictionary:
    return {
        "guard_block": 0,
        "guard_timings": PackedInt32Array(),
        "guard_bundle_enhanced": false,
        "evade_timings": PackedInt32Array(),
        "evade_bundle": false
    }

func _pay_action_cost(state: Dictionary, action: Dictionary, logs: Array[String], timing: int) -> bool:
    var actor_key := str(action.get("actor", "player"))
    var actor: Dictionary = state.get(actor_key, {})
    var definition: Dictionary = action.get("definition", {})
    var stamina_cost := maxi(0, int(definition.get("stamina_cost", 0)))
    var internal_cost := maxi(0, int(definition.get("internal_cost", 0)))
    var stamina := _resource_pair(actor, "stamina")
    var internal := _resource_pair(actor, "internal")
    if stamina.x < stamina_cost or internal.x < internal_cost:
        logs.append("[%d수] %s은(는) 자원이 부족해 %s을(를) 실행하지 못했다." % [timing, _actor_name(actor), str(definition.get("name", "행동"))])
        return false
    _set_resource(actor, "stamina", stamina.x - stamina_cost, stamina.y)
    _set_resource(actor, "internal", internal.x - internal_cost, internal.y)
    state[actor_key] = actor
    return true

func _execute_attack_phase(state: Dictionary, actions: Array, _defenses: Dictionary, logs: Array[String], timing: int, phase_label: String, resolved_actions: Array, _all_actions: Array, deferred_attacks: Array = []) -> void:
    if actions.is_empty():
        return
    for action in actions:
        if bool(action.get("cancelled", false)):
            resolved_actions.append(_resolved_record(action, timing, "interrupted"))
            continue
        if not _pay_action_cost(state, action, logs, timing):
            continue
        action["executed"] = true
        var actor_key := str(action.get("actor", "player"))
        var target_key := _other_actor(actor_key)
        var actor: Dictionary = state.get(actor_key, {})
        var target: Dictionary = state.get(target_key, {})
        var definition: Dictionary = action.get("definition", {})
        var actor_tile := int(actor.get("tile", 1))
        var target_tile := int(target.get("tile", 1))
        var relative_direction := signi(target_tile - actor_tile)
        var selected_direction := clampi(int(action.get("direction", 0)), -1, 1)
        if selected_direction == 0:
            selected_direction = relative_direction
        if bool(definition.get("dash_before_attack", false)) and selected_direction != 0:
            actor_tile = clampi(actor_tile + selected_direction, 1, maxi(1, int(rules.get("tile_count", 10))))
            actor["tile"] = actor_tile
            state[actor_key] = actor
            logs.append("[%d수 · 절초] %s이(가) 검광을 타고 1칸 돌진했다." % [timing, _actor_name(actor)])
            target_tile = int(target.get("tile", 1))
            relative_direction = signi(target_tile - actor_tile)
        if relative_direction != 0 and selected_direction != relative_direction:
            logs.append("[%d수 · %s] %s의 %s은(는) 반대 방향을 향해 빗나갔다." % [timing, phase_label, _actor_name(actor), str(definition.get("name", "공격"))])
            resolved_actions.append(_resolved_record(action, timing, "miss_direction"))
            continue

        var attack_range := maxi(0, int(str(definition.get("range_text", "0"))))
        var distance := absi(actor_tile - target_tile)
        if distance > attack_range:
            logs.append("[%d수 · %s] %s의 %s은(는) 사거리가 닿지 않았다." % [timing, phase_label, _actor_name(actor), str(definition.get("name", "공격"))])
            resolved_actions.append(_resolved_record(action, timing, "miss_range"))
            continue

        var damage := maxi(0, int(str(definition.get("damage", "0"))))
        if str(definition.get("source", "")) == "ultimate":
            damage += int(floor(float(actor.get("attack_power", 0)) * float(definition.get("attack_power_coefficient", 0.0))))
        var bonus := int(actor.get("next_attack_bonus", 0))
        damage += bonus
        actor["next_attack_bonus"] = 0
        state[actor_key] = actor

        var attack_record := _resolved_record(action, timing, phase_label)
        attack_record["target"] = target_key
        attack_record["raw_damage"] = damage
        attack_record["damage"] = 0
        attack_record["defense_outcome"] = "pending"
        attack_record["actor_tile_after_action"] = actor_tile
        attack_record["target_tile_at_action"] = target_tile
        resolved_actions.append(attack_record)
        deferred_attacks.append({"action": action, "record": attack_record, "actor": actor_key, "target": target_key, "raw_damage": damage, "phase": phase_label, "sure_hit": "필중" in definition.get("tags", [])})

func _resolve_timing_attacks(state: Dictionary, candidates: Array, defenses: Dictionary, logs: Array[String], timing: int, all_actions: Array) -> void:
    if candidates.is_empty():
        return
    var by_actor := {}
    for candidate in candidates:
        by_actor[str((candidate as Dictionary).get("actor", ""))] = candidate
    var pending_damage := {"player": 0, "enemy": 0}
    var momentum_awards := {"player": [], "enemy": []}
    if by_actor.has("player") and by_actor.has("enemy"):
        _resolve_clash(by_actor["player"], by_actor["enemy"], defenses, timing, logs, pending_damage, momentum_awards)
    else:
        for candidate in candidates:
            _resolve_single_attack(candidate, defenses, timing, logs, pending_damage, momentum_awards)
    _apply_pending_damage(state, pending_damage)
    var damage_phase := "attack_timing"
    for candidate in candidates:
        if str((candidate as Dictionary).get("phase", "")) == "속공":
            damage_phase = "속공"
            break
    _apply_interruption_after_damage(state, all_actions, pending_damage, timing, damage_phase, logs)
    _apply_timing_momentum_awards(state, momentum_awards, logs, timing)

func _resolve_clash(first: Dictionary, second: Dictionary, defenses: Dictionary, timing: int, logs: Array[String], pending_damage: Dictionary, momentum_awards: Dictionary) -> void:
    var first_raw := int(first.get("raw_damage", 0))
    var second_raw := int(second.get("raw_damage", 0))
    var first_record: Dictionary = first.get("record", {})
    var second_record: Dictionary = second.get("record", {})
    first_record["clash"] = true
    second_record["clash"] = true
    first_record["clash_opponent_raw_damage"] = second_raw
    second_record["clash_opponent_raw_damage"] = first_raw
    if first_raw == second_raw:
        first_record["outcome"] = "clash_draw"
        second_record["outcome"] = "clash_draw"
        first_record["defense_outcome"] = "clash_draw"
        second_record["defense_outcome"] = "clash_draw"
        logs.append("[%d수 · 합] 양측 공격력 %d가 맞부딪혀 상쇄됐다." % [timing, first_raw])
        return
    var winner: Dictionary = first if first_raw > second_raw else second
    var loser: Dictionary = second if first_raw > second_raw else first
    var difference := absi(first_raw - second_raw)
    var defended := _apply_defense(difference, str(winner.get("actor", "")), str(loser.get("actor", "")), bool(winner.get("sure_hit", false)), defenses, timing)
    var final_damage := int(defended.get("damage", 0))
    var winner_record: Dictionary = winner.get("record", {})
    var loser_record: Dictionary = loser.get("record", {})
    for record in [winner_record, loser_record]:
        record["clash_difference"] = difference
        record["damage"] = final_damage
        record["damage_after_block"] = int(defended.get("after_block", difference))
        record["defense_outcome"] = str(defended.get("outcome", "hit"))
        record["sure_hit"] = bool(winner.get("sure_hit", false))
    winner_record["outcome"] = "clash_win"
    loser_record["outcome"] = "clash_loss"
    pending_damage[str(loser.get("actor", ""))] = final_damage
    logs.append("[%d수 · 합] 공격력 %d 대 %d, 차이 %d." % [timing, first_raw, second_raw, difference])
    _queue_momentum_award(momentum_awards, str(winner.get("actor", "")), "clash_win")
    _queue_defense_momentum_award(momentum_awards, str(loser.get("actor", "")), str(defended.get("outcome", "hit")))

func _resolve_single_attack(candidate: Dictionary, defenses: Dictionary, timing: int, logs: Array[String], pending_damage: Dictionary, momentum_awards: Dictionary) -> void:
    var actor_key := str(candidate.get("actor", ""))
    var target_key := str(candidate.get("target", ""))
    var defended := _apply_defense(int(candidate.get("raw_damage", 0)), actor_key, target_key, bool(candidate.get("sure_hit", false)), defenses, timing)
    var record: Dictionary = candidate.get("record", {})
    record["damage"] = int(defended.get("damage", 0))
    record["damage_after_block"] = int(defended.get("after_block", candidate.get("raw_damage", 0)))
    record["defense_outcome"] = str(defended.get("outcome", "hit"))
    record["sure_hit"] = bool(candidate.get("sure_hit", false))
    pending_damage[target_key] = int(defended.get("damage", 0))
    _queue_defense_momentum_award(momentum_awards, target_key, str(defended.get("outcome", "hit")))
    if int(defended.get("damage", 0)) > 0:
        logs.append("[%d수 · 공격] %s의 공격이 적중했다. 피해 %d." % [timing, str((candidate.get("action", {}) as Dictionary).get("definition", {}).get("name", "공격")), int(defended.get("damage", 0))])

func _queue_defense_momentum_award(momentum_awards: Dictionary, actor_key: String, outcome: String) -> void:
    if outcome == "evade":
        _queue_momentum_award(momentum_awards, actor_key, "evade")
    elif outcome in ["block", "sure_hit_block"]:
        _queue_momentum_award(momentum_awards, actor_key, "guard")

func _queue_momentum_award(momentum_awards: Dictionary, actor_key: String, reason: String) -> void:
    if not momentum_awards.has(actor_key):
        momentum_awards[actor_key] = []
    var awards: Array = momentum_awards.get(actor_key, [])
    awards.append(reason)
    momentum_awards[actor_key] = awards

func _apply_timing_momentum_awards(state: Dictionary, momentum_awards: Dictionary, logs: Array[String], timing: int) -> void:
    for actor_key in ["player", "enemy"]:
        var awards: Array = momentum_awards.get(actor_key, [])
        for reason in awards:
            var amount := _momentum_award_amount(str(reason))
            if amount <= 0:
                continue
            _grant_momentum(state, actor_key, amount, logs, "[%d수 · 절초 기세] %s" % [timing, _momentum_award_label(str(reason))])

func _award_bundle_momentum(state: Dictionary, logs: Array[String]) -> void:
    var amount := maxi(0, int(rules.get("bundle_momentum_gain", 1)))
    for actor_key in ["player", "enemy"]:
        _grant_momentum(state, actor_key, amount, logs, "[묶음 완료 · 절초 기세]")

func _momentum_award_amount(reason: String) -> int:
    match reason:
        "guard":
            return maxi(0, int(rules.get("guard_success_momentum_gain", 1)))
        "evade":
            return maxi(0, int(rules.get("evade_success_momentum_gain", 1)))
        "clash_win":
            return maxi(0, int(rules.get("clash_win_momentum_gain", 1)))
    return 0

func _momentum_award_label(reason: String) -> String:
    match reason:
        "guard":
            return "막기 성공"
        "evade":
            return "회피 성공"
        "clash_win":
            return "합 승리"
    return "기세 획득"

func _grant_momentum(state: Dictionary, actor_key: String, amount: int, logs: Array[String], source: String) -> void:
    var actor: Dictionary = state.get(actor_key, {})
    var momentum := _resource_pair(actor, "momentum")
    var next := mini(momentum.y, momentum.x + amount)
    if next > momentum.x:
        _set_resource(actor, "momentum", next, momentum.y)
        state[actor_key] = actor
        logs.append("%s %s 기세 +%d (%d/%d)." % [source, _actor_name(actor), next - momentum.x, next, momentum.y])

func _apply_defense(raw_damage: int, _attacker_key: String, target_key: String, sure_hit: bool, defenses: Dictionary, timing: int) -> Dictionary:
    var defense: Dictionary = defenses.get(target_key, _empty_defense_profile())
    var evade_timings: PackedInt32Array = defense.get("evade_timings", PackedInt32Array())
    if not sure_hit and (bool(defense.get("evade_bundle", false)) or timing in evade_timings):
        return {"damage": 0, "after_block": raw_damage, "outcome": "evade"}
    var block := maxi(0, int(defense.get("guard_block", 0)))
    var after_block := maxi(0, raw_damage - block)
    var guard_timings: PackedInt32Array = defense.get("guard_timings", PackedInt32Array())
    var damage := int(floor(float(after_block) * float(rules.get("guard_same_timing_damage_multiplier", 0.5)))) if timing in guard_timings else after_block
    var outcome := "block" if block > 0 else "hit"
    if sure_hit:
        outcome = "sure_hit_block" if block > 0 else "sure_hit"
    return {"damage": damage, "after_block": after_block, "outcome": outcome}

func _apply_pending_damage(state: Dictionary, pending_damage: Dictionary) -> void:
    for target_key in ["player", "enemy"]:
        var damage := int(pending_damage.get(target_key, 0))
        if damage <= 0:
            continue
        var target: Dictionary = state.get(target_key, {})
        var health := _resource_pair(target, "health")
        _set_resource(target, "health", maxi(0, health.x - damage), health.y)
        state[target_key] = target

func _apply_interruption_after_damage(state: Dictionary, all_actions: Array, pending_damage: Dictionary, timing: int, phase_label: String, logs: Array[String]) -> void:
    for actor_key in ["player", "enemy"]:
        if int(pending_damage.get(actor_key, 0)) <= 0:
            continue
        var actor: Dictionary = state.get(actor_key, {})
        var defeated := _resource_pair(actor, "health").x <= 0
        for action in all_actions:
            var action_timing := int(action.get("execution_timing", 0))
            if str(action.get("actor", "")) != actor_key or bool(action.get("cancelled", false)) or bool(action.get("executed", false)):
                continue
            if (not defeated and action_timing != timing) or (defeated and action_timing < timing):
                continue
            var definition: Dictionary = action.get("definition", {})
            var protected_by_fortitude := phase_label == "속공" and bool(actor.get("fortitude_next_attack", false)) and int(action.get("span", 1)) == 1 and str(definition.get("category", "")) == "attack"
            if protected_by_fortitude and not defeated:
                actor["fortitude_next_attack"] = false
                logs.append("[%d수 · 강건] %s의 다음 1슬롯 공격은 속공 피격 중단을 버텼다." % [timing, _actor_name(actor)])
                continue
            action["cancelled"] = true
            action["interrupt_reason"] = "defeat" if defeated else "damage_%s" % phase_label
            logs.append("[%d수 · 중단] %s의 아직 실행되지 않은 이 수 행동이 실제 피해로 취소됐다." % [timing, _actor_name(actor)])
        state[actor_key] = actor

func _execute_move_phase(state: Dictionary, actions: Array, logs: Array[String], timing: int, resolved_actions: Array) -> void:
    if actions.is_empty():
        return
    var proposals: Dictionary = {}
    var board_size := maxi(1, int(rules.get("tile_count", 10)))
    for action in actions:
        if bool(action.get("cancelled", false)):
            resolved_actions.append(_resolved_record(action, timing, "interrupted"))
            continue
        if not _pay_action_cost(state, action, logs, timing):
            continue
        action["executed"] = true
        var actor_key := str(action.get("actor", "player"))
        var target_key := _other_actor(actor_key)
        var actor: Dictionary = state.get(actor_key, {})
        var target: Dictionary = state.get(target_key, {})
        var definition: Dictionary = action.get("definition", {})
        var movement_steps := maxi(1, int(definition.get("move_range", rules.get("movement_steps", 1))))
        var from_tile := int(actor.get("tile", 1))
        var enemy_tile := int(target.get("tile", 1))
        var requested_tile := int(action.get("target_tile", 0))
        var direction := clampi(int(action.get("direction", 0)), -1, 1)
        if requested_tile <= 0:
            if direction == 0:
                direction = signi(enemy_tile - from_tile)
            requested_tile = from_tile + direction * movement_steps

        var proposed := requested_tile
        var invalid := proposed < 1 or proposed > board_size or absi(proposed - from_tile) > movement_steps
        if invalid:
            proposed = from_tile
        proposals[actor_key] = proposed
        resolved_actions.append(_resolved_record(action, timing, "move" if not invalid else "move_invalid"))

    var player_from := int((state.get("player", {}) as Dictionary).get("tile", 1))
    var enemy_from := int((state.get("enemy", {}) as Dictionary).get("tile", 1))
    if proposals.has("player") and proposals.has("enemy") and int(proposals["player"]) == enemy_from and int(proposals["enemy"]) == player_from:
        proposals["player"] = int((state.get("player", {}) as Dictionary).get("tile", 1))
        proposals["enemy"] = int((state.get("enemy", {}) as Dictionary).get("tile", 1))
        logs.append("[%d수 · 이동] 자리 교환과 상대 통과는 금지되어 양측이 제자리를 지켰다." % timing)
        return

    for actor_key in proposals.keys():
        var actor: Dictionary = state.get(actor_key, {})
        var from_tile := int(actor.get("tile", 1))
        var to_tile := int(proposals[actor_key])
        actor["tile"] = to_tile
        state[actor_key] = actor
        if from_tile == to_tile:
            logs.append("[%d수 · 이동] %s의 지정 이동 칸이 유효하지 않아 제자리를 지켰다." % [timing, _actor_name(actor)])
        else:
            logs.append("[%d수 · 이동] %s이(가) %d번에서 %d번 칸으로 이동했다." % [timing, _actor_name(actor), from_tile, to_tile])

func _execute_utility(state: Dictionary, action: Dictionary, logs: Array[String], timing: int) -> void:
    var actor_key := str(action.get("actor", "player"))
    var actor: Dictionary = state.get(actor_key, {})
    var definition: Dictionary = action.get("definition", {})
    var card_id := _base_card_id(definition)
    if card_id == "basic_meditate":
        var stamina := _resource_pair(actor, "stamina")
        var internal := _resource_pair(actor, "internal")
        _set_resource(actor, "stamina", mini(stamina.y, stamina.x + int(rules.get("meditate_stamina_restore", 2))), stamina.y)
        _set_resource(actor, "internal", mini(internal.y, internal.x + int(rules.get("meditate_internal_restore", 1))), internal.y)
        logs.append("[%d수 · 일반] %s이(가) 명상해 기력과 내력을 회복했다." % [timing, _actor_name(actor)])
    elif card_id == "basic_stance":
        actor["next_attack_bonus"] = int(actor.get("next_attack_bonus", 0)) + int(rules.get("stance_attack_bonus", 2))
        actor["fortitude_next_attack"] = true
        logs.append("[%d수 · 일반] %s이(가) 태세를 가다듬어 다음 공격을 강화했다." % [timing, _actor_name(actor)])
    else:
        logs.append("[%d수 · 일반] %s이(가) %s을(를) 실행했다." % [timing, _actor_name(actor), str(definition.get("name", "행동"))])
    state[actor_key] = actor

func _base_card_id(definition: Dictionary) -> String:
    return str(definition.get("base_card_id", definition.get("id", "")))

func _resolved_record(action: Dictionary, timing: int, outcome: String) -> Dictionary:
    var definition: Dictionary = action.get("definition", {})
    return {
        "actor": str(action.get("actor", "player")),
        "timing": timing,
        "card_id": str(definition.get("id", "")),
        "base_card_id": _base_card_id(definition),
        "card_name": str(definition.get("name", "")),
        "outcome": outcome,
        "direction": int(action.get("direction", 0)),
        "target_tile": int(action.get("target_tile", 0)),
        "ai_reason": str(action.get("ai_reason", ""))
    }

func _build_presentation_events(state_before: Dictionary, state_after: Dictionary, resolved_actions: Array, logs: Array[String], append_state: bool = true) -> Array:
    var events: Array = []
    var before_positions := {
        "player": int((state_before.get("player", {}) as Dictionary).get("tile", 1)),
        "enemy": int((state_before.get("enemy", {}) as Dictionary).get("tile", 1))
    }
    for value in resolved_actions:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var action: Dictionary = value
        var outcome := str(action.get("outcome", ""))
        var phase := outcome
        if outcome in ["interrupted", "miss_direction", "miss_range", "move_invalid"]:
            phase = "result"
        var event := {
            "type": "clash" if outcome.begins_with("clash_") else "action_result",
            "phase": phase,
            "timing": int(action.get("timing", 0)),
            "actor": str(action.get("actor", "")),
            "card_id": str(action.get("card_id", "")),
            "card_name": str(action.get("card_name", "")),
            "outcome": outcome,
            "direction": int(action.get("direction", 0)),
            "target_tile": int(action.get("target_tile", 0)),
            "positions_before_bundle": before_positions.duplicate(true)
        }
        for key in ["target", "raw_damage", "damage", "damage_after_block", "defense_outcome", "actor_tile_after_action", "target_tile_at_action", "clash", "clash_opponent_raw_damage", "clash_difference", "sure_hit"]:
            if action.has(key):
                event[key] = action[key]
        events.append(event)
    if append_state:
        events.append({
            "type": "bundle_state",
            "phase": "result",
            "player": (state_after.get("player", {}) as Dictionary).duplicate(true),
            "enemy": (state_after.get("enemy", {}) as Dictionary).duplicate(true),
            "logs": logs.duplicate()
        })
    return events

func _resource_pair(actor: Dictionary, key: String) -> Vector2i:
    var value = actor.get(key, [0, 0])
    if typeof(value) == TYPE_ARRAY and value.size() >= 2:
        return Vector2i(int(value[0]), maxi(1, int(value[1])))
    return Vector2i.ZERO

func _set_resource(actor: Dictionary, key: String, current: int, maximum: int) -> void:
    actor[key] = [clampi(current, 0, maxi(1, maximum)), maxi(1, maximum)]

func _actor_name(actor: Dictionary) -> String:
    return str(actor.get("name", "전투원"))

func _other_actor(actor_key: String) -> String:
    return "enemy" if actor_key == "player" else "player"
