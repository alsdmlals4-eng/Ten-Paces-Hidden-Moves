class_name VerticalSliceResultShell
extends VerticalSliceShell

const RESULT_MODEL_SCRIPT := preload("res://src/run/vertical_slice_result_model.gd")

var result_model: VerticalSliceResultModel
var result_options_container: VBoxContainer
var _result_snapshot: Dictionary = {}
var _recorded_review: PanelContainer
var _result_focus_target := ""


func _ready() -> void:
    result_model = RESULT_MODEL_SCRIPT.new()
    super._ready()
    set_meta("result_visual_status", "STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL")
    set_meta("grade_formula_status", "FORMULA_PENDING")
    set_meta("reward_application_status", "APPLIED_ON_RESULT_CONTINUE")
    _build_result_options_container()
    _render_current_screen()


func get_result_snapshot() -> Dictionary:
    if run_state == null or run_state.get_current_screen() != VerticalSliceRunState.SCREEN_RESULT:
        return {}
    _refresh_result_snapshot()
    return _result_snapshot.duplicate(true)


func select_result_reward(reward_type: String, target_manual_id: String = "") -> bool:
    if run_state == null or run_state.get_current_screen() != VerticalSliceRunState.SCREEN_RESULT:
        return false
    var opponent := run_state.get_current_opponent()
    var receipt := result_model.build_reward_receipt(
        reward_type,
        target_manual_id,
        run_state.get_player_manual_loadout(),
        opponent
    )
    if receipt.is_empty(): return false
    _initialize_run_session()
    return session.transact(func(): return run_state.set_pending_result_reward(receipt))


func _build_result_options_container() -> void:
    if primary_button == null or primary_button.get_parent() == null:
        return
    result_options_container = VBoxContainer.new()
    result_options_container.name = "ResultRewardOptions"
    result_options_container.add_theme_constant_override("separation", 6)
    result_options_container.visible = false
    var parent := primary_button.get_parent()
    parent.add_child(result_options_container)
    parent.move_child(result_options_container, primary_button.get_index())


func _render_current_screen() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    super._render_current_screen()
    if result_options_container != null:
        result_options_container.visible = run_state != null and run_state.get_current_screen() == VerticalSliceRunState.SCREEN_RESULT
    if run_state != null and run_state.get_current_screen() == VerticalSliceRunState.SCREEN_RESULT:
        _render_result()
    elif run_state != null and run_state.is_frame_run() and run_state.get_current_screen() == VerticalSliceRunState.SCREEN_FAILURE_RETRY:
        _render_frame_loss()


func _render_frame_loss() -> void:
    result_options_container.visible=true
    for child in result_options_container.get_children():
        result_options_container.remove_child(child)
        child.queue_free()
    var result: Dictionary=run_state.last_combat_result
    var metrics: Dictionary=result.get("battle_metrics",{})
    title_label.text="패 배"
    description_label.text="제 %d전 · %s\n\n남은 체력 %d  ·  합 승리 %d회  ·  회피 %d회\n받은 피해 %d\n\n초식의 흐름을 복기하고 다시 도전할 수 있습니다." % [run_state.duel_index,str(run_state.get_current_opponent().get("working_name","상대")),int(result.get("player_health",0)),int(metrics.get("clash_wins",0)),int(metrics.get("successful_dodges",0)),int(metrics.get("player_health_lost",0))]
    title_label.add_theme_font_size_override("font_size",48)
    var review:=Button.new()
    review.name="ResultReviewButton"
    review.text="비무 복기 · 실제 행동 기록 보기"
    review.custom_minimum_size.y=48
    review.pressed.connect(_open_recorded_review)
    result_options_container.add_child(review)


func _render_result() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    if result_model == null or run_state == null:
        return
    _refresh_result_snapshot()
    if run_state.is_frame_run():
        _render_frame_result()
        return
    var metrics: Dictionary = _result_snapshot.get("battle_metrics", {})
    var outcome_label := _outcome_label(str(_result_snapshot.get("outcome", "draw")))
    var review_summary: Dictionary = _result_snapshot.get("review_summary", {})
    var cause_label := str(review_summary.get("cause_label", "")).strip_edges()
    if cause_label.is_empty():
        cause_label = "확정된 전투 결과"
    var description := "승부 · %s\n결정 원인 · %s\n등급 · 산식 미확정\n\n전투 기록 · 회피 성공 %d · 합 승리 %d · 잃은 체력 %d · 전투 라운드 %d · 절초 사용 %d\n\n보상을 하나 고른 뒤 확정하면 수련에 반영됩니다." % [
        outcome_label,
        cause_label,
        int(metrics.get("successful_dodges", 0)),
        int(metrics.get("clash_wins", 0)),
        int(metrics.get("player_health_lost", 0)),
        int(metrics.get("rounds_elapsed", 0)),
        int(metrics.get("ultimate_uses", 0))
    ]
    var next_label := "보상 확정 후 완주 정리" if run_state.completed_duels >= VerticalSliceRunState.MAX_DUELS else "보상 확정 후 강호행로로"
    _set_content("비무 %d 결과" % run_state.completed_duels, description, next_label)
    primary_button.disabled = run_state.get_pending_result_reward().is_empty()
    _rebuild_result_reward_buttons()
    _apply_session_input_lock()


func _refresh_result_snapshot() -> void:
    if result_model == null or run_state == null:
        _result_snapshot = {}
        return
    _result_snapshot = result_model.build_snapshot(
        run_state.last_combat_result,
        run_state.get_player_manual_loadout(),
        run_state.get_current_opponent()
    )


func _rebuild_result_reward_buttons() -> void:
    if result_options_container == null:
        return
    for child in result_options_container.get_children():
        result_options_container.remove_child(child)
        child.queue_free()

    var pending := run_state.get_pending_result_reward()
    var free_button := Button.new()
    free_button.text = _selected_prefix(pending, "free_training", "") + "자유 수련 · 자유 수련 +6"
    free_button.pressed.connect(func() -> void: select_result_reward("free_training"))
    result_options_container.add_child(free_button)

    for manual_id_value in run_state.get_player_manual_loadout():
        var manual_id := str(manual_id_value)
        var manual := manual_registry.get_manual(manual_id) if manual_registry != null else {}
        var manual_name := str(manual.get("manual_name", manual_id))
        var focused_button := Button.new()
        focused_button.text = _selected_prefix(pending, "focused_training", manual_id) + "집중 수련 · %s +5 / 자유 +3" % manual_name
        focused_button.pressed.connect(func() -> void: select_result_reward("focused_training", manual_id))
        result_options_container.add_child(focused_button)

    var opponent := run_state.get_current_opponent()
    var signature_manual_id := str(opponent.get("signature_manual_id", ""))
    var signature_manual := manual_registry.get_manual(signature_manual_id) if manual_registry != null else {}
    var transfer_name := str(signature_manual.get("manual_name", signature_manual_id))
    var transfer_button := Button.new()
    transfer_button.text = _selected_prefix(pending, "faction_transfer", "") + "문파 전수 · %s 3성" % transfer_name
    transfer_button.pressed.connect(func() -> void: select_result_reward("faction_transfer"))
    result_options_container.add_child(transfer_button)


func _render_frame_result() -> void:
    var metrics: Dictionary = _result_snapshot.get("battle_metrics", {})
    var review: Dictionary = _result_snapshot.get("review_summary", {})
    var resources: Dictionary = run_state.get_player_run_resources()
    var opponent := run_state.get_current_opponent()
    var outcome := _outcome_label(str(_result_snapshot.get("outcome", "draw")))
    var cause := str(review.get("cause_label", "확정된 전투 결과"))
    var description := "%s와의 비무 · %s\n받은 피해 %d  ·  행동 구간 %d회" % [str(opponent.get("working_name", "상대")), cause, int(metrics.get("player_health_lost", 0)), int(metrics.get("rounds_elapsed", 0))]
    _set_content(outcome, description, "보상 받고 완주 정리" if run_state.completed_duels >= VerticalSliceRunState.MAX_DUELS else "보상 받고 강호행로로")
    var compact := get_viewport_rect().size.y < 760
    title_label.add_theme_font_size_override("font_size", 34 if compact else 48)
    description_label.add_theme_font_size_override("font_size", 16 if compact else 17)
    primary_button.disabled = run_state.get_pending_result_reward().is_empty()
    content_panel.anchor_left = 0.075
    content_panel.anchor_right = 0.925
    content_panel.anchor_top = 0.035
    content_panel.anchor_bottom = 0.965
    for child in result_options_container.get_children():
        result_options_container.remove_child(child)
        child.queue_free()
    var highlights := HBoxContainer.new()
    highlights.name = "FrameBattleHighlights"
    highlights.add_theme_constant_override("separation", 12)
    for item in [{"label": "남은 체력", "value": "%d / %d" % [resources.health[0], resources.health[1]]}, {"label": "합 승리", "value": "%d회" % int(metrics.get("clash_wins", 0))}, {"label": "회피 성공", "value": "%d회" % int(metrics.get("successful_dodges", 0))}]:
        var highlight := Label.new()
        highlight.text = str(item.label) + "\n" + str(item.value)
        highlight.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        highlight.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        highlight.add_theme_font_size_override("font_size", 20 if compact else 26)
        highlight.add_theme_color_override("font_color", Color("eee5d2"))
        var ink := StyleBoxFlat.new()
        ink.bg_color = Color("292c27")
        ink.content_margin_top = 10
        ink.content_margin_bottom = 10
        highlight.add_theme_stylebox_override("normal", ink)
        highlights.add_child(highlight)
    result_options_container.add_child(highlights)
    var reward_label := Label.new()
    reward_label.text = "수련 보상 · 하나를 선택합니다"
    reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    reward_label.add_theme_font_size_override("font_size", 20)
    result_options_container.add_child(reward_label)
    var cards := HBoxContainer.new()
    cards.name = "FrameRewardCards"
    cards.add_theme_constant_override("separation", 12)
    result_options_container.add_child(cards)
    var pending := run_state.get_pending_result_reward()
    var art = preload("res://src/ui/approved_blueprint_art.gd")
    var free := _frame_reward_button(_selected_prefix(pending, "free_training", "") + "자유 수련\n수련 +6", load("res://assets/portraits/player_wanderer_ink_v1.png"))
    free.name = "ResultFreeTraining"
    free.pressed.connect(func(): select_result_reward("free_training"))
    cards.add_child(free)
    var owned := run_state.get_player_manual_loadout()
    if _result_focus_target not in owned: _result_focus_target = str(owned[0]) if not owned.is_empty() else ""
    if pending.get("reward_type") == "focused_training": _result_focus_target = str(pending.target_manual_id)
    var focus_column := VBoxContainer.new()
    focus_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cards.add_child(focus_column)
    var focused := _frame_reward_button(_selected_prefix(pending, "focused_training", _result_focus_target) + "집중 수련\n선택 무공 +5 · 자유 +3", art.manual_illustration(_result_focus_target, 3))
    focused.name = "ResultFocusedTraining"
    focused.pressed.connect(func(): select_result_reward("focused_training", _result_focus_target))
    focus_column.add_child(focused)
    var target := OptionButton.new()
    target.name = "ResultFocusManual"
    target.accessibility_name = "집중 수련할 보유 무공"
    for id in owned:
        target.add_item(str(manual_registry.get_manual(id).get("manual_name", id)))
        target.set_item_metadata(target.item_count - 1, id)
        if str(id) == _result_focus_target: target.select(target.item_count - 1)
    target.item_selected.connect(func(index: int):
        _result_focus_target = str(target.get_item_metadata(index))
        if run_state.get_pending_result_reward().get("reward_type") == "focused_training": select_result_reward("focused_training", _result_focus_target)
        else: _render_current_screen())
    focus_column.add_child(target)
    var signature := str(opponent.get("signature_manual_id", ""))
    var transfer_name := str(manual_registry.get_manual(signature).get("manual_name", signature))
    var transfer := _frame_reward_button(_selected_prefix(pending, "faction_transfer", "") + "문파 전수\n%s 3성" % transfer_name, art.manual_illustration(signature, 3))
    transfer.name = "ResultFactionTransfer"
    transfer.pressed.connect(func(): select_result_reward("faction_transfer"))
    cards.add_child(transfer)
    var review_button := Button.new()
    review_button.name = "ResultReviewButton"
    review_button.text = "비무 복기 · 실제 행동 기록 보기"
    review_button.custom_minimum_size.y = 44
    review_button.pressed.connect(_open_recorded_review)
    result_options_container.add_child(review_button)
    _apply_session_input_lock()


func _frame_reward_button(text: String, texture: Texture2D) -> Button:
    var button := Button.new()
    button.text = text
    button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    button.icon = texture
    button.expand_icon = true
    button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
    button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
    var compact := get_viewport_rect().size.y < 760
    button.add_theme_constant_override("icon_max_width", 54 if compact else 90)
    button.add_theme_font_size_override("font_size", 16 if compact else 18)
    button.custom_minimum_size = Vector2(0, 112 if compact else 150)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return button


func _open_recorded_review() -> void:
    if session != null and not session.accepts_commands(): return
    if _recorded_review != null:
        _recorded_review.show()
        return
    _recorded_review = PanelContainer.new()
    _recorded_review.name = "RecordedCombatReview"
    _recorded_review.anchor_left = 0.055
    _recorded_review.anchor_right = 0.945
    _recorded_review.anchor_top = 0.045
    _recorded_review.anchor_bottom = 0.955
    var style := StyleBoxFlat.new()
    style.bg_color = Color("eee5d2")
    style.border_color = Color("af8e53")
    style.set_border_width_all(3)
    for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]: style.set_content_margin(side, 24)
    _recorded_review.add_theme_stylebox_override("panel", style)
    add_child(_recorded_review)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 16)
    _recorded_review.add_child(stack)
    var heading := Label.new()
    heading.text = "비무 복기 · %s" % str(run_state.get_current_opponent().get("working_name", "상대"))
    heading.add_theme_font_size_override("font_size", 30)
    stack.add_child(heading)
    var hint := Label.new()
    hint.text = "확정된 시간과 행동을 다시 읽습니다. 이 화면은 승부와 보상을 바꾸지 않습니다."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    stack.add_child(hint)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.follow_focus = true
    stack.add_child(scroll)
    var text := Label.new()
    text.name = "RecordedReviewText"
    text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    text.add_theme_font_size_override("font_size", 19)
    text.text = _recorded_review_text()
    scroll.add_child(text)
    var close := Button.new()
    close.name = "RecordedReviewClose"
    close.text = "결과로 돌아가기"
    close.custom_minimum_size.y = 48
    close.pressed.connect(func():
        remove_child(_recorded_review)
        _recorded_review.queue_free()
        _recorded_review = null)
    stack.add_child(close)
    close.grab_focus()


func _recorded_review_text() -> String:
    var summary: Dictionary = run_state.last_combat_result.get("review_summary", {})
    var lines: Array[String] = []
    var windows: Array = summary.get("windows", [])
    for index in range(windows.size()):
        var window: Dictionary = windows[index]
        lines.append("── %d번째 10초 ──" % (index + 1))
        for event in window.get("events", []):
            if typeof(event) != TYPE_DICTIONARY: continue
            var actor := "나" if event.get("actor") == "player" else "상대" if event.get("actor") == "enemy" else "전장"
            var label := str(event.get("label", event.get("text", event.get("message", event.get("kind", event.get("type", "기록"))))))
            var suffix := " · 피해 %d" % int(event.damage) if event.has("damage") else ""
            lines.append("%.1f초  %s · %s%s" % [float(event.get("tick", 0)) / 10.0, actor, label, suffix])
            if event.has("changes"):lines.append("     "+str(event.changes))
        lines.append("")
    if lines.is_empty():
        for cause in summary.get("causes", []):
            if typeof(cause) == TYPE_DICTIONARY: lines.append(str(cause.get("label", "")))
    return "\n".join(lines) if not lines.is_empty() else "이 전투에는 저장된 개별 행동 기록이 없습니다."


func _selected_prefix(pending: Dictionary, reward_type: String, target_manual_id: String) -> String:
    if str(pending.get("reward_type", "")) != reward_type:
        return ""
    if reward_type == "focused_training" and str(pending.get("target_manual_id", "")) != target_manual_id:
        return ""
    return "✓ "


func _outcome_label(outcome: String) -> String:
    match outcome:
        "win":
            return "승리"
        "loss":
            return "패배"
        _:
            return "무승부"
