extends SceneTree

const REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")
const PIPELINE_SCRIPT := preload("res://src/combat/martial_effect_pipeline.gd")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var registry = REGISTRY_SCRIPT.new()
    var pipeline = PIPELINE_SCRIPT.new()
    _assert(registry.is_valid(), "registry must be valid before pipeline verification")
    _verify_vajra_state_precedes_attack(registry, pipeline)
    _verify_returning_spear_rechecks_range(registry, pipeline)
    _verify_zixia_use_is_not_refunded(registry, pipeline)
    _verify_four_independent_projectiles(registry, pipeline)
    _verify_counter_before_movement(registry, pipeline)
    _verify_unknown_operation_is_atomic(pipeline)
    _finish()

func _verify_vajra_state_precedes_attack(registry, pipeline) -> void:
    var definition := _card(registry, "shaolin_arhat_vajra_art", 10, "shaolin_arhat_vajra_art_star10")
    var result: Dictionary = pipeline.execute(definition, _state(4, 5), "player", {"tile_count": 10})
    var ops := _event_ops(result)
    _assert(result.get("completed", false), "Vajra ultimate must complete in range")
    _assert(ops.size() >= 6, "Vajra ultimate must emit its ordered structural events")
    _assert(ops[0] == "GAIN_RESOURCE" and ops[1] == "GAIN_STATUS", "defense and fortitude must precede the attack")
    _assert(ops.find("START_DEFENSE_LOSS_RECORD") < ops.find("ATTACK"), "defense-loss recording must start before attack")
    var player: Dictionary = (result.get("state", {}) as Dictionary).get("player", {})
    _assert(int(player.get("defense", 0)) == 4, "Vajra ultimate must create defense before striking")
    _assert(_status_count(player, "fortitude") == 1, "Vajra ultimate must create one limited fortitude stack")

func _verify_returning_spear_rechecks_range(registry, pipeline) -> void:
    var definition := _card(registry, "yang_family_spear", 10, "yang_family_spear_star10")
    var result: Dictionary = pipeline.execute(definition, _state(4, 5), "player", {"tile_count": 10})
    var attack_events := _events_with_op(result, "ATTACK")
    _assert(attack_events.size() == 2, "Returning Spear must attempt two attacks")
    _assert(str((attack_events[0] as Dictionary).get("status", "")) == "HIT", "first spear attack must hit")
    _assert(str((attack_events[1] as Dictionary).get("status", "")) == "SKIPPED_OUT_OF_RANGE", "second spear attack must not ignore range after retreat")
    _assert(_event_ops(result) == PackedStringArray(["ATTACK", "MOVE_AWAY", "RECHECK_RANGE", "ATTACK"]), "Returning Spear operation order must be fixed")

func _verify_zixia_use_is_not_refunded(registry, pipeline) -> void:
    var definition := _card(registry, "mount_hua_purple_mist_art", 10, "mount_hua_purple_mist_art_star10")
    var state := _state(4, 5)
    var player: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
    player["internal"] = [0, 4]
    player["stamina"] = [0, 5]
    player["momentum"] = [0, 5]
    player["battle_uses"] = {"purple_mist_ultimate": true}
    state["player"] = player
    var result: Dictionary = pipeline.execute(definition, state, "player", {"tile_count": 10, "interrupt_after_step": 2})
    player = (result.get("state", {}) as Dictionary).get("player", {})
    _assert(not bool((player.get("battle_uses", {}) as Dictionary).get("purple_mist_ultimate", true)), "Zixia use right must remain consumed after interruption")
    _assert(not bool(result.get("completed", true)), "interrupted Zixia must not complete")
    _assert(_resource_current(player, "momentum") == 0, "interrupted Zixia must not gain completion momentum")

func _verify_four_independent_projectiles(registry, pipeline) -> void:
    var definition := _card(registry, "sichuan_tang_hidden_weapons", 10, "sichuan_tang_hidden_weapons_star10")
    var result: Dictionary = pipeline.execute(definition, _state(3, 6), "player", {"tile_count": 10})
    var attacks := _events_with_op(result, "INDEPENDENT_ATTACK")
    _assert(attacks.size() == 4, "Myriad Heavens Rain must resolve exactly four deterministic independent attacks")
    _assert(int(result.get("actual_hp_hits", 0)) == 4, "all four in-range projectiles must record separate health hits")

func _verify_counter_before_movement(registry, pipeline) -> void:
    var definition := _card(registry, "xiaoyao_lingbo_footwork", 10, "xiaoyao_lingbo_footwork_star10")
    var result: Dictionary = pipeline.execute(definition, _state(4, 5), "player", {"tile_count": 10, "evade_succeeded": true})
    var ops := _event_ops(result)
    _assert(ops.find("ATTACK") < ops.find("MOVE_AWAY"), "Lingbo counter must resolve before retreat")
    var player: Dictionary = (result.get("state", {}) as Dictionary).get("player", {})
    _assert(int(player.get("tile", 0)) == 1, "Lingbo retreat must move up to three legal tiles away")
    _assert(_status_count(player, "prepared") == 1, "Lingbo completion must grant prepared")

func _verify_unknown_operation_is_atomic(pipeline) -> void:
    var state := _state(4, 5)
    var before := JSON.stringify(state)
    var definition := {
        "id": "invalid_runtime_card",
        "effect_steps": [
            {"op": "GAIN_RESOURCE", "resource": "defense", "amount": 9},
            {"op": "UNKNOWN_EFFECT_OP"}
        ]
    }
    var result: Dictionary = pipeline.execute(definition, state, "player", {"tile_count": 10})
    _assert(not bool(result.get("completed", true)), "unknown effect operation must fail")
    _assert(str(result.get("failure_reason", "")) == "UNKNOWN_EFFECT_OP", "unknown effect operation must use stable reason code")
    _assert(JSON.stringify(state) == before, "pipeline must never mutate caller-owned state")
    _assert(JSON.stringify(result.get("state", {})) == before, "unknown operation must return the unmodified state snapshot")

func _card(registry, manual_id: String, mastery: int, card_id: String) -> Dictionary:
    for value in registry.build_unlocked_cards(manual_id, mastery):
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("id", "")) == card_id:
            return value as Dictionary
    failures.append("missing runtime card: %s" % card_id)
    return {}

func _state(player_tile: int, enemy_tile: int) -> Dictionary:
    return {
        "player": _actor("플레이어", player_tile),
        "enemy": _actor("상대", enemy_tile)
    }

func _actor(label: String, tile: int) -> Dictionary:
    return {
        "label": label,
        "tile": tile,
        "health": [30, 30],
        "stamina": [5, 5],
        "internal": [4, 4],
        "momentum": [0, 5],
        "defense": 0,
        "status_counts": {},
        "battle_uses": {},
        "stats": {"외공": 5, "근골": 5, "신법": 5, "내공": 5, "심안": 5}
    }

func _event_ops(result: Dictionary) -> PackedStringArray:
    var ops := PackedStringArray()
    for value in result.get("events", []):
        if typeof(value) == TYPE_DICTIONARY:
            ops.append(str((value as Dictionary).get("op", "")))
    return ops

func _events_with_op(result: Dictionary, op: String) -> Array:
    var events: Array = []
    for value in result.get("events", []):
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("op", "")) == op:
            events.append(value)
    return events

func _resource_current(actor: Dictionary, key: String) -> int:
    var value = actor.get(key, [0, 0])
    return int(value[0]) if typeof(value) == TYPE_ARRAY and value.size() >= 1 else int(value)

func _status_count(actor: Dictionary, status: String) -> int:
    return int((actor.get("status_counts", {}) as Dictionary).get(status, 0))

func _assert(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _finish() -> void:
    if failures.is_empty():
        print("MARTIAL_EFFECT_PIPELINE_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("MARTIAL_EFFECT_PIPELINE_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
