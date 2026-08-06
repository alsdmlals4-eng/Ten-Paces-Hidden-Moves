class_name ActionViewModelAdapter
extends RefCounted

const BASIC_PATH := "res://data/cards/basic_cards.json"
const ULTIMATE_PATH := "res://data/cards/ultimate_cards.json"
const MASTERY_ULTIMATE_PATH := "res://data/combat/mastery_ultimate_poc.json"
const ACTION_SELECTION_PATH := "res://data/combat/action_selection_poc.json"

func build_basic_actions() -> Array[Dictionary]:
    var root := _load_dictionary(BASIC_PATH)
    var result: Array[Dictionary] = []
    for value in root.get("cards", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var definition: Dictionary = value
        result.append(_normalize_action(definition, "basic", "basic", "기초"))
    return result

func build_owned_manuals() -> Array[Dictionary]:
    var root := _load_dictionary(ACTION_SELECTION_PATH)
    var result: Array[Dictionary] = []
    for value in root.get("owned_manuals", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var source: Dictionary = value
        var manual_id := str(source.get("manual_id", ""))
        var manual_name := str(source.get("name", ""))
        var mastery := maxi(0, int(source.get("mastery", 0)))
        var techniques: Array[Dictionary] = []
        for technique_value in source.get("techniques", []):
            if typeof(technique_value) != TYPE_DICTIONARY:
                continue
            var technique_source: Dictionary = technique_value
            var technique := _normalize_action(technique_source, "martial", manual_id, manual_name)
            var unlock_mastery := maxi(0, int(technique_source.get("unlock_mastery", 0)))
            technique["unlock_mastery"] = unlock_mastery
            technique["current_mastery"] = mastery
            technique["locked"] = mastery < unlock_mastery
            technique["lock_reason"] = "%d성 해금 · 현재 %d성" % [unlock_mastery, mastery] if bool(technique["locked"]) else ""
            techniques.append(technique)
        result.append({
            "manual_id": manual_id,
            "name": manual_name,
            "mastery": mastery,
            "role_tags": _string_array(source.get("role_tags", [])),
            "ultimate_unlocked": bool(source.get("ultimate_unlocked", false)),
            "techniques": techniques
        })
    return result

func build_ultimate_actions(momentum: int) -> Array[Dictionary]:
    var base_root := _load_dictionary(ULTIMATE_PATH)
    var mastery_root := _load_dictionary(MASTERY_ULTIMATE_PATH)
    var required_momentum := maxi(0, int(base_root.get("momentum_cost", 5)))
    var sources: Array = []
    sources.append_array(base_root.get("cards", []))
    sources.append_array(mastery_root.get("cards", []))
    var result: Array[Dictionary] = []
    for value in sources:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var source: Dictionary = value
        var source_id := str(source.get("source_id", "basic_ultimate"))
        var source_label := str(source.get("source_label", "기본 절초"))
        var action := _normalize_action(source, "ultimate", source_id, source_label)
        var momentum_cost := maxi(0, int(source.get("momentum_cost", required_momentum)))
        var unlock_mastery := maxi(0, int(source.get("unlock_mastery", 0)))
        var current_mastery := maxi(0, int(source.get("current_mastery", unlock_mastery)))
        var mastery_locked := unlock_mastery > 0 and current_mastery < unlock_mastery
        var momentum_locked := momentum < momentum_cost
        action["momentum_cost"] = momentum_cost
        action["unlock_mastery"] = unlock_mastery
        action["current_mastery"] = current_mastery
        action["mastery_locked"] = mastery_locked
        action["momentum_locked"] = momentum_locked
        action["ultimate_origin"] = "mastery" if unlock_mastery > 0 else "basic"
        action["locked"] = mastery_locked or momentum_locked
        if mastery_locked:
            action["lock_reason"] = "%d성 해금 · 현재 %d성" % [unlock_mastery, current_mastery]
        elif momentum_locked:
            action["lock_reason"] = "기세 %d/%d" % [momentum, momentum_cost]
        else:
            action["lock_reason"] = ""
        result.append(action)
    return result

func _normalize_action(definition: Dictionary, source_kind: String, source_id: String, source_label: String) -> Dictionary:
    var action_slots := maxi(1, int(definition.get("action_slots", 1)))
    var normalized := definition.duplicate(true)
    normalized["id"] = str(definition.get("id", ""))
    normalized["name"] = str(definition.get("name", ""))
    normalized["source"] = source_kind
    normalized["source_kind"] = source_kind
    normalized["source_id"] = source_id
    normalized["source_label"] = source_label
    normalized["category"] = str(definition.get("category", ""))
    normalized["category_label"] = str(definition.get("category_label", ""))
    normalized["action_slots"] = action_slots
    normalized["stamina_cost"] = maxi(0, int(definition.get("stamina_cost", 0)))
    normalized["internal_cost"] = maxi(0, int(definition.get("internal_cost", 0)))
    normalized["momentum_cost"] = maxi(0, int(definition.get("momentum_cost", 0)))
    normalized["range_text"] = str(definition.get("range_text", "-"))
    normalized["targeting_mode"] = str(definition.get("targeting_mode", "none"))
    normalized["telegraph_count"] = maxi(0, action_slots - 1)
    normalized["execution_count"] = 1
    normalized["locked"] = bool(definition.get("locked", false))
    normalized["lock_reason"] = str(definition.get("lock_reason", ""))
    normalized["tags"] = _string_array(definition.get("tags", []))
    normalized["detail"] = {
        "target": str(definition.get("target", "")),
        "damage": str(definition.get("damage", "없음")),
        "condition": str(definition.get("condition", "없음")),
        "effect_text": str(definition.get("effect_text", "")),
        "flavor": str(definition.get("flavor", "")),
        "hits": _hit_count(definition.get("hits", 0))
    }
    return normalized

func _hit_count(value) -> int:
    if typeof(value) == TYPE_ARRAY or typeof(value) == TYPE_PACKED_INT32_ARRAY or typeof(value) == TYPE_PACKED_INT64_ARRAY:
        return value.size()
    return maxi(0, int(value))

func _load_dictionary(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_error("ActionViewModelAdapter file not found: %s" % path)
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("ActionViewModelAdapter could not open: %s" % path)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("ActionViewModelAdapter root must be a Dictionary: %s" % path)
        return {}
    return parsed

func _string_array(values) -> Array[String]:
    var result: Array[String] = []
    if typeof(values) != TYPE_ARRAY and typeof(values) != TYPE_PACKED_STRING_ARRAY:
        return result
    for value in values:
        result.append(str(value))
    return result
