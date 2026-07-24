class_name CombatResolutionEnginePrepare
extends CombatResolutionEngine

# 기존 판정 공식을 재사용하고, [준비] 상태의 수명과 명상 기세만 후처리한다.
# 이동은 준비를 소비하지 않으며 모든 비이동 행동 시도는 준비를 소비한다.

func make_initial_state(hud_data: Dictionary, player_tile: int, enemy_tile: int) -> Dictionary:
    var state := super.make_initial_state(hud_data, player_tile, enemy_tile)
    for actor_key in ["player", "enemy"]:
        var actor: Dictionary = (state.get(actor_key, {}) as Dictionary).duplicate(true)
        actor["prepare_active"] = false
        state[actor_key] = actor
    return state

func preview_player_plan(state_value: Dictionary, placements: Array) -> Dictionary:
    var preview := super.preview_player_plan(state_value, placements)
    var preview_state: Dictionary = (preview.get("state", {}) as Dictionary).duplicate(true)
    var actor: Dictionary = (preview_state.get("player", {}) as Dictionary).duplicate(true)
    var source_actor: Dictionary = state_value.get("player", {})
    var prepare_active := bool(source_actor.get("prepare_active", false))
    var statuses_by_anchor := {}
    for event_value in preview.get("events", []):
        if typeof(event_value) != TYPE_DICTIONARY:
            continue
        var event: Dictionary = event_value
        statuses_by_anchor[int(event.get("anchor_index", 0))] = str(event.get("status", ""))

    var ordered := _placement_attempts(placements, "player")
    for attempt_value in ordered:
        var attempt: Dictionary = attempt_value
        var definition: Dictionary = attempt.get("definition", {})
        var card_id := _base_card_id(definition)
        var category := str(definition.get("category", ""))
        var anchor := int(attempt.get("anchor_index", 0))
        var applied := str(statuses_by_anchor.get(anchor, "")) == "applied"
        if card_id == "basic_stance":
            if applied:
                prepare_active = true
                actor["next_attack_bonus"] = int(rules.get("stance_attack_bonus", 2))
                actor["fortitude_next_attack"] = true
            elif prepare_active:
                prepare_active = false
                _clear_prepare_state(actor)
            continue
        if category == "move":
            continue
        if prepare_active and card_id == "basic_meditate" and applied:
            _grant_prepare_momentum(actor)
        if prepare_active:
            prepare_active = false
            _clear_prepare_state(actor)

    actor["prepare_active"] = prepare_active
    preview_state["player"] = actor
    preview["state"] = preview_state
    return preview

func resolve_bundle(player_placements: Array, context: Dictionary, state_value: Dictionary) -> Dictionary:
    var normalized_state := state_value.duplicate(true)
    for actor_key in ["player", "enemy"]:
        var actor: Dictionary = (normalized_state.get(actor_key, {}) as Dictionary).duplicate(true)
        actor["prepare_active"] = bool(actor.get("prepare_active", false))
        normalized_state[actor_key] = actor

    var result := super.resolve_bundle(player_placements, context, normalized_state)
    var attempts := _placement_attempts(player_placements, "player")
    attempts.append_array(_enemy_attempts_from_result(result))
    attempts.sort_custom(_sort_attempts)
    _apply_prepare_state_to_result(result, normalized_state, attempts)
    _rewrite_user_facing_logs(result)
    return result

func _placement_attempts(placements: Array, actor_key: String) -> Array:
    var attempts: Array = []
    for value in placements:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var placement: Dictionary = value
        var definition: Dictionary = (placement.get("definition", {}) as Dictionary).duplicate(true)
        if definition.is_empty():
            definition = (cards_by_id.get(str(placement.get("card_id", "")), {}) as Dictionary).duplicate(true)
        if definition.is_empty():
            continue
        var anchor := int(placement.get("anchor_index", 1))
        var span := maxi(1, int(placement.get("span", definition.get("action_slots", 1))))
        attempts.append({
            "actor": actor_key,
            "anchor_index": anchor,
            "execution_timing": anchor + span - 1,
            "definition": definition,
            "response_phase": str(definition.get("category", "")) == "response"
        })
    return attempts

func _enemy_attempts_from_result(result: Dictionary) -> Array:
    var attempts: Array = []
    var seen := {}
    for value in result.get("resolved_actions", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var record: Dictionary = value
        if str(record.get("actor", "")) != "enemy" or str(record.get("action_stage", "execution")) == "preparation":
            continue
        var card_id := str(record.get("card_id", ""))
        var timing := int(record.get("timing", 0))
        var key := "%s:%d" % [card_id, timing]
        if seen.has(key):
            continue
        seen[key] = true
        var definition: Dictionary = (cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
        if definition.is_empty():
            continue
        attempts.append({
            "actor": "enemy",
            "anchor_index": timing - maxi(1, int(definition.get("action_slots", 1))) + 1,
            "execution_timing": timing,
            "definition": definition,
            "response_phase": str(definition.get("category", "")) == "response"
        })
    return attempts

func _sort_attempts(a: Dictionary, b: Dictionary) -> bool:
    var a_order := 0 if bool(a.get("response_phase", false)) else int(a.get("execution_timing", 0))
    var b_order := 0 if bool(b.get("response_phase", false)) else int(b.get("execution_timing", 0))
    if a_order == b_order:
        return str(a.get("actor", "")) < str(b.get("actor", ""))
    return a_order < b_order

func _apply_prepare_state_to_result(result: Dictionary, state_before: Dictionary, attempts: Array) -> void:
    var active := {
        "player": bool((state_before.get("player", {}) as Dictionary).get("prepare_active", false)),
        "enemy": bool((state_before.get("enemy", {}) as Dictionary).get("prepare_active", false))
    }
    var extra_momentum := {"player": 0, "enemy": 0}
    var reward_events: Array = []
    var processed := {}
    var timing_results: Array = result.get("timing_results", [])

    for index in range(timing_results.size()):
        var timing_result: Dictionary = timing_results[index]
        var phase := str(timing_result.get("phase", ""))
        var timing := int(timing_result.get("timing", 0))
        for attempt_index in range(attempts.size()):
            if processed.has(attempt_index):
                continue
            var attempt: Dictionary = attempts[attempt_index]
            var belongs := bool(attempt.get("response_phase", false)) if phase == "response" else (not bool(attempt.get("response_phase", false)) and int(attempt.get("execution_timing", 0)) == timing)
            if not belongs:
                continue
            _apply_attempt_transition(result, attempt, active, extra_momentum, reward_events)
            processed[attempt_index] = true
        var snapshot: Dictionary = (timing_result.get("state", {}) as Dictionary).duplicate(true)
        _apply_prepare_overlay(snapshot, active, extra_momentum)
        timing_result["state"] = snapshot
        timing_results[index] = timing_result

    for attempt_index in range(attempts.size()):
        if processed.has(attempt_index):
            continue
        _apply_attempt_transition(result, attempts[attempt_index], active, extra_momentum, reward_events)

    result["timing_results"] = timing_results
    var final_state: Dictionary = (result.get("state", {}) as Dictionary).duplicate(true)
    _apply_prepare_overlay(final_state, active, extra_momentum)
    result["state"] = final_state
    _append_prepare_reward_logs(result, reward_events)
    _patch_bundle_state_event(result)

func _apply_attempt_transition(result: Dictionary, attempt: Dictionary, active: Dictionary, extra_momentum: Dictionary, reward_events: Array) -> void:
    var actor_key := str(attempt.get("actor", "player"))
    var definition: Dictionary = attempt.get("definition", {})
    var card_id := _base_card_id(definition)
    var category := str(definition.get("category", ""))
    var executed := _attempt_executed(result, attempt)

    if card_id == "basic_stance":
        if executed:
            active[actor_key] = true
        elif bool(active.get(actor_key, false)):
            active[actor_key] = false
        return
    if category == "move":
        return
    if bool(active.get(actor_key, false)) and card_id == "basic_meditate" and executed:
        var amount := maxi(0, int(rules.get("prepare_meditate_momentum", 1)))
        extra_momentum[actor_key] = int(extra_momentum.get(actor_key, 0)) + amount
        reward_events.append({"actor": actor_key, "timing": int(attempt.get("execution_timing", 0)), "amount": amount})
    if bool(active.get(actor_key, false)):
        active[actor_key] = false

func _attempt_executed(result: Dictionary, attempt: Dictionary) -> bool:
    var actor_key := str(attempt.get("actor", ""))
    var timing := int(attempt.get("execution_timing", 0))
    var definition: Dictionary = attempt.get("definition", {})
    var expected_id := str(definition.get("id", ""))
    var expected_base_id := _base_card_id(definition)
    for value in result.get("resolved_actions", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var record: Dictionary = value
        if str(record.get("actor", "")) != actor_key or int(record.get("timing", 0)) != timing:
            continue
        if str(record.get("action_stage", "execution")) == "preparation":
            continue
        var record_id := str(record.get("card_id", ""))
        var record_base_id := str(record.get("base_card_id", record_id))
        if record_id != expected_id and record_base_id != expected_base_id:
            continue
        return str(record.get("outcome", "")) != "interrupted"
    return false

func _apply_prepare_overlay(state: Dictionary, active: Dictionary, extra_momentum: Dictionary) -> void:
    for actor_key in ["player", "enemy"]:
        var actor: Dictionary = (state.get(actor_key, {}) as Dictionary).duplicate(true)
        var is_active := bool(active.get(actor_key, false))
        actor["prepare_active"] = is_active
        if is_active:
            if int(actor.get("next_attack_bonus", 0)) <= 0:
                actor["next_attack_bonus"] = int(rules.get("stance_attack_bonus", 2))
            actor["fortitude_next_attack"] = true
            _sync_dynamic_statuses(actor)
        else:
            _clear_prepare_state(actor)
        var bonus := int(extra_momentum.get(actor_key, 0))
        if bonus > 0:
            var momentum := _resource_pair(actor, "momentum")
            _set_resource(actor, "momentum", momentum.x + bonus, momentum.y)
        state[actor_key] = actor

func _grant_prepare_momentum(actor: Dictionary) -> void:
    var momentum := _resource_pair(actor, "momentum")
    _set_resource(actor, "momentum", momentum.x + int(rules.get("prepare_meditate_momentum", 1)), momentum.y)

func _clear_prepare_state(actor: Dictionary) -> void:
    actor["prepare_active"] = false
    actor["next_attack_bonus"] = 0
    actor["fortitude_next_attack"] = false
    _sync_dynamic_statuses(actor)

func _append_prepare_reward_logs(result: Dictionary, reward_events: Array) -> void:
    if reward_events.is_empty():
        return
    var logs: Array = result.get("logs", [])
    var insert_at := logs.size()
    for index in range(logs.size()):
        if str(logs[index]).begins_with("[묶음 완료"):
            insert_at = index
            break
    for event_value in reward_events:
        var event: Dictionary = event_value
        var actor_key := str(event.get("actor", "player"))
        var actor: Dictionary = (result.get("state", {}) as Dictionary).get(actor_key, {})
        var line := "[%d수 · 준비 강화] %s이(가) 명상으로 절초 기세 +%d을 얻었다." % [int(event.get("timing", 0)), _actor_name(actor), int(event.get("amount", 1))]
        logs.insert(insert_at, line)
        insert_at += 1
    result["logs"] = logs

func _rewrite_user_facing_logs(result: Dictionary) -> void:
    var rewritten: Array[String] = []
    for value in result.get("logs", []):
        var line := str(value)
        line = line.replace(" · 준비]", " · 전조]")
        line = line.replace("태세와", "준비와")
        line = line.replace("태세를 가다듬어 다음 공격을 강화하고 [강건]을 얻었다.", "[준비]로 다음 비이동 행동을 강화했다.")
        rewritten.append(line)
    result["logs"] = rewritten
    _patch_bundle_state_event(result)

func _patch_bundle_state_event(result: Dictionary) -> void:
    var events: Array = result.get("presentation_events", [])
    for index in range(events.size()):
        if typeof(events[index]) != TYPE_DICTIONARY:
            continue
        var event: Dictionary = events[index]
        if str(event.get("type", "")) != "bundle_state":
            continue
        var final_state: Dictionary = result.get("state", {})
        event["player"] = (final_state.get("player", {}) as Dictionary).duplicate(true)
        event["enemy"] = (final_state.get("enemy", {}) as Dictionary).duplicate(true)
        event["logs"] = (result.get("logs", []) as Array).duplicate()
        events[index] = event
    result["presentation_events"] = events
