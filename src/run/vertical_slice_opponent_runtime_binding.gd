# 첫 5전 후보 데이터를 검증된 전투별 런타임 binding으로 변환한다.
class_name VerticalSliceOpponentRuntimeBinding
extends RefCounted

const ARCHETYPES_PATH := "res://data/run/vertical_slice_opponent_archetypes.json"
const BASIC_CARDS_PATH := "res://data/cards/basic_cards.json"
const STAT_ORDER := ["external", "constitution", "agility", "internal_power", "insight"]
const STAT_WEIGHT_TOTAL := 20
const SCORE_WEIGHT_KEYS := ["approach", "quick_pressure", "heavy_prepare", "response_low_health", "recover_low_resource", "ultimate_ready"]
const EXPECTED_PROFILE_IDS := ["initiative_exchange", "stabilize_then_pressure", "range_control", "public_history_counter", "sequence_pressure"]
const VALID_MOVEMENT_MODES := ["approach", "preferred_distance", "hold_or_approach"]
const VALID_HISTORY_MODES := ["none", "last_two_player_resolved_cards", "own_planned_cards_only"]

var load_errors := PackedStringArray()
var _profiles_by_id: Dictionary = {}
var _basic_card_ids: Dictionary = {}


func _init(archetypes_path: String = ARCHETYPES_PATH, basic_cards_path: String = BASIC_CARDS_PATH) -> void:
    _load_archetypes(archetypes_path)
    _load_basic_card_ids(basic_cards_path)


func is_valid() -> bool:
    return load_errors.is_empty()


func get_load_errors() -> PackedStringArray:
    return load_errors.duplicate()


func build(candidate: Dictionary) -> Dictionary:
    if not is_valid():
        return {"valid": false}
    var candidate_id := str(candidate.get("candidate_id", ""))
    var archetype_id := str(candidate.get("runtime_archetype_id", ""))
    if candidate_id.is_empty() or archetype_id.is_empty() or not _profiles_by_id.has(archetype_id):
        return {"valid": false}
    var raw_focus_ids = candidate.get("basic_action_focus_ids", [])
    if typeof(raw_focus_ids) != TYPE_ARRAY:
        return {"valid": false}
    var focus_ids: Array[String] = []
    for focus_value in raw_focus_ids:
        var focus_id := str(focus_value)
        if focus_id.is_empty() or focus_id in focus_ids or not _basic_card_ids.has(focus_id):
            return {"valid": false}
        focus_ids.append(focus_id)
    if focus_ids.size() != 3:
        return {"valid": false}
    var total_value = candidate.get("final_stat_total_seed", null)
    if not _is_integer_value(total_value):
        return {"valid": false}
    var total_seed := int(total_value)
    var profile: Dictionary = (_profiles_by_id.get(archetype_id, {}) as Dictionary).duplicate(true)
    var stat_weights: Dictionary = profile.get("stat_weights", {})
    var allocated := _allocate_stats(total_seed, stat_weights)
    if allocated.is_empty() or _sum_stats(allocated) != total_seed:
        return {"valid": false}
    return {
        "valid": true,
        "candidate_id": candidate_id,
        "archetype_id": archetype_id,
        "ai_profile": profile.duplicate(true),
        "basic_action_focus_ids": focus_ids.duplicate(),
        "stats": allocated.duplicate(true),
        "final_stat_total_seed": total_seed
    }


func _load_archetypes(path: String) -> void:
    var root := _load_json_root(path, "opponent archetypes")
    if root.is_empty():
        return
    if int(root.get("schema_version", 0)) != 1:
        load_errors.append("opponent archetype schema_version must be 1")
    if root.get("stat_order", []) != STAT_ORDER:
        load_errors.append("opponent archetype stat_order must remain canonical")
    if int(root.get("stat_weight_total", 0)) != STAT_WEIGHT_TOTAL:
        load_errors.append("opponent archetype stat_weight_total must be 20")
    var raw_profiles = root.get("profiles", [])
    if typeof(raw_profiles) != TYPE_ARRAY:
        load_errors.append("opponent archetype profiles must be an Array")
        return
    for profile_value in raw_profiles:
        if typeof(profile_value) != TYPE_DICTIONARY:
            load_errors.append("opponent archetype profile must be a Dictionary")
            continue
        var profile: Dictionary = (profile_value as Dictionary).duplicate(true)
        var profile_id := str(profile.get("id", ""))
        if profile_id.is_empty() or _profiles_by_id.has(profile_id):
            load_errors.append("opponent archetype id must be unique and non-empty: %s" % profile_id)
            continue
        if not _validate_profile(profile):
            continue
        _profiles_by_id[profile_id] = profile
    if _profiles_by_id.size() != EXPECTED_PROFILE_IDS.size():
        load_errors.append("expected exactly five opponent archetypes")
    for profile_id in EXPECTED_PROFILE_IDS:
        if not _profiles_by_id.has(profile_id):
            load_errors.append("missing approved opponent archetype: %s" % profile_id)


func _load_basic_card_ids(path: String) -> void:
    var root := _load_json_root(path, "basic cards")
    if root.is_empty():
        return
    var raw_cards = root.get("cards", [])
    if typeof(raw_cards) != TYPE_ARRAY:
        load_errors.append("basic cards must be an Array")
        return
    for card_value in raw_cards:
        if typeof(card_value) != TYPE_DICTIONARY:
            continue
        var card_id := str((card_value as Dictionary).get("id", ""))
        if card_id.is_empty() or _basic_card_ids.has(card_id):
            load_errors.append("basic card ids must be unique and non-empty")
            continue
        _basic_card_ids[card_id] = true
    if _basic_card_ids.is_empty():
        load_errors.append("basic card ids are required for opponent focus validation")


func _load_json_root(path: String, label: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        load_errors.append("missing %s data: %s" % [label, path])
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        load_errors.append("failed to open %s data: %s" % [label, path])
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        load_errors.append("%s root must be a Dictionary" % label)
        return {}
    return (parsed as Dictionary).duplicate(true)


func _validate_profile(profile: Dictionary) -> bool:
    var profile_id := str(profile.get("id", ""))
    var score_weights = profile.get("score_weights", {})
    if typeof(score_weights) != TYPE_DICTIONARY:
        load_errors.append("profile %s score_weights must be a Dictionary" % profile_id)
        return false
    for weight_key in SCORE_WEIGHT_KEYS:
        if not score_weights.has(weight_key) or float(score_weights.get(weight_key, -1.0)) < 0.0:
            load_errors.append("profile %s has invalid score weight: %s" % [profile_id, weight_key])
            return false
    var max_actions_value = profile.get("max_actions_per_bundle", 0)
    if not _is_integer_value(max_actions_value) or int(max_actions_value) < 1 or int(max_actions_value) > 2:
        load_errors.append("profile %s max_actions_per_bundle must be 1 or 2" % profile_id)
        return false
    var movement_policy = profile.get("movement_policy", {})
    if typeof(movement_policy) != TYPE_DICTIONARY:
        load_errors.append("profile %s movement_policy must be a Dictionary" % profile_id)
        return false
    var movement_mode := str((movement_policy as Dictionary).get("mode", ""))
    if movement_mode not in VALID_MOVEMENT_MODES:
        load_errors.append("profile %s movement mode is invalid" % profile_id)
        return false
    if movement_mode == "preferred_distance" and int((movement_policy as Dictionary).get("distance", 0)) != 3:
        load_errors.append("profile %s preferred distance must be 3" % profile_id)
        return false
    var history_policy = profile.get("history_policy", {})
    if typeof(history_policy) != TYPE_DICTIONARY or str((history_policy as Dictionary).get("mode", "")) not in VALID_HISTORY_MODES:
        load_errors.append("profile %s history policy is invalid" % profile_id)
        return false
    var stat_weights = profile.get("stat_weights", {})
    if typeof(stat_weights) != TYPE_DICTIONARY:
        load_errors.append("profile %s stat_weights must be a Dictionary" % profile_id)
        return false
    var total_weight := 0
    for stat_id in STAT_ORDER:
        if not stat_weights.has(stat_id) or not _is_integer_value(stat_weights.get(stat_id)) or int(stat_weights.get(stat_id, 0)) <= 0:
            load_errors.append("profile %s has invalid stat weight: %s" % [profile_id, stat_id])
            return false
        total_weight += int(stat_weights.get(stat_id, 0))
    if total_weight != STAT_WEIGHT_TOTAL:
        load_errors.append("profile %s stat weights must sum to 20" % profile_id)
        return false
    return true


func _allocate_stats(total_seed: int, stat_weights: Dictionary) -> Dictionary:
    if total_seed <= 0:
        return {}
    var allocated: Dictionary = {}
    var remainders: Array[Dictionary] = []
    for stat_index in range(STAT_ORDER.size()):
        var stat_id := str(STAT_ORDER[stat_index])
        if not _is_integer_value(stat_weights.get(stat_id)):
            return {}
        var weight := int(stat_weights.get(stat_id, 0))
        if weight <= 0:
            return {}
        var weighted_total := total_seed * weight
        allocated[stat_id] = int(floor(float(weighted_total) / float(STAT_WEIGHT_TOTAL)))
        remainders.append({"stat_id": stat_id, "remainder": weighted_total % STAT_WEIGHT_TOTAL, "order": stat_index})
    remainders.sort_custom(_sort_remainders)
    var remaining := total_seed - _sum_stats(allocated)
    for index in range(remaining):
        var remainder_entry: Dictionary = remainders[index]
        var stat_id := str(remainder_entry.get("stat_id", ""))
        allocated[stat_id] = int(allocated.get(stat_id, 0)) + 1
    for stat_id in STAT_ORDER:
        if int(allocated.get(stat_id, 0)) < 1:
            return {}
    return allocated


func _sort_remainders(left: Dictionary, right: Dictionary) -> bool:
    var left_remainder := int(left.get("remainder", 0))
    var right_remainder := int(right.get("remainder", 0))
    if left_remainder == right_remainder:
        return int(left.get("order", 0)) < int(right.get("order", 0))
    return left_remainder > right_remainder


func _sum_stats(stats: Dictionary) -> int:
    var total := 0
    for stat_id in STAT_ORDER:
        total += int(stats.get(stat_id, 0))
    return total


func _is_integer_value(value) -> bool:
    if typeof(value) == TYPE_INT:
        return true
    return typeof(value) == TYPE_FLOAT and is_equal_approx(float(value), floor(float(value)))
