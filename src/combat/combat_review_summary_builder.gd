class_name CombatReviewSummaryBuilder
extends RefCounted

const CAUSE_PRIORITY := [
    "clash",
    "interrupted",
    "defense",
    "direction",
    "range",
    "resource",
    "position",
    "order"
]

const CAUSE_LABELS := {
    "clash": "[합]에서 공격력 차이가 승부를 갈랐다.",
    "interrupted": "피해가 같은 수의 미실행 행동을 중단했다.",
    "defense": "막기·회피·필중 대응이 최종 결과를 바꿨다.",
    "direction": "선택한 공격 방향이 상대 위치와 어긋났다.",
    "range": "실행 순간 거리가 공격 사거리 밖이었다.",
    "resource": "실행 순간 기력 또는 내력이 부족했다.",
    "position": "이동으로 바뀐 전후 거리가 다음 판정을 만들었다.",
    "order": "행동 순서와 실행 시점이 결과를 결정했다."
}

const REVIEW_DIMENSIONS := {
    "clash": "다음 묶음에서는 같은 수에 맞부딪힐 공격의 원공격력을 비교한다.",
    "interrupted": "다음 묶음에서는 피해를 받는 수와 보호할 실행 수를 분리한다.",
    "defense": "다음 묶음에서는 막기·회피·필중의 적용 수를 먼저 확인한다.",
    "direction": "다음 묶음에서는 실행 순간 상대 방향을 다시 확인한다.",
    "range": "다음 묶음에서는 앞선 이동 뒤 실제 거리를 기준으로 계획한다.",
    "resource": "다음 묶음에서는 실행 순서대로 기력·내력 잔량을 확인한다.",
    "position": "다음 묶음에서는 전후 거리와 공동 이동 가능성을 먼저 본다.",
    "order": "다음 묶음에서는 대응·속공·이동·일반 공격 순서를 기준으로 배치한다."
}

func build_summary(result_value: Dictionary, player_plan_value: Array, hypothesis_value: Dictionary, state_before_value: Dictionary) -> Dictionary:
    var result := result_value.duplicate(true)
    var player_plan := player_plan_value.duplicate(true)
    var hypothesis := _normalize_hypothesis(hypothesis_value.duplicate(true))
    var state_before := state_before_value.duplicate(true)
    var events := _collect_events(result)
    var state_after: Dictionary = (result.get("state", {}) as Dictionary).duplicate(true)
    var distance_before := _distance_from_state(state_before)
    var distance_after := _distance_from_state(state_after)
    var cause_code := _select_cause(events, distance_before, distance_after)
    var decisive_event := _decisive_event(events, cause_code)
    var decisive_timing := int(decisive_event.get("timing", 0)) if not decisive_event.is_empty() else 0
    return {
        "hypothesis": hypothesis,
        "opponent_actual": _opponent_actual(events),
        "cause_code": cause_code,
        "cause_label": str(CAUSE_LABELS.get(cause_code, CAUSE_LABELS["order"])),
        "decisive_timing": decisive_timing,
        "distance_before": distance_before,
        "distance_after": distance_after,
        "review_dimension": str(REVIEW_DIMENSIONS.get(cause_code, REVIEW_DIMENSIONS["order"])),
        "player_plan_count": player_plan.size()
    }

func _collect_events(result: Dictionary) -> Array:
    var collected: Array = []
    var direct: Array = result.get("presentation_events", [])
    for value in direct:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("type", "")) in ["action_result", "clash"]:
            collected.append((value as Dictionary).duplicate(true))
    if not collected.is_empty():
        return collected
    for timing_value in result.get("timing_results", []):
        if typeof(timing_value) != TYPE_DICTIONARY:
            continue
        for event_value in (timing_value as Dictionary).get("events", []):
            if typeof(event_value) == TYPE_DICTIONARY and str((event_value as Dictionary).get("type", "")) in ["action_result", "clash"]:
                collected.append((event_value as Dictionary).duplicate(true))
    return collected

func _normalize_hypothesis(value: Dictionary) -> Dictionary:
    var id_value := str(value.get("id", "none"))
    if id_value.is_empty():
        id_value = "none"
    var recorded := bool(value.get("recorded", id_value != "none")) and id_value != "none"
    return {
        "id": id_value,
        "label": str(value.get("label", "기록한 가설 없음" if not recorded else id_value)),
        "recorded": recorded
    }

func _select_cause(events: Array, distance_before: int, distance_after: int) -> String:
    var found := {
        "clash": false,
        "interrupted": false,
        "defense": false,
        "direction": false,
        "range": false,
        "resource": false,
        "position": distance_before != distance_after,
        "order": true
    }
    for value in events:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var event: Dictionary = value
        var outcome := str(event.get("outcome", ""))
        var defense_outcome := str(event.get("defense_outcome", ""))
        if outcome.begins_with("clash_") or bool(event.get("clash", false)):
            found["clash"] = true
        if outcome == "interrupted":
            found["interrupted"] = true
        if defense_outcome in ["block", "evade", "sure_hit", "sure_hit_block"]:
            found["defense"] = true
        if outcome == "miss_direction":
            found["direction"] = true
        if outcome == "miss_range":
            found["range"] = true
        if outcome in ["resource_insufficient", "insufficient"]:
            found["resource"] = true
    for cause in CAUSE_PRIORITY:
        if bool(found.get(cause, false)):
            return cause
    return "order"

func _decisive_event(events: Array, cause_code: String) -> Dictionary:
    var best: Dictionary = {}
    for value in events:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var event: Dictionary = value
        if not _event_matches_cause(event, cause_code):
            continue
        if best.is_empty() or int(event.get("timing", 0)) < int(best.get("timing", 0)):
            best = event.duplicate(true)
    return best

func _event_matches_cause(event: Dictionary, cause_code: String) -> bool:
    var outcome := str(event.get("outcome", ""))
    var defense_outcome := str(event.get("defense_outcome", ""))
    match cause_code:
        "clash":
            return outcome.begins_with("clash_") or bool(event.get("clash", false))
        "interrupted":
            return outcome == "interrupted"
        "defense":
            return defense_outcome in ["block", "evade", "sure_hit", "sure_hit_block"]
        "direction":
            return outcome == "miss_direction"
        "range":
            return outcome == "miss_range"
        "resource":
            return outcome in ["resource_insufficient", "insufficient"]
        _:
            return false

func _opponent_actual(events: Array) -> String:
    for value in events:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var event: Dictionary = value
        if str(event.get("actor", "")) != "enemy":
            continue
        var card_name := str(event.get("card_name", ""))
        if not card_name.is_empty():
            return card_name
    return "행동 정보 없음"

func _distance_from_state(state: Dictionary) -> int:
    var player: Dictionary = state.get("player", {})
    var enemy: Dictionary = state.get("enemy", {})
    if not player.has("tile") or not enemy.has("tile"):
        return 0
    return absi(int(player.get("tile", 0)) - int(enemy.get("tile", 0)))
