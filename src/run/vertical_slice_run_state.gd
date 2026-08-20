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

var duel_index: int = 1
var completed_duels: int = 0
var route_visits: int = 0
var last_combat_result: Dictionary = {}

var _current_screen: String = SCREEN_MAIN
var _flow_history: Array[String] = [SCREEN_MAIN]


func get_current_screen() -> String:
    return _current_screen


func get_flow_history() -> Array[String]:
    return _flow_history.duplicate()


func start_new_run() -> bool:
    if _current_screen != SCREEN_MAIN:
        return false
    duel_index = 1
    completed_duels = 0
    route_visits = 0
    last_combat_result.clear()
    _flow_history = [SCREEN_MAIN]
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
            return _transition_to(SCREEN_ROUTE_GROWTH)
        SCREEN_ROUTE_GROWTH:
            return _transition_to(SCREEN_ROUTE_INFO)
        SCREEN_ROUTE_INFO:
            duel_index += 1
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
