extends SceneTree
func _initialize() -> void:
    var ai = load("res://src/combat/combat_ai_planner.gd").new()
    if not ai.has_method("set_signature_manual"):
        printerr("Signature selection missing: actual campaign used zero martial cards")
        quit(1)
        return
    var provider = load("res://src/run/variable_opponent_roster.gd").new()
    var errors: Array[String] = []
    var checks := 0
    for candidate in provider.get_all_candidates():
        var row: Dictionary = provider.get_stage(candidate.candidate_id,1)
        row.encounter_id="ai:01"
        candidate=provider.get_encounter_candidate(row)
        var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
        var binding = load("res://src/run/vertical_slice_opponent_runtime_binding.gd").new().build(candidate)
        engine.configure_enemy_runtime_binding(binding)
        engine.variable_opponent_rules=true
        var ids: Array = []
        var masteries := {}
        for manual in provider.get_stage(candidate.candidate_id,1).manuals:
            ids.append(manual.id);masteries[manual.id]=manual.mastery
        engine.configure_martial_loadouts([],{},ids,masteries)
        engine.ai_planner.set_signature_manual(candidate.signature_manual_id)
        var state: Dictionary = engine.make_initial_state(JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json")),4,6)
        state.ai_enabled=true
        var seen := false
        for distance in range(5):
            state.enemy.tile=4+distance
            var before := state.duplicate(true)
            var plan: Array = engine.ai_planner.build_bundle_actions(state,1,engine.get_enemy_ai_cards_by_id())
            checks+=1
            if state!=before: errors.append("AI mutates public state")
            for action in plan:
                if str(action.card_id).begins_with(candidate.signature_manual_id+"_star"): seen=true
            var hidden := state.duplicate(true)
            hidden.player_pending_plan=["secret"]
            checks+=1
            if engine.ai_planner.build_bundle_actions(hidden,1,engine.get_enemy_ai_cards_by_id())!=plan: errors.append("AI reads hidden player intent")
        checks+=1
        if not seen: errors.append("No legal signature selected: "+candidate.candidate_id)
    for error in errors: printerr(error)
    print("SIGNATURE_AI checks=%d failures=%d" % [checks,errors.size()])
    quit(0 if errors.is_empty() else 1)
