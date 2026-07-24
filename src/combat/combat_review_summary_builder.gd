class_name CombatReviewSummaryBuilder
extends RefCounted

# This layer reads authoritative results and does not recompute damage or combat state.
const CAUSE_PRIORITY := [
    "CLASH_DIFFERENCE",
    "INTERRUPTION",
    "GUARD_REDUCTION",
    "EVADE_SUCCESS",
    "SURE_HIT_OVERRIDE",
    "DIRECTION_FAILURE",
    "RANGE_FAILURE",
    "RESOURCE_FAILURE",
    "POSITION_RANGE",
    "ULTIMATE_TIMING",
    "NO_SINGLE_DECISIVE_CAUSE"
]

func build_summary(result: Dictionary, player_plan_snapshot: Array, hypothesis_snapshot: Dictionary, state_before: Dictionary) -> Dictionary:
    var safe_result := result.duplicate(true)
    var safe_plan := player_plan_snapshot.duplicate(true)
    var safe_hypothesis := hypothesis_snapshot.duplicate(true)
    var safe_before := state_before.duplicate(true)
    var causes := _collect_causes(safe_result)
    var primary := _primary_cause(causes)
    var before_distance := _distance(safe_before)
    var after_state: Dictionary = safe_result.get("state", {})
    var after_distance := _distance(after_state)
    return {
        "hypothesis": _normalize_hypothesis(safe_hypothesis),
        "player_plan": safe_plan,
        "enemy_actions": _enemy_action_ids(safe_result),
        "decisive_timing": _decisive_timing(safe_result, primary),
        "primary_cause_code": primary,
        "cause_codes": causes,
        "cause_text": _cause_text(primary),
        "distance_before": before_distance,
        "distance_after": after_distance,
        "next_review_dimension": _next_review_dimension(primary)
    }

func _collect_causes(result: Dictionary) -> Array[String]:
    var found: Dictionary = {}
    for timing_value in result.get("timing_results", []):
        if typeof(timing_value) != TYPE_DICTIONARY:
            continue
        for event_value in (timing_value as Dictionary).get("events", []):
            _collect_from_event(event_value, found)
    for event_value in result.get("presentation_events", []):
        _collect_from_event(event_value, found)
    if found.is_empty():
        return ["NO_SINGLE_DECISIVE_CAUSE"]
    var ordered: Array[String] = []
    for code in CAUSE_PRIORITY:
        if found.has(code):
            ordered.append(code)
    return ordered

func _collect_from_event(event_value, found: Dictionary) -> void:
    var text := str(event_value).to_lower()
    var event_type := ""
    var reason := ""
    if typeof(event_value) == TYPE_DICTIONARY:
        var event: Dictionary = event_value
        event_type = str(event.get("type", event.get("event", event.get("event_id", "")))).to_lower()
        reason = str(event.get("reason", event.get("outcome", ""))).to_lower()
        text += " " + event_type + " " + reason
    if "clash" in text or "합" in text:
        found["CLASH_DIFFERENCE"] = true
    if "interrupt" in text or "중단" in text:
        found["INTERRUPTION"] = true
    if "guard" in text or "block" in text or "방어" in text:
        found["GUARD_REDUCTION"] = true
    if "evade" in text or "회피" in text:
        found["EVADE_SUCCESS"] = true
    if "sure_hit" in text or "필중" in text:
        found["SURE_HIT_OVERRIDE"] = true
    if "direction" in text or "방향" in text:
        found["DIRECTION_FAILURE"] = true
    if "range" in text or "사거리" in text:
        found["RANGE_FAILURE"] = true
    if "resource" in text or "insufficient" in text or "자원" in text:
        found["RESOURCE_FAILURE"] = true
    if "position" in text or "distance" in text or "거리" in text:
        found["POSITION_RANGE"] = true
    if "ultimate" in text or "절초" in text:
        found["ULTIMATE_TIMING"] = true

func _primary_cause(causes: Array[String]) -> String:
    for code in CAUSE_PRIORITY:
        if code in causes:
            return code
    return "NO_SINGLE_DECISIVE_CAUSE"

func _decisive_timing(result: Dictionary, primary: String) -> int:
    for timing_value in result.get("timing_results", []):
        if typeof(timing_value) != TYPE_DICTIONARY:
            continue
        var timing: Dictionary = timing_value
        var found: Dictionary = {}
        for event_value in timing.get("events", []):
            _collect_from_event(event_value, found)
        if found.has(primary):
            return int(timing.get("timing", 0))
    return int(result.get("bundle_end", result.get("bundle_start", 0)))

func _enemy_action_ids(result: Dictionary) -> Array[String]:
    var ids: Array[String] = []
    for value in result.get("resolved_actions", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var action: Dictionary = value
        if str(action.get("actor", "")) == "enemy":
            ids.append(str(action.get("card_id", action.get("id", ""))))
    return ids

func _normalize_hypothesis(snapshot: Dictionary) -> Dictionary:
    var hypothesis_id := str(snapshot.get("id", "none"))
    if hypothesis_id.is_empty() or hypothesis_id == "none":
        return {"id": "none", "label": "기록한 가설 없음", "recorded": false}
    return {
        "id": hypothesis_id,
        "label": str(snapshot.get("label", hypothesis_id)),
        "recorded": true
    }

func _distance(state: Dictionary) -> int:
    var player: Dictionary = state.get("player", {})
    var enemy: Dictionary = state.get("enemy", {})
    return absi(int(player.get("tile", 0)) - int(enemy.get("tile", 0)))

func _cause_text(code: String) -> String:
    var labels := {
        "CLASH_DIFFERENCE": "같은 수의 합 차이가 결과를 갈랐습니다.",
        "INTERRUPTION": "피격 중단이 뒤 행동 실행을 막았습니다.",
        "GUARD_REDUCTION": "방어도와 같은 수 반감이 결과를 바꿨습니다.",
        "EVADE_SUCCESS": "회피가 공격을 무효화했습니다.",
        "SURE_HIT_OVERRIDE": "필중이 회피를 무시했습니다.",
        "DIRECTION_FAILURE": "공격 방향이 상대 위치와 어긋났습니다.",
        "RANGE_FAILURE": "실행 시점 사거리가 맞지 않았습니다.",
        "RESOURCE_FAILURE": "실행 자원이 부족했습니다.",
        "POSITION_RANGE": "전후 위치와 거리가 결과를 만들었습니다.",
        "ULTIMATE_TIMING": "절초의 준비·실행 시점이 결정적이었습니다.",
        "NO_SINGLE_DECISIVE_CAUSE": "하나의 원인보다 여러 작은 차이가 누적됐습니다."
    }
    return str(labels.get(code, labels["NO_SINGLE_DECISIVE_CAUSE"]))

func _next_review_dimension(code: String) -> String:
    if code in ["DIRECTION_FAILURE", "RANGE_FAILURE", "POSITION_RANGE"]:
        return "거리와 실행 순서"
    if code in ["GUARD_REDUCTION", "EVADE_SUCCESS", "SURE_HIT_OVERRIDE"]:
        return "대응 선택과 적용 시점"
    if code in ["CLASH_DIFFERENCE", "INTERRUPTION"]:
        return "같은 수 충돌과 중단 위험"
    if code == "RESOURCE_FAILURE":
        return "묶음 자원 예산"
    if code == "ULTIMATE_TIMING":
        return "절초 준비 슬롯과 노출"
    return "다음 묶음에서 바꿀 한 가지"
