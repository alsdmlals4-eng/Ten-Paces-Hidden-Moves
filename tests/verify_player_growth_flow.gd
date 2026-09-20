extends SceneTree

const RUN = preload("res://src/run/vertical_slice_run_state.gd")
const CODEC = preload("res://src/run/run_checkpoint_codec.gd")
const GROWTH = preload("res://src/run/player_growth_state.gd")
const LEGACY_IDENTITIES := ["7f89ee55e89a47c52c9eb851bada78d552e55eb8e77efecbb09c8fbefdd771bf", "8db0de9663d0112c58675659bba2c2ac7f78fda9aac9cd9122f7597471e60a20", "adb691c986eabca56e7bc67671be7c3d8851c1a220d2cebea034d63d6f5e6e82"]
var failures: Array[String] = []
var checks := 0

func check(value: bool, label: String) -> bool:
    checks += 1
    if not value:
        failures.append(label)
        push_error(label)
    return value

func _initialize() -> void:
    create_timer(90).timeout.connect(func(): printerr("PLAYER_GROWTH_TIMEOUT"); quit(1))
    call_deferred("_run")

func _run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() == 2 and args[0] == "--resume-root":
        await _resume_boundary(args[1])
        print("PLAYER_GROWTH_RESUME checks=%d failures=%d" % [checks,failures.size()])
        quit(0 if failures.is_empty() else 1)
        return
    var codec = CODEC.new()
    for version in [1, 2, 3]:
        check(codec.content_identity_for_schema(version) == LEGACY_IDENTITIES[version - 1], "old content identity unchanged v%d" % version)
    var growth = GROWTH.new()
    var ids: Array = load("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0,4)
    var mastery := {}
    for id in ids: mastery[id] = 3
    var allocation: Dictionary = growth.recommended_allocation(ids)
    check(growth.valid_allocation(allocation), "recommended allocation spends exactly six")
    var initial: Dictionary = growth.project(allocation, mastery)
    check(_total(initial.stats) == 20 and initial.grants.size() == 4, "base10 plus six plus four first grants equals20")
    for id in ids:
        var cards: Array = growth.registry.build_unlocked_cards(id,3)
        check(growth.lock_reason(cards[0], initial.stats).is_empty(), "recommendation opens initial technique " + id)
    for id in growth.registry.get_manual_ids():
        var a: Dictionary = growth.project(allocation, {id:3})
        var b: Dictionary = growth.project(allocation, {id:8})
        var source: Dictionary = growth.registry.get_manual(id)
        var primary: String = growth.stat_key(source.primary_stat)
        var secondary: String = growth.stat_key(source.secondary_stat)
        check(int(b.stats[primary]) - int(a.stats[primary]) == 6 and int(b.stats[secondary]) - int(a.stats[secondary]) == 4, "3 to8 primary6 secondary4 " + id)
        check(b.grants.size() == 4 and b == growth.project(allocation,{id:8}), "repeat projection never pays again " + id)
        var previous: Dictionary = a
        var delta := 0
        for star in range(4,9):
            var current: Dictionary = growth.project(allocation,{id:star})
            delta += _total(current.stats) - _total(previous.stats)
            previous = current
        check(delta == 10 and previous == b, "multi-star equals sequential " + id)
    var starters: Array = load("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS
    for a in range(starters.size()):
        for b in range(a+1,starters.size()):
            for c in range(b+1,starters.size()):
                for d in range(c+1,starters.size()):
                    var choice := [starters[a],starters[b],starters[c],starters[d]]
                    var levels := {}
                    for id in choice: levels[id] = 3
                    var recommendation: Dictionary = growth.recommended_allocation(choice)
                    var view: Dictionary = growth.project(recommendation,levels)
                    check(growth.valid_allocation(recommendation) and _total(view.stats) == 20,"all starter combinations total20")
                    for id in choice:
                        check(growth.lock_reason(growth.registry.build_unlocked_cards(id,3)[0],view.stats).is_empty(),"all starter recommendations meet first requirement")
    var all_max := {}
    for id in growth.registry.get_manual_ids(): all_max[id] = 10
    var grown: Dictionary = growth.project(allocation,all_max)
    check(_total(grown.stats) == 126 and grown.stats.values().max() > 15,"legal ten-manual growth is not capped at15")
    var requirement_manual: Dictionary = growth.registry.get_manual(ids[0])
    for star in [3,7,10]:
        var card: Dictionary = growth.registry.build_unlocked_cards(ids[0],star)[-1]
        var stats := {"external":2,"constitution":2,"agility":2,"internal_power":2,"insight":2}
        var key: String = growth.stat_key(requirement_manual.primary_stat)
        stats[key] = int(growth.rules.primary_requirements[str(star)]) - 1
        check(not growth.lock_reason(card,stats).is_empty(),"below permanent tier" + str(star))
        stats[key] += 1
        check(growth.lock_reason(card,stats).is_empty(),"exact permanent tier" + str(star))
    var run = RUN.new()
    if check(run.start_new_stats_run(34,"growth-v4"), "new v4 run"):
        var before: Dictionary = run.export_snapshot()
        check(run.validate_snapshot(before).ok, "empty setup v4 valid")
        check(not run.advance(), "setup cannot bypass allocation and manuals")
        for invalid in [{}, {"external":true,"constitution":1,"agility":1,"internal_power":1,"insight":2}, {"external":5,"constitution":1,"agility":0,"internal_power":0,"insight":0}, {"external":2.5,"constitution":1.5,"agility":1,"internal_power":1,"insight":0}]:
            check(not run.confirm_setup_loadout(ids,mastery,invalid) and run.export_snapshot() == before,"invalid allocation atomic")
        check(run.confirm_setup_loadout(ids,mastery,allocation), "confirm starter allocation")
        check(run.get_player_growth_stats() == initial.stats, "domain stats match preview")
        check(run.advance() and run.advance(), "briefing")
        check(run.validate_snapshot(run.export_snapshot()).ok, "v4 initial accounting validates")
        var encoded: Dictionary = codec.encode("growth-v4","briefing",1,run.export_snapshot())
        if check(encoded.get("ok",false), "v4 encode: " + str(encoded.get("error",""))):
            check(encoded.payload.schema_version == 4, "explicit schema4")
            var decoded: Dictionary = codec.decode(encoded.text)
            if check(decoded.ok, "v4 decode"):
                var restored = RUN.new()
                check(restored.import_snapshot(decoded.payload.run_state).ok and restored.get_player_growth_stats() == initial.stats,"load preserves grants")
                check(restored.import_snapshot(decoded.payload.run_state).ok and restored.get_player_growth_stats() == initial.stats,"repeated load cannot duplicate")
        var invalid_snapshot: Dictionary = run.export_snapshot()
        invalid_snapshot.starting_stat_allocation.external += 1
        check(not run.validate_snapshot(invalid_snapshot).ok, "tampered allocation rejected")
        check(run.advance(), "enter combat")
        check(run.mark_combat_finished({"outcome":"win","player_health":30,"enemy_health":0,"player_resources":run.get_player_run_resources()}) and run.advance(), "accounting fixture wins first fight")
        var reward: Dictionary = load("res://src/run/vertical_slice_result_model.gd").new().build_reward_receipt("free_training", "", ids, run.get_current_opponent())
        check(run.set_pending_result_reward(reward) and run.advance(), "receive free training")
        var stats_before: Dictionary = run.get_player_growth_stats()
        var preview: Dictionary = run.preview_training({ids[0]:2})
        check(preview.ok and run.get_player_growth_stats() == stats_before, "preview does not pay")
        var revision: int = run.get_training_revision()
        check(run.commit_training({ids[0]:2},revision), "train through fourth star")
        check(_total(run.get_player_growth_stats()) == 22, "fourth star adds primary1 secondary1")
        check(not run.commit_training({ids[0]:2},revision) and _total(run.get_player_growth_stats()) == 22,"stale action no duplicate grant")
        check(run.validate_snapshot(run.export_snapshot()).ok,"v4 ordered ledger accepts training")
        var after: Dictionary = codec.encode("growth-v4","trained",2,run.export_snapshot())
        check(after.get("ok",false) and codec.decode(after.get("text", "")).get("ok",false), "trained v4 survives transport")
    if args.size() == 2 and args[0] == "--store-root": _store_boundary(run,args[1])
    _combat_growth(growth, ids, mastery)
    print("PLAYER_GROWTH checks=%d failures=%d" % [checks, failures.size()])
    quit(0 if failures.is_empty() else 1)

func _total(stats: Dictionary) -> int:
    var total := 0
    for value in stats.values(): total += int(value)
    return total

func _combat_growth(growth, ids: Array, mastery: Dictionary) -> void:
    var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
    if not check(engine.has_method("configure_player_growth_stats"), "combat consumes permanent growth and rejects unmet requirements"): return
    var stats := {"external":2,"constitution":2,"agility":2,"internal_power":2,"insight":2}
    check(engine.configure_player_growth_stats(stats), "bind permanent stats")
    check(engine.configure_martial_loadouts(ids,mastery,ids,mastery), "same manuals on both actors")
    var card: Dictionary = growth.registry.build_unlocked_cards(ids[0],3)[0]
    check(not engine.get_action_lock_reason(card.id).is_empty(), "primary requirement explained")
    check(engine.get_actor_card_definition(card.id,"player").is_empty(), "locked player technique cannot bypass UI")
    check(not engine.get_actor_card_definition(card.id,"enemy").is_empty(), "enemy unaffected by player restriction")
    stats[growth.stat_key(card.primary_stat)] = 4
    check(engine.configure_player_growth_stats(stats), "permanent requirement reached")
    check(engine.get_action_lock_reason(card.id).is_empty() and not engine.get_actor_card_definition(card.id,"player").is_empty(),"permanent growth unlocks")
    var state: Dictionary = engine.make_initial_state({},4,6)
    check(state.player.stats == stats,"initial actor consumes growth")
    state.player.stats[growth.stat_key(card.primary_stat)] = 1
    check(not engine.get_actor_card_definition(card.id,"player").is_empty(),"temporary combat decrease does not re-lock")

func _store_boundary(run, path: String) -> void:
    if not check(not DirAccess.dir_exists_absolute(path), "isolated store must be new"): return
    DirAccess.make_dir_recursive_absolute(path)
    var original := FileAccess.get_file_as_bytes("res://tests/fixtures/acquired-legacy-v1.json")
    var file := FileAccess.open(path.path_join("primary.json"), FileAccess.WRITE)
    file.store_buffer(original)
    file.close()
    var store = load("res://src/run/run_save_store.gd").new(path)
    store.io_guard = func(operation: String, _path: String): return operation != "write_primary"
    check(not store.replace_run("growth-v4", "training-first", run.export_snapshot()).get("ok",true), "v4 obeys shared durable write failure gate")
    store.io_guard = Callable()
    var saved: Dictionary = store.replace_run("growth-v4", "training-first", run.export_snapshot())
    check(saved.get("ok", false), "v4 actual store saves: " + str(saved.get("error", "")))
    check(FileAccess.get_file_as_bytes(path.path_join("primary.json")) == original, "legacy primary remains byte-identical")
    var pointer = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("active.json")))
    if not check(typeof(pointer) == TYPE_DICTIONARY and pointer.get("schema_version") == 4, "v4 has explicit pointer version4"): return
    var loaded: Dictionary = store.load_checkpoint()
    check(loaded.get("ok", false) and loaded.get("payload", {}).get("schema_version") == 4, "v4 actual pointer read")
    var repeated: Dictionary = store.save_checkpoint("growth-v4", "training-first", run.export_snapshot())
    check(repeated.get("ok", false) and repeated.get("idempotent", false), "same checkpoint idempotent")
    var blocked_once := [true]
    store.io_guard = func(operation: String, _path: String):
        if operation == "rename_active" and blocked_once[0]:
            blocked_once[0] = false
            return false
        return true
    check(run.commit_training({run.get_owned_player_manuals()[1]:1}, run.get_training_revision()), "new allocation before failed save")
    var snapshot: Dictionary = run.export_snapshot()
    var failed: Dictionary = store.save_checkpoint("growth-v4", "training-retry", snapshot)
    check(not failed.get("ok", true), "failed pointer switch not acknowledged")
    check(store.load_checkpoint().payload == loaded.payload, "previous durable generation survives")
    var retry: Dictionary = store.save_checkpoint("growth-v4", "training-retry", snapshot)
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
    check(shell.run_state.get_progression_snapshot().mastery_by_manual[ids[0]] == 4, "earned fourth star survives process restart")
    check(shell.run_state.is_stat_growth_run() and shell.run_state.get_player_growth_stats().size() == 5, "fresh process projects stats")
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
    check(retired.get("ok",false) and retired.get("payload",{}).get("schema_version") == 4 and not retired.get("payload",{}).get("active",true), "retirement retains explicit growth identity")
    var repeated: Dictionary = shell.session.store.retire_run(shell.session.save_id, "growth-retired")
    check(repeated.get("ok",false) and repeated.get("idempotent",false), "growth retirement is idempotent")
    shell.queue_free()
    await process_frame
