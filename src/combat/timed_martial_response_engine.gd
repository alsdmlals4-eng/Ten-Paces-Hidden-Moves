extends TenManualCombatResolutionEngine
## Stats-v4 uses authored response programs at their actual execution timing.
## Transient continuation never crosses a bundle/save boundary.
var timed_martial_responses := false
var _response_entries: Array = []
var _response_state: Dictionary = {}
var _timing_defenses: Dictionary = {}

func _prepare_bundle_defenses(state: Dictionary, actions: Array, logs: Array[String], resolved: Array) -> Dictionary:
    if not timed_martial_responses: return super._prepare_bundle_defenses(state,actions,logs,resolved)
    _response_entries.clear()
    var ordinary: Array = actions.filter(func(a): return not _is_martial_response(a))
    return super._prepare_bundle_defenses(state,ordinary,logs,resolved)

func _is_martial_response(action: Dictionary) -> bool:
    var d: Dictionary = action.get("definition",{})
    return d.get("source")=="martial_manual" and d.get("category")=="response"

func _begin_timing_responses(state: Dictionary, timing_actions: Array, defenses: Dictionary, logs: Array[String], timing: int, resolved: Array, all_actions: Array) -> void:
    if not timed_martial_responses: return
    _response_state=state
    _timing_defenses=defenses
    _response_entries.clear()
    for action in timing_actions:
        if not _is_martial_response(action): continue
        if action.get("cancelled",false):
            resolved.append(_resolved_record(action,timing,"interrupted"))
            continue
        if not _pay_action_cost(state,action,logs,timing): continue
        action.executed=true
        var actor: String = action.actor
        var old_evade := int(state[actor].get("status_counts",{}).get("evade",0))
        var result := _run_response(state,action.definition,actor,{"timing":timing,"defer_evade":true,"opponent_clash_power":_opponent_clash_power(action,all_actions)})
        if result.get("response_pending",false):
            _response_entries.append({"action":action,"result":result,"old_evade":old_evade,"remaining":maxi(0,int(state[actor].get("status_counts",{}).get("evade",0))-old_evade),"evaded":false})
        else:
            action.martial_result=result
            resolved.append(_response_record(action,timing))
            logs.append(_martial_log_line(action,result,timing,"대응"))
            if result.get("clash_won",false):
                for other in all_actions:
                    if other.actor!=actor and int(other.execution_timing)==timing and not other.get("executed",false): other.cancelled=true

func _finish_timing_responses(state: Dictionary, logs: Array[String], timing: int, resolved: Array) -> void:
    if not timed_martial_responses: return
    for entry in _response_entries:
        var actor: String = entry.action.actor
        var definition: Dictionary = entry.action.definition.duplicate(true)
        definition.effect_steps=entry.result.remaining_steps
        var result: Dictionary
        if _resource_pair(state[actor],"health").x<=0:
            result=_martial_failure(state,"DEFEATED")
        else:
            result=_run_response(state,definition,actor,{"timing":timing,"resume_runtime":entry.result.resume_runtime,"pending_completion_momentum":entry.result.pending_completion_momentum,"evade_succeeded":entry.evaded})
        var events: Array = entry.result.events.duplicate(true)
        events.append_array(result.events)
        result.events=events
        result["grade_non_cost_applied"]=bool(result.get("grade_non_cost_applied",false)) or bool(entry.result.get("grade_non_cost_applied",false)) or bool(entry.evaded)
        result["damage"]=int(result.get("damage",0))+int(entry.result.get("damage",0))
        # Only this response's unconsumed timing-bound grant expires.
        var counts: Dictionary = state[actor].get("status_counts",{})
        counts.evade=maxi(0,int(counts.get("evade",0))-int(entry.remaining))
        state[actor].status_counts=counts
        entry.action.martial_result=result
        resolved.append(_response_record(entry.action,timing))
        logs.append(_martial_log_line(entry.action,result,timing,"대응"))
    _response_entries.clear()
    _response_state={}
    _timing_defenses={}

func _run_response(state: Dictionary, definition: Dictionary, actor: String, context: Dictionary) -> Dictionary:
    context.tile_count=int(rules.get("tile_count",10))
    context.defense_resolver=Callable(self,"_martial_defense")
    var result: Dictionary = martial_effect_pipeline.execute(definition,state,actor,context)
    var target := _other_actor(actor)
    result["damage"]=maxi(0,_resource_pair(state[target],"health").x-_resource_pair(result.state[target],"health").x)
    var grade_after: Dictionary = result.state.duplicate(true)
    # A temporary evasion grant alone is not a successful defensive effect.
    if result.get("response_pending",false):
        var counts: Dictionary = grade_after[actor].get("status_counts",{})
        counts.evade=int(state[actor].get("status_counts",{}).get("evade",0))
        grade_after[actor].status_counts=counts
    result["grade_non_cost_applied"]=_response_effect_applied(state,grade_after,actor)
    var next: Dictionary = result.state.duplicate(true)
    state.clear()
    state.merge(next,true)
    return result

func _response_effect_applied(_before: Dictionary, _after: Dictionary, _actor: String) -> bool:
    return false

func _response_record(action: Dictionary, timing: int) -> Dictionary:
    var record := _resolved_record(action,timing,"martial_completed")
    record.target=_other_actor(action.actor)
    record.damage=int(action.martial_result.get("damage",0))
    record.damage_after_block=record.damage
    record.defense_outcome="martial_pipeline"
    return record

func resolve_martial_card(card_id: String, state: Dictionary, actor: String, context: Dictionary = {}) -> Dictionary:
    var actual := context.duplicate(true)
    if timed_martial_responses and not _response_state.is_empty(): actual.defense_resolver=Callable(self,"_martial_defense")
    return super.resolve_martial_card(card_id,state,actor,actual)

func _consume_response_evade(state: Dictionary, target: String, sure_hit: bool) -> bool:
    if sure_hit: return false
    for entry in _response_entries:
        if entry.action.actor==target and int(entry.remaining)>0:
            entry.remaining-=1
            entry.evaded=true
            var counts: Dictionary = state[target].get("status_counts",{})
            counts.evade=maxi(0,int(counts.get("evade",0))-1)
            state[target].status_counts=counts
            return true
    return false

func _apply_defense(raw: int, attacker: String, target: String, sure_hit: bool, defenses: Dictionary, timing: int) -> Dictionary:
    if timed_martial_responses and not _response_state.is_empty() and _consume_response_evade(_response_state,target,sure_hit):
        return {"damage":0,"after_block":raw,"outcome":"evade"}
    return super._apply_defense(raw,attacker,target,sure_hit,defenses,timing)

func _martial_defense(state: Dictionary, attacker: String, target: String, raw: int, sure_hit: bool, timing: int) -> Dictionary:
    if _consume_response_evade(state,target,sure_hit): return {"damage":0,"outcome":"evade"}
    return super._apply_defense(raw,attacker,target,sure_hit,_timing_defenses,timing)
