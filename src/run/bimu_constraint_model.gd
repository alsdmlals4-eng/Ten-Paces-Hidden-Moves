class_name BimuConstraintModel
extends RefCounted

const CATALOG_PATH := "res://data/run/bimu_constraints.json"
const ALLOWED_STAT_KEYS := ["external", "constitution", "agility", "internal_power", "insight"]

var _catalog: Dictionary = {}
var _options_by_id: Dictionary = {}

func _init() -> void:
    _catalog = _load_catalog()
    for value in _catalog.get("constraints", []):
        if typeof(value) == TYPE_DICTIONARY:
            var option: Dictionary = value
            _options_by_id[str(option.get("constraint_id", ""))] = option.duplicate(true)

func get_options() -> Array:
    return (_catalog.get("constraints", []) as Array).duplicate(true)

func validate_selection(selection: Array, player_manual_ids: Array, enemy_manual_ids: Array) -> Dictionary:
    var errors: Array = []
    var normalized: Array = []
    var seen: Dictionary = {}
    var spent := 0
    var enemy_buffs := 0
    var player_ids := _validated_string_set(player_manual_ids, "player_manual_ids", errors)
    var enemy_ids := _validated_string_set(enemy_manual_ids, "enemy_manual_ids", errors)
    if not _catalog_contract_valid():
        errors.append("비무 제약 카탈로그가 유효하지 않습니다.")
        return {"valid": false, "errors": errors, "selections": [], "selection_point_spent": 0, "disclosed_effects": []}
    var policy: Dictionary = _catalog.get("selection_policy")
    var max_selected := int(policy.get("max_selected_constraints"))
    var min_selected := int(policy.get("minimum_selected_constraints"))
    var point_budget := int(policy.get("selection_point_budget"))
    var max_enemy_buffs := int(policy.get("max_enemy_reinforcements"))
    if selection.size() > max_selected:
        errors.append("제약은 최대 %d개까지 선택할 수 있습니다." % max_selected)
    if selection.size() < min_selected:
        errors.append("제약은 최소 %d개를 선택해야 합니다." % min_selected)
    for index in selection.size():
        var value = selection[index]
        if typeof(value) != TYPE_DICTIONARY:
            errors.append("선택 %d은 Dictionary여야 합니다." % index)
            continue
        var item: Dictionary = value
        if not item.has("constraint_id") or typeof(item.get("constraint_id")) != TYPE_STRING:
            errors.append("선택 %d의 constraint_id는 String이어야 합니다." % index)
            continue
        var constraint_id: String = item.get("constraint_id")
        if not _options_by_id.has(constraint_id):
            errors.append("알 수 없는 제약 ID: %s" % constraint_id)
            continue
        var option: Dictionary = _options_by_id[constraint_id]
        var allowed_keys := ["constraint_id"]
        var binding: Dictionary = option.get("parameter_binding", {})
        var parameter_field := str(binding.get("field", ""))
        if not parameter_field.is_empty():
            allowed_keys.append(parameter_field)
        for key in item.keys():
            if str(key) not in allowed_keys:
                errors.append("%s에 허용되지 않은 필드가 있습니다: %s" % [constraint_id, str(key)])
        if seen.has(constraint_id):
            errors.append("같은 제약을 중복 선택할 수 없습니다: %s" % constraint_id)
        seen[constraint_id] = true
        var normalized_item := {"constraint_id": constraint_id}
        if not parameter_field.is_empty():
            if not item.has(parameter_field) or typeof(item.get(parameter_field)) != TYPE_STRING or str(item.get(parameter_field)).is_empty():
                errors.append("%s의 %s는 비어 있지 않은 String이어야 합니다." % [constraint_id, parameter_field])
            else:
                var parameter_value: String = item.get(parameter_field)
                normalized_item[parameter_field] = parameter_value
                if constraint_id == "CST_TECH_MANUAL_SEAL" and (player_ids.size() < 2 or not player_ids.has(parameter_value)):
                    errors.append("문파 단절 대상은 2종 이상 보유 중인 무공이어야 합니다.")
                elif constraint_id == "CST_ENEMY_MASTERED_MANUAL" and not enemy_ids.has(parameter_value):
                    errors.append("무공 숙련 대상은 상대가 보유한 무공이어야 합니다.")
                elif constraint_id == "CST_ENEMY_STAT_DISCIPLINE" and parameter_value not in ALLOWED_STAT_KEYS:
                    errors.append("허용되지 않은 스테이터스입니다: %s" % parameter_value)
        spent += int(option.get("selection_cost", 99))
        if str(option.get("category", "")) == "ENEMY_REINFORCEMENT":
            enemy_buffs += 1
        normalized.append(normalized_item)
    if spent > point_budget:
        errors.append("제약 점수는 %d점을 넘을 수 없습니다." % point_budget)
    if enemy_buffs > max_enemy_buffs:
        errors.append("상대 강화는 최대 %d개만 선택할 수 있습니다." % max_enemy_buffs)
    var disclosed: Array = []
    if errors.is_empty():
        for item_value in normalized:
            var option: Dictionary = _options_by_id[str((item_value as Dictionary).get("constraint_id", ""))]
            disclosed.append(str(option.get("briefing_disclosure", "")))
    return {"valid": errors.is_empty(), "errors": errors.duplicate(true), "selections": normalized.duplicate(true), "selection_point_spent": spent, "disclosed_effects": disclosed.duplicate(true)}

func action_lock_reason(definition: Dictionary, validated_receipt: Dictionary) -> String:
    if str(definition.get("source", "")) != "martial_manual":
        return ""
    if typeof(definition.get("manual_id")) != TYPE_STRING or str(definition.get("manual_id", "")).is_empty():
        return ""
    var selections := _receipt_selections(validated_receipt)
    for value in selections:
        var item: Dictionary = value
        match str(item.get("constraint_id", "")):
            "CST_TECH_ULTIMATE_SEAL":
                if typeof(definition.get("unlock_star")) == TYPE_INT and int(definition.get("unlock_star")) == 10: return "비무 제약: 절초 봉인"
            "CST_TECH_RESPONSE_SEAL":
                if typeof(definition.get("category")) == TYPE_STRING and str(definition.get("category")) == "response": return "비무 제약: 대응 봉인"
            "CST_TECH_RECOVERY_SEAL":
                if typeof(definition.get("category")) == TYPE_STRING and str(definition.get("category")) == "recovery": return "비무 제약: 회복 봉인"
            "CST_TECH_MULTI_SLOT_SEAL":
                if typeof(definition.get("action_slots")) == TYPE_INT and int(definition.get("action_slots")) >= 2: return "비무 제약: 연속 수 봉인"
            "CST_TECH_MANUAL_SEAL":
                if str(definition.get("manual_id")) == str(item.get("target_manual_id", "")): return "비무 제약: 문파 단절"
    return ""

func enemy_mastery_overlay(masteries: Dictionary, receipt: Dictionary) -> Dictionary:
    var result := masteries.duplicate(true)
    for value in _receipt_selections(receipt):
        var item: Dictionary = value
        if str(item.get("constraint_id", "")) == "CST_ENEMY_MASTERED_MANUAL":
            var manual_id := str(item.get("target_enemy_manual_id", ""))
            if result.has(manual_id) and typeof(result.get(manual_id)) == TYPE_INT:
                result[manual_id] = clampi(int(result.get(manual_id)) + 2, 0, 10)
    return result

func enemy_state_overlay(enemy: Dictionary, receipt: Dictionary) -> Dictionary:
    var result := enemy.duplicate(true)
    for value in _receipt_selections(receipt):
        var item: Dictionary = value
        match str(item.get("constraint_id", "")):
            "CST_ENEMY_START_MOMENTUM_1": _increase_current(result, "momentum")
            "CST_ENEMY_RESOURCE_SURPLUS":
                _increase_current(result, "stamina")
                _increase_current(result, "internal")
            "CST_ENEMY_STAT_DISCIPLINE":
                var stat_key := str(item.get("target_stat_key", ""))
                if stat_key in ALLOWED_STAT_KEYS:
                    var stats: Dictionary = result.get("stats", {}) if typeof(result.get("stats", {})) == TYPE_DICTIONARY else {}
                    if stats.has(stat_key) and typeof(stats.get(stat_key)) == TYPE_INT:
                        stats[stat_key] = int(stats.get(stat_key)) + 1
                        result["stats"] = stats
                    elif result.has(stat_key) and typeof(result.get(stat_key)) == TYPE_INT:
                        result[stat_key] = int(result.get(stat_key)) + 1
    return result

func _increase_current(state: Dictionary, key: String) -> void:
    var pair_value = state.get(key)
    if typeof(pair_value) == TYPE_ARRAY and (pair_value as Array).size() >= 2 and typeof(pair_value[0]) == TYPE_INT and typeof(pair_value[1]) == TYPE_INT:
        var pair: Array = (pair_value as Array).duplicate()
        pair[0] = clampi(int(pair[0]) + 1, 0, maxi(0, int(pair[1])))
        state[key] = pair
        return
    var maximum_key := key + "_max"
    if state.has(key) and state.has(maximum_key) and typeof(state.get(key)) == TYPE_INT and typeof(state.get(maximum_key)) == TYPE_INT:
        state[key] = clampi(int(state.get(key)) + 1, 0, maxi(0, int(state.get(maximum_key))))

func _receipt_selections(receipt: Dictionary) -> Array:
    if not _catalog_contract_valid():
        return []
    if receipt.get("valid") != true or typeof(receipt.get("errors")) != TYPE_ARRAY or not (receipt.get("errors") as Array).is_empty():
        return []
    if typeof(receipt.get("selections")) != TYPE_ARRAY or typeof(receipt.get("selection_point_spent")) != TYPE_INT:
        return []
    var selections: Array = receipt.get("selections")
    var spent := 0
    var seen: Dictionary = {}
    var enemy_buffs := 0
    var policy: Dictionary = _catalog.get("selection_policy")
    if selections.size() > int(policy.get("max_selected_constraints")):
        return []
    for value in selections:
        if typeof(value) != TYPE_DICTIONARY:
            return []
        var item: Dictionary = value
        if typeof(item.get("constraint_id")) != TYPE_STRING or not _options_by_id.has(str(item.get("constraint_id"))):
            return []
        var id := str(item.get("constraint_id"))
        if seen.has(id): return []
        seen[id] = true
        var option: Dictionary = _options_by_id[id]
        spent += int(option.get("selection_cost", 99))
        if str(option.get("category", "")) == "ENEMY_REINFORCEMENT": enemy_buffs += 1
        var binding: Dictionary = option.get("parameter_binding", {})
        var field := str(binding.get("field", ""))
        if not field.is_empty() and (typeof(item.get(field)) != TYPE_STRING or str(item.get(field)).is_empty()): return []
    if spent > int(policy.get("selection_point_budget")) or enemy_buffs > int(policy.get("max_enemy_reinforcements")) or spent != int(receipt.get("selection_point_spent")):
        return []
    return selections.duplicate(true)

func _catalog_contract_valid() -> bool:
    if typeof(_catalog.get("selection_policy")) != TYPE_DICTIONARY or typeof(_catalog.get("constraints")) != TYPE_ARRAY:
        return false
    var policy: Dictionary = _catalog.get("selection_policy")
    for field in ["minimum_selected_constraints", "max_selected_constraints", "selection_point_budget", "max_enemy_reinforcements"]:
        if not _is_integer_value(policy.get(field)) or int(policy.get(field)) < 0:
            return false
    if int(policy.get("minimum_selected_constraints")) > int(policy.get("max_selected_constraints")):
        return false
    var options: Array = _catalog.get("constraints")
    if options.size() != 9 or _options_by_id.size() != 9:
        return false
    for value in options:
        if typeof(value) != TYPE_DICTIONARY:
            return false
        var option: Dictionary = value
        var constraint_id := str(option.get("constraint_id", ""))
        if constraint_id.is_empty() or not _options_by_id.has(constraint_id) or not _is_integer_value(option.get("selection_cost")) or int(option.get("selection_cost")) < 0:
            return false
    return true

func _is_integer_value(value) -> bool:
    return typeof(value) == TYPE_INT or (typeof(value) == TYPE_FLOAT and is_equal_approx(float(value), floor(float(value))))

func _validated_string_set(values: Array, label: String, errors: Array) -> Dictionary:
    var result: Dictionary = {}
    for value in values:
        if typeof(value) != TYPE_STRING or str(value).is_empty():
            errors.append("%s 항목은 비어 있지 않은 String이어야 합니다." % label)
        else:
            result[str(value)] = true
    return result

func _load_catalog() -> Dictionary:
    if not FileAccess.file_exists(CATALOG_PATH):
        return {}
    var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return (parsed as Dictionary).duplicate(true) if typeof(parsed) == TYPE_DICTIONARY else {}
