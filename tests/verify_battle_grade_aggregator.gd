extends SceneTree
var failures: Array[String] = []
var checks := 0
func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok: failures.append(label)
func _initialize() -> void:
    var path := "res://src/run/battle_grade_aggregator.gd"
    if not FileAccess.file_exists(path):
        printerr("Missing executable grade aggregation consumer")
        quit(1)
        return
    var a = load(path)
    var events: Array = []
    for i in range(3):
        events.append({"source":"basic:quick","instance":"1:%d" % i,"round":1,"kind":"clash","applied":true})
    var raw := {"clash_wins":3,"successful_dodges":0,"player_health_lost":4,"rounds_elapsed":4,"ultimate_uses":2}
    var before := events.duplicate(true)
    var result: Dictionary = a.summarize(raw, {"version":1,"complete":true,"events":events})
    check(result.effective.clash == 1.5, "same source gives 1, .5, 0")
    check(result.raw == raw and events == before, "raw and source events unchanged")
    check(result.grade == "" and result.grade_status == "FORMULA_PENDING", "no invented final grade")
    events = [
        {"source":"martial:a","instance":"1:1","round":1,"kind":"clash","applied":true},
        {"source":"martial:a","instance":"1:1","round":1,"kind":"dodge","applied":true},
        {"source":"martial:a","instance":"1:1","round":1,"kind":"dodge","applied":true}]
    result = a.summarize(raw,{"version":1,"complete":true,"events":events})
    check(is_equal_approx(result.effective.clash,1.0/3.0) and is_equal_approx(result.effective.dodge,2.0/3.0),"multihit shares one instance pool")
    events.append({"source":"martial:b","instance":"4:1","round":4,"kind":"clash","applied":true})
    events.append({"source":"ultimate:a","instance":"1:2","round":1,"kind":"ultimate","applied":false})
    events.append({"source":"ultimate:b","instance":"2:1","round":2,"kind":"ultimate","applied":true})
    events.append({"source":"ultimate:c","instance":"3:1","round":3,"kind":"ultimate","applied":true})
    result = a.summarize(raw,{"version":1,"complete":true,"events":events})
    check(result.effective.ultimate == 1,"only first non-cost ultimate")
    check(is_equal_approx(result.effective.clash,1.0/3.0),"outside window no extra credit")
    check(result.reasons.has("SCORING_WINDOW") and result.reasons.has("NO_APPLIED_EFFECT") and result.reasons.has("ULTIMATE_CAP"),"explain rejected credit")
    events = []
    for i in range(8): events.append({"source":"basic:%d" % i,"instance":"1:%d" % i,"round":1,"kind":"clash","applied":true})
    result = a.summarize(raw,{"version":1,"complete":true,"events":events})
    check(result.effective.clash == 3,"clash cap")
    result = a.summarize(raw,{})
    check(result.effective.is_empty() and result.evidence_status == "LEGACY_UNAVAILABLE", "old records not fabricated")
    check(not a.valid_ledger({"version":true,"complete":true,"events":[]}),"bool version rejected")
    check(not a.valid_ledger({"version":1,"complete":true,"events":[{"kind":"clash"}]}),"malformed telemetry rejected")
    for category in ["utility","response","move","attack"]:
        var evidence := {"round_number":1,"bundle_index":1,"resolved_actions":[{"actor":"player","card_id":"wudang_taiji_sword_star7","timing":2,"clash_won":true},{"actor":"enemy","card_id":"basic_fixture","timing":2,"category":category}]}
        var summary: Dictionary = a.summarize(raw,a.record({"grade_ledger":a.initial()},evidence))
        check(summary.effective.clash==(1.0 if category=="attack" else 0.0),"only an opposing attack receives clash credit: "+category)
    var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
    var hud: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))
    var state: Dictionary = engine.make_initial_state(hud,4,6)
    state["ai_enabled"] = true
    state["ai_decision_seed"] = 42
    check(state.has("grade_ledger"),"real combat starts ledger")
    var codec = load("res://src/run/combat_checkpoint_codec.gd").new()
    check(codec._state(codec.portable(state)),"new state accepted by strict save validator")
    var legacy := state.duplicate(true)
    legacy.erase("grade_ledger")
    check(codec._state(codec.portable(legacy)),"legacy state remains accepted")
    var bad := state.duplicate(true)
    bad.grade_ledger = {"version":9,"complete":true,"events":[]}
    check(not codec._state(bad),"unknown tracking rejected")
    for failure in failures: printerr(failure)
    print("BATTLE_GRADE_AGGREGATOR checks=%d failures=%d" % [checks,failures.size()])
    quit(0 if failures.is_empty() else 1)
