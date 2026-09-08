extends SceneTree

var failures: Array[String] = []
const STARTERS := ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]

func _initialize() -> void:
    create_timer(60.0).timeout.connect(func(): push_error("Save verification timed out"); quit(1))
    call_deferred("_run")

func check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
        push_error(label)

func new_run():
    var run = load("res://src/run/vertical_slice_run_state.gd").new()
    run.configure_opponents(load("res://src/run/vertical_slice_opponent_catalog.gd").new(), 42)
    run.start_new_run()
    var mastery := {}
    for id in STARTERS:
        mastery[id] = 3
    run.confirm_setup_loadout(STARTERS, mastery)
    return run

func _run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() == 2 and args[0] in ["--checkpoint-write", "--checkpoint-read"]:
        _fresh_process_fixture(args[0], args[1])
        finish()
        return
    var run = new_run()
    if not run.has_method("export_snapshot") or not run.has_method("import_snapshot"):
        check(false, "Explicit durable run snapshot API must exist")
        finish()
        return
    var source: Dictionary = run.export_snapshot()
    var restored = new_run()
    check(restored.import_snapshot(JSON.parse_string(JSON.stringify(source))).get("ok", false), "Fresh JSON snapshot imports")
    check(restored.export_snapshot() == source, "Fresh run roundtrip preserves all fields")
    for key in ["duel_index", "completed_duels", "route_visits", "retry_count", "attempt_id", "run_seed"]:
        for bad in [1.25, "1", true, -1]:
            var broken := source.duplicate(true)
            broken[key] = bad
            check(not restored.import_snapshot(broken).get("ok", false), "Reject malformed numeric " + key)
            check(restored.export_snapshot() == source, "Failed import is atomic")
    for field in ["mastery_by_manual", "training_by_manual"]:
        var broken := source.duplicate(true)
        broken.progression[field][STARTERS[0]] = 3.5
        check(not restored.import_snapshot(broken).get("ok", false), "Reject fractional progression")
    var broken := source.duplicate(true)
    broken.progression.player_resources.health = [31, 30]
    check(not restored.import_snapshot(broken).get("ok", false), "Reject wrong resource pair without clamp")
    broken = source.duplicate(true)
    broken.current_opponent_id = "slot5_rajin"
    check(not restored.import_snapshot(broken).get("ok", false), "Reject opponent/duel mismatch")
    broken = source.duplicate(true)
    broken.progression.owned_manual_ids.append("invented")
    check(not restored.import_snapshot(broken).get("ok", false), "Reject unknown manual")
    run.advance()
    run.advance()
    run.advance()
    run.mark_combat_finished({"outcome": "loss"})
    run.advance()
    source = run.export_snapshot()
    check(restored.import_snapshot(source).get("ok", false), "Failure receipt roundtrip")
    check(restored.retry_failed_duel(), "Restored retry remains available exactly once")
    check(restored.get_retry_remaining() == 0, "Restored retry cannot reset count")
    check(restored.get_run_seed() == 42, "Restored retry preserves seed")
    broken = source.duplicate(true)
    broken.pre_battle_snapshot.duel_index = 9
    check(not restored.import_snapshot(broken).get("ok", false), "Reject wrong prebattle identity")
    broken = source.duplicate(true)
    broken.pre_battle_snapshot.progression.free_training_pool = 999
    check(not restored.import_snapshot(broken).get("ok", false), "Reject fabricated prebattle training reward")
    run.retry_failed_duel()
    run.mark_combat_finished({"outcome": "win"})
    run.advance()
    check(restored.import_snapshot(run.export_snapshot()).get("ok", false), "Result pre-selection roundtrip")
    run.set_pending_result_reward({"reward_type": "free_training", "free_training": 6})
    check(restored.import_snapshot(run.export_snapshot()).get("ok", false), "Result pending receipt roundtrip")
    run.advance()
    check(restored.import_snapshot(run.export_snapshot()).get("ok", false), "Route before selection roundtrip")
    run.select_jianghu_node("training", 0)
    source = run.export_snapshot()
    check(restored.import_snapshot(source).get("ok", false), "Applied route plus pending receipt roundtrip")
    broken = source.duplicate(true)
    broken.progression.free_training_pool = 100
    check(not restored.import_snapshot(broken).get("ok", false), "Training total must agree with confirmed and pending receipts")
    check(restored.get_progression_snapshot().free_training_pool == 9, "Reward six plus route three retained")
    check(restored.advance(), "Restored pending route advances")
    check(restored.get_progression_snapshot().free_training_pool == 9, "Restored advance never reapplies route")
    check(restored.route_visits == 1, "Route visits advance once")
    if not ResourceLoader.exists("res://src/run/run_save_store.gd"):
        check(false, "Recoverable durable store must exist")
        finish()
        return
    var root_path := OS.get_cache_dir().path_join("ten-paces-save-test-%s-%s" % [OS.get_process_id(), Time.get_ticks_usec()])
    var store = load("res://src/run/run_save_store.gd").new(root_path)
    check(not DirAccess.dir_exists_absolute(root_path), "Construction never performs production IO")
    check(store.load_checkpoint().status == "ABSENT", "Missing save is absent")
    var saved: Dictionary = store.replace_run("run-a", "route-0", source)
    check(saved.get("ok", false), "New generation durable in both slots")
    if not saved.get("ok", false):
        print(saved)
        finish()
        return
    check(store.load_checkpoint().status == "VALID_PRIMARY", "Validated primary exposed")
    var same: Dictionary = store.save_checkpoint("run-a", "route-0", source)
    check(same.get("revision") == saved.get("revision"), "Identical checkpoint idempotent")
    var advanced: Dictionary = restored.export_snapshot()
    var next: Dictionary = store.save_checkpoint("run-a", "route-0", advanced)
    check(next.get("revision", 0) == saved.get("revision", 0) + 1, "Same boundary with different pending data creates revision")
    store.io_guard = func(operation: String, _path: String): return operation != "rename_primary"
    var failed: Dictionary = store.save_checkpoint("run-a", "route-1", source)
    check(not failed.get("ok", false) and failed.status == "IO_FAILURE", "Rename failure cannot acknowledge")
    check(store.load_checkpoint().payload.run_state == advanced, "Failed write preserves acknowledged primary")
    store.io_guard = Callable()
    var retry: Dictionary = store.save_checkpoint("run-a", "route-1", source)
    check(retry.get("revision") == failed.get("revision"), "Failed retry retains exact pending revision")
    var primary := root_path.path_join("primary.json")
    var file := FileAccess.open(primary, FileAccess.WRITE)
    file.store_string("{broken")
    file.close()
    check(store.load_checkpoint().status == "RECOVERED_BACKUP", "Corrupt primary recovers validated backup")
    check(FileAccess.get_file_as_string(primary) == "{broken", "Recovery preserves corrupt evidence")
    check(store.replace_run("run-b", "new", source).get("ok", false), "Explicit new generation replaces recoverable slots")
    file = FileAccess.open(primary, FileAccess.WRITE)
    file.store_string("{broken-again")
    file.close()
    check(store.load_checkpoint().payload.save_id == "run-b", "Acknowledged replacement cannot resurrect old generation")
    check(store.retire_run("run-b", "end").get("ok", false), "Retirement durable")
    file = FileAccess.open(primary, FileAccess.WRITE)
    file.store_string("{broken-retired")
    file.close()
    check(store.load_checkpoint().status == "ABSENT", "Tombstone backup prevents resurrection")
    store.replace_run("run-c", "new", source)
    var envelope: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(primary))
    envelope.schema_version = 999
    file = FileAccess.open(primary, FileAccess.WRITE)
    file.store_string(JSON.stringify(envelope))
    file.close()
    check(store.load_checkpoint().status == "INCOMPATIBLE", "Future primary never downgrades via backup")
    check(not store.save_checkpoint("run-c", "new", source).get("ok", false), "Ordinary save cannot overwrite incompatible evidence")
    var codec = load("res://src/run/run_checkpoint_codec.gd").new()
    var encoded: Dictionary = codec.encode("fixture", "boundary", 1, source)
    check(not codec.decode(encoded.text.insert(encoded.text.length() - 1, ",")).get("ok", false), "Reject trailing JSON comma instead of silently sanitizing")
    check(not codec.decode(encoded.text.insert(1, '"schema_version":999,')).get("ok", false), "Reject duplicate JSON key instead of last-key-wins")
    var nonfinite := source.duplicate(true)
    nonfinite.progression.free_training_pool = INF
    check(not restored.import_snapshot(nonfinite).get("ok", false), "Reject nonfinite domain values")
    var nodes: Array = []
    nodes.resize(100001)
    check(not codec.json_safe(nodes, 0, [0]), "Bound JSON node count")
    check(not codec.validate_payload(source, {"invented": 1}).get("ok", false), "Nonempty unsupported combat rejected")
    check(not codec.decode("x".repeat(8 * 1024 * 1024 + 1)).get("ok", false), "Oversize input bounded")
    check(not codec.decode("[".repeat(66) + "0" + "]".repeat(66)).get("ok", false), "Deep input bounded")
    _verify_campaign_snapshots()
    _verify_interrupted_generation(source)
    _verify_corrupt_metadata_recovery(source)
    finish()

func _verify_corrupt_metadata_recovery(source: Dictionary) -> void:
    var storage := OS.get_cache_dir().path_join("ten-paces-metadata-test-%s-%s" % [OS.get_process_id(), Time.get_ticks_usec()])
    var store = load("res://src/run/run_save_store.gd").new(storage)
    check(store.replace_run("metadata", "start", source).get("ok", false), "Metadata fixture durable in both slots")
    var primary := storage.path_join("primary.json")
    var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(primary))
    for mutation in ["content_changed", "content_missing", "schema_missing", "schema_string"]:
        var damaged: Dictionary = original.duplicate(true)
        match mutation:
            "content_changed": damaged.content_identity = "different-content"
            "content_missing": damaged.erase("content_identity")
            "schema_missing": damaged.erase("schema_version")
            "schema_string": damaged.schema_version = "1"
        var text := JSON.stringify(damaged)
        var file := FileAccess.open(primary, FileAccess.WRITE)
        file.store_string(text)
        file.close()
        var loaded: Dictionary = store.load_checkpoint()
        check(loaded.status == "RECOVERED_BACKUP", "Corrupt metadata recovers backup: " + mutation)
        check(loaded.get("payload", {}) == store.codec.normalized(original), "Metadata recovery exposes only validated original payload: " + mutation)
        check(FileAccess.get_file_as_string(primary) == text, "Metadata recovery preserves damaged primary: " + mutation)
    for mutation in ["different_content_valid_hash", "future_numeric_schema"]:
        var incompatible: Dictionary = original.duplicate(true)
        if mutation == "different_content_valid_hash":
            incompatible.content_identity = "different-content"
            incompatible.erase("integrity_hash")
            incompatible.integrity_hash = store.codec.digest(incompatible)
        else:
            incompatible.schema_version = 999
        var text := JSON.stringify(incompatible)
        var file := FileAccess.open(primary, FileAccess.WRITE)
        file.store_string(text)
        file.close()
        check(store.load_checkpoint().status == "INCOMPATIBLE", "Genuine incompatible metadata blocks fallback: " + mutation)
        check(FileAccess.get_file_as_string(primary) == text, "Incompatible primary preserved: " + mutation)

func _verify_interrupted_generation(source: Dictionary) -> void:
    var storage := OS.get_cache_dir().path_join("ten-paces-generation-test-%s-%s" % [OS.get_process_id(), Time.get_ticks_usec()])
    var store = load("res://src/run/run_save_store.gd").new(storage)
    check(store.replace_run("old", "start", source).get("ok", false), "Generation fixture durable")
    store.io_guard = func(operation: String, _path: String): return operation != "rename_primary"
    var failed: Dictionary = store.replace_run("new", "start", source)
    check(not failed.ok, "Backup-only replacement remains unacknowledged")
    var fresh = load("res://src/run/run_save_store.gd").new(storage)
    check(fresh.load_checkpoint().payload.save_id == "old", "Old valid primary wins interrupted new backup")
    check(not store.save_checkpoint("new", "start", source).get("ok", false), "Pending replacement cannot degrade to ordinary rotation")
    store.io_guard = Callable()
    var retried: Dictionary = store.replace_run("new", "start", source)
    check(retried.ok and retried.revision == failed.revision, "Replacement retry retains revision")
    var primary: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(storage.path_join("primary.json")))
    var backup: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(storage.path_join("backup.json")))
    check(primary == backup and primary.save_id == "new", "Acknowledged replacement matches both slots")
    store.io_guard = func(operation: String, _path: String): return operation != "write_primary"
    check(not store.retire_run("new", "end").get("ok", false), "Failed retirement write not acknowledged")
    check(fresh.load_checkpoint().payload.active, "Pre-acknowledgment retirement retains valid primary")
    store.io_guard = Callable()
    check(store.retire_run("new", "end").get("ok", false), "Retirement retry succeeds")
    primary = JSON.parse_string(FileAccess.get_file_as_string(storage.path_join("primary.json")))
    backup = JSON.parse_string(FileAccess.get_file_as_string(storage.path_join("backup.json")))
    check(primary == backup and not primary.active, "Retirement acknowledgment matches both slots")
    check(store.retire_run("new", "end").revision == primary.revision, "Retirement idempotency still checks both slots")
    var read_count := {"count": 0}
    store.io_guard = func(operation: String, _path: String):
        if operation == "read_primary":
            read_count.count += 1
            return read_count.count < 3
        return true
    failed = store.replace_run("response-loss", "start", source)
    check(not failed.ok and failed.status == "IO_FAILURE", "Post-replacement readback failure not acknowledged")
    check(fresh.load_checkpoint().payload.save_id == "response-loss", "Fresh reader sees validated published primary after response loss")
    store.io_guard = Callable()
    retried = store.replace_run("response-loss", "start", source)
    check(retried.ok and retried.revision == failed.revision, "Response loss retry retains exact revision")
    primary = JSON.parse_string(FileAccess.get_file_as_string(storage.path_join("primary.json")))
    backup = JSON.parse_string(FileAccess.get_file_as_string(storage.path_join("backup.json")))
    check(primary == backup, "Response loss retry verifies both slots before acknowledgment")
    for slot in ["primary", "backup"]:
        var file := FileAccess.open(storage.path_join(slot + ".json"), FileAccess.WRITE)
        file.store_string("{invalid")
        file.close()
    var corrupt_store = load("res://src/run/run_save_store.gd").new(storage)
    check(corrupt_store.load_checkpoint().status == "CORRUPT", "Both corrupt slots remain corrupt")
    check(not corrupt_store.save_checkpoint("accidental-new", "start", source).get("ok", false), "Ordinary checkpoint cannot silently replace unrecoverable save")

func _fresh_process_fixture(mode: String, storage: String) -> void:
    var store = load("res://src/run/run_save_store.gd").new(storage)
    if mode == "--checkpoint-write":
        var run = new_run()
        run.advance()
        run.advance()
        run.advance()
        run.mark_combat_finished({"outcome": "win"})
        run.advance()
        run.set_pending_result_reward({"reward_type": "free_training", "free_training": 6})
        run.advance()
        run.select_jianghu_node("training", 0)
        check(store.replace_run("fresh-process", "pending-training", run.export_snapshot()).get("ok", false), "Fresh process writer commits pending training")
    else:
        var loaded: Dictionary = store.load_checkpoint()
        check(loaded.get("status") == "VALID_PRIMARY", "Fresh process finds primary")
        if not loaded.get("ok", false): return
        var run = load("res://src/run/vertical_slice_run_state.gd").new()
        check(run.import_snapshot(loaded.payload.run_state).get("ok", false), "Fresh process restores models")
        check(run.get_current_screen() == "JIANGHU" and run.get_progression_snapshot().free_training_pool == 9, "Fresh process retains confirmed reward and selected route effect")
        check(run.advance() and run.route_visits == 1 and run.get_progression_snapshot().free_training_pool == 9, "Fresh process consumes receipt exactly once")

func _verify_campaign_snapshots() -> void:
    var campaign = new_run()
    var target = new_run()
    campaign.advance()
    campaign.advance()
    for duel in range(1, 11):
        check(target.import_snapshot(campaign.export_snapshot()).get("ok", false), "Campaign briefing snapshot %d" % duel)
        campaign.advance()
        campaign.mark_combat_finished({"outcome": "win", "player_resources": {"health": [20, 30], "stamina": [2, 5], "internal": [1, 4]}})
        campaign.advance()
        var model = load("res://src/run/vertical_slice_result_model.gd").new()
        campaign.set_pending_result_reward(model.build_reward_receipt("faction_transfer", "", campaign.get_player_manual_loadout(), campaign.get_current_opponent()))
        check(target.import_snapshot(JSON.parse_string(JSON.stringify(campaign.export_snapshot()))).get("ok", false), "Campaign result snapshot %d" % duel)
        campaign.advance()
        if duel == 10: break
        for step in range(4):
            var options: Array = campaign.get_jianghu_options()
            campaign.select_jianghu_node(options[0].id, step)
            check(target.import_snapshot(campaign.export_snapshot()).get("ok", false), "Campaign pending route %d/%d" % [duel, step])
            campaign.advance()
    check(target.import_snapshot(campaign.export_snapshot()).get("ok", false), "Campaign completion snapshot")
    check(target.completed_duels == 10 and target.route_visits == 36, "Restored complete campaign preserves all counts")

func finish() -> void:
    print("RUN_SAVE_STORE: %s (%d failures)" % ["PASS" if failures.is_empty() else "FAIL", failures.size()])
    quit(0 if failures.is_empty() else 1)
