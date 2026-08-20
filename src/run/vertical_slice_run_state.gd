class_name VerticalSliceRunState
extends RefCounted

signal screen_changed(previous_screen: String, current_screen: String)

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
    _player_manual_loadout = next_loadout
    _player_mastery_by_manual = mastery_by_manual.duplicate(true)
    return true


func get_player_manual_loadout() -> Array:
    return _player_manual_loadout.duplicate()


func get_player_mastery_by_manual() -> Dictionary:
    return _player_mastery_by_manual.duplicate(true)


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
            if completed_duels >= MAX_DUELS:
                return _transition_to(SCREEN_COMPLETION)
            if not _lock_next_opponent_if_configured():
                return false
            return _transition_to(SCREEN_ROUTE_GROWTH)
        SCREEN_ROUTE_GROWTH:
            return _transition_to(SCREEN_ROUTE_INFO)
        SCREEN_ROUTE_INFO:
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
    completed_duels += 1
    return _transition_to(SCREEN_REVIEW)


func is_complete() -> bool:
    return _current_screen == SCREEN_COMPLETION and completed_duels == MAX_DUELS


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
