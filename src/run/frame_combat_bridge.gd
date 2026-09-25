extends Control
## Transaction boundary: record committed plan before playback; settle once afterward.
signal terminal_review_ready(result: Dictionary)
signal terminal_review_confirmed(result: Dictionary)
signal stable_checkpoint_changed(checkpoint: Dictionary)
const ENGINE = preload("res://src/combat/frame_timeline_engine.gd")
const CHECKPOINT = preload("res://src/run/frame_checkpoint_codec.gd")
var resolution_engine
var combat_state := {}
var checkpoint_writer: Callable
var session_input_blocked := false
var session_suspended := false
var _sound_muted := false
var _fast_replay := false
var _reduced_motion := false
var _sound_volume := 0.65
var view: Control
var player_plan: Array = []
var _binding := {}
var _initial_state := {}
var _plans: Array = []
var _history: Array = []
var _stable_checkpoint := {}
var _pending_result := {}
var _phase := "PLANNING"
var _duel := 1
var _attempt := 0
var _pending_write := false
var _pending_next := ""
var _terminal_sent := false
var _restore_digest := ""

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var matte:=ColorRect.new()
    matte.color=Color("202722")
    matte.mouse_filter=Control.MOUSE_FILTER_IGNORE
    matte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(matte)
    view = preload("res://src/ui/frame/frame_combat_view.gd").new()
    view.name="FrameCombatView"
    add_child(view)
    view.place_requested.connect(place_action)
    view.remove_requested.connect(remove_action)
    view.clear_requested.connect(clear_plan)
    view.execute_requested.connect(commit_plan)
    view.playback_finished.connect(finish_playback)
    set_meta("vertical_slice_bridge",true)
    set_meta("frame_timeline",true)

func configure_vertical_slice_loadouts(player_loadout,player_mastery: Dictionary,enemy_loadout,enemy_mastery: Dictionary,enemy_id: String,enemy_binding: Dictionary,identity: Dictionary={},bimu: Dictionary={},encounter: Dictionary={},giyun: Dictionary={}) -> bool:
    if player_loadout.size()<4 or player_loadout.size()>10 or enemy_id.is_empty() or enemy_binding.get("candidate_id")!=enemy_id:return false
    _binding={"player_loadout":Array(player_loadout),"player_mastery_by_manual":player_mastery.duplicate(true),"enemy_candidate_id":enemy_id,"enemy_loadout":Array(enemy_loadout),"enemy_mastery_by_manual":enemy_mastery.duplicate(true),"enemy_runtime_binding":enemy_binding.duplicate(true),"bimu_receipt":bimu.duplicate(true)}
    if not encounter.is_empty():_binding["resolved_encounter"]=encounter.duplicate(true)
    if not giyun.is_empty():_binding["giyun_ids"]=giyun.get("owned",[]).duplicate()
    resolution_engine=CHECKPOINT.make_engine(_binding)
    if resolution_engine==null:return false
    _binding["effective_enemy_mastery_by_manual"]=resolution_engine.get_bimu_enemy_mastery(enemy_mastery)
    combat_state=resolution_engine.make_initial_state(JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json")),4,6)
    combat_state.enemy["candidate_id"]=enemy_id
    combat_state.enemy["name"]=str(identity.get("name","무명 검객"))
    combat_state=resolution_engine.lock_enemy_plan(combat_state)
    _initial_state=combat_state.duplicate(true)
    if view!=null:view.configure_opponent(enemy_id)
    _capture()
    _refresh()
    set_meta("vertical_slice_runtime_loadout_bound",true)
    return true

func configure_checkpoint_identity(duel_index: int,attempt_id: int) -> void:
    _duel=duel_index
    _attempt=attempt_id
    _capture()

func apply_vertical_slice_player_resources(resources: Dictionary) -> bool:
    if combat_state.is_empty() or not _plans.is_empty():return false
    for key in ["health","stamina","internal"]:
        if not resources.get(key) is Array or resources[key].size()!=2:return false
        if resources[key][0]<0 or resources[key][0]>resources[key][1]:return false
    for key in ["health","stamina","internal"]:combat_state.player[key]=resources[key].duplicate()
    combat_state.frame.enemy_queue=[]
    combat_state.frame.enemy_locked_until_tick=0
    combat_state=resolution_engine.lock_enemy_plan(combat_state)
    _initial_state=combat_state.duplicate(true)
    _capture()
    _refresh()
    return true

func get_vertical_slice_loadout_snapshot() -> Dictionary:return _binding.duplicate(true)
func get_vertical_slice_player_resources() -> Dictionary:
    var result: Dictionary={}
    for key in ["health","stamina","internal"]:result[key]=combat_state.get("player",{}).get(key,[0,0]).duplicate()
    return result

func place_action(card_id: String,tick: int,from_index: int=-1) -> bool:
    if not _can_edit():return false
    var proposed:=player_plan.duplicate(true)
    if from_index>=0:
        if from_index>=proposed.size():return false
        proposed.remove_at(from_index)
    var direction:=0
    if view!=null and view.reverse_direction:direction=-signi(int(combat_state.enemy.tile)-int(combat_state.player.tile))
    var steps:=1
    for card in resolution_engine.cards_for("player"):
        if str(card.id)==card_id:
            steps=mini(view.move_steps if view!=null else 1,maxi(1,int(card.get("move_range",1))))
            break
    proposed.append({"card_id":card_id,"start_tick":tick,"direction":direction,"move_steps":steps})
    proposed.sort_custom(func(a,b):return int(a.start_tick)<int(b.start_tick))
    var checked: Dictionary=resolution_engine.validate_plan(proposed,combat_state)
    if not checked.ok:
        if view!=null:view.show_message(str(checked.get("reason","배치할 수 없는 시간입니다")))
        return false
    player_plan=checked.plan.duplicate(true)
    _capture()
    _persist("draft")
    _refresh()
    return true

func remove_action(index: int) -> bool:
    if not _can_edit() or index<0 or index>=player_plan.size():return false
    player_plan.remove_at(index)
    _capture()
    _persist("draft")
    _refresh()
    return true

func clear_plan() -> bool:
    if not _can_edit():return false
    player_plan.clear()
    _capture()
    _persist("draft")
    _refresh()
    return true

func commit_plan() -> bool:
    if not _can_edit():return false
    var valid: Dictionary=resolution_engine.validate_plan(player_plan,combat_state)
    if not valid.ok:return false
    _phase="COMMITTED"
    _capture()
    if not _persist("play"):
        _refresh()
        return false
    _play_committed()
    return true

func _play_committed() -> void:
    _pending_result=resolution_engine.resolve_window(combat_state,player_plan)
    if not _pending_result.get("ok",false):
        if view!=null:view.show_message(str(_pending_result.get("reason","시간축 판정을 다시 확인하세요")))
        return
    if view!=null:
        # Both actors' definitions are used only for records already disclosed by playback.
        for card in resolution_engine.cards_for("enemy"):view.definitions[str(card.id)]=card
        view.play(_pending_result,combat_state,player_plan,resolution_engine.public_enemy_plan(combat_state))

func finish_playback() -> bool:
    if _phase!="COMMITTED" or _pending_write or _pending_result.is_empty() or session_suspended:return false
    _plans.append(player_plan.duplicate(true))
    _history.append(CHECKPOINT.review_window(_pending_result))
    combat_state=_pending_result.state.duplicate(true)
    if not _pending_result.get("terminal",false):combat_state=resolution_engine.lock_enemy_plan(combat_state)
    player_plan.clear()
    _phase="PLANNING"
    _capture()
    if not _persist("finish"):return false
    _after_finish()
    return true

func _after_finish() -> void:
    var terminal:=bool(_pending_result.get("terminal",false))
    _pending_result.clear()
    if terminal:_emit_terminal()
    else:
        if view!=null:view.show_preparation()
        _refresh()

func _emit_terminal() -> void:
    if _terminal_sent:return
    var outcome:=str(ENGINE.battle_outcome(combat_state))
    if outcome not in ["win","loss","draw"]:return
    _terminal_sent=true
    var result: Dictionary={"terminal":true,"outcome":outcome,"player_health":int(combat_state.player.health[0]),"enemy_health":int(combat_state.enemy.health[0]),"player_resources":get_vertical_slice_player_resources(),"battle_metrics":combat_state.get("battle_metrics",{}).duplicate(true),"review_summary":{"format":"frame-v1","windows":_history.duplicate(true),"elapsed_seconds":float(combat_state.frame.time_tick)*0.1},"presentation_state":"COMPLETED"}
    terminal_review_ready.emit(result)
    terminal_review_confirmed.emit(result)

func _capture() -> void:
    if combat_state.is_empty():return
    _stable_checkpoint={"version":1,"phase":_phase,"duel_index":_duel,"attempt_id":_attempt,"binding":_binding.duplicate(true),"initial_state":_initial_state.duplicate(true),"plans":_plans.duplicate(true),"state":combat_state.duplicate(true),"plan":player_plan.duplicate(true)}

func _persist(next: String) -> bool:
    if checkpoint_writer.is_valid() and not bool(checkpoint_writer.call(_stable_checkpoint.duplicate(true))):
        _pending_write=true
        _pending_next=next
        return false
    _pending_write=false
    _pending_next=""
    stable_checkpoint_changed.emit(_stable_checkpoint.duplicate(true))
    return true

func get_last_stable_checkpoint() -> Dictionary:return _stable_checkpoint.duplicate(true)

func retry_checkpoint() -> bool:
    if not _pending_write:return true
    var next:=_pending_next
    if not _persist(next):return false
    if next=="play":_play_committed()
    elif next=="finish":_after_finish()
    _refresh()
    return true

func restore_combat_checkpoint(dto: Dictionary) -> Dictionary:
    var checked: Dictionary=CHECKPOINT.new().validate(dto)
    if not checked.ok:return checked
    var digest:=preload("res://src/run/run_checkpoint_codec.gd").digest(dto)
    if digest==_restore_digest:return {"ok":true,"status":"VALID"}
    _restore_digest=digest
    var value: Dictionary=checked.checkpoint
    _binding=value.binding.duplicate(true)
    resolution_engine=CHECKPOINT.make_engine(_binding)
    _duel=int(value.duel_index)
    _attempt=int(value.attempt_id)
    _initial_state=value.initial_state.duplicate(true)
    _plans=value.plans.duplicate(true)
    combat_state=value.state.duplicate(true)
    player_plan=value.plan.duplicate(true)
    _phase=str(value.phase)
    _history.clear()
    var cursor: Dictionary=_initial_state.duplicate(true)
    for plan in _plans:
        var result: Dictionary=resolution_engine.resolve_window(cursor,plan)
        _history.append(CHECKPOINT.review_window(result))
        cursor=result.state
        if not result.get("terminal",false):cursor=resolution_engine.lock_enemy_plan(cursor)
    _terminal_sent=false
    _capture()
    _refresh()
    if view!=null:view.configure_opponent(str(_binding.enemy_candidate_id))
    if _phase=="COMMITTED":call_deferred("_play_committed")
    elif ENGINE.battle_outcome(combat_state) in ["win","loss","draw"]:call_deferred("_emit_terminal")
    return {"ok":true,"status":"VALID"}

func _can_edit() -> bool:
    return resolution_engine!=null and _phase=="PLANNING" and not _pending_write and not session_input_blocked and not session_suspended and not _terminal_sent

func _refresh() -> void:
    if view==null or combat_state.is_empty() or resolution_engine==null:return
    view.set_data(combat_state,resolution_engine.cards_for("player"),player_plan,resolution_engine.public_enemy_plan(combat_state),not _can_edit())
    view.suspended=session_suspended or _pending_write
    view.reduced_motion=_reduced_motion
    view.speed=2.0 if _fast_replay else 1.0

func _sync_progress_availability() -> void:_refresh()
func _sync_runtime_context() -> void:_refresh()
func _sync_action_selection_dock() -> void:_refresh()
func _toggle_sound() -> void:_sound_muted=not _sound_muted
func _toggle_fast_replay() -> void:_fast_replay=not _fast_replay;_refresh()
func _toggle_reduced_motion() -> void:_reduced_motion=not _reduced_motion;_refresh()
func _set_sound_volume(value: float) -> void:_sound_volume=clampf(value,0,1)
