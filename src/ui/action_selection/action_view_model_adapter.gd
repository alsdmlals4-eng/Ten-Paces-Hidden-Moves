class_name ActionViewModelAdapter
extends RefCounted

const BASIC_PATH := "res://data/cards/basic_cards.json"
const ULTIMATE_PATH := "res://data/cards/ultimate_cards.json"
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
    var root := _load_dictionary(ULTIMATE_PATH)
    var required_momentum := maxi(0, int(root.get("momentum_cost", 5)))
    var result: Array[Dictionary] = []
    for value in root.get("cards", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var source: Dictionary = value
        var source_id := str(source.get("source_id", "basic_ultimate"))
        var source_label := str(source.get("source_label", "기본 절초"))
        var action := _normalize_action(source, "ultimate", source_id, source_label)
        action["momentum_cost"] = maxi(0, int(source.get("momentum_cost", required_momentum)))
        action["locked"] = momentum < int(action["momentum_cost"])
        action["lock_reason"] = "절초기세 %d/%d" % [momentum, int(action["momentum_cost"])] if bool(action["locked"]) else ""
        result.append(action)
    return result

func _normalize_action(definition: Dictionary, source_kind: String, source_id: String, source_label: String) -> Dictionary:
    var action_slots := maxi(1, int(definition.get("action_slots", 1)))
    var detail := {
        "target": str(definition.get("target", "")),
        "damage": str(definition.get("damage", "없음")),
        "condition": str(definition.get("condition", "없음")),
        "effect_text": str(definition.get("effect_text", "")),
        "flavor": str(definition.get("flavor", "")),
        "hits": maxi(0, int(definition.get("hits", 0)))
    }
    return {
        "id": str(definition.get("id", "")),
        "name": str(definition.get("name", "")),
        "source_kind": source_kind,
        "source_id": source_id,
        "source_label": source_label,
        "category": str(definition.get("category", "")),
        "category_label": str(definition.get("category_label", "")),
        "action_slots": action_slots,
        "stamina_cost": maxi(0, int(definition.get("stamina_cost", 0))),
        "internal_cost": maxi(0, int(definition.get("internal_cost", 0))),
        "momentum_cost": maxi(0, int(definition.get("momentum_cost", 0))),
        "range_text": str(definition.get("range_text", "-")),
        "targeting_mode": str(definition.get("targeting_mode", "none")),
        "telegraph_count": maxi(0, action_slots - 1),
        "execution_count": 1,
        "locked": bool(definition.get("locked", false)),
        "lock_reason": str(definition.get("lock_reason", "")),
        "tags": _string_array(definition.get("tags", [])),
        "detail": detail
    }

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
