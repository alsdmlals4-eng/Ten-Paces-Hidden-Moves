extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("run_tests")

func check(value: bool, message: String) -> void:
    if not value: failures.append(message)

func run_tests() -> void:
    var path := "res://src/run/giyun_rules.gd"
    check(ResourceLoader.exists(path), "Giyun rules owner must exist")
    if ResourceLoader.exists(path):
        var rules = load(path).new()
        check(rules.catalog.giyun.size() >= 6, "Several build directions are required")
        for seed_value in range(60):
            for step in range(4):
                var offers: Array = rules.options(seed_value, 1, step)
                check(offers.size() == 3, "Three unique activities")
                var ids: Array = []
                for offer in offers: ids.append(offer.id)
                check(ids.has("event") and not ids.has("investigate"), "New four-category route and event access")
                check(offers == rules.options(seed_value, 1, step), "Stable route generation")
        var event: Dictionary = rules.event_for(99, 1, 0, 1)
        check(event == rules.event_for(99, 1, 0, 1), "Stable event after continue")
        var outcome: Dictionary = rules.resolve_event(event, "accept", [])
        check(outcome.has("giyun_id"), "Accept grants the shown giyun")
        var duplicate: Dictionary = rules.resolve_event(event, "accept", [outcome.giyun_id])
        check(duplicate.get("giyun_id", "").is_empty() and duplicate.training == 3, "Duplicate converts to disclosed training")
        check(rules.resolve_event(event, "invalid", []).is_empty(), "Invalid option rejected")
        var before := {"player": {"health": [20,30], "stamina": [1,5], "internal": [1,4], "next_attack_bonus": 0}}
        var result := {"state": before.duplicate(true), "resolved_actions": [{"actor":"enemy","defense_outcome":"evade","outcome":"attack"}], "logs":[]}
        rules.apply_bundle(["cloud_step"], before, result)
        check(result.state.player.internal[0] == 2, "Dodge rewards internal resource")
        check(result.logs.size() == 1, "Proc cause is visible")
        var unrelated := {"state": before.duplicate(true), "resolved_actions": [], "logs":[]}
        rules.apply_bundle(["cloud_step"], before, unrelated)
        check(unrelated.state == before, "No proc without qualifying action")
        var healed := {"state": before.duplicate(true), "resolved_actions": [{"actor":"player","damage":4},{"actor":"enemy","damage":2}], "logs":[]}
        rules.apply_bundle(["clear_spring"], before, healed)
        check(healed.state.player.health[0] == 20, "Healing during a damaged bundle must not count as no damage")
        var dead := {"state": before.duplicate(true), "resolved_actions": result.resolved_actions, "logs":[]}
        dead.state.player.health[0] = 0
        rules.apply_bundle(["cloud_step"], before, dead)
        check(dead.state.player.internal[0] == 1, "No posthumous proc")
    var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
    check(engine.has_method("configure_giyun"), "Combat must consume approved run giyun")
    if engine.has_method("configure_giyun"):
        check(engine.configure_giyun(["clear_spring"]), "Bind known giyun")
        check(not engine.configure_giyun(["invalid"]), "Reject unknown binding")
        var state: Dictionary = engine.make_initial_state(JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json")), 3, 4)
        state.player.health = [20,30]
        state.player.stamina = [5,5]
        state.ai_enabled = false
        engine.rules["enemy_bundles"] = {}
        var definition: Dictionary = engine.get_actor_card_definition("basic_quick_attack", "player")
        var placements := [{"anchor_index":1,"card_id":"basic_quick_attack","definition":definition,"duration":1}]
        var context := {"round_number":1,"bundle_index":1,"current_timing":1,"total_timings":10,"timing_sequence":[3,3,4]}
        var result: Dictionary = engine.resolve_bundle(placements, context, state)
        check(result.state.player.health[0] == 22, "Actual hit resolves clear spring benefit through engine")
    test_engine_boundaries()
    for failure in failures: push_error(failure)
    print("GIYUN_RULES: ", "PASS" if failures.is_empty() else "FAIL")
    quit(0 if failures.is_empty() else 1)

func test_engine_boundaries() -> void:
    var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
    engine.configure_giyun(["clear_spring", "last_ember", "jade_guard"])
    var hud: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))
    var context := {"round_number":1,"bundle_index":1,"timing_sequence":[3,3,4]}
    var quick: Dictionary = engine.cards_by_id.basic_quick_attack.duplicate(true)
    quick.damage_formula = {"base":8,"stat_key":"external","coefficient":0.0}
    var enemy: Dictionary = quick.duplicate(true)
    enemy.id = "giyun_test_enemy"
    enemy.damage_formula.base = 6
    engine.cards_by_id[enemy.id] = enemy
    engine.rules.enemy_bundles = {"1":[{"timing":1,"card_id":enemy.id,"direction":-1}]}
    var state: Dictionary = engine.make_initial_state(hud,4,5)
    state.ai_enabled = false
    state.player.health = [20,30]
    var plan := [{"card_id":quick.id,"definition":quick,"anchor_index":1,"direction":1,"target_ready":true}]
    var won: Dictionary = engine.resolve_bundle(plan,context,state)
    check(won.state.player.health[0] == 22, "Actual clash winner receives clean-hit heal")
    quick.damage_formula.base = 4
    state.player.health = [10,30]
    state.player.stamina = [4,5]
    var lost: Dictionary = engine.resolve_bundle(plan,context,state)
    check(lost.state.player.stamina[0] == 3, "Clash loser never receives low-health hit benefit")
    engine.rules.enemy_bundles = {}
    state.player["giyun_attack_bonus"] = 4
    var waiting: Dictionary = engine.resolve_bundle([],context,state)
    check(waiting.state.player.get("giyun_attack_bonus") == 4, "Independent giyun bonus survives an empty bundle")
    var next: Dictionary = engine.resolve_bundle(plan,context,waiting.state)
    check(next.state.player.get("giyun_attack_bonus") == 0, "Basic attack consumes giyun bonus")
    var damage := 0
    for row in next.resolved_actions:
        if row.actor == "player": damage = int(row.get("raw_damage",0))
    check(damage == 8, "Basic damage includes stored giyun bonus exactly once")
    var martial = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
    var manual := "mount_hua_plum_blossom_sword"
    martial.configure_martial_loadouts([],{},[manual],{manual:3})
    martial.configure_giyun(["jade_guard"])
    martial.rules.enemy_bundles = {"1":[{"timing":1,"card_id":manual+"_star3"}]}
    var defended: Dictionary = martial.make_initial_state(hud,4,5)
    defended.ai_enabled = false
    defended.player["defense"] = 20
    var blocked: Dictionary = martial.resolve_bundle([],context,defended)
    check(blocked.state.player.get("giyun_attack_bonus",0) == 2, "Real martial damage reduction triggers jade guard")
    var continued: Dictionary = martial.resolve_bundle([],context,blocked.state)
    check(continued.state.player.get("giyun_attack_bonus",0) == 4, "Repeated defense accumulates independent bonus to cap")
    check(load("res://src/run/combat_checkpoint_codec.gd").new()._actor(continued.state.player), "Stored bonus is a valid combat DTO field")
