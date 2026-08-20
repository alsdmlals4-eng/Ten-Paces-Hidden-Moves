class_name VerticalSliceCompletionShell
extends VerticalSliceRouteShell

const COMPLETION_MODEL_SCRIPT := preload("res://src/run/vertical_slice_completion_model.gd")

var completion_model: VerticalSliceCompletionModel
var _completion_snapshot: Dictionary = {}


func _ready() -> void:
    completion_model = COMPLETION_MODEL_SCRIPT.new()
    super._ready()
    set_meta("completion_visual_status", "STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL")
    set_meta("completion_summary_policy", "PLAYER_VISIBLE_RUN_HISTORY_ONLY")
    _render_current_screen()


func get_completion_snapshot() -> Dictionary:
    if run_state == null or run_state.get_current_screen() != VerticalSliceRunState.SCREEN_COMPLETION:
        return {}
    _refresh_completion_snapshot()
    return _completion_snapshot.duplicate(true)


func _render_current_screen() -> void:
    super._render_current_screen()
    if run_state != null and run_state.get_current_screen() == VerticalSliceRunState.SCREEN_COMPLETION:
        _render_completion()


func _render_completion() -> void:
    if completion_model == null or run_state == null:
        return
    _refresh_completion_snapshot()
    var lines: Array[String] = []
    lines.append("5전 결과")
    for value in _completion_snapshot.get("duel_rows", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var row: Dictionary = value
        lines.append("비무 %d · %s · %s" % [
            int(row.get("duel_index", 0)),
            str(row.get("opponent_working_name", row.get("opponent_candidate_id", "상대"))),
            _outcome_label(str(row.get("outcome", "draw")))
        ])

    var causes: Array = _completion_snapshot.get("top_review_causes", [])
    if not causes.is_empty():
        lines.append("")
        lines.append("많이 남은 복기 원인")
        for value in causes:
            if typeof(value) == TYPE_DICTIONARY:
                var cause: Dictionary = value
                lines.append("%s · %d회" % [str(cause.get("cause_code", "")), int(cause.get("count", 0))])

    var growth: Array = _completion_snapshot.get("focused_growth", [])
    if not growth.is_empty():
        lines.append("")
        lines.append("집중 성장")
        for value in growth:
            if typeof(value) != TYPE_DICTIONARY:
                continue
            var row: Dictionary = value
            var manual_id := str(row.get("manual_id", ""))
            var manual := manual_registry.get_manual(manual_id) if manual_registry != null else {}
            lines.append("%s · 누적 수련 %d · %d성" % [
                str(manual.get("manual_name", manual_id)),
                int(row.get("training_points", 0)),
                int(row.get("mastery", 0))
            ])

    lines.append("")
    lines.append("행로 선택 · %d회 / 보상 기록 · %d회" % [
        (_completion_snapshot.get("route_choices", []) as Array).size(),
        (_completion_snapshot.get("reward_history", []) as Array).size()
    ])
    lines.append("")
    lines.append(str(_completion_snapshot.get("peer_closing_line", "")))

    _set_content(
        "첫 강호 비무행 완주",
        "\n".join(lines),
        "기록 확인 완료"
    )
    primary_button.disabled = true


func _refresh_completion_snapshot() -> void:
    if completion_model == null or run_state == null:
        _completion_snapshot = {}
        return
    _completion_snapshot = completion_model.build_snapshot(
        run_state.get_duel_history(),
        run_state.get_reward_history(),
        run_state.get_route_history(),
        run_state.get_progression_snapshot()
    )
