extends CombatBoardPreview

const PREPARE_ENGINE_SCRIPT := preload("res://src/combat/combat_resolution_engine_prepare.gd")
const ACTION_PLACEMENT_CONTROLLER_SCRIPT := preload("res://src/ui/action_selection/action_placement_controller.gd")
const ACTION_SELECTION_DOCK_SCENE := preload("res://scenes/ui/action_selection/action_selection_dock.tscn")

var action_placement_controller: ActionPlacementController
var action_selection_dock: ActionSelectionDock
var _pending_controller_definition: Dictionary = {}
var _plan_locked := false

func _ready() -> void:
    super._ready()
    resolution_engine = PREPARE_ENGINE_SCRIPT.new()
    combat_state = resolution_engine.make_initial_state(top_hud.hud_data, _player_tile, _enemy_tile)
    combat_state["ai_enabled"] = true
    _build_product_action_selection_dock()
    _configure_action_placement_controller()
    _configure_ultimate_menu()
    _sync_runtime_context()
    _apply_combat_state_to_view()
    _refresh_ultimate_menu()
    _sync_action_selection_dock()
    call_deferred("_layout_board")
    call_deferred("_configure_keyboard_focus_order")
    set_meta("card_selection_mode", "auto_earliest_contiguous")
    set_meta("prepare_rule_extension", true)
    set_meta("action_placement_controller", true)
    set_meta("action_selection_dock_component", "ActionSelectionDock")
    set_meta("product_action_selection_enabled", true)
    set_meta("virtual_combo_enabled", false)

func restart_combat() -> void:
    _plan_locked = false
    if is_instance_valid(combat_progress_button):
        combat_progress_button.set_plan_locked(false)
    _player_tile = int(contract.get("player_start_tile", 4))
    _enemy_tile = int(contract.get("enemy_start_tile", 6))
    super.restart_combat()
    if is_instance_valid(action_selection_dock):
        action_selection_dock.set_interaction_state("new_combat")
    _sync_action_placement_controller_state()
    _sync_action_selection_dock()

func _build_product_action_selection_dock() -> void:
    if is_instance_valid(action_selection_dock):
        return
    action_selection_dock = ACTION_SELECTION_DOCK_SCENE.instantiate() as ActionSelectionDock
    action_selection_dock.name = "ActionSelectionDock"
    action_selection_dock.set_anchors_preset(Control.PRESET_TOP_LEFT)
    action_selection_dock.action_selected.connect(_on_product_action_selected)
    action_selection_dock.intent_selected.connect(_on_product_intent_selected)
    action_selection_dock.source_changed.connect(_on_product_source_changed)
    add_child(action_selection_dock)
    _hide_legacy_action_ui()

func _configure_action_placement_controller() -> void:
    action_placement_controller = ACTION_PLACEMENT_CONTROLLER_SCRIPT.new() as ActionPlacementController
    action_placement_controller.configure(
        action_timing_panel,
        Callable(self, "_can_reserve_ultimate"),
        Callable(self, "_reserve_ultimate_at"),
        Callable(self, "_refund_ultimate_reservation"),
        Callable(self, "_begin_targeting_for_anchor")
    )
    action_placement_controller.placement_succeeded.connect(_on_controller_placement_succeeded)
    action_placement_controller.placement_failed.connect(_on_controller_placement_failed)
    action_placement_controller.placement_moved.connect(_on_controller_placement_moved)
    action_placement_controller.targeting_requested.connect(_on_controller_targeting_requested)
    if action_timing_panel.has_signal("linked_block_move_requested"):
        action_timing_panel.connect("linked_block_move_requested", Callable(self, "_on_timing_linked_block_move_requested"))
    _sync_action_placement_controller_state()

func _sync_action_placement_controller_state() -> void:
    if action_placement_controller == null:
        return
    action_placement_controller.set_locked(_inputs_locked())
    action_placement_controller.set_targeting_in_progress(_targeting_anchor > 0, _targeting_anchor)

func _on_product_action_selected(definition: Dictionary) -> void:
    if _inputs_locked():
        return
    _auto_place_selected_card(definition.duplicate(true))

func _on_progress_requested(context: Dictionary) -> void:
    if (not _plan_locked and super._inputs_locked()) or not action_timing_panel.is_current_bundle_complete():
        return
    if not _plan_locked:
        _plan_locked = true
        if is_instance_valid(combat_progress_button):
            combat_progress_button.set_plan_locked(true)
        _set_presentation_state("plan_locked")
        set_meta("plan_locked", true)
        return
    _plan_locked = false
    if is_instance_valid(combat_progress_button):
        combat_progress_button.set_plan_locked(false)
    _set_presentation_state("planning")
    set_meta("plan_locked", false)
    super._on_progress_requested(context)

func _on_product_source_changed(_source: String) -> void:
    call_deferred("_configure_keyboard_focus_order")

func _on_action_card_selected(definition: Dictionary) -> void:
    if _inputs_locked():
        return
    _auto_place_selected_card(definition.duplicate(true))

func _on_ultimate_menu_id_pressed(index: int) -> void:
    if _inputs_locked() or index < 0 or index >= _ultimate_definitions.size():
        return
    var definition := (_ultimate_definitions[index] as Dictionary).duplicate(true)
    _auto_place_selected_card(definition)

func _auto_place_selected_card(definition: Dictionary) -> bool:
    if definition.is_empty() or action_placement_controller == null:
        return false
    _pending_controller_definition = definition.duplicate(true)
    _sync_action_placement_controller_state()
    return action_placement_controller.select_and_place(definition.duplicate(true))

func _on_timing_linked_block_move_requested(anchor_index: int, new_anchor_index: int) -> void:
    if action_placement_controller == null:
        return
    _sync_action_placement_controller_state()
    if action_placement_controller.move_placement(anchor_index, new_anchor_index):
        if action_timing_panel.has_method("focus_linked_block"):
            action_timing_panel.call_deferred("focus_linked_block", new_anchor_index)

func _on_controller_placement_succeeded(result: Dictionary) -> void:
    var is_ultimate := bool(result.get("is_ultimate", false))
    if is_instance_valid(combat_log_panel):
        var prefix := "[절초 자동 예약]" if is_ultimate else "[자동 배치]"
        combat_log_panel.append_entry("%s %s · %s" % [
            prefix,
            str(result.get("card_name", "")),
            _placement_timing_text(result)
        ], "system")
    _clear_auto_selection_state()
    if not bool(result.get("targeting_started", false)):
        _clear_targeting()
        _begin_next_pending_target()
    _pending_controller_definition.clear()
    _refresh_ultimate_menu()
    _sync_action_selection_dock()

func _on_controller_placement_moved(result: Dictionary) -> void:
    var is_ultimate := bool(result.get("is_ultimate", false))
    if is_instance_valid(combat_log_panel):
        var prefix := "[절초 예약 이동]" if is_ultimate else "[배치 이동]"
        combat_log_panel.append_entry("%s %s · %s" % [
            prefix,
            str(result.get("card_name", result.get("card_id", "행동"))),
            _placement_timing_text(result)
        ], "system")
    if not bool(result.get("targeting_started", false)):
        _begin_next_pending_target()
    _refresh_ultimate_menu()
    _sync_action_selection_dock()

func _on_controller_placement_failed(code: String, message: String) -> void:
    var is_ultimate := _is_pending_ultimate()
    _clear_auto_selection_state()
    if is_instance_valid(combat_log_panel):
        match code:
            ActionPlacementController.CODE_TARGETING_IN_PROGRESS:
                combat_log_panel.append_entry("[의도 선택] 먼저 자동 배치된 행동의 이동 또는 공격 의도 카드를 선택해야 합니다.", "system")
            ActionPlacementController.CODE_MOMENTUM_INSUFFICIENT:
                combat_log_panel.append_entry("[절초 예약 불가] 기세 5와 현재 묶음의 연속된 빈 슬롯이 모두 필요합니다.", "system")
            ActionPlacementController.CODE_NO_CONTIGUOUS_TIMINGS:
                var prefix := "[절초 예약 불가]" if is_ultimate else "[배치 불가]"
                combat_log_panel.append_entry("%s 연속된 빈 행동 슬롯이 부족합니다." % prefix, "system")
            _:
                combat_log_panel.append_entry("[배치 불가] %s" % message, "system")
    _pending_controller_definition.clear()
    _refresh_ultimate_menu()
    _sync_action_selection_dock()

func _on_controller_targeting_requested(anchor_index: int) -> void:
    set_meta("controller_targeting_anchor", anchor_index)
    _sync_action_selection_dock()

func _is_pending_ultimate() -> bool:
    return str(_pending_controller_definition.get("source_kind", _pending_controller_definition.get("source", ""))) == "ultimate"

func _clear_auto_selection_state() -> void:
    _clear_action_selection()
    _clear_card_detail()
    if is_instance_valid(basic_card_tray):
        basic_card_tray.clear_action_selection()

func _begin_targeting_for_anchor(anchor_index: int) -> bool:
    var placement := action_timing_panel.get_placement(anchor_index)
    if placement.is_empty() or bool(placement.get("target_ready", true)):
        return false
    var mode := str(placement.get("targeting_mode", "none"))
    if mode != "move_intent":
        return false
    _targeting_anchor = anchor_index
    _targeting_mode = mode
    _targeting_origin_tile = _projected_player_tile_before(anchor_index)
    _clear_tile_interactions()
    _set_tactical_target_layer_visible(false)
    if is_instance_valid(action_selection_dock):
        action_selection_dock.set_interaction_state("targeting")
        action_selection_dock.set_targeting_intents(_intent_title(placement), _build_semantic_intents(placement))
    if is_instance_valid(combat_log_panel):
        combat_log_panel.append_entry("[의도 선택] %s · 전장 칸 대신 의미 카드로 행동 의도를 정합니다." % str(placement.get("card_name", "행동")), "system")
    set_meta("targeting_anchor", _targeting_anchor)
    set_meta("targeting_mode", _targeting_mode)
    set_meta("targeting_origin_tile", _targeting_origin_tile)
    set_meta("targeting_surface", "semantic_intent_cards")
    _sync_action_selection_dock()
    return true

func _on_product_intent_selected(intent: Dictionary) -> void:
    if _inputs_locked() or _targeting_anchor <= 0:
        return
    var placement := action_timing_panel.get_placement(_targeting_anchor)
    if placement.is_empty():
        return
    var direction := clampi(int(intent.get("resolver_direction", 0)), -1, 1)
    if direction == 0:
        return
    var target_tile := 0
    if _targeting_mode == "move_intent":
        target_tile = _targeting_origin_tile + direction * maxi(1, int(intent.get("steps", 1)))
        if target_tile < 1 or target_tile > tiles.size():
            return
    var target_data := {
        "resolver_direction": direction,
        "target_tile": target_tile,
        "origin_tile": _targeting_origin_tile,
        "intent": str(intent.get("intent", "")),
        "target_text": str(intent.get("name", "행동 의도"))
    }
    if not action_timing_panel.set_placement_target(_targeting_anchor, target_data):
        return
    if is_instance_valid(combat_log_panel):
        combat_log_panel.append_entry("[의도 확정] %s · %s" % [str(placement.get("card_name", "행동")), str(intent.get("name", "행동 의도"))], "system")
    _clear_targeting()
    _begin_next_pending_target()

func _intent_title(placement: Dictionary) -> String:
    return "이동 의도 · %s" % str(placement.get("card_name", "행동"))

func _build_semantic_intents(placement: Dictionary) -> Array[Dictionary]:
    var definition: Dictionary = placement.get("definition", {})
    var toward_direction := signi(_enemy_tile - _targeting_origin_tile)
    if toward_direction == 0:
        toward_direction = 1
    var result: Array[Dictionary] = []
    if _targeting_mode == "move_intent":
        var movement_steps := maxi(1, int(definition.get("move_range", resolution_engine.rules.get("movement_steps", 1))))
        for steps in range(1, movement_steps + 1):
            var approach_tile := _targeting_origin_tile + toward_direction * steps
            if approach_tile >= 1 and approach_tile <= tiles.size():
                result.append(_make_intent_card("approach_%d" % steps, "접근 %d칸" % steps, "approach", toward_direction, steps, "상대와의 거리를 좁힌다.", "move"))
            var retreat_tile := _targeting_origin_tile - toward_direction * steps
            if retreat_tile >= 1 and retreat_tile <= tiles.size():
                result.append(_make_intent_card("retreat_%d" % steps, "후퇴 %d칸" % steps, "retreat", -toward_direction, steps, "상대와의 거리를 벌린다.", "move"))
    return result

func _make_intent_card(intent_id: String, label: String, intent: String, resolver_direction: int, steps: int, summary: String, category: String) -> Dictionary:
    return {
        "id": intent_id,
        "name": label,
        "source_label": "행동 의도",
        "category": category,
        "category_label": "이동 의도" if category == "move" else "공격 의도",
        "action_slots": 1,
        "stamina_cost": 0,
        "internal_cost": 0,
        "hide_range": true,
        "intent": intent,
        "resolver_direction": resolver_direction,
        "steps": steps,
        "effect_text": summary,
        "intent_summary": summary
    }

func _clear_targeting() -> void:
    super._clear_targeting()
    if is_instance_valid(action_selection_dock):
        action_selection_dock.clear_targeting_intents()
    _set_tactical_target_layer_visible(false)
    _sync_action_selection_dock()

func _on_timing_slot_clicked(timing_index: int) -> void:
    super._on_timing_slot_clicked(timing_index)
    _sync_action_placement_controller_state()
    _sync_action_selection_dock()

func _set_presentation_state(value: String) -> void:
    super._set_presentation_state(value)
    _sync_action_placement_controller_state()
    _sync_action_selection_dock()

func _inputs_locked() -> bool:
    return _plan_locked or super._inputs_locked()

func _set_resolution_surface_visible(value: bool) -> void:
    super._set_resolution_surface_visible(value)
    if is_instance_valid(action_selection_dock):
        action_selection_dock.visible = value

func _refresh_ultimate_menu() -> void:
    super._refresh_ultimate_menu()
    _hide_legacy_action_ui()
    _sync_action_selection_dock()

func _layout_board() -> void:
    super._layout_board()
    _layout_product_action_dock()
    _apply_frontal_duel_composition()

func _layout_product_action_dock() -> void:
    if not is_instance_valid(action_selection_dock) or size.x <= 0.0 or size.y <= 0.0:
        return
    var lower_margin := maxf(10.0, size.x * 0.014)
    var lower_bottom := maxf(8.0, size.y * 0.012)
    var dock_height := clampf(size.y * 0.34, 272.0, 304.0)
    var dock_y := size.y - dock_height - lower_bottom
    action_selection_dock.position = Vector2(lower_margin, dock_y)
    action_selection_dock.size = Vector2(maxf(1.0, size.x - lower_margin * 2.0), dock_height)

    if is_instance_valid(action_timing_panel) and is_instance_valid(combat_progress_button):
        var timing_height := action_timing_panel.size.y
        var timing_y := dock_y - timing_height - 8.0
        action_timing_panel.position.y = timing_y
        combat_progress_button.position.y = timing_y + (timing_height - combat_progress_button.size.y) * 0.5
        _shift_battlefield_above(timing_y - 30.0)
        if is_instance_valid(combat_log_panel):
            combat_log_panel.size.y = maxf(1.0, timing_y - 10.0 - combat_log_panel.position.y)
        _layout_screen_surfaces(timing_y - 10.0)
    _hide_legacy_action_ui()

func _apply_frontal_duel_composition() -> void:
    if not is_instance_valid(player_character) or not is_instance_valid(enemy_character) or tiles.is_empty():
        return
    _set_tactical_target_layer_visible(false)
    if is_instance_valid(_anchor_line):
        _anchor_line.visible = false

    var duel_rect := get_duel_stage_rect()
    var timing_top := action_timing_panel.position.y if is_instance_valid(action_timing_panel) else size.y * 0.60
    var hud_bottom := maxf(top_hud.position.y + top_hud.size.y, duel_rect.position.y) if is_instance_valid(top_hud) else duel_rect.position.y
    var grounded_floor_y := battle_background.get_duel_floor_y(size) if is_instance_valid(battle_background) else size.y * 0.46
    var player_foot_y := clampf(grounded_floor_y, hud_bottom + 32.0, timing_top - 16.0)
    var normalized_distance := clampf(float(absi(_enemy_tile - _player_tile)) / 4.0, 0.0, 1.0)
    var horizontal_separation := lerpf(size.x * 0.19, size.x * 0.255, normalized_distance)
    var tile_center_drift := clampf((float(_player_tile + _enemy_tile) * 0.5 - 5.5) * size.x * 0.014, -size.x * 0.05, size.x * 0.05)
    var duel_center_x := size.x * 0.5 + tile_center_drift

    var distant_scale_width := minf(_tile_width * 0.76, maxf(54.0, duel_rect.size.y * 0.31))
    player_character.set_dimensions(distant_scale_width)
    enemy_character.set_dimensions(distant_scale_width)
    player_character.z_index = 4
    enemy_character.z_index = 4
    if not _defer_character_snap:
        player_character.place_foot_at(Vector2(duel_center_x - horizontal_separation, player_foot_y))
        enemy_character.place_foot_at(Vector2(duel_center_x + horizontal_separation, player_foot_y))

    if is_instance_valid(range_readout_panel):
        var range_size := Vector2(clampf(size.x * 0.15, 152.0, 220.0), 72.0)
        var range_y := clampf(player_foot_y - range_size.y - 44.0, hud_bottom + 20.0, timing_top - range_size.y - 10.0)
        range_readout_panel.position = Vector2(duel_center_x - range_size.x * 0.5, range_y)
        range_readout_panel.size = range_size
        range_readout_panel.z_index = 6

    set_meta("duel_composition", "player_left|enemy_right|shared_ground|distance_center")
    set_meta("duel_floor_y", player_foot_y)
    set_meta("character_scale_profile", "distant_frontal_duel")
    set_meta("logical_board_default_visibility", "hidden")

func _set_tactical_target_layer_visible(_value: bool) -> void:
    if is_instance_valid(_tile_layer):
        _tile_layer.visible = false
    for tile in tiles:
        if is_instance_valid(tile):
            tile.visible = false

func _shift_battlefield_above(maximum_bottom: float) -> void:
    if tiles.is_empty() or _tile_height <= 0.0:
        return
    var current_bottom := _board_top + _tile_height
    if current_bottom <= maximum_bottom:
        return
    var shift := current_bottom - maximum_bottom
    _board_top = maxf(145.0, _board_top - shift)
    for tile in tiles:
        tile.position.y = _board_top
    if not _defer_character_snap:
        var player_foot := get_tile_foot_anchor(_player_tile)
        var enemy_foot := get_tile_foot_anchor(_enemy_tile)
        if _player_tile == _enemy_tile:
            var engage_offset := _tile_width * 0.18
            player_foot.x -= engage_offset
            enemy_foot.x += engage_offset
        player_character.place_foot_at(player_foot)
        enemy_character.place_foot_at(enemy_foot)
    if is_instance_valid(_anchor_line):
        var board_left := tiles[0].position.x
        var board_right := tiles[tiles.size() - 1].position.x + tiles[tiles.size() - 1].size.x
        var anchor_y := get_tile_foot_anchor(_player_tile).y
        _anchor_line.position = Vector2(board_left, anchor_y - 1.0)
        _anchor_line.size = Vector2(board_right - board_left, 2.0)

func _hide_legacy_action_ui() -> void:
    for control_value in [basic_card_tray, ultimate_menu, ultimate_list_panel, card_detail_panel]:
        if is_instance_valid(control_value):
            var control := control_value as Control
            control.visible = false
            control.mouse_filter = Control.MOUSE_FILTER_IGNORE
            control.focus_mode = Control.FOCUS_NONE

func _sync_action_selection_dock() -> void:
    if not is_instance_valid(action_selection_dock):
        return
    action_selection_dock.set_interaction_state(_dock_interaction_state())
    action_selection_dock.set_runtime_context(_build_action_selection_runtime_context())
    _hide_legacy_action_ui()
    set_meta("action_selection_source", action_selection_dock.active_source)
    set_meta("action_selection_state", _dock_interaction_state())

func _dock_interaction_state() -> String:
    if _targeting_anchor > 0:
        return "targeting"
    if _plan_locked:
        return "plan_locked"
    # An ultimate reserves multiple timing slots as one atomic plan.  Keep its
    # source context stable until the player explicitly removes that plan.
    if not _ultimate_reservation_anchors.is_empty():
        return "ultimate_reserved"
    match _presentation_state:
        "review_ready":
            return "review"
        "resolving":
            return "resolving"
        "presenting_result":
            return "presenting_result"
        "committed":
            return "committed"
        "next_bundle_ready":
            return "next_bundle_ready"
        _:
            return "planning"

func _build_action_selection_runtime_context() -> Dictionary:
    var player: Dictionary = combat_state.get("player", {})
    var momentum_value = player.get("momentum", [0, 5])
    var current := int(momentum_value[0]) if typeof(momentum_value) == TYPE_ARRAY and momentum_value.size() >= 1 else 0
    var maximum := int(momentum_value[1]) if typeof(momentum_value) == TYPE_ARRAY and momentum_value.size() >= 2 else 5
    return {
        "interaction_state": _dock_interaction_state(),
        "round_number": int(combat_state.get("round_number", 1)),
        "bundle_index": int(combat_state.get("bundle_index", 1)),
        "momentum": [current, maximum],
        "momentum_maximum": maximum,
        "ultimate_reservations": _build_ultimate_reservation_snapshot()
    }

func _build_ultimate_reservation_snapshot() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if not is_instance_valid(action_timing_panel):
        return result
    for anchor_value in _ultimate_reservation_anchors:
        var anchor_index := int(anchor_value)
        var placement := action_timing_panel.get_placement(anchor_index)
        if placement.is_empty():
            continue
        var definition: Dictionary = placement.get("definition", {})
        var indices: PackedInt32Array = placement.get("indices", PackedInt32Array())
        result.append({
            "action_id": str(definition.get("id", "")),
            "start_timing": int(indices[0]) if not indices.is_empty() else anchor_index,
            "end_timing": int(indices[indices.size() - 1]) if not indices.is_empty() else anchor_index
        })
    return result

func _configure_keyboard_focus_order() -> void:
    super._configure_keyboard_focus_order()
    if not is_instance_valid(action_selection_dock):
        return
    var sequence: Array[Control] = [
        action_selection_dock.basic_tab,
        action_selection_dock.martial_tab,
        action_selection_dock.ultimate_tab
    ]
    if action_selection_dock.interaction_state == "targeting" and is_instance_valid(action_selection_dock.action_intent_panel):
        sequence.append_array(action_selection_dock.action_intent_panel.intent_buttons)
    else:
        match action_selection_dock.active_source:
            "martial":
                sequence.append_array(action_selection_dock.martial_panel.manual_buttons)
                sequence.append_array(action_selection_dock.martial_panel.technique_buttons)
            "ultimate":
                sequence.append_array(action_selection_dock.ultimate_panel.action_buttons)
            _:
                sequence.append_array(action_selection_dock.basic_panel.buttons)

    var appended_anchors: Dictionary = {}
    var visible_timing_indices := action_timing_panel.get_visible_timing_indices()
    for timing_value in visible_timing_indices:
        var timing_index := int(timing_value)
        if action_timing_panel.has_assignment_at(timing_index):
            var anchor_index := action_timing_panel.get_assignment_anchor(timing_index)
            if appended_anchors.has(anchor_index):
                continue
            appended_anchors[anchor_index] = true
            if action_timing_panel.has_method("get_linked_block"):
                var block = action_timing_panel.call("get_linked_block", anchor_index)
                if is_instance_valid(block):
                    sequence.append(block as Control)
                    continue
        var slot := action_timing_panel.get_slot(timing_index)
        if is_instance_valid(slot):
            sequence.append(slot)

    if is_instance_valid(combat_progress_button) and is_instance_valid(combat_progress_button._button):
        sequence.append(combat_progress_button._button)
    for control_value in [fast_replay_button, reduced_motion_button, sound_toggle_button, sound_volume_slider]:
        if is_instance_valid(control_value):
            sequence.append(control_value as Control)
    _link_product_focus_sequence(sequence)
    set_meta("product_focus_order", "source_tabs|active_source|timings|targets|progress|presentation_controls")

func _link_product_focus_sequence(sequence: Array[Control]) -> void:
    var filtered: Array[Control] = []
    for control in sequence:
        if is_instance_valid(control) and control.visible and control.focus_mode != Control.FOCUS_NONE:
            filtered.append(control)
    if filtered.size() < 2:
        return
    for index in range(filtered.size()):
        var current := filtered[index]
        var previous := filtered[(index - 1 + filtered.size()) % filtered.size()]
        var next := filtered[(index + 1) % filtered.size()]
        current.focus_previous = current.get_path_to(previous)
        current.focus_next = current.get_path_to(next)

func _presentation_summary_for_event(event: Dictionary, fallback: String) -> String:
    if str(event.get("action_stage", "execution")) == "preparation":
        return "[전조] %s" % str(event.get("card_name", "행동"))
    return super._presentation_summary_for_event(event, fallback)
