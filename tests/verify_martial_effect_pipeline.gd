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
    _verify_actual_stat_boundary(pipeline)
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
        "stats": {"external": 5, "constitution": 5, "agility": 5, "internal_power": 5, "insight": 5}
    }

func _verify_actual_stat_boundary(pipeline) -> void:
    var engine = preload("res://src/combat/combat_resolution_engine_ten_manuals.gd").new()
    var state: Dictionary = engine.make_initial_state(_state(4, 5), 4, 5)
    state.player.stats = {"external": 1, "constitution": 4, "agility": 7, "internal_power": 4, "insight": 15}
    state.enemy.stats = {"external": 15, "constitution": 7, "agility": 4, "internal_power": 1, "insight": 9}
    for actor in ["player", "enemy"]:
        for pair in [["외공", "external"], ["근골", "constitution"], ["신법", "agility"], ["내공", "internal_power"], ["심안", "insight"]]:
            for reference in pair:
                var definition := {"effect_steps": [{"op": "SPECIAL_CLASH", "power": 8, "stat": reference, "coefficient": 1.0}]}
                var result: Dictionary = pipeline.execute(definition, state, actor)
                _assert(result.completed and result.events[0].power == 8 + state[actor].stats[pair[1]], "Actual canonical stat " + actor + " " + reference)
    for value in [1, 4, 15]:
        state.player.stats.internal_power = value
        var result: Dictionary = pipeline.execute({"effect_steps": [{"op": "SPECIAL_CLASH", "power": 8, "stat": "내공", "coefficient": 1.0}]}, state, "player")
        _assert(result.completed and result.events[0].power == {1: 9, 4: 12, 15: 23}[value], "Authored internal scaling boundary " + str(value))
    var fractional: Dictionary = pipeline.execute({"effect_steps": [{"op": "SPECIAL_CLASH", "power": 8, "stat": "내공", "coefficient": 0.25}]}, state, "player")
    _assert(fractional.completed and fractional.events[0].power == 11, "Fractional contribution is floored")
    var fixed: Dictionary = pipeline.execute({"effect_steps": [{"op": "SPECIAL_CLASH", "power": 8, "stat": "", "coefficient": 0}]}, state, "player")
    _assert(fixed.completed and fixed.events[0].power == 8, "Fixed-only clash accepts empty zero reference")
    var cases := [{"stat": "unknown", "coefficient": 1}, {"stat": "", "coefficient": 1}, {"stat": false, "coefficient": 0}, {"stat": 4, "coefficient": 0}]
    for coefficient in ["1", true, INF, NAN]: cases.append({"stat": "내공", "coefficient": coefficient})
    for entry in cases:
        var step: Dictionary = entry.duplicate(true)
        step.merge({"op": "SPECIAL_CLASH", "power": 8, "condition": "CLASH_WIN"})
        _invalid_stat_atomic(pipeline, state, step, "bad reference or coefficient " + str(entry))
    for value in [null, "4", true, INF, NAN]:
        var invalid := state.duplicate(true)
        if value == null: invalid.player.stats.erase("internal_power")
        else: invalid.player.stats.internal_power = value
        _invalid_stat_atomic(pipeline, invalid, {"op": "SPECIAL_CLASH", "power": 8, "stat": "내공", "coefficient": 1}, "absent or invalid canonical stat " + str(value))
    var invalid := state.duplicate(true)
    invalid.player.stats = []
    _invalid_stat_atomic(pipeline, invalid, {"op": "SPECIAL_CLASH", "stat": "내공", "coefficient": 1}, "non-dictionary stats")

func _invalid_stat_atomic(pipeline, state: Dictionary, step: Dictionary, label: String) -> void:
    # Variant bytes preserve invalid numeric values without coercing NaN to JSON null.
    var before := var_to_bytes(state)
    var result: Dictionary = pipeline.execute({"effect_steps": [{"op": "GAIN_RESOURCE", "resource": "defense", "amount": 9}, step]}, state, "player")
    _assert(not result.completed and result.failure_reason == "INVALID_STAT_REFERENCE", "Invalid stat fails closed: " + label)
    _assert(result.events.is_empty(), "Invalid stat emits no applied events: " + label)
    _assert(var_to_bytes(state) == before and var_to_bytes(result.state) == before, "Invalid stat preserves input/output: " + label)

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
