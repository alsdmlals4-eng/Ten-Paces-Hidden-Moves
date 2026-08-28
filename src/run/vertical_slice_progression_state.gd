class_name VerticalSliceProgressionState
extends RefCounted

const STARTER_MASTERY := 3
const MAX_MASTERY := 10
const NEXT_STAR_COSTS := {
    4: 2,
    5: 3,
    6: 4,
    7: 5,
    8: 6,
    9: 8,
    10: 10
}
const DEFAULT_RESOURCES := {
    "health": [30, 30],
    "stamina": [5, 5],
    "internal": [4, 4]
}

var owned_manual_ids: Array[String] = []
var mastery_by_manual: Dictionary = {}
var training_by_manual: Dictionary = {}
var free_training_pool: int = 0
var player_resources: Dictionary = {}
var pending_duplicate_transfers: Array[Dictionary] = []


func reset() -> void:
    owned_manual_ids.clear()
    mastery_by_manual.clear()
    training_by_manual.clear()
    free_training_pool = 0
    player_resources = _normalize_resources(DEFAULT_RESOURCES)
    pending_duplicate_transfers.clear()


func initialize_from_setup(loadout, setup_mastery: Dictionary) -> bool:
    if typeof(loadout) != TYPE_ARRAY and typeof(loadout) != TYPE_PACKED_STRING_ARRAY:
        return false
    owned_manual_ids.clear()
    mastery_by_manual.clear()
    training_by_manual.clear()
    for value in loadout:
        var manual_id := str(value)
        if manual_id.is_empty() or manual_id in owned_manual_ids:
            return false
        var mastery := int(setup_mastery.get(manual_id, 0))
        if mastery < STARTER_MASTERY or mastery > MAX_MASTERY:
            return false
        owned_manual_ids.append(manual_id)
        mastery_by_manual[manual_id] = mastery
        training_by_manual[manual_id] = _minimum_training_for_mastery(mastery)
    player_resources = _normalize_resources(DEFAULT_RESOURCES)
    return not owned_manual_ids.is_empty()


func apply_reward_receipt(receipt: Dictionary) -> Dictionary:
    if receipt.is_empty():
        return {}
    var result := receipt.duplicate(true)
    var reward_type := str(receipt.get("reward_type", ""))
    match reward_type:
        "free_training":
            free_training_pool += maxi(0, int(receipt.get("free_training", 0)))
            result["application_status"] = "APPLIED"
        "focused_training":
            var manual_id := str(receipt.get("target_manual_id", ""))
            if manual_id.is_empty() or manual_id not in owned_manual_ids:
                return {}
            free_training_pool += maxi(0, int(receipt.get("free_training", 0)))
            _add_training(manual_id, maxi(0, int(receipt.get("focused_training", 0))))
            result["application_status"] = "APPLIED"
        "faction_transfer":
            var manual_id := str(receipt.get("manual_id", ""))
            var mastery := int(receipt.get("mastery", STARTER_MASTERY))
            if manual_id.is_empty():
                return {}
            if manual_id in owned_manual_ids:
                result["application_status"] = "PENDING_DUPLICATE_POLICY"
                pending_duplicate_transfers.append(result.duplicate(true))
            else:
                owned_manual_ids.append(manual_id)
                mastery_by_manual[manual_id] = clampi(mastery, STARTER_MASTERY, MAX_MASTERY)
                training_by_manual[manual_id] = _minimum_training_for_mastery(int(mastery_by_manual[manual_id]))
                result["application_status"] = "APPLIED"
        _:
            return {}
    return result


func add_focused_training(manual_id: String, amount: int) -> bool:
    if manual_id.is_empty() or manual_id not in owned_manual_ids or amount <= 0:
        return false
    _add_training(manual_id, amount)
    return true


func add_free_training(amount: int) -> bool:
    if amount <= 0:
        return false
    free_training_pool += amount
    return true


func apply_recovery(health_fraction: float, stamina_amount: int, internal_amount: int) -> Dictionary:
    var next := _normalize_resources(player_resources)
    var health: Array = next.get("health", [0, 0])
    var stamina: Array = next.get("stamina", [0, 0])
    var internal: Array = next.get("internal", [0, 0])
    var health_gain := int(round(float(int(health[1])) * health_fraction))
    health[0] = mini(int(health[1]), int(health[0]) + maxi(0, health_gain))
    stamina[0] = mini(int(stamina[1]), int(stamina[0]) + maxi(0, stamina_amount))
    internal[0] = mini(int(internal[1]), int(internal[0]) + maxi(0, internal_amount))
    next["health"] = health
    next["stamina"] = stamina
    next["internal"] = internal
    player_resources = next
    return get_player_resources()


func set_player_resources(resources: Dictionary) -> bool:
    if not _has_resource_pairs(resources):
        return false
    player_resources = _normalize_resources(resources)
    return true


func get_player_resources() -> Dictionary:
    return player_resources.duplicate(true)


func get_snapshot() -> Dictionary:
    return {
        "owned_manual_ids": owned_manual_ids.duplicate(),
        "mastery_by_manual": mastery_by_manual.duplicate(true),
        "training_by_manual": training_by_manual.duplicate(true),
        "free_training_pool": free_training_pool,
        "player_resources": get_player_resources(),
        "pending_duplicate_transfers": pending_duplicate_transfers.duplicate(true)
    }


func restore_snapshot(snapshot: Dictionary) -> bool:
    if snapshot.is_empty() or not _has_resource_pairs(snapshot.get("player_resources", {})):
        return false
    var next_owned = snapshot.get("owned_manual_ids", [])
    var next_mastery = snapshot.get("mastery_by_manual", {})
    var next_training = snapshot.get("training_by_manual", {})
    var next_pending = snapshot.get("pending_duplicate_transfers", [])
    if typeof(next_owned) != TYPE_ARRAY or typeof(next_mastery) != TYPE_DICTIONARY or typeof(next_training) != TYPE_DICTIONARY or typeof(next_pending) != TYPE_ARRAY:
        return false
    var next_owned_ids: Array[String] = []
    var next_seen := {}
    for value in next_owned:
        var manual_id := str(value)
        if manual_id.is_empty() or next_seen.has(manual_id):
            return false
        next_seen[manual_id] = true
        next_owned_ids.append(manual_id)
    for manual_id in next_owned_ids:
        if not next_mastery.has(manual_id) or not next_training.has(manual_id):
            return false
        var mastery := int(next_mastery.get(manual_id, 0))
        if mastery < STARTER_MASTERY or mastery > MAX_MASTERY or int(next_training.get(manual_id, -1)) < 0:
            return false
    var next_resources := _normalize_resources(snapshot.get("player_resources", {}))
    var next_free_training := maxi(0, int(snapshot.get("free_training_pool", 0)))
    # All values above have been validated before replacing any live run state.
    owned_manual_ids = next_owned_ids
    mastery_by_manual = (next_mastery as Dictionary).duplicate(true)
    training_by_manual = (next_training as Dictionary).duplicate(true)
    free_training_pool = next_free_training
    player_resources = next_resources
    pending_duplicate_transfers = (next_pending as Array).duplicate(true)
    return true


func _add_training(manual_id: String, amount: int) -> void:
    var invested := maxi(0, int(training_by_manual.get(manual_id, 0))) + amount
    training_by_manual[manual_id] = invested
    mastery_by_manual[manual_id] = _mastery_after_total_training(invested)


func _mastery_after_total_training(points: int) -> int:
    var mastery := STARTER_MASTERY
    var remaining := maxi(0, points)
    while mastery < MAX_MASTERY:
        var next_mastery := mastery + 1
        var cost := int(NEXT_STAR_COSTS.get(next_mastery, 999999))
        if remaining < cost:
            break
        remaining -= cost
        mastery = next_mastery
    return mastery


func _minimum_training_for_mastery(mastery: int) -> int:
    var total := 0
    for target in range(STARTER_MASTERY + 1, clampi(mastery, STARTER_MASTERY, MAX_MASTERY) + 1):
        total += int(NEXT_STAR_COSTS.get(target, 0))
    return total


func _has_resource_pairs(resources: Dictionary) -> bool:
    for key in ["health", "stamina", "internal"]:
        var pair = resources.get(key, null)
        if typeof(pair) != TYPE_ARRAY or pair.size() < 2:
            return false
    return true


func _normalize_resources(resources: Dictionary) -> Dictionary:
    var result := {}
    for key in ["health", "stamina", "internal"]:
        var fallback: Array = DEFAULT_RESOURCES.get(key, [0, 0]).duplicate()
        var source = resources.get(key, fallback)
        var current := int(fallback[0])
        var maximum := int(fallback[1])
        if typeof(source) == TYPE_ARRAY and source.size() >= 2:
            maximum = maxi(0, int(source[1]))
            current = clampi(int(source[0]), 0, maximum)
        result[key] = [current, maximum]
    return result
