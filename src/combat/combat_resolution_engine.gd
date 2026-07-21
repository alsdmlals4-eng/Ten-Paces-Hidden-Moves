class_name CombatResolutionEngine
extends RefCounted

const RULES_PATH := "res://data/combat/combat_resolution_preview.json"
const CARDS_PATH := "res://data/cards/basic_cards.json"

var rules: Dictionary = {}
var cards_by_id: Dictionary = {}

func _init() -> void:
    rules = _load_json(RULES_PATH, "STEP 10 resolution rules")
    var card_data := _load_json(CARDS_PATH, "basic cards")
    var cards: Array = card_data.get("cards", [])
    for value in cards:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var definition: Dictionary = value
        cards_by_id[str(definition.get("id", ""))] = definition.duplicate(true)

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
        "enemy": enemy
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

func resolve_bundle(player_placements: Array, context: Dictionary, state_value: Dictionary) -> Dictionary:
    var state := state_value.duplicate(true)
    var logs: Array[String] = []
    var resolved_actions: Array = []
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
    actions.append_array(_build_enemy_actions(bundle_index))

    for timing in range(bundle_start, bundle_end + 1):
        var timing_actions := _actions_for_timing(actions, timing)
        if timing_actions.is_empty():
            logs.append("[%d수] 양측 모두 행동하지 않았다." % timing)
            continue

        var responses: Dictionary = {}
        var response_actions := _filter_phase(timing_actions, "response")
        for action in response_actions:
            if _pay_action_cost(state, action, logs, timing):
                _execute_response(state, action, responses, logs, timing)
                resolved_actions.append(_resolved_record(action, timing, "response"))

        var quick_actions := _filter_phase(timing_actions, "quick_attack")
        _execute_attack_phase(state, quick_actions, responses, logs, timing, "속공", resolved_actions)

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
        _execute_attack_phase(state, normal_attacks, responses, logs, timing, "일반 공격", resolved_actions)
        for action in utility_actions:
            if not _pay_action_cost(state, action, logs, timing):
                continue
            _execute_utility(state, action, logs, timing)
            resolved_actions.append(_resolved_record(action, timing, "general"))

    return {
        "state": state,
        "logs": logs,
        "resolved_actions": resolved_actions,
        "round_number": round_number,
        "bundle_index": bundle_index,
        "bundle_start": bundle_start,
        "bundle_end": bundle_end,
        "resolution_order": rules.get("resolution_order", ["response", "quick_attack", "move", "general"])
    }

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

func _build_enemy_actions(bundle_index: int) -> Array:
    var result: Array = []
    var bundles: Dictionary = rules.get("enemy_bundles", {})
    var plan: Array = bundles.get(str(bundle_index), [])
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
            "origin_tile": 0
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
    var tags: Array = definition.get("tags", [])
    if category == "response":
        return "response"
    if category == "attack" and "속공" in tags:
        return "quick_attack"
    if category == "move":
        return "move"
    return "general"

func _pay_action_cost(state: Dictionary, action: Dictionary, logs: Array[String], timing: int) -> bool:
    var actor_key := str(action.get("actor", "player"))
    var actor: Dictionary = state.get(actor_key, {})
    var definition: Dictionary = action.get("definition", {})
    var stamina_cost := int(definition.get("stamina_cost", 0))
    var internal_cost := int(definition.get("internal_cost", 0))
    var stamina := _resource_pair(actor, "stamina")
    var internal := _resource_pair(actor, "internal")
    if stamina.x < stamina_cost or internal.x < internal_cost:
        logs.append("[%d수] %s은(는) 자원이 부족해 %s을(를) 실행하지 못했다." % [timing, _actor_name(actor), str(definition.get("name", "행동"))])
        return false
    _set_resource(actor, "stamina", stamina.x - stamina_cost, stamina.y)
    _set_resource(actor, "internal", internal.x - internal_cost, internal.y)
    state[actor_key] = actor
    return true

func _execute_response(state: Dictionary, action: Dictionary, responses: Dictionary, logs: Array[String], timing: int) -> void:
    var actor_key := str(action.get("actor", "player"))
    var actor: Dictionary = state.get(actor_key, {})
    var definition: Dictionary = action.get("definition", {})
    var card_id := str(definition.get("id", ""))
    if card_id == "basic_evade":
        responses[actor_key] = "evade"
        logs.append("[%d수 · 대응] %s이(가) 회피를 준비했다." % [timing, _actor_name(actor)])
    else:
        responses[actor_key] = "guard"
        logs.append("[%d수 · 대응] %s이(가) 막기를 준비했다." % [timing, _actor_name(actor)])

func _execute_attack_phase(state: Dictionary, actions: Array, responses: Dictionary, logs: Array[String], timing: int, phase_label: String, resolved_actions: Array) -> void:
    if actions.is_empty():
        return
    var pending_damage: Dictionary = {"player": 0, "enemy": 0}
    var successful_attackers: Array[String] = []
    for action in actions:
        if not _pay_action_cost(state, action, logs, timing):
            continue
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
        var bonus := int(actor.get("next_attack_bonus", 0))
        damage += bonus
        actor["next_attack_bonus"] = 0
        state[actor_key] = actor

        var response := str(responses.get(target_key, ""))
        if response == "evade":
            damage = 0
            logs.append("[%d수 · %s] %s이(가) %s의 %s을(를) 회피했다." % [timing, phase_label, _actor_name(target), _actor_name(actor), str(definition.get("name", "공격"))])
        elif response == "guard":
            var block := int(rules.get("guard_block", 4))
            var before := damage
            damage = maxi(0, damage - block)
            logs.append("[%d수 · %s] %s이(가) 막기로 피해 %d를 %d로 줄였다." % [timing, phase_label, _actor_name(target), before, damage])
        else:
            logs.append("[%d수 · %s] %s의 %s이(가) 적중했다. 피해 %d." % [timing, phase_label, _actor_name(actor), str(definition.get("name", "공격")), damage])

        pending_damage[target_key] = int(pending_damage.get(target_key, 0)) + damage
        if damage > 0:
            successful_attackers.append(actor_key)
        resolved_actions.append(_resolved_record(action, timing, phase_label))

    for target_key in ["player", "enemy"]:
        var damage := int(pending_damage.get(target_key, 0))
        if damage <= 0:
            continue
        var target: Dictionary = state.get(target_key, {})
        var health := _resource_pair(target, "health")
        _set_resource(target, "health", maxi(0, health.x - damage), health.y)
        state[target_key] = target

    for actor_key in successful_attackers:
        var actor: Dictionary = state.get(actor_key, {})
        var momentum := _resource_pair(actor, "momentum")
        _set_resource(actor, "momentum", mini(momentum.y, momentum.x + int(rules.get("damage_momentum_gain", 1))), momentum.y)
        state[actor_key] = actor

func _execute_move_phase(state: Dictionary, actions: Array, logs: Array[String], timing: int, resolved_actions: Array) -> void:
    if actions.is_empty():
        return
    var proposals: Dictionary = {}
    var board_size := maxi(1, int(rules.get("tile_count", 10)))
    for action in actions:
        if not _pay_action_cost(state, action, logs, timing):
            continue
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
        var invalid := proposed < 1 or proposed > board_size or absi(proposed - from_tile) > movement_steps or proposed == enemy_tile
        if invalid:
            proposed = from_tile
        proposals[actor_key] = proposed
        resolved_actions.append(_resolved_record(action, timing, "move" if not invalid else "move_invalid"))

    if proposals.has("player") and proposals.has("enemy") and int(proposals["player"]) == int(proposals["enemy"]):
        logs.append("[%d수 · 이동] 양측이 같은 칸을 선택해 모두 제자리에 멈췄다." % timing)
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
    var card_id := str(definition.get("id", ""))
    if card_id == "basic_meditate":
        var stamina := _resource_pair(actor, "stamina")
        var internal := _resource_pair(actor, "internal")
        _set_resource(actor, "stamina", mini(stamina.y, stamina.x + int(rules.get("meditate_stamina_restore", 2))), stamina.y)
        _set_resource(actor, "internal", mini(internal.y, internal.x + int(rules.get("meditate_internal_restore", 1))), internal.y)
        logs.append("[%d수 · 일반] %s이(가) 명상해 기력과 내력을 회복했다." % [timing, _actor_name(actor)])
    elif card_id == "basic_stance":
        actor["next_attack_bonus"] = int(actor.get("next_attack_bonus", 0)) + int(rules.get("stance_attack_bonus", 2))
        logs.append("[%d수 · 일반] %s이(가) 태세를 가다듬어 다음 공격을 강화했다." % [timing, _actor_name(actor)])
    else:
        logs.append("[%d수 · 일반] %s이(가) %s을(를) 실행했다." % [timing, _actor_name(actor), str(definition.get("name", "행동"))])
    state[actor_key] = actor

func _resolved_record(action: Dictionary, timing: int, outcome: String) -> Dictionary:
    var definition: Dictionary = action.get("definition", {})
    return {
        "actor": str(action.get("actor", "player")),
        "timing": timing,
        "card_id": str(definition.get("id", "")),
        "card_name": str(definition.get("name", "")),
        "outcome": outcome,
        "direction": int(action.get("direction", 0)),
        "target_tile": int(action.get("target_tile", 0))
    }

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
