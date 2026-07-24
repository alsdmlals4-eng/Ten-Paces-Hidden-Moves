extends ActionTimingPanel

func find_earliest_open_anchor(span: int) -> int:
    var required := maxi(1, span)
    for start_value in get_current_bundle_indices():
        var start := int(start_value)
        var fits := true
        for offset in range(required):
            var timing_index := start + offset
            if not is_index_actionable(timing_index) or has_assignment_at(timing_index):
                fits = false
                break
        if fits:
            return start
    return 0
