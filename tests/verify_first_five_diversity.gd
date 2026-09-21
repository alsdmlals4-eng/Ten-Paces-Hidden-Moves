extends SceneTree

func _initialize() -> void:
    var provider = load("res://src/run/variable_opponent_roster.gd").new()
    var failures: Array[String] = []
    var coverage := {}
    for seed_value in range(256):
        var rows: Array = provider.generate(seed_value, "five")
        var people := {}
        var manuals := {}
        for row in rows.slice(0, 5):
            var id: String = row.candidate_id
            var manual: String = row.manuals[0].id
            if people.has(id) or manuals.has(manual):
                failures.append("seed %d repeats person/signature at stage %d" % [seed_value, row.stage])
                break
            people[id] = true
            manuals[manual] = true
            coverage[id] = true
        if rows != provider.generate(seed_value, "five"):
            failures.append("non-deterministic seed")
    # Previously frozen repeats remain valid; new-generation constraints are not migration.
    var legacy: Array = []
    for stage in range(1, 11):
        var row: Dictionary = provider.get_stage("slot1_dogyeom", stage)
        row.encounter_id = "legacy:%02d" % stage
        legacy.append(row)
    if not provider.validate(legacy, 42, "legacy"):
        failures.append("legacy repeated roster rejected")
    if coverage.size() != 16:
        failures.append("not all approved people reachable")
    for failure in failures.slice(0, 8): printerr(failure)
    print("FIRST_FIVE_DIVERSITY seeds=256 failures=%d candidates=%d" % [failures.size(), coverage.size()])
    quit(0 if failures.is_empty() else 1)
