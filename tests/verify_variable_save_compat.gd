extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
    call_deferred("_run")
func check(value: bool, label: String) -> void:
    if not value:
        failures.append(label)
        push_error(label)
func _run() -> void:
    var codec = load("res://src/run/run_checkpoint_codec.gd").new()
    var unknown := {"schema_version": 2}
    check(codec.decode(JSON.stringify(unknown)).status == "CORRUPT", "Known schema2 malformed fields are corrupt, not unsupported")
    var legacy_identity: String = codec.content_identity()
    check(not legacy_identity.is_empty(), "Legacy content identity resolves")
    var root_path := OS.get_cache_dir().path_join("ten-paces-variable-save-%s-%s" % [OS.get_process_id(), Time.get_ticks_usec()])
    DirAccess.make_dir_recursive_absolute(root_path)
    var file := FileAccess.open(root_path.path_join("active.json"), FileAccess.WRITE)
    file.store_string('{"schema_version":2,"slot":"../../outside"}')
    file.close()
    var store = load("res://src/run/run_save_store.gd").new(root_path)
    check(store.load_checkpoint().status == "CORRUPT", "Invalid active pointer must not silently fall back to legacy")
    var missing_pointer := {"schema_version": 2, "slot": "v2_" + "0".repeat(64)}
    missing_pointer["integrity_hash"] = codec.digest(missing_pointer)
    file = FileAccess.open(root_path.path_join("active.json"), FileAccess.WRITE)
    file.store_string(JSON.stringify(missing_pointer))
    file.close()
    check(store.load_checkpoint().status == "CORRUPT", "Missing pointer target is corruption, not absent save")
    await _roundtrip_and_faults(root_path + "-valid", codec)
    print("VARIABLE_SAVE_COMPAT: %s" % ("PASS" if failures.is_empty() else "FAIL"))
    quit(0 if failures.is_empty() else 1)

func _roundtrip_and_faults(root_path: String, codec) -> void:
    var legacy = load("res://src/run/vertical_slice_run_state.gd").new()
    legacy.configure_opponents(load("res://src/run/vertical_slice_opponent_catalog.gd").new(), 42)
    legacy.start_new_run()
    var store = load("res://src/run/run_save_store.gd").new(root_path)
    var legacy_result: Dictionary = store.replace_run("legacy", "legacy-1", legacy.export_snapshot())
    check(legacy_result.ok, "Create v1 fixture with original codec semantics")
    if not legacy_result.ok: return
    var old_primary := FileAccess.get_file_as_bytes(root_path.path_join("primary.json"))
    var old_backup := FileAccess.get_file_as_bytes(root_path.path_join("backup.json"))
    var run = load("res://src/run/vertical_slice_run_state.gd").new()
    check(run.start_new_variable_run(12345, "variable"), "Create v2 resolved roster")
    var source: Dictionary = run.export_snapshot()
    var encoded: Dictionary = codec.encode("variable", "v2-1", 1, source)
    check(encoded.ok, "Encode v2 genuine snapshot")
    if not encoded.ok:
        print(encoded)
        return
    check(encoded.payload.schema_version == 2, "V2 envelope dispatch")
    check(encoded.payload.content_identity != codec.content_identity(), "Independent v2 content identity")
    check(codec.decode(encoded.text).ok, "V2 strict JSON roundtrip")
    check(not codec.encode("wrong-save", "v2-1", 1, source).ok, "Reject save/roster identity mismatch")
    for field in ["ruleset_id", "roster_version", "roster_seed", "resolved_encounters", "roster_digest"]:
        var broken: Dictionary = encoded.payload.duplicate(true)
        broken[field] = null
        broken.erase("integrity_hash")
        broken["integrity_hash"] = codec.digest(broken)
        check(not codec.decode(JSON.stringify(broken)).ok, "Strict envelope rejects malformed " + field)
    var failed := false
    store.io_guard = func(op: String, _path: String) -> bool: return op != "rename_active"
    var first: Dictionary = store.replace_run("variable", "v2-1", source)
    failed = not first.ok
    check(failed and first.status == "IO_FAILURE", "Pointer switch fault is unacknowledged")
    check(store.load_checkpoint().get("payload", {}).get("save_id") == "legacy", "Failed switch retains active legacy")
    check(FileAccess.get_file_as_bytes(root_path.path_join("primary.json")) == old_primary and FileAccess.get_file_as_bytes(root_path.path_join("backup.json")) == old_backup, "V2 failure preserves both original v1 files")
    store.io_guard = Callable()
    var saved: Dictionary = store.replace_run("variable", "v2-1", source)
    check(saved.ok and saved.payload.schema_version == 2, "Retry saves same v2 roster and switches pointer")
    if not saved.ok: return
    check(saved.payload == first.pending_payload, "Retry envelope bytes and time remain immutable")
    var fresh = load("res://src/run/run_save_store.gd").new(root_path)
    check(fresh.load_checkpoint().payload == saved.payload, "Fresh store loads persisted v2 without RNG")
    check(FileAccess.get_file_as_bytes(root_path.path_join("primary.json")) == old_primary and FileAccess.get_file_as_bytes(root_path.path_join("backup.json")) == old_backup, "V2 success preserves original legacy bytes")
    check(FileAccess.file_exists(root_path.path_join("primary_evidence_" + FileAccess.get_sha256(root_path.path_join("primary.json")) + ".json")), "Original legacy has hash-verified archive")
    for operation in ["write_active", "read_active_temp", "rename_active"]:
        var before := FileAccess.get_file_as_bytes(root_path.path_join("active.json"))
        fresh.io_guard = func(op: String, _path: String) -> bool: return op != operation
        var result: Dictionary = fresh.save_checkpoint("variable", "next-" + operation, source)
        check(not result.ok and result.status == "IO_FAILURE", "Injected pointer fault " + operation)
        check(FileAccess.get_file_as_bytes(root_path.path_join("active.json")) == before, "Fault keeps previous pointer " + operation)
        fresh.io_guard = Callable()
        var retry: Dictionary = fresh.save_checkpoint("variable", "next-" + operation, source)
        check(retry.ok and retry.payload == result.pending_payload, "Fault retry retains exact roster " + operation)
    var evidence_name := "v2_" + "f".repeat(64) + ".json"
    var evidence_file := FileAccess.open(root_path.path_join(evidence_name), FileAccess.WRITE)
    evidence_file.store_string("{unknown-user-evidence")
    evidence_file.close()
    var outsider := source.duplicate(true)
    var outsider_run = load("res://src/run/vertical_slice_run_state.gd").new()
    outsider_run.start_new_variable_run(99, "other-save")
    outsider = outsider_run.export_snapshot()
    var outsider_encoded: Dictionary = codec.encode("other-save", "other", 1, outsider)
    var outsider_name: String = "v2_" + codec.digest(outsider_encoded.payload) + ".json"
    var outsider_file := FileAccess.open(root_path.path_join(outsider_name), FileAccess.WRITE)
    outsider_file.store_string(outsider_encoded.text)
    outsider_file.close()
    for index in range(8): check(fresh.save_checkpoint("variable", "retention-%d" % index, source).ok, "Retention write succeeds")
    var own_revisions := 0
    for name in DirAccess.get_files_at(root_path):
        if not name.begins_with("v2_") or name.ends_with("_temp.json"): continue
        var candidate: Dictionary = codec.decode(FileAccess.get_file_as_string(root_path.path_join(name)))
        if candidate.ok and candidate.payload.save_id == "variable": own_revisions += 1
    check(own_revisions == 3, "Successful v2 history is bounded to initial, previous, active")
    check(FileAccess.get_file_as_string(root_path.path_join(evidence_name)) == "{unknown-user-evidence", "Unknown or corrupt evidence survives cleanup")
    check(FileAccess.get_file_as_string(root_path.path_join(outsider_name)) == outsider_encoded.text, "Other save generation survives cleanup")
    var names_before := DirAccess.get_files_at(root_path)
    fresh.io_guard = func(op: String, _path: String) -> bool: return op != "write_primary"
    check(not fresh.save_checkpoint("variable", "retention-failure", source).ok, "Failed save never cleans history")
    check(DirAccess.get_files_at(root_path) == names_before, "Failed save preserves all files")
    fresh.io_guard = Callable()
    check(fresh.save_checkpoint("variable", "retention-failure", source).ok, "Retry after retention failure")
    fresh.io_guard = func(op: String, _path: String) -> bool: return not op.begins_with("cleanup_")
    check(fresh.save_checkpoint("variable", "cleanup-denied", source).ok, "Cleanup failure does not invalidate acknowledged save")
    fresh.io_guard = Callable()
    check(fresh.save_checkpoint("variable", "cleanup-resumed", source).ok, "Later acknowledged write resumes bounded cleanup")
    check(fresh.retire_run("variable", "retire").ok, "V2 retirement writes schema2 tombstone")
    var retired: Dictionary = fresh.load_checkpoint()
    check(retired.status == "ABSENT" and retired.retired and retired.payload.schema_version == 2, "Retirement cannot revive original v1 on reload")
    check(FileAccess.get_file_as_bytes(root_path.path_join("primary.json")) == old_primary, "Retirement preserves old v1 bytes")
