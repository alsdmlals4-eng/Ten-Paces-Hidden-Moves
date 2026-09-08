extends SceneTree

# Bounded campaign probe: actual resolver + bound public-state AI through the
# real VerticalSliceRunState. No health/outcome injection is used.
const MAX_BUNDLES := 270
const STARTERS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear"
]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("run_probe")


func run_probe() -> void:
    var catalog := VerticalSliceOpponentCatalog.new()
    var run := VerticalSliceRunState.new()
    var mastery := {}
    for manual_id in STARTERS:
        mastery[manual_id] = 3
    _require(run.configure_opponents(catalog, 20260908), "catalog must configure")
    _require(run.start_new_run(), "run must enter setup")
    _require(run.confirm_setup_loadout(STARTERS, mastery), "four legal starters must configure")
    _require(run.advance() and run.advance() and run.advance(), "setup must reach combat")

    var attempts: Array[Dictionary] = []
    while failures.is_empty() and not run.is_complete():
        var duel := run.duel_index
        var first := _resolve_actual_duel(run, catalog, 0)
        attempts.append(first.duplicate(true))
        print(_attempt_line(first))
        _require(str(first.get("outcome", "")) in ["win", "loss", "draw"], "duel %d must reach terminal HP" % duel)
        if not failures.is_empty():
            break
        _require(run.mark_combat_finished(first), "duel %d terminal result must enter review" % duel)
        _require(run.advance(), "duel %d review must advance" % duel)
        if str(first.get("outcome", "")) == "loss":
            _require(run.retry_failed_duel(), "duel %d must permit its one legal retry" % duel)
            var retry := _resolve_actual_duel(run, catalog, 1)
            attempts.append(retry.duplicate(true))
            print(_attempt_line(retry))
            _require(str(retry.get("outcome", "")) in ["win", "loss", "draw"], "duel %d retry must reach terminal HP" % duel)
            if not failures.is_empty():
                break
            _require(run.mark_combat_finished(retry), "duel %d retry terminal result must enter review" % duel)
            _require(run.advance(), "duel %d retry review must advance" % duel)
            if str(retry.get("outcome", "")) == "loss":
                failures.append("duel %d lost its legal retry; campaign is not complete" % duel)
                break

        var reward := VerticalSliceResultModel.new().build_reward_receipt(
            "focused_training", STARTERS[(duel - 1) % STARTERS.size()],
            run.get_player_manual_loadout(), run.get_current_opponent())
        _require(run.set_pending_result_reward(reward), "duel %d reward must be accepted" % duel)
        _require(run.advance(), "duel %d reward must advance" % duel)
        if duel < VerticalSliceRunState.MAX_DUELS:
            for step in range(VerticalSliceRunState.JIANGHU_CHOICES):
                var options: Array = run.get_jianghu_options()
                var choice_id := _choose_public_route(options)
                _require(not choice_id.is_empty(), "duel %d route step %d must offer a public choice" % [duel, step])
                _require(run.select_jianghu_node(choice_id, step), "duel %d route step %d selection must apply" % [duel, step])
                _require(run.advance(), "duel %d route step %d must advance" % [duel, step])
        if duel < VerticalSliceRunState.MAX_DUELS:
            _require(run.get_current_screen() == VerticalSliceRunState.SCREEN_BRIEFING, "next duel must reach briefing")
            _require(run.advance(), "next duel briefing must reach combat")
        print("SEQUENTIAL_PROGRESS duel=%d resources=%s progression=%s reward_count=%d route_count=%d" % [
            duel, str(run.get_player_run_resources()), str(run.get_progression_snapshot()),
            run.get_reward_history().size(), run.get_route_history().size()
        ])

    var summary := {
        "complete": run.is_complete(),
        "completed_duels": run.completed_duels,
        "attempt_count": attempts.size(),
        "duel_history_count": run.get_duel_history().size(),
        "reward_history_count": run.get_reward_history().size(),
        "route_choice_count": run.get_route_history().size(),
        "route_choices": run.get_route_history(),
        "resources": run.get_player_run_resources(),
        "progression": run.get_progression_snapshot(),
        "attempts": attempts
    }
    print("SEQUENTIAL_CAMPAIGN_SUMMARY ", JSON.stringify(summary))
    _require(run.is_complete(), "campaign must complete after ten real engine wins/draws")
    _require(run.get_duel_history().size() == 10, "ten actual terminal successes must be retained")
    _require(run.get_reward_history().size() == 10, "ten earned rewards must be retained")
    _require(run.get_route_history().size() == 36, "nine intervals must retain 36 real choices")
    for failure in failures:
        printerr("SEQUENTIAL_CAMPAIGN_FAIL: ", failure)
    quit(1 if not failures.is_empty() else 0)


func _resolve_actual_duel(run: VerticalSliceRunState, catalog: VerticalSliceOpponentCatalog, policy_mode: int) -> Dictionary:
    var candidate := run.get_current_opponent()
    var binding := VerticalSliceOpponentRuntimeBinding.new().build(candidate)
    var engine := VerticalSliceMetricsCombatResolutionEngine.new()
    if not engine.configure_enemy_runtime_binding(binding):
        return {"outcome": "invalid_binding", "duel_index": run.duel_index}
    var enemy_manual := str(candidate.get("signature_manual_id", ""))
    engine.configure_martial_loadouts(
        run.get_player_manual_loadout(), run.get_player_mastery_by_manual(),
        [enemy_manual], {enemy_manual: int(candidate.get("signature_star_seed", 3))})
    var hud: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))
    var player_hud: Dictionary = (hud.get("player", {}) as Dictionary).duplicate(true)
    for key in ["health", "stamina", "internal"]:
        player_hud[key] = (run.get_player_run_resources().get(key, [0, 0]) as Array).duplicate()
    hud["player"] = player_hud
    var state := engine.make_initial_state(hud, 4, 6)
    state["ai_enabled"] = true
    for turn in range(MAX_BUNDLES):
        var bundle := turn % 3 + 1
        state["bundle_index"] = bundle
        state["round_number"] = turn / 3 + 1
        engine.lock_enemy_bundle(state, bundle)
        var placements := _public_policy(engine, state, bundle, policy_mode)
        var result := engine.resolve_bundle(placements, {
            "bundle_index": bundle,
            "round_number": state["round_number"],
            "timing_sequence": [3, 3, 4]
        }, state)
        state = result.get("state", {})
        var player_hp := int((state["player"]["health"] as Array)[0])
        var enemy_hp := int((state["enemy"]["health"] as Array)[0])
        if player_hp <= 0 or enemy_hp <= 0:
            return {
                "terminal": true,
                "outcome": "win" if enemy_hp <= 0 else "loss",
                "duel_index": run.duel_index,
                "candidate_id": str(candidate.get("candidate_id", "")),
                "policy_mode": policy_mode,
                "bundles": turn + 1,
                "player_health": player_hp,
                "enemy_health": enemy_hp,
                "player_resources": _resource_snapshot(state["player"]),
                "battle_metrics": (state.get("battle_metrics", {}) as Dictionary).duplicate(true)
            }
    return {"outcome": "stalled", "duel_index": run.duel_index, "candidate_id": str(candidate.get("candidate_id", "")), "policy_mode": policy_mode}


func _public_policy(engine, state: Dictionary, bundle: int, policy_mode: int) -> Array:
    var placements: Array = []
    var start: int = [1, 4, 7][bundle - 1]
    var remaining: int = [3, 3, 4][bundle - 1]
    var player: Dictionary = state["player"]
    var enemy: Dictionary = state["enemy"]
    var stamina := int((player["stamina"] as Array)[0])
    var internal := int((player["internal"] as Array)[0])
    var distance := absi(int(player["tile"]) - int(enemy["tile"]))
    while remaining > 0:
        var card_id := "basic_meditate"
        # These are real star-3 techniques from the selected starter manuals.
        # Selection depends only on own loadout/resources and public distance.
        if int(state.get("round_number", 1)) == 1 and bundle == 1 and start == 1 and distance == 2 and remaining >= 1 and stamina >= 1:
            card_id = "yang_family_spear_star3"
        elif int(state.get("round_number", 1)) == 1 and bundle == 2 and start == 4 and distance == 1 and remaining >= 2 and stamina >= 1 and internal >= 1:
            card_id = "mount_hua_plum_blossom_sword_star3"
        elif policy_mode == 1 and distance <= 2 and remaining >= 2 and stamina >= 1 and internal >= 2:
            card_id = "basic_heavy_attack"
        elif distance <= 1 and stamina >= 1:
            card_id = "basic_quick_attack"
        elif distance <= 3 and distance >= 1 and internal >= 1 and remaining >= 2:
            card_id = "basic_palm"
        elif distance > 3:
            card_id = "basic_move"
        var definition: Dictionary = engine.cards_by_id[card_id]
        var span := int(definition.get("action_slots", 1))
        stamina -= int(definition.get("stamina_cost", 0))
        internal -= int(definition.get("internal_cost", 0))
        if card_id == "basic_meditate":
            stamina += 1
            internal += 1
        var direction := 1 if int(enemy["tile"]) >= int(player["tile"]) else -1
        placements.append({
            "card_id": card_id, "anchor_index": start, "span": span,
            "target_ready": true,
            "target_tile": int(player["tile"]) + direction if card_id == "basic_move" else int(enemy["tile"]),
            "direction": direction, "origin_tile": int(player["tile"])
        })
        start += span
        remaining -= span
    return placements


func _choose_public_route(options: Array) -> String:
    for preferred in ["rest", "training", "event", "recon", "investigate"]:
        for option_value in options:
            if typeof(option_value) == TYPE_DICTIONARY and str((option_value as Dictionary).get("id", "")) == preferred:
                return preferred
    return ""


func _resource_snapshot(actor: Dictionary) -> Dictionary:
    var result := {}
    for key in ["health", "stamina", "internal"]:
        result[key] = (actor.get(key, [0, 0]) as Array).duplicate()
    return result


func _attempt_line(value: Dictionary) -> String:
    return "SEQUENTIAL_DUEL duel=%d candidate=%s attempt_policy=%d outcome=%s bundles=%s player_hp=%s enemy_hp=%s resources=%s" % [
        int(value.get("duel_index", 0)), str(value.get("candidate_id", "")), int(value.get("policy_mode", -1)),
        str(value.get("outcome", "")), str(value.get("bundles", "-")), str(value.get("player_health", "-")),
        str(value.get("enemy_health", "-")), str(value.get("player_resources", {}))
    ]


func _require(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
