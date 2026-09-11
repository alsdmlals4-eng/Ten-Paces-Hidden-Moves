extends SceneTree
const Run = preload("res://src/run/vertical_slice_run_state.gd")
const Roster = preload("res://src/run/variable_opponent_roster.gd")
const Codec = preload("res://src/run/run_checkpoint_codec.gd")
const STARTERS := ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]
var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var provider = Roster.new()
    var route = load("res://src/run/vertical_slice_route_model.gd").new()
    var registry = load("res://src/combat/martial_manual_registry.gd").new()
    var expected_names: Array[String] = []
    var row: Dictionary = provider.get_stage("masked_baekmujin", 2)
    row["encounter_id"] = "recon:02"
    for card in registry.build_unlocked_cards(row.manuals[0].id, row.manuals[0].mastery): expected_names.append(card.name)
    var text: String = route.build_public_intel("MANUAL_RUMOR", provider.get_encounter_candidate(row))
    check(text.contains(", ".join(expected_names)), "Baek recon must use current encounter mastery, not absent legacy seed")
    var run = Run.new()
    check(run.start_new_variable_run(123, "recon"), "start")
    var snapshot: Dictionary = run.export_snapshot()
    for stage in range(1, 11):
        var encounter: Dictionary = provider.get_stage("masked_baekmujin", stage)
        encounter["encounter_id"] = "recon:%02d" % stage
        snapshot.resolved_encounters[stage-1] = encounter
    snapshot.current_opponent_id = "masked_baekmujin"
    snapshot.roster_digest = Codec.digest(snapshot.resolved_encounters)
    check(run.import_snapshot(snapshot).ok, "repeated-person approved roster fixture")
    var mastery := {}
    for id in STARTERS: mastery[id] = 3
    check(run.confirm_setup_loadout(STARTERS, mastery), "setup")
    run.advance()
    run.advance()
    run.advance()
    var rumor_count := 0
    for duel in range(1,11):
        check(run.get_current_screen() == "COMBAT", "combat stage")
        check(run.mark_combat_finished({"outcome":"win"}), "win")
        run.advance()
        run.set_pending_result_reward({"reward_type":"free_training", "free_training":6})
        run.advance()
        if duel == 10: break
        for step in range(4):
            var options: Array = run.get_jianghu_options()
            var choice: String = options[0].id
            for option in options:
                if option.id == "recon": choice = "recon"
            check(run.select_jianghu_node(choice, step), "route selection")
            if choice == "recon":
                rumor_count += 1
                var receipt: Dictionary = run.get_pending_jianghu()
                check(receipt.get("encounter_id") == "recon:%02d" % (duel+1), "recon receipt belongs to exact encounter")
            check(run.validate_snapshot(run.export_snapshot()).ok, "pending route snapshot validates stage %d/%d" % [duel,step])
            run.advance()
        var intel: Dictionary = run.get_current_opponent_intel()
        if not intel.is_empty():
            check(intel.get("encounter_id") == "recon:%02d" % (duel+1), "repeated person gets current encounter intel only")
            for entry in intel.get("entries", []): check(entry.get("encounter_id") == intel.get("encounter_id"), "no prior-stage rumor mixing")
        var restored = Run.new()
        check(restored.import_snapshot(run.export_snapshot()).ok, "recon resume validation")
        check(restored.get_current_opponent_intel() == intel, "recon resume exact")
        run = restored
        run.advance()
    check(rumor_count > 1, "multiple recon receipts exercised")
    check(run.get_current_screen() == "COMPLETION", "all ten duels completed")
    check(run.get_route_history().size() == 36, "all36 routes")
    for failure in failures: printerr("FAIL: ",failure)
    print("VARIABLE_RECON_", "PASS" if failures.is_empty() else "FAIL")
    quit(0 if failures.is_empty() else 1)
