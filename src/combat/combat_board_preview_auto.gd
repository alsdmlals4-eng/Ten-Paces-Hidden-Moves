extends CombatBoardPreview

const PREPARE_ENGINE_SCRIPT := preload("res://src/combat/combat_resolution_engine_prepare.gd")

func _ready() -> void:
    super._ready()
    resolution_engine = PREPARE_ENGINE_SCRIPT.new()
    combat_state = resolution_engine.make_initial_state(top_hud.hud_data, _player_tile, _enemy_tile)
    combat_state["ai_enabled"] = true
    _configure_ultimate_menu()
    _sync_runtime_context()
    _apply_combat_state_to_view()
    _refresh_ultimate_menu()
    set_meta("card_selection_mode", "auto_earliest_contiguous")
    set_meta("prepare_rule_extension", true)

func restart_combat() -> void:
    _player_tile = int(contract.get("player_start_tile", 4))
    _enemy_tile = int(contract.get("enemy_start_tile", 7))
    super.restart_combat()

func _on_action_card_selected(definition: Dictionary) -> void:
    if _inputs_locked():
        return
    if _targeting_anchor > 0:
        basic_card_tray.clear_action_selection()
        if is_instance_valid(combat_log_panel):
            combat_log_panel.append_entry("[대상 선택] 먼저 자동 배치된 행동의 이동 칸 또는 공격 방향을 지정해야 합니다.", "system")
        return
    _auto_place_selected_card(definition.duplicate(true))

func _on_ultimate_menu_id_pressed(index: int) -> void:
    if _inputs_locked() or index < 0 or index >= _ultimate_definitions.size() or _targeting_anchor > 0:
        return
    var definition := (_ultimate_definitions[index] as Dictionary).duplicate(true)
    _auto_place_selected_card(definition)

func _auto_place_selected_card(definition: Dictionary) -> bool:
    if definition.is_empty() or not is_instance_valid(action_timing_panel):
        return false
    var span := maxi(1, int(definition.get("action_slots", 1)))
    var anchor := int(action_timing_panel.call("find_earliest_open_anchor", span))
    var is_ultimate := str(definition.get("source", "")) == "ultimate"
    if anchor <= 0:
        _clear_auto_selection_state()
        if is_instance_valid(combat_log_panel):
            var prefix := "[절초 예약 불가]" if is_ultimate else "[배치 불가]"
            combat_log_panel.append_entry("%s 연속된 빈 행동 슬롯이 부족합니다." % prefix, "system")
        _refresh_ultimate_menu()
        return false
    if is_ultimate and not _can_reserve_ultimate(definition):
        _clear_auto_selection_state()
        if is_instance_valid(combat_log_panel):
            combat_log_panel.append_entry("[절초 예약 불가] 기세 5와 현재 묶음의 연속된 빈 슬롯이 모두 필요합니다.", "system")
        _refresh_ultimate_menu()
        return false
    if not action_timing_panel.place_card(definition, anchor):
        _clear_auto_selection_state()
        if is_instance_valid(combat_log_panel):
            combat_log_panel.append_entry("[배치 불가] 연속된 빈 행동 슬롯이 부족합니다.", "system")
        _refresh_ultimate_menu()
        return false

    if is_ultimate:
        _reserve_ultimate_at(anchor)
    var placement := {
        "card_name": str(definition.get("name", "")),
        "indices": _make_timing_indices(anchor, span)
    }
    if is_instance_valid(combat_log_panel):
        var prefix := "[절초 자동 예약]" if is_ultimate else "[자동 배치]"
        combat_log_panel.append_entry("%s %s · %s" % [prefix, str(placement.get("card_name", "")), _placement_timing_text(placement)], "system")
    _clear_auto_selection_state()
    if not _begin_targeting_for_anchor(anchor):
        _begin_next_pending_target()
    _refresh_ultimate_menu()
    return true

func _clear_auto_selection_state() -> void:
    _clear_action_selection()
    _clear_card_detail()
    if is_instance_valid(basic_card_tray):
        basic_card_tray.clear_action_selection()

func _presentation_summary_for_event(event: Dictionary, fallback: String) -> String:
    if str(event.get("action_stage", "execution")) == "preparation":
        return "[전조] %s" % str(event.get("card_name", "행동"))
    return super._presentation_summary_for_event(event, fallback)
