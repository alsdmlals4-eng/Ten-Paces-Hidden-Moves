class_name ActionViewModelAdapter
extends RefCounted

const BASIC_PATH := "res://data/cards/basic_cards.json"
const ULTIMATE_PATH := "res://data/cards/ultimate_cards.json"
const MASTERY_ULTIMATE_PATH := "res://data/combat/mastery_ultimate_poc.json"
const MARTIAL_ULTIMATE_ATLAS_PATH := "res://assets/ui/cards/martial_ultimate_card_illustration_atlas_01_v1.png"
const MARTIAL_REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")
const MARTIAL_ATLAS_REGIONS := {
    "mount_hua_plum_blossom_sword": [0, 0, 384, 512],
    "nangong_boundless_sky_sword": [0, 0, 384, 512],
    "wudang_taiji_sword": [0, 0, 384, 512],
    "hebei_peng_five_tigers_saber": [384, 0, 384, 512],
    "beggars_dragon_subduing_palm": [768, 0, 384, 512],
    "yang_family_spear": [1152, 0, 384, 512],
    "sichuan_tang_hidden_weapons": [1152, 0, 384, 512],
    "mount_hua_purple_mist_art": [0, 512, 384, 512],
    "shaolin_arhat_vajra_art": [384, 512, 384, 512],
    "xiaoyao_lingbo_footwork": [768, 512, 384, 512]
}
const ULTIMATE_ATLAS_REGION := [1152, 512, 384, 512]

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
        return []
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
    normalized["targeting_mode"] = _semantic_targeting_mode(definition)
    normalized["telegraph_count"] = maxi(0, action_slots - 1)
    normalized["execution_count"] = 1
    normalized["locked"] = bool(definition.get("locked", false))
    normalized["lock_reason"] = str(definition.get("lock_reason", ""))
    normalized["tags"] = _string_array(definition.get("tags", []))
    var semantic_illustration := _semantic_illustration_for(definition, source_kind, source_id)
    if not semantic_illustration.is_empty():
        normalized["illustration"] = semantic_illustration
    normalized["detail"] = {
        "target": str(definition.get("target", "")),
        "damage": _damage_text(definition),
        "condition": str(definition.get("condition", "없음")),
        "effect_text": _effect_text(definition, source_kind),
        "flavor": str(definition.get("flavor", "")),
        "hits": _hit_count(definition.get("hits", _independent_attack_count(definition.get("effect_steps", []))))
    }
    return normalized

func _semantic_illustration_for(definition: Dictionary, source_kind: String, source_id: String) -> Dictionary:
    if source_kind == "ultimate":
        return _atlas_spec(ULTIMATE_ATLAS_REGION)
    if source_kind != "martial":
        return {}
    var region: Array = MARTIAL_ATLAS_REGIONS.get(source_id, []) as Array
    if region.is_empty():
        match str(definition.get("category", "")):
            "move":
                region = [768, 512, 384, 512]
            "response":
                region = [384, 512, 384, 512]
            "recovery", "strengthen":
                region = [0, 512, 384, 512]
            _:
                region = [0, 0, 384, 512]
    return _atlas_spec(region)

func _atlas_spec(region: Array) -> Dictionary:
    return {
        "atlas": MARTIAL_ULTIMATE_ATLAS_PATH,
        "region": region.duplicate()
    }

func _semantic_targeting_mode(definition: Dictionary) -> String:
    match str(definition.get("category", "")):
        "move":
            return "move_intent"
        "attack":
            return "aim_intent"
        _:
            return "none"

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
    if formula.is_empty():
        return str(definition.get("damage", "없음"))
    var base := int(formula.get("base", 0))
    var stat_label: String = str({"external": "외공", "internal_power": "내공"}.get(str(formula.get("stat_key", "")), "능력치"))
    var coefficient := float(formula.get("coefficient", 0.0))
    return "floor(%d + %s × %.2f)" % [base, stat_label, coefficient]

func _effect_step_summary(values) -> String:
    if typeof(values) != TYPE_ARRAY:
        return ""
    var operations := PackedStringArray()
    var attack_count := 0
    for value in values:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        match str((value as Dictionary).get("op", "")):
            "ATTACK", "INDEPENDENT_ATTACK":
                attack_count += 1
            "MOVE_TOWARD":
                operations.append("접근")
            "MOVE_AWAY":
                operations.append("후퇴")
            "RECHECK_RANGE":
                operations.append("거리 재확인")
            "SPECIAL_CLASH":
                operations.append("특수 합")
            "GAIN_RESOURCE":
                operations.append("자원 획득")
            "GAIN_STATUS":
                operations.append("상태 획득")
    if attack_count > 0:
        operations.append("연속 공격 %d회" % attack_count if attack_count > 1 else "공격")
    return " → ".join(operations)

func _effect_text(definition: Dictionary, source_kind: String) -> String:
    var explicit_text := str(definition.get("effect_text", "")).strip_edges()
    if not explicit_text.is_empty():
        return explicit_text
    var step_summary := _effect_step_summary(definition.get("effect_steps", []))
    if not step_summary.is_empty():
        return step_summary
    if source_kind == "ultimate":
        var parts := PackedStringArray()
        parts.append("돌진 후 공격" if bool(definition.get("dash_before_attack", false)) else "공격")
        var damage_text := _damage_text(definition)
        if not damage_text.is_empty() and damage_text != "없음":
            parts.append("기본 피해 %s" % damage_text)
        return " · ".join(parts)
    return ""

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
