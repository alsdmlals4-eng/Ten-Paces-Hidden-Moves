class_name VerticalSliceRouteModel
extends RefCounted

const MANUAL_REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")

const GROWTH_SEEDS := {
    "R1": {"focused": 1, "free": 3},
    "R3": {"focused": 1, "free": 3},
    "R5": {"focused": 2, "free": 4},
    "R7": {"focused": 2, "free": 4}
}
const INFO_CATEGORIES := {
    "R2": ["BODY_TRACE", "MANUAL_RUMOR", "RECENT_DUEL"],
    "R4": ["RANGE_RECORD", "FOOTWORK_SIGHTING", "PAST_RANGE_FAILURE"],
    "R6": ["EVADE_RECORD", "COUNTER_CASE", "HABIT_RUMOR"],
    "R8": ["CHAIN_TRACE", "INTERRUPTION_CASE", "FOLLOWUP_RUMOR"]
}

var manual_registry: RefCounted


func _init() -> void:
    manual_registry = MANUAL_REGISTRY_SCRIPT.new()


func growth_node_id(completed_duels: int) -> String:
    if completed_duels < 1 or completed_duels > 4:
        return ""
    return "R%d" % (completed_duels * 2 - 1)


func info_node_id(completed_duels: int) -> String:
    if completed_duels < 1 or completed_duels > 4:
        return ""
    return "R%d" % (completed_duels * 2)


func get_growth_options(node_id: String, owned_manual_ids) -> Array:
    if not GROWTH_SEEDS.has(node_id):
        return []
    var seed: Dictionary = GROWTH_SEEDS[node_id]
    return [
        {
            "choice_type": "recovery",
            "label": "숨 고르기",
            "health_fraction": 0.25,
            "stamina": 1,
            "internal": 1,
            "rounding_policy": "REVERSIBLE_NEAREST_INTEGER"
        },
        {
            "choice_type": "focused_training",
            "label": "한 수 다듬기",
            "focused_training": int(seed.get("focused", 0)),
            "eligible_manual_ids": _string_values(owned_manual_ids)
        },
        {
            "choice_type": "free_training",
            "label": "기억해 두기",
            "free_training": int(seed.get("free", 0))
        }
    ]


func get_info_options(node_id: String, candidate: Dictionary) -> Array:
    if not INFO_CATEGORIES.has(node_id) or candidate.is_empty():
        return []
    var result: Array = []
    for category_value in INFO_CATEGORIES[node_id]:
        var category := str(category_value)
        result.append({
            "category": category,
            "text": build_public_intel(category, candidate)
        })
    return result


func build_public_intel(category: String, candidate: Dictionary) -> String:
    if candidate.is_empty():
        return ""
    var manual_id := str(candidate.get("signature_manual_id", ""))
    var manual: Dictionary = manual_registry.get_manual(manual_id) if manual_registry != null else {}
    var manual_name := str(manual.get("manual_name", "알려지지 않은 무공"))
    var faction := str(manual.get("faction", ""))
    var readable_habit := str(candidate.get("readable_habit", ""))
    var ambiguity := str(candidate.get("ambiguity_or_counterexample", ""))
    var identity := str(candidate.get("martial_identity", ""))
    var hook := str(candidate.get("public_briefing_hook", ""))
    var mastery := int(candidate.get("signature_star_seed", 0))
    var unlocked: Array = manual_registry.build_unlocked_cards(manual_id, mastery) if manual_registry != null else []
    var technique_names: Array[String] = []
    var range_fragments: Array[String] = []
    var chain_fragments: Array[String] = []
    for value in unlocked:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var card: Dictionary = value
        var card_name := str(card.get("name", ""))
        if not card_name.is_empty():
            technique_names.append(card_name)
        var range_value = card.get("range", {})
        if typeof(range_value) == TYPE_DICTIONARY:
            var minimum := int((range_value as Dictionary).get("min", 0))
            var maximum := int((range_value as Dictionary).get("max", 0))
            if maximum > 0:
                range_fragments.append("%s 사거리 %d~%d" % [card_name, minimum, maximum])
        var slots := int(card.get("action_slots", 0))
        if slots > 1:
            chain_fragments.append("%s는 %d칸 행동" % [card_name, slots])

    match category:
        "BODY_TRACE":
            return "%s형 무인으로 알려져 있다. %s" % [identity, hook]
        "MANUAL_RUMOR":
            var techniques := ", ".join(technique_names) if not technique_names.is_empty() else "기술명 미상"
            return "%s%s을 쓰며 현재 알려진 기술 범위는 %s이다." % ["[%s] " % faction if not faction.is_empty() else "", manual_name, techniques]
        "RECENT_DUEL":
            return "최근 비무 기록에서는 이런 습관이 반복되었다: %s" % readable_habit
        "RANGE_RECORD":
            if not range_fragments.is_empty():
                return "공개된 사거리 기록: %s." % ", ".join(range_fragments)
            return "공개 기록상 거리 운용 습관은 다음과 같다: %s" % readable_habit
        "FOOTWORK_SIGHTING":
            return "목격담은 위치 운용을 이렇게 묘사한다: %s" % readable_habit
        "PAST_RANGE_FAILURE":
            return "과거 기록에는 이 습관이 깨진 사례도 있다: %s" % ambiguity
        "EVADE_RECORD":
            return "공개 이력에서 회피·대응을 볼 때 참고할 습관: %s" % readable_habit
        "COUNTER_CASE":
            return "같은 대응이 늘 통하지는 않았다: %s" % ambiguity
        "HABIT_RUMOR":
            return "강호의 평은 이 무인의 반복 습관을 이렇게 전한다: %s" % readable_habit
        "CHAIN_TRACE":
            if not chain_fragments.is_empty():
                return "연계 흔적에서 확인된 기술 구조: %s." % ", ".join(chain_fragments)
            return "연계 흔적에서 드러난 습관: %s" % readable_habit
        "INTERRUPTION_CASE":
            return "연계가 끊긴 사례를 보면 다음 반례가 있다: %s" % ambiguity
        "FOLLOWUP_RUMOR":
            return "후속 수에 관한 소문은 이 흐름을 강조한다: %s" % readable_habit
    return ""


func _string_values(values) -> Array[String]:
    var result: Array[String] = []
    if typeof(values) != TYPE_ARRAY and typeof(values) != TYPE_PACKED_STRING_ARRAY:
        return result
    for value in values:
        var text := str(value)
        if not text.is_empty():
            result.append(text)
    return result
