extends "res://tests/probe_sequential_ten_duel_campaign.gd"
var active_engine
func run_probe() -> void:
    var observed: Array = []
    for seed_value in [42,145571664,20260921,34,0,1,2,3,4,5]:
        failures.clear()
        publicly_used_player_cards.clear()
        var run = VerticalSliceRunState.new()
        _require(run.start_new_stats_run(seed_value,"probe"),"new v4")
        var masteries := {}
        for id in STARTERS: masteries[id]=3
        _require(run.confirm_setup_loadout(STARTERS,masteries,load("res://src/run/player_growth_state.gd").new().recommended_allocation(STARTERS)),"setup")
        for i in range(3): _require(run.advance(),"setup advance")
        var duels: Array = []
        for duel in range(1,6):
            var outcome := _resolve_actual_duel(run,0)
            duels.append(outcome)
            _require(run.mark_combat_finished(outcome) and run.advance(),"real terminal")
            if outcome.get("outcome")=="loss":
                _require(run.retry_failed_duel(),"legal retry")
                outcome=_resolve_actual_duel(run,1)
                duels.append(outcome)
                _require(run.mark_combat_finished(outcome) and run.advance(),"retry terminal")
            if outcome.get("outcome") not in ["win","draw"] or not failures.is_empty(): break
            var reward := VerticalSliceResultModel.new().build_reward_receipt("focused_training",_reward_target_for_duel(duel),run.get_owned_player_manuals(),run.get_current_opponent())
            _require(run.set_pending_result_reward(reward) and run.advance(),"reward")
            if duel==5: break
            for step in range(4):
                _require(run.select_jianghu_node(_choose_public_route(run.get_jianghu_options()),step) and run.advance(),"route")
            _require(run.advance(),"next combat")
        var report := {"seed":seed_value,"completed":run.completed_duels,"routes":run.get_route_history().size(),"attempts":duels,"errors":failures.duplicate()}
        observed.append(report)
        print("FIRST_FIVE_EXPLORATION ",JSON.stringify(report))
    var output := OS.get_environment("TEN_FIVE_CAPTURE_DIR")
    if not output.is_empty():
        var file = FileAccess.open(output.path_join("campaign-exploration.json"),FileAccess.WRITE)
        file.store_string(JSON.stringify(observed,"  "))
    quit()
func _public_action_is_legal(definition: Dictionary,state: Dictionary,remaining: int,stamina: int,internal: int,distance: int) -> bool:
    if active_engine!=null and active_engine.get_actor_card_definition(str(definition.get("id","")),"player").is_empty(): return false
    return super._public_action_is_legal(definition,state,remaining,stamina,internal,distance)

func _resolve_actual_duel(run: VerticalSliceRunState, policy_mode: int) -> Dictionary:
    var candidate := run.get_current_opponent()
    var binding := VerticalSliceOpponentRuntimeBinding.new().build(candidate)
    binding.stats = candidate.stats.duplicate(true)
    var engine := VerticalSliceMetricsCombatResolutionEngine.new()
    engine.variable_opponent_rules = true
    engine.ai_planner.set_signature_manual(candidate.signature_manual_id)
    engine.configure_player_growth_stats(run.get_player_growth_stats())
    active_engine = engine
    if not engine.configure_enemy_runtime_binding(binding):
        return {"outcome": "invalid_binding", "duel_index": run.duel_index}
    var enemy_ids: Array = []
    var enemy_mastery := {}
    for owned in candidate.manuals:
        enemy_ids.append(owned.id)
        enemy_mastery[owned.id] = owned.mastery
    engine.configure_martial_loadouts(
        run.get_owned_player_manuals(), run.get_player_mastery_by_manual(),
        enemy_ids, enemy_mastery)
    var available_player_card_ids := Array(engine.get_player_martial_card_ids())
    var hud: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))
    var player_hud: Dictionary = (hud.get("player", {}) as Dictionary).duplicate(true)
    for key in ["health", "stamina", "internal"]:
        player_hud[key] = (run.get_player_run_resources().get(key, [0, 0]) as Array).duplicate()
    hud["player"] = player_hud
    var state := engine.make_initial_state(hud, 4, 6)
    var expected_resources := run.get_player_run_resources()
    _require(
        _apply_validated_run_resources(state, expected_resources),
        "duel %d policy %d RunState resources must be valid before combat" % [run.duel_index, policy_mode]
    )
    _require(
        _resource_snapshot(state.get("player", {})) == expected_resources,
        "duel %d policy %d initial engine resources must exactly match RunState before the first resolver" % [run.duel_index, policy_mode]
    )
    state["ai_enabled"] = true
    var duel_public_player_cards := {}
    var enemy_cards := {}
    for turn in range(MAX_BUNDLES):
        var bundle := turn % 3 + 1
        state["bundle_index"] = bundle
        state["round_number"] = turn / 3 + 1
        engine.lock_enemy_bundle(state, bundle)
        var placements := _public_policy(engine, state.duplicate(true), bundle, policy_mode)
        var result := engine.resolve_bundle(placements, {
            "bundle_index": bundle,
            "round_number": state["round_number"],
            "timing_sequence": [3, 3, 4]
        }, state)
        state = result.get("state", {})
        for action in result.get("resolved_actions",[]):
            if action.get("actor")=="enemy" and str(action.get("card_id","")).contains("_star") and action.get("outcome") not in ["preparation","interrupted","martial_failed"]:
                enemy_cards[action.card_id] = action.outcome
        _remember_public_player_cards(state)
        for card_id in _player_card_counts(state):
            duel_public_player_cards[str(card_id)] = true
        var player_hp := int((state["player"]["health"] as Array)[0])
        var enemy_hp := int((state["enemy"]["health"] as Array)[0])
        if player_hp <= 0 or enemy_hp <= 0:
            var outcome := "draw" if player_hp <= 0 and enemy_hp <= 0 else ("win" if enemy_hp <= 0 else "loss")
            var duel_public_player_card_ids: Array = duel_public_player_cards.keys()
            duel_public_player_card_ids.sort()
            return {
                "terminal": true,
                "outcome": outcome,
                "duel_index": run.duel_index,
                "candidate_id": str(candidate.get("candidate_id", "")),
                "policy_mode": policy_mode,
                "policy": _policy_label(policy_mode),
                "bundles": turn + 1,
                "player_health": player_hp,
                "enemy_health": enemy_hp,
                "player_resources": _resource_snapshot(state["player"]),
                "available_player_card_ids": available_player_card_ids.duplicate(),
                "enemy_executed":enemy_cards.duplicate(true),
                "grade_summary":load("res://src/run/battle_grade_aggregator.gd").summarize(state.battle_metrics,state.get("grade_ledger",{})),
                "duel_public_player_card_ids": duel_public_player_card_ids,
                "player_card_counts": _player_card_counts(state),
                "battle_metrics": (state.get("battle_metrics", {}) as Dictionary).duplicate(true)
            }
    return {"outcome": "stalled", "duel_index": run.duel_index, "candidate_id": str(candidate.get("candidate_id", "")), "policy_mode": policy_mode}
