class_name GiyunRules
extends RefCounted

const DATA_PATH := "res://data/run/giyun_rules.json"
var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))

func initial() -> Dictionary:
    return {"version": 1, "owned": [], "pending_event": {}}

func index_for(seed_value: int, duel: int, step: int, salt: String, count: int) -> int:
    var key := "%d:%d:%d:%s" % [seed_value, duel, step, salt]
    return int(key.sha256_text().substr(0, 7).hex_to_int()) % count

func options(seed_value: int, duel: int, step: int) -> Array:
    if duel < 1 or duel >= 10 or step < 0 or step >= 4: return []
    var omitted := index_for(seed_value, duel, step, "activity", 3)
    var result: Array = []
    for i in range(4):
        if i != omitted: result.append(catalog.activities[i].duplicate(true))
    return result

func event_for(seed_value: int, duel: int, step: int) -> Dictionary:
    return catalog.events[index_for(seed_value, duel, step, "event", catalog.events.size())].duplicate(true)

func definition(id: String) -> Dictionary:
    for item in catalog.giyun:
        if item.id == id: return item.duplicate(true)
    return {}

func valid_owned(ids) -> bool:
    if typeof(ids) != TYPE_ARRAY or ids.size() > catalog.giyun.size(): return false
    var seen := {}
    for id in ids:
        if typeof(id) != TYPE_STRING or seen.has(id) or definition(id).is_empty(): return false
        seen[id] = true
    return true

func event_options(event: Dictionary, owned: Array, health: int) -> Array:
    var result: Array = []
    var item := definition(str(event.giyun_id))
    for choice in event.choices:
        var effect := "자유 수련 +2" if choice.id == "study" else "기력 +1"
        if choice.id == "accept":
            effect = "체력 -%d · %s" % [event.health_cost, "이미 보유: 자유 수련 +3" if event.giyun_id in owned else item.name+" 획득 · "+item.description]
        result.append({"id": "event."+choice.id, "label": choice.label, "effect": effect,
            "disabled": choice.id == "accept" and health <= int(event.health_cost)})
    return result

func resolve_event(event: Dictionary, choice: String, owned: Array) -> Dictionary:
    if choice not in ["accept", "study", "leave"]: return {}
    var result := {"choice": choice, "event_id": event.id, "training": 0, "health_cost": 0, "stamina": 0, "giyun_id": ""}
    if choice == "accept":
        result.health_cost = int(event.health_cost)
        if event.giyun_id in owned: result.training = 3
        else: result.giyun_id = event.giyun_id
    elif choice == "study": result.training = 2
    else: result.stamina = 1
    return result

func apply_bundle(owned: Array, before: Dictionary, result: Dictionary) -> void:
    if owned.is_empty() or result.get("rejected", false): return
    var player: Dictionary = result.state.player
    if int(player.health[0]) <= 0: return
    var hits := 0
    var hurt := false
    var flags := {"evade": false, "block": false, "clash": false}
    # Read the engine's resolved events once; emitted benefits never feed this pass.
    for action in result.get("resolved_actions", []):
        # Basic clashes copy the same damage onto both records. Only the winner
        # describes the attack that actually reached a defender.
        if action.get("outcome") in ["clash_loss", "clash_draw"]: continue
        if action.get("actor") == "player":
            hits += int(action.get("actual_hp_hits", 1 if int(action.get("damage", 0)) > 0 else 0))
            if action.get("outcome") == "clash_win" or action.get("clash_won", false): flags.clash = true
            if action.get("evade_succeeded", false): flags.evade = true
        elif action.get("actor") == "enemy":
            hurt = hurt or int(action.get("damage", 0)) > 0
            if action.get("defense_outcome") == "evade" and (not str(action.get("outcome", "")).begins_with("clash_") or action.get("outcome") == "clash_win"): flags.evade = true
            if action.get("defense_outcome") in ["block", "sure_hit_block"] and int(action.get("clash_difference", action.get("raw_damage", 0))) > int(action.get("damage_after_block", 0)): flags.block = true
            for event in action.get("martial_events", []):
                if event.get("status") in ["HIT", "BLOCKED"] and int(event.get("raw_power", 0)) > int(event.get("health_damage", 0)) and int(event.get("defense", 0)) > 0: flags.block = true
    flags["chain"] = hits >= 2
    flags["clean_hit"] = hits > 0 and not hurt and int(player.health[0]) >= int(before.player.health[0])
    flags["low_health_hit"] = hits > 0 and int(player.health[0]) * 2 <= int(player.health[1])
    for item in catalog.giyun:
        if item.id not in owned or not flags.get(item.trigger, false): continue
        var resource: String = item.resource
        var amount := int(item.amount)
        var gained := 0
        if resource == "next_attack_bonus":
            resource = "giyun_attack_bonus"
            var old := int(player.get(resource, 0))
            player[resource] = maxi(old, mini(old + amount, int(item.next_attack_cap)))
            gained = int(player[resource]) - old
        else:
            var pair = player[resource]
            gained = mini(amount, int(pair[1]) - int(pair[0]))
            pair[0] += gained
        if gained > 0:
            result.logs.append("[기연 · %s] %s · 실제 +%d" % [item.name, item.description, gained])
    result.state.player = player
