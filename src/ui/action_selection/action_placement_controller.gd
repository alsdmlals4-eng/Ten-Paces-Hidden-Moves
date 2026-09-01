class_name ActionPlacementController
extends RefCounted

signal placement_succeeded(result: Dictionary)
signal placement_failed(code: String, message: String)
signal placement_moved(result: Dictionary)
signal targeting_requested(anchor_index: int)

const CODE_NO_CONTIGUOUS_TIMINGS := "NO_CONTIGUOUS_TIMINGS"
const CODE_MOMENTUM_INSUFFICIENT := "MOMENTUM_INSUFFICIENT"
const CODE_TARGETING_IN_PROGRESS := "TARGETING_IN_PROGRESS"
const CODE_CURRENT_BUNDLE_LOCKED := "CURRENT_BUNDLE_LOCKED"
const CODE_INVALID_ACTION := "INVALID_ACTION"

var timing_panel: ActionTimingPanel
var can_reserve_ultimate: Callable
var reserve_ultimate: Callable
var refund_ultimate: Callable
var begin_targeting: Callable
var locked := false
var targeting_in_progress := false
var targeting_anchor := 0

func configure(
    value_timing_panel: ActionTimingPanel,
    value_can_reserve_ultimate: Callable,
    value_reserve_ultimate: Callable,
    value_refund_ultimate: Callable,
    value_begin_targeting: Callable
) -> void:
    timing_panel = value_timing_panel
    can_reserve_ultimate = value_can_reserve_ultimate
    reserve_ultimate = value_reserve_ultimate
    refund_ultimate = value_refund_ultimate
    begin_targeting = value_begin_targeting

func set_locked(value: bool) -> void:
    locked = value

func set_targeting_in_progress(value: bool, anchor_index: int = 0) -> void:
    targeting_in_progress = value
    targeting_anchor = anchor_index if value else 0

func select_and_place(definition: Dictionary) -> bool:
    if locked:
        return _fail(CODE_CURRENT_BUNDLE_LOCKED, "현재 행동 묶음은 편집할 수 없습니다.")
    if targeting_in_progress:
        return _fail(CODE_TARGETING_IN_PROGRESS, "먼저 배치된 이동의 접근 또는 후퇴를 정해야 합니다.")
    if definition.is_empty() or not is_instance_valid(timing_panel):
        return _fail(CODE_INVALID_ACTION, "배치할 행동 정보가 없습니다.")
    if bool(definition.get("locked", false)):
        return _fail(CODE_INVALID_ACTION, str(definition.get("lock_reason", "잠긴 행동입니다.")))

    var span := maxi(1, int(definition.get("action_slots", 1)))
    var anchor := int(timing_panel.call("find_earliest_open_anchor", span))
    if anchor <= 0:
        return _fail(CODE_NO_CONTIGUOUS_TIMINGS, "연속된 빈 행동 슬롯이 부족합니다.")

    var is_ultimate := _is_ultimate(definition)
    if is_ultimate and (not can_reserve_ultimate.is_valid() or not bool(can_reserve_ultimate.call(definition))):
        return _fail(CODE_MOMENTUM_INSUFFICIENT, "절초기세와 현재 묶음의 연속된 빈 슬롯이 모두 필요합니다.")

    if not timing_panel.place_card(definition, anchor):
        return _fail(CODE_NO_CONTIGUOUS_TIMINGS, "연속된 빈 행동 슬롯이 부족합니다.")

    if is_ultimate and reserve_ultimate.is_valid():
        reserve_ultimate.call(anchor)

    var placement := timing_panel.get_placement(anchor)
    var targeting_started := _start_targeting_if_needed(placement, anchor)

    var result := placement.duplicate(true)
    result["anchor_index"] = anchor
    result["span"] = span
    result["card_name"] = str(definition.get("name", ""))
    result["definition"] = definition.duplicate(true)
    result["is_ultimate"] = is_ultimate
    result["targeting_started"] = targeting_started
    placement_succeeded.emit(result)
    return true

func remove_at(timing_index: int) -> Dictionary:
    if locked or not is_instance_valid(timing_panel):
        return {}
    var placement := timing_panel.remove_at(timing_index)
    if placement.is_empty():
        return {}
    if _is_ultimate(placement.get("definition", {})) and refund_ultimate.is_valid():
        refund_ultimate.call(placement)
    if int(placement.get("anchor_index", 0)) == targeting_anchor:
        set_targeting_in_progress(false)
    return placement

func move_placement(anchor_index: int, new_anchor_index: int) -> bool:
    if locked or targeting_in_progress or not is_instance_valid(timing_panel):
        return false
    if not timing_panel.has_method("move_placement"):
        return false
    var original := timing_panel.get_placement(anchor_index)
    if original.is_empty():
        return false
    if not bool(timing_panel.call("move_placement", anchor_index, new_anchor_index)):
        return false

    var definition: Dictionary = original.get("definition", {})
    var is_ultimate := _is_ultimate(definition)
    if is_ultimate:
        if refund_ultimate.is_valid():
            refund_ultimate.call(original)
        if reserve_ultimate.is_valid():
            reserve_ultimate.call(new_anchor_index)

    var moved := timing_panel.get_placement(new_anchor_index)
    var targeting_started := _start_targeting_if_needed(moved, new_anchor_index)
    var result := moved.duplicate(true)
    result["previous_anchor_index"] = anchor_index
    result["anchor_index"] = new_anchor_index
    result["is_ultimate"] = is_ultimate
    result["targeting_started"] = targeting_started
    placement_moved.emit(result)
    return true

func _start_targeting_if_needed(placement: Dictionary, anchor_index: int) -> bool:
    if placement.is_empty() or bool(placement.get("target_ready", true)):
        return false
    var targeting_started := false
    if begin_targeting.is_valid():
        targeting_started = bool(begin_targeting.call(anchor_index))
    if targeting_started:
        targeting_in_progress = true
        targeting_anchor = anchor_index
        targeting_requested.emit(anchor_index)
    return targeting_started

func _is_ultimate(definition_value) -> bool:
    if typeof(definition_value) != TYPE_DICTIONARY:
        return false
    var definition: Dictionary = definition_value
    return str(definition.get("source_kind", definition.get("source", ""))) == "ultimate"

func _fail(code: String, message: String) -> bool:
    placement_failed.emit(code, message)
    return false
