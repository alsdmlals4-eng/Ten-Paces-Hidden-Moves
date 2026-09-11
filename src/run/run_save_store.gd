class_name RunSaveStore
extends RefCounted

const CODEC := preload("res://src/run/run_checkpoint_codec.gd")
const CACHE_MAX_ENTRIES := 3
var root_path: String
var codec = CODEC.new()
# Optional operation guard for bounded injected file faults. It cannot supply success.
var io_guard: Callable
var _pending: Dictionary = {}
var _validated_cache: Array[Dictionary] = []
var _validated_cache_bytes := 0

func _init(path: String = "user://run_checkpoint") -> void:
    root_path = path

func _allowed(operation: String, path: String) -> bool:
    return not io_guard.is_valid() or bool(io_guard.call(operation, path))

func _cache_context() -> Dictionary:
    return {
        "schema_version": CODEC.SCHEMA_VERSION,
        "semantic_contract_version": CODEC.SEMANTIC_CONTRACT_VERSION,
        "content_identity": codec.content_identity(),
        "variable_content_identity": codec.content_identity_for_schema(CODEC.VARIABLE_SCHEMA_VERSION),
    }

func _cached(bytes: PackedByteArray) -> Dictionary:
    var context := _cache_context()
    if context.content_identity.is_empty(): return {}
    for entry in _validated_cache:
        if entry.context == context and entry.source_bytes == bytes:
            return {
                "ok": true,
                "status": "VALID",
                "payload": entry.payload.duplicate(true),
                "source_bytes": entry.source_bytes.duplicate(),
                "source_text": str(entry.source_text),
            }
    return {}

func _remember_validated(bytes: PackedByteArray, text: String, payload: Dictionary) -> void:
    var context := _cache_context()
    if context.content_identity.is_empty() or bytes.size() > CODEC.MAX_BYTES: return
    for entry in _validated_cache:
        if entry.context == context and entry.source_bytes == bytes:
            return
    while not _validated_cache.is_empty() and (_validated_cache.size() >= CACHE_MAX_ENTRIES or _validated_cache_bytes + bytes.size() > CODEC.MAX_BYTES):
        var evicted: Dictionary = _validated_cache.pop_front()
        _validated_cache_bytes -= int(evicted.source_bytes.size())
    if _validated_cache.size() >= CACHE_MAX_ENTRIES or _validated_cache_bytes + bytes.size() > CODEC.MAX_BYTES: return
    _validated_cache.append({
        "context": context.duplicate(true),
        "source_bytes": bytes.duplicate(),
        "source_text": text,
        "payload": payload.duplicate(true),
    })
    _validated_cache_bytes += bytes.size()

func _continuation(value: int) -> bool:
    return value >= 0x80 and value <= 0xbf

func _valid_utf8(bytes: PackedByteArray) -> bool:
    var index := 0
    while index < bytes.size():
        var first: int = bytes[index]
        if first <= 0x7f:
            index += 1
            continue
        if first >= 0xc2 and first <= 0xdf:
            if index + 1 >= bytes.size() or not _continuation(bytes[index + 1]): return false
            index += 2
            continue
        if first >= 0xe0 and first <= 0xef:
            if index + 2 >= bytes.size() or not _continuation(bytes[index + 2]): return false
            var second: int = bytes[index + 1]
            if first == 0xe0:
                if second < 0xa0 or second > 0xbf: return false
            elif first == 0xed:
                if second < 0x80 or second > 0x9f: return false
            elif not _continuation(second):
                return false
            index += 3
            continue
        if first >= 0xf0 and first <= 0xf4:
            if index + 3 >= bytes.size() or not _continuation(bytes[index + 2]) or not _continuation(bytes[index + 3]): return false
            var second: int = bytes[index + 1]
            if first == 0xf0:
                if second < 0x90 or second > 0xbf: return false
            elif first == 0xf4:
                if second < 0x80 or second > 0x8f: return false
            elif not _continuation(second):
                return false
            index += 4
            continue
        return false
    return true

func _read(slot: String) -> Dictionary:
    var path := root_path.path_join(slot + ".json")
    if not FileAccess.file_exists(path):
        if DirAccess.dir_exists_absolute(path): return CODEC.error("IO_FAILURE", "Save slot is a directory")
        return CODEC.error("ABSENT", "No save file")
    if not _allowed("read_" + slot, path): return CODEC.error("IO_FAILURE", "Read blocked")
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null: return CODEC.error("IO_FAILURE", "Cannot open save")
    var length := file.get_length()
    if length > CODEC.MAX_BYTES:
        file.close()
        return CODEC.error("CORRUPT", "Save exceeds size bound")
    var bytes := file.get_buffer(length)
    var read_error := file.get_error()
    file.close()
    if bytes.size() != length or (read_error != OK and read_error != ERR_FILE_EOF): return CODEC.error("IO_FAILURE", "Cannot read complete save")
    if not _valid_utf8(bytes): return CODEC.error("CORRUPT", "Save is not canonical UTF-8")
    var text := bytes.get_string_from_utf8()
    if text.to_utf8_buffer() != bytes: return CODEC.error("CORRUPT", "Save is not roundtrippable UTF-8")
    var cached := _cached(bytes)
    if not cached.is_empty(): return cached
    var decoded: Dictionary = codec.decode(text)
    if not decoded.get("ok", false): return decoded
    _remember_validated(bytes, text, decoded.payload)
    return {
        "ok": true,
        "status": decoded.status,
        "payload": decoded.payload.duplicate(true),
        "source_bytes": bytes.duplicate(),
        "source_text": text,
    }

func load_checkpoint() -> Dictionary:
    var pointer := _read_pointer()
    if pointer.status != "ABSENT":
        if not pointer.ok: return pointer
        var resolved := _read(pointer.slot)
        if resolved.status == "ABSENT": return CODEC.error("CORRUPT", "Active pointer target is missing")
        if not resolved.ok: return resolved
        if int(resolved.payload.schema_version) != CODEC.VARIABLE_SCHEMA_VERSION or pointer.slot != "v2_" + CODEC.digest(resolved.payload): return CODEC.error("CORRUPT", "Active pointer target mismatch")
        return _loaded(resolved.payload, "VALID_PRIMARY")
    var primary := _read("primary")
    return _load_from_primary(primary)

func _load_from_primary(primary: Dictionary) -> Dictionary:
    if primary.ok:
        return _loaded(primary.payload, "VALID_PRIMARY")
    if primary.status in ["INCOMPATIBLE", "IO_FAILURE"]: return primary
    var backup := _read("backup")
    if backup.ok: return _loaded(backup.payload, "RECOVERED_BACKUP")
    if backup.status in ["INCOMPATIBLE", "IO_FAILURE"]: return backup
    if primary.status == "ABSENT" and backup.status == "ABSENT": return CODEC.error("ABSENT", "No checkpoint")
    return CODEC.error("CORRUPT", "Neither save slot validates")

func _loaded(payload: Dictionary, status: String) -> Dictionary:
    if not payload.active: return {"ok": true, "status": "ABSENT", "retired": true, "payload": payload.duplicate(true)}
    return {"ok": true, "status": status, "payload": payload.duplicate(true)}

func save_checkpoint(save_id: String, checkpoint_id: String, run_state: Dictionary, combat_checkpoint: Dictionary = {}) -> Dictionary:
    return _save(save_id, checkpoint_id, run_state, combat_checkpoint, true, false)

func replace_run(save_id: String, checkpoint_id: String, run_state: Dictionary, combat_checkpoint: Dictionary = {}) -> Dictionary:
    return _save(save_id, checkpoint_id, run_state, combat_checkpoint, true, true)

func retire_run(save_id: String, checkpoint_id: String) -> Dictionary:
    return _save(save_id, checkpoint_id, {}, {}, false, true)

func _matches_request(payload: Dictionary, save_id: String, checkpoint_id: String, run_state: Dictionary, combat_checkpoint: Dictionary, active: bool) -> bool:
    return (
        payload.save_id == save_id
        and payload.checkpoint_id == checkpoint_id
        and payload.active == active
        and CODEC.normalized(payload.run_state) == CODEC.normalized(run_state)
        and CODEC.normalized(payload.combat_checkpoint) == CODEC.normalized(combat_checkpoint)
    )

func _physical_idempotent(primary: Dictionary, save_id: String, checkpoint_id: String, run_state: Dictionary, combat_checkpoint: Dictionary, active: bool, replace: bool) -> Dictionary:
    if not primary.get("ok", false) or not _matches_request(primary.payload, save_id, checkpoint_id, run_state, combat_checkpoint, active): return {}
    if replace:
        var backup := _read("backup")
        if not backup.get("ok", false) or backup.payload != primary.payload: return {}
    return {"ok": true, "status": "SAVED", "revision": primary.payload.revision, "payload": primary.payload.duplicate(true), "idempotent": true}

func _save(save_id: String, checkpoint_id: String, run_state: Dictionary, combat_checkpoint: Dictionary, active: bool, replace: bool) -> Dictionary:
    if run_state.get("ruleset_id", "") == CODEC.VARIABLE_RULESET_ID or (not active and FileAccess.file_exists(root_path.path_join("active.json"))):
        return _save_variable(save_id, checkpoint_id, run_state, combat_checkpoint, active, replace)
    if FileAccess.file_exists(root_path.path_join("active.json")): return CODEC.error("INCOMPATIBLE", "Legacy writer cannot replace variable save")
    if not CODEC.json_safe([run_state, combat_checkpoint], 0, [0]): return CODEC.error("CORRUPT", "Unsupported payload")
    var identity := CODEC.digest({"save_id": save_id, "checkpoint_id": checkpoint_id, "run_state": run_state, "combat_checkpoint": combat_checkpoint, "active": active, "replace": replace})
    if not _pending.is_empty() and _pending.identity != identity:
        return CODEC.error("IO_FAILURE", "Retry the pending immutable checkpoint before another command")
    var physical_primary := _read("primary")
    var current := _load_from_primary(physical_primary)
    if not replace and current.status in ["INCOMPATIBLE", "IO_FAILURE", "CORRUPT"]: return current
    var previous: Dictionary = current.get("payload", {})
    if not replace and not previous.is_empty() and (previous.save_id != save_id or not previous.active):
        return CODEC.error("INCOMPATIBLE", "Generation replacement requires explicit operation")
    if _pending.is_empty():
        var idempotent := _physical_idempotent(physical_primary, save_id, checkpoint_id, run_state, combat_checkpoint, active, replace)
        if not idempotent.is_empty(): return idempotent
        var revision := int(previous.get("revision", 0)) + 1
        var encoded: Dictionary = codec.encode(save_id, checkpoint_id, revision, run_state, combat_checkpoint, active)
        if not encoded.ok: return encoded
        var encoded_bytes: PackedByteArray = encoded.text.to_utf8_buffer()
        _remember_validated(encoded_bytes, encoded.text, encoded.payload)
        _pending = {"identity": identity, "encoded": {"text": str(encoded.text), "payload": encoded.payload.duplicate(true)}, "replace": replace}
    var envelope: Dictionary = _pending.encoded.payload
    var failed := CODEC.error("IO_FAILURE", "Checkpoint not acknowledged; retry this unchanged payload")
    failed["revision"] = envelope.revision
    failed["pending_payload"] = envelope.duplicate(true)
    if not _allowed("mkdir", root_path) or DirAccess.make_dir_recursive_absolute(root_path) != OK: return failed
    # Preserve unreadable evidence before replacing either slot. Valid saves need no archive.
    for slot in ["primary", "backup"]:
        var inspected := _read(slot)
        if inspected.status == "IO_FAILURE": return failed
        if inspected.status in ["CORRUPT", "INCOMPATIBLE"] and not _preserve_evidence(slot): return failed
    if replace:
        if not _write_slot("backup", _pending.encoded.text, envelope): return failed
    else:
        var primary := _read("primary")
        if primary.ok:
            if not _write_slot("backup", primary.source_text, primary.payload): return failed
        elif not _read("backup").ok:
            if not _write_slot("backup", _pending.encoded.text, envelope): return failed
    if not _write_slot("primary", _pending.encoded.text, envelope): return failed
    var primary_check := _read("primary")
    if not primary_check.ok or primary_check.payload != envelope: return failed
    if replace:
        var backup_check := _read("backup")
        if not backup_check.ok or backup_check.payload != envelope: return failed
    _pending.clear()
    return {"ok": true, "status": "SAVED", "revision": envelope.revision, "payload": envelope.duplicate(true)}

func _write_slot(slot: String, text: String, expected_payload: Dictionary) -> bool:
    var temp := root_path.path_join(slot + "_temp.json")
    if slot.begins_with("v2_") and not _allowed("write_primary", temp): return false
    if not _allowed("write_" + slot, temp): return false
    var file := FileAccess.open(temp, FileAccess.WRITE)
    if file == null: return false
    var expected_bytes := text.to_utf8_buffer()
    file.store_buffer(expected_bytes)
    file.flush()
    var error := file.get_error()
    file.close()
    if error != OK: return false
    var readback := _read(slot + "_temp")
    if not readback.ok or readback.source_bytes != expected_bytes or readback.payload != expected_payload: return false
    var destination := root_path.path_join(slot + ".json")
    if not _allowed("rename_" + slot, destination): return false
    if DirAccess.rename_absolute(temp, destination) != OK: return false
    var destination_readback := _read(slot)
    return destination_readback.ok and destination_readback.source_bytes == expected_bytes and destination_readback.payload == expected_payload

func _preserve_evidence(slot: String) -> bool:
    var source := root_path.path_join(slot + ".json")
    if not _allowed("preserve_" + slot, source): return false
    var hash := FileAccess.get_sha256(source)
    if hash.is_empty(): return false
    var destination := root_path.path_join(slot + "_evidence_" + hash + ".json")
    if FileAccess.file_exists(destination): return FileAccess.get_sha256(destination) == hash
    return DirAccess.copy_absolute(source, destination) == OK and FileAccess.get_sha256(destination) == hash

# V2 revisions are immutable files. Only this small, strictly validated pointer is
# switched, after the entire new checkpoint has survived flush and readback.
func _read_pointer(slot: String = "active") -> Dictionary:
    var path := root_path.path_join(slot + ".json")
    if not FileAccess.file_exists(path):
        if DirAccess.dir_exists_absolute(path): return CODEC.error("IO_FAILURE", "Active pointer is a directory")
        return CODEC.error("ABSENT", "No active pointer")
    if not _allowed("read_" + slot, path): return CODEC.error("IO_FAILURE", "Pointer read blocked")
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null: return CODEC.error("IO_FAILURE", "Cannot read pointer")
    if file.get_length() > 1024:
        file.close()
        return CODEC.error("CORRUPT", "Pointer exceeds bound")
    var length := file.get_length()
    var bytes := file.get_buffer(length)
    file.close()
    if bytes.size() != length or not _valid_utf8(bytes): return CODEC.error("CORRUPT", "Malformed pointer encoding")
    var text := bytes.get_string_from_utf8()
    var cursor := [0]
    if not codec._strict_value(text, cursor, 0, [0]): return CODEC.error("CORRUPT", "Malformed pointer JSON")
    codec._skip_space(text, cursor)
    if cursor[0] != text.length(): return CODEC.error("CORRUPT", "Trailing pointer content")
    var parsed = JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY or parsed.size() != 3 or not parsed.has("schema_version") or not parsed.has("slot") or not parsed.has("integrity_hash"): return CODEC.error("CORRUPT", "Malformed pointer fields")
    if not CODEC.integer(parsed.schema_version, 1): return CODEC.error("CORRUPT", "Malformed pointer version")
    if parsed.schema_version != 2: return CODEC.error("INCOMPATIBLE", "Unknown pointer version")
    if typeof(parsed.slot) != TYPE_STRING or RegEx.create_from_string("^v2_[0-9a-f]{64}$").search(parsed.slot) == null: return CODEC.error("CORRUPT", "Untrusted pointer path")
    if typeof(parsed.integrity_hash) != TYPE_STRING or parsed.integrity_hash != CODEC.digest({"schema_version": 2, "slot": parsed.slot}): return CODEC.error("CORRUPT", "Pointer integrity mismatch")
    return {"ok": true, "status": "VALID", "slot": parsed.slot, "source_bytes": bytes}

func _switch_pointer(slot: String) -> bool:
    var payload := {"schema_version": 2, "slot": slot}
    payload["integrity_hash"] = CODEC.digest(payload)
    var bytes := JSON.stringify(payload).to_utf8_buffer()
    var temp := root_path.path_join("active_temp.json")
    if not _allowed("write_active", temp): return false
    var file := FileAccess.open(temp, FileAccess.WRITE)
    if file == null: return false
    file.store_buffer(bytes)
    file.flush()
    var write_error := file.get_error()
    file.close()
    if write_error != OK: return false
    var readback := _read_pointer("active_temp")
    if not readback.ok or readback.source_bytes != bytes: return false
    var destination := root_path.path_join("active.json")
    if FileAccess.file_exists(destination) and not _read_pointer().ok and not _preserve_evidence("active"): return false
    if not _allowed("rename_active", destination) or DirAccess.rename_absolute(temp, destination) != OK: return false
    readback = _read_pointer()
    return readback.ok and readback.source_bytes == bytes

func _save_variable(save_id: String, checkpoint_id: String, run_state: Dictionary, combat_checkpoint: Dictionary, active: bool, replace: bool) -> Dictionary:
    if not CODEC.json_safe([run_state, combat_checkpoint], 0, [0]): return CODEC.error("CORRUPT", "Unsupported payload")
    var identity := CODEC.digest({"save_id": save_id, "checkpoint_id": checkpoint_id, "run_state": run_state, "combat_checkpoint": combat_checkpoint, "active": active, "replace": replace})
    if not _pending.is_empty() and _pending.identity != identity: return CODEC.error("IO_FAILURE", "Retry pending immutable checkpoint")
    var current := load_checkpoint()
    if current.status == "IO_FAILURE" or (not replace and current.status in ["INCOMPATIBLE", "CORRUPT"]): return current
    var previous: Dictionary = current.get("payload", {})
    if not replace and not previous.is_empty() and (previous.save_id != save_id or not previous.active): return CODEC.error("INCOMPATIBLE", "Generation replacement requires explicit operation")
    if _pending.is_empty():
        if not previous.is_empty() and int(previous.schema_version) == 2 and _matches_request(previous, save_id, checkpoint_id, run_state, combat_checkpoint, active):
            return {"ok": true, "status": "SAVED", "revision": previous.revision, "payload": previous.duplicate(true), "idempotent": true}
        var encoded: Dictionary = codec.encode(save_id, checkpoint_id, int(previous.get("revision", 0)) + 1, run_state, combat_checkpoint, active, CODEC.VARIABLE_SCHEMA_VERSION)
        if not encoded.ok: return encoded
        _pending = {"identity": identity, "encoded": encoded, "replace": replace}
    var envelope: Dictionary = _pending.encoded.payload
    var failed := CODEC.error("IO_FAILURE", "Checkpoint not acknowledged; retry unchanged payload")
    failed["revision"] = envelope.revision
    failed["pending_payload"] = envelope.duplicate(true)
    if not _allowed("mkdir", root_path) or DirAccess.make_dir_recursive_absolute(root_path) != OK: return failed
    # Legacy originals and their byte-identical archives remain available to v1 builds.
    for legacy in ["primary", "backup"]:
        if FileAccess.file_exists(root_path.path_join(legacy + ".json")) and not _preserve_evidence(legacy): return failed
    var slot := "v2_" + CODEC.digest(envelope)
    var existing := _read(slot)
    if existing.status == "ABSENT":
        if not _write_slot(slot, _pending.encoded.text, envelope): return failed
    elif not existing.ok or existing.payload != envelope:
        return failed
    if not _switch_pointer(slot): return failed
    var readback := load_checkpoint()
    if not readback.ok or readback.get("payload", {}) != envelope: return failed
    _pending.clear()
    _cleanup_variable_history(envelope)
    return {"ok": true, "status": "SAVED", "revision": envelope.revision, "payload": envelope.duplicate(true)}

# Retention touches only strict, canonical v2 checkpoints of this save identity.
# Cleanup is best effort after acknowledgment; legacy, corrupt, foreign and
# unrecognized files remain evidence and cannot become deletion candidates.
func _cleanup_variable_history(active_payload: Dictionary) -> void:
    var pointer := _read_pointer()
    var active_slot := "v2_" + CODEC.digest(active_payload)
    if not pointer.ok or pointer.slot != active_slot: return
    var revisions: Array[Dictionary] = []
    var slot_pattern := RegEx.create_from_string("^v2_[0-9a-f]{64}$")
    for filename in DirAccess.get_files_at(root_path):
        if not filename.ends_with(".json"): continue
        var slot := filename.trim_suffix(".json")
        if slot_pattern.search(slot) == null: continue
        var checked := _read(slot)
        if not checked.ok or int(checked.payload.schema_version) != 2 or checked.payload.save_id != active_payload.save_id: continue
        if int(checked.payload.revision) > int(active_payload.revision): continue
        if "v2_" + CODEC.digest(checked.payload) != slot or "v2_" + checked.source_text.sha256_text() != slot: continue
        revisions.append({"slot": slot, "revision": int(checked.payload.revision)})
    revisions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.revision < b.revision if a.revision != b.revision else a.slot < b.slot)
    if revisions.size() <= 3: return
    var retained := {active_slot: true, str(revisions[0].slot): true}
    for index in range(revisions.size() - 1, -1, -1):
        if revisions[index].revision < int(active_payload.revision):
            retained[str(revisions[index].slot)] = true
            break
    for entry in revisions:
        if retained.has(entry.slot): continue
        pointer = _read_pointer()
        if not pointer.ok or pointer.slot != active_slot: return
        var path := root_path.path_join(str(entry.slot) + ".json")
        if not _allowed("cleanup_" + str(entry.slot), path): continue
        # Revalidate immediately before deletion, including exact byte hash.
        var current := _read(str(entry.slot))
        if not current.ok or int(current.payload.schema_version) != 2 or current.payload.save_id != active_payload.save_id: continue
        if "v2_" + current.source_text.sha256_text() != entry.slot or "v2_" + CODEC.digest(current.payload) != entry.slot: continue
        DirAccess.remove_absolute(path)
