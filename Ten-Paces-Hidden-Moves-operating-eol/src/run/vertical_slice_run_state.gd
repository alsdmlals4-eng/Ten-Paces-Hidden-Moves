class_name VerticalSliceRunState
extends RefCounted

signal screen_changed(previous_screen: String, current_screen: String)

const PROGRESSION_SCRIPT := preload("res://src/run/vertical_slice_progression_state.gd")
const ROUTE_MODEL_SCRIPT := preload("res://src/run/vertical_slice_route_model.gd")

const SCREEN_MAIN := "MAIN"
const SCREEN_SETUP := "SETUP"
const SCREEN_INTRO := "INTRO"
const SCREEN_BRIEFING := "BRIEFING"
const SCREEN_COMBAT := "COMBAT"
const SCREEN_REVIEW := "REVIEW"
const SCREEN_RESULT := "RESULT"
const SCREEN_ROUTE_GROWTH := "ROUTE_GROWTH"
const SCREEN_ROUTE_INFO := "ROUTE_INFO"
const SCREEN_COMPLETION := "COMPLETION"
const MAX_DUELS := 5
const STARTER_SELECTION_COUNT := 4
const STARTER_MASTERY := 3

var duel_index: int = 1
var completed_duels: int = 0
var route_visits: int = 0
var last_combat_result: Dictionary = {}

var _current_screen: String = SCREEN_MAIN
var _flow_history: Array[String] = [SCREEN_MAIN]
var _opponent_catalog = null
var _run_seed: int = 0
var _current_opponent_id: String = ""
var _next_opponent_id: String = ""
var _player_manual_loadout: Array[String] = []
var _player_mastery_by_manual: Dictionary = {}
var _pending_result_reward: Dictionary = {}
var _reward_history: Array[Dictionary] = []
var _duel_history: Array[Dictionary] = []
var _progression: VerticalSliceProgressionState
var _route_model: VerticalSliceRouteModel
var _pending_growth_route: Dictionary = {}
var _pending_route_intel: Dictionary = {}
var _route_history: Array[Dictionary] = []
var _intel_by_candidate: Dictionary = {}


func _init() -> void:
    _progression = PROGRESSION_SCRIPT.new()
    _progression.reset()
    _route_model = ROUTE_MODEL_SCRIPT.new()


func get_current_screen() -> String:
    return _current_screen


func get_flow_history() -> Array[String]:
    return _flow_history.duplicate()


func configure_opponents(catalog, run_seed: int) -> bool:
    if _current_screen != SCREEN_MAIN:
        return false
    if catalog == null or not catalog.has_method("is_valid") or not catalog.is_valid():
        return false
    _opponent_catalog = catalog
    _run_seed = run_seed
    _current_opponent_id = ""
    _next_opponent_id = ""
    return true


func get_current_opponent() -> Dictionary:
    if _opponent_catalog == null or _current_opponent_id.is_empty():
        return {}
    return _opponent_catalog.get_candidate(_current_opponent_id)


func get_route_target_opponent() -> Dictionary:
    if _opponent_catalog == null or _next_opponent_id.is_empty():
        return {}
    return _opponent_catalog.get_candidate(_next_opponent_id)


func confirm_setup_loadout(loadout, mastery_by_manual: Dictionary) -> bool:
    if _current_screen != SCREEN_SETUP:
        return false
    if typeof(loadout) != TYPE_ARRAY and typeof(loadout) != TYPE_PACKED_STRING_ARRAY:
        return false
    if loadout.size() != STARTER_SELECTION_COUNT:
        return false
    var next_loadout: Array[String] = []
    var seen := {}
    for value in loadout:
        var manual_id := str(value)
        if manual_id.is_empty() or seen.has(manual_id):
            return false
        if int(mastery_by_manual.get(manual_id, 0)) != STARTER_MASTERY:
            return false
        seen[manual_id] = true
        next_loadout.append(manual_id)
    if not _progression.initialize_from_setup(next_loadout, mastery_by_manual):
        return false
    _player_manual_loadout = next_loadout
    _player_mastery_by_manual = mastery_by_manual.duplicate(true)
    return true


func get_player_manual_loadout() -> Array:
    return _player_manual_loadout.duplicate()


func get_player_mastery_by_manual() -> Dictionary:
    if _progression != null:
        return (_progression.get_snapshot().get("mastery_by_manual", {}) as Dictionary).duplicate(true)
    return _player_mastery_by_manual.duplicate(true)


func get_player_run_resources() -> Dictionary:
    return _progression.get_player_resources() if _progression != null else {}


func get_progression_snapshot() -> Dictionary:
    return _progression.get_snapshot() if _progression != null else {}


func get_duel_history() -> Array:
    var result: Array = []
    for receipt in _duel_history:
        result.append(receipt.duplicate(true))
    return result


func has_pending_growth_route() -> bool:
    return not _pending_growth_route.is_empty()


func get_growth_route_options() -> Array:
    if _current_screen != SCREEN_ROUTE_GROWTH or _route_model == null or _progression == null:
        return []
    var node_id := _route_model.growth_node_id(completed_duels)
    return _route_model.get_growth_options(node_id, _progression.owned_manual_ids)


func get_info_route_options() -> Array:
    if _current_screen != SCREEN_ROUTE_INFO or _route_model == null:
        return []
    var node_id := _route_model.info_node_id(completed_duels)
    return _route_model.get_info_options(node_id, get_route_target_opponent())


func select_growth_route(choice_type: String, target_manual_id: String = "") -> bool:
    if _current_screen != SCREEN_ROUTE_GROWTH or _progression == null or _route_model == null:
        return false
    if not _pending_growth_route.is_empty():
        return false
    var node_id := _route_model.growth_node_id(completed_duels)
    var options := _route_model.get_growth_options(node_id, _progression.owned_manual_ids)
    var selected: Dictionary = {}
    for value in options:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("choice_type", "")) == choice_type:
            selected = (value as Dictionary).duplicate(true)
            break
    if selected.is_empty():
        return false
    match choice_type:
        "recovery":
            _progression.apply_recovery(
                float(selected.get("health_fraction", 0.0)),
                int(selected.get("stamina", 0)),
                int(selected.get("internal", 0))
            )
        "focused_training":
            if target_manual_id.is_empty() or not _progression.add_focused_training(target_manual_id, int(selected.get("focused_training", 0))):
                return false
            selected["target_manual_id"] = target_manual_id
        "free_training":
            if not _progression.add_free_training(int(selected.get("free_training", 0))):
                return false
        _:
            return false
    selected["node_id"] = node_id
    selected["route_type"] = "growth"
    _pending_growth_route = selected
    return true


func select_info_route(category: String) -> bool:
    if _current_screen != SCREEN_ROUTE_INFO or _route_model == null:
        return false
    if not _pending_route_intel.is_empty():
        return false
    var candidate := get_route_target_opponent()
    if candidate.is_empty():
        return false
    var node_id := _route_model.info_node_id(completed_duels)
    var valid := false
    for value in _route_model.get_info_options(node_id, candidate):
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("category", "")) == category:
            valid = true
            break
    if not valid:
        return false
    var text := _route_model.build_public_intel(category, candidate)
    if text.is_empty():
        return false
    _pending_route_intel = {
        "node_id": node_id,
        "route_type": "info",
        "candidate_id": str(candidate.get("candidate_id", "")),
        "category": category,
        "text": text
    }
    return true


func get_pending_route_intel() -> Dictionary:
    return _pending_route_intel.duplicate(true)


func get_current_opponent_intel() -> Dictionary:
    if _current_opponent_id.is_empty() or not _intel_by_candidate.has(_current_opponent_id):
        return {}
    return (_intel_by_candidate[_current_opponent_id] as Dictionary).duplicate(true)


func get_route_history() -> Array:
    var result: Array = []
    for receipt in _route_history:
        result.append(receipt.duplicate(true))
    return result


func set_pending_result_reward(receipt: Dictionary) -> bool:
    if _current_screen != SCREEN_RESULT or receipt.is_empty():
        return false
    var reward_type := str(receipt.get("reward_type", ""))
    if reward_type not in ["free_training", "focused_training", "faction_transfer"]:
        return false
    _pending_result_reward = receipt.duplicate(true)
    return true


func get_pending_result_reward() -> Dictionary:
    return _pending_result_reward.duplicate(true)


func get_reward_history() -> Array:
    var result: Array = []
    for receipt in _reward_history:
        result.append(receipt.duplicate(true))
    return result


func start_new_run() -> bool:
    if _current_screen != SCREEN_MAIN:
        return false
    duel_index = 1
    completed_duels = 0
    route_visits = 0
    last_combat_result.clear()
    _flow_history = [SCREEN_MAIN]
    _current_opponent_id = ""
    _next_opponent_id = ""
    _player_manual_loadout.clear()
    _player_mastery_by_manual.clear()
    _pending_result_reward.clear()
    _reward_history.clear()
    _duel_history.clear()
    _pending_growth_route.clear()
    _pending_route_intel.clear()
    _route_history.clear()
    _intel_by_candidate.clear()
    _progression.reset()
    if _opponent_catalog != null:
        _current_opponent_id = str(_opponent_catalog.select_candidate_id(1, _run_seed))
        if _current_opponent_id.is_empty():
            return false
    return _transition_to(SCREEN_SETUP)


func advance() -> bool:
    match _current_screen:
        SCREEN_SETUP:
            return _transition_to(SCREEN_INTRO)
        SCREEN_INTRO:
            return _transition_to(SCREEN_BRIEFING)
        SCREEN_BRIEFING:
            return _transition_to(SCREEN_COMBAT)
        SCREEN_COMBAT:
            return false
        SCREEN_REVIEW:
            return _transition_to(SCREEN_RESULT)
        SCREEN_RESULT:
            if _pending_result_reward.is_empty():
                return false
            if completed_duels >= MAX_DUELS:
                if not _confirm_pending_result_reward():
                    return false
                return _transition_to(SCREEN_COMPLETION)
            if not _lock_next_opponent_if_configured():
                return false
            if not _confirm_pending_result_reward():
                return false
            _pending_growth_route.clear()
            _pending_route_intel.clear()
            return _transition_to(SCREEN_ROUTE_GROWTH)
        SCREEN_ROUTE_GROWTH:
            if _pending_growth_route.is_empty():
                return false
            _route_history.append(_pending_growth_route.duplicate(true))
            _pending_growth_route.clear()
            return _transition_to(SCREEN_ROUTE_INFO)
        SCREEN_ROUTE_INFO:
            if _pending_route_intel.is_empty():
                return false
            var intel_receipt := _pending_route_intel.duplicate(true)
            _route_history.append(intel_receipt)
            _intel_by_candidate[str(intel_receipt.get("candidate_id", ""))] = intel_receipt.duplicate(true)
            _pending_route_intel.clear()
            duel_index += 1
            _promote_next_opponent_if_configured()
            return _transition_to(SCREEN_BRIEFING)
        _:
            return false


func mark_combat_finished(result: Dictionary) -> bool:
    if _current_screen != SCREEN_COMBAT:
        return false
    if completed_duels >= MAX_DUELS:
        return false
    last_combat_result = result.duplicate(true)
    var resources = result.get("player_resources", null)
    if typeof(resources) == TYPE_DICTIONARY:
        _progression.set_player_resources(resources as Dictionary)
    _duel_history.append(_build_duel_history_row(result))
    _pending_result_reward.clear()
    completed_duels += 1
    return _transition_to(SCREEN_REVIEW)


func is_complete() -> bool:
    return _current_screen == SCREEN_COMPLETION and completed_duels == MAX_DUELS


func _build_duel_history_row(result: Dictionary) -> Dictionary:
    var opponent := get_current_opponent()
    var review_source = result.get("review_summary", {})
    var review: Dictionary = review_source if typeof(review_source) == TYPE_DICTIONARY else {}
    var metrics_source = result.get("battle_metrics", {})
    var metrics: Dictionary = metrics_source if typeof(metrics_source) == TYPE_DICTIONARY else {}
    return {
        "duel_index": duel_index,
        "opponent_candidate_id": _current_opponent_id,
        "opponent_working_name": str(opponent.get("working_name", "")),
        "outcome": str(result.get("outcome", "draw")),
        "review_summary": {
            "cause_code": str(review.get("cause_code", "")),
            "cause_label": str(review.get("cause_label", "")),
            "review_focus": str(review.get("review_focus", ""))
        },
        "battle_metrics": {
            "successful_dodges": maxi(0, int(metrics.get("successful_dodges", 0))),
            "clash_wins": maxi(0, int(metrics.get("clash_wins", 0))),
            "player_health_lost": maxi(0, int(metrics.get("player_health_lost", 0))),
            "rounds_elapsed": maxi(0, int(metrics.get("rounds_elapsed", 0))),
            "ultimate_uses": maxi(0, int(metrics.get("ultimate_uses", 0)))
        }
    }


func _confirm_pending_result_reward() -> bool:
    if _pending_result_reward.is_empty() or _progression == null:
        return false
    var receipt := _pending_result_reward.duplicate(true)
    var applied := _progression.apply_reward_receipt(receipt)
    if applied.is_empty():
        return false
    applied["duel_index"] = completed_duels
    applied["opponent_candidate_id"] = _current_opponent_id
    _reward_history.append(applied)
    _pending_result_reward.clear()
    return true


func _lock_next_opponent_if_configured() -> bool:
    if _opponent_catalog == null:
        return true
    if not _next_opponent_id.is_empty():
        return true
    var next_slot := duel_index + 1
    if next_slot > MAX_DUELS:
        return true
    _next_opponent_id = str(_opponent_catalog.select_candidate_id(next_slot, _run_seed))
    return not _next_opponent_id.is_empty()


func _promote_next_opponent_if_configured() -> void:
    if _opponent_catalog == null:
        return
    _current_opponent_id = _next_opponent_id
    _next_opponent_id = ""


func _transition_to(next_screen: String) -> bool:
    if next_screen == _current_screen:
        return false
    var previous_screen := _current_screen
    _current_screen = next_screen
    if next_screen == SCREEN_ROUTE_GROWTH or next_screen == SCREEN_ROUTE_INFO:
        route_visits += 1
    _flow_history.append(next_screen)
    screen_changed.emit(previous_screen, next_screen)
    return true
