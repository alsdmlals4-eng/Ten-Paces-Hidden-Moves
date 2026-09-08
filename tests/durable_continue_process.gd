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

# Explicit combat-module fixtures can carry mastery5/7 before growth spending is
# implemented. Full-run shell fixtures below keep their actual legal progression.
class RecordingActorEngine extends VerticalSliceMetricsCombatResolutionEngine:
    var actual_results: Array = []
    func resolve_bundle(placements: Array, context: Dictionary, state: Dictionary) -> Dictionary:
        var result := super.resolve_bundle(placements, context, state)
        actual_results.append(result.duplicate(true))
        return result

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
    directory = args[2]
    if phase.begins_with("actor_"):
        await _actor_process_fixture()
        return
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

func _actor_process_fixture() -> void:
    var codec = preload("res://src/run/combat_checkpoint_codec.gd").new()
    var digest_codec = preload("res://src/run/run_checkpoint_codec.gd")
    var orientation := phase.get_slice("_", 1)
    var board = preload("res://scenes/run/vertical_slice_combat_bridge.tscn").instantiate()
    root.add_child(board)
    await process_frame
    var opponent: Dictionary = {}
    for candidate in preload("res://src/run/vertical_slice_opponent_catalog.gd").new().get_all_candidates():
        if (orientation == "low" and candidate.signature_manual_id == "shaolin_arhat_vajra_art" and candidate.signature_star_seed == 7) or (orientation == "high" and candidate.signature_manual_id == "mount_hua_plum_blossom_sword" and candidate.signature_star_seed == 3):
            opponent = candidate
            break
    if not require(not opponent.is_empty(), "canonical unequal-mastery opponent"): return
    var manual: String = opponent.signature_manual_id
    var player_mastery := 3 if orientation == "low" else 5
    var loadout: Array = [manual]
    for id in board.resolution_engine.martial_registry.get_manual_ids():
        if id != manual and loadout.size() < 4: loadout.append(id)
    var mastery := {}
    for id in loadout: mastery[id] = player_mastery
    var runtime: Dictionary = preload("res://src/run/vertical_slice_opponent_runtime_binding.gd").new().build(opponent)
    if not require(board.configure_vertical_slice_loadouts(loadout, mastery, [manual], {manual: opponent.signature_star_seed}, opponent.candidate_id, runtime, {}, {"selections": [], "enemy_candidate_id": opponent.candidate_id}), "configured shared manual"): return
    var recorder = RecordingActorEngine.new()
    recorder.configure_bimu_constraints([], loadout, [manual])
    recorder.configure_enemy_runtime_binding(runtime)
    recorder.configure_martial_loadouts(loadout, mastery, [manual], {manual: opponent.signature_star_seed})
    # Explicit opponent action fixture; the ordinary campaign below uses public AI.
    # Lock construction and both effect programs still use the production resolver.
    recorder.rules["enemy_bundles"] = {"1": [{"card_id": manual + "_star3", "timing": 1, "targeting_mode": "none"}]}
    board.resolution_engine = recorder
    var receipts: Array = []
    board.terminal_review_ready.connect(func(value): receipts.append(value))
    var copies: Array = []
    board.checkpoint_writer = func(dto): copies.append(dto.duplicate(true)); return false
    var fixture_path := directory.path_join("actor-" + orientation + ".json")
    if mode == "write":
        var adapter = preload("res://src/ui/action_selection/action_view_model_adapter.gd").new()
        var selected: Dictionary = {}
        for group in adapter.build_owned_manuals(loadout, mastery):
            for action in group.techniques:
                if action.id == manual + "_star3": selected = action
        var guard: Dictionary = {}
        for action in adapter.build_basic_actions():
            if action.id == "basic_guard": guard = action
        board.action_selection_dock.request_action(selected)
        for i in range(3 - int(selected.action_slots)): board.action_selection_dock.request_action(guard)
        if not require(board.action_timing_panel.is_current_bundle_complete(), "actor actual dock complete"): return
        var produced: Array = board.action_timing_panel.get_resolution_placements()
        if not require(digest_codec.digest(produced[0].definition) == digest_codec.digest(selected), "exact actual adapter producer"): return
        board.combat_progress_button.request_progress()
        var committed: Dictionary = board.get_last_stable_checkpoint()
        if not require(committed.phase == "BUNDLE_COMMITTED" and codec.validate(committed).ok, "strict actor commitment " + str(codec.validate(committed))): return
        if not require(digest_codec.digest(committed.player_plan[0].definition) == digest_codec.digest(recorder.get_actor_card_definition(manual + "_star3", "player")), "saved plan equals own canonical map"): return
        if not require(committed.enemy_lock.actions.size() == 1 and committed.enemy_lock.actions[0].definition.id == manual + "_star3", "enemy lock actually contains the shared martial ID"): return
        for action in committed.enemy_lock.actions:
            if not require(digest_codec.digest(action.definition) == digest_codec.digest(recorder.get_actor_card_definition(action.definition.id, "enemy")), "saved enemy lock equals own mastery"): return
        var wrong := committed.duplicate(true)
        wrong.player_plan[0].definition = recorder.get_actor_card_definition(manual + "_star3", "enemy")
        if not require(not codec.validate(wrong).ok, "strict saved same-ID opposite mastery rejected"): return
        var before: Dictionary = board.combat_state.duplicate(true)
        var lock_before: Dictionary = recorder.export_enemy_lock()
        if not require(not board.restore_combat_checkpoint(wrong).ok and board.combat_state == before and recorder.export_enemy_lock() == lock_before and recorder.actual_results.is_empty(), "forged restore leaves live state untouched"): return
        # Producer validation accepts exact UI metadata, but never arbitrary decoration.
        board._committed_player_plan_snapshot[0].definition["forged_ui_key"] = true
        if not require(board._checkpoint_domain_plan().is_empty(), "bridge rejects unauthored UI metadata"): return
        board._committed_player_plan_snapshot = produced.duplicate(true)
        board.checkpoint_writer = func(dto): copies.append(dto.duplicate(true)); return dto.phase != "BUNDLE_RESOLVED"
        await board.retry_checkpoint()
        var resolved: Dictionary = board.get_last_stable_checkpoint()
        if not require(resolved.phase == "BUNDLE_RESOLVED" and codec.validate(resolved).ok and recorder.actual_results.size() == 1, "uninterrupted actor resolve once"): return
        var file := FileAccess.open(fixture_path, FileAccess.WRITE)
        file.store_string(JSON.stringify({"committed": committed, "resolved": resolved, "actual_result": recorder.actual_results[0], "receipts": receipts, "reservations": Array(board._ultimate_reservation_anchors)}))
        file.close()
        print("FRESH_ACTOR_WRITE PASS ", orientation, " player=", player_mastery, " enemy=", opponent.signature_star_seed)
    else:
        var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(fixture_path))
        var boundary_name := phase.get_slice("_", 2)
        var dto: Dictionary = fixture[boundary_name]
        if not require(codec.validate(dto).ok and board.restore_combat_checkpoint(dto).ok, "fresh actor boundary restores"): return
        if boundary_name == "committed":
            if not require(recorder.actual_results.size() == 1 and digest_codec.digest(recorder.actual_results[0]) == digest_codec.digest(fixture.actual_result), "fresh actor state and full effect events equal uninterrupted"): return
            if not require(digest_codec.digest(board.get_last_stable_checkpoint()) == digest_codec.digest(fixture.resolved), "fresh actor resolved DTO parity"): return
        else:
            if not require(recorder.actual_results.is_empty() and board._resolution_count == 0, "persisted actor RESOLVED never invokes resolver"): return
            for key in ["player", "enemy", "battle_metrics", "public_resolution_history"]:
                if not require(digest_codec.digest(board.combat_state.get(key)) == digest_codec.digest(fixture.resolved.state.get(key)), "resolved actor authoritative " + key): return
        if not require(digest_codec.digest(receipts) == digest_codec.digest(fixture.receipts), "actor receipt count and values match"): return
        if boundary_name == "committed":
            if not require(Array(board._ultimate_reservation_anchors) == fixture.reservations and digest_codec.digest(recorder.export_enemy_lock()) == digest_codec.digest(fixture.resolved.enemy_lock), "actor reservation and enemy lock parity"): return
        print("FRESH_ACTOR_READ PASS ", phase)
    board.queue_free()
    await process_frame
    quit(0)
