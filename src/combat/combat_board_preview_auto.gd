extends CombatBoardPreview

const PREPARE_ENGINE_SCRIPT := preload("res://src/combat/combat_resolution_engine_prepare.gd")
const ACTION_PLACEMENT_CONTROLLER_SCRIPT := preload("res://src/ui/action_selection/action_placement_controller.gd")
const ACTION_SELECTION_DOCK_SCENE := preload("res://scenes/ui/action_selection/action_selection_dock.tscn")

var action_placement_controller: ActionPlacementController
var action_selection_dock: ActionSelectionDock
var _pending_controller_definition: Dictionary = {}
var _plan_locked := false
var _last_applied_active_duel_rect := Rect2()
var _has_applied_active_duel_rect := false

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
    _set_plan_locked_surface_visible(false)
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
    if super._inputs_locked() or not action_timing_panel.is_current_bundle_complete():
        return
    # A valid activation atomically closes private planning and hands the
    # committed bundle to the existing authoritative resolver.
    _set_plan_locked_surface_visible(true)
    if is_instance_valid(combat_progress_button):
        combat_progress_button.set_plan_locked(false)
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
    _apply_state_derived_product_layout()

func _inputs_locked() -> bool:
    return _plan_locked or super._inputs_locked()

func _set_resolution_surface_visible(value: bool) -> void:
    super._set_resolution_surface_visible(value)
    if is_instance_valid(action_selection_dock):
        action_selection_dock.visible = value
    if is_instance_valid(observation_reveal_panel):
        observation_reveal_panel.visible = value
    _apply_state_derived_product_layout()

func _set_plan_locked_surface_visible(value: bool) -> void:
    if is_instance_valid(planning_surface):
        planning_surface.visible = not value
    if is_instance_valid(action_timing_panel):
        action_timing_panel.visible = not value
    if is_instance_valid(action_selection_dock):
        action_selection_dock.visible = not value
    if is_instance_valid(observation_reveal_panel):
        observation_reveal_panel.visible = not value
    if is_instance_valid(combat_progress_button):
        combat_progress_button.visible = true
    if value:
        _expand_locked_duel_stage()
        _layout_locked_plan_execute_prompt()
    else:
        _apply_state_derived_product_layout()

func _expand_locked_duel_stage() -> void:
    _apply_state_derived_product_layout()

func _uses_expanded_execution_layout() -> bool:
    var planning_is_visible := is_instance_valid(planning_surface) and planning_surface.visible
    return not planning_is_visible or _presentation_state not in ["planning", "next_bundle_ready"]

func _apply_state_derived_product_layout() -> void:
    if not _layout_ready or not is_instance_valid(action_selection_dock) or not is_instance_valid(top_hud) or not is_instance_valid(duel_stage_surface):
        return
    if not is_instance_valid(battle_background) or not is_instance_valid(duel_foreground_banner) or not is_instance_valid(_background_readability_tint):
        return
    if not size.is_finite() or size.x <= 0.0 or size.y <= 0.0:
        return
    var expanded := _uses_expanded_execution_layout()
    # The combat field is the primary surface; HUD panels float above it.
    var duel_y := 0.0
    var planning_top := clampf(size.y * 0.60, 260.0, size.y - 296.0)
    var active_rect := Rect2(0.0, duel_y, size.x, size.y - duel_y if expanded else planning_top - duel_y - 5.0)
    if not active_rect.position.is_finite() or not active_rect.size.is_finite() or not active_rect.has_area():
        return
    # Compare only final successful layouts, not super's temporary planning rect.
    var delta_position := (active_rect.position - _last_applied_active_duel_rect.position).abs()
    var delta_size := (active_rect.size - _last_applied_active_duel_rect.size).abs()
    var geometry_changed := _has_applied_active_duel_rect and maxf(maxf(delta_position.x, delta_position.y), maxf(delta_size.x, delta_size.y)) > 0.01
    if not expanded:
        _layout_product_action_dock()
    duel_stage_surface.position = active_rect.position
    duel_stage_surface.size = active_rect.size
    top_hud_surface.visible = false
    top_hud.z_index = 10
    battle_background.set_stage_rect(active_rect)
    duel_foreground_banner.set_stage_rect(active_rect)
    _background_readability_tint.position = active_rect.position
    _background_readability_tint.size = active_rect.size
    if not _apply_frontal_duel_composition():
        return
    if geometry_changed:
        player_character.snap_move_for_relayout(_presentation_anchor_for_actor("player"))
        enemy_character.snap_move_for_relayout(_presentation_anchor_for_actor("enemy"))
    if expanded:
        duel_foreground_banner.visible = false
        top_hud.round_panel.visible = false
        var gap := clampf(size.y * 0.015, 10.0, 18.0)
        var compare_height := clampf(active_rect.size.y * 0.40, 270.0, 340.0)
        var compare_rect := Rect2(active_rect.position, Vector2(active_rect.size.x, compare_height))
        var inset := clampf(size.x * 0.04, 24.0, 72.0)
        var impact_y := compare_rect.end.y + gap
        var impact_height := active_rect.end.y - gap - impact_y
        var impact_rect := Rect2(active_rect.position.x + inset, impact_y, active_rect.size.x - 2.0 * inset, impact_height)
        var label_height := clampf(impact_height * 0.20, 64.0, 96.0)
        var label_rect := Rect2(impact_rect.position.x + impact_rect.size.x * 0.15, impact_rect.end.y - label_height, impact_rect.size.x * 0.70, label_height)
        _apply_presentation_layout_lanes(compare_rect, label_rect, Rect2(impact_rect.position, Vector2(impact_rect.size.x, label_rect.position.y - gap - impact_y)))
    else:
        duel_foreground_banner.visible = true
        top_hud.round_panel.visible = true
        _clear_presentation_layout_lanes()
    _last_applied_active_duel_rect = active_rect
    _has_applied_active_duel_rect = true
    set_meta("duel_stage_surface_rect", active_rect)
    set_meta("locked_duel_stage_expanded", expanded)

func _layout_locked_plan_execute_prompt() -> void:
    if not _plan_locked or not is_instance_valid(combat_progress_button):
        return
    var duel_rect := get_duel_stage_rect()
    if duel_rect.size.x <= 0.0 or duel_rect.size.y <= 0.0:
        return
    var prompt_size := Vector2(clampf(size.x * 0.09, 104.0, 124.0), 48.0)
    combat_progress_button.size = prompt_size
    combat_progress_button.position = Vector2(
        duel_rect.get_center().x - prompt_size.x * 0.5,
        maxf(duel_rect.position.y + 14.0, duel_rect.end.y - prompt_size.y - 12.0)
    )

func _refresh_ultimate_menu() -> void:
    super._refresh_ultimate_menu()
    _hide_legacy_action_ui()
    _sync_action_selection_dock()

func _layout_board() -> void:
    var previous_defer := _defer_character_snap
    # Base configures logical tiles; an ordinary relayout must not snap MOVE
    # to those hidden tile anchors before the final frontal composition.
    if is_instance_valid(player_character) and is_instance_valid(enemy_character):
        _defer_character_snap = previous_defer or player_character.motion_state == "move" or enemy_character.motion_state == "move"
    super._layout_board()
    _defer_character_snap = previous_defer
    _apply_state_derived_product_layout()

func _layout_product_action_dock() -> void:
    if not is_instance_valid(action_selection_dock) or size.x <= 0.0 or size.y <= 0.0:
        return
    var lower_margin := maxf(12.0, size.x * 0.012)
    var lower_bottom := maxf(6.0, size.y * 0.0085)
    # The summary-card continuation moves the planning ink frame only enough
    # to keep two readable rows at 720p while retaining the top HUD and a
    # distinct frontal duel field.
    var planning_top := clampf(size.y * 0.60, 260.0, size.y - 296.0)
    var timing_height := clampf(size.y * 0.20 - 88.0, 64.0, 100.0)
    var timing_y := planning_top + 4.0
    var dock_y := timing_y + timing_height + 4.0
    var dock_height := maxf(142.0, size.y - dock_y - lower_bottom)
    var columns_width := size.x - lower_margin * 2.0 - 16.0
    var source_width := columns_width * 0.52
    var detail_width := columns_width * 0.23
    var observation_width := columns_width * 0.25
    var observation_x := lower_margin + source_width + detail_width + 16.0
    action_selection_dock.position = Vector2(lower_margin, dock_y)
    action_selection_dock.size = Vector2(source_width + 8.0 + detail_width, dock_height)
    action_selection_dock.configure_preparation_columns(source_width, detail_width, dock_y - timing_y)

    var execute_height := maxf(48.0, combat_progress_button.get_combined_minimum_size().y) if is_instance_valid(combat_progress_button) else 48.0
    if is_instance_valid(action_timing_panel) and is_instance_valid(combat_progress_button):
        var timing_width := source_width
        action_timing_panel.position = Vector2(lower_margin, timing_y)
        action_timing_panel.size = Vector2(timing_width, timing_height)
        combat_progress_button.size = Vector2(observation_width, execute_height)
        combat_progress_button.position = Vector2(observation_x, size.y - lower_bottom - execute_height)
        _shift_battlefield_above(planning_top - 24.0)
        _layout_screen_surfaces(planning_top)

    if is_instance_valid(observation_reveal_panel):
        # This source frame is portrait-oriented.  Preserve that visual lane so
        # its parchment rows stay readable rather than treating it as a short
        # horizontal tooltip beneath the detail column.
        observation_reveal_panel.position = Vector2(observation_x, timing_y)
        observation_reveal_panel.size = Vector2(observation_width, size.y - lower_bottom - timing_y - execute_height - 8.0)

    for control_value in [fast_replay_button, combat_log_panel]:
        if is_instance_valid(control_value):
            var control := control_value as Control
            control.visible = false
            control.focus_mode = Control.FOCUS_NONE
    if is_instance_valid(sound_toggle_button) and is_instance_valid(sound_volume_slider):
        sound_toggle_button.visible = true
        sound_toggle_button.focus_mode = Control.FOCUS_ALL
        sound_toggle_button.size = Vector2(94.0, 34.0)
        sound_toggle_button.position = Vector2(size.x - lower_margin - 392.0, planning_top - 38.0)
        sound_toggle_button.z_index = 40
        sound_toggle_button.tooltip_text = "전투 효과음을 켜거나 끕니다. 결과 텍스트와 판정은 유지됩니다."
        sound_volume_slider.visible = true
        sound_volume_slider.focus_mode = Control.FOCUS_ALL
        sound_volume_slider.size = Vector2(134.0, 34.0)
        sound_volume_slider.position = Vector2(size.x - lower_margin - 290.0, planning_top - 38.0)
        sound_volume_slider.z_index = 40
        sound_volume_slider.tooltip_text = "효과음 음량 · 좌우 화살표로 조절"
    if is_instance_valid(reduced_motion_button):
        reduced_motion_button.visible = true
        reduced_motion_button.focus_mode = Control.FOCUS_ALL
        reduced_motion_button.size = Vector2(148.0, 34.0)
        reduced_motion_button.position = Vector2(size.x - lower_margin - 148.0, planning_top - 38.0)
        reduced_motion_button.tooltip_text = "카메라 흔들림과 타격 정지를 끕니다. 판정과 결과 텍스트는 유지됩니다."
    _settle_inline_result_row(38.0, 4.0)
    _hide_legacy_action_ui()

func _settle_inline_result_row(row_height: float, row_gap: float) -> void:
    if not _layout_ready:
        super._settle_inline_result_row(row_height, row_gap)
        return
    if not is_instance_valid(inline_result_label):
        return
    var margin := maxf(12.0, size.x * 0.012)
    var planning_top := clampf(size.y * 0.60, 260.0, size.y - 296.0)
    # Previous-bundle cause and presentation preferences own separate lanes.
    inline_result_label.position = Vector2(margin, planning_top - 42.0)
    inline_result_label.size = Vector2(size.x - margin * 2.0 - 408.0, 38.0)
    set_meta("inline_result_row_bounded", true)

func _frontal_anchor_pair(player_tile: int, enemy_tile: int, floor_y: float) -> Dictionary:
    # Keep all ten logical distances distinguishable, including distances 5–9.
    # This is a visual projection only; positions and range rules remain domain-owned.
    var normalized_distance := clampf(float(absi(enemy_tile - player_tile)) / 9.0, 0.0, 1.0)
    var separation := lerpf(size.x * 0.135, size.x * 0.29, normalized_distance)
    var drift := clampf((float(player_tile + enemy_tile) * 0.5 - 5.5) * size.x * 0.014, -size.x * 0.05, size.x * 0.05)
    return {"player": Vector2(size.x * 0.5 + drift - separation, floor_y), "enemy": Vector2(size.x * 0.5 + drift + separation, floor_y)}

func _presentation_anchor_for_actor(actor_key: String) -> Vector2:
    return _frontal_anchor_pair(_player_tile, _enemy_tile, battle_background.get_duel_floor_y(size))[actor_key]

func _apply_frontal_duel_composition() -> bool:
    if not is_instance_valid(player_character) or not is_instance_valid(enemy_character) or tiles.is_empty():
        return false
    _set_tactical_target_layer_visible(false)
    if is_instance_valid(_anchor_line):
        _anchor_line.visible = false

    var duel_rect := get_duel_stage_rect()
    var hud_bottom := maxf(top_hud.position.y + top_hud.size.y, duel_rect.position.y) if is_instance_valid(top_hud) else duel_rect.position.y
    var player_foot_y := battle_background.get_duel_floor_y(size)
    var anchors := _frontal_anchor_pair(_player_tile, _enemy_tile, player_foot_y)
    var duel_center_x: float = (anchors.player.x + anchors.enemy.x) * 0.5
    for actor in [player_character, enemy_character]:
        var factor: float = actor.get_idle_art_height_per_node_height()
        var max_idle_ratio: float = minf(0.60, 0.67 / actor.get_existing_motion_peak_scale())
        if factor <= 0.0 or actor.character_height_ratio <= 0.0 or max_idle_ratio < 0.58:
            return false
    for actor in [player_character, enemy_character]:
        var node_height: float = duel_rect.size.y * 0.58 / actor.get_idle_art_height_per_node_height()
        actor.set_dimensions(node_height / actor.character_height_ratio)
    player_character.z_index = 4
    enemy_character.z_index = 4
    if not _defer_character_snap:
        if player_character.motion_state != "move":
            player_character.place_foot_at(anchors.player)
        if enemy_character.motion_state != "move":
            enemy_character.place_foot_at(anchors.enemy)

    if is_instance_valid(range_readout_panel):
        var range_size := Vector2(clampf(size.x * 0.090, 104.0, 122.0), 44.0)
        var range_y := top_hud.position.y + top_hud.size.y * 0.50 if is_instance_valid(top_hud) else hud_bottom + 12.0
        range_readout_panel.position = Vector2(duel_center_x - range_size.x * 0.5, range_y)
        range_readout_panel.size = range_size
        range_readout_panel.z_index = 6

    set_meta("duel_composition", "player_left|enemy_right|shared_ground|distance_center")
    set_meta("duel_floor_y", player_foot_y)
    set_meta("character_scale_profile", "distant_frontal_duel")
    set_meta("logical_board_default_visibility", "hidden")
    return true

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
    # Logical tile layout is hidden; only the final frontal composition places
    # actors. In particular, this planning shift must not reposition live MOVE.
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
        "terminal_result_ready":
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
        "preview_actor": {
            "stats": (player.get("stats", {}) as Dictionary).duplicate(true),
            "attack_power": int(player.get("attack_power", 0))
        },
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
