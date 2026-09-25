extends SceneTree
## Public legal inputs only. No injected result, resource, binding or enemy plan.
const OUT := "res://docs/blueprint/evidence/frame-runtime-20260925/"
const POLICIES := [{"seed":550,"id":"palm-and-meditate"},{"seed":734,"id":"palm-and-meditate"},{"seed":550,"id":"close-quick-or-palm"}]
var shell
var attempts: Array = []
var shots: Array = []
var failures: Array[String] = []

func _initialize() -> void:
    create_timer(180).timeout.connect(func():printerr("REAL_WIN_TIMEOUT");quit(1))
    call_deferred("run_probe")

func run_probe() -> void:
    root.size=Vector2i(1440,1000)
    root.content_scale_size=root.size
    var first_policy := 0
    var last_policy := 3
    for argument in OS.get_cmdline_user_args():
        if argument.begins_with("--policy="):
            first_policy=int(argument.trim_prefix("--policy="))
            last_policy=first_policy+1
    var winning_policy := -1
    for index in range(first_policy,last_policy):
        if not await start_policy(POLICIES[index]):return finish(false,-1)
        var plans: Array=[]
        for window in range(30):
            if shell.run_state.get_current_screen()!="COMBAT":break
            var board=shell._combat_view
            var public_distance:=absi(int(board.combat_state.player.tile)-int(board.combat_state.enemy.tile))
            var own: Dictionary=board.combat_state.player
            var tick:=maxi(0,int(board.combat_state.frame.carry.player.get("end_tick",board.combat_state.frame.time_tick))-int(board.combat_state.frame.time_tick))
            var stamina:=int(own.stamina[0])
            var internal:=int(own.internal[0])
            var planned: Array=[]
            while tick<100:
                var card: String="basic_palm"
                if public_distance>3:
                    card="basic_move"
                    public_distance-=1
                elif index==2 and public_distance<=1 and stamina>0:
                    card="basic_quick_attack"
                    stamina-=1
                elif internal>0:
                    internal-=1
                else:
                    card="basic_meditate"
                    stamina=mini(int(own.stamina[1]),stamina+1)
                    internal=mini(int(own.internal[1]),internal+1)
                if not board.place_action(card,tick):
                    failures.append("Legal policy placement rejected: "+card+" at "+str(tick))
                    return finish(false,index)
                planned.append({"card_id":card,"start_tick":tick})
                tick+=int(board.view.definitions[card].frame_timing.total)
            plans.append({"window":window,"visible_distance":absi(int(own.tile)-int(board.combat_state.enemy.tile)),"own_health":own.health.duplicate(),"own_stamina":own.stamina.duplicate(),"own_internal":own.internal.duplicate(),"plan":planned})
            if not board.commit_plan() or not board.finish_playback():
                failures.append("Actual frame commit/settlement failed")
                return finish(false,index)
            await process_frame
        var outcome: String=str(shell.run_state.last_combat_result.get("outcome","ongoing"))
        attempts.append({"policy_index":index,"policy":POLICIES[index],"outcome":outcome,"windows":plans.size(),"plans":plans})
        print("REAL_WIN_POLICY index=%d seed=%d outcome=%s windows=%d" % [index,int(POLICIES[index].seed),outcome,plans.size()])
        if outcome=="win":
            winning_policy=index
            break
        root.remove_child(shell)
        shell.queue_free()
        await process_frame
        shell=null
    if winning_policy<0:return finish(false,-1)
    if DisplayServer.get_name()=="headless":return finish(true,winning_policy)
    if not await shot("victory"):return finish(false,winning_policy)
    var before: Dictionary=shell.run_state.export_snapshot()
    shell.find_child("ResultReviewButton",true,false).pressed.emit()
    if not await shot("victory-review"):return finish(false,winning_policy)
    if shell.run_state.export_snapshot()!=before:
        failures.append("Review mutated the completed victory")
        return finish(false,winning_policy)
    shell.find_child("RecordedReviewClose",true,false).pressed.emit()
    if not shell.select_result_reward("free_training") or not shell.advance_noncombat():
        failures.append("Actual victory reward confirmation failed")
        return finish(false,winning_policy)
    if not await shot("journey"):return finish(false,winning_policy)
    var event=shell.find_child("JourneyNode_event",true,false)
    if event==null:
        failures.append("First post-victory route has no offered event node")
        return finish(false,winning_policy)
    event.pressed.emit()
    await process_frame
    shell.find_child("FrameRouteEnter",true,false).pressed.emit()
    if shell.run_state.get_giyun_state().pending_event.is_empty():
        failures.append("Actual later event did not open")
        return finish(false,winning_policy)
    if not await shot("later-event"):return finish(false,winning_policy)
    finish(true,winning_policy)

func start_policy(policy: Dictionary) -> bool:
    shell=load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    if not shell.session.transact(func():return shell.run_state.start_new_frame_run(int(policy.seed),shell.session.save_id),true):return false
    if not shell.advance_noncombat():return false
    for id in preload("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0,4):shell.toggle_setup_manual(id)
    if not shell.advance_noncombat():return false
    for step in range(3):
        if not shell.advance_noncombat():return false
    shell._on_onboarding_command("practice","20")
    if not shell.advance_noncombat():return false
    shell._on_onboarding_command("enter_journey","")
    shell._on_onboarding_command("choice","leave")
    return shell.advance_noncombat() and shell.advance_noncombat()

func shot(label: String) -> bool:
    DirAccess.make_dir_recursive_absolute(OUT)
    for i in range(5):await process_frame
    await RenderingServer.frame_post_draw
    var path: String=OUT+label+".png"
    if root.get_texture().get_image().save_png(path)!=OK:
        failures.append("Screenshot failed: "+label)
        return false
    var digest: String=FileAccess.get_sha256(path)
    if digest.length()!=64:
        failures.append("Screenshot hash missing: "+label)
        return false
    shots.append({"key":label,"status":"PASS","path":path.trim_prefix("res://"),"sha256":digest,"screen":shell.run_state.get_current_screen(),"size":[root.size.x,root.size.y],"evidence":"ACTUAL_GODOT_PUBLIC_LEGAL_INPUT_NO_INJECTED_RESULT"})
    return true

func finish(won: bool, policy_index: int) -> void:
    var captured: bool=won and failures.is_empty() and shots.size()==4
    var result: Dictionary=shell.run_state.last_combat_result.duplicate(true) if shell!=null else {}
    var sources: Dictionary={}
    for path in ["src/combat/frame_timeline_engine.gd","src/combat/frame_effect_program.gd","src/run/frame_combat_bridge.gd","src/ui/frame/frame_combat_view.gd","src/run/vertical_slice_run_state.gd"]:sources[path]=FileAccess.get_sha256("res://"+path)
    var receipt: Dictionary={"schema_version":1,"status":"PASS" if captured else "NOT_RUN","real_win_status":"PASS" if won and failures.is_empty() else "NOT_RUN","engine":Engine.get_version_info().string,"project":ProjectSettings.globalize_path("res://"),"display_server":DisplayServer.get_name(),"render_size":[root.size.x,root.size.y],"policy_index":policy_index,"attempts":attempts,"shots":shots,"first_duel_result":result,"first_duel_result_sha256":preload("res://src/run/run_checkpoint_codec.gd").digest(result),"source_sha256":sources,"failures":failures,"human_play":"NOT_RUN","policy_information":"Own resources, own carry, own card definitions and public distance only; no hidden queue or enemy HP read for action selection."}
    var target: String=OUT+"capture-win-receipt.json" if DisplayServer.get_name()!="headless" else "res://output/frame-review/real-win-policy.json"
    var file=FileAccess.open(target,FileAccess.WRITE)
    file.store_string(JSON.stringify(receipt,"\t"))
    file.close()
    print("REAL_WIN_FINISH real_win=",won," captures=",shots.size()," failures=",failures.size()," receipt=",target)
    for failure in failures:printerr(failure)
    if shell!=null:shell.queue_free()
    quit(0 if won and failures.is_empty() else 1)
