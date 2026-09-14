extends SceneTree

const RUN = preload("res://src/run/vertical_slice_run_state.gd")
const CODEC = preload("res://src/run/run_checkpoint_codec.gd")
var failures: Array[String] = []
var checks := 0

func check(value: bool, label: String) -> bool:
    checks += 1
    if not value:
        failures.append(label)
        push_error(label)
    return value

func _initialize() -> void:
    create_timer(60).timeout.connect(func(): printerr("TRAINING_GROWTH_TIMEOUT"); quit(1))
    call_deferred("_run")

func _run() -> void:
    var process_args := OS.get_cmdline_user_args()
    if process_args.size() == 2 and process_args[0] == "--resume-root":
        await _resume_boundary(process_args[1])
        print("TRAINING_GROWTH_RESUME checks=%d failures=%d" % [checks,failures.size()])
        quit(0 if failures.is_empty() else 1)
        return
    var run = RUN.new()
    if check(run.has_method("start_new_growth_run"), "new growth ruleset has explicit entry"):
        check(run.start_new_growth_run(34, "training-v3"), "start v3")
        var ids: Array = load("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0,4)
        var mastery := {}
        for id in ids: mastery[id] = 3
        check(run.confirm_setup_loadout(ids, mastery), "starter setup")
        check(run.advance() and run.advance(), "first briefing")
        check(run.export_snapshot().ruleset_id == "ten-duel-growth-v3", "explicit ruleset")
        check(run.validate_snapshot(run.export_snapshot()).ok, "v3 initial snapshot validates")
        check(not run.commit_training({ids[0]:1}, run.get_training_revision()), "no free credit at initial briefing")
        check(run.advance(), "enter combat")
        check(not run.commit_training({ids[0]:1}, run.get_training_revision()), "combat allocation forbidden")
        # Synthetic terminal for accounting, separate from native gameplay evidence.
        check(run.mark_combat_finished({"outcome":"win","player_health":30,"enemy_health":0,"player_resources":run.get_player_run_resources()}), "synthetic result")
        check(run.advance(), "review to reward")
        var reward: Dictionary = load("res://src/run/vertical_slice_result_model.gd").new().build_reward_receipt("free_training", "", ids, run.get_current_opponent())
        check(run.set_pending_result_reward(reward) and run.advance(), "receive real free reward")
        var revision: int = run.get_training_revision()
        var before: Dictionary = run.export_snapshot()
        check(run.preview_training({ids[0]:2}).ok and run.export_snapshot() == before, "run preview is unchanged")
        check(run.commit_training({ids[0]:2}, revision), "allocate received pool")
        var applied: Dictionary = run.export_snapshot()
        check(not run.commit_training({ids[0]:2}, revision) and run.export_snapshot() == applied, "stale double activation rejected")
        check(run.validate_snapshot(applied).ok, "ordered training snapshot validates")
        var encoded: Dictionary = CODEC.new().encode("training-v3","allocated",1,applied)
        if check(encoded.get("ok",false), "v3 encodes"):
            check(encoded.payload.schema_version == 3, "explicit schema3")
            var decoded: Dictionary = CODEC.new().decode(encoded.text)
            if not check(decoded.ok, "v3 decodes: " + str(decoded.get("error", ""))):
                quit(1)
                return
            var restored = RUN.new()
            check(restored.import_snapshot(decoded.payload.run_state).ok, "v3 domain restore")
            check(restored.get_progression_snapshot() == run.get_progression_snapshot(), "allocation restored once")
        for step in range(4):
            var option_id: String = run.get_jianghu_options()[0].id
            check(run.select_jianghu_node(option_id,step), "valid route option " + str(step))
            check(run.validate_snapshot(run.export_snapshot()).ok, "pending route accounting")
            check(run.advance(), "advance route")
        check(run.commit_training({ids[0]:3}, run.get_training_revision()), "next briefing allocation")
        check(run.get_progression_snapshot().mastery_by_manual[ids[0]] == 5, "actual fifth star")
        check(run.validate_snapshot(run.export_snapshot()).ok, "later training validates")
        var args := OS.get_cmdline_user_args()
        if args.size() == 2 and args[0] == "--store-root": _store_boundary(run, args[1])
        var forged: Dictionary = run.export_snapshot()
        var events: Array = forged.progression_events
        var first_reward = events[0]
        events[0] = events[1]
        events[1] = first_reward
        for index in range(events.size()): events[index].sequence = index + 1
        check(not run.validate_snapshot(forged).ok, "future reward cannot fund past spending")
        check(run.advance(), "grown run enters next duel")
        var lost_resources: Dictionary = run.get_player_run_resources()
        lost_resources.health[0] = 0
        check(run.mark_combat_finished({"outcome":"loss","player_health":0,"enemy_health":30,"player_resources":lost_resources}) and run.advance(), "grown run reaches failure")
        check(run.end_failed_run(), "end failed growth journey")
        check(run.export_snapshot().progression_events.is_empty(), "failure exit clears event references with reward history")
        check(run.validate_snapshot(run.export_snapshot()).ok, "ended growth run remains valid")
        var legacy = RUN.new()
        check(legacy.start_new_variable_run(34,"legacy-frozen"), "v2 remains available")
        check(not legacy.export_snapshot().has("progression_events"), "v2 shape remains frozen")
        check(not legacy.commit_training({ids[0]:1},0), "v2 cannot adopt new spending semantics")
        _full_accounting_journey(ids)
    print("TRAINING_GROWTH_V3 checks=%d failures=%d" % [checks,failures.size()])
    quit(0 if failures.is_empty() else 1)

func _store_boundary(run, path: String) -> void:
    if not check(not DirAccess.dir_exists_absolute(path), "isolated store must be new"): return
    DirAccess.make_dir_recursive_absolute(path)
    var original := FileAccess.get_file_as_bytes("res://tests/fixtures/acquired-legacy-v1.json")
    var file := FileAccess.open(path.path_join("primary.json"), FileAccess.WRITE)
    file.store_buffer(original)
    file.close()
    var store = load("res://src/run/run_save_store.gd").new(path)
    store.io_guard = func(operation: String, _path: String): return operation != "write_primary"
    check(not store.replace_run("training-v3", "training-first", run.export_snapshot()).get("ok",true), "v3 obeys shared durable write failure gate")
    store.io_guard = Callable()
    var saved: Dictionary = store.replace_run("training-v3", "training-first", run.export_snapshot())
    check(saved.get("ok", false), "v3 actual store saves: " + str(saved.get("error", "")))
    check(FileAccess.get_file_as_bytes(path.path_join("primary.json")) == original, "legacy primary remains byte-identical")
    var pointer = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("active.json")))
    if not check(typeof(pointer) == TYPE_DICTIONARY and pointer.get("schema_version") == 3, "v3 has explicit pointer version3"): return
    var loaded: Dictionary = store.load_checkpoint()
    check(loaded.get("ok", false) and loaded.get("payload", {}).get("schema_version") == 3, "v3 actual pointer read")
    var repeated: Dictionary = store.save_checkpoint("training-v3", "training-first", run.export_snapshot())
    check(repeated.get("ok", false) and repeated.get("idempotent", false), "same checkpoint idempotent")
    var blocked_once := [true]
    store.io_guard = func(operation: String, _path: String):
        if operation == "rename_active" and blocked_once[0]:
            blocked_once[0] = false
            return false
        return true
    check(run.commit_training({run.get_owned_player_manuals()[1]:1}, run.get_training_revision()), "new allocation before failed save")
    var snapshot: Dictionary = run.export_snapshot()
    var failed: Dictionary = store.save_checkpoint("training-v3", "training-retry", snapshot)
    check(not failed.get("ok", true), "failed pointer switch not acknowledged")
    check(store.load_checkpoint().payload == loaded.payload, "previous durable generation survives")
    var retry: Dictionary = store.save_checkpoint("training-v3", "training-retry", snapshot)
    check(retry.get("ok", false), "same allocation snapshot retries")
    check(store.load_checkpoint().payload.run_state == CODEC.normalized(snapshot), "retry records exact state once")

func _resume_boundary(path: String) -> void:
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    shell.configure_save_storage(path)
    root.add_child(shell)
    await process_frame
    var available: Dictionary = shell.session.available.duplicate(true)
    if not check(not available.is_empty(), "fresh process finds durable growth journey"):
        shell.queue_free()
        await process_frame
        return
    check(shell.continue_saved_run(), "actual shell Continue restores growth")
    check(CODEC.digest(shell.run_state.export_snapshot()) == CODEC.digest(available.run_state), "fresh process exact run parity")
    var ids: Array = shell.run_state.get_owned_player_manuals()
    check(shell.run_state.get_progression_snapshot().mastery_by_manual[ids[0]] == 5, "earned fifth star survives process restart")
    var once := [true]
    shell.session.store.io_guard = func(operation: String, _path: String):
        if operation == "rename_active" and once[0]:
            once[0] = false
            return false
        return true
    var revision: int = shell.run_state.get_training_revision()
    check(not shell.session.transact(func(): return shell.run_state.commit_training({ids[1]:1}, revision)), "session reports failed training save")
    check(shell.session.blocked and not shell.session.accepts_commands(), "pending save blocks further spending")
    var candidate: Dictionary = shell.run_state.export_snapshot()
    check(not shell.session.transact(func(): return shell.run_state.commit_training({ids[1]:1}, shell.run_state.get_training_revision())), "blocked session rejects second application")
    check(CODEC.digest(shell.session.store.load_checkpoint().payload) == CODEC.digest(available), "failed session preserves previous durable state")
    check(await shell.session.retry(), "pending session retry succeeds")
    check(shell.run_state.export_snapshot() == candidate and not shell.session.blocked, "retry does not replay spending")
    check(CODEC.digest(shell.session.last_durable.run_state) == CODEC.digest(candidate), "retry acknowledges exact candidate")
    check(shell.session.flush_stable(), "suspension flush preserves acknowledged growth")
    var retired: Dictionary = shell.session.store.retire_run(shell.session.save_id, "growth-retired")
    check(retired.get("ok",false) and retired.get("payload",{}).get("schema_version") == 3 and not retired.get("payload",{}).get("active",true), "retirement retains explicit growth identity")
    var repeated: Dictionary = shell.session.store.retire_run(shell.session.save_id, "growth-retired")
    check(repeated.get("ok",false) and repeated.get("idempotent",false), "growth retirement is idempotent")
    shell.queue_free()
    await process_frame

func _full_accounting_journey(ids: Array) -> void:
    # Full accounting coverage with synthetic outcomes, not a native win-rate claim.
    var run = RUN.new()
    var mastery := {}
    for id in ids: mastery[id] = 3
    check(run.start_new_growth_run(34,"training-full") and run.confirm_setup_loadout(ids,mastery), "mixed full journey setup")
    check(run.advance() and run.advance(), "mixed first briefing")
    var rewards = load("res://src/run/vertical_slice_result_model.gd").new()
    for duel in range(10):
        if not check(run.advance(), "mixed combat entry %d" % duel): return
        if not check(run.mark_combat_finished({"outcome":"win","player_health":30,"enemy_health":0,"player_resources":run.get_player_run_resources()}) and run.advance(), "mixed accounting terminal %d" % duel): return
        var kind: String = ["free_training","faction_transfer","focused_training"][duel % 3]
        var receipt: Dictionary = rewards.build_reward_receipt(kind,ids[0] if kind == "focused_training" else "",run.get_owned_player_manuals(),run.get_current_opponent())
        if not check(run.set_pending_result_reward(receipt) and run.advance(), "mixed reward %d" % duel): return
        check(run.validate_snapshot(run.export_snapshot()).ok, "mixed post-reward ledger %d" % duel)
        if duel == 9: break
        for step in range(4):
            var options: Dictionary = run.get_training_options()
            for manual in options.manuals:
                if manual.next_amount > 0:
                    check(run.commit_training({manual.id:manual.next_amount},run.get_training_revision()), "mixed allocation before route")
                    break
            var routes: Array = run.get_jianghu_options()
            check(run.select_jianghu_node(routes[(duel+step)%routes.size()].id,step), "mixed route selected")
            check(run.validate_snapshot(run.export_snapshot()).ok, "mixed pending route ledger")
            if not check(run.advance(), "mixed route advance"): return
    check(run.get_current_screen() == "COMPLETION" and run.completed_duels == 10 and run.route_visits == 36, "full growth accounting reaches ten duels and 36 routes")
    var envelope: Dictionary = CODEC.new().encode("training-full","completed",1,run.export_snapshot())
    check(envelope.get("ok",false), "completed growth encodes")
    if envelope.get("ok",false): check(CODEC.new().decode(envelope.text).get("ok",false), "completed mixed ledger roundtrips")
