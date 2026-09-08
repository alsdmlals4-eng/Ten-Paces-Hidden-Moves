class_name RunSaveStore
extends RefCounted

const CODEC := preload("res://src/run/run_checkpoint_codec.gd")
var root_path: String
var codec = CODEC.new()
# Optional operation guard for bounded injected file faults. It cannot supply success.
var io_guard: Callable
var _pending: Dictionary = {}

func _init(path: String = "user://run_checkpoint") -> void:
    root_path = path

func _allowed(operation: String, path: String) -> bool:
    return not io_guard.is_valid() or bool(io_guard.call(operation, path))

func _read(slot: String) -> Dictionary:
    var path := root_path.path_join(slot + ".json")
    if not FileAccess.file_exists(path):
        if DirAccess.dir_exists_absolute(path): return CODEC.error("IO_FAILURE", "Save slot is a directory")
        return CODEC.error("ABSENT", "No save file")
    if not _allowed("read_" + slot, path): return CODEC.error("IO_FAILURE", "Read blocked")
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null: return CODEC.error("IO_FAILURE", "Cannot open save")
    if file.get_length() > CODEC.MAX_BYTES:
        file.close()
        return CODEC.error("CORRUPT", "Save exceeds size bound")
    var bytes := file.get_buffer(file.get_length())
    var read_error := file.get_error()
    file.close()
    if read_error != OK and read_error != ERR_FILE_EOF: return CODEC.error("IO_FAILURE", "Cannot read save")
    return codec.decode(bytes.get_string_from_utf8())

func load_checkpoint() -> Dictionary:
    var primary := _read("primary")
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

func _save(save_id: String, checkpoint_id: String, run_state: Dictionary, combat_checkpoint: Dictionary, active: bool, replace: bool) -> Dictionary:
    if not CODEC.json_safe([run_state, combat_checkpoint], 0, [0]): return CODEC.error("CORRUPT", "Unsupported payload")
    var identity := CODEC.digest({"save_id": save_id, "checkpoint_id": checkpoint_id, "run_state": run_state, "combat_checkpoint": combat_checkpoint, "active": active, "replace": replace})
    if not _pending.is_empty() and _pending.identity != identity:
        return CODEC.error("IO_FAILURE", "Retry the pending immutable checkpoint before another command")
    var current := load_checkpoint()
    if not replace and current.status in ["INCOMPATIBLE", "IO_FAILURE", "CORRUPT"]: return current
    var previous: Dictionary = current.get("payload", {})
    if not replace and not previous.is_empty() and (previous.save_id != save_id or not previous.active):
        return CODEC.error("INCOMPATIBLE", "Generation replacement requires explicit operation")
    if _pending.is_empty():
        var revision := int(previous.get("revision", 0)) + 1
        var encoded: Dictionary = codec.encode(save_id, checkpoint_id, revision, run_state, combat_checkpoint, active)
        if not encoded.ok: return encoded
        if not previous.is_empty() and previous.save_id == save_id and previous.checkpoint_id == checkpoint_id and previous.active == active and CODEC.digest([previous.run_state, previous.combat_checkpoint]) == CODEC.digest([run_state, combat_checkpoint]):
            # A two-slot operation is idempotent only when both slots already agree.
            var backup := _read("backup")
            if not replace or (backup.ok and backup.payload == previous):
                return {"ok": true, "status": "SAVED", "revision": previous.revision, "payload": previous.duplicate(true), "idempotent": true}
        _pending = {"identity": identity, "encoded": encoded, "replace": replace}
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
        if not _write_slot("backup", _pending.encoded.text): return failed
    else:
        var primary := _read("primary")
        if primary.ok:
            var prior_text := JSON.stringify(primary.payload, "", true, true)
            if not _write_slot("backup", prior_text): return failed
        elif not _read("backup").ok:
            if not _write_slot("backup", _pending.encoded.text): return failed
    if not _write_slot("primary", _pending.encoded.text): return failed
    var primary_check := _read("primary")
    if not primary_check.ok or primary_check.payload != envelope: return failed
    if replace:
        var backup_check := _read("backup")
        if not backup_check.ok or backup_check.payload != envelope: return failed
    _pending.clear()
    return {"ok": true, "status": "SAVED", "revision": envelope.revision, "payload": envelope.duplicate(true)}

func _write_slot(slot: String, text: String) -> bool:
    var temp := root_path.path_join(slot + "_temp.json")
    if not _allowed("write_" + slot, temp): return false
    var file := FileAccess.open(temp, FileAccess.WRITE)
    if file == null: return false
    file.store_buffer(text.to_utf8_buffer())
    file.flush()
    var error := file.get_error()
    file.close()
    if error != OK: return false
    var readback := _read(slot + "_temp")
    if not readback.ok or readback.payload != codec.decode(text).get("payload"): return false
    var destination := root_path.path_join(slot + ".json")
    if not _allowed("rename_" + slot, destination): return false
    return DirAccess.rename_absolute(temp, destination) == OK

func _preserve_evidence(slot: String) -> bool:
    var source := root_path.path_join(slot + ".json")
    if not _allowed("preserve_" + slot, source): return false
    var hash := FileAccess.get_sha256(source)
    if hash.is_empty(): return false
    var destination := root_path.path_join(slot + "_evidence_" + hash + ".json")
    if FileAccess.file_exists(destination): return FileAccess.get_sha256(destination) == hash
    return DirAccess.copy_absolute(source, destination) == OK and FileAccess.get_sha256(destination) == hash
