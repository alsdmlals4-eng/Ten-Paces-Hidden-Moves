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
const BASIC_ULTIMATES := [
    "ultimate_void_sword_qi",
    "ultimate_cleave_peak",
    "ultimate_ten_paces_wave"
]
const BasicCardTrayScript := preload("res://src/ui/basic_card_tray.gd")

var failures: Array[String] = []
var publicly_used_player_cards := {}


func _initialize() -> void:
    call_deferred("run_probe")


func run_probe() -> void:
    publicly_used_player_cards.clear()
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
        var first := _resolve_actual_duel(run, 0)
        attempts.append(first.duplicate(true))
        print(_attempt_line(first))
        _require(str(first.get("outcome", "")) in ["win", "loss", "draw"], "duel %d must reach terminal HP" % duel)
        if not failures.is_empty():
            break
        _require(run.mark_combat_finished(first), "duel %d terminal result must enter review" % duel)
        _require(run.advance(), "duel %d review must advance" % duel)
        if str(first.get("outcome", "")) == "loss":
            _require(run.retry_failed_duel(), "duel %d must permit its one legal retry" % duel)
            var retry := _resolve_actual_duel(run, 1)
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
            "focused_training", _reward_target_for_duel(duel),
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

    var publicly_used_card_ids: Array = publicly_used_player_cards.keys()
    publicly_used_card_ids.sort()
    var ultimate_use_count := 0
    for attempt in attempts:
        ultimate_use_count += int((attempt.get("battle_metrics", {}) as Dictionary).get("ultimate_uses", 0))
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
        "publicly_used_player_card_ids": publicly_used_card_ids,
        "ultimate_use_count": ultimate_use_count,
        "attempts": attempts
    }
    print("SEQUENTIAL_CAMPAIGN_SUMMARY ", JSON.stringify(summary))
    _require(run.is_complete(), "campaign must complete after ten real engine wins/draws")
    _require(run.get_duel_history().size() == 10, "ten actual terminal successes must be retained")
    _require(run.get_reward_history().size() == 10, "ten earned rewards must be retained")
    _require(run.get_route_history().size() == 36, "nine intervals must retain 36 real choices")
    _require(publicly_used_player_cards.has("shaolin_arhat_vajra_art_star7"), "public policy must actually resolve the unlocked Shaolin seven-star technique")
    _require(publicly_used_player_cards.has("yang_family_spear_star7"), "public policy must actually resolve the unlocked Yang seven-star technique")
    _require(ultimate_use_count > 0, "public policy must actually resolve a base ultimate when own momentum makes one legal")
    for failure in failures:
        printerr("SEQUENTIAL_CAMPAIGN_FAIL: ", failure)
    quit(1 if not failures.is_empty() else 0)


func _resolve_actual_duel(run: VerticalSliceRunState, policy_mode: int) -> Dictionary:
    var candidate := run.get_current_opponent()
    var binding := VerticalSliceOpponentRuntimeBinding.new().build(candidate)
    var engine := VerticalSliceMetricsCombatResolutionEngine.new()
    if not engine.configure_enemy_runtime_binding(binding):
        return {"outcome": "invalid_binding", "duel_index": run.duel_index}
    var enemy_manual := str(candidate.get("signature_manual_id", ""))
    engine.configure_martial_loadouts(
        run.get_player_manual_loadout(), run.get_player_mastery_by_manual(),
        [enemy_manual], {enemy_manual: int(candidate.get("signature_star_seed", 3))})
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
                "duel_public_player_card_ids": duel_public_player_card_ids,
                "player_card_counts": _player_card_counts(state),
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
    var defense := _public_bundle_defense(engine, policy_mode)
    if not defense.is_empty() and stamina >= int(defense.get("stamina_cost", 0)) and internal >= int(defense.get("internal_cost", 0)):
        placements.append(_placement_for(defense, start, player, enemy))
        stamina -= int(defense.get("stamina_cost", 0))
        internal -= int(defense.get("internal_cost", 0))
        start += 1
        remaining -= 1
    while remaining > 0:
        var definition := _best_public_action(engine, state, remaining, stamina, internal, distance)
        if definition.is_empty():
            definition = (engine.cards_by_id.get("basic_meditate", {}) as Dictionary).duplicate(true)
        var span := int(definition.get("action_slots", 1))
        if _is_ultimate(definition):
            var momentum: Array = player.get("momentum", [0, 5])
            player["momentum"] = [0, int(momentum[1])]
            state["player"] = player
        stamina -= int(definition.get("stamina_cost", 0))
        internal -= int(definition.get("internal_cost", 0))
        if str(definition.get("base_card_id", definition.get("id", ""))) == "basic_meditate":
            stamina += 1
            internal += 1
        placements.append(_placement_for(definition, start, player, enemy))
        start += span
        remaining -= span
    return placements


func _best_public_action(engine, state: Dictionary, remaining: int, stamina: int, internal: int, distance: int) -> Dictionary:
    var candidates: Array[Dictionary] = []
    var player_ids: PackedStringArray = engine.get_player_martial_card_ids()
    for card_id in player_ids:
        var martial: Dictionary = (engine.cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
        if _public_action_is_legal(martial, state, remaining, stamina, internal, distance):
            candidates.append(martial)
    for card_id in BASIC_ULTIMATES + ["basic_heavy_attack", "basic_quick_attack", "basic_palm"]:
        var definition: Dictionary = (engine.cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)
        if _public_action_is_legal(definition, state, remaining, stamina, internal, distance):
            candidates.append(definition)
    if candidates.is_empty() and distance > 1:
        return (engine.cards_by_id.get("basic_move", {}) as Dictionary).duplicate(true)
    candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        var a_score := _public_action_score(a)
        var b_score := _public_action_score(b)
        return a_score > b_score if a_score != b_score else str(a.get("id", "")) < str(b.get("id", ""))
    )
    return candidates[0] if not candidates.is_empty() else {}


func _public_action_is_legal(definition: Dictionary, state: Dictionary, remaining: int, stamina: int, internal: int, distance: int) -> bool:
    if definition.is_empty() or str(definition.get("category", "")) != "attack":
        return false
    if int(definition.get("action_slots", 1)) > remaining:
        return false
    if int(definition.get("stamina_cost", 0)) > stamina or int(definition.get("internal_cost", 0)) > internal:
        return false
    if _is_ultimate(definition):
        var momentum = (state.get("player", {}) as Dictionary).get("momentum", [0, 5])
        if typeof(momentum) != TYPE_ARRAY or momentum.size() < 2 or int(momentum[0]) != int(momentum[1]):
            return false
    var range_data = definition.get("range", {})
    var minimum := 0
    var maximum := int(str(definition.get("range_text", "0")))
    if typeof(range_data) == TYPE_DICTIONARY and not (range_data as Dictionary).is_empty():
        minimum = int((range_data as Dictionary).get("min", 0))
        maximum = int((range_data as Dictionary).get("max", minimum))
    var approach := 1 if bool(definition.get("dash_before_attack", false)) else _leading_move_toward(definition)
    var effective_distance := maxi(0, distance - approach)
    return effective_distance >= minimum and effective_distance <= maximum


func _public_action_score(definition: Dictionary) -> int:
    if _is_ultimate(definition):
        return 1000 + int(str(definition.get("damage", "0"))) * 10 - int(definition.get("action_slots", 1))
    var power := 0
    for value in definition.get("effect_steps", []):
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("op", "")) in ["ATTACK", "INDEPENDENT_ATTACK", "SPECIAL_CLASH"]:
            power += int((value as Dictionary).get("power", 0))
    if power == 0:
        var damage_formula = definition.get("damage_formula", {})
        if typeof(damage_formula) == TYPE_DICTIONARY:
            power = int((damage_formula as Dictionary).get("base", 0)) + int(floor(float((damage_formula as Dictionary).get("coefficient", 0.0)) * 4.0))
    var card_id := str(definition.get("id", ""))
    var mastery_priority := 30 if int(definition.get("unlock_star", 0)) >= 7 and not publicly_used_player_cards.has(card_id) else 0
    return power * 10 + mastery_priority - int(definition.get("action_slots", 1)) * 2 - int(definition.get("stamina_cost", 0)) - int(definition.get("internal_cost", 0))


func _leading_move_toward(definition: Dictionary) -> int:
    var steps: Array = definition.get("effect_steps", [])
    if not steps.is_empty() and typeof(steps[0]) == TYPE_DICTIONARY and str((steps[0] as Dictionary).get("op", "")) == "MOVE_TOWARD":
        return maxi(0, int((steps[0] as Dictionary).get("tiles", 0)))
    return 0


func _public_bundle_defense(engine, policy_mode: int) -> Dictionary:
    if policy_mode == 0:
        return (engine.cards_by_id.get("basic_guard", {}) as Dictionary).duplicate(true)
    var tray = BasicCardTrayScript.new()
    var combo: Dictionary = tray.build_stance_response_combo(
        engine.cards_by_id.get("basic_stance", {}),
        engine.cards_by_id.get("basic_evade", {})
    )
    tray.free()
    return combo


func _placement_for(definition: Dictionary, anchor: int, player: Dictionary, enemy: Dictionary) -> Dictionary:
    var base_id := str(definition.get("base_card_id", definition.get("id", "")))
    var direction := 1 if int(enemy.get("tile", 1)) >= int(player.get("tile", 1)) else -1
    return {
        "card_id": str(definition.get("id", "")),
        "definition": definition.duplicate(true),
        "anchor_index": anchor,
        "span": int(definition.get("action_slots", 1)),
        "target_ready": true,
        "target_tile": int(player.get("tile", 1)) + direction if base_id == "basic_move" else int(enemy.get("tile", 1)),
        "direction": direction,
        "origin_tile": int(player.get("tile", 1))
    }


func _is_ultimate(definition: Dictionary) -> bool:
    return str(definition.get("source", "")) == "ultimate" or str(definition.get("source_kind", "")) == "ultimate"


func _reward_target_for_duel(duel: int) -> String:
    if duel <= 4:
        return "shaolin_arhat_vajra_art"
    if duel <= 8:
        return "yang_family_spear"
    return "mount_hua_plum_blossom_sword"


func _policy_label(policy_mode: int) -> String:
    return "public_guarded_pressure" if policy_mode == 0 else "public_evasive_retry"


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


func _player_card_counts(state: Dictionary) -> Dictionary:
    var counts := {}
    for value in state.get("public_resolution_history", []):
        if typeof(value) != TYPE_DICTIONARY or str((value as Dictionary).get("actor", "")) != "player":
            continue
        var card_id := str((value as Dictionary).get("card_id", ""))
        if not card_id.is_empty():
            counts[card_id] = int(counts.get(card_id, 0)) + 1
    return counts


func _remember_public_player_cards(state: Dictionary) -> void:
    for card_id in _player_card_counts(state):
        publicly_used_player_cards[str(card_id)] = true


func _apply_validated_run_resources(state: Dictionary, resources: Dictionary) -> bool:
    var player_value = state.get("player", null)
    if typeof(player_value) != TYPE_DICTIONARY:
        return false
    var player: Dictionary = (player_value as Dictionary).duplicate(true)
    for key in ["health", "stamina", "internal"]:
        var pair = resources.get(key, null)
        if typeof(pair) != TYPE_ARRAY or pair.size() < 2:
            return false
        var maximum := maxi(0, int(pair[1]))
        var current := clampi(int(pair[0]), 0, maximum)
        player[key] = [current, maximum]
    state["player"] = player
    return true


func _attempt_line(value: Dictionary) -> String:
    return "SEQUENTIAL_DUEL duel=%d candidate=%s attempt_policy=%d outcome=%s bundles=%s player_hp=%s enemy_hp=%s resources=%s" % [
        int(value.get("duel_index", 0)), str(value.get("candidate_id", "")), int(value.get("policy_mode", -1)),
        str(value.get("outcome", "")), str(value.get("bundles", "-")), str(value.get("player_health", "-")),
        str(value.get("enemy_health", "-")), str(value.get("player_resources", {}))
    ]


func _require(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
