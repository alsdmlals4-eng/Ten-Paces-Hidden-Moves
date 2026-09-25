extends SceneTree
const SHELL = preload("res://scenes/run/vertical_slice_shell.tscn")
const CODEC = preload("res://src/run/run_checkpoint_codec.gd")
var failures: Array[String] = []
var checks := 0
var shell

func _initialize() -> void:
    create_timer(60).timeout.connect(func():printerr("FRAME_BRIDGE_TIMEOUT");quit(1))
    call_deferred("run_test")

func run_test() -> void:
    shell=SHELL.instantiate()
    shell.configure_save_storage("res://output/frame-tests/"+str(Time.get_ticks_usec()))
    root.add_child(shell)
    await process_frame
    _check(shell.start_new_run(),"durable frame new game")
    _check(shell.advance_noncombat(),"prologue to selection")
    for id in preload("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0,4):shell.toggle_setup_manual(id)
    _check(shell.advance_noncombat(),"selection to tutorial")
    for step in range(3):_check(shell.advance_noncombat(),"tutorial instruction")
    shell._on_onboarding_command("practice","20")
    _check(shell.advance_noncombat(),"tutorial to first journey")
    shell._on_onboarding_command("enter_journey","")
    shell._on_onboarding_command("choice","observe")
    _check(shell.advance_noncombat(),"first event to briefing")
    _check(shell.advance_noncombat(),"briefing to real combat")
    await process_frame
    var board=shell._combat_view
    if not _check(board!=null and board.get_meta("frame_timeline",false),"default combat uses frame bridge"):return _finish()
    _check(shell.session.last_durable.schema_version==7,"durable combat has schema seven")
    _check(board.view.timeline.public_enemy.is_empty(),"preparation hides locked enemy future")
    _check(board.place_action("basic_guard",0),"place real illustrated action")
    _check(not board.place_action("basic_heavy_attack",1),"UI rejects overlapping placement")
    _check(board.place_action("basic_observe",85),"place carried observation near window end")
    var codec=CODEC.new()
    var before: Dictionary=board.combat_state.duplicate(true)
    _check(board.commit_plan(),"commit succeeds after durable write")
    var committed: Dictionary=board.get_last_stable_checkpoint()
    _check(committed.phase=="COMMITTED","playback owns committed plan")
    _check(board.combat_state==before,"viewing does not award result early")
    _check(codec.validate_payload(shell.run_state.export_snapshot(),committed).ok,"committed checkpoint validates")
    var replay=load("res://src/run/frame_combat_bridge.gd").new()
    root.add_child(replay)
    _check(replay.restore_combat_checkpoint(JSON.parse_string(JSON.stringify(committed))).ok,"committed plan restores across JSON")
    await process_frame
    _check(replay._pending_result==board._pending_result,"resumed playback has same actual result")
    _check(not replay.place_action("basic_move",30),"committed replay cannot edit plan")
    replay.queue_free()
    var actual: Dictionary=board._pending_result.duplicate(true)
    _check(board.finish_playback(),"result settles once")
    _check(not board.finish_playback(),"result cannot settle twice")
    if shell.run_state.get_current_screen()=="COMBAT":
        var settled: Dictionary=board.get_last_stable_checkpoint()
        _check(codec.validate_payload(shell.run_state.export_snapshot(),settled).ok,"settled checkpoint validates by replay")
        var forged:=settled.duplicate(true)
        forged.state.player.health[0]=mini(forged.state.player.health[1],forged.state.player.health[0]+1)
        if forged.state.player.health==settled.state.player.health:forged.state.player.stamina[0]=0
        _check(not codec.validate_payload(shell.run_state.export_snapshot(),forged).ok,"cached forged result is rejected")
    else:
        _check(shell.run_state.last_combat_result.outcome==actual.state.outcome,"terminal outcome is real resolver result")
        _check(not shell.run_state.last_combat_result.review_summary.windows.is_empty(),"terminal review has actual events")
    _finish()

func _check(value: bool,label: String) -> bool:
    checks+=1
    if not value:
        failures.append(label)
        printerr("FAIL: ",label," ",shell.session.error if shell!=null else "")
    return value

func _finish() -> void:
    print("FRAME_BRIDGE checks=%d failures=%d" % [checks,failures.size()])
    if shell!=null:shell.queue_free()
    quit(0 if failures.is_empty() else 1)
