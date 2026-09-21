class_name VerticalSliceResultShell
extends VerticalSliceShell

const RESULT_MODEL_SCRIPT := preload("res://src/run/vertical_slice_result_model.gd")

var result_model: VerticalSliceResultModel
var result_options_container: VBoxContainer
var _result_snapshot: Dictionary = {}
var _result_scroll: ScrollContainer
var _result_choice_keys: Array[String] = []


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
        run_state.get_owned_player_manuals(),
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
    result_options_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _result_scroll = ScrollContainer.new()
    _result_scroll.name = "ResultRewardsScroll"
    _result_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    _result_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    _result_scroll.follow_focus = true
    var scroll_padding := StyleBoxEmpty.new()
    for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
        scroll_padding.set_content_margin(side, 4.0)
    _result_scroll.add_theme_stylebox_override("panel", scroll_padding)
    _result_scroll.accessibility_name = "비무 보상 선택 · 위아래로 탐색"
    _result_scroll.hide()
    var parent := primary_button.get_parent()
    parent.add_child(_result_scroll)
    parent.move_child(_result_scroll, primary_button.get_index())
    _result_scroll.add_child(result_options_container)


func _render_current_screen() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    super._render_current_screen()
    if result_options_container != null:
        result_options_container.visible = run_state != null and run_state.get_current_screen() == VerticalSliceRunState.SCREEN_RESULT
        _result_scroll.visible = result_options_container.visible
        if not result_options_container.visible:
            primary_button.focus_previous = NodePath()
            primary_button.focus_next = NodePath()
            primary_button.focus_neighbor_top = NodePath()
            primary_button.focus_neighbor_bottom = NodePath()
    if run_state != null and run_state.get_current_screen() == VerticalSliceRunState.SCREEN_RESULT:
        _render_result()


func _render_result() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    if result_model == null or run_state == null:
        return
    _refresh_result_snapshot()
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
    description += "\n첫 선택은 변경할 수 없으며, 확정할 때 적용됩니다." if run_state.get_pending_result_reward().is_empty() else "\n선택을 저장했습니다. 아래 확정 버튼으로 진행하세요."
    description += "\n\n" + preload("res://src/run/battle_grade_aggregator.gd").explanation(_result_snapshot.get("grade_summary",{}))
    var next_label := "보상 확정 후 완주 정리" if run_state.completed_duels >= VerticalSliceRunState.MAX_DUELS else "보상 확정 후 강호행로로"
    _set_content("비무 %d 결과" % run_state.completed_duels, description, next_label)
    primary_button.disabled = run_state.get_pending_result_reward().is_empty()
    _rebuild_result_reward_buttons()
    content_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    content_panel.anchor_left = 0.14
    content_panel.anchor_top = 0.08
    content_panel.anchor_right = 0.86
    content_panel.anchor_bottom = 0.92
    _apply_session_input_lock()


func _refresh_result_snapshot() -> void:
    if result_model == null or run_state == null:
        _result_snapshot = {}
        return
    _result_snapshot = result_model.build_snapshot(
        run_state.last_combat_result,
        run_state.get_owned_player_manuals(),
        run_state.get_current_opponent()
    )


func _rebuild_result_reward_buttons() -> void:
    if result_options_container == null:
        return
    var choices: Array[Dictionary] = [{"key": "free_training", "type": "free_training", "target": "", "label": "자유 수련 · 자유 수련 +6"}]
    for manual_id_value in run_state.get_owned_player_manuals():
        var manual_id := str(manual_id_value)
        var manual := manual_registry.get_manual(manual_id) if manual_registry != null else {}
        var manual_name := str(manual.get("manual_name", manual_id))
        choices.append({"key": "focused_training:" + manual_id, "type": "focused_training", "target": manual_id, "label": "집중 수련 · %s +5 / 자유 +3" % manual_name})
    var opponent := run_state.get_current_opponent()
    var signature_manual_id := str(opponent.get("signature_manual_id", ""))
    var signature_manual := manual_registry.get_manual(signature_manual_id) if manual_registry != null else {}
    var transfer_name := str(signature_manual.get("manual_name", signature_manual_id))
    var transfer_label := "문파 전수 · %s 3성" % transfer_name
    var transfer_view: Dictionary = _result_snapshot.reward_options[2]
    var transfer_available: bool = transfer_view.get("available", false)
    var historical_selected: bool = run_state.get_pending_result_reward().get("reward_type", "") == "faction_transfer"
    if not transfer_available:
        transfer_label = "문파 전수 · %s · 이미 보유한 무공 (선택 불가)" % transfer_name
        if transfer_view.get("unavailable_reason_key", "") == "MISSING_MANUAL":
            transfer_label = "문파 전수 · 전수할 무공 없음 (선택 불가)"
        if historical_selected:
            transfer_label = "문파 전수 · %s · 이전 선택 유지 (전수 기록만 보관)" % transfer_name
    choices.append({"key": "faction_transfer:" + signature_manual_id, "type": "faction_transfer", "target": "", "label": transfer_label, "available": transfer_available or historical_selected})
    var keys: Array[String] = []
    for choice in choices: keys.append(choice.key)
    # Stable identities retain focus and scroll when only selection changes.
    if keys != _result_choice_keys:
        for child in result_options_container.get_children():
            result_options_container.remove_child(child)
            child.queue_free()
        for choice in choices:
            var button := Button.new()
            button.custom_minimum_size.y = 44.0
            button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            button.set_meta("reward_key", choice.key)
            button.pressed.connect(select_result_reward.bind(choice.type, choice.target))
            button.focus_entered.connect(_keep_result_choice_visible.bind(button))
            result_options_container.add_child(button)
        _result_choice_keys = keys
    var pending := run_state.get_pending_result_reward()
    var buttons := result_options_container.get_children()
    for index in range(choices.size()):
        var choice := choices[index]
        var button := buttons[index] as Button
        var selected_prefix := _selected_prefix(pending, choice.type, choice.target)
        button.text = selected_prefix + str(choice.label)
        button.disabled = not choice.get("available", true) or (not pending.is_empty() and selected_prefix.is_empty())
        button.focus_mode = Control.FOCUS_NONE if button.disabled else Control.FOCUS_ALL
        button.accessibility_name = button.text
    var available: Array[Control] = []
    for button in buttons:
        if not button.disabled: available.append(button)
    for index in range(available.size()):
        var button := available[index]
        var previous: Control = available[index - 1] if index > 0 else menu_button
        var following: Control = available[index + 1] if index + 1 < available.size() else (primary_button if not primary_button.disabled else menu_button)
        if previous != null:
            button.focus_previous = button.get_path_to(previous)
            button.focus_neighbor_top = button.focus_previous
        if following != null:
            button.focus_next = button.get_path_to(following)
            button.focus_neighbor_bottom = button.focus_next
    var last_available: Control = buttons.back()
    for button in buttons:
        if not button.disabled: last_available = button
    primary_button.focus_previous = primary_button.get_path_to(last_available)
    primary_button.focus_neighbor_top = primary_button.focus_previous
    if menu_button != null:
        primary_button.focus_next = primary_button.get_path_to(menu_button)
        primary_button.focus_neighbor_bottom = primary_button.focus_next


func _keep_result_choice_visible(button: Button) -> void:
    # Let container layout settle, then account for the panel's focus-ring inset.
    await get_tree().process_frame
    if not is_instance_valid(button) or not button.is_visible_in_tree() or get_viewport().gui_get_focus_owner() != button:
        return
    _result_scroll.ensure_control_visible(button)
    var viewport_rect := _result_scroll.get_global_rect().grow(-4.0)
    var button_rect := button.get_global_rect()
    if button_rect.end.y > viewport_rect.end.y:
        _result_scroll.scroll_vertical += ceili(button_rect.end.y - viewport_rect.end.y)
    elif button_rect.position.y < viewport_rect.position.y:
        _result_scroll.scroll_vertical -= ceili(viewport_rect.position.y - button_rect.position.y)


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
