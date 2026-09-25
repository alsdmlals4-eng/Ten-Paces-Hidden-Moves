extends "res://tests/verify_frame_bridge.gd"

func run_test() -> void:
    shell = SHELL.instantiate()
    shell.configure_save_storage("res://output/frame-tests/durability-"+str(Time.get_ticks_usec()))
    root.add_child(shell)
    await process_frame
    _check(shell.session.transact(func():return shell.run_state.start_new_frame_run(550,shell.session.save_id),true), "fixed seeded new frame run")
    _check(shell.advance_noncombat(), "prologue")
    for id in preload("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0,4):shell.toggle_setup_manual(id)
    _check(shell.advance_noncombat(), "selection")
    for step in range(3):_check(shell.advance_noncombat(), "tutorial")
    shell._on_onboarding_command("practice","20")
    _check(shell.advance_noncombat(), "first journey")
    shell._on_onboarding_command("enter_journey", "")
    shell._on_onboarding_command("choice", "leave")
    _check(shell.advance_noncombat() and shell.advance_noncombat(), "actual combat entry")
    await process_frame
    var board = shell._combat_view
    var initial: Dictionary = board.get_last_stable_checkpoint()
    var codec = CODEC.new()
    _check(codec.validate_payload(shell.run_state.export_snapshot(),initial).ok, "canonical entry validated")
    for field in ["attack_power","defense"]:
        var forged := initial.duplicate(true)
        forged.initial_state.player[field] = 999
        forged.state.player[field] = 999
        _check(not codec.validate_payload(shell.run_state.export_snapshot(),forged).ok, "forged initial "+field+" rejected")
    var forged := initial.duplicate(true)
    forged.initial_state.frame.enemy_queue.clear()
    forged.state.frame.enemy_queue.clear()
    _check(not codec.validate_payload(shell.run_state.export_snapshot(),forged).ok, "forged initial enemy future rejected")
    forged = initial.duplicate(true)
    forged.initial_state.player.health[0] -= 1
    forged.state.player.health[0] -= 1
    _check(not codec.validate_payload(shell.run_state.export_snapshot(),forged).ok, "entry resources cross-checked with run receipt")
    board.view.move_steps = 2
    _check(board.place_action("basic_guard",0), "movement distance setting does not block nonmovement actions")
    board.view.move_steps = 1
    board.clear_plan()
    board.view.reverse_direction = true
    _check(board.place_action("basic_move",0) and board.place_action("basic_move",10) and board.place_action("basic_move",20) and board.place_action("basic_observe",98), "plan with known carry")
    board.view.reverse_direction = false
    var old: Dictionary = shell.session.last_durable.duplicate(true)
    shell.session.store.io_guard = func(operation: String,_path: String):return operation!="rename_active"
    _check(not board.commit_plan(), "commit acknowledgment failure blocks playback")
    _check(board._pending_result.is_empty() and board.combat_state==initial.state, "failed commit grants no outcome")
    _check(shell.session.store.load_checkpoint().payload==old, "failed pointer switch leaves old durable plan")
    shell.session.store.io_guard = Callable()
    _check(await shell.session.retry(), "retry acknowledges same commit")
    _check(board._phase=="COMMITTED" and not board._pending_result.is_empty(), "retry starts actual committed result")
    var committed: Dictionary = board.get_last_stable_checkpoint()
    shell.session.store.io_guard = func(operation: String,_path: String):return operation!="rename_active"
    _check(not board.finish_playback(), "settlement acknowledgment failure blocks next planning")
    _check(board._plans.size()==1 and not board.finish_playback(), "blocked settlement cannot append same plan twice")
    _check(CODEC.normalized(shell.session.store.load_checkpoint().payload.combat_checkpoint)==CODEC.normalized(committed), "committed checkpoint remains durable during settlement failure")
    shell.session.store.io_guard = Callable()
    _check(await shell.session.retry(), "retry acknowledges settled boundary")
    _check(board._plans.size()==1, "settlement retry keeps a single plan")
    if shell.run_state.get_current_screen()=="COMBAT" and not board.combat_state.frame.carry.player.is_empty():
        _check(board.player_plan.is_empty() and not board.view.execute.disabled, "empty carried continuation can be executed")
        _check(board.commit_plan(), "empty carried continuation durably commits")
        _check(not board.view.movie_timeline.carry.is_empty(), "carry-only playback retains the executing player action")
        _check(board.view.movie_timeline.carry.remaining_ticks==int(board.combat_state.frame.carry.player.end_tick)-int(board.combat_state.frame.time_tick), "playback carry ends at the recorded boundary")
        _check(codec.validate_payload(shell.run_state.export_snapshot(),board.get_last_stable_checkpoint()).ok, "empty committed checkpoint validates")
        var replay = load("res://src/run/frame_combat_bridge.gd").new()
        root.add_child(replay)
        _check(replay.restore_combat_checkpoint(JSON.parse_string(JSON.stringify(board.get_last_stable_checkpoint()))).ok,"carry-only commit restores")
        await process_frame
        _check(replay._pending_result==board._pending_result,"restored carry-only result is identical")
        replay.queue_free()
    else:
        print("NO_CARRY ", JSON.stringify({"screen":shell.run_state.get_current_screen(),"hp":board.combat_state.player.health,"time":board.combat_state.frame.time_tick,"carry":board.combat_state.frame.carry.player}))
        _check(false,"seeded first window retains observation carry")
    print("FRAME_DURABILITY checks=%d failures=%d" % [checks,failures.size()])
    shell.queue_free()
    quit(0 if failures.is_empty() else 1)
