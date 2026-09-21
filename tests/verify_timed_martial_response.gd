extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
    for manual in ["wudang_taiji_sword","xiaoyao_lingbo_footwork"]:
        for attack in ["basic_quick_attack","sichuan_tang_hidden_weapons_star3","basic_meditate"]:
            var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
            engine.configure_player_growth_stats({"external":4,"constitution":4,"agility":4,"internal_power":4,"insight":4})
            engine.configure_martial_loadouts([],{},[manual,"sichuan_tang_hidden_weapons"],{manual:3,"sichuan_tang_hidden_weapons":3})
            # Player attacks are genuine actor-owned definitions; enemy response uses its own program.
            engine.configure_martial_loadouts(["sichuan_tang_hidden_weapons"],{"sichuan_tang_hidden_weapons":3},[manual],{manual:3})
            engine.rules.enemy_bundles={"1":[{"card_id":manual+"_star3","timing":1}]}
            var hud: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))
            var state: Dictionary = engine.make_initial_state(hud,4,5)
            state.enemy.internal=[5,10]
            var result: Dictionary = engine.resolve_bundle([{"card_id":attack,"anchor_index":1,"target_ready":true,"target_tile":5,"targeting_mode":"enemy","direction":1}],{},state)
            if attack == "sichuan_tang_hidden_weapons_star3":
                var cues: Array = load("res://src/ui/combat_motion_sequence.gd").compile(result.presentation_events)
                var dodges: Array = cues.filter(func(e): return e.get("actor") == "player" and e.get("defense_outcome") == "evade")
                if dodges.size()!=1 or dodges[0].get("damage",-1)!=0: failures.append("real martial evade lost between engine and choreography: "+manual)
            var records: Array = result.resolved_actions.filter(func(a): return a.actor=="enemy" and a.get("action_stage")=="execution")
            if records.is_empty() or records[0].get("martial_events",[]).is_empty(): failures.append(manual+" lacks authored response events")
            if int(result.defenses.enemy.guard_block)!=0: failures.append("martial response becomes generic guard")
            if result.state.enemy.get("status_counts",{}).get("evade",0)!=0: failures.append("response leaks evasion into later timings")
            if manual=="wudang_taiji_sword":
                var attacked: bool = attack!="basic_meditate"
                if int(result.state.enemy.tile)!=(6 if attacked else 5): failures.append("taiji success-only movement "+attack)
                if int(result.state.enemy.internal[0])!=(5 if attacked else 4): failures.append("cost once and conditional recovery "+attack)
            elif int(result.state.enemy.tile)<6: failures.append("xiaoyao always executes initial movement")
    for card in ["xiaoyao_lingbo_footwork_star7","xiaoyao_lingbo_footwork_star10","wudang_taiji_sword_star10"]:
        _advanced_response(card)
    _legacy_unchanged()
    for failure in failures: printerr(failure)
    print("TIMED_MARTIAL_RESPONSE failures=",failures.size())
    quit(0 if failures.is_empty() else 1)

func _advanced_response(card: String) -> void:
    var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
    engine.configure_player_growth_stats({"external":12,"constitution":12,"agility":12,"internal_power":12,"insight":12})
    var manual := card.get_slice("_star",0)
    engine.configure_martial_loadouts([manual],{manual:10},[],{})
    var definition: Dictionary = engine.get_actor_card_definition(card,"player")
    var timing := int(definition.action_slots)
    engine.rules.enemy_bundles={"1":[{"card_id":"basic_quick_attack","timing":timing,"direction":-1,"targeting_mode":"enemy"}]}
    var state: Dictionary = engine.make_initial_state(JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json")),4,5)
    state.player.stamina=[10,10];state.player.internal=[10,10];state.player.momentum=[0,5]
    var result: Dictionary = engine.resolve_bundle([{"card_id":card,"anchor_index":1}],{},state)
    var records: Array = result.resolved_actions.filter(func(a): return a.actor=="player" and a.get("action_stage")=="execution")
    if records.is_empty(): failures.append("advanced response missing "+card);return
    var record: Dictionary = records[0]
    if int(record.get("damage",0))<=0: failures.append("counter damage not reported "+card)
    if int(result.state.player.stamina[0])!=10-int(definition.stamina_cost): failures.append("counter cost paid twice "+card)
    if record.timing!=timing: failures.append("counter starts before execution timing "+card)
    if card.ends_with("_star10"):
        var summary: Dictionary = load("res://src/run/battle_grade_aggregator.gd").summarize(result.battle_metrics,result.state.grade_ledger)
        if summary.effective.ultimate!=1: failures.append("effective response ultimate lost "+card)
    if card=="xiaoyao_lingbo_footwork_star10":
        engine.clear_locked_enemy_bundle()
        engine.rules.enemy_bundles={"1":[{"card_id":"basic_meditate","timing":timing}]}
        var idle: Dictionary = engine.resolve_bundle([{"card_id":card,"anchor_index":1}],{},state)
        var summary: Dictionary = load("res://src/run/battle_grade_aggregator.gd").summarize(idle.battle_metrics,idle.state.grade_ledger)
        if summary.effective.ultimate!=0: failures.append("unused transient evade falsely scores ultimate")
    # JSON roundtrip in this engine verifies no timing-bound evade leaks into the next bundle.
    engine.clear_locked_enemy_bundle()
    engine.rules.enemy_bundles={"2":[{"card_id":"basic_quick_attack","timing":4,"direction":-1}]}
    var decoded: Dictionary = JSON.parse_string(JSON.stringify(load("res://src/run/combat_checkpoint_codec.gd").portable(result.state)))
    var next: Dictionary = engine.resolve_bundle([],{"bundle_index":2},decoded)
    if next.state.player.get("status_counts",{}).get("evade",0)!=0: failures.append("unused response persists after save boundary")

func _legacy_unchanged() -> void:
    var base = load("res://src/combat/combat_resolution_engine_ten_manuals.gd").new()
    var modern = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
    var manual := "wudang_taiji_sword"
    for engine in [base,modern]:
        engine.configure_martial_loadouts([],{ },[manual],{manual:3})
        engine.rules.enemy_bundles={"1":[{"card_id":manual+"_star3","timing":2}]}
    var hud: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))
    var a: Dictionary = base.resolve_bundle([],{},base.make_initial_state(hud,4,5))
    var b: Dictionary = modern.resolve_bundle([],{},modern.make_initial_state(hud,4,5))
    if a.state.player!=b.state.player or a.state.enemy!=b.state.enemy or a.resolved_actions!=b.resolved_actions: failures.append("legacy response behavior changed")
