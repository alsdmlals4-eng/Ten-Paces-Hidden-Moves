extends SceneTree

const DATA_PATH := "res://data/run/vertical_slice_opponents.json"

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    if file == null:
        failures.append("Opponent data must be readable.")
        _finish()
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        failures.append("Opponent data must parse as a Dictionary.")
        _finish()
        return

    var seen := {}
    for value in (parsed as Dictionary).get("candidates", []):
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var candidate := value as Dictionary
        var candidate_id := str(candidate.get("candidate_id", ""))
        var duel_slot := int(candidate.get("duel_slot", 0))
        _expect_true(not candidate_id.contains(" "), "Candidate IDs may not contain whitespace: %s" % candidate_id)
        _expect_true(candidate_id.begins_with("slot%d_" % duel_slot), "Candidate ID must be namespaced by its duel slot: %s" % candidate_id)
        _expect_true(not seen.has(candidate_id), "Candidate IDs must remain unique: %s" % candidate_id)
        seen[candidate_id] = true

    _expect_eq(seen.size(), 15, "Candidate ID validation must cover all 15 opponents.")
    _finish()


func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)


func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])


func _finish() -> void:
    if failures.is_empty():
        print("VERTICAL_SLICE_CANDIDATE_IDS_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_CANDIDATE_IDS_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
