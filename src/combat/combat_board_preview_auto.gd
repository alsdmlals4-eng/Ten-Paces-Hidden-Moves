extends CombatBoardPreview

const PREPARE_ENGINE_SCRIPT := preload("res://src/combat/combat_resolution_engine_prepare.gd")
const ACTION_PLACEMENT_CONTROLLER_SCRIPT := preload("res://src/ui/action_selection/action_placement_controller.gd")

var action_placement_controller: ActionPlacementController
var _pending_controller_definition: Dictionary = {}

func _ready() -> void:
    super._ready()
    resolution_engine = PREPARE_ENGINE_SCRIPT.new()
    combat_state = resolution_engine.make_initial_state(top_hud.hud_data, _player_tile, _enemy_tile)
    combat_state["ai_enabled"] = true
    _configure_action_placement_controller()
    _configure_ultimate_menu()
    _sync_runtime_context()
    _apply_combat_state_to_view()
    _refresh_ultimate_menu()
    set_meta("card_selection_mode", "auto_earliest_contiguous")
    set_meta("prepare_rule_extension", true)
    set_meta("action_placement_controller", true)

func restart_combat() -> void:
    _player_tile = int(contract.get("player_start_tile", 4))
    _enemy_tile = int(contract.get("enemy_start_tile", 7))
    super.restart_combat()
    _sync_action_placement_controller_state()

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
    action_placement_controller.targeting_requested.connect(_on_controller_targeting_requested)
    _sync_action_placement_controller_state()

func _sync_action_placement_controller_state() -> void:
    if action_placement_controller == null:
        return
    action_placement_controller.set_locked(_inputs_locked())
    action_placement_controller.set_targeting_in_progress(_targeting_anchor > 0, _targeting_anchor)

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
        _begin_next_pending_target()
    _pending_controller_definition.clear()
    _refresh_ultimate_menu()

func _on_controller_placement_failed(code: String, message: String) -> void:
    var is_ultimate := _is_pending_ultimate()
    _clear_auto_selection_state()
    if is_instance_valid(combat_log_panel):
        match code:
            ActionPlacementController.CODE_TARGETING_IN_PROGRESS:
                combat_log_panel.append_entry("[대상 선택] 먼저 자동 배치된 행동의 이동 칸 또는 공격 방향을 지정해야 합니다.", "system")
            ActionPlacementController.CODE_MOMENTUM_INSUFFICIENT:
                combat_log_panel.append_entry("[절초 예약 불가] 기세 5와 현재 묶음의 연속된 빈 슬롯이 모두 필요합니다.", "system")
            ActionPlacementController.CODE_NO_CONTIGUOUS_TIMINGS:
                var prefix := "[절초 예약 불가]" if is_ultimate else "[배치 불가]"
                combat_log_panel.append_entry("%s 연속된 빈 행동 슬롯이 부족합니다." % prefix, "system")
            _:
                combat_log_panel.append_entry("[배치 불가] %s" % message, "system")
    _pending_controller_definition.clear()
    _refresh_ultimate_menu()

func _on_controller_targeting_requested(anchor_index: int) -> void:
    set_meta("controller_targeting_anchor", anchor_index)

func _is_pending_ultimate() -> bool:
    return str(_pending_controller_definition.get("source_kind", _pending_controller_definition.get("source", ""))) == "ultimate"

func _clear_auto_selection_state() -> void:
    _clear_action_selection()
    _clear_card_detail()
    if is_instance_valid(basic_card_tray):
        basic_card_tray.clear_action_selection()

func _presentation_summary_for_event(event: Dictionary, fallback: String) -> String:
    if str(event.get("action_stage", "execution")) == "preparation":
        return "[전조] %s" % str(event.get("card_name", "행동"))
    return super._presentation_summary_for_event(event, fallback)
