class_name VerticalSliceRouteShell
extends VerticalSliceResultShell

var route_options_container: VBoxContainer
var route_focus_target: OptionButton
var _route_logical_option_count: int = 0
var _route_scroll: ScrollContainer
var _route_stack: VBoxContainer
var _route_margin: Control
var _frame_journey_map: Control
var _route_preview_id := ""
var _route_preview_step := ""


func _ready() -> void:
    super._ready()
    set_meta("route_visual_status", "STRUCTURED_FUNCTIONAL_UI_NOT_FINAL_VISUAL")
    set_meta("recovery_rounding_policy", "REVERSIBLE_NEAREST_INTEGER")
    set_meta("faction_transfer_duplicate_policy", "PENDING_DUPLICATE_POLICY")
    _build_route_options_container()
    _render_current_screen()


func get_route_option_count() -> int:
    return _route_logical_option_count


func select_growth_route(choice_type: String, target_manual_id: String = "") -> bool:
    if run_state == null or run_state.get_current_screen() != VerticalSliceRunState.SCREEN_ROUTE_GROWTH:
        return false
    var target := target_manual_id
    if choice_type == "focused_training" and target.is_empty():
        target = _selected_focus_target_manual_id()
    _initialize_run_session()
    return session.transact(func(): return run_state.select_growth_route(choice_type, target))


func select_info_route(category: String) -> bool:
    if run_state == null or run_state.get_current_screen() != VerticalSliceRunState.SCREEN_ROUTE_INFO:
        return false
    _initialize_run_session()
    return session.transact(func(): return run_state.select_info_route(category))


func get_active_combat_resource_snapshot() -> Dictionary:
    if _combat_view == null or not is_instance_valid(_combat_view):
        return {}
    if not _combat_view.has_method("get_vertical_slice_player_resources"):
        return {}
    return _combat_view.call("get_vertical_slice_player_resources") as Dictionary


func _build_route_options_container() -> void:
    if primary_button == null or primary_button.get_parent() == null:
        return
    route_options_container = VBoxContainer.new()
    route_options_container.name = "RouteOptions"
    route_options_container.add_theme_constant_override("separation", 6)
    route_options_container.visible = false
    var parent := primary_button.get_parent()
    parent.add_child(route_options_container)
    parent.move_child(route_options_container, primary_button.get_index())


func _render_current_screen() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    _set_route_composition(false)
    if _route_scroll != null and run_state.get_current_screen() != VerticalSliceRunState.SCREEN_JIANGHU:
        _route_stack.reparent(_route_margin)
        _route_scroll.queue_free()
        _route_scroll = null
    super._render_current_screen()
    if route_options_container == null or run_state == null:
        return
    var screen := run_state.get_current_screen()
    if _frame_journey_map != null: _frame_journey_map.visible = screen == VerticalSliceRunState.SCREEN_JIANGHU and run_state.is_frame_run()
    route_options_container.visible = screen in [VerticalSliceRunState.SCREEN_JIANGHU, VerticalSliceRunState.SCREEN_ROUTE_GROWTH, VerticalSliceRunState.SCREEN_ROUTE_INFO]
    if screen == VerticalSliceRunState.SCREEN_JIANGHU:
        _render_jianghu()
    elif screen == VerticalSliceRunState.SCREEN_ROUTE_GROWTH:
        _render_growth_route()
    elif screen == VerticalSliceRunState.SCREEN_ROUTE_INFO:
        _render_info_route()
    else:
        _route_logical_option_count = 0


func _render_jianghu() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    _clear_route_options()
    if _route_scroll == null:
        _route_stack = primary_button.get_parent()
        _route_margin = _route_stack.get_parent()
        _route_scroll = ScrollContainer.new()
        _route_scroll.name = "RouteScroll"
        _route_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        _route_margin.add_child(_route_scroll)
        _route_stack.reparent(_route_scroll)
        _route_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var pending := run_state.get_pending_jianghu()
    var resting := str(pending.get("route_type", "")) == "rest"
    _set_route_composition(resting)
    route_options_container.visible = pending.is_empty()
    var step := run_state.jianghu_step
    var resources := run_state.get_player_run_resources()
    var health: Array = resources.get("health", [0, 0])
    title_label.text = "강호행로 · %d/4 · 다음 비무 %d/10" % [step + (0 if pending.is_empty() else 1), run_state.duel_index + 1]
    if resting:
        title_label.text = "주막에서 휴식 · %d/4" % (step + 1)
    description_label.text = "세 갈래 중 다음 목적지 하나를 선택합니다.\n체력 %d/%d · 다음 상대 %s\n\n%s" % [health[0], health[1], run_state.get_route_target_opponent().get("working_name", ""), "아직 고르지 않은 길은 다음 단계에서 새로 제시됩니다." if pending.is_empty() else "선택 결과 · %s\n%s" % [pending.get("effect", ""), pending.get("text", "")]]
    if resting:
        var stamina: Array = resources.get("stamina", [0, 0])
        var internal: Array = resources.get("internal", [0, 0])
        description_label.text = "빗소리를 들으며 잠시 몸을 추스릅니다.\n\n%s\n\n현재 체력 %d/%d\n기력 %d/%d · 내력 %d/%d\n\n휴식을 마쳤습니다. 다음 갈림길로 나아갑니다." % [pending.get("effect", ""), health[0], health[1], stamina[0], stamina[1], internal[0], internal[1]]
    var giyun := run_state.get_giyun_state()
    if not giyun.is_empty():
        var rules = preload("res://src/run/giyun_rules.gd").new()
        if not giyun.pending_event.is_empty():
            title_label.text = giyun.pending_event.title
            var choice_hint := "선택 전 성공률·성공/실패 결과를 확인하세요." if int(giyun.version) == 2 else "이 회차는 이전 사건 규칙을 이어갑니다. 선택의 대가·효과를 확인하세요."
            description_label.text = giyun.pending_event.text+"\n\n%s 체력 %d/%d" % [choice_hint,health[0],health[1]]
            if int(giyun.version) == 2:
                var stats: Dictionary = rules.player_stats()
                description_label.text += "\n외공 %d · 근골 %d · 신법 %d · 내공 %d · 심안 %d" % [stats.external, stats.constitution, stats.agility, stats.internal_power, stats.insight]
                description_label.text += "\n기연은 표시된 선택이 성공했을 때만 추가 10% 확률입니다."
        var owned: Array[String] = []
        for id in giyun.owned:
            var item: Dictionary = rules.definition(id)
            owned.append(item.name+": "+item.description)
        description_label.text += "\n\n보유 기연 · 이번 회차\n"+("\n".join(owned) if not owned.is_empty() else "아직 없음")
    var options := run_state.get_jianghu_options()
    _route_logical_option_count = options.size()
    for option in options:
        var button := Button.new()
        button.name = "Jianghu_" + str(option["id"])
        button.text = "%s\n%s" % [option["label"], option["effect"]]
        button.custom_minimum_size.y = 64
        button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.disabled = not pending.is_empty() or bool(option.get("disabled", false))
        button.pressed.connect(_choose_jianghu.bind(str(option["id"]), step))
        route_options_container.add_child(button)
    primary_button.text = "다음 갈림길" if step < 3 else "다음 비무 브리핑"
    primary_button.disabled = pending.is_empty()
    if run_state.is_frame_run(): _render_frame_journey_map(options, pending, giyun)
    _apply_session_input_lock()


func _render_frame_journey_map(options: Array, pending: Dictionary, giyun: Dictionary) -> void:
    if _frame_journey_map == null:
        _frame_journey_map = preload("res://src/ui/ink/ink_journey_map.gd").new()
        _frame_journey_map.name = "FrameJourneyMap"
        _frame_journey_map.anchor_left = 0.035
        _frame_journey_map.anchor_right = 0.49
        _frame_journey_map.anchor_top = 0.16
        _frame_journey_map.anchor_bottom = 0.86
        add_child(_frame_journey_map)
        _frame_journey_map.node_selected.connect(func(id: String):
            if session != null and not session.accepts_commands(): return
            _route_preview_id = id
            _render_current_screen())
    _frame_journey_map.visible = true
    content_panel.anchor_left = 0.52
    content_panel.anchor_right = 0.965
    content_panel.anchor_top = 0.06
    content_panel.anchor_bottom = 0.94
    var token := "%d:%d" % [run_state.completed_duels, run_state.jianghu_step]
    if token != _route_preview_step:
        _route_preview_step = token
        _route_preview_id = ""
    var event_pending: bool = not giyun.is_empty() and not giyun.pending_event.is_empty()
    if not pending.is_empty():
        _frame_journey_map.configure([{"id": str(pending.id), "label": str(pending.label), "disabled": true}], "산길\n행로 %d / 4" % (run_state.jianghu_step + 1), str(pending.id))
    elif event_pending:
        _frame_journey_map.configure([{"id": "event", "label": str(giyun.pending_event.title), "disabled": true}], "산길\n현재 위치", "event")
    else:
        _frame_journey_map.configure(options, "비무터\n지난 길" if run_state.jianghu_step == 0 else "산길\n현재 위치", _route_preview_id)
        _clear_route_options()
        _route_logical_option_count = options.size()
        if _route_preview_id.is_empty():
            description_label.text = "지도에서 다음 길을 고르세요.\n\n세 갈래 길의 상황과 효과를 비교한 뒤 이동합니다.\n현재 선택하지 않은 길에서는 효과를 얻지 않습니다."
            primary_button.text = "지도에서 목적지를 선택하세요"
        else:
            for option in options:
                if str(option.id) != _route_preview_id: continue
                description_label.text = "%s\n\n%s\n\n이 길로 이동하면 선택이 확정됩니다." % [option.label, option.effect]
                var enter := Button.new()
                enter.name = "FrameRouteEnter"
                enter.text = "이곳으로 향한다  ›"
                enter.custom_minimum_size.y = 64
                enter.pressed.connect(_choose_jianghu.bind(str(option.id), run_state.jianghu_step))
                route_options_container.add_child(enter)
            primary_button.text = "목적지 확인"
        primary_button.visible = false
        return
    primary_button.visible = true


func _set_route_composition(resting: bool) -> void:
    if content_panel == null:
        return
    if run_state != null:
        _apply_screen_art(run_state.get_current_screen(), resting)


func _choose_jianghu(node_id: String, step: int) -> void:
    _initialize_run_session()
    session.transact(func(): return run_state.select_jianghu_node(node_id, step))


func _render_briefing() -> void:
    super._render_briefing()
    if run_state == null or description_label == null:
        return
    var giyun := run_state.get_giyun_state()
    if not giyun.is_empty() and not giyun.owned.is_empty():
        var rules = preload("res://src/run/giyun_rules.gd").new()
        description_label.text += "\n\n이번 비무에 적용되는 기연"
        for id in giyun.owned:
            var item: Dictionary = rules.definition(id)
            description_label.text += "\n"+item.name+" · "+item.description
    var intel := run_state.get_current_opponent_intel()
    var intel_text := str(intel.get("text", ""))
    if not intel_text.is_empty():
        description_label.text += "\n\n행로에서 얻은 단서 · %s" % intel_text


func _render_growth_route() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    if route_options_container == null or run_state == null:
        return
    _clear_route_options()
    var options := run_state.get_growth_route_options()
    _route_logical_option_count = options.size()
    var node_id := "R%d" % (run_state.completed_duels * 2 - 1)
    var resources := run_state.get_player_run_resources()
    var health: Array = resources.get("health", [0, 0])
    var stamina: Array = resources.get("stamina", [0, 0])
    var internal: Array = resources.get("internal", [0, 0])
    description_label.text = "%s · 성장/회복\n현재 체력 %d/%d · 기력 %d/%d · 내력 %d/%d\n세 선택지 중 하나만 확정합니다. 회복과 성장은 동시에 받지 않습니다." % [
        node_id,
        int(health[0]), int(health[1]),
        int(stamina[0]), int(stamina[1]),
        int(internal[0]), int(internal[1])
    ]

    route_focus_target = OptionButton.new()
    route_focus_target.name = "FocusedTrainingTarget"
    for manual_id_value in run_state.get_player_manual_loadout():
        var manual_id := str(manual_id_value)
        var manual := manual_registry.get_manual(manual_id) if manual_registry != null else {}
        route_focus_target.add_item(str(manual.get("manual_name", manual_id)))
        route_focus_target.set_item_metadata(route_focus_target.item_count - 1, manual_id)
    route_options_container.add_child(route_focus_target)

    for value in options:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var option: Dictionary = value
        var choice_type := str(option.get("choice_type", ""))
        var button := Button.new()
        match choice_type:
            "recovery":
                button.text = "숨 고르기 · 최대체력 25% + 기력1 + 내력1"
                button.pressed.connect(func() -> void: select_growth_route("recovery"))
            "focused_training":
                button.text = "한 수 다듬기 · 선택 무공 +%d" % int(option.get("focused_training", 0))
                button.pressed.connect(func() -> void: select_growth_route("focused_training"))
            "free_training":
                button.text = "기억해 두기 · 미배분 자유 수련 +%d" % int(option.get("free_training", 0))
                button.pressed.connect(func() -> void: select_growth_route("free_training"))
            _:
                continue
        route_options_container.add_child(button)

    var selected := run_state.has_pending_growth_route()
    primary_button.disabled = not selected
    if selected:
        description_label.text += "\n선택 확정됨 · 계속하면 다음 정보/대비 노드로 이동합니다."
    _apply_session_input_lock()


func _render_info_route() -> void:
    if session != null and (session.busy or session.blocked):
        _apply_session_input_lock()
        return
    if route_options_container == null or run_state == null:
        return
    _clear_route_options()
    var options := run_state.get_info_route_options()
    _route_logical_option_count = options.size()
    var target := run_state.get_route_target_opponent()
    var node_id := "R%d" % (run_state.completed_duels * 2)
    title_label.text = "%s · 정보/대비 · %s" % [node_id, str(target.get("working_name", "다음 상대"))]
    description_label.text = "이미 잠긴 다음 상대에 대해 공개 정보 한 범주만 더 확인합니다.\n선택으로 상대가 바뀌거나 현재 숨은 계획·AI 가중치가 공개되지는 않습니다."

    for value in options:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var option: Dictionary = value
        var category := str(option.get("category", ""))
        var button := Button.new()
        button.text = "%s · %s" % [_info_category_label(category), str(option.get("text", ""))]
        button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.pressed.connect(_on_info_option_pressed.bind(category))
        route_options_container.add_child(button)

    var intel := run_state.get_pending_route_intel()
    primary_button.disabled = intel.is_empty()
    if not intel.is_empty():
        description_label.text += "\n\n선택한 단서 · %s" % str(intel.get("text", ""))
    _apply_session_input_lock()


func _on_info_option_pressed(category: String) -> void:
    select_info_route(category)


func _ensure_combat_view() -> void:
    var previous := _combat_view
    super._ensure_combat_view()
    if _combat_view == previous: return
    if _combat_view == null or not is_instance_valid(_combat_view) or run_state == null:
        return
    if not _combat_view.has_method("apply_vertical_slice_player_resources"):
        return
    var resources := run_state.get_player_run_resources()
    if resources.is_empty():
        return
    var applied := bool(_combat_view.call("apply_vertical_slice_player_resources", resources))
    _combat_view.set_meta("vertical_slice_run_resources_applied_from_shell", applied)
    if not applied:
        push_error("Vertical Slice shell could not apply persisted player resources to combat.")


func _clear_route_options() -> void:
    if route_options_container == null:
        return
    for child in route_options_container.get_children():
        route_options_container.remove_child(child)
        child.queue_free()
    route_focus_target = null


func _selected_focus_target_manual_id() -> String:
    if route_focus_target == null or route_focus_target.item_count <= 0:
        return ""
    var index := route_focus_target.selected
    if index < 0:
        return ""
    return str(route_focus_target.get_item_metadata(index))


func _info_category_label(category: String) -> String:
    var labels := {
        "BODY_TRACE": "신체·운용 흔적",
        "MANUAL_RUMOR": "무공 소문",
        "RECENT_DUEL": "최근 비무",
        "RANGE_RECORD": "사거리 기록",
        "FOOTWORK_SIGHTING": "보법 목격담",
        "PAST_RANGE_FAILURE": "거리 실패 사례",
        "EVADE_RECORD": "회피 기록",
        "COUNTER_CASE": "반격 사례",
        "HABIT_RUMOR": "습관 소문",
        "CHAIN_TRACE": "연계 흔적",
        "INTERRUPTION_CASE": "중단 사례",
        "FOLLOWUP_RUMOR": "후속 수 소문"
    }
    return str(labels.get(category, category))
