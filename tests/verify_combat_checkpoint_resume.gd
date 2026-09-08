extends SceneTree

const BRIDGE = preload("res://scenes/run/vertical_slice_combat_bridge.tscn")
const STARTERS = ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]
var failures: Array[String] = []
var boundary_copies: Array = []
var veto_phase := ""
var run_state
var fixture_root := ""

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    run_state = load("res://src/run/vertical_slice_run_state.gd").new()
    run_state.configure_opponents(load("res://src/run/vertical_slice_opponent_catalog.gd").new(), 83)
    run_state.start_new_run()
    var mastery := {}
    for id in STARTERS: mastery[id] = 3
    run_state.confirm_setup_loadout(STARTERS, mastery)
    for i in range(3): run_state.advance()
    var arguments := OS.get_cmdline_user_args()
    if arguments.size() == 2:
        fixture_root = arguments[1]
        if arguments[0] == "--checkpoint-read":
            await _read_fixtures()
            _finish()
            return
    var board = await _board()
    if not board.has_method("capture_planning_checkpoint") or not board.has_method("restore_combat_checkpoint"):
        failures.append("Combat stable checkpoint and fail-closed restore APIs must exist")
    else:
        _expect(board.call("capture_planning_checkpoint"), "Capture planning")
        var dto: Dictionary = board.call("get_last_stable_checkpoint")
        var unconfigured = BRIDGE.instantiate()
        root.add_child(unconfigured)
        await process_frame
        var unconfigured_before: Dictionary = unconfigured.combat_state.duplicate(true)
        _expect(not unconfigured.call("restore_combat_checkpoint", _json(dto)).ok, "Reject restore before runtime binding configuration")
        _expect(unconfigured.combat_state == unconfigured_before, "Unconfigured restore has no partial mutation")
        unconfigured.queue_free()
        await process_frame
        _persist_fixture("planning", dto)
        _expect(load("res://src/run/run_checkpoint_codec.gd").new().validate_payload(run_state.export_snapshot(), dto).ok, "Run codec accepts bound COMBAT planning")
        var wrong_binding: Dictionary = _json(dto)
        wrong_binding.duel_index = 2
        _expect(not load("res://src/run/run_checkpoint_codec.gd").new().validate_payload(run_state.export_snapshot(), wrong_binding).ok, "Reject cross-duel combat")
        wrong_binding = _json(dto)
        var enemy_manual: String = wrong_binding.binding.enemy_loadout[0]
        wrong_binding.binding.enemy_mastery_by_manual[enemy_manual] = 10
        wrong_binding.binding.effective_enemy_mastery_by_manual[enemy_manual] = 10
        _expect(not load("res://src/run/run_checkpoint_codec.gd").new().validate_payload(run_state.export_snapshot(), wrong_binding).ok, "Reject fabricated enemy mastery")
        _expect(dto.get("phase") == "PLANNING", "Initial phase is planning")
        _expect(dto.enemy_lock.key == "", "Initial lazy enemy decision stays lazy")
        var restored = await _board()
        _expect(restored.call("restore_combat_checkpoint", _json(dto)).ok, "Planning JSON restores")
        _expect(restored.combat_state == dto.state, "Planning preserves entire state")
        _expect(restored.resolution_engine.export_enemy_lock() == dto.enemy_lock, "Planning preserves empty lock")
        var corrupt: Dictionary = _json(dto)
        corrupt.state.player.health = [-1, 30]
        var before: Dictionary = restored.combat_state.duplicate(true)
        _expect(not restored.call("restore_combat_checkpoint", corrupt).ok, "Corrupt resources rejected")
        _expect(restored.combat_state == before, "Reject without partial live mutation")
        var dead_enemy: Dictionary = _json(dto)
        dead_enemy.state.enemy.health = [0, 30]
        _expect(not restored.call("restore_combat_checkpoint", dead_enemy).ok, "Enemy cannot be terminal at a planning boundary")
        var carried_zero: Dictionary = _json(dto)
        carried_zero.state.player.health = [0, 30]
        var zero_run: Dictionary = run_state.export_snapshot()
        zero_run.progression.player_resources.health = [0, 30]
        zero_run.pre_battle_snapshot.progression.player_resources.health = [0, 30]
        _expect(load("res://src/run/run_checkpoint_codec.gd").new().validate_payload(zero_run, carried_zero).ok, "Preserve existing zero-HP carry at first combat planning")
        _expect(not load("res://src/run/run_checkpoint_codec.gd").new().validate_payload(run_state.export_snapshot(), carried_zero).ok, "Zero-HP entry must match carried run resources")
        _expect(not restored.call("restore_combat_checkpoint", carried_zero).ok, "Zero-HP entry requires configured carried resources")
        for corruption in ["tile", "status", "metrics", "seed", "unknown", "context", "binding", "unsupported_actor_field"]:
            var invalid: Dictionary = _json(dto)
            match corruption:
                "tile": invalid.state.enemy.tile = 11
                "status": invalid.state.player.statuses = ["not-a-status-record"]
                "metrics": invalid.state.battle_metrics.ultimate_uses = 0.25
                "seed": invalid.state.ai_decision_seed = "1"
                "unknown": invalid.state["hidden_plan"] = ["future"]
                "context": invalid.context.current_timing = 2
                "binding": invalid.binding.enemy_candidate_id = "unknown"
                "unsupported_actor_field": invalid.state.player["defense_records"] = "unsupported"
            _expect(not restored.call("restore_combat_checkpoint", invalid).ok, "Reject malformed " + corruption)
            _expect(restored.combat_state == before, "Preserve live state on " + corruption)
        restored.queue_free()
        await process_frame
        # A confirmed observation must survive without retaining an unsent reservation.
        board.combat_state.player.observation_points = 1
        board.combat_state.player.momentum = [5, 5]
        board.call("capture_planning_checkpoint")
        board.action_timing_panel.place_card(board.resolution_engine.cards_by_id.basic_guard, 1)
        _expect(not board.call("capture_planning_checkpoint"), "Partial placements cannot redefine planning baseline")
        board.combat_state.player.momentum = [0, 5]
        board._ultimate_reservation_anchors = PackedInt32Array([1])
        board.request_locked_enemy_action_type_reveal()
        dto = board.call("get_last_stable_checkpoint")
        _expect(dto.state.player.momentum == [5, 5], "Observation excludes unsent reserved momentum")
        _expect(dto.state.player.observation_points == 0, "Observation point spent once")
        restored = await _board()
        _expect(restored.call("restore_combat_checkpoint", _json(dto)).ok, "Observation restores")
        _expect(restored.combat_state.player.get("observation_reveals", []) == dto.state.player.get("observation_reveals", []), "No second reveal")
        _expect(restored.action_timing_panel.get_resolution_placements().is_empty(), "Unsent plan discarded")
        _expect(restored.resolution_engine.export_enemy_lock() == dto.enemy_lock, "Observed enemy lock unchanged")
        restored.queue_free()
        board.queue_free()
        await process_frame
        for outcome in ["ongoing", "win", "loss"]:
            await _committed_and_resolved(outcome)
        await _ultimate_resume()
        await _observation_without_plan()
        await _zero_health_carry_entry()
        board = null
    if is_instance_valid(board): board.queue_free()
    await process_frame
    _finish()

func _finish() -> void:
    for failure in failures: push_error(failure)
    print("COMBAT_CHECKPOINT_RESUME: %s (%d failures)" % ["PASS" if failures.is_empty() else "FAIL", failures.size()])
    quit(0 if failures.is_empty() else 1)

func _zero_health_carry_entry() -> void:
    var original = run_state
    run_state = load("res://src/run/vertical_slice_run_state.gd").new()
    _expect(run_state.import_snapshot(original.export_snapshot()).ok, "Clone run for real carry transitions")
    _expect(run_state.mark_combat_finished({"outcome": "draw", "player_resources": {"health": [0, 30], "stamina": [5, 5], "internal": [4, 4]}}), "Existing draw accepts zero-health carry")
    _expect(run_state.advance(), "Draw Review to Result")
    _expect(run_state.set_pending_result_reward({"reward_type": "free_training", "free_training": 6}), "Draw selects existing reward")
    _expect(run_state.advance(), "Draw Result to Jianghu")
    for step in range(4):
        var selected := ""
        for option in run_state.get_jianghu_options():
            if option.id != "rest":
                selected = option.id
                break
        _expect(run_state.select_jianghu_node(selected, step), "Select offered non-healing route")
        _expect(run_state.advance(), "Confirm route")
    _expect(run_state.advance(), "Next briefing to combat")
    _expect(run_state.duel_index == 2 and run_state.get_player_run_resources().health == [0, 30], "Existing domain preserves zero health into duel two")
    var board = await _board()
    _expect(board.capture_planning_checkpoint(), "Capture legitimate zero-health entry")
    var dto: Dictionary = _json(board.get_last_stable_checkpoint())
    _expect(load("res://src/run/run_checkpoint_codec.gd").new().validate_payload(run_state.export_snapshot(), dto).ok, "Validate genuine draw-route-entry envelope")
    var restored = await _board()
    _expect(restored.restore_combat_checkpoint(dto).ok, "Restore genuine configured zero-health entry")
    _expect(restored.combat_state == load("res://src/run/combat_checkpoint_codec.gd").portable(dto.state), "Zero-health entry restored without inventing recovery")
    board.queue_free()
    restored.queue_free()
    await process_frame
    run_state = original

func _persist_fixture(label: String, dto: Dictionary) -> void:
    if fixture_root.is_empty(): return
    var store = load("res://src/run/run_save_store.gd").new(fixture_root.path_join(label))
    var started := Time.get_ticks_usec()
    var result: Dictionary = store.save_checkpoint("native-fresh-process", label, run_state.export_snapshot(), dto)
    _expect(result.ok, "Write independent-process " + label + " " + str(result.get("error", "")))
    print("CHECKPOINT_SAMPLE ", label, " dto_bytes=", JSON.stringify(dto).to_utf8_buffer().size(), " write_ms=", (Time.get_ticks_usec() - started) / 1000.0)

func _read_fixtures() -> void:
    for label in ["planning", "ongoing-committed", "ongoing-resolved", "win-resolved", "loss-resolved"]:
        var store = load("res://src/run/run_save_store.gd").new(fixture_root.path_join(label))
        var loaded: Dictionary = store.load_checkpoint()
        _expect(loaded.ok, "Read independent-process " + label)
        if not loaded.ok: continue
        var dto: Dictionary = loaded.payload.combat_checkpoint
        var board = await _board()
        var receipts: Array = []
        board.terminal_review_ready.connect(func(receipt): receipts.append(receipt))
        _expect(board.call("restore_combat_checkpoint", dto).ok, "Fresh process restores " + label)
        if label == "planning":
            _expect(board.combat_state == dto.state, "Fresh planning exact state")
        elif label.begins_with("ongoing"):
            _expect(board.combat_state.bundle_index == 2, "Fresh ongoing advances exactly one bundle")
            if label == "ongoing-committed":
                var expected: Dictionary = load("res://src/run/run_save_store.gd").new(fixture_root.path_join("ongoing-resolved")).load_checkpoint().payload.combat_checkpoint
                _expect(board.combat_state.player.health == expected.state.player.health and board.combat_state.battle_metrics == expected.state.battle_metrics, "Fresh committed equals saved authoritative result")
        else:
            _expect(receipts.size() == 1 and receipts[0].outcome == label.trim_suffix("-resolved"), "Fresh terminal result exactly once")
        board.queue_free()
        await process_frame

func _ultimate_resume() -> void:
    var board = await _board()
    board.combat_state.player.momentum = [5, 5]
    board.combat_state.player.prepare_active = true
    board.combat_state.player.next_attack_bonus = 2
    board.combat_state.player.fortitude_next_attack = true
    board.combat_state.player.status_counts = {"강건": 1}
    board.combat_state.player.battle_uses = {"once": false}
    board.combat_state.player.defense = 3
    board.combat_state.enemy.observation_points = 2
    board.combat_state.enemy.health = [300, 300] # Nonterminal synthetic target for multi-bundle reservation lifetime.
    board.combat_state.ai_decision_seed = 742
    board.call("capture_planning_checkpoint")
    var definition: Dictionary = board.resolution_engine.cards_by_id.ultimate_void_sword_qi
    _expect(board.action_timing_panel.place_card(definition, 1), "Place actual ultimate")
    board._reserve_ultimate_at(1)
    for i in range(1 + int(definition.action_slots), 4): board.action_timing_panel.place_card(board.resolution_engine.cards_by_id.basic_guard, i)
    board.set("checkpoint_writer", Callable(self, "_write_boundary"))
    veto_phase = "BUNDLE_COMMITTED"
    await board._on_progress_requested(board.action_timing_panel.get_runtime_context())
    var committed: Dictionary = board.call("get_last_stable_checkpoint")
    _expect(load("res://src/run/combat_checkpoint_codec.gd").new().validate(_json(committed)).ok, "Actual ultimate DTO independently validates")
    _expect(committed.phase == "BUNDLE_COMMITTED" and committed.state.player.momentum[0] == 0, "Commit includes already spent ultimate")
    var bad: Dictionary = _json(committed)
    bad.enemy_lock.actions[0]["cancelled"] = true
    _expect(not load("res://src/run/combat_checkpoint_codec.gd").new().validate(bad).ok, "Reject hidden action cancellation field")
    bad = _json(committed)
    bad.player_plan[0].definition["damage"] = 999
    _expect(not load("res://src/run/combat_checkpoint_codec.gd").new().validate(bad).ok, "Reject altered action definition")
    var restored = await _board()
    var copies: Array = []
    restored.set("checkpoint_writer", func(dto): copies.append(dto); return false)
    _expect(restored.call("restore_combat_checkpoint", _json(committed)).ok, "Ultimate committed resumes")
    if not copies.is_empty():
        _expect(copies[0].state.battle_metrics.ultimate_uses == 1, "Ultimate executed exactly once")
        _expect(copies[0].state.ai_decision_seed == 742, "Existing AI seed preserved, run seed not connected")
        veto_phase = "BUNDLE_RESOLVED"
        await board.call("retry_checkpoint")
        _expect(board.call("get_last_stable_checkpoint").state == copies[0].state, "Ultimate resources/status/preparation/metrics exactly match uninterrupted")
        veto_phase = ""
        await board.call("retry_checkpoint")
        _expect(board.call("get_last_stable_checkpoint").phase == "PLANNING", "Resolved acknowledgment advances to stable planning")
        veto_phase = "BUNDLE_COMMITTED"
        for i in [4, 5, 6]: board.action_timing_panel.place_card(board.resolution_engine.cards_by_id.basic_guard, i)
        await board._on_progress_requested(board.action_timing_panel.get_runtime_context())
        _expect(load("res://src/run/combat_checkpoint_codec.gd").new().validate(_json(board.call("get_last_stable_checkpoint"))).ok, "Later commitment excludes already resolved ultimate reservation")
    board.queue_free()
    restored.queue_free()
    await process_frame

func _actor_owned_actions(board, committed: Dictionary) -> void:
    var engine = board.resolution_engine
    var player_only := ""
    var enemy_only := ""
    for id in engine.get_player_martial_card_ids():
        if id not in engine.get_enemy_martial_card_ids() and engine.cards_by_id[id].get("action_slots", 1) == 1:
            player_only = id
            break
    for id in engine.get_enemy_martial_card_ids():
        if id not in engine.get_player_martial_card_ids() and engine.cards_by_id[id].get("action_slots", 1) == 1:
            enemy_only = id
            break
    _expect(not player_only.is_empty() and not enemy_only.is_empty(), "Actor ownership fixture has distinct unlocked martial actions")
    if player_only.is_empty() or enemy_only.is_empty(): return
    var shared: Dictionary = _json(committed)
    var shared_manual: String = shared.binding.enemy_loadout[0]
    shared.binding.player_loadout[0] = shared_manual
    shared.binding.player_mastery_by_manual[shared_manual] = shared.binding.enemy_mastery_by_manual[shared_manual]
    var shared_codec = load("res://src/run/combat_checkpoint_codec.gd").new()
    var shared_engine = shared_codec._engine(shared_codec.portable(shared.binding))
    _expect(shared_engine != null, "Shared manual fixture rebuilds actual actor bindings")
    if shared_engine != null:
        var definition: Dictionary = _json(shared_engine.cards_by_id[enemy_only])
        shared.player_plan[0].definition = definition
        shared.player_plan[0].card_id = enemy_only
        shared.player_plan[0].card_name = definition.get("name", enemy_only)
        var action: Dictionary = shared.enemy_lock.actions[0].duplicate(true)
        action.definition = definition
        action.anchor_index = 1
        action.span = 1
        action.execution_timing = 1
        shared.enemy_lock.actions = [action]
        for state in [shared.state, shared.state_before]:
            state.player.stamina = [100, 100]
            state.player.internal = [100, 100]
        _expect(shared_codec.validate(shared).ok, "Same unlocked manual remains legal for both actors")
        # Combat-module binding can represent higher mastery independently of the
        # full-run progression validator, which still owns current earned growth.
        shared.binding.player_mastery_by_manual[shared_manual] = 5
        shared_engine = shared_codec._engine(shared_codec.portable(shared.binding))
        shared.player_plan[0].definition = _json(shared_engine.get_actor_card_definition(enemy_only, "player"))
        shared.enemy_lock.actions[0].definition = _json(shared_engine.get_actor_card_definition(enemy_only, "enemy"))
        _expect(shared_codec.validate(shared).ok, "Strict DTO accepts unequal actor effective definitions for one ID")
        var opposite: Dictionary = _json(shared)
        opposite.player_plan[0].definition = opposite.enemy_lock.actions[0].definition.duplicate(true)
        _expect(not shared_codec.validate(opposite).ok, "Strict DTO rejects same-ID opposite mastery in player plan")
        opposite = _json(shared)
        opposite.enemy_lock.actions[0].definition = opposite.player_plan[0].definition.duplicate(true)
        _expect(not shared_codec.validate(opposite).ok, "Strict DTO rejects same-ID opposite mastery in enemy lock")
    for actor in ["player", "enemy"]:
        for valid_owner in [true, false]:
            var dto: Dictionary = _json(committed)
            var id: String = (player_only if valid_owner else enemy_only) if actor == "player" else (enemy_only if valid_owner else player_only)
            var definition: Dictionary = _json(engine.cards_by_id[id])
            for state in [dto.state, dto.state_before]:
                state.player.stamina = [100, 100]
                state.player.internal = [100, 100]
            if actor == "player":
                dto.player_plan[0].definition = definition
                dto.player_plan[0].card_id = id
                dto.player_plan[0].card_name = definition.get("name", id)
            else:
                var action: Dictionary = dto.enemy_lock.actions[0].duplicate(true)
                action.definition = definition
                action.anchor_index = 1
                action.span = 1
                action.execution_timing = 1
                dto.enemy_lock.actions = [action]
            var validation: Dictionary = load("res://src/run/combat_checkpoint_codec.gd").new().validate(dto)
            _expect(validation.ok == valid_owner, "Actor-owned canonical definition membership: " + actor + " valid=" + str(valid_owner))
            if not valid_owner:
                var target = await _board()
                target.checkpoint_writer = func(_dto): return false
                var before: Dictionary = target.combat_state.duplicate(true)
                var lock_before: Dictionary = target.resolution_engine.export_enemy_lock()
                _expect(not target.restore_combat_checkpoint(dto).ok, "Cross-actor restore rejected: " + actor)
                _expect(target.combat_state == before and target.resolution_engine.export_enemy_lock() == lock_before and target._resolution_count == 0, "Cross-actor rejection preserves live state and lock: " + actor)
                target.queue_free()
                await process_frame

func _observation_without_plan() -> void:
    var board = await _board()
    board.combat_state.player.observation_points = 1
    board.call("capture_planning_checkpoint")
    board.request_locked_enemy_action_type_reveal()
    var dto: Dictionary = board.call("get_last_stable_checkpoint")
    var restored = await _board()
    _expect(restored.call("restore_combat_checkpoint", _json(dto)).ok, "Observation without placements restores")
    _expect(restored.combat_state.player.observation_points == 0, "Observation without placements is not refunded")
    _expect(restored.resolution_engine.export_enemy_lock() == dto.enemy_lock, "Observation without placements retains actual lock")
    restored.request_locked_enemy_action_type_reveal()
    _expect(restored.combat_state.player.observation_reveals.size() == 1, "Explicit repeated reveal without points adds nothing")
    board.queue_free()
    restored.queue_free()
    await process_frame

func _expect(value: bool, message: String) -> void:
    if not value:
        failures.append(message)
        print("FAIL: ", message)

func _json(value):
    return JSON.parse_string(JSON.stringify(value))

func _board():
    var board = BRIDGE.instantiate()
    root.add_child(board)
    await process_frame
    var opponent: Dictionary = run_state.get_current_opponent()
    var binding: Dictionary = load("res://src/run/vertical_slice_opponent_runtime_binding.gd").new().build(opponent)
    var manual: String = opponent.signature_manual_id
    _expect(board.configure_vertical_slice_loadouts(STARTERS, run_state.get_player_mastery_by_manual(), [manual], {manual: opponent.signature_star_seed}, opponent.candidate_id, binding, {"name": opponent.working_name, "epithet": opponent.martial_identity}, run_state.get_frozen_bimu_receipt()), "Configure actual runtime binding")
    board.apply_vertical_slice_player_resources(run_state.get_player_run_resources())
    board.configure_checkpoint_identity(run_state.duel_index, int(run_state.export_snapshot().attempt_id))
    return board

func _write_boundary(dto: Dictionary) -> bool:
    boundary_copies.append(dto.duplicate(true))
    return dto.phase != veto_phase

func _committed_and_resolved(outcome: String) -> void:
    var board = await _board()
    if outcome == "win": board.combat_state.enemy.health = [0, 30]
    if outcome == "loss": board.combat_state.player.health = [0, 30]
    board.call("capture_planning_checkpoint")
    board.set("checkpoint_writer", Callable(self, "_write_boundary"))
    boundary_copies.clear()
    veto_phase = "BUNDLE_COMMITTED"
    for i in [1, 2, 3]: board.action_timing_panel.place_card(board.resolution_engine.cards_by_id.basic_guard, i)
    await board._on_progress_requested(board.action_timing_panel.get_runtime_context())
    _expect(board._resolution_count == 0, "Persistence veto prevents resolution")
    var committed: Dictionary = board.call("get_last_stable_checkpoint")
    if outcome == "ongoing": await _actor_owned_actions(board, committed)
    var no_resource: Dictionary = _json(committed)
    no_resource.state.player.stamina = [0, 5]
    no_resource.state_before.player.stamina = [0, 5]
    _expect(not load("res://src/run/combat_checkpoint_codec.gd").new().validate(no_resource).ok, "Reject committed plan that cannot pay its validated costs")
    _expect(committed.phase == "BUNDLE_COMMITTED", "Commit frozen before resolve")
    _expect(board._inputs_locked(), "Veto keeps commitment frozen")
    var final_dtos: Array = []
    # Resume a saved committed plan once, stopping at resolved persistence ack.
    var restored = await _board()
    restored.set("checkpoint_writer", func(dto: Dictionary) -> bool:
        final_dtos.append(dto.duplicate(true))
        return false)
    _expect(restored.call("restore_combat_checkpoint", _json(committed)).ok, "Committed JSON restores")
    _expect(final_dtos.size() == 1 and final_dtos[0].phase == "BUNDLE_RESOLVED", "Committed resolves once to final boundary")
    if final_dtos.is_empty():
        board.queue_free()
        restored.queue_free()
        return
    var resolved: Dictionary = final_dtos[0]
    if outcome != "ongoing":
        var reclassified: Dictionary = _json(resolved)
        reclassified.phase = "PLANNING"
        reclassified.player_plan = []
        reclassified.reservation_anchors = []
        reclassified.state_before = {}
        reclassified.review_summary = {}
        _expect(not load("res://src/run/combat_checkpoint_codec.gd").new().validate(reclassified).ok, "Resolved terminal cannot masquerade as planning")
    var bad_summary: Dictionary = _json(resolved)
    bad_summary.review_summary["future_enemy_actions"] = ["private"]
    _expect(not load("res://src/run/combat_checkpoint_codec.gd").new().validate(bad_summary).ok, "Reject future-action summary fields")
    if outcome == "ongoing": _persist_fixture("ongoing-committed", committed)
    _persist_fixture(outcome + "-resolved", resolved)
    _expect(load("res://src/run/run_checkpoint_codec.gd").new().validate_payload(run_state.export_snapshot(), resolved).ok, "Store codec accepts actual resolved bundle")
    _expect(resolved.enemy_lock == committed.enemy_lock, "Resolve never replans enemy")
    veto_phase = "BUNDLE_RESOLVED"
    await board.call("retry_checkpoint")
    _expect(board._resolution_count == 1, "Resolved write veto still records exactly one resolver invocation")
    _expect(board.call("get_last_stable_checkpoint").state == resolved.state, "Uninterrupted and committed restore have identical final state")
    var resumed = await _board()
    var receipts: Array = []
    var confirmations: Array = []
    resumed.terminal_review_ready.connect(func(result): receipts.append(result))
    resumed.terminal_review_confirmed.connect(func(result): confirmations.append(result))
    _expect(resumed.call("restore_combat_checkpoint", _json(resolved)).ok, "Resolved JSON restores")
    _expect(resumed.get_meta("last_review_summary", {}) == resolved.review_summary, "Common finalize publishes authoritative summary metadata")
    _expect(resumed._resolution_count == 0, "Resolved restore does not rerun resolver")
    if outcome == "ongoing":
        _expect(resumed.combat_state.bundle_index == 2, "Nonterminal resolved advances exactly one bundle")
    else:
        _expect(receipts.size() == 1 and receipts[0].outcome == outcome, "Terminal ready receipt once in exact pre-deferred gap")
        _expect(not resumed.call("capture_planning_checkpoint"), "Terminal state cannot be recaptured as planning")
        _expect(receipts[0].player_resources == {"health": resolved.state.player.health, "stamina": resolved.state.player.stamina, "internal": resolved.state.player.internal}, "Terminal receipt uses final resources")
        _expect(resumed.call("restore_combat_checkpoint", _json(resolved)).ok, "Repeated same resolved restore acknowledged")
        _expect(receipts.size() == 1, "Repeated resolved boundary emits no duplicate terminal")
        _expect(confirmations.is_empty(), "Ready-to-deferred-confirmed crash gap is exercised")
        await process_frame
        resumed._confirm_terminal_result_once()
        _expect(confirmations.size() == 1, "Deferred terminal confirmation is exactly once")
    _expect(not resumed.get_meta("presentation_future_action_exposed", false), "No UI future-action disclosure")
    for b in [board, restored, resumed]: b.queue_free()
    await process_frame
