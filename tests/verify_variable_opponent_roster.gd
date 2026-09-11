extends SceneTree

var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _init() -> void:
    if not ResourceLoader.exists("res://src/run/variable_opponent_roster.gd"):
        printerr("FAIL: approved variable roster runtime provider is missing")
        quit(1)
        return
    var catalog = load("res://src/run/variable_opponent_roster.gd").new()
    check(catalog.is_valid(), str(catalog.get_load_errors()))
    check(catalog.get_all_candidates().size() == 16, "16 candidates")
    var counts := {}
    var repeated := 0
    var type_repeated := 0
    var widths := {}
    for seed_value in range(10000):
        var roster: Array = catalog.generate(seed_value, "fixture")
        check(roster.size() == 10, "10 encounters")
        if seed_value < 20:
            check(roster == catalog.generate(seed_value, "fixture"), "same seed reproducible")
            check(catalog.validate(roster, seed_value, "fixture"), "valid roster")
            check(catalog.validate(JSON.parse_string(JSON.stringify(roster)), seed_value, "fixture"), "JSON numeric roundtrip")
        var previous := {}
        for row in roster:
            var id: String = row.candidate_id
            counts[id] = counts.get(id, 0) + 1
            widths[row.manuals.size()] = true
            var candidate: Dictionary = catalog.get_encounter_candidate(row)
            check(candidate.get("candidate_id") == id, "encounter identity")
            if not previous.is_empty():
                if previous.candidate_id == id: repeated += 1
                if previous.runtime_archetype_id == candidate.runtime_archetype_id: type_repeated += 1
            previous = candidate
    check(counts.size() == 16, "all candidates reachable")
    check(repeated > 0, "same person allowed")
    check(widths.size() == 4, "2/3/4/5 manual coverage")
    seed(123456)
    var global_expected := randi()
    seed(123456)
    catalog.generate(987, "isolated")
    check(randi() == global_expected, "roster RNG leaves global RNG untouched")
    var original: Array = catalog.generate(42, "fixture")
    var candidate_copy: Dictionary = catalog.get_candidate(original[0].candidate_id)
    candidate_copy.working_name = "tampered"
    check(catalog.get_candidate(original[0].candidate_id).working_name != "tampered", "candidate copy isolation")
    var bad: Array = original.duplicate(true)
    bad[0].manuals[0].mastery = true
    check(not catalog.validate(bad, 42, "fixture"), "reject bool mastery")
    bad = original.duplicate(true)
    bad[0].manuals[0].mastery += 1
    check(not catalog.validate(bad, 42, "fixture"), "reject changed mastery")
    bad = original.duplicate(true)
    bad[0].stats.external += 1
    check(not catalog.validate(bad, 42, "fixture"), "reject changed stat")
    bad = original.duplicate(true)
    bad[0].manuals.append(bad[0].manuals[0].duplicate())
    check(not catalog.validate(bad, 42, "fixture"), "reject duplicate manual")
    bad = original.duplicate(true)
    bad[0].future_plan = "private"
    check(not catalog.validate(bad, 42, "fixture"), "reject extra private field")
    check(not catalog.validate(original, 42, "other"), "reject foreign save identity")
    bad = original.duplicate(true)
    bad[0].stage = true
    check(not catalog.validate(bad, 42, "fixture"), "reject bool stage")
    bad = original.duplicate(true)
    bad[0].source_revision = "unknown"
    check(not catalog.validate(bad, 42, "fixture"), "reject unknown content revision")
    bad = original.duplicate(true)
    bad[0].epithet_key = "wrong"
    check(not catalog.validate(bad, 42, "fixture"), "reject epithet drift")
    bad = original.duplicate(true)
    bad.remove_at(0)
    check(not catalog.validate(bad, 42, "fixture"), "reject missing encounter")
    check(catalog.get_encounter_candidate({}).is_empty(), "malformed encounter safe")
    check(catalog.generate(42, "").is_empty(), "empty save rejected")
    var runtime_adapter = load("res://src/run/vertical_slice_opponent_runtime_binding.gd").new()
    for candidate in catalog.get_all_candidates():
        var last := {}
        for stage in range(1,11):
            var row: Dictionary = catalog.get_stage(candidate.candidate_id, stage)
            row["encounter_id"] = "binding:%02d" % stage
            var encounter_candidate: Dictionary = catalog.get_encounter_candidate(row)
            var bound: Dictionary = runtime_adapter.build(encounter_candidate)
            check(bound.get("valid", false), "every approved encounter resolves existing adapter: %s:%d" % [candidate.candidate_id,stage])
            var total := 0
            for stat in row.stats.values(): total += int(stat)
            check(encounter_candidate.get("final_stat_total_seed") == total, "adapter seed equals approved stat total")
            check(row.manuals[0].id == candidate.signature_manual_id, "signature preserved")
            check(row.resource_caps == {"health":30,"stamina":5,"internal":4}, "resource caps")
            if not last.is_empty():
                for key in row.stats: check(row.stats[key] >= last.stats[key], "stats monotonic")
                for i in range(row.manuals.size()): check(row.manuals[i].mastery >= last.manuals[i].mastery, "mastery monotonic")
            last = row
    print("ROSTER_DISTRIBUTION ", JSON.stringify({"seeds":10000,"counts":counts,"same_person":repeated,"same_type":type_repeated}))
    for failure in failures: printerr("FAIL: ", failure)
    if failures.is_empty(): print("VARIABLE_OPPONENT_ROSTER_PASS")
    quit(0 if failures.is_empty() else 1)
