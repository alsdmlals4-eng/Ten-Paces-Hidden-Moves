class_name VerticalSliceShell
extends Control

const COMBAT_SCENE := preload("res://scenes/run/vertical_slice_combat_bridge.tscn")

var run_state: VerticalSliceRunState
var content_panel: PanelContainer
var combat_host: Control
var title_label: Label
var description_label: Label
var primary_button: Button

var _combat_view: Control
var _combat_view_duel_index: int = 0


func _ready() -> void:
    set_meta("technical_shell", true)
    set_meta("final_visual_reference_pending", true)
    set_meta("visual_evidence_ceiling", "TECHNICAL_SHELL_NOT_HUMAN_VISUAL_PASS")

    run_state = VerticalSliceRunState.new()
    run_state.screen_changed.connect(_on_screen_changed)
    _build_shell()
    _render_current_screen()


func start_new_run() -> bool:
    return run_state.start_new_run()


func advance_noncombat() -> bool:
    var screen := run_state.get_current_screen()
    if screen == VerticalSliceRunState.SCREEN_COMBAT or screen == VerticalSliceRunState.SCREEN_REVIEW:
        return false
    return run_state.advance()


func complete_combat_for_runtime(result: Dictionary) -> bool:
    return run_state.mark_combat_finished(result)


func complete_review_for_runtime() -> bool:
    if run_state.get_current_screen() != VerticalSliceRunState.SCREEN_REVIEW:
        return false
    return run_state.advance()


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
    content_panel.anchor_left = 0.18
    content_panel.anchor_top = 0.16
    content_panel.anchor_right = 0.82
    content_panel.anchor_bottom = 0.84
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
    margin.add_theme_constant_override("margin_top", 36)
    margin.add_theme_constant_override("margin_right", 40)
    margin.add_theme_constant_override("margin_bottom", 36)
    content_panel.add_child(margin)

    var stack := VBoxContainer.new()
    stack.alignment = BoxContainer.ALIGNMENT_CENTER
    stack.add_theme_constant_override("separation", 20)
    margin.add_child(stack)

    var technical_label := Label.new()
    technical_label.text = "PC-FIRST VERTICAL SLICE · TECHNICAL SHELL"
    technical_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    technical_label.add_theme_color_override("font_color", Color("b99254"))
    technical_label.add_theme_font_size_override("font_size", 16)
    stack.add_child(technical_label)

    title_label = Label.new()
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.add_theme_color_override("font_color", Color("eadfc9"))
    title_label.add_theme_font_size_override("font_size", 34)
    stack.add_child(title_label)

    description_label = Label.new()
    description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description_label.custom_minimum_size = Vector2(0.0, 110.0)
    description_label.add_theme_color_override("font_color", Color("c9bca8"))
    description_label.add_theme_font_size_override("font_size", 18)
    stack.add_child(description_label)

    primary_button = Button.new()
    primary_button.custom_minimum_size = Vector2(260.0, 52.0)
    primary_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    primary_button.pressed.connect(_on_primary_button_pressed)
    stack.add_child(primary_button)

    var pending_label := Label.new()
    pending_label.text = "최종 시각 레퍼런스 대기 중 · 현재 화면은 기능 검증용 구조화 shell"
    pending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    pending_label.add_theme_color_override("font_color", Color("8d8375"))
    pending_label.add_theme_font_size_override("font_size", 13)
    stack.add_child(pending_label)


func _on_primary_button_pressed() -> void:
    if run_state.get_current_screen() == VerticalSliceRunState.SCREEN_MAIN:
        start_new_run()
        return
    advance_noncombat()


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

    if keeps_combat_visible:
        _ensure_combat_view()
        return

    match screen:
        VerticalSliceRunState.SCREEN_MAIN:
            _set_content(
                "십보강호: 숨은 수의 비무",
                "첫 5전 Vertical Slice의 PC-first 기술 shell입니다.\n전투 코어는 기존 CombatBoardPreview를 그대로 재사용합니다.",
                "새 비무행"
            )
        VerticalSliceRunState.SCREEN_SETUP:
            _set_content(
                "시작 설정 · 무공 6중4",
                "Phase I에서는 화면 경계와 RunState만 연결합니다.\n실제 6중4 선택 UI와 데이터 바인딩은 후속 Phase에서 붙입니다.",
                "설정 완료"
            )
        VerticalSliceRunState.SCREEN_INTRO:
            _set_content(
                "강호 비무행",
                "첫 여정을 시작합니다. 긴 설명보다 첫 상대와 수읽기로 빠르게 진입합니다.",
                "첫 상대 확인"
            )
        VerticalSliceRunState.SCREEN_BRIEFING:
            _set_content(
                "비무 %d · 상대 파악" % run_state.duel_index,
                "공개 정보와 현재 상태만 확인합니다. 숨은 계획·AI 가중치·정답 대응은 보여 주지 않습니다.",
                "비무 시작"
            )
        VerticalSliceRunState.SCREEN_RESULT:
            var next_label := "완주 정리" if run_state.completed_duels >= VerticalSliceRunState.MAX_DUELS else "강호행로로"
            _set_content(
                "비무 %d 결과" % run_state.completed_duels,
                "Review와 분리된 결과 화면입니다. 승패·보상·다음 상대 선잠금은 후속 데이터 Phase에서 연결합니다.",
                next_label
            )
        VerticalSliceRunState.SCREEN_ROUTE_GROWTH:
            _set_content(
                "강호행로 · 성장/회복",
                "비무 사이 첫 번째 Route 노드입니다. 실제 수치 선택은 기존 승인 Seed를 후속 Phase에서 연결합니다.",
                "선택 확정"
            )
        VerticalSliceRunState.SCREEN_ROUTE_INFO:
            _set_content(
                "강호행로 · 정보/대비",
                "잠긴 다음 상대에 대해 어떤 공개 정보를 얻을지 선택하는 두 번째 Route 노드입니다.",
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
