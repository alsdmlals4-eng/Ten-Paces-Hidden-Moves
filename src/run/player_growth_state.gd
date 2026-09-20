class_name PlayerGrowthState
extends RefCounted

# Pure projection. Mastery is verified by the run's ordered progression ledger.
# No persisted bonus accumulator and no load-time grant side effects.
const RULES_PATH := "res://data/run/player_growth_rules.json"
const REGISTRY := preload("res://src/combat/martial_manual_registry.gd")
const KEYS := ["external", "constitution", "agility", "internal_power", "insight"]
var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES_PATH))
var registry = REGISTRY.new()

static func whole(value, minimum: int, maximum: int) -> bool:
    return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and value == floor(float(value)) and value >= minimum and value <= maximum

func valid_allocation(value, allow_unspent: bool = false) -> bool:
    if typeof(value) != TYPE_DICTIONARY or value.size() != KEYS.size(): return false
    var total := 0
    for key in KEYS:
        if not whole(value.get(key), 0, int(rules.free_per_stat_max)): return false
        total += int(value[key])
    return total <= int(rules.free_points) if allow_unspent else total == int(rules.free_points)

static func valid_stats(value) -> bool:
    if typeof(value) != TYPE_DICTIONARY or value.size() != KEYS.size(): return false
    for key in KEYS:
        if not whole(value.get(key), 1, 9007199254740991): return false
    return true

func stat_key(label: String) -> String:
    for key in KEYS:
        if rules.stat_labels[key] == label: return key
    return ""

func project(allocation: Dictionary, masteries: Dictionary, allow_unspent: bool = false) -> Dictionary:
    if not valid_allocation(allocation, allow_unspent): return {}
    var stats := {}
    var grants := {}
    for key in KEYS: stats[key] = int(rules.base_each) + int(allocation[key])
    for id in masteries:
        var manual: Dictionary = registry.get_manual(str(id))
        if manual.is_empty() or not whole(masteries[id], 1, 10): return {}
        var primary := stat_key(str(manual.get("primary_stat", "")))
        var secondary := stat_key(str(manual.get("secondary_stat", "")))
        if primary.is_empty() or secondary.is_empty(): return {}
        for star in rules.even_star_grants:
            if int(masteries[id]) < int(star): continue
            var amount: Array = rules.even_star_grants[star]
            stats[primary] += int(amount[0])
            stats[secondary] += int(amount[1])
            grants[str(id) + ":" + star] = {primary: int(amount[0]), secondary: int(amount[1])}
    return {"stats": stats, "grants": grants}

func recommended_allocation(ids: Array) -> Dictionary:
    var allocation := {}
    var masteries := {}
    for key in KEYS: allocation[key] = 0
    for id in ids: masteries[id] = 3
    # First satisfy each selected manual's initial primary requirement, then spread spare points.
    var bonus := {}
    for key in KEYS: bonus[key] = 0
    for id in ids:
        var manual: Dictionary = registry.get_manual(str(id))
        var primary := stat_key(str(manual.get("primary_stat", "")))
        if primary.is_empty(): return {}
        bonus[primary] += 1
    var remaining := int(rules.free_points)
    for key in KEYS:
        if bonus[key] > 0:
            allocation[key] = maxi(0, int(rules.primary_requirements["3"]) - int(rules.base_each) - int(bonus[key]))
            remaining -= int(allocation[key])
    while remaining > 0:
        for key in KEYS:
            if remaining == 0: break
            if allocation[key] < int(rules.free_per_stat_max):
                allocation[key] += 1
                remaining -= 1
    return allocation

func lock_reason(card: Dictionary, stats: Dictionary) -> String:
    if stats.is_empty() or card.get("source") != "martial_manual": return ""
    var requirement := int(rules.primary_requirements.get(str(int(card.get("unlock_star", card.get("unlock_mastery", 0)))), 0))
    if requirement == 0: return ""
    var label := str(card.get("primary_stat", ""))
    var key := stat_key(label)
    if key.is_empty() or not valid_stats(stats): return "영구 능력 확인 필요"
    return "%s %d 필요 · 영구 %d" % [label, requirement, int(stats[key])] if int(stats[key]) < requirement else ""

func describe_change(allocation: Dictionary, current: Dictionary, next: Dictionary) -> Dictionary:
    var before: Dictionary = project(allocation,current).get("stats",{})
    var after: Dictionary = project(allocation,next).get("stats",{})
    var unlocked: Array[String] = []
    for id in next:
        var previously_usable := {}
        for card in registry.build_unlocked_cards(id,int(current.get(id,0))):
            if lock_reason(card,before).is_empty(): previously_usable[card.id] = true
        for card in registry.build_unlocked_cards(id,int(next[id])):
            if lock_reason(card,after).is_empty() and not previously_usable.has(card.id): unlocked.append(str(card.get("name",card.id)))
    return {"before":before,"after":after,"unlocked":unlocked}

func stats_text(stats: Dictionary) -> String:
    var labels := PackedStringArray()
    for key in KEYS: labels.append("%s %d" % [rules.stat_labels[key],int(stats.get(key,0))])
    return " · ".join(labels)
