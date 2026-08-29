class_name VerticalSliceOpponentCatalog
extends RefCounted

const DATA_PATH := "res://data/run/vertical_slice_opponents.json"
const RuntimeBindingScript := preload("res://src/run/vertical_slice_opponent_runtime_binding.gd")

var load_errors := PackedStringArray()

var _candidates: Array[Dictionary] = []
var _candidates_by_id: Dictionary = {}
var _candidates_by_slot: Dictionary = {}
var _selection_binding_status: String = ""


func _init(data_path: String = DATA_PATH) -> void:
    _load(data_path)


func is_valid() -> bool:
    return load_errors.is_empty()


func get_all_candidates() -> Array:
    var result: Array = []
    for candidate in _candidates:
        result.append(candidate.duplicate(true))
    return result


func get_candidates_for_slot(duel_slot: int) -> Array:
    var result: Array = []
    for value in _candidates_by_slot.get(duel_slot, []):
        if typeof(value) == TYPE_DICTIONARY:
            result.append((value as Dictionary).duplicate(true))
    return result


func get_candidate(candidate_id: String) -> Dictionary:
    var value = _candidates_by_id.get(candidate_id, {})
    if typeof(value) != TYPE_DICTIONARY:
        return {}
    return (value as Dictionary).duplicate(true)


func get_selection_binding_status() -> String:
    return _selection_binding_status


func select_candidate_id(duel_slot: int, run_seed: int) -> String:
    var slot_candidates: Array = _candidates_by_slot.get(duel_slot, [])
    if slot_candidates.is_empty():
        return ""
    var index := (run_seed + duel_slot * 17) % slot_candidates.size()
    if index < 0:
        index += slot_candidates.size()
    var candidate = slot_candidates[index]
    if typeof(candidate) != TYPE_DICTIONARY:
        return ""
    return str((candidate as Dictionary).get("candidate_id", ""))


func _load(data_path: String) -> void:
    load_errors.clear()
    _candidates.clear()
    _candidates_by_id.clear()
    _candidates_by_slot.clear()
    _selection_binding_status = ""

    if not FileAccess.file_exists(data_path):
        load_errors.append("missing opponent data: %s" % data_path)
        return

    var file := FileAccess.open(data_path, FileAccess.READ)
    if file == null:
        load_errors.append("failed to open opponent data: %s" % data_path)
        return

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        load_errors.append("opponent data root must be a Dictionary")
        return

    var root := parsed as Dictionary
    _selection_binding_status = str(root.get("selection_binding_status", ""))
    if _selection_binding_status != "REVERSIBLE_SELECTION_BINDING":
        load_errors.append("selection binding must remain explicitly reversible")

    var raw_candidates = root.get("candidates", [])
    if typeof(raw_candidates) != TYPE_ARRAY:
        load_errors.append("candidates must be an Array")
        return

    var runtime_binding = RuntimeBindingScript.new()
    if not runtime_binding.is_valid():
        for binding_error in runtime_binding.get_load_errors():
            load_errors.append("runtime binding data: %s" % str(binding_error))
        return

    for value in raw_candidates:
        if typeof(value) != TYPE_DICTIONARY:
            load_errors.append("candidate entry must be a Dictionary")
            continue
        var candidate := (value as Dictionary).duplicate(true)
        var candidate_id := str(candidate.get("candidate_id", ""))
        var duel_slot := int(candidate.get("duel_slot", 0))
        if candidate_id.is_empty():
            load_errors.append("candidate_id may not be empty")
            continue
        if _candidates_by_id.has(candidate_id):
            load_errors.append("duplicate candidate_id: %s" % candidate_id)
            continue
        if duel_slot < 1 or duel_slot > 5:
            load_errors.append("invalid duel_slot for %s: %d" % [candidate_id, duel_slot])
            continue
        if str(candidate.get("runtime_archetype_id", "")).is_empty():
            load_errors.append("missing runtime_archetype_id for %s" % candidate_id)
            continue
        if not bool(runtime_binding.build(candidate).get("valid", false)):
            load_errors.append("invalid runtime binding candidate: %s" % candidate_id)
            continue

        _candidates.append(candidate)
        _candidates_by_id[candidate_id] = candidate
        if not _candidates_by_slot.has(duel_slot):
            _candidates_by_slot[duel_slot] = []
        (_candidates_by_slot[duel_slot] as Array).append(candidate)

    if _candidates.size() != 15:
        load_errors.append("expected 15 candidates, got %d" % _candidates.size())
    for duel_slot in range(1, 6):
        var slot_candidates: Array = _candidates_by_slot.get(duel_slot, [])
        if slot_candidates.size() != 3:
            load_errors.append("slot %d must contain exactly 3 candidates, got %d" % [duel_slot, slot_candidates.size()])
