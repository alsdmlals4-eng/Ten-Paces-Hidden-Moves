class_name VerticalSliceResultShell
extends VerticalSliceShell

const RESULT_MODEL_SCRIPT := preload("res://src/run/vertical_slice_result_model.gd")

var result_model: VerticalSliceResultModel
var result_options_container: VBoxContainer
var _result_snapshot: Dictionary = {}


func _ready() -> void:
    result_model = RESULT_MODEL_SCRIPT.new()
    super._ready()
    set_meta("result_visual_status", "STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL")
    set_meta("grade_formula_status", "FORMULA_PENDING")
    set_meta("reward_application_status", "DEFERRED_TO_PHASE_V")
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
    if receipt.is_empty() or not run_state.set_pending_result_reward(receipt):
        return false
    _render_result()
    return true


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
    super._render_current_screen()
    if result_options_container != null:
        result_options_container.visible = run_state != null and run_state.get_current_screen() == VerticalSliceRunState.SCREEN_RESULT
    if run_state != null and run_state.get_current_screen() == VerticalSliceRunState.SCREEN_RESULT:
        _render_result()


func _render_result() -> void:
    if result_model == null or run_state == null:
        return
    _refresh_result_snapshot()
    var metrics: Dictionary = _result_snapshot.get("battle_metrics", {})
    var outcome_label := _outcome_label(str(_result_snapshot.get("outcome", "draw")))
    var description := "승부 · %s\n등급 · 산식 미확정 (S/A/B/C 가중치·경계값 Decision 대기)\n\n원지표 · 회피 성공 %d · 합 승리 %d · 잃은 체력 %d · 전투 라운드 %d · 절초 사용 %d\n\n보상은 아래 세 유형 중 하나만 선택합니다. 선택 결과는 기록만 하며 실제 성장 적용은 다음 Phase에서 처리합니다." % [
        outcome_label,
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
    transfer_button.text = _selected_prefix(pending, "faction_transfer", "") + "문파 전수 · %s 3성 receipt" % transfer_name
    transfer_button.pressed.connect(func() -> void: select_result_reward("faction_transfer"))
    result_options_container.add_child(transfer_button)


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
