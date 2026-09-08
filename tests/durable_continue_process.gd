extends SceneTree
## Process-boundary fixtures. Route/result/retry/completion use explicitly synthetic
## terminal receipts; the separate ordinary native campaign never injects outcomes.
const SHELL := preload("res://scenes/run/vertical_slice_shell.tscn")
var shell
var mode := ""
var phase := ""
var directory := ""
var action_kind := "basic"
var boundary := ""

func _initialize() -> void:
    call_deferred("run_fixture")

func require(value: bool, message: String) -> bool:
    if not value:
        printerr("FRESH_SHELL_FAIL ", message)
        quit(1)
    return value

func run_fixture() -> void:
    var args := OS.get_cmdline_user_args()
    mode = args[0]
    phase = args[1]
    action_kind = "terminal" if phase.begins_with("terminal_") else ("martial" if phase.begins_with("martial_") else ("ultimate" if phase.begins_with("ultimate_") else "basic"))
    boundary = phase.trim_prefix("martial_").trim_prefix("ultimate_").trim_prefix("terminal_")
    directory = args[2]
    shell = SHELL.instantiate()
    shell.configure_save_storage(directory.path_join(phase))
    root.add_child(shell)
    await process_frame
    if mode == "read":
        var loaded_phase: String = str(shell.session.available.get("combat_checkpoint", {}).get("phase", ""))
        if not require(shell.continue_saved_run(), "continue " + phase): return
        var expected_phase := (("" if action_kind == "basic" else action_kind + "_") + "baseline") if boundary in ["committed", "resolved", "gap"] else phase
        var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(directory.path_join("expected-" + expected_phase + ".json")))
        var codec = preload("res://src/run/run_checkpoint_codec.gd")
        if not require(codec.digest(shell.run_state.export_snapshot()) == codec.digest(expected.run), "whole run restore " + phase): return
        if not expected.combat.is_empty():
            if not require(codec.digest(shell._combat_view.get_last_stable_checkpoint()) == codec.digest(expected.combat), "whole combat parity " + phase): return
        if boundary in ["committed", "resolved"] and loaded_phase in ["BUNDLE_COMMITTED", "BUNDLE_RESOLVED"]:
            if not require(codec.digest(shell._combat_view._last_review_summary) == codec.digest(expected.summary), "resolver summary parity " + phase): return
        print("FRESH_SHELL_READ PASS ", phase)
        shell.queue_free()
        await process_frame
        quit(0)
        return
    if not require(shell.start_new_run(), "start"): return
    for option in shell.starter_manual_catalog.get_options().slice(0, 4): shell.toggle_setup_manual(str(option.manual_id))
    if not require(shell.advance_noncombat() and shell.advance_noncombat() and shell.advance_noncombat(), "setup to combat"): return
    if boundary in ["committed", "resolved", "baseline", "gap"]:
        var board = shell._combat_view
        if action_kind == "terminal":
            # Synthetic initial HP only; actual dock and resolver produce terminal result.
            board.combat_state.enemy.health[0] = 1
            board.capture_planning_checkpoint()
            if boundary == "gap":
                var handler := Callable(shell, "_on_terminal_review_ready")
                board.terminal_review_ready.disconnect(handler)
                board.terminal_review_ready.connect(func(_result):
                    shell.session.store.io_guard = func(operation, _path): return operation != "write_primary")
                board.terminal_review_ready.connect(handler)
                board.terminal_review_ready.connect(func(_result):
                    if not require(shell.session.blocked and shell.session.last_durable.combat_checkpoint.phase == "BUNDLE_RESOLVED", "terminal pending gap retains durable resolution"): return
                    print("FRESH_SHELL_WRITE PASS ", phase)
                    quit(0))
        if action_kind == "ultimate":
            # Explicit module fixture: an already-earned full momentum gauge.
            board.combat_state.player.momentum[0] = 5
            board.capture_planning_checkpoint()
            board._sync_runtime_context()
            board._sync_action_selection_dock()
        if boundary in ["committed", "resolved"]:
            board.checkpoint_writer = func(dto: Dictionary):
                var accepted: bool = shell.session.write_combat(dto)
                if dto.phase == ("BUNDLE_COMMITTED" if boundary == "committed" else "BUNDLE_RESOLVED"):
                    print("FRESH_SHELL_WRITE PASS ", phase)
                    quit(0)
                    return false # End this process at the acknowledged boundary.
                return accepted
        var adapter = preload("res://src/ui/action_selection/action_view_model_adapter.gd").new()
        var guard: Dictionary
        for action in adapter.build_basic_actions():
            if action.id == "basic_guard": guard = action
        var selected: Dictionary = guard
        if action_kind == "terminal":
            for action in adapter.build_basic_actions():
                if action.id == "basic_heavy_attack": selected = action
        elif action_kind == "martial":
            for manual in adapter.build_owned_manuals(shell.run_state.get_player_manual_loadout(), shell.run_state.get_player_mastery_by_manual()):
                for action in manual.techniques:
                    if not action.locked and action.action_slots <= 3 and action.targeting_mode == "none": selected = action
        elif action_kind == "ultimate":
            for action in adapter.build_ultimate_actions(5, shell.run_state.get_player_manual_loadout(), shell.run_state.get_player_mastery_by_manual()):
                if not action.locked and action.action_slots <= 3 and action.targeting_mode == "none":
                    selected = action
                    break
        for i in range(3 - int(selected.action_slots)): board.action_selection_dock.request_action(guard)
        board.action_selection_dock.request_action(selected)
        if not require(board.action_timing_panel.is_current_bundle_complete(), "actual dock completes " + action_kind): return
        board.combat_progress_button.request_progress()
        if boundary != "baseline": return
        var deadline := Time.get_ticks_msec() + 20000
        while board._presentation_state not in ["next_bundle_ready", "terminal_result_ready"] and Time.get_ticks_msec() < deadline:
            await process_frame
        if not require(board._presentation_state in ["next_bundle_ready", "terminal_result_ready"], "uninterrupted baseline settles"): return
    elif phase in ["result", "pending_reward", "route", "retry", "completion"]:
        if phase == "retry":
            if not require(shell.complete_combat_for_runtime({"outcome": "loss", "review_causes": [{"event": "miss_range"}]}), "synthetic defeat fixture"): return
        else:
            var duel_count := 10 if phase == "completion" else 1
            for duel in range(duel_count):
                if not require(shell.complete_combat_for_runtime({"outcome": "win"}), "synthetic win fixture"): return
                if phase == "result": break
                if not require(shell.select_result_reward("free_training"), "pending reward"): return
                if phase == "pending_reward": break
                if duel == 9:
                    var published_title: String = shell.title_label.text
                    shell.session.store.io_guard = func(operation, _path): return operation != "write_primary"
                    if not require(not shell.advance_noncombat(), "completion failure freezes confirmation"): return
                    shell._render_current_screen()
                    shell._render_completion()
                    if not require(shell.title_label.text == published_title and shell.primary_button.disabled, "direct completion render cannot publish pending candidate"): return
                    shell.session.store.io_guard = Callable()
                    if not require(await shell.retry_durable_save(), "completion retry acknowledges once"): return
                elif not require(shell.advance_noncombat(), "confirm reward"): return
                if duel == 9: break
                for step in range(4):
                    var options: Array = shell.run_state.get_jianghu_options()
                    var choice: String = str(options[0].id)
                    for option in options:
                        if option.id == "rest": choice = str(option.id)
                    shell._choose_jianghu(choice, step)
                    if not require(not shell.run_state.get_pending_jianghu().is_empty(), "route effect pending"): return
                    if phase == "route": break
                    if not require(shell.advance_noncombat(), "advance selected route"): return
                if phase == "route": break
                if duel < 9 and not require(shell.advance_noncombat(), "next combat"): return
    var combat: Dictionary = shell._combat_view.get_last_stable_checkpoint() if shell.run_state.get_current_screen() == "COMBAT" else {}
    var expected_file := FileAccess.open(directory.path_join("expected-" + phase + ".json"), FileAccess.WRITE)
    expected_file.store_string(JSON.stringify({"run": shell.run_state.export_snapshot(), "combat": combat, "summary": shell._combat_view._last_review_summary if not combat.is_empty() else {}}))
    expected_file.close()
    print("FRESH_SHELL_WRITE PASS ", phase, " writes_ms=", shell.session.write_msec)
    shell.queue_free()
    await process_frame
    quit(0)
