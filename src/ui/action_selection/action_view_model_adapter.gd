class_name ActionViewModelAdapter
extends RefCounted

const BASIC_PATH := "res://data/cards/basic_cards.json"
const ULTIMATE_PATH := "res://data/cards/ultimate_cards.json"
const MASTERY_ULTIMATE_PATH := "res://data/combat/mastery_ultimate_poc.json"
const ACTION_SELECTION_PATH := "res://data/combat/action_selection_poc.json"
const MARTIAL_REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")

func build_basic_actions() -> Array[Dictionary]:
    var root := _load_dictionary(BASIC_PATH)
    var result: Array[Dictionary] = []
    for value in root.get("cards", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var definition: Dictionary = value
        result.append(_normalize_action(definition, "basic", "basic", "기초"))
    return result

func build_owned_manuals(loadout: Array = [], mastery_by_manual: Dictionary = {}) -> Array[Dictionary]:
    if loadout.is_empty() and mastery_by_manual.is_empty():
        return _build_legacy_owned_manuals()
    var registry: MartialManualRegistry = MARTIAL_REGISTRY_SCRIPT.new()
    var result: Array[Dictionary] = []
    for manual_value in loadout:
        var manual_id := str(manual_value)
        var source: Dictionary = registry.get_manual(manual_id)
        if source.is_empty():
            continue
        var mastery := clampi(int(mastery_by_manual.get(manual_id, 0)), 0, 10)
        var unlocked_by_id: Dictionary = {}
        for card_value in registry.build_unlocked_cards(manual_id, mastery):
            if typeof(card_value) == TYPE_DICTIONARY:
                var unlocked_card: Dictionary = card_value
                unlocked_by_id[str(unlocked_card.get("id", ""))] = unlocked_card.duplicate(true)
        var techniques: Array[Dictionary] = []
        var cards: Dictionary = source.get("cards", {})
        for stage in ["star3", "star7"]:
            var raw_card: Dictionary = cards.get(stage, {})
            if raw_card.is_empty():
                continue
            var card_id := str(raw_card.get("id", ""))
            var card: Dictionary = (unlocked_by_id.get(card_id, raw_card) as Dictionary).duplicate(true)
            var source_label := "[%s] %s" % [str(source.get("faction", "")), str(source.get("manual_name", ""))]
            var technique := _normalize_action(card, "martial", manual_id, source_label)
            technique["source"] = "martial_manual"
            technique["source_kind"] = "martial"
            technique["manual_id"] = manual_id
            technique["faction"] = str(source.get("faction", ""))
            technique["primary_stat"] = str(source.get("primary_stat", ""))
            technique["secondary_stat"] = str(source.get("secondary_stat", ""))
            technique["applied_overlays"] = _string_array(card.get("applied_overlays", []))
            var unlock_mastery := maxi(0, int(raw_card.get("unlock_star", 0)))
            technique["unlock_mastery"] = unlock_mastery
            technique["current_mastery"] = mastery
            technique["locked"] = mastery < unlock_mastery
            technique["lock_reason"] = "%d성 해금 · 현재 %d성" % [unlock_mastery, mastery] if bool(technique["locked"]) else ""
            techniques.append(technique)
        result.append({
            "manual_id": manual_id,
            "name": str(source.get("manual_name", "")),
            "faction": str(source.get("faction", "")),
            "primary_stat": str(source.get("primary_stat", "")),
            "secondary_stat": str(source.get("secondary_stat", "")),
            "mastery": mastery,
            "role_tags": [str(source.get("primary_stat", "")), str(source.get("secondary_stat", ""))],
            "ultimate_unlocked": mastery >= 10,
            "techniques": techniques
        })
    return result

func build_ultimate_actions(momentum: int, loadout: Array = [], mastery_by_manual: Dictionary = {}) -> Array[Dictionary]:
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
        _apply_ultimate_locks(action, source, momentum, required_momentum)
        action["ultimate_origin"] = "mastery" if int(action.get("unlock_mastery", 0)) > 0 else "basic"
        result.append(action)
    result.append_array(_build_martial_ultimates(momentum, required_momentum, loadout, mastery_by_manual))
    return result

func _build_legacy_owned_manuals() -> Array[Dictionary]:
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

func _build_martial_ultimates(momentum: int, required_momentum: int, loadout: Array, mastery_by_manual: Dictionary) -> Array[Dictionary]:
    var registry: MartialManualRegistry = MARTIAL_REGISTRY_SCRIPT.new()
    var result: Array[Dictionary] = []
    for manual_value in loadout:
        var manual_id := str(manual_value)
        var manual: Dictionary = registry.get_manual(manual_id)
        if manual.is_empty():
            continue
        var raw_card: Dictionary = (manual.get("cards", {}) as Dictionary).get("star10", {})
        if raw_card.is_empty():
            continue
        var mastery := clampi(int(mastery_by_manual.get(manual_id, 0)), 0, 10)
        var card := raw_card.duplicate(true)
        if mastery >= 10:
            for unlocked_value in registry.build_unlocked_cards(manual_id, mastery):
                if typeof(unlocked_value) == TYPE_DICTIONARY and str((unlocked_value as Dictionary).get("id", "")) == str(raw_card.get("id", "")):
                    card = (unlocked_value as Dictionary).duplicate(true)
                    break
        card["momentum_cost"] = maxi(0, int(card.get("momentum_cost", required_momentum)))
        var source_label := "[%s] %s" % [str(manual.get("faction", "")), str(manual.get("manual_name", ""))]
        var action := _normalize_action(card, "ultimate", manual_id, source_label)
        action["source"] = "martial_manual"
        action["source_kind"] = "ultimate"
        action["manual_id"] = manual_id
        action["faction"] = str(manual.get("faction", ""))
        action["primary_stat"] = str(manual.get("primary_stat", ""))
        action["secondary_stat"] = str(manual.get("secondary_stat", ""))
        action["unlock_mastery"] = 10
        action["current_mastery"] = mastery
        _apply_ultimate_locks(action, action, momentum, required_momentum)
        action["ultimate_origin"] = "martial_manual"
        result.append(action)
    return result

func _apply_ultimate_locks(action: Dictionary, source: Dictionary, momentum: int, required_momentum: int) -> void:
    var momentum_cost := maxi(0, int(source.get("momentum_cost", required_momentum)))
    var unlock_mastery := maxi(0, int(source.get("unlock_mastery", 0)))
    var current_mastery := maxi(0, int(source.get("current_mastery", action.get("current_mastery", unlock_mastery))))
    var mastery_locked := unlock_mastery > 0 and current_mastery < unlock_mastery
    var momentum_locked := momentum < momentum_cost
    action["momentum_cost"] = momentum_cost
    action["unlock_mastery"] = unlock_mastery
    action["current_mastery"] = current_mastery
    action["mastery_locked"] = mastery_locked
    action["momentum_locked"] = momentum_locked
    action["locked"] = mastery_locked or momentum_locked
    if mastery_locked:
        action["lock_reason"] = "%d성 해금 · 현재 %d성" % [unlock_mastery, current_mastery]
    elif momentum_locked:
        action["lock_reason"] = "기세 %d/%d" % [momentum, momentum_cost]
    else:
        action["lock_reason"] = ""

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
    normalized["range_text"] = _range_text(definition)
    normalized["targeting_mode"] = str(definition.get("targeting_mode", "none"))
    normalized["telegraph_count"] = maxi(0, action_slots - 1)
    normalized["execution_count"] = 1
    normalized["locked"] = bool(definition.get("locked", false))
    normalized["lock_reason"] = str(definition.get("lock_reason", ""))
    normalized["tags"] = _string_array(definition.get("tags", []))
    normalized["detail"] = {
        "target": str(definition.get("target", "")),
        "damage": _damage_text(definition),
        "condition": str(definition.get("condition", "없음")),
        "effect_text": str(definition.get("effect_text", _effect_step_summary(definition.get("effect_steps", [])))),
        "flavor": str(definition.get("flavor", "")),
        "hits": _hit_count(definition.get("hits", _independent_attack_count(definition.get("effect_steps", []))))
    }
    return normalized

func _range_text(definition: Dictionary) -> String:
    if definition.has("range_text"):
        return str(definition.get("range_text", "-"))
    var range_value = definition.get("range", {})
    if typeof(range_value) != TYPE_DICTIONARY:
        return "-"
    var range_data: Dictionary = range_value
    var minimum := int(range_data.get("min", 0))
    var maximum := int(range_data.get("max", minimum))
    return str(minimum) if minimum == maximum else "%d~%d" % [minimum, maximum]

func _damage_text(definition: Dictionary) -> String:
    var formula_value = definition.get("damage_formula", {})
    if typeof(formula_value) != TYPE_DICTIONARY:
        return str(definition.get("damage", "없음"))
    var formula: Dictionary = formula_value
    var base := int(formula.get("base", 0))
    var stat_label: String = str({"external": "외공", "internal_power": "내공"}.get(str(formula.get("stat_key", "")), "능력치"))
    var coefficient := float(formula.get("coefficient", 0.0))
    return "floor(%d + %s × %.2f)" % [base, stat_label, coefficient]

func _effect_step_summary(values) -> String:
    if typeof(values) != TYPE_ARRAY:
        return ""
    var operations := PackedStringArray()
    for value in values:
        if typeof(value) == TYPE_DICTIONARY:
            operations.append(str((value as Dictionary).get("op", "")))
    return " → ".join(operations)

func _independent_attack_count(values) -> int:
    if typeof(values) != TYPE_ARRAY:
        return 0
    var result := 0
    for value in values:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("op", "")) in ["ATTACK", "INDEPENDENT_ATTACK"]:
            result += 1
    return result

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
