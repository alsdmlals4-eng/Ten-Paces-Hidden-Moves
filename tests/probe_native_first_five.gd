extends "res://tests/probe_native_ten_duel_campaign.gd"
## Actual UI commands and resolver; initial seeded SETUP is the only staged fixture.
func run_probe() -> void:
    create_timer(900).timeout.connect(func(): printerr("FIRST_FIVE_TIMEOUT"); quit(1))
    var seed_value := 1
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--seed="): seed_value=int(arg.trim_prefix("--seed="))
    var storage := "user://first-five-%d" % OS.get_process_id()
    var run = load("res://src/run/vertical_slice_run_state.gd").new()
    _require(run.start_new_stats_run(seed_value,"first-five"),"seeded new stats run")
    var frozen: Dictionary = run.export_snapshot()
    var store = load("res://src/run/run_save_store.gd").new(storage)
    _require(store.replace_run("first-five","setup",frozen,{}).ok,"persist real initial SETUP")
    shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    shell.configure_save_storage(storage)
    root.add_child(shell)
    await process_frame
    await process_frame
    started_ms = Time.get_ticks_msec()
    await _click(shell.find_child("MainContinueButton",true,false),"continue initial setup")
    for id in STARTERS: await _click(_meta_button(shell,"manual_id",id),"starter "+id)
    await _advance("setup",VerticalSliceRunState.SCREEN_INTRO)
    await _advance("intro",VerticalSliceRunState.SCREEN_BRIEFING)
    run = shell.run_state
    var played: Array = []
    for duel in range(1,6):
        if not failures.is_empty(): break
        var candidate: Dictionary = run.get_current_opponent()
        _require(candidate.candidate_id == frozen.resolved_encounters[duel-1].candidate_id,"frozen opponent at real briefing")
        await capture("briefing-%d" % duel)
        await _advance("enter duel",VerticalSliceRunState.SCREEN_COMBAT)
        var bridge = shell._combat_view
        # Faster playback for bounded automation only; no combat state or AI mutation.
        bridge._fast_replay=true
        bridge._reduced_motion=true
        var signature: String = candidate.signature_manual_id
        _require(bridge.resolution_engine.get_enemy_martial_card_ids().has(signature+"_star3"),"actual enemy owns signature technique")
        var terminal := false
        var cards := {}
        var effect_witnesses := {}
        for turn in range(90):
            if not failures.is_empty(): break
            var bundle := int(bridge.combat_state.bundle_index)
            var placements := _native_schedule(_public_policy(bridge.resolution_engine,bridge.combat_state.duplicate(true),bundle,0),bundle)
            for placement in placements: await _place(bridge,placement)
            await _click(bridge.combat_progress_button._button,"resolve plan")
            var deadline := Time.get_ticks_msec()+30000
            while bridge._presentation_state not in ["next_bundle_ready","terminal_result_ready"] and Time.get_ticks_msec()<deadline:
                await process_frame
            _require(bridge._presentation_state in ["next_bundle_ready","terminal_result_ready"],"bounded presentation settles")
            _remember_public_player_cards(bridge.combat_state)
            for event in bridge.combat_state.get("public_resolution_history",[]):
                if event.actor=="enemy" and event.card_id.contains("_star") and event.outcome not in ["preparation","interrupted","martial_failed"]: cards[event.card_id]=event.outcome
            for event in bridge._presentation_events:
                if event.get("actor")=="enemy" and str(event.get("card_id","")).begins_with(signature+"_star") and event.get("action_stage")=="execution":
                    for effect in event.get("martial_events",[]):
                        if effect.get("status") in ["APPLIED","HIT","BLOCKED","EVADED"]:
                            effect_witnesses[event.card_id]=event.martial_events.duplicate(true)
            if run.get_current_screen() in [VerticalSliceRunState.SCREEN_REVIEW,VerticalSliceRunState.SCREEN_RESULT,VerticalSliceRunState.SCREEN_FAILURE_RETRY]:
                terminal=true
                break
        _require(terminal,"actual terminal within90 bundles")
        _require(not effect_witnesses.is_empty(),"actual signature program effects in duel%d" % duel)
        played.append({"duel":duel,"candidate":candidate.candidate_id,"name":candidate.get("working_name",""),"signature":signature,"enemy_executed":cards.keys(),"signature_effects":effect_witnesses,"outcome":run.last_combat_result.get("outcome",""),"metrics":bridge.combat_state.battle_metrics})
        print("FIRST_FIVE_DUEL ",JSON.stringify(played.back()))
        _require(run.last_combat_result.get("outcome") in ["win","draw"],"public player policy must reach next duel without fake outcome")
        for i in range(3): await process_frame
        _require(run.get_current_screen()==VerticalSliceRunState.SCREEN_RESULT,"actual reward screen")
        await capture("result-%d" % duel)
        if not failures.is_empty(): break
        # Test readback at real save boundaries, retaining the exact frozen roster.
        var loaded: Dictionary = store.load_checkpoint()
        _require(loaded.get("ok",false),"persisted result reloads")
        if loaded.get("ok",false): _require(loaded.payload.run_state.resolved_encounters==frozen.resolved_encounters,"save retains all opponents")
        await _click(_text_button(shell.result_options_container,"집중 수련 · "+str(shell.manual_registry.get_manual(_reward_target_for_duel(duel)).manual_name)),"earned focused reward")
        await _click(shell.primary_button,"confirm reward")
        if duel==5: break
        for step in range(4):
            var choice := _choose_public_route(run.get_jianghu_options())
            await _click(shell.find_child("Jianghu_"+choice,true,false),"route "+choice)
            if duel==1 and step==0: await capture("route")
            await _click(shell.primary_button,"route continue")
        _require(run.get_current_screen()==VerticalSliceRunState.SCREEN_BRIEFING,"four route choices reach next briefing")
    _require(run.completed_duels==5 and run.get_route_history().size()==16,"five real victories and sixteen intervening routes")
    print("FIRST_FIVE_SUMMARY ",JSON.stringify({"seed":seed_value,"duels":played,"routes":run.get_route_history().size(),"completed":run.completed_duels,"failures":failures,"elapsed_ms":Time.get_ticks_msec()-started_ms}))
    shell.queue_free()
    await process_frame
    await process_frame
    quit(0 if failures.is_empty() else 1)

func capture(label: String) -> void:
    if DisplayServer.get_name()=="headless" or OS.get_environment("TEN_FIVE_CAPTURE_DIR").is_empty(): return
    await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OS.get_environment("TEN_FIVE_CAPTURE_DIR").path_join(label+".png"))

func _public_action_is_legal(definition: Dictionary,state: Dictionary,remaining: int,stamina: int,internal: int,distance: int) -> bool:
    if is_instance_valid(shell) and is_instance_valid(shell._combat_view):
        if shell._combat_view.resolution_engine.get_actor_card_definition(str(definition.get("id","")),"player").is_empty(): return false
    return super._public_action_is_legal(definition,state,remaining,stamina,internal,distance)
