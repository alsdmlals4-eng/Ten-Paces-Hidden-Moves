class_name VerticalSliceRouteShell
extends VerticalSliceResultShell

var route_options_container: VBoxContainer
var route_focus_target: OptionButton
var _route_logical_option_count: int = 0


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
    if not run_state.select_growth_route(choice_type, target):
        return false
    _render_growth_route()
    return true


func select_info_route(category: String) -> bool:
    if run_state == null or run_state.get_current_screen() != VerticalSliceRunState.SCREEN_ROUTE_INFO:
        return false
    if not run_state.select_info_route(category):
        return false
    _render_info_route()
    return true


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
    super._render_current_screen()
    if route_options_container == null or run_state == null:
        return
    var screen := run_state.get_current_screen()
    route_options_container.visible = screen in [VerticalSliceRunState.SCREEN_ROUTE_GROWTH, VerticalSliceRunState.SCREEN_ROUTE_INFO]
    if screen == VerticalSliceRunState.SCREEN_ROUTE_GROWTH:
        _render_growth_route()
    elif screen == VerticalSliceRunState.SCREEN_ROUTE_INFO:
        _render_info_route()
    else:
        _route_logical_option_count = 0


func _render_briefing() -> void:
    super._render_briefing()
    if run_state == null or description_label == null:
        return
    var intel := run_state.get_current_opponent_intel()
    var intel_text := str(intel.get("text", ""))
    if not intel_text.is_empty():
        description_label.text += "\n\n행로에서 얻은 단서 · %s" % intel_text


func _render_growth_route() -> void:
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

    var selected := _has_pending_growth_selection()
    primary_button.disabled = not selected
    if selected:
        description_label.text += "\n선택 확정됨 · 계속하면 다음 정보/대비 노드로 이동합니다."


func _render_info_route() -> void:
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
        button.pressed.connect(func() -> void: select_info_route(category))
        route_options_container.add_child(button)

    var intel := run_state.get_pending_route_intel()
    primary_button.disabled = intel.is_empty()
    if not intel.is_empty():
        description_label.text += "\n\n선택한 단서 · %s" % str(intel.get("text", ""))


func _ensure_combat_view() -> void:
    super._ensure_combat_view()
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


func _has_pending_growth_selection() -> bool:
    if run_state == null:
        return false
    var history_size := run_state.get_route_history().size()
    var before_info := run_state.get_current_screen() == VerticalSliceRunState.SCREEN_ROUTE_GROWTH
    if not before_info:
        return false
    var probe := run_state.get_progression_snapshot()
    return bool(probe.get("route_growth_selected", false)) if probe.has("route_growth_selected") else _growth_selection_inferred()


func _growth_selection_inferred() -> bool:
    if primary_button == null or run_state == null:
        return false
    # RunState advance() is the authority; UI selection state is inferred from a private-free public contract:
    # a second selection attempt fails once a choice is locked. Use no mutation here; expose a RunState helper later if needed.
    return run_state.has_method("has_pending_growth_route") and bool(run_state.call("has_pending_growth_route"))


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
