extends SceneTree

const STORE := preload("res://src/run/run_save_store.gd")
const CODEC := preload("res://src/run/run_checkpoint_codec.gd")
const STARTERS := ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]

class CountingCodec extends "res://src/run/run_checkpoint_codec.gd":
    var decode_calls := 0
    var validate_calls := 0
    var context_suffix := ""

    func decode(text: String) -> Dictionary:
        decode_calls += 1
        return super.decode(text)

    func validate_payload(run_state, combat_checkpoint = {}) -> Dictionary:
        validate_calls += 1
        return super.validate_payload(run_state, combat_checkpoint)

    func content_identity() -> String:
        return super.content_identity() + context_suffix

    func reset_counts() -> void:
        decode_calls = 0
        validate_calls = 0


var failures: Array[String] = []
var _root_sequence := 0
var _owned_roots: Array[String] = []


func _initialize() -> void:
    create_timer(120.0).timeout.connect(func():
        push_error("Run save cache verification timed out")
        quit(1)
    )
    call_deferred("_run")


func check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
        push_error("RUN_SAVE_CACHE_FAIL: " + label)


func _new_root(label: String) -> String:
    _root_sequence += 1
    var root_path := OS.get_cache_dir().path_join("ten-paces-save-cache-%s-%s-%s-%s" % [label, OS.get_process_id(), Time.get_ticks_usec(), _root_sequence])
    _owned_roots.append(root_path)
    return root_path


func _write_bytes(path: String, bytes: PackedByteArray) -> bool:
    if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
        return false
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_buffer(bytes)
    file.flush()
    var error := file.get_error()
    file.close()
    return error == OK


func _encoded(codec, save_id: String, checkpoint_id: String, revision: int, run_state: Dictionary, combat_checkpoint: Dictionary = {}) -> Dictionary:
    var result: Dictionary = codec.encode(save_id, checkpoint_id, revision, run_state, combat_checkpoint)
    check(result.get("ok", false), "Fixture encoding succeeds: " + checkpoint_id)
    return result


func _new_run(seed: int = 83):
    var run = load("res://src/run/vertical_slice_run_state.gd").new()
    run.configure_opponents(load("res://src/run/vertical_slice_opponent_catalog.gd").new(), seed)
    run.start_new_run()
    var mastery := {}
    for id in STARTERS:
        mastery[id] = 3
    check(run.confirm_setup_loadout(STARTERS, mastery), "Configured run fixture accepts starter loadout")
    return run


func _planning_fixture() -> Dictionary:
    var run = _new_run()
    for _step in range(3):
        check(run.advance(), "Configured run fixture reaches combat")
    var board = load("res://scenes/run/vertical_slice_combat_bridge.tscn").instantiate()
    root.add_child(board)
    await process_frame
    var opponent: Dictionary = run.get_current_opponent()
    var binding: Dictionary = load("res://src/run/vertical_slice_opponent_runtime_binding.gd").new().build(opponent)
    var manual: String = opponent.signature_manual_id
    check(board.configure_vertical_slice_loadouts(
        STARTERS,
        run.get_progression_snapshot().mastery_by_manual,
        [manual],
        {manual: opponent.signature_star_seed},
        opponent.candidate_id,
        binding,
        {"name": opponent.working_name, "epithet": opponent.martial_identity},
        run.get_frozen_bimu_receipt()
    ), "Configured combat fixture accepts real first-duel binding")
    board.apply_vertical_slice_player_resources(run.get_player_run_resources())
    board.configure_checkpoint_identity(run.duel_index, int(run.export_snapshot().attempt_id))
    check(board.capture_planning_checkpoint(), "Configured combat fixture captures PLANNING boundary")
    var fixture := {"run": run.export_snapshot(), "combat": board.get_last_stable_checkpoint()}
    board.queue_free()
    await process_frame
    return fixture


func _verify_duplicate_validation_removed(fixture: Dictionary) -> void:
    var store = STORE.new(_new_root("counts"))
    var codec := CountingCodec.new()
    store.codec = codec
    var input_run: Dictionary = fixture.run.duplicate(true)
    var input_combat: Dictionary = fixture.combat.duplicate(true)
    codec.reset_counts()
    var first: Dictionary = store.replace_run("cache-run", "planning-0", input_run, input_combat)
    check(first.get("ok", false), "Cold replacement persists the real PLANNING checkpoint")
    check(codec.validate_calls == 1, "Cold replacement performs one full domain validation, got %s" % codec.validate_calls)
    check(codec.decode_calls == 0, "Encoded expected payload avoids duplicate decode during readback, got %s" % codec.decode_calls)

    input_run.current_screen = "MUTATED_AFTER_CALL"
    input_combat.phase = "MUTATED_AFTER_CALL"
    var owned: Dictionary = store.load_checkpoint()
    check(owned.get("ok", false) and owned.payload.run_state.current_screen == fixture.run.current_screen, "Store owns encoded input independently of caller mutation")
    owned.payload.run_state.current_screen = "MUTATED_RETURN"
    var reread: Dictionary = store.load_checkpoint()
    check(reread.get("ok", false) and reread.payload.run_state.current_screen == fixture.run.current_screen, "Every cached payload return is a deep copy")
    var internal_read: Dictionary = store._read("primary")
    if internal_read.get("source_bytes", PackedByteArray()).size() > 0:
        internal_read.source_bytes[0] = 0
    check(store._read("primary").get("ok", false), "Every cached raw-byte return owns an independent copy")

    codec.reset_counts()
    var changed: Dictionary = store.save_checkpoint("cache-run", "planning-1", fixture.run, fixture.combat)
    check(changed.get("ok", false) and changed.revision == first.revision + 1, "Changed checkpoint creates the next revision")
    check(codec.validate_calls == 1, "Warm changed save performs one full domain validation, got %s" % codec.validate_calls)
    check(codec.decode_calls == 0, "Warm changed save reuses exact validated bytes, got %s decodes" % codec.decode_calls)

    var physical_reads := {"count": 0}
    store.io_guard = func(operation: String, _path: String):
        if operation.begins_with("read_"):
            physical_reads.count += 1
        return true
    codec.reset_counts()
    var warm: Dictionary = store.load_checkpoint()
    check(warm.get("status") == "VALID_PRIMARY", "Warm cache load exposes validated primary")
    check(physical_reads.count >= 1, "Warm cache lookup still performs the guarded physical read")
    check(codec.decode_calls == 0 and codec.validate_calls == 0, "Warm exact-byte load avoids all domain decode work")
    store.io_guard = Callable()


func _verify_raw_bytes_and_physical_guards(fixture: Dictionary) -> void:
    var encoder := CODEC.new()
    var root_path := _new_root("raw")
    var store = STORE.new(root_path)
    var codec := CountingCodec.new()
    store.codec = codec
    var valid_replacement: Dictionary = _encoded(encoder, "utf8-�", "boundary-a", 1, fixture.run, fixture.combat)
    var valid_bytes: PackedByteArray = valid_replacement.text.to_utf8_buffer()
    check(_write_bytes(root_path.path_join("primary.json"), valid_bytes), "Writes legitimate UTF-8 replacement-character fixture")
    codec.reset_counts()
    check(store._read("primary").get("ok", false), "Legitimate U+FFFD UTF-8 bytes validate")
    check(codec.decode_calls == 1, "Cold legitimate UTF-8 bytes decode once")
    var invalid_bytes := valid_bytes.duplicate()
    var replacement_index := -1
    for index in range(invalid_bytes.size() - 2):
        if invalid_bytes[index] == 0xef and invalid_bytes[index + 1] == 0xbf and invalid_bytes[index + 2] == 0xbd:
            replacement_index = index
            break
    check(replacement_index >= 0, "Fixture contains encoded U+FFFD bytes")
    if replacement_index >= 0:
        invalid_bytes[replacement_index] = 0xff
        invalid_bytes[replacement_index + 1] = 0xfe
        invalid_bytes[replacement_index + 2] = 0xff
        check(_write_bytes(root_path.path_join("primary.json"), invalid_bytes), "Writes same-length invalid UTF-8 mutation")
        var invalid: Dictionary = store._read("primary")
        check(not invalid.get("ok", false) and invalid.status == "CORRUPT", "Invalid UTF-8 fails closed before JSON acceptance")
        check(codec.decode_calls == 1, "Invalid UTF-8 never aliases cached U+FFFD or reaches codec decode")
        var invalid_sequences := [
            PackedByteArray([0xc0, 0xaf, 0x20]),
            PackedByteArray([0xed, 0xa0, 0x80]),
            PackedByteArray([0xf5, 0x80, 0x80]),
            PackedByteArray([0xe2, 0x82, 0x20]),
        ]
        for invalid_sequence in invalid_sequences:
            var distinct_invalid := valid_bytes.duplicate()
            for offset in range(3):
                distinct_invalid[replacement_index + offset] = invalid_sequence[offset]
            check(_write_bytes(root_path.path_join("primary.json"), distinct_invalid), "Writes distinct same-length invalid UTF-8 mutation")
            var distinct_result: Dictionary = store._read("primary")
            check(not distinct_result.get("ok", false) and distinct_result.status == "CORRUPT", "Distinct invalid UTF-8 bytes cannot alias legitimate U+FFFD")
        check(codec.decode_calls == 1, "No invalid UTF-8 sequence reaches codec decode")
        check(_write_bytes(root_path.path_join("primary.json"), valid_bytes), "Restores legitimate UTF-8 bytes")
        check(store._read("primary").get("ok", false) and codec.decode_calls == 1, "Exact original UTF-8 bytes reuse the validated entry")

    var same_a: Dictionary = _encoded(encoder, "same-run", "same-size-a", 2, fixture.run, fixture.combat)
    var same_b: Dictionary = _encoded(encoder, "same-run", "same-size-b", 2, fixture.run, fixture.combat)
    var bytes_a: PackedByteArray = same_a.text.to_utf8_buffer()
    var bytes_b: PackedByteArray = same_b.text.to_utf8_buffer()
    check(bytes_a.size() == bytes_b.size(), "Same-length edit fixtures have identical byte length")
    check(_write_bytes(root_path.path_join("primary.json"), bytes_a), "Writes same-length source A")
    codec.reset_counts()
    check(store._read("primary").payload.checkpoint_id == "same-size-a", "Source A validates")
    check(_write_bytes(root_path.path_join("primary.json"), bytes_b), "Overwrites with same-length source B")
    var edited: Dictionary = store._read("primary")
    check(edited.get("ok", false) and edited.payload.checkpoint_id == "same-size-b", "Changed bytes with same length miss cache and fully validate")
    check(codec.decode_calls == 2, "Same-length byte edit causes a second decode")

    var guarded_root := _new_root("guards")
    var guarded_store = STORE.new(guarded_root)
    var guarded_codec := CountingCodec.new()
    guarded_store.codec = guarded_codec
    check(_write_bytes(guarded_root.path_join("primary.json"), bytes_a), "Writes physical-guard fixture")
    check(guarded_store._read("primary").get("ok", false), "Physical-guard fixture seeds cache")
    guarded_codec.reset_counts()
    guarded_store.io_guard = func(operation: String, _path: String): return operation != "read_primary"
    check(guarded_store.load_checkpoint().status == "IO_FAILURE", "Read guard failure wins over a cache hit")
    check(guarded_codec.decode_calls == 0, "Blocked physical read does not decode")
    guarded_store.io_guard = Callable()
    check(DirAccess.remove_absolute(guarded_root.path_join("primary.json")) == OK, "Deletes isolated cached slot fixture")
    check(guarded_store.load_checkpoint().status == "ABSENT", "Deleted physical slot is absent despite cache")
    check(DirAccess.make_dir_recursive_absolute(guarded_root.path_join("primary.json")) == OK, "Creates isolated directory-slot fixture")
    check(guarded_store.load_checkpoint().status == "IO_FAILURE", "Directory physical slot is IO failure despite cache")


func _verify_context_errors_and_eviction(fixture: Dictionary) -> void:
    var encoder := CODEC.new()
    var root_path := _new_root("context")
    var store = STORE.new(root_path)
    var codec := CountingCodec.new()
    store.codec = codec
    var encoded: Dictionary = _encoded(encoder, "context", "base", 1, fixture.run, fixture.combat)
    check(_write_bytes(root_path.path_join("primary.json"), encoded.text.to_utf8_buffer()), "Writes context fixture")
    check(store._read("primary").get("ok", false), "Base codec context validates")
    codec.context_suffix = "-changed"
    codec.reset_counts()
    check(store._read("primary").status == "INCOMPATIBLE", "Different content context cannot reuse validated bytes")
    check(store._read("primary").status == "INCOMPATIBLE" and codec.decode_calls == 2, "Incompatible results are never cached")
    codec.context_suffix = ""
    codec.reset_counts()
    check(store._read("primary").get("ok", false) and codec.decode_calls == 0, "Original context can still reuse its exact validated entry")

    var malformed := "{invalid".to_utf8_buffer()
    check(_write_bytes(root_path.path_join("malformed.json"), malformed), "Writes malformed JSON fixture")
    codec.reset_counts()
    check(not store._read("malformed").get("ok", false), "Malformed JSON is rejected")
    check(not store._read("malformed").get("ok", false) and codec.decode_calls == 2, "Malformed JSON errors are never cached")

    var future: Dictionary = JSON.parse_string(encoded.text)
    future.schema_version = 999
    check(_write_bytes(root_path.path_join("future.json"), JSON.stringify(future).to_utf8_buffer()), "Writes future-schema fixture")
    codec.reset_counts()
    check(store._read("future").status == "INCOMPATIBLE", "Future schema is incompatible")
    check(store._read("future").status == "INCOMPATIBLE" and codec.decode_calls == 2, "Future-schema incompatibility is never cached")

    var invalid_domain: Dictionary = JSON.parse_string(encoded.text)
    invalid_domain.run_state.duel_index = 999
    invalid_domain.erase("integrity_hash")
    invalid_domain.integrity_hash = encoder.digest(invalid_domain)
    check(_write_bytes(root_path.path_join("invalid_domain.json"), JSON.stringify(invalid_domain).to_utf8_buffer()), "Writes integrity-valid domain-invalid fixture")
    codec.reset_counts()
    check(not store._read("invalid_domain").get("ok", false), "Domain-invalid payload is rejected")
    check(not store._read("invalid_domain").get("ok", false) and codec.decode_calls == 2 and codec.validate_calls == 2, "Domain validation failures are never cached")

    var count_root := _new_root("entry-bound")
    var count_store = STORE.new(count_root)
    var count_codec := CountingCodec.new()
    count_store.codec = count_codec
    for index in range(4):
        var item: Dictionary = _encoded(encoder, "bounded", "entry-%s" % index, index + 1, fixture.run, fixture.combat)
        check(_write_bytes(count_root.path_join("entry%s.json" % index), item.text.to_utf8_buffer()), "Writes bounded entry %s" % index)
        check(count_store._read("entry%s" % index).get("ok", false), "Validates bounded entry %s" % index)
    count_codec.reset_counts()
    check(count_store._read("entry1").get("ok", false) and count_codec.decode_calls == 0, "Three-entry FIFO retains the second entry after fourth insert")
    check(count_store._read("entry0").get("ok", false) and count_codec.decode_calls == 1, "Three-entry FIFO deterministically evicts the oldest entry")
    check(count_store._read("entry2").get("ok", false) and count_codec.decode_calls == 1, "FIFO hit does not displace a newer retained entry")
    check(count_store._read("entry1").get("ok", false) and count_codec.decode_calls == 2, "Reinsert deterministically evicts the then-oldest entry")

    var byte_root := _new_root("byte-bound")
    var byte_store = STORE.new(byte_root)
    var byte_codec := CountingCodec.new()
    byte_store.codec = byte_codec
    var padding := " ".repeat(2800000)
    for index in range(3):
        var item: Dictionary = _encoded(encoder, "byte-bound", "large-%s" % index, index + 1, fixture.run, fixture.combat)
        var padded: PackedByteArray = (padding + item.text).to_utf8_buffer()
        check(padded.size() < CODEC.MAX_BYTES, "Each padded validated entry fits the codec byte bound")
        check(_write_bytes(byte_root.path_join("large%s.json" % index), padded), "Writes byte-bound entry %s" % index)
        check(byte_store._read("large%s" % index).get("ok", false), "Validates byte-bound entry %s" % index)
    byte_codec.reset_counts()
    check(byte_store._read("large1").get("ok", false) and byte_codec.decode_calls == 0, "Byte-bound FIFO retains the second large entry")
    check(byte_store._read("large0").get("ok", false) and byte_codec.decode_calls == 1, "Aggregate byte bound evicts the oldest large entry")
    check(byte_store._read("large2").get("ok", false) and byte_codec.decode_calls == 1, "Aggregate byte bound retains the newest large entry")
    check(byte_store._read("large1").get("ok", false) and byte_codec.decode_calls == 2, "Large-entry reinsertion preserves deterministic byte eviction")


func _verify_idempotency_recovery_and_pending(fixture: Dictionary) -> void:
    var recovery_root := _new_root("repair")
    var recovery = STORE.new(recovery_root)
    check(recovery.replace_run("repair", "planning", fixture.run, fixture.combat).get("ok", false), "Recovery fixture persists both slots")
    check(_write_bytes(recovery_root.path_join("primary.json"), "{corrupt-primary".to_utf8_buffer()), "Corrupts isolated primary for recovery")
    check(recovery.load_checkpoint().status == "RECOVERED_BACKUP", "Recovery fixture exposes validated backup")
    var repaired: Dictionary = recovery.save_checkpoint("repair", "planning", fixture.run, fixture.combat)
    check(repaired.get("ok", false) and not repaired.get("idempotent", false), "Recovered backup cannot acknowledge idempotency before primary repair")
    check(recovery.load_checkpoint().status == "VALID_PRIMARY", "Recovered backup save repairs and validates physical primary")

    var failed_root := _new_root("failed-repair")
    var failed_store = STORE.new(failed_root)
    check(failed_store.replace_run("failed-repair", "planning", fixture.run, fixture.combat).get("ok", false), "Failed-repair fixture persists both slots")
    check(_write_bytes(failed_root.path_join("primary.json"), "{corrupt-primary".to_utf8_buffer()), "Corrupts failed-repair primary")
    failed_store.io_guard = func(operation: String, _path: String): return operation != "rename_primary"
    var failed: Dictionary = failed_store.save_checkpoint("failed-repair", "planning", fixture.run, fixture.combat)
    check(not failed.get("ok", false) and failed.status == "IO_FAILURE", "Failed primary repair is not acknowledged")
    var pending_revision := int(failed.get("revision", 0))
    check(not failed_store.save_checkpoint("failed-repair", "different", fixture.run, fixture.combat).get("ok", false), "Pending repair rejects a different command")
    failed_store.io_guard = Callable()
    var retried: Dictionary = failed_store.save_checkpoint("failed-repair", "planning", fixture.run, fixture.combat)
    check(retried.get("ok", false) and retried.revision == pending_revision, "Pending repair retries the immutable revision")
    check(failed_store.load_checkpoint().status == "VALID_PRIMARY", "Successful retry leaves a validated primary")

    var changed_run = _new_run(84)
    var state_a: Dictionary = changed_run.export_snapshot()
    check(changed_run.advance(), "Changed-payload fixture advances to another stable run boundary")
    var state_b: Dictionary = changed_run.export_snapshot()
    var change_root := _new_root("changed-payload")
    var change_store = STORE.new(change_root)
    var a: Dictionary = change_store.replace_run("changed", "same-checkpoint", state_a)
    var b: Dictionary = change_store.save_checkpoint("changed", "same-checkpoint", state_b)
    check(a.get("ok", false) and b.get("ok", false) and b.revision == a.revision + 1 and not b.get("idempotent", false), "Changed normalized payload at the same checkpoint creates a revision")

    var generation_root := _new_root("generation")
    var generation = STORE.new(generation_root)
    var initial: Dictionary = generation.replace_run("generation", "start", state_a)
    check(initial.get("ok", false), "Generation fixture persists both slots")
    check(DirAccess.remove_absolute(generation_root.path_join("backup.json")) == OK, "Removes isolated generation backup")
    generation.io_guard = func(operation: String, _path: String): return operation != "write_backup"
    var incomplete_replace: Dictionary = generation.replace_run("generation", "start", state_a)
    check(not incomplete_replace.get("ok", false), "Replacement idempotency requires a freshly validated equal backup")
    generation.io_guard = Callable()
    var replace_retry: Dictionary = generation.replace_run("generation", "start", state_a)
    check(replace_retry.get("ok", false) and replace_retry.revision == incomplete_replace.revision, "Replacement retry preserves pending identity and revision")
    var retired: Dictionary = generation.retire_run("generation", "end")
    check(retired.get("ok", false), "Retirement persists both slots")
    check(DirAccess.remove_absolute(generation_root.path_join("backup.json")) == OK, "Removes isolated retirement backup")
    generation.io_guard = func(operation: String, _path: String): return operation != "write_backup"
    var incomplete_retire: Dictionary = generation.retire_run("generation", "end")
    check(not incomplete_retire.get("ok", false), "Retirement idempotency requires a freshly validated equal backup")
    generation.io_guard = Callable()
    var retire_retry: Dictionary = generation.retire_run("generation", "end")
    check(retire_retry.get("ok", false) and retire_retry.revision == incomplete_retire.revision, "Retirement retry preserves pending identity and revision")
    check(DirAccess.remove_absolute(generation_root.path_join("primary.json")) == OK, "Removes isolated retirement primary")
    generation.io_guard = func(operation: String, _path: String): return operation != "write_backup"
    var backup_only_retire: Dictionary = generation.retire_run("generation", "end")
    check(not backup_only_retire.get("ok", false), "Backup-only tombstone cannot acknowledge retirement without primary repair")
    generation.io_guard = Callable()
    var backup_only_retry: Dictionary = generation.retire_run("generation", "end")
    check(backup_only_retry.get("ok", false) and backup_only_retry.revision == backup_only_retire.revision, "Backup-only tombstone repair retains pending revision")
    var primary: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(generation_root.path_join("primary.json")))
    var backup: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(generation_root.path_join("backup.json")))
    check(primary == backup and not primary.active, "Acknowledged retirement leaves equal validated tombstones in both slots")


func _verify_exact_write_readback(fixture: Dictionary) -> void:
    var temp_root := _new_root("temp-readback")
    var temp_store = STORE.new(temp_root)
    var temp_mutated := {"done": false}
    temp_store.io_guard = func(operation: String, path: String):
        if operation == "read_backup_temp" and not temp_mutated.done:
            temp_mutated.done = true
            var bytes := FileAccess.get_file_as_bytes(path)
            bytes.append(0x20)
            _write_bytes(path, bytes)
        return true
    var temp_failed: Dictionary = temp_store.replace_run("readback-temp", "planning", fixture.run, fixture.combat)
    check(not temp_failed.get("ok", false) and temp_mutated.done, "Temporary readback rejects exact-byte drift even when JSON payload is unchanged")
    check(not FileAccess.file_exists(temp_root.path_join("primary.json")), "Temporary readback drift is never published to primary")
    temp_store.io_guard = Callable()
    var temp_retry: Dictionary = temp_store.replace_run("readback-temp", "planning", fixture.run, fixture.combat)
    check(temp_retry.get("ok", false) and temp_retry.revision == temp_failed.revision, "Temporary readback failure retries the immutable candidate")

    var destination_root := _new_root("destination-readback")
    var destination_store = STORE.new(destination_root)
    var backup_reads := {"count": 0, "mutated": false}
    destination_store.io_guard = func(operation: String, path: String):
        if operation == "read_backup":
            backup_reads.count += 1
            if not backup_reads.mutated and FileAccess.file_exists(path):
                backup_reads.mutated = true
                var bytes := FileAccess.get_file_as_bytes(path)
                bytes.append(0x20)
                _write_bytes(path, bytes)
        return true
    var destination_failed: Dictionary = destination_store.replace_run("readback-destination", "planning", fixture.run, fixture.combat)
    check(not destination_failed.get("ok", false) and backup_reads.mutated, "Destination readback rejects exact-byte drift after rename")
    check(not FileAccess.file_exists(destination_root.path_join("primary.json")), "Destination readback failure prevents primary publication")
    destination_store.io_guard = Callable()
    var destination_retry: Dictionary = destination_store.replace_run("readback-destination", "planning", fixture.run, fixture.combat)
    check(destination_retry.get("ok", false) and destination_retry.revision == destination_failed.revision, "Destination readback failure retries the immutable candidate")


func _verify_revision_upper_bound(fixture: Dictionary) -> void:
    var encoder := CODEC.new()
    var maximum_declared_revision := CODEC.MAX_SAFE_INTEGER
    var maximum_transport_revision := maximum_declared_revision - 1
    var unroundtrippable: Dictionary = encoder.encode("revision-bound", "declared-maximum", maximum_declared_revision, {}, {}, false)
    check(not unroundtrippable.get("ok", false) and unroundtrippable.get("status", "") == "CORRUPT", "Declared maximum that Godot cannot round-trip fails before cache seeding")
    var beyond_bound: Dictionary = encoder.encode("revision-bound", "beyond-maximum", maximum_declared_revision + 1, {}, {}, false)
    check(not beyond_bound.get("ok", false) and beyond_bound.get("status", "") == "CORRUPT", "Revision beyond the shared codec integer bound fails closed")
    for operation_value in ["save", "replace", "retire"]:
        var operation := str(operation_value)
        var root_path := _new_root("revision-bound-" + operation)
        var save_id := "revision-bound-" + operation
        var encoded: Dictionary = _encoded(encoder, save_id, "last-valid", maximum_transport_revision, fixture.run, fixture.combat)
        var last_valid_bytes: PackedByteArray = encoded.text.to_utf8_buffer()
        var seed_readback: Dictionary = encoder.decode(encoded.text)
        check(seed_readback.get("ok", false) and seed_readback.payload.revision == maximum_transport_revision, "Transport-boundary fixture is cold-readable before " + operation)
        check(_write_bytes(root_path.path_join("primary.json"), last_valid_bytes), "Writes transport-boundary primary fixture for " + operation)
        check(_write_bytes(root_path.path_join("backup.json"), last_valid_bytes), "Writes transport-boundary backup fixture for " + operation)
        var store = STORE.new(root_path)
        var result: Dictionary
        match operation:
            "save":
                result = store.save_checkpoint(save_id, "next-save", fixture.run, fixture.combat)
            "replace":
                result = store.replace_run(save_id + "-replacement", "next-replace", fixture.run, fixture.combat)
            "retire":
                result = store.retire_run(save_id, "next-retire")
        check(not result.get("ok", false) and result.get("status", "") == "CORRUPT", "Non-roundtrippable next revision fails before acknowledging " + operation)
        check(FileAccess.get_file_as_bytes(root_path.path_join("primary.json")) == last_valid_bytes, "Rejected next revision preserves the last valid primary for " + operation)
        check(FileAccess.get_file_as_bytes(root_path.path_join("backup.json")) == last_valid_bytes, "Rejected next revision preserves the last valid backup for " + operation)
        var cold: Dictionary = STORE.new(root_path).load_checkpoint()
        check(cold.get("ok", false) and cold.get("status", "") == "VALID_PRIMARY" and cold.payload.revision == maximum_transport_revision, "Fresh store cold-read keeps the last transport-valid revision after " + operation)


func _run() -> void:
    var fixture: Dictionary = await _planning_fixture()
    if not failures.is_empty():
        _finish()
        return
    _verify_duplicate_validation_removed(fixture)
    _verify_raw_bytes_and_physical_guards(fixture)
    _verify_context_errors_and_eviction(fixture)
    _verify_idempotency_recovery_and_pending(fixture)
    _verify_exact_write_readback(fixture)
    _verify_revision_upper_bound(fixture)
    _finish()


func _remove_owned_tree(path: String, owned_root: String) -> bool:
    if path != owned_root and not path.begins_with(owned_root + "/"):
        return false
    if not DirAccess.dir_exists_absolute(path):
        return true
    var directory := DirAccess.open(path)
    if directory == null:
        return false
    directory.list_dir_begin()
    var entry := directory.get_next()
    while not entry.is_empty():
        var child := path.path_join(entry)
        var removed := _remove_owned_tree(child, owned_root) if directory.current_is_dir() else DirAccess.remove_absolute(child) == OK
        if not removed:
            directory.list_dir_end()
            return false
        entry = directory.get_next()
    directory.list_dir_end()
    return DirAccess.remove_absolute(path) == OK


func _cleanup_owned_roots() -> bool:
    var safe_prefix := OS.get_cache_dir().path_join("ten-paces-save-cache-").simplify_path()
    for root_path in _owned_roots:
        var owned_root := root_path.simplify_path()
        if not owned_root.begins_with(safe_prefix) or not _remove_owned_tree(owned_root, owned_root):
            return false
    return true


func _finish() -> void:
    if failures.is_empty():
        check(_cleanup_owned_roots(), "Removes only exact test-owned cache roots after a successful run")
        if failures.is_empty():
            print("RUN_SAVE_CACHE_CLEANUP: PASS (%s exact roots)" % _owned_roots.size())
    print("RUN_SAVE_CACHE: %s (%s failures)" % ["PASS" if failures.is_empty() else "FAIL", failures.size()])
    quit(0 if failures.is_empty() else 1)
