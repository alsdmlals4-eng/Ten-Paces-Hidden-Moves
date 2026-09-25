extends RefCounted
## Replay validates frame saves. Cached state is never accepted as a new outcome.
const CODEC = preload("res://src/run/run_checkpoint_codec.gd")
const ENGINE = preload("res://src/combat/frame_timeline_engine.gd")
const KEYS := ["version","phase","duel_index","attempt_id","binding","initial_state","plans","state","plan"]

static func make_engine(binding: Dictionary):
    for key in ["player_loadout","enemy_loadout"]:
        if typeof(binding.get(key)) != TYPE_ARRAY: return null
    for key in ["player_mastery_by_manual","enemy_mastery_by_manual","enemy_runtime_binding","bimu_receipt"]:
        if typeof(binding.get(key)) != TYPE_DICTIONARY: return null
    if typeof(binding.get("giyun_ids",[]))!=TYPE_ARRAY:return null
    if typeof(binding.bimu_receipt.get("selections",[]))!=TYPE_ARRAY:return null
    if not _binding_matches_roster(binding):return null
    var engine = ENGINE.new()
    engine.variable_opponent_rules = binding.has("resolved_encounter")
    if not engine.configure(binding.player_loadout,binding.player_mastery_by_manual,binding.enemy_loadout,binding.enemy_mastery_by_manual,binding.enemy_runtime_binding,binding.bimu_receipt.get("selections",[]),binding.get("giyun_ids",[])): return null
    return engine

static func _binding_matches_roster(binding: Dictionary) -> bool:
    if binding.player_loadout.size()<4 or binding.player_loadout.size()>10:return false
    var opponent: Dictionary
    if binding.has("resolved_encounter"):
        var provider=preload("res://src/run/variable_opponent_roster.gd").new()
        if not provider.validate_encounter(binding.resolved_encounter):return false
        opponent=provider.get_encounter_candidate(binding.resolved_encounter)
        var ids: Array=[]
        var masteries: Dictionary={}
        for manual in binding.resolved_encounter.manuals:
            ids.append(manual.id)
            masteries[manual.id]=manual.mastery
        if binding.enemy_loadout!=ids or binding.enemy_mastery_by_manual!=masteries:return false
    else:
        opponent=preload("res://src/run/vertical_slice_opponent_catalog.gd").new().get_candidate(str(binding.get("enemy_candidate_id","")))
        if opponent.is_empty() or binding.enemy_loadout!=[opponent.signature_manual_id]:return false
        if binding.enemy_mastery_by_manual!={opponent.signature_manual_id:int(opponent.signature_star_seed)}:return false
    if binding.get("enemy_candidate_id")!=opponent.candidate_id:return false
    var runtime: Dictionary=preload("res://src/run/vertical_slice_opponent_runtime_binding.gd").new().build(opponent)
    if binding.has("resolved_encounter"):
        runtime.stats=binding.resolved_encounter.stats.duplicate(true)
        runtime.final_stat_total_seed=0
        for stat in runtime.stats.values():runtime.final_stat_total_seed+=int(stat)
    return CODEC.normalized(runtime)==CODEC.normalized(binding.enemy_runtime_binding)

func validate(value: Dictionary) -> Dictionary:
    var bad := CODEC.error("CORRUPT","Invalid frame checkpoint")
    if value.size()!=KEYS.size() or not CODEC.json_safe(value,0,[0]): return bad
    for key in KEYS:
        if not value.has(key): return bad
    var dto: Dictionary = CODEC.normalized(value)
    if dto.version!=1 or dto.phase not in ["PLANNING","COMMITTED"] or not CODEC.integer(dto.duel_index,1,10) or not CODEC.integer(dto.attempt_id,0,1):return bad
    for key in ["binding","initial_state","state"]:
        if typeof(dto[key])!=TYPE_DICTIONARY:return bad
    for key in ["plans","plan"]:
        if typeof(dto[key])!=TYPE_ARRAY:return bad
    if dto.plans.size()>150:return bad
    var engine = make_engine(dto.binding)
    if engine==null:return CODEC.error("CORRUPT","Invalid frame actor binding")
    var initial_check: Dictionary=engine.validate_state(dto.initial_state)
    var state_check: Dictionary=engine.validate_state(dto.state)
    if not initial_check.ok:return CODEC.error("CORRUPT","Frame initial state: "+str(initial_check.reason))
    if not state_check.ok:return CODEC.error("CORRUPT","Frame state: "+str(state_check.reason))
    if int(dto.initial_state.frame.time_tick)!=0:return bad
    var canonical: Dictionary=engine.make_initial_state(JSON.parse_string(FileAccess.get_file_as_string("res://data/combat/combat_hud_preview.json")),4,6)
    for resource in ["health","stamina","internal"]:canonical.player[resource]=dto.initial_state.player[resource].duplicate()
    canonical.enemy.candidate_id=str(dto.binding.enemy_candidate_id)
    canonical.enemy.name=str(dto.initial_state.enemy.get("name","무명 검객"))
    canonical=engine.lock_enemy_plan(canonical)
    if CODEC.normalized(canonical)!=dto.initial_state:return CODEC.error("CORRUPT","Frame initial state differs from canonical duel entry")
    var state: Dictionary = dto.initial_state.duplicate(true)
    for plan in dto.plans:
        if typeof(plan)!=TYPE_ARRAY:return bad
        var result: Dictionary = engine.resolve_window(state,plan)
        if not result.get("ok",false):return bad
        state=result.state
        state=engine.lock_enemy_plan(state) if not result.get("terminal",false) else state
    if CODEC.normalized(state)!=dto.state:return CODEC.error("CORRUPT","Frame replay/state mismatch")
    if not dto.plan.is_empty() and not engine.validate_plan(dto.plan,state).ok:return bad
    if dto.phase=="COMMITTED" and not engine.validate_plan(dto.plan,state).ok:return bad
    return {"ok":true,"status":"VALID","checkpoint":dto}

static func review_window(result: Dictionary) -> Dictionary:
    var review: Dictionary = result.get("review",{})
    var events: Array = []
    for event in result.get("events",[]):
        var actors: Array = []
        for action in event.get("actions",[]):
            var item := {}
            for key in ["actor","card_id","card_name","outcome","damage","defense_outcome","clash_power","opponent_clash_power","motion_cue"]:
                if action.has(key):item[key]=action[key]
            actors.append(item)
        var delta: Dictionary = preload("res://src/ui/ink/ink_resolution_model.gd").delta(event.get("before",{}),event.get("after",{}))
        events.append({"tick":event.get("tick",0),"window_tick":event.get("window_tick",0),"actor":event.get("actor",""),"text":event.get("text",""),"actions":actors,"delta":delta,"changes":preload("res://src/ui/ink/ink_resolution_model.gd").changes(delta)})
    return {"window_index":review.get("window_index",0),"start_tick":review.get("start_tick",0),"end_tick":review.get("end_tick",0),"events":events,"outcome":review.get("outcome","")}
