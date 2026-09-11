extends SceneTree
const STARTERS := ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]
var failures: Array[String] = []
func _initialize() -> void:
    call_deferred("_run")
func check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
        push_error(label)
func _run() -> void:
    var provider = load("res://src/run/variable_opponent_roster.gd").new()
    var codec = load("res://src/run/combat_checkpoint_codec.gd").new()
    var adapter = load("res://src/run/vertical_slice_opponent_runtime_binding.gd").new()
    var bimu = load("res://src/run/bimu_constraint_model.gd").new()
    var player_mastery := {}
    for id in STARTERS: player_mastery[id] = 3
    var sizes := {}
    var checked := 0
    for candidate in provider.get_all_candidates():
        for stage in range(1, 11):
            var encounter: Dictionary = provider.get_stage(candidate.candidate_id, stage)
            encounter["encounter_id"] = "test:%02d" % stage
            var opponent: Dictionary = provider.get_encounter_candidate(encounter)
            var runtime: Dictionary = adapter.build(opponent)
            runtime.stats = encounter.stats.duplicate(true)
            runtime.final_stat_total_seed = 0
            for value in encounter.stats.values(): runtime.final_stat_total_seed += int(value)
            var ids: Array = []
            var mastery := {}
            for manual in encounter.manuals:
                ids.append(manual.id)
                mastery[manual.id] = manual.mastery
            sizes[ids.size()] = true
            var receipt: Dictionary = bimu.validate_selection([], STARTERS, ids)
            var binding := {"player_loadout": STARTERS.duplicate(), "player_mastery_by_manual": player_mastery.duplicate(), "enemy_candidate_id": candidate.candidate_id, "enemy_loadout": ids, "enemy_mastery_by_manual": mastery, "enemy_runtime_binding": runtime, "effective_enemy_mastery_by_manual": mastery.duplicate(), "bimu_receipt": receipt, "resolved_encounter": encounter}
            check(codec._engine(binding) != null, "Approved binding accepted %s:%d" % [candidate.candidate_id, stage])
            checked += 1
            if stage == 10:
                for mutation in ["empty", "duplicate", "mastery", "unknown", "extra", "legacy"]:
                    var broken := binding.duplicate(true)
                    match mutation:
                        "empty": broken.enemy_loadout.clear()
                        "duplicate": broken.enemy_loadout.append(broken.enemy_loadout[0])
                        "mastery": broken.enemy_mastery_by_manual[ids[0]] = true
                        "unknown": broken.enemy_loadout[0] = "unknown"
                        "extra": broken["future_encounters"] = []
                        "legacy": broken.erase("resolved_encounter")
                    check(codec._engine(broken) == null, "Reject corrupted variable binding " + mutation)
                var strengthened := binding.duplicate(true)
                var target: String = ids[ids.size() - 1]
                strengthened.bimu_receipt = bimu.validate_selection([{"constraint_id":"CST_ENEMY_MASTERED_MANUAL", "target_enemy_manual_id":target}], STARTERS, ids)
                strengthened.effective_enemy_mastery_by_manual = bimu.enemy_mastery_overlay(mastery, strengthened.bimu_receipt)
                check(codec._engine(strengthened) != null, "Constraint applies to auxiliary owned manual")
    check(checked == 160 and sizes.size() == 4, "All 160 approved rows and 2/3/4/5 manual sizes validated")
    await _bridge_roundtrip(player_mastery)
    print("VARIABLE_COMBAT_CODEC: %s (%d rows)" % ["PASS" if failures.is_empty() else "FAIL", checked])
    quit(0 if failures.is_empty() else 1)
func _bridge_roundtrip(player_mastery: Dictionary) -> void:
    var run = load("res://src/run/vertical_slice_run_state.gd").new()
    check(run.start_new_variable_run(12345, "combat"), "Initialize variable combat run")
    check(run.confirm_setup_loadout(STARTERS, player_mastery), "Confirm player loadout")
    for _step in range(3): check(run.advance(), "Advance to v2 combat")
    var encounter: Dictionary = run.export_snapshot().resolved_encounters[0]
    var opponent: Dictionary = run.get_current_opponent()
    var runtime: Dictionary = load("res://src/run/vertical_slice_opponent_runtime_binding.gd").new().build(opponent)
    runtime.stats = encounter.stats.duplicate(true)
    runtime.final_stat_total_seed = 0
    for value in encounter.stats.values(): runtime.final_stat_total_seed += int(value)
    var ids: Array = []
    var mastery := {}
    for manual in encounter.manuals:
        ids.append(manual.id)
        mastery[manual.id] = manual.mastery
    var board = load("res://scenes/run/vertical_slice_combat_bridge.tscn").instantiate()
    root.add_child(board)
    await process_frame
    check(board.configure_vertical_slice_loadouts(STARTERS, player_mastery, ids, mastery, opponent.candidate_id, runtime, {"name":opponent.working_name,"epithet":opponent.epithet}, run.get_frozen_bimu_receipt(), encounter), "Actual bridge binds v2 encounter")
    board.apply_vertical_slice_player_resources(run.get_player_run_resources())
    board.configure_checkpoint_identity(1, 0)
    check(board.capture_planning_checkpoint(), "Capture v2 planning boundary")
    var dto: Dictionary = board.get_last_stable_checkpoint()
    var codec = load("res://src/run/run_checkpoint_codec.gd").new()
    var validation: Dictionary = codec.validate_payload(run.export_snapshot(), dto)
    check(validation.ok, "Run/combat cross-validation")
    if not validation.ok: print(validation)
    var encoded: Dictionary = codec.encode("combat", "planning", 1, run.export_snapshot(), dto)
    check(encoded.ok, "V2 combat envelope encodes")
    if encoded.ok: check(codec.decode(encoded.text).ok, "V2 combat envelope JSON roundtrip")
    var forged := dto.duplicate(true)
    forged.state.enemy.observation_points = 1
    check(not codec.validate_payload(run.export_snapshot(), forged).ok, "V2 forbids persisted enemy observation")
    forged = dto.duplicate(true)
    forged.binding.resolved_encounter.encounter_id = "another:01"
    check(not codec.validate_payload(run.export_snapshot(), forged).ok, "V2 rejects cross-roster combat binding")
    board.queue_free()
    await process_frame
