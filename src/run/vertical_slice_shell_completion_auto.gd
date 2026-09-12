class_name VerticalSliceCompletionShell
extends VerticalSliceRouteShell

const COMPLETION_MODEL_SCRIPT := preload("res://src/run/vertical_slice_completion_model.gd")

var completion_model: VerticalSliceCompletionModel
var _completion_snapshot: Dictionary = {}
var _completion_scroll: ScrollContainer


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
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    super._render_current_screen()
    if run_state != null and run_state.get_current_screen() == VerticalSliceRunState.SCREEN_COMPLETION:
        _render_completion()


func _render_completion() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    if completion_model == null or run_state == null:
        return
    _refresh_completion_snapshot()
    var lines: Array[String] = []
    lines.append("10전 결과")
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
                var cause_label := str(CombatReviewSummaryBuilder.CAUSE_LABELS.get(str(cause.get("cause_code", "")), "기록된 전투 흐름을 다시 확인하세요."))
                lines.append("%s · %d회" % [cause_label, int(cause.get("count", 0))])

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
    var stack := primary_button.get_parent()
    if _completion_scroll == null:
        _completion_scroll = ScrollContainer.new()
        _completion_scroll.name = "CompletionHistoryScroll"
        _completion_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        _completion_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
        _completion_scroll.focus_mode = Control.FOCUS_ALL
        _completion_scroll.accessibility_name = "열 번의 비무 결과와 복기 · 위아래로 스크롤"
        stack.add_child(_completion_scroll)
        stack.move_child(_completion_scroll, 1)
    _completion_scroll.show()
    description_label.reparent(_completion_scroll)
    description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    content_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    content_panel.anchor_left = 0.14
    content_panel.anchor_top = 0.08
    content_panel.anchor_right = 0.86
    content_panel.anchor_bottom = 0.92


func _set_content(title: String, description: String, button_text: String) -> void:
    if is_instance_valid(_completion_scroll):
        _completion_scroll.hide()
        if description_label.get_parent() == _completion_scroll:
            var stack := primary_button.get_parent()
            description_label.reparent(stack)
            stack.move_child(description_label, 1)
            description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    super._set_content(title, description, button_text)


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
