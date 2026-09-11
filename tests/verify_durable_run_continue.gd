extends SceneTree

const SHELL := preload("res://scenes/run/vertical_slice_shell.tscn")
var failures: Array[String] = []
var storage := "user://durable_continue_test_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]

func _initialize() -> void:
    create_timer(180.0).timeout.connect(func(): printerr("DURABLE_CONTINUE timed out"); quit(1))
    call_deferred("_run")

func check(value: bool, message: String) -> void:
    if not value: failures.append(message)

func make_shell():
    var shell = SHELL.instantiate()
    if shell.has_method("configure_save_storage"): shell.configure_save_storage(storage)
    root.add_child(shell)
    await process_frame
    return shell

func tap_action(action: String) -> void:
    for pressed in [true, false]:
        var event := InputEventAction.new()
        event.action = action
        event.pressed = pressed
        root.push_input(event)
        await process_frame

func bimu_surface(shell) -> Dictionary:
    var panel = shell.get_bimu_constraint_panel()
    var snapshot := {"buttons": {}, "targets": {}, "summary": panel.summary_label.text,
        "reason": panel.reason_label.text, "cta": shell.primary_button.text}
    for id in panel.option_buttons:
        var button: Button = panel.option_buttons[id]
        snapshot.buttons[id] = [button.button_pressed, button.text, button.accessibility_name]
    for id in panel.target_selectors: snapshot.targets[id] = panel.target_selectors[id].selected
    return snapshot

func verify_bimu_failed_publication(shell):
    var panel = shell.get_bimu_constraint_panel()
    var before := bimu_surface(shell)
    var revision: int = shell.session.last_durable.revision
    var emissions := [0]
    panel.selection_changed.connect(func(_receipt): emissions[0] += 1)
    shell.session.store.io_guard = func(operation, _path): return operation != "write_primary"
    panel.option_buttons.CST_TECH_MANUAL_SEAL.grab_focus()
    await tap_action("ui_accept")
    check(shell.session.blocked, "actual bimu toggle reaches failed save")
    check(bimu_surface(shell) == before and emissions[0] == 0, "failed bimu toggle preserves published pressed labels summary CTA without signal")
    check(shell.primary_button.disabled and panel.option_buttons.CST_TECH_MANUAL_SEAL.disabled, "failed bimu toggle blocks inputs")
    var pending: Dictionary = shell.session._pending.duplicate(true)
    shell._render_current_screen()
    panel._refresh()
    check(bimu_surface(shell) == before and emissions[0] == 0, "blocked bimu refresh cannot publish staged selection")
    check(shell.session.last_durable.revision == revision and shell.session._pending == pending, "failed bimu render cannot write or replace candidate")
    shell.session.store.io_guard = Callable()
    check(await shell.retry_durable_save(), "bimu toggle retry acknowledges")
    check(shell.session.last_durable.revision == revision + 1, "bimu toggle retry writes once")
    check(emissions[0] == 1, "bimu toggle retry publishes one selection receipt")
    check(panel.option_buttons.CST_TECH_MANUAL_SEAL.button_pressed and "선택한" in shell.primary_button.text, "acknowledged bimu selection published")
    before = bimu_surface(shell)
    revision = shell.session.last_durable.revision
    emissions[0] = 0
    var target: OptionButton = panel.target_selectors.CST_TECH_MANUAL_SEAL
    target.grab_focus()
    await tap_action("ui_accept")
    await tap_action("ui_down")
    shell.session.store.io_guard = func(operation, _path): return operation != "write_primary"
    await tap_action("ui_accept")
    check(shell.session.blocked, "actual bimu target selection reaches failed save")
    check(bimu_surface(shell) == before and emissions[0] == 0, "failed bimu target preserves target selection and published surface")
    pending = shell.session._pending.duplicate(true)
    shell._render_current_screen()
    panel._refresh()
    check(shell.session.last_durable.revision == revision and shell.session._pending == pending, "target failure render cannot autosave")
    shell.session.store.io_guard = Callable()
    check(await shell.retry_durable_save(), "bimu target retry acknowledges")
    check(shell.session.last_durable.revision == revision + 1, "target retry writes once")
    check(emissions[0] == 1, "target retry publishes one selection receipt")
    check(panel.target_selectors.CST_TECH_MANUAL_SEAL.selected == 1, "acknowledged target publishes requested item")
    var saved: Dictionary = shell.run_state.export_snapshot()
    for reopen in range(2):
        shell.queue_free()
        await process_frame
        shell = await make_shell()
        check(shell.continue_saved_run(), "bimu repeated reopen")
        check(shell.run_state.export_snapshot() == saved and shell.session.last_durable.revision == revision + 1, "bimu repeated reopen has no effect or write replay")
    check(shell._submit_bimu_constraints([]), "clear fixture constraints through acknowledged transaction")
    return shell

func _run() -> void:
    var shell = await make_shell()
    check(shell.has_method("configure_save_storage"), "actual shell must expose isolated durable storage")
    check(shell.find_child("MainContinueButton", true, false) != null, "title must offer validated Continue")
    if failures.is_empty():
        shell.session.store.io_guard = func(operation, _path): return operation != "write_primary"
        shell.find_child("MainStartButton", true, false).grab_focus()
        await tap_action("ui_accept")
        check(shell.session.blocked, "actual new journey failure blocks")
        shell.session.store.io_guard = Callable()
        check(await shell.retry_durable_save(), "new generation retry saves setup")
        check(shell.primary_button.disabled and shell.get_setup_selected_manual_ids().is_empty(), "new journey retry respects SETUP zero-of-four disabled CTA")
        var options: Array = shell.starter_manual_catalog.get_options()
        for option in options.slice(0, 4): shell.toggle_setup_manual(str(option.manual_id))
        check(shell.advance_noncombat(), "starter confirmation saves")
        check(shell.advance_noncombat(), "intro advances")
        shell = await verify_bimu_failed_publication(shell)
        var revision: int = shell.session.last_durable.revision
        shell._render_current_screen()
        check(shell.session.last_durable.revision == revision, "briefing render must not autosave")
        shell.session.store.io_guard = func(operation, _path): return operation != "write_primary"
        check(not shell.advance_noncombat(), "briefing combat save failure reported")
        check(shell.session.blocked, "save failure blocks irreversible commands")
        check(not shell.combat_host.visible, "unacknowledged combat transition must not publish staged board")
        check(not shell.advance_noncombat(), "blocked command rejected")
        check(shell.primary_button.disabled, "failure rendering keeps primary input disabled")
        shell.session.store.io_guard = Callable()
        check(await shell.retry_durable_save(), "retry recovers exact pending payload")
        check(shell.run_state.get_current_screen() == "COMBAT", "retry publishes combat")
        if shell._combat_view == null:
            printerr("Failed combat retry: ", shell.session.status, "; ", failures)
            quit(1)
            return
        var dto: Dictionary = shell._combat_view.get_last_stable_checkpoint()
        check(dto.phase == "PLANNING", "first combat checkpoint stable")
        shell.queue_free()
        await process_frame
        shell = await make_shell()
        check(shell.find_child("MainContinueButton", true, false).visible, "valid saved run offered on title")
        for viewport_size in [Vector2i(960, 640), Vector2i(1280, 720), Vector2i(1280, 800), Vector2i(1920, 1080)]:
            root.size = viewport_size
            root.content_scale_size = viewport_size
            shell.size = Vector2(viewport_size)
            await process_frame
            await process_frame
            var title_button: Button = shell.find_child("MainContinueButton", true, false)
            var notice: Label = shell.find_child("SaveContinueNotice", true, false)
            check(title_button.get_global_rect().end.y <= root.size.y and notice.get_global_rect().end.y <= root.size.y, "title Continue and notice fit " + str(viewport_size))
        check(shell.continue_saved_run(), "actual subclass chain restores")
        check(shell._combat_view.get_last_stable_checkpoint() == dto, "restore retains complete planning DTO")
        shell._combat_view.combat_state.player.health[0] -= 1
        var health: int = shell._combat_view.combat_state.player.health[0]
        shell._ensure_combat_view()
        check(shell._combat_view.combat_state.player.health[0] == health, "existing ensure never resets restored resources")
        # Synthetic terminal fixtures test transaction consumers, not campaign play.
        check(shell.complete_combat_for_runtime({"outcome": "loss", "review_causes": [{"event": "miss_range"}]}), "defeat committed directly to failure screen")
        check(shell.run_state.get_current_screen() == "FAILURE_RETRY", "internal REVIEW never durable")
        var old_board = shell._combat_view
        shell.session.store.io_guard = func(operation, _path): return operation != "write_primary"
        check(not shell.retry_failed_combat(), "retry combat write failure reported")
        check(is_instance_valid(old_board) and old_board.is_inside_tree(), "failed retry retains previous board")
        check(shell._retained_combat_view == old_board, "old board explicitly retained until acknowledgment")
        check(old_board.visible and not shell._combat_view.visible, "failed retry keeps published board visible and candidate hidden")
        check(shell.run_state._attempt_id == 1, "retry staged once")
        check(not shell.retry_failed_combat(), "repeat retry command refused while pending")
        shell.session.store.io_guard = Callable()
        check(await shell.retry_durable_save(), "retry write recovers")
        check(shell._combat_view.visible, "acknowledged retry publishes candidate board")
        check(shell.run_state._attempt_id == 1, "disk retry never consumes another game retry")
        var board = shell._combat_view
        # A process-frame continuation must not finish movement or a bundle while paused.
        var moved: Dictionary = board.combat_state.duplicate(true)
        moved.player.tile = 3
        board._apply_timing_snapshot(moved)
        shell.set_session_paused(true)
        var paused_state: Dictionary = board.combat_state.duplicate(true)
        var paused_run: Dictionary = shell.run_state.export_snapshot()
        await create_timer(0.35, true).timeout
        check(board.combat_state == paused_state and shell.run_state.export_snapshot() == paused_run, "pause freezes state and receipts across frame wait")
        check(board._defer_character_snap, "paused frame continuation does not settle movement")
        check(not shell.advance_noncombat(), "paused command rejected")
        shell.set_session_paused(false)
        await create_timer(0.5, true).timeout
        check(not board._defer_character_snap, "resume settles movement once")
        for i in [1, 2, 3]:
            for action in board.action_selection_dock.basic_panel.actions:
                if action.id == "basic_guard": board.action_selection_dock.request_action(action)
        board.combat_progress_button.request_progress()
        check(not shell.session.blocked, "actual ProgressButton UI request produces a valid domain checkpoint")
        shell.set_session_paused(true)
        paused_state = board.combat_state.duplicate(true)
        var paused_phase: String = board._presentation_state
        var count: int = board._resolution_count
        await create_timer(0.4, true).timeout
        check(board.combat_state == paused_state and board._presentation_state == paused_phase and board._resolution_count == count, "paused resolution presentation cannot advance phase/resources/counters")
        shell.set_session_paused(false)
        var deadline := Time.get_ticks_msec() + 15000
        while board._presentation_state not in ["next_bundle_ready", "terminal_result_ready"] and Time.get_ticks_msec() < deadline: await process_frame
        check(board._resolution_count == count and board.combat_state.bundle_index == 2, "resume advances one bundle without rerunning resolver")
        var committed: Array = board._committed_player_plan_snapshot.duplicate(true)
        board._committed_player_plan_snapshot[0].definition.damage = "forged damage"
        check(board._checkpoint_domain_plan().is_empty(), "changed gameplay definition is rejected, never repaired by producer")
        board._committed_player_plan_snapshot = committed
        check(shell.complete_combat_for_runtime({"outcome": "win"}), "synthetic result committed")
        shell._on_terminal_review_confirmed({"outcome": "win"})
        check(shell.run_state.completed_duels == 1, "deferred terminal confirmation does not repeat receipt")
        check(shell.select_result_reward("free_training"), "reward pending saved")
        var pending_snapshot: Dictionary = shell.run_state.export_snapshot()
        shell.queue_free()
        await process_frame
        shell = await make_shell()
        check(shell.continue_saved_run(), "pending reward Continue")
        check(shell.run_state.export_snapshot() == pending_snapshot, "pending reward restored without granting")
        shell.session.store.io_guard = func(operation, _path): return operation != "write_primary"
        check(not shell.advance_noncombat(), "reward confirmation disk failure")
        check(shell.run_state.get_reward_history().size() == 1, "reward transaction staged once")
        shell._render_jianghu()
        check(shell.primary_button.disabled, "direct route render retains freeze")
        shell.session.store.io_guard = Callable()
        check(await shell.retry_durable_save(), "reward confirmation retry")
        check(shell.run_state.get_reward_history().size() == 1, "reward retry grants exactly once")
        # Rest is an authored choice at the third node in the first interval.
        for step in range(2):
            shell._choose_jianghu(str(shell.run_state.get_jianghu_options()[0].id), step)
            check(shell.advance_noncombat(), "reach authored rest choice")
        for option in shell.run_state.get_jianghu_options():
            if option.id == "rest": shell._choose_jianghu(str(option.id), 2)
        var route_snapshot: Dictionary = shell.run_state.export_snapshot()
        check(not shell.run_state.get_pending_jianghu().is_empty(), "rest effect and receipt saved together")
        shell.queue_free()
        await process_frame
        shell = await make_shell()
        check(shell.continue_saved_run(), "rest Continue")
        check(shell.run_state.export_snapshot() == route_snapshot, "rest never applied twice on reopen")
        var after_rest: Dictionary = shell.run_state.get_player_run_resources()
        check(shell.advance_noncombat(), "same-screen route advance saved")
        check(shell.run_state.get_player_run_resources() == after_rest and shell.run_state.route_visits == 3, "route advance consumes pending once")
        print("DURABLE_CONTINUE integrated_write_ms=", shell.session.write_msec)
    shell.queue_free()
    await process_frame
    # A corrupt selected v2 checkpoint must not revive a preserved old generation.
    var pointer: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(storage.path_join("active.json")))
    var selected := storage.path_join(str(pointer.slot) + ".json")
    var corrupt_v2 := FileAccess.open(selected, FileAccess.WRITE)
    corrupt_v2.store_string("{truncated")
    corrupt_v2.close()
    shell = await make_shell()
    check(shell.session.status == "CORRUPT", "corrupt active v2 fails closed without resurrecting old generation")
    check(not shell.find_child("MainContinueButton", true, false).visible, "corrupt v2 cannot continue")
    shell.queue_free()
    await process_frame
    # Keep legacy backup recovery on an independent genuine v1 fixture.
    storage += "_legacy_recovery"
    var legacy_run = load("res://src/run/vertical_slice_run_state.gd").new()
    legacy_run.configure_opponents(load("res://src/run/vertical_slice_opponent_catalog.gd").new(), 83)
    legacy_run.start_new_run()
    var legacy_store = load("res://src/run/run_save_store.gd").new(storage)
    check(legacy_store.replace_run("legacy-fixture", "setup", legacy_run.export_snapshot()).ok, "prepare genuine v1 recovery fixture")
    # Invalid/incompatible slots preserve evidence before explicit replacement.
    var primary := storage.path_join("primary.json")
    var backup := storage.path_join("backup.json")
    var truncated := FileAccess.open(primary, FileAccess.WRITE)
    truncated.store_string("{truncated")
    truncated.close()
    shell = await make_shell()
    check(shell.session.status == "RECOVERED_BACKUP", "truncated primary offers validated backup")
    check("백업" in shell.find_child("SaveContinueNotice", true, false).text, "backup recovery disclosed on title")
    shell.queue_free()
    await process_frame
    var future := FileAccess.open(primary, FileAccess.WRITE)
    future.store_string('{"schema_version":999}')
    future.close()
    shell = await make_shell()
    check(shell.session.status == "INCOMPATIBLE", "future schema title fails closed without backup downgrade")
    check(not shell.find_child("MainContinueButton", true, false).visible, "future schema cannot continue")
    check("버전" in shell.find_child("SaveContinueNotice", true, false).text, "future schema explains incompatibility")
    shell.queue_free()
    await process_frame
    for path in [primary, backup]:
        var file := FileAccess.open(path, FileAccess.WRITE)
        file.store_string("{truncated")
        file.close()
    shell = await make_shell()
    check(shell.session.status == "CORRUPT", "both corrupt fail closed on title")
    check(not shell.find_child("SaveContinueNotice", true, false).text.is_empty(), "corrupt title gives player feedback")
    var hash := FileAccess.get_sha256(primary)
    check(not shell.start_new_run(), "corrupt replacement asks player confirmation")
    check(FileAccess.get_sha256(primary) == hash, "confirmation retains original source")
    shell._replacement_dialog.hide()
    shell.session.store.io_guard = func(operation, _path): return not operation.begins_with("preserve_")
    check(not shell.start_new_run(true), "evidence preservation failure blocks replacement")
    check(FileAccess.get_sha256(primary) == hash, "preservation failure never overwrites source")
    shell.session.store.io_guard = Callable()
    check(await shell.retry_durable_save(), "replacement retries original pending generation")
    check(shell.primary_button.disabled and shell.get_setup_selected_manual_ids().is_empty(), "replacement retry respects SETUP zero-of-four disabled CTA")
    check(FileAccess.file_exists(storage.path_join("primary_evidence_" + hash + ".json")), "original corrupt evidence retained")
    shell.queue_free()
    await process_frame
    for failure in failures: printerr("DURABLE_CONTINUE_FAIL: ", failure)
    print("DURABLE_CONTINUE ", "PASS" if failures.is_empty() else "FAIL")
    quit(0 if failures.is_empty() else 1)
