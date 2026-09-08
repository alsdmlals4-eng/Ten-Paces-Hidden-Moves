class_name VerticalSliceShell
extends Control

const COMBAT_SCENE := preload("res://scenes/run/vertical_slice_combat_bridge.tscn")
const MAIN_TITLE_SCENE := preload("res://scenes/ui/main_title_screen.tscn")
const OpponentRuntimeBindingScript := preload("res://src/run/vertical_slice_opponent_runtime_binding.gd")
const TECHNICAL_RUN_SEED := 20260820

var run_state: VerticalSliceRunState
var opponent_catalog: VerticalSliceOpponentCatalog
var starter_manual_catalog: VerticalSliceStarterManualCatalog
var manual_registry: MartialManualRegistry
var content_panel: PanelContainer
var combat_host: Control
var main_title_screen: Control
var title_label: Label
var description_label: Label
var primary_button: Button
var failure_end_button: Button
var setup_options_container: VBoxContainer

var _combat_view: Control
var _combat_view_duel_index: int = 0
var _setup_buttons: Dictionary = {}
var _setup_selected_manual_ids: Array[String] = []
var _briefing_body: HBoxContainer
var _briefing_description_scroll: ScrollContainer
var _bimu_constraint_panel: VBoxContainer
var session
var _save_storage_override := ""
var _retained_combat_view: Control
var _recovery_panel: PanelContainer
var _recovery_label: Label
var _save_retry_button: Button
var _replacement_dialog: ConfirmationDialog
var _explicit_pause := false
var _application_suspended := false


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
    call_deferred("_initialize_run_session")


func start_new_run(replacement_confirmed: bool = false) -> bool:
    _initialize_run_session()
    if not session.accepts_commands(): return false
    if session.enabled and not replacement_confirmed and (not session.available.is_empty() or session.status in ["CORRUPT", "INCOMPATIBLE", "IO_FAILURE"]):
        _replacement_dialog.popup_centered(Vector2i(520, 200))
        return false
    _setup_selected_manual_ids.clear()
    _refresh_setup_selection_ui()
    return session.transact(Callable(run_state, "start_new_run"), true)


func advance_noncombat() -> bool:
    _initialize_run_session()
    return session.transact(Callable(self, "_advance_noncombat_domain"))


func _advance_noncombat_domain() -> bool:
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
    _initialize_run_session()
    return session.transact(Callable(run_state, "retry_failed_duel"))


func end_failed_run() -> bool:
    if run_state == null:
        return false
    _initialize_run_session()
    return session.transact(Callable(run_state, "end_failed_run"))


func complete_combat_for_runtime(result: Dictionary) -> bool:
    if session != null and session.enabled: return session.terminal_ready(result)
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
    if session != null and not session.accepts_commands(): return false
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
    var background := TextureRect.new()
    background.name = "ShellBackdrop"
    background.texture = preload("res://assets/backgrounds/atlas_blue_ink_courtyard_v1.png")
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)
    move_child(background, 0)

    main_title_screen = MAIN_TITLE_SCENE.instantiate() as Control
    main_title_screen.name = "MainTitleScreen"
    main_title_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    main_title_screen.connect("start_requested", Callable(self, "_on_primary_button_pressed"))
    add_child(main_title_screen)

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
    panel_style.bg_color = Color(0.025, 0.045, 0.062, 0.93)
    panel_style.border_color = Color("ae8c55")
    panel_style.set_border_width_all(2)
    panel_style.set_corner_radius_all(2)
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
    if session != null and not session.accepts_commands(): return false
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
    if session != null and (session.busy or session.blocked): return
    _publish_session_screen()


func _render_current_screen() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    if content_panel == null or combat_host == null:
        return

    var screen := run_state.get_current_screen()
    var keeps_combat_visible := (
        screen == VerticalSliceRunState.SCREEN_COMBAT
        or screen == VerticalSliceRunState.SCREEN_REVIEW
    )

    var showing_main := screen == VerticalSliceRunState.SCREEN_MAIN
    combat_host.visible = keeps_combat_visible
    content_panel.visible = not keeps_combat_visible and not showing_main
    if is_instance_valid(main_title_screen):
        main_title_screen.visible = showing_main
    if setup_options_container != null:
        setup_options_container.visible = screen == VerticalSliceRunState.SCREEN_SETUP
    if failure_end_button != null:
        failure_end_button.visible = screen == VerticalSliceRunState.SCREEN_FAILURE_RETRY and run_state.get_retry_remaining() > 0

    if keeps_combat_visible:
        _ensure_combat_view()
        _apply_session_input_lock()
        return

    match screen:
        VerticalSliceRunState.SCREEN_MAIN:
            _set_content(
                "십보강호: 숨은 수의 비무",
                "세 수를 고르고, 한 수씩 드러나는 승부를 읽습니다.",
                "비무행 시작"
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
    _apply_session_input_lock()


func _render_briefing() -> void:
    var focused := get_viewport().gui_get_focus_owner()
    var opponent: Dictionary = run_state.get_current_opponent()
    if opponent.is_empty():
        _set_content("비무 %d · 상대 정보 없음" % run_state.duel_index, "잠긴 상대 데이터를 찾을 수 없습니다.", "비무 시작")
        return
    var manual_id := str(opponent.get("signature_manual_id", ""))
    var manual: Dictionary = manual_registry.get_manual(manual_id) if manual_registry != null else {}
    var manual_label := "[%s] %s" % [str(manual.get("faction", "")), str(manual.get("manual_name", ""))]
    var description := "무인상 · %s\n공개 무공 · %s\n알려진 습관 · %s\n의심할 점 · %s\n\n상대의 다음 수는 아직 알 수 없습니다. 공개된 단서로 대비하세요.\n\n나의 보유 무공\n%s" % [
        str(opponent.get("martial_identity", "")),
        manual_label,
        str(opponent.get("readable_habit", "")),
        str(opponent.get("ambiguity_or_counterexample", "")),
        _player_manual_names_text()
    ]
    _set_content(
        "비무 %d · %s" % [run_state.duel_index, str(opponent.get("working_name", ""))],
        description,
        "비무 시작"
    )
    _show_bimu_briefing()
    # _set_content temporarily hides the briefing. Keep focus only when configure
    # retained the same widget; a new opponent/loadout must not revive old nodes.
    if is_instance_valid(focused) and _bimu_constraint_panel.is_ancestor_of(focused): focused.grab_focus()


func get_bimu_constraint_panel() -> VBoxContainer:
    return _bimu_constraint_panel


func _show_bimu_briefing() -> void:
    var stack := primary_button.get_parent()
    if _briefing_body == null:
        _briefing_body = HBoxContainer.new()
        _briefing_body.name = "BimuBriefingBody"
        _briefing_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
        _briefing_body.add_theme_constant_override("separation", 24)
        stack.add_child(_briefing_body)
        stack.move_child(_briefing_body, 1)
        _briefing_description_scroll = ScrollContainer.new()
        _briefing_description_scroll.name = "PublicOpponentBriefing"
        _briefing_description_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        _briefing_description_scroll.focus_mode = Control.FOCUS_ALL
        _briefing_description_scroll.accessibility_name = "상대 공개 정보와 나의 보유 무공 · 위아래로 스크롤"
        _briefing_description_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _briefing_body.add_child(_briefing_description_scroll)
        _bimu_constraint_panel = preload("res://src/ui/bimu_constraint_panel.gd").new()
        _bimu_constraint_panel.name = "BimuConstraintPanel"
        _bimu_constraint_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _bimu_constraint_panel.size_flags_stretch_ratio = 1.3
        _briefing_body.add_child(_bimu_constraint_panel)
        _bimu_constraint_panel.selection_changed.connect(_on_bimu_selection_changed)
        _bimu_constraint_panel.submit_selection = Callable(self, "_submit_bimu_constraints")
    _briefing_body.visible = true
    description_label.reparent(_briefing_description_scroll)
    description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    content_panel.anchor_left = 0.06
    content_panel.anchor_right = 0.94
    _bimu_constraint_panel.configure(run_state, manual_registry)


func _on_bimu_selection_changed(receipt: Dictionary) -> void:
    primary_button.text = "제약 없이 비무 시작" if (receipt.get("selections", []) as Array).is_empty() else "선택한 제약으로 비무 시작"


func _player_manual_names_text() -> String:
    var names: Array[String] = []
    if manual_registry == null:
        return "미확정"
    var mastery := run_state.get_player_mastery_by_manual()
    for manual_id_value in run_state.get_player_manual_loadout():
        var manual: Dictionary = manual_registry.get_manual(str(manual_id_value))
        var name := str(manual.get("manual_name", ""))
        if not name.is_empty():
            names.append("%s · %d ☆" % [name, int(mastery.get(str(manual_id_value), 0))])
    return "\n".join(names) if not names.is_empty() else "미확정"


func _set_content(title: String, description: String, button_text: String) -> void:
    if _briefing_body != null:
        _briefing_body.visible = false
        var stack := primary_button.get_parent()
        if description_label.get_parent() != stack:
            description_label.reparent(stack)
            stack.move_child(description_label, 1)
        description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title_label.text = title
    description_label.text = description
    primary_button.text = button_text
    primary_button.disabled = false


func _ensure_combat_view() -> void:
    if _combat_view != null and is_instance_valid(_combat_view):
        if _combat_view_duel_index == run_state.duel_index and int(_combat_view.get_meta("shell_attempt", 0)) == run_state._attempt_id:
            return
        if session != null and session.busy:
            _retained_combat_view = _combat_view
            _combat_view = null
        else:
            _discard_combat_view()

    _combat_view = COMBAT_SCENE.instantiate() as Control
    if _combat_view == null:
        push_error("Vertical Slice shell could not instantiate the combat bridge.")
        return
    _combat_view_duel_index = run_state.duel_index
    _combat_view.set_meta("shell_attempt", run_state._attempt_id)
    _combat_view.visible = session == null or not session.busy
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
            },
            run_state.get_frozen_bimu_receipt()
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
    if session != null and session.enabled:
        session.terminal_ready(run_result)
        return
    complete_combat_for_runtime(run_result)


func _on_terminal_review_confirmed(_result: Dictionary) -> void:
    if session != null and session.enabled: return
    if run_state.get_current_screen() != VerticalSliceRunState.SCREEN_REVIEW:
        return
    complete_review_for_runtime()


func configure_save_storage(path: String) -> void:
    assert(not is_inside_tree(), "Configure isolated storage before adding the shell")
    _save_storage_override = path


func _initialize_run_session() -> void:
    if session != null: return
    session = preload("res://src/run/run_session_coordinator.gd").new()
    var script_entry := "--script" in OS.get_cmdline_args() or "-s" in OS.get_cmdline_args()
    var path := _save_storage_override
    for argument in OS.get_cmdline_user_args():
        if argument.begins_with("--run-save-dir="): path = argument.trim_prefix("--run-save-dir=")
    session.configure(self, "user://run_checkpoint" if path.is_empty() else path, not script_entry or not path.is_empty())
    process_mode = Node.PROCESS_MODE_ALWAYS
    combat_host.process_mode = Node.PROCESS_MODE_PAUSABLE
    if session.enabled: get_tree().auto_accept_quit = false
    main_title_screen.continue_requested.connect(continue_saved_run)
    main_title_screen.reread_requested.connect(func():
        if session.accepts_commands():
            session.refresh_available()
            _publish_session_screen())
    _replacement_dialog = ConfirmationDialog.new()
    _replacement_dialog.title = "새 여정 시작"
    _replacement_dialog.dialog_text = "현재 여정을 새 여정으로 바꿉니다. 계속하시겠습니까?\n읽을 수 없는 저장 기록은 진단 사본으로 보존합니다."
    _replacement_dialog.ok_button_text = "새 여정 시작"
    _replacement_dialog.cancel_button_text = "돌아가기"
    _replacement_dialog.confirmed.connect(func(): start_new_run(true))
    add_child(_replacement_dialog)
    _build_save_recovery()
    _publish_session_screen()


func continue_saved_run() -> bool:
    _initialize_run_session()
    return session.continue_run()


func retry_durable_save() -> bool:
    return await session.retry()


func _submit_bimu_constraints(proposed: Array) -> bool:
    _initialize_run_session()
    return session.transact(func(): return run_state.select_bimu_constraints(proposed))


func _publish_session_screen() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    # Restore old widget locks before the new screen calculates availability.
    # An old MAIN enabled value must not overwrite a new SETUP 0/4 disabled CTA.
    _apply_session_input_lock()
    _render_current_screen()
    if session != null:
        main_title_screen.configure_continue(session.available, session.status)
        _apply_session_input_lock()


func _build_save_recovery() -> void:
    _recovery_panel = PanelContainer.new()
    _recovery_panel.name = "SaveRecoveryPanel"
    _recovery_panel.anchor_left = 0.18
    _recovery_panel.anchor_right = 0.82
    _recovery_panel.anchor_top = 0.02
    _recovery_panel.anchor_bottom = 0.02
    _recovery_panel.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(_recovery_panel)
    var stack := VBoxContainer.new()
    _recovery_panel.add_child(stack)
    _recovery_label = Label.new()
    _recovery_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    stack.add_child(_recovery_label)
    _save_retry_button = Button.new()
    _save_retry_button.name = "RetryDurableSaveButton"
    _save_retry_button.text = "저장 다시 시도"
    _save_retry_button.pressed.connect(retry_durable_save)
    stack.add_child(_save_retry_button)
    var resume_button := Button.new()
    resume_button.name = "ResumeSessionButton"
    resume_button.text = "계속하기"
    resume_button.pressed.connect(func(): set_session_paused(false))
    stack.add_child(resume_button)


func _apply_session_input_lock() -> void:
    if session == null: return
    var locked: bool = not session.accepts_commands()
    for host in [content_panel, main_title_screen, combat_host]: _lock_session_buttons(host, locked)
    if is_instance_valid(_combat_view):
        _combat_view.session_input_blocked = locked
        _combat_view.session_suspended = session.suspended
        _combat_view._sync_progress_availability()
    if _recovery_panel != null:
        _recovery_panel.visible = session.blocked or session.suspended
        _recovery_label.text = "저장을 확인하지 못했습니다. 진행을 멈췄습니다. 저장 위치를 확인한 뒤 다시 시도해 주세요." if session.blocked else "일시 정지 · 마지막으로 확정된 진행을 보존합니다."
        _save_retry_button.visible = session.blocked
        _save_retry_button.disabled = session.suspended
        _recovery_panel.find_child("ResumeSessionButton", true, false).visible = _explicit_pause


func _lock_session_buttons(node: Node, locked: bool) -> void:
    if node is BaseButton:
        if locked:
            if not node.has_meta("before_session_lock"): node.set_meta("before_session_lock", node.disabled)
            node.disabled = true
        elif node.has_meta("before_session_lock"):
            node.disabled = bool(node.get_meta("before_session_lock"))
            node.remove_meta("before_session_lock")
    for child in node.get_children(): _lock_session_buttons(child, locked)


func _release_retained_combat() -> void:
    if is_instance_valid(_retained_combat_view): _retained_combat_view.queue_free()
    _retained_combat_view = null
    if is_instance_valid(_combat_view): _combat_view.visible = true
    if run_state.get_current_screen() == "MAIN": _discard_combat_view()


func set_session_paused(value: bool) -> void:
    _explicit_pause = value
    _update_session_suspension()


func _update_session_suspension() -> void:
    if session == null or not session.enabled: return
    var value := _explicit_pause or _application_suspended
    if value and not session.suspended: session.flush_stable()
    session.suspended = value
    get_tree().paused = value
    if not value and is_instance_valid(_combat_view):
        _combat_view.session_suspended = false
        _combat_view.session_input_blocked = session.blocked
        _combat_view._sync_runtime_context()
        _combat_view._sync_action_selection_dock()
    _publish_session_screen()


func _notification(what: int) -> void:
    if session == null or not session.enabled: return
    if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
        _application_suspended = true
        _update_session_suspension()
    elif what in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED]:
        _application_suspended = false
        _update_session_suspension()
    elif what == NOTIFICATION_WM_CLOSE_REQUEST:
        if session.flush_stable(): get_tree().quit()
        else: _apply_session_input_lock()
