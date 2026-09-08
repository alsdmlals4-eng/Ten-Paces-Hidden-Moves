extends RefCounted
## Owns durable transactions; domain models retain all gameplay rules.
const STORE := preload("res://src/run/run_save_store.gd")
const CODEC := preload("res://src/run/run_checkpoint_codec.gd")
var store
var shell: Control
var enabled := false
var busy := false
var blocked := false
var suspended := false
var last_durable: Dictionary = {}
var available: Dictionary = {}
var status := "ABSENT"
var error := ""
var save_id := ""
var _sequence := 0
var _pending: Dictionary = {}
var _queued_terminal: Dictionary = {}
var _board_pending := false
var write_msec: Array[int] = []

func configure(owner: Control, path: String, use_storage: bool) -> void:
    shell = owner
    enabled = use_storage
    if not enabled: return
    store = STORE.new(path)
    refresh_available()

func refresh_available() -> void:
    if not enabled: return
    var result: Dictionary = store.load_checkpoint()
    status = result.status
    error = str(result.get("error", ""))
    available = result.get("payload", {}).duplicate(true) if status in ["VALID_PRIMARY", "RECOVERED_BACKUP"] else {}

func accepts_commands() -> bool:
    return not busy and not blocked and not suspended

func transact(command: Callable, replace: bool = false) -> bool:
    if not accepts_commands(): return false
    busy = true
    if not bool(command.call()):
        busy = false
        shell._publish_session_screen()
        return false
    if replace:
        save_id = "%d-%d-%d" % [Time.get_unix_time_from_system(), OS.get_process_id(), Time.get_ticks_usec()]
    _prepare_combat()
    _apply_queued_terminal()
    var ok := _stage_current("replace" if replace else "save")
    busy = false
    _publish(ok)
    return ok

func _prepare_combat() -> void:
    if shell.run_state.get_current_screen() == "COMBAT":
        shell._ensure_combat_view()
        shell._combat_view.configure_checkpoint_identity(shell.run_state.duel_index, shell.run_state._attempt_id)
        shell._combat_view.checkpoint_writer = Callable(self, "write_combat")

func _stage_current(operation: String = "save") -> bool:
    if not enabled: return true
    var combat := {}
    if shell.run_state.get_current_screen() == "COMBAT": combat = shell._combat_view.get_last_stable_checkpoint()
    _sequence += 1
    _pending = {"operation": "retire" if shell.run_state.get_current_screen() == "MAIN" else operation,
        "id": "transaction-%d-%d" % [Time.get_ticks_usec(), _sequence],
        "run": shell.run_state.export_snapshot(), "combat": combat.duplicate(true)}
    return _write_pending()

func _write_pending() -> bool:
    var start := Time.get_ticks_msec()
    var result: Dictionary
    match _pending.operation:
        "replace": result = store.replace_run(save_id, _pending.id, _pending.run, _pending.combat)
        "retire": result = store.retire_run(save_id, _pending.id)
        _: result = store.save_checkpoint(save_id, _pending.id, _pending.run, _pending.combat)
    write_msec.append(Time.get_ticks_msec() - start)
    blocked = not result.ok
    status = result.status
    error = str(result.get("error", ""))
    if result.ok:
        last_durable = result.payload.duplicate(true)
        _pending.clear()
        available = last_durable.duplicate(true) if last_durable.active else {}
    return result.ok

func write_combat(dto: Dictionary) -> bool:
    # Construction/restoration producers are staged into the outer complete transaction.
    if busy: return true
    if not enabled: return true
    if suspended or blocked: return false
    _sequence += 1
    _pending = {"operation": "save", "id": "combat-%d-%d" % [Time.get_ticks_usec(), _sequence],
        "run": shell.run_state.export_snapshot(), "combat": dto.duplicate(true)}
    var ok := _write_pending()
    _board_pending = not ok
    if not ok: shell._apply_session_input_lock()
    return ok

func terminal_ready(result: Dictionary) -> bool:
    if shell.run_state.get_current_screen() != "COMBAT": return false
    if busy:
        _queued_terminal = result.duplicate(true)
        return true
    if not accepts_commands(): return false
    return transact(func(): return _apply_terminal(result))

func _apply_terminal(result: Dictionary) -> bool:
    if not shell.run_state.mark_combat_finished(result): return false
    if shell.run_state.get_current_screen() == "REVIEW": return shell.run_state.advance()
    return true

func _apply_queued_terminal() -> void:
    if not _queued_terminal.is_empty():
        var result := _queued_terminal.duplicate(true)
        _queued_terminal.clear()
        _apply_terminal(result)

func continue_run() -> bool:
    if not accepts_commands() or available.is_empty(): return false
    # The title retained this fully validated payload; do not load a second, different file.
    busy = true
    var previous: Dictionary = shell.run_state.export_snapshot()
    var loaded := available.duplicate(true)
    var imported: Dictionary = shell.run_state.import_snapshot(loaded.run_state)
    if not imported.ok:
        busy = false
        status = imported.status
        return false
    save_id = loaded.save_id
    last_durable = loaded.duplicate(true)
    _prepare_combat()
    if not loaded.combat_checkpoint.is_empty():
        var restored: Dictionary = shell._combat_view.restore_combat_checkpoint(loaded.combat_checkpoint)
        if not restored.ok:
            shell.run_state.import_snapshot(previous)
            shell._discard_combat_view()
            busy = false
            status = restored.status
            error = restored.error
            shell._publish_session_screen()
            return false
    _apply_queued_terminal()
    # COMMITTED/RESOLVED restore may produce the next stable boundary or terminal result.
    var ok := true
    var current_combat: Dictionary = shell._combat_view.get_last_stable_checkpoint() if shell.run_state.get_current_screen() == "COMBAT" else {}
    if CODEC.digest([shell.run_state.export_snapshot(), current_combat]) != CODEC.digest([loaded.run_state, loaded.combat_checkpoint]):
        ok = _stage_current()
    busy = false
    _publish(ok)
    return ok

func retry() -> bool:
    if busy or suspended: return false
    if not blocked: return true
    if _pending.is_empty(): return false
    busy = true
    var ok := _write_pending()
    busy = false
    if not ok:
        _publish(false)
        return false
    var resume_board := _board_pending
    _board_pending = false
    _publish(true)
    if resume_board and is_instance_valid(shell._combat_view):
        # The original immutable candidate was acknowledged above; the bridge retries its
        # producer once without replaying the user's gameplay command.
        shell._combat_view.checkpoint_writer = func(dto: Dictionary):
            if CODEC.digest(dto) == CODEC.digest(last_durable.combat_checkpoint): return true
            return write_combat(dto)
        await shell._combat_view.retry_checkpoint()
        shell._combat_view.checkpoint_writer = Callable(self, "write_combat")
    return not blocked

func flush_stable() -> bool:
    if not enabled or last_durable.is_empty(): return not blocked
    if blocked: return false
    var result: Dictionary
    if last_durable.active:
        result = store.save_checkpoint(last_durable.save_id, last_durable.checkpoint_id, last_durable.run_state, last_durable.combat_checkpoint)
    else:
        result = store.retire_run(last_durable.save_id, last_durable.checkpoint_id)
    if not result.ok:
        _pending = {"operation": "save" if last_durable.active else "retire", "id": last_durable.checkpoint_id,
            "run": last_durable.run_state.duplicate(true), "combat": last_durable.combat_checkpoint.duplicate(true)}
        blocked = true
        status = result.status
    return result.ok

func _publish(ok: bool) -> void:
    if ok:
        shell._release_retained_combat()
        shell._publish_session_screen()
    else:
        # Keep the previous published screen until the candidate is acknowledged.
        shell._apply_session_input_lock()
