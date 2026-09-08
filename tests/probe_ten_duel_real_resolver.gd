extends SceneTree

# Bounded simulation probe: real resolver and AI, no forced health/outcome.
# Each opponent starts independently; this is NOT a complete campaign or UX pass.
func _initialize() -> void:
    call_deferred("run_probe")

func run_probe() -> void:
    var catalog := VerticalSliceOpponentCatalog.new()
    var binding_builder := VerticalSliceOpponentRuntimeBinding.new()
    var starters := VerticalSliceStarterManualCatalog.STARTER_MANUAL_IDS.slice(0, 4)
    var mastery := {}
    for manual in starters:
        mastery[manual] = 3
    var hud: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json"))
    var stalled := 0
    for duel in range(1, 11):
        var candidate_id: String = catalog.select_campaign_candidate_id(duel)
        var candidate: Dictionary = catalog.get_candidate(candidate_id)
        var engine := VerticalSliceMetricsCombatResolutionEngine.new()
        if not engine.configure_enemy_runtime_binding(binding_builder.build(candidate)):
            printerr("Invalid runtime binding: ", candidate_id)
            quit(1)
            return
        var manual_id := str(candidate.get("signature_manual_id", ""))
        engine.configure_martial_loadouts(starters, mastery, [manual_id], {manual_id: int(candidate.get("signature_star_seed", 3))})
        var state := engine.make_initial_state(hud, 4, 6)
        state["ai_enabled"] = true
        var outcome := "stalled"
        var used_bundles := 0
        for turn in range(90):
            var bundle := turn % 3 + 1
            state["bundle_index"] = bundle
            state["round_number"] = turn / 3 + 1
            engine.lock_enemy_bundle(state, bundle)
            var placements := public_policy(engine, state, bundle)
            var result := engine.resolve_bundle(placements, {"bundle_index": bundle, "round_number": state["round_number"], "timing_sequence": [3, 3, 4]}, state)
            state = result["state"]
            used_bundles += 1
            if int(state["player"]["health"][0]) <= 0 or int(state["enemy"]["health"][0]) <= 0:
                outcome = "win" if int(state["enemy"]["health"][0]) <= 0 else "loss"
                break
        print("REAL_RESOLVER_PROBE duel=%d candidate=%s outcome=%s bundles=%d player_hp=%s enemy_hp=%s" % [duel, candidate_id, outcome, used_bundles, state["player"]["health"], state["enemy"]["health"]])
        if outcome == "stalled":
            stalled += 1
    quit(1 if stalled > 0 else 0)

func public_policy(engine, state: Dictionary, bundle: int) -> Array:
    var placements: Array = []
    var start: int = [1, 4, 7][bundle - 1]
    var remaining: int = [3, 3, 4][bundle - 1]
    var player: Dictionary = state["player"]
    var enemy: Dictionary = state["enemy"]
    var stamina := int(player["stamina"][0])
    var internal := int(player["internal"][0])
    var distance := absi(int(player["tile"]) - int(enemy["tile"]))
    while remaining > 0:
        var id := "basic_meditate"
        if distance <= 1 and stamina >= 1:
            id = "basic_quick_attack"
        elif distance <= 3 and distance >= 1 and internal >= 1 and remaining >= 2:
            id = "basic_palm"
        elif distance > 3 and stamina >= 1:
            id = "basic_move"
        var definition: Dictionary = engine.cards_by_id[id]
        var span := int(definition.get("action_slots", 1))
        stamina -= int(definition.get("stamina_cost", 0))
        internal -= int(definition.get("internal_cost", 0))
        if id == "basic_meditate":
            stamina += 1
            internal += 1
        var direction := 1 if int(enemy["tile"]) >= int(player["tile"]) else -1
        placements.append({"card_id": id, "anchor_index": start, "span": span, "target_ready": true, "target_tile": int(player["tile"]) + direction if id == "basic_move" else int(enemy["tile"]), "direction": direction, "origin_tile": int(player["tile"])})
        start += span
        remaining -= span
    return placements
