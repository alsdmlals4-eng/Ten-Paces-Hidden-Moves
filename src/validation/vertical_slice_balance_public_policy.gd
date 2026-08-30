class_name VerticalSliceBalancePublicPolicy
extends RefCounted

const POLICY_IDS: Array[String] = [
    "public_approach_pressure",
    "public_guarded_exchange",
    "public_recovery_range"
]


static func get_policy_ids() -> Array[String]:
    return POLICY_IDS.duplicate()


static func build_placements(
    policy_id: String,
    state: Dictionary,
    cards_by_id: Dictionary,
    player_martial_card_ids: PackedStringArray,
    bundle_index: int,
    timing_sequence: Array
) -> Array[Dictionary]:
    if policy_id not in POLICY_IDS:
        return []
    var snapshot := _public_snapshot(state)
    var bounds := _bundle_bounds(bundle_index, timing_sequence)
    if bounds.x > bounds.y:
        return []
    match policy_id:
        "public_approach_pressure":
            return _approach_pressure(snapshot, cards_by_id, player_martial_card_ids, bounds)
        "public_guarded_exchange":
            return _guarded_exchange(snapshot, cards_by_id, bounds)
        "public_recovery_range":
            return _recovery_range(snapshot, cards_by_id, player_martial_card_ids, bounds)
    return []


static func _approach_pressure(snapshot: Dictionary, cards_by_id: Dictionary, martial_ids: PackedStringArray, bounds: Vector2i) -> Array[Dictionary]:
    var distance := int(snapshot.get("distance", 0))
    var direction := int(snapshot.get("direction_to_enemy", 1))
    if distance > 2:
        var move := _choose_move(snapshot, cards_by_id)
        if not move.is_empty():
            return [_placement(move, snapshot, bounds.x, direction)]
    var martial := _first_reachable_martial_attack(snapshot, cards_by_id, martial_ids, bounds)
    if not martial.is_empty():
        return [_placement(martial, snapshot, bounds.x, direction)]
    for card_id in ["basic_heavy_attack", "basic_quick_attack", "basic_palm"]:
        var definition: Dictionary = (cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
        if _is_reachable_attack(snapshot, definition, bounds) and _can_afford(snapshot, definition):
            return [_placement(definition, snapshot, bounds.x, direction)]
    return []


static func _guarded_exchange(snapshot: Dictionary, cards_by_id: Dictionary, bounds: Vector2i) -> Array[Dictionary]:
    for card_id in ["basic_guard", "basic_evade"]:
        var definition: Dictionary = (cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
        if not definition.is_empty() and _fits_bundle(definition, bounds) and _can_afford(snapshot, definition):
            return [_placement(definition, snapshot, bounds.x, int(snapshot.get("direction_to_enemy", 1)))]
    var fallback: Dictionary = (cards_by_id.get("basic_meditate", {}) as Dictionary).duplicate(true)
    return [_placement(fallback, snapshot, bounds.x, int(snapshot.get("direction_to_enemy", 1)))] if not fallback.is_empty() else []


static func _recovery_range(snapshot: Dictionary, cards_by_id: Dictionary, martial_ids: PackedStringArray, bounds: Vector2i) -> Array[Dictionary]:
    var direction := int(snapshot.get("direction_to_enemy", 1))
    if _resources_below_maximum(snapshot):
        for card_id_value in martial_ids:
            var recovery: Dictionary = (cards_by_id.get(str(card_id_value), {}) as Dictionary).duplicate(true)
            if str(recovery.get("category", "")) == "recovery" and _fits_bundle(recovery, bounds) and _can_afford(snapshot, recovery):
                return [_placement(recovery, snapshot, bounds.x, direction)]
        var meditate: Dictionary = (cards_by_id.get("basic_meditate", {}) as Dictionary).duplicate(true)
        if not meditate.is_empty() and _fits_bundle(meditate, bounds):
            return [_placement(meditate, snapshot, bounds.x, direction)]
    for card_id_value in martial_ids:
        var martial: Dictionary = (cards_by_id.get(str(card_id_value), {}) as Dictionary).duplicate(true)
        if _is_reachable_attack(snapshot, martial, bounds) and _can_afford(snapshot, martial):
            return [_placement(martial, snapshot, bounds.x, direction)]
    var palm: Dictionary = (cards_by_id.get("basic_palm", {}) as Dictionary).duplicate(true)
    if _is_reachable_attack(snapshot, palm, bounds) and _can_afford(snapshot, palm):
        return [_placement(palm, snapshot, bounds.x, direction)]
    var move := _choose_move(snapshot, cards_by_id)
    return [_placement(move, snapshot, bounds.x, direction)] if not move.is_empty() else []


static func _first_reachable_martial_attack(snapshot: Dictionary, cards_by_id: Dictionary, martial_ids: PackedStringArray, bounds: Vector2i) -> Dictionary:
    var sorted_ids: Array[String] = []
    for card_id_value in martial_ids:
        sorted_ids.append(str(card_id_value))
    sorted_ids.sort()
    for card_id in sorted_ids:
        var definition: Dictionary = (cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
        if _is_reachable_attack(snapshot, definition, bounds) and _can_afford(snapshot, definition):
            return definition
    return {}


static func _choose_move(snapshot: Dictionary, cards_by_id: Dictionary) -> Dictionary:
    var footwork: Dictionary = (cards_by_id.get("basic_footwork", {}) as Dictionary).duplicate(true)
    if not footwork.is_empty() and _can_afford(snapshot, footwork):
        return footwork
    var move: Dictionary = (cards_by_id.get("basic_move", {}) as Dictionary).duplicate(true)
    return move if _can_afford(snapshot, move) else {}


static func _public_snapshot(state: Dictionary) -> Dictionary:
    var player: Dictionary = state.get("player", {})
    var enemy: Dictionary = state.get("enemy", {})
    var player_tile := int(player.get("tile", state.get("player_tile", 4)))
    var enemy_tile := int(enemy.get("tile", state.get("enemy_tile", 6)))
    if state.has("player_tile"):
        player_tile = int(state.get("player_tile", player_tile))
    if state.has("enemy_tile"):
        enemy_tile = int(state.get("enemy_tile", enemy_tile))
    return {
        "player_tile": player_tile,
        "enemy_tile": enemy_tile,
        "distance": absi(enemy_tile - player_tile),
        "direction_to_enemy": 1 if enemy_tile >= player_tile else -1,
        "stamina": _resource_pair(player, "stamina"),
        "internal": _resource_pair(player, "internal"),
        "public_resolution_history": (state.get("public_resolution_history", []) as Array).duplicate(true)
    }


static func _resource_pair(actor: Dictionary, key: String) -> Array[int]:
    var value = actor.get(key, [0, 0])
    if (typeof(value) == TYPE_ARRAY or typeof(value) == TYPE_PACKED_INT32_ARRAY) and value.size() >= 2:
        return [int(value[0]), maxi(1, int(value[1]))]
    return [0, 1]


static func _resources_below_maximum(snapshot: Dictionary) -> bool:
    var stamina: Array = snapshot.get("stamina", [0, 1])
    var internal: Array = snapshot.get("internal", [0, 1])
    return int(stamina[0]) < int(stamina[1]) or int(internal[0]) < int(internal[1])


static func _can_afford(snapshot: Dictionary, definition: Dictionary) -> bool:
    var stamina: Array = snapshot.get("stamina", [0, 1])
    var internal: Array = snapshot.get("internal", [0, 1])
    return int(stamina[0]) >= int(definition.get("stamina_cost", 0)) and int(internal[0]) >= int(definition.get("internal_cost", 0))


static func _is_reachable_attack(snapshot: Dictionary, definition: Dictionary, bounds: Vector2i) -> bool:
    if definition.is_empty() or str(definition.get("category", "")) != "attack" or not _fits_bundle(definition, bounds):
        return false
    var range_value = definition.get("range", {})
    if typeof(range_value) != TYPE_DICTIONARY:
        return false
    var distance := int(snapshot.get("distance", 0))
    return distance >= int((range_value as Dictionary).get("min", 0)) and distance <= int((range_value as Dictionary).get("max", -1))


static func _fits_bundle(definition: Dictionary, bounds: Vector2i) -> bool:
    return maxi(1, int(definition.get("action_slots", 1))) <= bounds.y - bounds.x + 1


static func _bundle_bounds(bundle_index: int, sequence: Array) -> Vector2i:
    if bundle_index < 1 or bundle_index > sequence.size():
        return Vector2i(1, 0)
    var start := 1
    for index in range(bundle_index - 1):
        start += int(sequence[index])
    return Vector2i(start, start + int(sequence[bundle_index - 1]) - 1)


static func _placement(definition: Dictionary, snapshot: Dictionary, anchor_index: int, direction: int) -> Dictionary:
    var category := str(definition.get("category", ""))
    var player_tile := int(snapshot.get("player_tile", 4))
    var target_tile := 0
    var targeting_mode := str(definition.get("targeting_mode", "none"))
    if category == "move":
        var move_range := maxi(1, int(definition.get("move_range", 1)))
        target_tile = clampi(player_tile + direction * move_range, 1, 10)
        targeting_mode = "move_tile"
    elif category == "attack":
        targeting_mode = "attack_direction"
    return {
        "card_id": str(definition.get("id", "")),
        "definition": definition.duplicate(true),
        "anchor_index": anchor_index,
        "span": maxi(1, int(definition.get("action_slots", 1))),
        "targeting_mode": targeting_mode,
        "target_ready": true,
        "target_tile": target_tile,
        "direction": direction,
        "origin_tile": player_tile
    }
