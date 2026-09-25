extends SceneTree
## Actual native flow and resolver; deterministic input fixture, no injected victories.
const OUT := "res://docs/blueprint/evidence/frame-runtime-20260925/"
var shell
var receipt: Array = []

func _initialize() -> void:
    create_timer(120).timeout.connect(func():push_error("Frame capture timed out");quit(1))
    call_deferred("capture")

func shot(label: String) -> void:
    await create_timer(0.8).timeout
    await process_frame
    await process_frame
    RenderingServer.force_draw()
    var path:=OUT+label+".png"
    var error:=root.get_texture().get_image().save_png(path)
    if error!=OK:push_error("Capture failed: "+path);quit(1);return
    receipt.append({"key":label,"status":"PASS","path":path.trim_prefix("res://"),"sha256":FileAccess.get_sha256(path),"screen":shell.run_state.get_current_screen(),"size":[root.size.x,root.size.y],"evidence":"ACTUAL_GODOT_DETERMINISTIC_INPUT"})

func capture() -> void:
    root.size=Vector2i(1440,1000)
    DirAccess.make_dir_recursive_absolute(OUT)
    seed(734)
    shell=load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await create_timer(0.4).timeout
    await shot("main")
    shell.start_new_run()
    await shot("prologue")
    shell.advance_noncombat()
    for id in preload("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0,4):shell.toggle_setup_manual(id)
    await shot("setup")
    shell.advance_noncombat()
    await shot("tutorial")
    for step in range(3):shell.advance_noncombat()
    shell._on_onboarding_command("practice","20")
    shell.advance_noncombat()
    await shot("first_journey")
    shell._on_onboarding_command("enter_journey","")
    await shot("event")
    shell._on_onboarding_command("choice","observe")
    shell.advance_noncombat()
    await shot("briefing")
    if not shell.advance_noncombat():push_error("Cannot enter frame combat");quit(1);return
    var board=shell._combat_view
    for entry in [["basic_footwork",0],["basic_guard",15],["basic_heavy_attack",35],["basic_meditate",60],["basic_observe",80]]:
        if not board.place_action(entry[0],entry[1]):push_error("Capture plan rejected");quit(1);return
    await shot("preparation")
    if not board.commit_plan():push_error("Capture commit rejected");quit(1);return
    await create_timer(3.85).timeout
    await shot("resolution")
    while board.view.playing:await process_frame
    board.finish_playback()
    # Continue legal deterministic actions until the first real terminal event.
    var window:=0
    while shell.run_state.get_current_screen()=="COMBAT" and window<30:
        board=shell._combat_view
        var busy_until:=maxi(0,int(board.combat_state.frame.carry.player.get("end_tick",board.combat_state.frame.time_tick))-int(board.combat_state.frame.time_tick))
        for tick in range(busy_until,100,20):
            var card: String="basic_palm" if int(board.combat_state.player.internal[0])>0 and tick==busy_until else "basic_meditate"
            if not board.place_action(card,tick):board.place_action("basic_meditate",tick)
        if not board.commit_plan():push_error("Continuation rejected");break
        # Same resolved payload is used for native playback; speed here affects capture time only.
        board.view.speed=8.0
        while board.view.playing:await process_frame
        board.finish_playback()
        window+=1
    if shell.run_state.get_current_screen()!="COMBAT":
        await shot("result")
        var review_button=shell.find_child("ResultReviewButton",true,false)
        if review_button!=null:
            review_button.pressed.emit()
            await shot("review")
    else:
        push_error("No terminal result captured within bounded legal input sequence")
        quit(1)
        return
    var file:=FileAccess.open(OUT+"capture-receipt.json",FileAccess.WRITE)
    file.store_string(JSON.stringify({"status":"PASS","engine":Engine.get_version_info().string,"project":ProjectSettings.globalize_path("res://"),"shots":receipt,"first_duel_result":shell.run_state.last_combat_result},"\t"))
    file.close()
    print("FRAME_RUNTIME_CAPTURE_PASS shots=",receipt.size()," final_screen=",shell.run_state.get_current_screen())
    shell.queue_free()
    await process_frame
    quit()
