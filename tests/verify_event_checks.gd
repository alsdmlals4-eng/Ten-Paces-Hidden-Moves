extends SceneTree

var failures: Array[String] = []
func check(value: bool, message: String) -> void:
    if not value: failures.append(message); push_error(message)
func _initialize() -> void: call_deferred("run_tests")
func run_tests() -> void:
    var rules = load("res://src/run/giyun_rules.gd").new()
    check(rules.has_method("success_chance"), "Event outcomes need stat-based success odds")
    if not rules.has_method("success_chance"): quit(1); return
    var choice := {"check":{"stat":"agility","difficulty":4}}
    check(rules.success_chance(choice,{"agility":4}) == 50, "Equal stat/difficulty is 50 percent")
    check(rules.success_chance(choice,{"agility":5}) == 60, "One stat point adds ten percentage points")
    check(rules.success_chance(choice,{"agility":0}) == 10, "Success lower cap")
    check(rules.success_chance(choice,{"agility":20}) == 90, "Success upper cap")
    check(rules.success_chance({}, {}) == 100, "Safe exit needs no roll")
    var stats := {"external":4,"constitution":4,"agility":4,"internal_power":4,"insight":4}
    var ordinary := 0
    var rare_events := 0
    for event in rules.catalog.events:
        check(event.choices.size() == 3, "Exactly three meaningful options")
        var bonuses := 0
        for option in event.choices:
            if option.has("rare_bonus"): bonuses += 1
        if bonuses == 0: ordinary += 1
        else: rare_events += 1
        var leave: Dictionary = rules.resolve_event(event,"leave",[],stats,71,1,0)
        check(leave.giyun_id.is_empty() and leave.training == 0 and leave.health_cost == 0 and leave.stamina == 0, "Safe exit has no cost, reward or giyun")
        check(rules.resolve_event(event,"invalid",[],stats,71,1,0).is_empty(), "Unknown option rejected")
        if bonuses == 0:
            for seed_value in range(150):
                check(rules.resolve_event(event,"accept",[],stats,seed_value,1,0).giyun_id.is_empty(), "Ordinary events never award giyun")
    check(ordinary >= 2 and rare_events == 6, "Ordinary events coexist with all six existing giyun sources")
    var event: Dictionary = rules.catalog.events.filter(func(e):return e.id == "cloud_hermit")[0]
    var limited: Array = rules.event_options(event, [], 2, stats)
    check(limited[0].disabled and not limited[2].disabled, "Risky health loss is blocked before a roll; safe exit remains")
    var richer: Dictionary = stats.duplicate(true)
    richer.agility = 5
    var won := 0
    var rare := 0
    var failed := 0
    for seed_value in range(4000):
        var outcome: Dictionary = rules.resolve_event(event,"accept",[],stats,seed_value,1,0)
        var higher: Dictionary = rules.resolve_event(event,"accept",[],richer,seed_value,1,0)
        check(not outcome.success or higher.success, "Higher relevant stat never turns the same roll into failure")
        check(higher.roll == outcome.roll, "Stat change affects threshold, not random sample")
        check(outcome == rules.resolve_event(event,"accept",[],stats,seed_value,1,0), "Outcome stays fixed for same run/step/choice")
        if outcome.success:
            won += 1
            if not outcome.giyun_id.is_empty():
                rare += 1
                var duplicate: Dictionary = rules.resolve_event(event,"accept",[outcome.giyun_id],stats,seed_value,1,0)
                check(duplicate.giyun_id.is_empty() and duplicate.training == outcome.training + 3, "Only an awarded rare duplicate converts to training")
        else:
            failed += 1
            check(outcome.giyun_id.is_empty() and outcome.rare_roll == -1, "Failed action cannot roll a rare reward")
    check(won > 1750 and won < 2250 and failed > 0, "Deterministic seed sample matches roughly 50 percent success")
    check(rare > 130 and rare < 270, "Independent ten percent bonus after success yields roughly five percent overall")
    var legacy = load("res://src/run/run_checkpoint_codec.gd").new()
    check(legacy.content_identity_for_schema(5) == "5363363676e6c1e66ac36bb4725dea1b2918c6f35744c50e453999d61e442884", "Schema5 content identity remains byte-compatible")
    for boundary in ["pending","applied"]:
        var decoded: Dictionary = legacy.decode(FileAccess.get_file_as_string("res://tests/fixtures/giyun_v1/"+boundary+".json"))
        check(decoded.ok, "Pre-change schema5 "+boundary+" checkpoint still decodes: "+str(decoded.get("error","")))
    print("EVENT_CHECKS: ", "PASS" if failures.is_empty() else "FAIL")
    quit(0 if failures.is_empty() else 1)
