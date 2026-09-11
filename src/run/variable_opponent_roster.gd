class_name VariableOpponentRoster
extends RefCounted
## Approved content projection, isolated from the v1 catalog and content identity.
const DATA_PATH := "res://data/run/approved_opponent_stages_v2.json"
const SOURCE_REVISION := "c95ec7e671b14cfa1e8954f1f495ba2833bbd101"
const RULESET_ID := "ten-duel-variable-roster-v2"
const ROSTER_VERSION := 1
var _errors := PackedStringArray()
var _candidates := {}
var _stages := {}
var _ids: Array = []

func _init(data_path: String = DATA_PATH) -> void:
    if not FileAccess.file_exists(data_path):
        _errors.append("Missing approved opponent stages")
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(data_path))
    if not parsed is Dictionary or parsed.get("source_revision") != SOURCE_REVISION or parsed.get("ruleset_id") != RULESET_ID:
        _errors.append("Invalid approved opponent source")
        return
    var entries = parsed.get("candidates")
    if not entries is Array or entries.size() != 16:
        _errors.append("Expected 16 approved candidates")
        return
    for entry in entries:
        if not entry is Dictionary or not entry.get("candidate") is Dictionary or not entry.get("stages") is Array:
            _errors.append("Malformed approved candidate")
            continue
        entry = _normalize_numbers(entry)
        var candidate: Dictionary = entry.candidate
        var id: String = str(candidate.get("candidate_id", ""))
        if id.is_empty() or _candidates.has(id) or entry.stages.size() != 10:
            _errors.append("Invalid candidate identity or stage count")
            continue
        _candidates[id] = candidate.duplicate(true)
        _stages[id] = entry.stages.duplicate(true)
        for i in range(10):
            if not _valid_stage(entry.stages[i], candidate, i + 1):
                _errors.append("Invalid approved row: %s:%d" % [id, i + 1])
    _ids = _candidates.keys()
    _ids.sort()

func _valid_stage(row: Variant, candidate: Dictionary, stage: int) -> bool:
    if not row is Dictionary or row.get("stage") != stage or row.get("candidate_id") != candidate.candidate_id or row.get("source_revision") != SOURCE_REVISION:
        return false
    if not row.get("stats") is Dictionary or row.stats.size() != 5 or not row.get("manuals") is Array or row.manuals.is_empty():
        return false
    for key in ["external", "constitution", "agility", "internal_power", "insight"]:
        if not _integer(row.stats.get(key)) or row.stats[key] < 1: return false
    if not _same(row.get("resource_caps"), {"health":30,"stamina":5,"internal":4}): return false
    var seen := {}
    for manual in row.manuals:
        if not manual is Dictionary or not manual.get("id") is String or not _integer(manual.get("mastery")):
            return false
        if manual.mastery < 3 or manual.mastery > 10 or seen.has(manual.id): return false
        if not FileAccess.file_exists("res://data/cards/martial_manuals/%s.json" % manual.id): return false
        seen[manual.id] = true
    return row.manuals[0].id == candidate.get("signature_manual_id")

func is_valid() -> bool:
    return _errors.is_empty()

func get_load_errors() -> PackedStringArray:
    return _errors.duplicate()

func get_all_candidates() -> Array:
    var result: Array = []
    for id in _ids: result.append(get_candidate(id))
    return result

func get_candidate(id: String) -> Dictionary:
    return _candidates.get(id, {}).duplicate(true)

func get_stage(id: String, stage: int) -> Dictionary:
    if not is_valid() or not _stages.has(id) or stage < 1 or stage > 10: return {}
    return _stages[id][stage - 1].duplicate(true)

func generate(run_seed: int, save_id: String = "run") -> Array:
    if not is_valid() or save_id.is_empty(): return []
    var rng := RandomNumberGenerator.new()
    rng.seed = run_seed
    var result: Array = []
    var previous_id := ""
    var previous_type := ""
    for stage in range(1, 11):
        var weights: Array[int] = []
        var total := 0
        for id in _ids:
            var weight := 100
            if id == previous_id: weight = int(weight * 25 / 100)
            if _candidates[id].runtime_archetype_id == previous_type: weight = int(weight * 50 / 100)
            weights.append(weight)
            total += weight
        var draw := rng.randi_range(0, total - 1)
        for i in range(_ids.size()):
            draw -= weights[i]
            if draw < 0:
                previous_id = _ids[i]
                previous_type = _candidates[previous_id].runtime_archetype_id
                var row := get_stage(previous_id, stage)
                row["encounter_id"] = "%s:%02d" % [save_id, stage]
                result.append(row)
                break
    return result

## Validate persisted content without RNG calls. Seed-only reconstruction is unsafe
## across engine upgrades; the enclosing save owns roster_seed/integrity identity.
func validate(encounters: Array, _run_seed: int, save_id: String = "run") -> bool:
    if not is_valid() or encounters.size() != 10 or save_id.is_empty(): return false
    for index in range(10):
        var row = encounters[index]
        if not validate_encounter(row): return false
        if row.stage != index + 1 or row.encounter_id != "%s:%02d" % [save_id, index + 1]: return false
    return true

func validate_encounter(encounter: Variant) -> bool:
    if not encounter is Dictionary or not _integer(encounter.get("stage")) or not encounter.get("candidate_id") is String:
        return false
    var expected := get_stage(encounter.candidate_id, int(encounter.stage))
    if expected.is_empty() or not encounter.get("encounter_id") is String or encounter.encounter_id.is_empty(): return false
    expected["encounter_id"] = encounter.encounter_id
    return _same(expected, encounter)

func get_encounter_candidate(encounter: Dictionary) -> Dictionary:
    if not validate_encounter(encounter): return {}
    var result := get_candidate(encounter.candidate_id)
    for key in encounter: result[key] = encounter[key].duplicate(true) if encounter[key] is Dictionary or encounter[key] is Array else encounter[key]
    result["mastery"] = encounter.manuals[0].mastery
    var stat_total := 0
    for value in encounter.stats.values(): stat_total += int(value)
    result["final_stat_total_seed"] = stat_total
    result["epithet"] = result.presentation.epithet_bands[mini(int((int(encounter.stage) - 1) / 3), 3)]
    return result

static func _integer(value: Variant) -> bool:
    return typeof(value) == TYPE_INT or (typeof(value) == TYPE_FLOAT and is_finite(value) and value == floor(value))

static func _same(expected: Variant, actual: Variant) -> bool:
    if expected is Dictionary:
        if not actual is Dictionary or expected.size() != actual.size(): return false
        for key in expected:
            if not actual.has(key) or not _same(expected[key], actual[key]): return false
        return true
    if expected is Array:
        if not actual is Array or expected.size() != actual.size(): return false
        for index in range(expected.size()):
            if not _same(expected[index], actual[index]): return false
        return true
    if _integer(expected): return _integer(actual) and expected == actual
    return typeof(expected) == typeof(actual) and expected == actual

static func _normalize_numbers(value: Variant) -> Variant:
    if value is Dictionary:
        var result := {}
        for key in value: result[key] = _normalize_numbers(value[key])
        return result
    if value is Array:
        var result: Array = []
        for item in value: result.append(_normalize_numbers(item))
        return result
    return int(value) if typeof(value) == TYPE_FLOAT and _integer(value) else value
