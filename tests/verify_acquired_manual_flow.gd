extends SceneTree

const RUN = preload("res://src/run/vertical_slice_run_state.gd")
const CODEC = preload("res://src/run/run_checkpoint_codec.gd")
const REGISTRY = preload("res://src/combat/martial_manual_registry.gd")
const RESULT = preload("res://src/run/vertical_slice_result_model.gd")
var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
    create_timer(120.0).timeout.connect(func(): printerr("ACQUIRED_MANUAL_TIMEOUT"); quit(1))
    call_deferred("_run")

func check(value: bool, label: String) -> bool:
    checks += 1
    if not value:
        failures.append(label)
        push_error(label)
    return value

func _run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() >= 2 and args[0] == "--resume":
        await _resume_fixture(args[1])
        print("ACQUIRED_MANUAL_RESUME checks=%d failures=%d" % [checks, failures.size()])
        quit(0 if failures.is_empty() else 1)
        return
    for variable in [false, true]:
        await _campaign(variable)
    print("ACQUIRED_MANUAL_FLOW checks=%d failures=%d" % [checks, failures.size()])
    quit(0 if failures.is_empty() else 1)

func _campaign(variable: bool) -> void:
    var run = RUN.new()
    if variable:
        # Fixed approved generator seed: six non-starter signatures occur before duel ten.
        check(run.start_new_variable_run(34, "acquisition"), "Initialize v2")
    else:
        run.configure_opponents(load("res://src/run/vertical_slice_opponent_catalog.gd").new(), 42)
        check(run.start_new_run(), "Initialize v1")
    var first: String = run.get_current_opponent().signature_manual_id
    var starters: Array = []
    var mastery := {}
    for id in load("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS:
        if id != first and starters.size() < 4:
            starters.append(id)
            mastery[id] = 3
    check(run.confirm_setup_loadout(starters, mastery), "Four valid starters exclude first transfer")
    for _step in range(3): check(run.advance(), "Enter first combat")
    if not check(run.has_method("get_owned_player_manuals"), "Acquired-manual view must exist separately from starter history"):
        return
    check(run.get_owned_player_manuals() == starters, "Initial owned view matches four starters")
    for duel in range(1, 11):
        var opponent: Dictionary = run.get_current_opponent()
        var owned: Array = run.get_owned_player_manuals()
        if duel == 2 or owned.size() == 10:
            await _combat_boundary(run, starters)
        # Explicit synthetic terminal: valid domain history, not native combat-win evidence.
        check(run.mark_combat_finished({"outcome":"win", "player_health":30, "enemy_health":0, "player_resources":run.get_player_run_resources()}), "Finish synthetic duel")
        check(run.advance(), "Review to result")
        if duel == 2:
            var focused_run = RUN.new()
            check(focused_run.import_snapshot(run.export_snapshot()).ok, "Fork acquired reward boundary")
            var focused: Dictionary = RESULT.new().build_reward_receipt("focused_training", first, owned, opponent)
            check(focused_run.set_pending_result_reward(focused), "Focus newly acquired manual")
            check(focused_run.validate_snapshot(focused_run.export_snapshot()).ok, "Pending acquired training saves")
            check(focused_run.advance(), "Confirm acquired training")
            check(focused_run.validate_snapshot(focused_run.export_snapshot()).ok, "Confirmed acquired training saves")
        var receipt: Dictionary = RESULT.new().build_reward_receipt("faction_transfer", "", owned, opponent)
        if receipt.is_empty(): receipt = RESULT.new().build_reward_receipt("free_training", "", owned, opponent)
        check(run.set_pending_result_reward(receipt), "Select new signature or available alternative")
        check(run.advance(), "Confirm transfer once")
        check(run.get_player_manual_loadout() == starters, "Starter history remains immutable")
        check(run.get_owned_player_manuals() == run.get_progression_snapshot().owned_manual_ids, "Owned view follows reward history")
        if duel == 1: check(run.get_owned_player_manuals().size() == 5, "First transfer creates fifth usable manual")
        var snapshot: Dictionary = run.export_snapshot()
        var saved: Dictionary = CODEC.new().encode("acquisition", "reward-%d" % duel, duel, snapshot)
        if not check(saved.ok, "Reward boundary saves with acquisition history: " + str(saved)):
            return
        var decoded: Dictionary = CODEC.new().decode(saved.text)
        check(decoded.ok, "Acquisition envelope decodes")
        var restored = RUN.new()
        check(restored.import_snapshot(decoded.payload.run_state).ok, "Fresh run restores acquisition history")
        check(restored.get_owned_player_manuals() == run.get_owned_player_manuals(), "Restored acquired list identical")
        var forged := snapshot.duplicate(true)
        forged.progression.owned_manual_ids.append("unearned")
        check(not RUN.new().validate_snapshot(forged).ok, "Forged acquisition rejected")
        if duel == 10: break
        for step in range(4):
            var options: Array = run.get_jianghu_options()
            check(run.select_jianghu_node(str(options[0].id), step), "Choose offered route")
            check(run.advance(), "Advance route once")
        if duel == 1: await _seal_boundary(run)
        check(run.advance(), "Next combat uses current owned list")
    print("ACQUIRED_ROSTER variable=%s owned=%d" % [variable, run.get_owned_player_manuals().size()])
    if variable: check(run.get_owned_player_manuals().size() == 10, "Earn all ten through actual signature receipts")

func _seal_boundary(run) -> void:
    var candidate = RUN.new()
    check(candidate.import_snapshot(run.export_snapshot()).ok, "Fork acquired briefing")
    var panel = load("res://src/ui/bimu_constraint_panel.gd").new()
    root.add_child(panel)
    panel.configure(candidate, REGISTRY.new())
    var selector: OptionButton = panel.target_selectors.CST_TECH_MANUAL_SEAL
    selector.select(4)
    var target: String = selector.get_item_metadata(4)
    check(await _activate(panel.option_buttons.CST_TECH_MANUAL_SEAL), "Native acquired seal selection")
    check(candidate.get_pending_bimu_constraints()[0].target_manual_id == target, "Selector passes earned target to domain")
    check(candidate.advance(), "Freeze earned manual seal")
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    check(shell.run_state.import_snapshot(candidate.export_snapshot()).ok, "Import frozen acquired seal")
    shell._publish_session_screen()
    await process_frame
    var bridge = shell._combat_view
    var card_id: String = REGISTRY.new().build_unlocked_cards(target, 3)[0].id
    check(not bridge.resolution_engine.get_action_lock_reason(card_id).is_empty(), "Actual engine enforces acquired manual seal")
    bridge.configure_checkpoint_identity(candidate.duel_index, 0)
    bridge.capture_planning_checkpoint()
    check(CODEC.new().validate_payload(candidate.export_snapshot(), bridge.get_last_stable_checkpoint()).ok, "Acquired seal checkpoint validates")
    panel.queue_free()
    shell.queue_free()
    await process_frame

func _combat_boundary(run, starters: Array) -> void:
    var panel = load("res://src/ui/bimu_constraint_panel.gd").new()
    root.add_child(panel)
    panel.configure(run, REGISTRY.new())
    for option in panel._options:
        if option.get("parameter_binding", {}).get("field", "") == "target_manual_id":
            check(panel.target_selectors[option.constraint_id].item_count == run.get_owned_player_manuals().size(), "Actual seal selector includes acquisitions")
    panel.queue_free()
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    if not check(shell.run_state.import_snapshot(run.export_snapshot()).ok, "Shell imports valid acquired run"):
        shell.queue_free()
        await process_frame
        return
    shell._publish_session_screen()
    await process_frame
    var bridge = shell._combat_view
    if not check(bridge != null and bridge.get_meta("vertical_slice_runtime_loadout_bound", false), "Actual shell binds acquired manuals"):
        shell.queue_free()
        await process_frame
        return
    bridge.configure_checkpoint_identity(run.duel_index, 0)
    check(bridge.capture_planning_checkpoint(), "Capture current duel boundary")
    var dto: Dictionary = bridge.get_last_stable_checkpoint()
    check(dto.get("binding", {}).get("player_loadout", []) == run.get_owned_player_manuals(), "Checkpoint binds all earned manuals")
    var validation: Dictionary = CODEC.new().validate_payload(run.export_snapshot(), dto)
    check(validation.ok, "Run and combat ownership cross-validation: " + str(validation.get("error", "")))
    var args := OS.get_cmdline_user_args()
    if args.size() >= 2 and args[0] == "--legacy-codec" and run.get_owned_player_manuals().size() == 5:
        var legacy := dto.duplicate(true)
        legacy.binding.erase("owned_binding_version")
        legacy.binding.player_loadout = starters.duplicate()
        var baseline = load(args[1]).new()
        var old: Dictionary = baseline.encode("acquisition", "legacy-combat", 2, run.export_snapshot(), legacy)
        check(old.ok, "Exact baseline codecs accept historical acquired save")
        if old.ok:
            var file := FileAccess.open("res://tests/fixtures/acquired-legacy-v%d.json" % old.payload.schema_version, FileAccess.WRITE)
            file.store_string(old.text)
            var upgraded: Dictionary = CODEC.new().decode(old.text)
            check(upgraded.ok, "Baseline-valid legacy save upgrades")
            if upgraded.ok:
                check(upgraded.payload.combat_checkpoint.state == CODEC.normalized(legacy.state), "Upgrade preserves combat state")
                check(upgraded.payload.combat_checkpoint.player_plan == CODEC.normalized(legacy.player_plan), "Upgrade preserves committed plan")
    if validation.ok and args.size() >= 2 and args[0] == "--fixtures":
        var encoded: Dictionary = CODEC.new().encode("acquisition", "combat-%d" % run.duel_index, run.duel_index, run.export_snapshot(), dto)
        check(encoded.ok, "Acquired combat envelope encodes")
        if encoded.ok:
            var path := args[1].path_join("acquired-v%d-%d.json" % [encoded.payload.schema_version, run.get_owned_player_manuals().size()])
            var file := FileAccess.open(path, FileAccess.WRITE)
            check(file != null, "Write isolated acquisition fixture")
            if file != null: file.store_string(encoded.text)
    if not dto.is_empty():
        var forged := dto.duplicate(true)
        forged.binding.player_loadout = starters.duplicate()
        check(not CODEC.new().validate_payload(run.export_snapshot(), forged).ok, "Truncated acquired combat binding rejected")
        var extra_mastery := dto.duplicate(true)
        extra_mastery.binding.player_mastery_by_manual["unearned"] = 3
        check(not CODEC.new().validate_payload(run.export_snapshot(), extra_mastery).ok, "Extra mastery key rejected")
        var duplicate := dto.duplicate(true)
        duplicate.binding.player_loadout[1] = duplicate.binding.player_loadout[0]
        check(not CODEC.new().validate_payload(run.export_snapshot(), duplicate).ok, "Duplicate owned binding rejected")
    var engine = bridge.resolution_engine
    for id in run.get_owned_player_manuals():
        for card in REGISTRY.new().build_unlocked_cards(id, 3):
            check(engine.cards_by_id.has(str(card.id)), "Earned card resolves in actual engine " + str(card.id))
    shell.queue_free()
    await process_frame

func _resume_fixture(path: String) -> void:
    var source := FileAccess.get_file_as_string(path)
    var original: Dictionary = JSON.parse_string(source)
    var isolated := "user://acquired-resume-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()]
    DirAccess.make_dir_recursive_absolute(isolated)
    var slot := "v2_" + CODEC.digest(original) if original.schema_version == 2 else "primary"
    var source_path := isolated.path_join(slot + ".json")
    var file := FileAccess.open(source_path, FileAccess.WRITE)
    file.store_string(source)
    file.close()
    if original.schema_version == 2:
        var pointer := {"schema_version":2, "slot":slot}
        pointer["integrity_hash"] = CODEC.digest(pointer)
        file = FileAccess.open(isolated.path_join("active.json"), FileAccess.WRITE)
        file.store_string(JSON.stringify(pointer))
        file.close()
    print("ACQUIRED_ISOLATED_SAVE ", ProjectSettings.globalize_path(isolated))
    var store = load("res://src/run/run_save_store.gd").new(isolated)
    var loaded: Dictionary = store.load_checkpoint()
    if not check(loaded.ok, "Real primary/pointer loads acquisition envelope: " + str(loaded.get("error", ""))): return
    check(store.load_checkpoint() == loaded, "Cached source identity still matches pointer")
    var payload: Dictionary = loaded.payload
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    shell.session.configure(shell, isolated, true)
    shell._publish_session_screen()
    await process_frame
    var button = shell.find_child("MainContinueButton", true, false) as Button
    if check(button != null and not button.disabled, "Title offers Continue for acquired save"):
        button.grab_focus()
        var key := InputEventKey.new()
        key.keycode = KEY_ENTER
        key.pressed = true
        root.push_input(key)
        await process_frame
        key = InputEventKey.new()
        key.keycode = KEY_ENTER
        key.pressed = false
        root.push_input(key)
        await process_frame
        check(shell.run_state.get_current_screen() == "COMBAT", "Actual Enter resumes combat")
        check(shell.run_state.get_player_manual_loadout().size() == 4, "Continue retains four starter provenance")
        check(shell.run_state.get_owned_player_manuals() == payload.run_state.progression.owned_manual_ids, "Continue retains all acquired manuals")
        if shell._combat_view != null:
            var bridge = shell._combat_view
            check(bridge.get_last_stable_checkpoint() == payload.combat_checkpoint, "Continue restores exact combat checkpoint")
            var earned: String = shell.run_state.get_owned_player_manuals()[-1]
            var cards: Array = REGISTRY.new().build_unlocked_cards(earned, int(shell.run_state.get_player_mastery_by_manual()[earned]))
            var card_id := str(cards[0].id)
            check(bridge.resolution_engine.get_actor_card_definition(card_id, "player").get("id", "") == card_id, "Restored acquired technique is player-owned")
            check(FileAccess.get_file_as_string(source_path) == source, "Continue leaves original save bytes intact")
            var saved: Dictionary = store.save_checkpoint(payload.save_id, "acquired-after-resume", shell.run_state.export_snapshot(), bridge.get_last_stable_checkpoint())
            check(saved.ok, "Migrated checkpoint saves next revision")
            check(store.load_checkpoint().get("payload", {}).get("checkpoint_id", "") == "acquired-after-resume", "Next revision reads back through real store")
            await _execute_acquired(bridge, card_id)
    shell.queue_free()
    await process_frame

func _activate(button: Button) -> bool:
    if not check(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled, "Acquired native input target is available"): return false
    button.grab_focus()
    await process_frame
    for pressed in [true, false]:
        var event := InputEventKey.new()
        event.keycode = KEY_ENTER
        event.pressed = pressed
        root.push_input(event)
        await process_frame
    await process_frame
    return true

func _action_button(node: Node, id: String) -> Button:
    for button in node.find_children("*", "Button", true, false):
        if button.is_visible_in_tree() and str(button.get_meta("action_id", "")) == id: return button
    return null

func _execute_acquired(bridge, card_id: String) -> void:
    var receipts: Array = []
    var writer: Callable = bridge.checkpoint_writer
    bridge.checkpoint_writer = func(dto: Dictionary):
        var saved: bool = bool(writer.call(dto))
        if saved and dto.phase == "BUNDLE_RESOLVED": receipts.append(dto.duplicate(true))
        return saved
    var dock = bridge.action_selection_dock
    if not await _activate(dock.martial_tab): return
    if not await _activate(_action_button(dock, card_id)): return
    var args := OS.get_cmdline_user_args()
    if args.size() >= 4 and args[2] == "--capture":
        await RenderingServer.frame_post_draw
        check(root.get_texture().get_image().save_png(args[3]) == OK, "Capture actual acquired technique placement")
    var placed: Dictionary = bridge.action_timing_panel.get_placement(1)
    if not check(placed.get("card_id", "") == card_id, "Native input places acquired technique"): return
    if not placed.get("target_ready", true):
        if not await _activate(dock.action_intent_panel.intent_buttons[0]): return
    if not await _activate(dock.basic_tab): return
    for anchor in range(1, 4):
        if bridge.action_timing_panel.get_placement(anchor).is_empty():
            if not await _activate(_action_button(dock, "basic_guard")): return
    var before := int(bridge.get_meta("resolution_count", 0))
    if not await _activate(bridge.combat_progress_button._button): return
    check(int(bridge.get_meta("resolution_count", 0)) == before + 1, "Acquired native plan reaches real resolver once")
    var deadline := Time.get_ticks_msec() + 15000
    while bridge._presentation_state not in ["next_bundle_ready", "terminal_result_ready"] and Time.get_ticks_msec() < deadline:
        await process_frame
    check(bridge._presentation_state in ["next_bundle_ready", "terminal_result_ready"], "Acquired resolution presentation completes")
    check(receipts.size() == 1 and receipts[0].player_plan.any(func(row): return row.card_id == card_id), "Resolved durable receipt contains acquired technique")
