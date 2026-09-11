extends RefCounted
## Private run adapter; only the current permitted candidate view leaves the run domain.
var _encounters: Array
var _provider
func _init(encounters: Array):
    _encounters = encounters.duplicate(true)
    _provider = load("res://src/run/variable_opponent_roster.gd").new()
func is_valid() -> bool:
    return _encounters.size() == 10 and _provider.is_valid()
func select_campaign_candidate_id(stage: int) -> String:
    return str(_encounters[stage - 1].candidate_id) if stage >= 1 and stage <= 10 else ""
func get_candidate(id: String) -> Dictionary:
    return _provider.get_candidate(id)
func for_stage(stage: int) -> Dictionary:
    return _provider.get_encounter_candidate(_encounters[stage - 1]) if stage >= 1 and stage <= 10 else {}
