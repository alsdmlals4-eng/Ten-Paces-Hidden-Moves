extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var builder := CombatReviewSummaryBuilder.new()
    var before := {"player": {"tile": 4}, "enemy": {"tile": 7}}
    var result := {
        "state": {"player": {"tile": 5}, "enemy": {"tile": 6}},
        "bundle_start": 1,
        "bundle_end": 3,
        "resolved_actions": [{"actor": "enemy", "card_id": "basic_heavy_attack"}],
        "timing_results": [{"timing": 2, "events": [{"type": "clash", "outcome": "difference"}, {"type": "interrupt"}]}],
        "presentation_events": []
    }
    var original := result.duplicate(true)
    var summary := builder.build_summary(result, [{"card_id": "basic_guard"}], {"id": "none"}, before)
    if summary.get("primary_cause_code") != "CLASH_DIFFERENCE":
        push_error("Clash must outrank interruption.")
        quit(1)
        return
    if summary.get("decisive_timing") != 2 or summary.get("distance_before") != 3 or summary.get("distance_after") != 1:
        push_error("Summary timing or distance snapshot changed.")
        quit(1)
        return
    if (summary.get("hypothesis", {}) as Dictionary).get("label") != "기록한 가설 없음":
        push_error("None hypothesis was inferred or renamed.")
        quit(1)
        return
    if result != original:
        push_error("Summary builder mutated authoritative result input.")
        quit(1)
        return
    var range_summary := builder.build_summary({"state": before, "timing_results": [{"timing": 1, "events": [{"reason": "range_failure"}]}]}, [], {"id": "approach", "label": "접근할 것이다"}, before)
    if range_summary.get("primary_cause_code") != "RANGE_FAILURE":
        push_error("Range fixture cause changed.")
        quit(1)
        return
    print("COMBAT_REVIEW_SUMMARY_VERIFY_OK")
    quit(0)
