class_name VerticalSliceShell
extends Control

const COMBAT_SCENE := preload("res://scenes/run/vertical_slice_combat_bridge.tscn")
const OpponentRuntimeBindingScript := preload("res://src/run/vertical_slice_opponent_runtime_binding.gd")
const TECHNICAL_RUN_SEED := 20260820

var run_state: VerticalSliceRunState
var opponent_catalog: VerticalSliceOpponentCatalog
var starter_manual_catalog: VerticalSliceStarterManualCatalog
var manual_registry: MartialManualRegistry
var content_panel: PanelContainer
var combat_host: Control
var title_label: Label
var description_label: Label
var primary_button: Button
var failure_end_button: Button
var setup_options_container: VBoxContainer

var _combat_view: Control
var _combat_view_duel_index: int = 0
var _setup_buttons: Dictionary = {}
var _setup_selected_manual_ids: Array[String] = []


func _ready() -> void:
    set_meta("technical_shell", true)
    set_meta("final_visual_reference_pending", false)
    set_meta("visual_evidence_ceiling", "TECHNICAL_SHELL_NOT_HUMAN_VISUAL_PASS")
    set_meta("run_seed_policy", "PHASE_II_TECHNICAL_FIXED_SEED_REPLACE_WITH_SAVE_STATE_LATER")
    set_meta("setup_visual_status", "STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL")
    set_meta("briefing_visual_status", "STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL")

    opponent_catalog = VerticalSliceOpponentCatalog.new()
    starter_manual_catalog = VerticalSliceStarterManualCatalog.new()
    manual_registry = MartialManualRegistry.new()
    run_state = VerticalSliceRunState.new()
    var catalog_bound := false
    if opponent_catalog.is_valid():
        catalog_bound = run_state.configure_opponents(opponent_catalog, TECHNICAL_RUN_SEED)
    else:
        push_error("Vertical Slice opponent catalog is invalid: %s" % str(opponent_catalog.load_errors))
    set_meta("opponent_catalog_bound", catalog_bound)
    set_meta("opponent_selection_binding", opponent_catalog.get_selection_binding_status())
    set_meta("starter_manual_catalog_valid", starter_manual_catalog.is_valid())

    run_state.screen_changed.connect(_on_screen_changed)
    _build_shell()
    _build_setup_options()
    _render_current_screen()


func start_new_run() -> bool:
    _setup_selected_manual_ids.clear()
    _refresh_setup_selection_ui()
    return run_state.start_new_run()


func advance_noncombat() -> bool:
    var screen := run_state.get_current_screen()
    if screen == VerticalSliceRunState.SCREEN_COMBAT or screen == VerticalSliceRunState.SCREEN_REVIEW:
        return false
    if screen == VerticalSliceRunState.SCREEN_SETUP:
        if starter_manual_catalog == null or not starter_manual_catalog.validate_selection(_setup_selected_manual_ids):
            return false
        var mastery := starter_manual_catalog.build_mastery(_setup_selected_manual_ids)
        if not run_state.confirm_setup_loadout(_setup_selected_manual_ids, mastery):
            return false
    return run_state.advance()


func retry_failed_combat() -> bool:
    if run_state == null or run_state.get_current_screen() != VerticalSliceRunState.SCREEN_FAILURE_RETRY:
        return false
    _discard_combat_view()
    return run_state.retry_failed_duel()


func end_failed_run() -> bool:
    if run_state == null:
        return false
    _discard_combat_view()
    return run_state.end_failed_run()


func complete_combat_for_runtime(result: Dictionary) -> bool:
    return run_state.mark_combat_finished(result)


func complete_review_for_runtime() -> bool:
    if run_state.get_current_screen() != VerticalSliceRunState.SCREEN_REVIEW:
        return false
    return run_state.advance()


func get_setup_option_button_count() -> int:
    return _setup_buttons.size()


func get_setup_selected_manual_ids() -> Array:
    return _setup_selected_manual_ids.duplicate()


func toggle_setup_manual(manual_id: String) -> bool:
    if run_state == null or run_state.get_current_screen() != VerticalSliceRunState.SCREEN_SETUP:
        return false
    if not _setup_buttons.has(manual_id):
        return false
    var should_select := not manual_id in _setup_selected_manual_ids
    return _set_setup_manual_selected(manual_id, should_select)


func get_active_combat_loadout_snapshot() -> Dictionary:
    if _combat_view == null or not is_instance_valid(_combat_view):
        return {}
    if not _combat_view.has_method("get_vertical_slice_loadout_snapshot"):
        return {}
    return _combat_view.call("get_vertical_slice_loadout_snapshot") as Dictionary


func _build_shell() -> void:
    var background := ColorRect.new()
    background.name = "TechnicalBackground"
    background.color = Color("171411")
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)
    move_child(background, 0)

    combat_host = Control.new()
    combat_host.name = "CombatHost"
    combat_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    combat_host.visible = false
    add_child(combat_host)

    content_panel = PanelContainer.new()
    content_panel.name = "ContentPanel"
    content_panel.anchor_left = 0.14
    content_panel.anchor_top = 0.08
    content_panel.anchor_right = 0.86
    content_panel.anchor_bottom = 0.92
    content_panel.offset_left = 0.0
    content_panel.offset_top = 0.0
    content_panel.offset_right = 0.0
    content_panel.offset_bottom = 0.0
    add_child(content_panel)

    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color("241f1a")
    panel_style.border_color = Color("7f6847")
    panel_style.set_border_width_all(2)
    panel_style.set_corner_radius_all(8)
    content_panel.add_theme_stylebox_override("panel", panel_style)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 40)
    margin.add_theme_constant_override("margin_top", 30)
    margin.add_theme_constant_override("margin_right", 40)
    margin.add_theme_constant_override("margin_bottom", 30)
    content_panel.add_child(margin)

    var stack := VBoxContainer.new()
    stack.alignment = BoxContainer.ALIGNMENT_CENTER
    stack.add_theme_constant_override("separation", 14)
    margin.add_child(stack)

    var technical_label := Label.new()
    technical_label.text = "PC-FIRST VERTICAL SLICE · FUNCTIONAL UI"
    technical_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    technical_label.add_theme_color_override("font_color", Color("b99254"))
    technical_label.add_theme_font_size_override("font_size", 15)
    stack.add_child(technical_label)

    title_label = Label.new()
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.add_theme_color_override("font_color", Color("eadfc9"))
    title_label.add_theme_font_size_override("font_size", 30)
    stack.add_child(title_label)

    description_label = Label.new()
    description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description_label.custom_minimum_size = Vector2(0.0, 100.0)
    description_label.add_theme_color_override("font_color", Color("c9bca8"))
    description_label.add_theme_font_size_override("font_size", 17)
    stack.add_child(description_label)

    setup_options_container = VBoxContainer.new()
    setup_options_container.name = "SetupManualOptions"
    setup_options_container.add_theme_constant_override("separation", 6)
    setup_options_container.visible = false
    stack.add_child(setup_options_container)

    primary_button = Button.new()
    primary_button.custom_minimum_size = Vector2(260.0, 52.0)
    primary_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    primary_button.pressed.connect(_on_primary_button_pressed)
    stack.add_child(primary_button)

    failure_end_button = Button.new()
    failure_end_button.name = "FailureEndRunButton"
    failure_end_button.custom_minimum_size = Vector2(260.0, 42.0)
    failure_end_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    failure_end_button.text = "비무행 끝내기"
    failure_end_button.visible = false
    failure_end_button.pressed.connect(end_failed_run)
    stack.add_child(failure_end_button)

    var pending_label := Label.new()
    pending_label.name = "VisualReferenceStatus"
    pending_label.text = "승인 전투 레퍼런스 확인됨 · 현재 UI는 기능/정보 위계 검증용"
    pending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    pending_label.add_theme_color_override("font_color", Color("8d8375"))
    pending_label.add_theme_font_size_override("font_size", 13)
    stack.add_child(pending_label)


func _build_setup_options() -> void:
    _setup_buttons.clear()
    if setup_options_container == null or starter_manual_catalog == null or not starter_manual_catalog.is_valid():
        return
    for option_value in starter_manual_catalog.get_options():
        if typeof(option_value) != TYPE_DICTIONARY:
            continue
        var option := option_value as Dictionary
        var manual_id := str(option.get("manual_id", ""))
        var button := Button.new()
        button.name = "Starter_%s" % manual_id
        button.toggle_mode = true
        button.custom_minimum_size = Vector2(680.0, 40.0)
        button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        button.text = "[%s] %s · 3성 %s · %s/%s" % [
            str(option.get("faction", "")),
            str(option.get("manual_name", "")),
            str(option.get("star3_card_name", "")),
            str(option.get("primary_stat", "")),
            str(option.get("secondary_stat", ""))
        ]
        button.set_meta("manual_id", manual_id)
        button.toggled.connect(_on_setup_manual_toggled.bind(manual_id))
        setup_options_container.add_child(button)
        _setup_buttons[manual_id] = button


func _on_primary_button_pressed() -> void:
    if run_state.get_current_screen() == VerticalSliceRunState.SCREEN_MAIN:
        start_new_run()
        return
    if run_state.get_current_screen() == VerticalSliceRunState.SCREEN_FAILURE_RETRY:
        if run_state.get_retry_remaining() > 0:
            retry_failed_combat()
        else:
            end_failed_run()
        return
    advance_noncombat()


func _on_setup_manual_toggled(pressed: bool, manual_id: String) -> void:
    if not _set_setup_manual_selected(manual_id, pressed):
        var button: Button = _setup_buttons.get(manual_id)
        if button != null:
            button.set_pressed_no_signal(manual_id in _setup_selected_manual_ids)


func _set_setup_manual_selected(manual_id: String, selected: bool) -> bool:
    if not _setup_buttons.has(manual_id):
        return false
    var already_selected := manual_id in _setup_selected_manual_ids
    if selected == already_selected:
        _refresh_setup_selection_ui()
        return true
    if selected:
        if _setup_selected_manual_ids.size() >= VerticalSliceRunState.STARTER_SELECTION_COUNT:
            _refresh_setup_selection_ui()
            return false
        _setup_selected_manual_ids.append(manual_id)
    else:
        _setup_selected_manual_ids.erase(manual_id)
    _refresh_setup_selection_ui()
    return true


func _refresh_setup_selection_ui() -> void:
    for manual_id_value in _setup_buttons.keys():
        var manual_id := str(manual_id_value)
        var button: Button = _setup_buttons.get(manual_id)
        if button != null:
            button.set_pressed_no_signal(manual_id in _setup_selected_manual_ids)
    if run_state == null or primary_button == null or description_label == null:
        return
    if run_state.get_current_screen() != VerticalSliceRunState.SCREEN_SETUP:
        return
    var count := _setup_selected_manual_ids.size()
    description_label.text = "강호에 들고 갈 무공 4권을 고릅니다. 선택 %d/4\n각 무공은 3성 기술 하나로 시작하며, 선택한 네 권이 이번 비무행의 전투 정체성이 됩니다." % count
    primary_button.disabled = count != VerticalSliceRunState.STARTER_SELECTION_COUNT


func _on_screen_changed(_previous_screen: String, _current_screen: String) -> void:
    _render_current_screen()


func _render_current_screen() -> void:
    if content_panel == null or combat_host == null:
        return

    var screen := run_state.get_current_screen()
    var keeps_combat_visible := (
        screen == VerticalSliceRunState.SCREEN_COMBAT
        or screen == VerticalSliceRunState.SCREEN_REVIEW
    )

    combat_host.visible = keeps_combat_visible
    content_panel.visible = not keeps_combat_visible
    if setup_options_container != null:
        setup_options_container.visible = screen == VerticalSliceRunState.SCREEN_SETUP
    if failure_end_button != null:
        failure_end_button.visible = screen == VerticalSliceRunState.SCREEN_FAILURE_RETRY and run_state.get_retry_remaining() > 0

    if keeps_combat_visible:
        _ensure_combat_view()
        return

    match screen:
        VerticalSliceRunState.SCREEN_MAIN:
            _set_content(
                "십보강호: 숨은 수의 비무",
                "첫 5전 Vertical Slice의 PC-first 기능 UI입니다.\n전투 코어는 기존 CombatBoardPreview를 그대로 재사용합니다.",
                "새 비무행"
            )
        VerticalSliceRunState.SCREEN_SETUP:
            _set_content(
                "시작 설정 · 나의 무공 6중4",
                "강호에 들고 갈 무공 4권을 고릅니다. 선택 0/4\n각 무공은 3성 기술 하나로 시작하며, 선택은 이번 비무행의 전투 정체성을 정합니다.",
                "이 네 권으로 출발"
            )
            _refresh_setup_selection_ui()
        VerticalSliceRunState.SCREEN_INTRO:
            _set_content(
                "강호 비무행",
                "첫 여정을 시작합니다. 긴 설명보다 첫 상대와 수읽기로 빠르게 진입합니다.\n나의 시작 무공: %s" % _player_manual_names_text(),
                "첫 상대 확인"
            )
        VerticalSliceRunState.SCREEN_BRIEFING:
            _render_briefing()
        VerticalSliceRunState.SCREEN_RESULT:
            var next_label := "완주 정리" if run_state.completed_duels >= VerticalSliceRunState.MAX_DUELS else "강호행로로"
            _set_content(
                "비무 %d 결과" % run_state.completed_duels,
                "Review와 분리된 결과 화면입니다. 다음 상대는 이 결과를 확정하고 Route로 이동할 때 한 번 잠깁니다.",
                next_label
            )
        VerticalSliceRunState.SCREEN_FAILURE_RETRY:
            var failure := run_state.get_failure_receipt()
            var causes: Array = failure.get("review_causes", []) if typeof(failure.get("review_causes", [])) == TYPE_ARRAY else []
            var cause_lines: Array[String] = []
            for cause_value in causes:
                if typeof(cause_value) == TYPE_DICTIONARY:
                    var cause: Dictionary = cause_value
                    cause_lines.append("- %s" % str(cause.get("label", cause.get("event", "전투 기록"))))
            if cause_lines.is_empty():
                cause_lines.append("- 확인 가능한 전투 원인을 찾지 못했습니다.")
            var remaining := run_state.get_retry_remaining()
            _set_content(
                "비무 %d 패배 복기" % run_state.duel_index,
                "실제 전투 기록\n%s\n\n무료 동일 조건 재도전 · %d/1\n보상과 강호행로는 패배에 적용되지 않습니다." % ["\n".join(cause_lines), 1 - remaining],
                "같은 조건으로 다시 비무" if remaining > 0 else "제목으로 돌아가기"
            )
        VerticalSliceRunState.SCREEN_ROUTE_GROWTH:
            _set_content(
                "강호행로 · 성장/회복",
                "다음 상대가 이미 잠긴 상태의 첫 번째 Route 노드입니다. Route 선택으로 상대를 다시 뽑지 않습니다.",
                "선택 확정"
            )
        VerticalSliceRunState.SCREEN_ROUTE_INFO:
            _set_content(
                "강호행로 · 정보/대비",
                "잠긴 다음 상대에 대해 어떤 공개 정보를 얻을지 선택하는 두 번째 Route 노드입니다. 상대 ID는 이 화면에서도 바뀌지 않습니다.",
                "정보 확정"
            )
        VerticalSliceRunState.SCREEN_COMPLETION:
            _set_content(
                "첫 비무행 완주",
                "5전 결과·복기 태그·Route 선택을 회고하는 완료 지점입니다. 실제 요약 데이터는 후속 Phase에서 연결합니다.",
                "완료"
            )
            primary_button.disabled = true
        _:
            _set_content("Unknown", screen, "계속")


func _render_briefing() -> void:
    var opponent: Dictionary = run_state.get_current_opponent()
    if opponent.is_empty():
        _set_content("비무 %d · 상대 정보 없음" % run_state.duel_index, "잠긴 상대 데이터를 찾을 수 없습니다.", "비무 시작")
        return
    var manual_id := str(opponent.get("signature_manual_id", ""))
    var manual: Dictionary = manual_registry.get_manual(manual_id) if manual_registry != null else {}
    var manual_label := "[%s] %s" % [str(manual.get("faction", "")), str(manual.get("manual_name", ""))]
    var description := "무인상 · %s\n공개 무공 · %s\n알려진 습관 · %s\n의심할 점 · %s\n최근 평 · %s\n\n알 수 없음 · 현재 계획 / AI 가중치 / 내부 선택 seed\n나의 무공 · %s" % [
        str(opponent.get("martial_identity", "")),
        manual_label,
        str(opponent.get("readable_habit", "")),
        str(opponent.get("ambiguity_or_counterexample", "")),
        str(opponent.get("public_briefing_hook", "")),
        _player_manual_names_text()
    ]
    _set_content(
        "비무 %d · %s" % [run_state.duel_index, str(opponent.get("working_name", ""))],
        description,
        "비무 시작"
    )


func _player_manual_names_text() -> String:
    var names: Array[String] = []
    if manual_registry == null:
        return "미확정"
    for manual_id_value in run_state.get_player_manual_loadout():
        var manual: Dictionary = manual_registry.get_manual(str(manual_id_value))
        var name := str(manual.get("manual_name", ""))
        if not name.is_empty():
            names.append(name)
    return " · ".join(names) if not names.is_empty() else "미확정"


func _set_content(title: String, description: String, button_text: String) -> void:
    title_label.text = title
    description_label.text = description
    primary_button.text = button_text
    primary_button.disabled = false


func _ensure_combat_view() -> void:
    if _combat_view != null and is_instance_valid(_combat_view):
        if _combat_view_duel_index == run_state.duel_index:
            return
        _discard_combat_view()

    _combat_view = COMBAT_SCENE.instantiate() as Control
    if _combat_view == null:
        push_error("Vertical Slice shell could not instantiate the combat bridge.")
        return
    _combat_view_duel_index = run_state.duel_index
    _combat_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    combat_host.add_child(_combat_view)

    var opponent: Dictionary = run_state.get_current_opponent()
    var runtime_binding_adapter = OpponentRuntimeBindingScript.new()
    var enemy_runtime_binding: Dictionary = runtime_binding_adapter.build(opponent) if runtime_binding_adapter.is_valid() else {"valid": false}
    var signature_manual_id := str(opponent.get("signature_manual_id", ""))
    var enemy_mastery := {}
    if not signature_manual_id.is_empty():
        enemy_mastery[signature_manual_id] = int(opponent.get("signature_star_seed", 0))
    var runtime_loadout_bound := false
    if _combat_view.has_method("configure_vertical_slice_loadouts"):
        runtime_loadout_bound = bool(_combat_view.call(
            "configure_vertical_slice_loadouts",
            run_state.get_player_manual_loadout(),
            run_state.get_player_mastery_by_manual(),
            [signature_manual_id],
            enemy_mastery,
            str(opponent.get("candidate_id", "")),
            enemy_runtime_binding,
            {
                "name": str(opponent.get("working_name", "")),
                "epithet": str(opponent.get("martial_identity", ""))
            }
        ))
    _combat_view.set_meta("vertical_slice_runtime_loadout_bound_from_shell", runtime_loadout_bound)
    if not runtime_loadout_bound:
        push_error("Vertical Slice shell could not bind Setup/opponent loadouts to combat.")

    if _combat_view.has_signal("terminal_review_ready"):
        _combat_view.connect("terminal_review_ready", Callable(self, "_on_terminal_review_ready"))
    if _combat_view.has_signal("terminal_review_confirmed"):
        _combat_view.connect("terminal_review_confirmed", Callable(self, "_on_terminal_review_confirmed"))


func _discard_combat_view() -> void:
    if _combat_view == null or not is_instance_valid(_combat_view):
        _combat_view = null
        _combat_view_duel_index = 0
        return
    if _combat_view.get_parent() == combat_host:
        combat_host.remove_child(_combat_view)
    _combat_view.queue_free()
    _combat_view = null
    _combat_view_duel_index = 0


func _on_terminal_review_ready(result: Dictionary) -> void:
    if run_state.get_current_screen() != VerticalSliceRunState.SCREEN_COMBAT:
        return
    var run_result := result.duplicate(true)
    run_result["duel_index"] = run_state.duel_index
    complete_combat_for_runtime(run_result)


func _on_terminal_review_confirmed(_result: Dictionary) -> void:
    if run_state.get_current_screen() != VerticalSliceRunState.SCREEN_REVIEW:
        return
    complete_review_for_runtime()
