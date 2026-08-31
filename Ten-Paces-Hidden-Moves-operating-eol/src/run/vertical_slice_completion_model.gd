class_name VerticalSliceCompletionModel
extends RefCounted

const STATUS := "STRUCTURED_RUN_SUMMARY"
const PEER_CLOSING_LINE := "다섯 번 싸워서 다섯 명을 안 건 아니겠지. 네가 어떤 수를 두는 사람인지는 조금 알았을 테고."
const MAX_REVIEW_CAUSES := 3
const MAX_FOCUSED_GROWTH := 2


func build_snapshot(
    duel_history_value: Array,
    reward_history_value: Array,
    route_history_value: Array,
    progression_snapshot_value: Dictionary
) -> Dictionary:
    var duel_rows := _sanitize_duel_rows(duel_history_value)
    var reward_rows := _sanitize_reward_history(reward_history_value)
    var route_rows := _sanitize_route_history(route_history_value)
    return {
        "status": STATUS,
        "duel_rows": duel_rows,
        "top_review_causes": _top_review_causes(duel_rows),
        "focused_growth": _focused_growth(progression_snapshot_value),
        "reward_history": reward_rows,
        "route_choices": route_rows,
        "free_training_pool": maxi(0, int(progression_snapshot_value.get("free_training_pool", 0))),
        "peer_closing_line": PEER_CLOSING_LINE
    }


func _sanitize_duel_rows(values: Array) -> Array:
    var rows: Array = []
    for value in values:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var source: Dictionary = value
        var review: Dictionary = source.get("review_summary", {}) if typeof(source.get("review_summary", {})) == TYPE_DICTIONARY else {}
        rows.append({
            "duel_index": int(source.get("duel_index", 0)),
            "opponent_candidate_id": str(source.get("opponent_candidate_id", "")),
            "opponent_working_name": str(source.get("opponent_working_name", "")),
            "outcome": str(source.get("outcome", "draw")),
            "review_summary": {
                "cause_code": str(review.get("cause_code", "")),
                "cause_label": str(review.get("cause_label", "")),
                "review_focus": str(review.get("review_focus", ""))
            }
        })
    return rows


func _sanitize_reward_history(values: Array) -> Array:
    var rows: Array = []
    for value in values:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var source: Dictionary = value
        rows.append({
            "duel_index": int(source.get("duel_index", 0)),
            "opponent_candidate_id": str(source.get("opponent_candidate_id", "")),
            "reward_type": str(source.get("reward_type", "")),
            "application_status": str(source.get("application_status", "")),
            "target_manual_id": str(source.get("target_manual_id", "")),
            "focused_training": maxi(0, int(source.get("focused_training", 0))),
            "free_training": maxi(0, int(source.get("free_training", 0))),
            "manual_id": str(source.get("manual_id", "")),
            "mastery": maxi(0, int(source.get("mastery", 0)))
        })
    return rows


func _sanitize_route_history(values: Array) -> Array:
    var rows: Array = []
    for value in values:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var source: Dictionary = value
        rows.append({
            "node_id": str(source.get("node_id", "")),
            "route_type": str(source.get("route_type", "")),
            "choice_type": str(source.get("choice_type", "")),
            "target_manual_id": str(source.get("target_manual_id", "")),
            "focused_training": maxi(0, int(source.get("focused_training", 0))),
            "free_training": maxi(0, int(source.get("free_training", 0))),
            "candidate_id": str(source.get("candidate_id", "")),
            "category": str(source.get("category", "")),
            "text": str(source.get("text", ""))
        })
    return rows


func _top_review_causes(duel_rows: Array) -> Array:
    var counts := {}
    var first_seen := {}
    for index in range(duel_rows.size()):
        var row: Dictionary = duel_rows[index]
        var review: Dictionary = row.get("review_summary", {})
        var cause := str(review.get("cause_code", ""))
        if cause.is_empty():
            continue
        counts[cause] = int(counts.get(cause, 0)) + 1
        if not first_seen.has(cause):
            first_seen[cause] = index

    var rows: Array = []
    for cause_value in counts.keys():
        var cause := str(cause_value)
        rows.append({
            "cause_code": cause,
            "count": int(counts[cause]),
            "first_seen": int(first_seen.get(cause, 999))
        })
    _sort_cause_rows(rows)
    return rows.slice(0, mini(MAX_REVIEW_CAUSES, rows.size()))


func _sort_cause_rows(rows: Array) -> void:
    for left in range(rows.size()):
        var best := left
        for right in range(left + 1, rows.size()):
            var candidate: Dictionary = rows[right]
            var current: Dictionary = rows[best]
            var candidate_count := int(candidate.get("count", 0))
            var current_count := int(current.get("count", 0))
            if candidate_count > current_count:
                best = right
            elif candidate_count == current_count and int(candidate.get("first_seen", 999)) < int(current.get("first_seen", 999)):
                best = right
        if best != left:
            var temporary = rows[left]
            rows[left] = rows[best]
            rows[best] = temporary
    for index in range(rows.size()):
        (rows[index] as Dictionary).erase("first_seen")


func _focused_growth(progression_snapshot: Dictionary) -> Array:
    var training: Dictionary = progression_snapshot.get("training_by_manual", {}) if typeof(progression_snapshot.get("training_by_manual", {})) == TYPE_DICTIONARY else {}
    var mastery: Dictionary = progression_snapshot.get("mastery_by_manual", {}) if typeof(progression_snapshot.get("mastery_by_manual", {})) == TYPE_DICTIONARY else {}
    var rows: Array = []
    for manual_id_value in training.keys():
        var manual_id := str(manual_id_value)
        var points := maxi(0, int(training.get(manual_id, 0)))
        if points <= 0:
            continue
        rows.append({
            "manual_id": manual_id,
            "training_points": points,
            "mastery": maxi(0, int(mastery.get(manual_id, 0)))
        })
    _sort_growth_rows(rows)
    return rows.slice(0, mini(MAX_FOCUSED_GROWTH, rows.size()))


func _sort_growth_rows(rows: Array) -> void:
    for left in range(rows.size()):
        var best := left
        for right in range(left + 1, rows.size()):
            var candidate: Dictionary = rows[right]
            var current: Dictionary = rows[best]
            var candidate_points := int(candidate.get("training_points", 0))
            var current_points := int(current.get("training_points", 0))
            if candidate_points > current_points:
                best = right
            elif candidate_points == current_points and str(candidate.get("manual_id", "")) < str(current.get("manual_id", "")):
                best = right
        if best != left:
            var temporary = rows[left]
            rows[left] = rows[best]
            rows[best] = temporary
