class_name TenManualCombatResolutionEngine
extends "res://src/combat/combat_resolution_engine_prepare.gd"

const MartialManualRegistryScript := preload("res://src/combat/martial_manual_registry.gd")
const MartialEffectPipelineScript := preload("res://src/combat/martial_effect_pipeline.gd")

var martial_registry: MartialManualRegistry
var martial_effect_pipeline: MartialEffectPipeline
var _loaded_martial_card_ids := PackedStringArray()
var _loaded_player_martial_card_ids := PackedStringArray()
var _loaded_enemy_martial_card_ids := PackedStringArray()
var _player_martial_cards: Dictionary = {}
var _enemy_martial_cards: Dictionary = {}

func _init() -> void:
    super()
    martial_registry = MartialManualRegistryScript.new()
    martial_effect_pipeline = MartialEffectPipelineScript.new()

func configure_martial_loadout(loadout: Array, mastery_by_manual: Dictionary) -> bool:
    return configure_martial_loadouts(loadout, mastery_by_manual, [], {})

func configure_martial_loadouts(player_loadout: Array, player_mastery_by_manual: Dictionary, enemy_loadout: Array = [], enemy_mastery_by_manual: Dictionary = {}) -> bool:
    var player_cards := _build_normalized_loadout_cards(player_loadout, player_mastery_by_manual)
    var enemy_cards := _build_normalized_loadout_cards(enemy_loadout, enemy_mastery_by_manual)
    if not _locked_enemy_bundle_key.is_empty() or not _locked_enemy_actions.is_empty():
        return player_cards == _player_martial_cards and enemy_cards == _enemy_martial_cards
    _remove_loaded_martial_cards()
    _player_martial_cards = player_cards
    _enemy_martial_cards = enemy_cards
    # Compatibility discovery union only; player wins a shared ID. Execution is actor-bound.
    _loaded_enemy_martial_card_ids = _register_loadout_cards(enemy_cards)
    _loaded_player_martial_card_ids = _register_loadout_cards(player_cards)
    var union := PackedStringArray()
    for card_id in _loaded_player_martial_card_ids:
        if card_id not in union:
            union.append(card_id)
    for card_id in _loaded_enemy_martial_card_ids:
        if card_id not in union:
            union.append(card_id)
    union.sort()
    _loaded_martial_card_ids = union
    return true

func get_actor_card_definition(card_id: String, actor_key: String) -> Dictionary:
    if actor_key not in ["player", "enemy"]:
        return {}
    var owned := _player_martial_cards if actor_key == "player" else _enemy_martial_cards
    if owned.has(card_id):
        return (owned[card_id] as Dictionary).duplicate(true)
    if _is_martial_card_id(card_id):
        return {}
    return super.get_actor_card_definition(card_id, actor_key)

func get_actor_cards_by_id(actor_key: String) -> Dictionary:
    if actor_key not in ["player", "enemy"]:
        return {}
    var result := {}
    for id in cards_by_id:
        if not _is_martial_card_id(str(id)):
            result[id] = (cards_by_id[id] as Dictionary).duplicate(true)
    result.merge((_player_martial_cards if actor_key == "player" else _enemy_martial_cards).duplicate(true), true)
    return result

func _is_martial_card_id(card_id: String) -> bool:
    if _player_martial_cards.has(card_id) or _enemy_martial_cards.has(card_id):
        return true
    for manual in martial_registry.manuals.values():
        for card in manual.get("cards", {}).values():
            if card.get("id", "") == card_id:
                return true
    return false

func _martial_plan_rejection(placements: Array, state: Dictionary) -> Dictionary:
    var invalid := PackedInt32Array()
    for value in placements:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var placement: Dictionary = value
        var supplied = placement.get("definition", {})
        var definition_id := str(supplied.get("id", "")) if typeof(supplied) == TYPE_DICTIONARY else ""
        var card_id := str(placement.get("card_id", definition_id))
        if not _is_martial_card_id(card_id) and not _is_martial_card_id(definition_id):
            continue
        if get_actor_card_definition(card_id, "player").is_empty() or typeof(supplied) != TYPE_DICTIONARY or (supplied.has("id") and (typeof(supplied.id) != TYPE_STRING or card_id != definition_id)):
            invalid.append(int(placement.get("anchor_index", 1)))
    if invalid.is_empty():
        return {}
    return {"valid": false, "failure_reason": "MARTIAL_ACTOR_DEFINITION_MISMATCH", "invalid_anchors": invalid, "state": state.duplicate(true), "events": [], "resolved_actions": [], "logs": [], "presentation_events": []}

func preview_player_plan(state_value: Dictionary, placements: Array) -> Dictionary:
    var rejection := _martial_plan_rejection(placements, state_value)
    return rejection if not rejection.is_empty() else super.preview_player_plan(state_value, placements)

func resolve_bundle(player_placements: Array, context: Dictionary, state_value: Dictionary) -> Dictionary:
    var rejection := _martial_plan_rejection(player_placements, state_value)
    if not rejection.is_empty():
        rejection["rejected"] = true
        return rejection
    return super.resolve_bundle(player_placements, context, state_value)

func _canonical_actor_placements(placements: Array, actor_key: String) -> Array:
    var result := placements.duplicate(true)
    for placement in result:
        if typeof(placement) != TYPE_DICTIONARY:
            continue
        var supplied = placement.get("definition", {})
        var definition_id := str(supplied.get("id", "")) if typeof(supplied) == TYPE_DICTIONARY else ""
        var card_id := str(placement.get("card_id", definition_id))
        if _is_martial_card_id(card_id):
            var canonical := get_actor_card_definition(card_id, actor_key)
            placement["definition"] = canonical
            placement["span"] = int(canonical.get("action_slots", 1))
    return result

func _build_player_actions(placements: Array) -> Array:
    return super._build_player_actions(_canonical_actor_placements(placements, "player"))

func _placement_attempts(placements: Array, actor_key: String) -> Array:
    return super._placement_attempts(_canonical_actor_placements(placements, actor_key), actor_key)

func resolve_martial_card(card_id: String, state: Dictionary, actor_key: String, context: Dictionary = {}) -> Dictionary:
    var definition := get_actor_card_definition(card_id, actor_key)
    if definition.is_empty():
        return _martial_failure(state, "MARTIAL_CARD_NOT_LOADED")
    if str(definition.get("source", "")) != "martial_manual":
        return _martial_failure(state, "NOT_A_MARTIAL_CARD")
    return martial_effect_pipeline.execute(definition.duplicate(true), state, actor_key, context)

func get_loaded_martial_card_ids() -> PackedStringArray:
    return _loaded_martial_card_ids.duplicate()

func get_player_martial_card_ids() -> PackedStringArray:
    return _loaded_player_martial_card_ids.duplicate()

func get_enemy_martial_card_ids() -> PackedStringArray:
    return _loaded_enemy_martial_card_ids.duplicate()

func get_enemy_ai_cards_by_id() -> Dictionary:
    return get_actor_cards_by_id("enemy")

func _build_enemy_actions(bundle_index: int, state: Dictionary = {}) -> Array:
    var result: Array = []
    var bundles: Dictionary = rules.get("enemy_bundles", {})
    var plan: Array = bundles.get(str(bundle_index), [])
    if plan.is_empty() and bool(state.get("ai_enabled", false)) and str(rules.get("enemy_plan_source", "fixture")) == "public_state_ai" and ai_planner != null:
        plan = ai_planner.build_bundle_actions(state, bundle_index, get_enemy_ai_cards_by_id())
    for value in plan:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var entry: Dictionary = value
        var card_id := str(entry.get("card_id", ""))
        var definition := get_actor_card_definition(card_id, "enemy")
        if definition.is_empty():
            continue
        var anchor := int(entry.get("timing", 1))
        var span := maxi(1, int(definition.get("action_slots", 1)))
        var action_types: Array = []
        if typeof(entry.get("action_types", [])) == TYPE_ARRAY:
            for action_type in entry.get("action_types", []):
                action_types.append(str(action_type))
        if str(definition.get("source", "")) == "ultimate" or str(definition.get("source_kind", "")) == "ultimate":
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
            "targeting_mode": str(entry.get("targeting_mode", definition.get("targeting_mode", "none"))),
            "target_ready": true,
            "target_tile": int(entry.get("target_tile", 0)),
            "direction": clampi(int(entry.get("direction", -1)), -1, 1),
            "origin_tile": 0,
            "ai_reason": str(entry.get("ai_reason", "fixture")),
            "ai_seed": int(entry.get("ai_seed", state.get("ai_decision_seed", 0))),
            "action_types": action_types
        })
    return result

func _execute_attack_phase(state: Dictionary, actions: Array, defenses: Dictionary, logs: Array[String], timing: int, phase_label: String, resolved_actions: Array, all_actions: Array, deferred_attacks: Array = []) -> void:
    if actions.is_empty():
        return
    var regular_actions: Array = []
    for action_value in actions:
        var action: Dictionary = action_value
        var definition: Dictionary = action.get("definition", {})
        if str(definition.get("source", "")) != "martial_manual":
            regular_actions.append(action)
            continue
        if bool(action.get("cancelled", false)):
            resolved_actions.append(_resolved_record(action, timing, "interrupted"))
            continue
        if not _pay_action_cost(state, action, logs, timing):
            continue
        action["executed"] = true
        _execute_martial_program(state, action, logs, timing, phase_label, resolved_actions, all_actions)
    if not regular_actions.is_empty():
        super._execute_attack_phase(state, regular_actions, defenses, logs, timing, phase_label, resolved_actions, all_actions, deferred_attacks)

func _execute_utility(state: Dictionary, action: Dictionary, logs: Array[String], timing: int) -> void:
    var definition: Dictionary = action.get("definition", {})
    if str(definition.get("source", "")) != "martial_manual":
        super._execute_utility(state, action, logs, timing)
        return
    var result := _run_martial_pipeline(state, action, timing, [])
    action["martial_result"] = result.duplicate(true)
    logs.append(_martial_log_line(action, result, timing, "일반"))

func _resolved_record(action: Dictionary, timing: int, outcome: String) -> Dictionary:
    var record := super._resolved_record(action, timing, outcome)
    if action.has("martial_result"):
        var result: Dictionary = action.get("martial_result", {})
        record["outcome"] = "martial_completed" if bool(result.get("completed", false)) else "martial_failed"
        record["failure_reason"] = str(result.get("failure_reason", ""))
        record["martial_events"] = (result.get("events", []) as Array).duplicate(true)
        record["actual_hp_hits"] = int(result.get("actual_hp_hits", 0))
        record["clash_won"] = bool(result.get("clash_won", false))
        record["evade_succeeded"] = bool(result.get("evade_succeeded", false))
    return record

func _execute_martial_program(state: Dictionary, action: Dictionary, logs: Array[String], timing: int, phase_label: String, resolved_actions: Array, all_actions: Array) -> void:
    var actor_key := str(action.get("actor", "player"))
    var target_key := _other_actor(actor_key)
    var target_before: Dictionary = state.get(target_key, {})
    var health_before := _resource_pair(target_before, "health").x
    var result := _run_martial_pipeline(state, action, timing, all_actions)
    action["martial_result"] = result.duplicate(true)
    var record := _resolved_record(action, timing, "martial_completed" if bool(result.get("completed", false)) else "martial_failed")
    var target_after: Dictionary = state.get(target_key, {})
    var health_after := _resource_pair(target_after, "health").x
    record["target"] = target_key
    record["damage"] = maxi(0, health_before - health_after)
    record["damage_after_block"] = int(record.get("damage", 0))
    record["defense_outcome"] = "martial_pipeline"
    resolved_actions.append(record)
    logs.append(_martial_log_line(action, result, timing, phase_label))
    var damage := maxi(0, health_before - health_after)
    if damage > 0:
        var pending_damage := {"player": 0, "enemy": 0}
        pending_damage[target_key] = damage
        _apply_interruption_after_damage(state, all_actions, pending_damage, timing, phase_label, logs)
    if bool(result.get("clash_won", false)):
        for other_value in all_actions:
            var other: Dictionary = other_value
            if str(other.get("actor", "")) == actor_key or int(other.get("execution_timing", 0)) != timing or bool(other.get("executed", false)):
                continue
            other["cancelled"] = true
            other["interrupt_reason"] = "martial_clash_loss"

func _run_martial_pipeline(state: Dictionary, action: Dictionary, timing: int, all_actions: Array) -> Dictionary:
    var actor_key := str(action.get("actor", "player"))
    var definition: Dictionary = action.get("definition", {})
    var context := {
        "tile_count": maxi(1, int(rules.get("tile_count", 10))),
        "timing": timing,
        "opponent_clash_power": _opponent_clash_power(action, all_actions)
    }
    var result := resolve_martial_card(str(definition.get("id", "")), state, actor_key, context)
    var next_state: Dictionary = result.get("state", state)
    state.clear()
    state.merge(next_state.duplicate(true), true)
    return result

func _opponent_clash_power(action: Dictionary, all_actions: Array) -> int:
    var actor_key := str(action.get("actor", "player"))
    var timing := int(action.get("execution_timing", 0))
    for other_value in all_actions:
        var other: Dictionary = other_value
        if str(other.get("actor", "")) == actor_key or int(other.get("execution_timing", 0)) != timing or bool(other.get("cancelled", false)):
            continue
        var definition: Dictionary = other.get("definition", {})
        var power := maxi(0, int(str(definition.get("damage", "0"))))
        if str(definition.get("source", "")) == "ultimate":
            power += 8
        return power
    return 0

func _martial_log_line(action: Dictionary, result: Dictionary, timing: int, phase_label: String) -> String:
    var definition: Dictionary = action.get("definition", {})
    var actor_key := str(action.get("actor", "player"))
    var status := "완료" if bool(result.get("completed", false)) else "실패:%s" % str(result.get("failure_reason", "UNKNOWN"))
    return "[%d수 · %s · 무공] %s의 %s 프로그램 %s." % [timing, phase_label, actor_key, str(definition.get("name", "무공")), status]

func _build_normalized_loadout_cards(loadout: Array, mastery_by_manual: Dictionary) -> Dictionary:
    var unlocked: Dictionary = martial_registry.build_loadout_cards(loadout, mastery_by_manual)
    var result: Dictionary = {}
    for card_key in unlocked.keys():
        var card_id := str(card_key)
        var card: Dictionary = unlocked.get(card_key, {})
        card = card.duplicate(true)
        card["source"] = "martial_manual"
        card["source_kind"] = "ultimate" if int(card.get("unlock_star", 0)) >= 10 else "martial"
        if not card.has("targeting_mode"):
            card["targeting_mode"] = "none"
        if not card.has("category"):
            card["category"] = "attack" if _has_attack_step(card) else "utility"
        card["range_text"] = _range_text(card)
        if int(card.get("unlock_star", 0)) >= 10:
            card["momentum_cost"] = maxi(0, int(card.get("momentum_cost", 5)))
        result[card_id] = card
    return result

func _register_loadout_cards(values: Dictionary) -> PackedStringArray:
    var ids := PackedStringArray()
    for card_key in values.keys():
        var card_id := str(card_key)
        cards_by_id[card_id] = (values.get(card_key, {}) as Dictionary).duplicate(true)
        ids.append(card_id)
    ids.sort()
    return ids

func _has_attack_step(card: Dictionary) -> bool:
    for value in card.get("effect_steps", []):
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("op", "")) in ["ATTACK", "INDEPENDENT_ATTACK", "SPECIAL_CLASH"]:
            return true
    return false

func _range_text(card: Dictionary) -> String:
    var value = card.get("range", {})
    if typeof(value) != TYPE_DICTIONARY:
        return "-"
    var range_data: Dictionary = value
    var minimum := int(range_data.get("min", 0))
    var maximum := int(range_data.get("max", minimum))
    return str(minimum) if minimum == maximum else "%d~%d" % [minimum, maximum]

func _martial_failure(state: Dictionary, reason: String) -> Dictionary:
    return {
        "state": state.duplicate(true),
        "events": [],
        "completed": false,
        "failure_reason": reason,
        "actual_hp_hits": 0,
        "clash_won": false,
        "evade_succeeded": false
    }

func _remove_loaded_martial_cards() -> void:
    for card_id in _loaded_martial_card_ids:
        cards_by_id.erase(str(card_id))
    _loaded_martial_card_ids = PackedStringArray()
    _loaded_player_martial_card_ids = PackedStringArray()
    _loaded_enemy_martial_card_ids = PackedStringArray()
    _player_martial_cards.clear()
    _enemy_martial_cards.clear()
