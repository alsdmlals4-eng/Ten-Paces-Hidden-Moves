extends RefCounted
## Read-only grading evidence; never owns combat, rewards, or the final letter grade.
const VERSION := 1
const TARGET_ROUNDS := 3
const METRICS = preload("res://src/run/vertical_slice_battle_metrics.gd")

static func initial(complete: bool = true) -> Dictionary:
    return {"version":VERSION,"complete":complete,"events":[]}

static func valid_ledger(value: Variant) -> bool:
    if not value is Dictionary or value.size()!=3 or not value.has_all(["version","complete","events"]): return false
    if typeof(value.version) not in [TYPE_INT,TYPE_FLOAT] or value.version != VERSION or typeof(value.complete)!=TYPE_BOOL or not value.events is Array or value.events.size()>512: return false
    for e in value.events:
        if not e is Dictionary or e.size()!=5 or not e.has_all(["source","instance","round","kind","applied"]): return false
        if not e.source is String or e.source.is_empty() or e.source.length()>160 or not e.instance is String or e.instance.is_empty() or e.instance.length()>80: return false
        if typeof(e.round) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(e.round)) or e.round != floor(e.round) or e.round < 1: return false
        if e.kind not in ["clash","dodge","ultimate"] or typeof(e.applied)!=TYPE_BOOL: return false
    return true

static func summarize(raw: Dictionary, ledger: Dictionary) -> Dictionary:
    var out := {"raw":METRICS.new().normalize(raw),"effective":{},"reasons":[],"formula_version":"","aggregation_version":VERSION,"grade_status":"FORMULA_PENDING","grade":"","grade_target_rounds":TARGET_ROUNDS,"evidence_status":"LEGACY_UNAVAILABLE"}
    if not valid_ledger(ledger) or not ledger.complete: return out
    out.evidence_status = "RECORDED"
    out.effective = {"clash":0.0,"dodge":0.0,"ultimate":0.0}
    if int(out.raw.rounds_elapsed)>TARGET_ROUNDS: _reason(out,"SCORING_WINDOW")
    var groups := {}
    for e in ledger.events:
        if e.round > TARGET_ROUNDS:
            _reason(out,"SCORING_WINDOW")
            continue
        if e.kind == "ultimate":
            if not e.applied: _reason(out,"NO_APPLIED_EFFECT")
            elif out.effective.ultimate == 0: out.effective.ultimate = 1.0
            else: _reason(out,"ULTIMATE_CAP")
            continue
        if not e.applied:
            _reason(out,"NO_OPPOSING_ACTION")
            continue
        var key: String = e.instance
        if not groups.has(key): groups[key] = {"source":e.source,"events":[]}
        # The actual resolver adapter guarantees one enemy action per instance.
        if groups[key].source != e.source:
            out.effective = {}
            out.evidence_status = "CONFLICTING_SOURCE"
            return out
        groups[key].events.append(e)
    var repeats := {}
    for key in groups:
        var group: Dictionary = groups[key]
        var count := int(repeats.get(group.source,0))
        var pool := 1.0 if count==0 else (0.5 if count==1 else 0.0)
        repeats[group.source] = count + 1
        if count>0: _reason(out,"REPEATED_SOURCE")
        for e in group.events:
            var amount: float = pool / group.events.size()
            if float(out.effective[e.kind])+amount > 3.0: _reason(out,"DEFENSE_CAP")
            out.effective[e.kind] = minf(3.0,float(out.effective[e.kind])+amount)
    return out

static func _reason(out: Dictionary, reason: String) -> void:
    if reason not in out.reasons: out.reasons.append(reason)

static func record(before: Dictionary, result: Dictionary) -> Dictionary:
    var ledger: Dictionary = before.get("grade_ledger", initial(false)).duplicate(true)
    if not valid_ledger(ledger): return initial(false)
    var round_number := int(result.get("round_number",0))
    if round_number<1 or round_number>TARGET_ROUNDS: return ledger
    var actions: Array = result.get("resolved_actions",[])
    for action in actions:
        if not action is Dictionary or action.get("action_stage","execution")!="execution": continue
        var actor := str(action.get("actor",""))
        var outcome := str(action.get("outcome",""))
        var timing := int(action.get("timing",0))
        var id := str(action.get("card_id",""))
        var instance := "%d:%d:%d" % [round_number,int(result.get("bundle_index",0)),timing]
        if actor == "enemy" and action.get("defense_outcome") == "evade" and (not outcome.begins_with("clash_") or outcome=="clash_win"):
            _append(ledger, id, instance, round_number,"dodge",true)
        if actor == "enemy":
            for event in action.get("martial_events",[]):
                if event.get("status")=="EVADED": _append(ledger,id,instance,round_number,"dodge",true)
        if actor == "player" and (outcome=="clash_win" or action.get("clash_won",false)):
            var enemy_id := ""
            for enemy in actions:
                if enemy is Dictionary and enemy.get("actor")=="enemy" and enemy.get("category")=="attack" and int(enemy.get("timing",-1))==timing and enemy.get("action_stage","execution")=="execution":
                    enemy_id = str(enemy.get("card_id",""))
                    break
            # No opposing action means no invented source for an uncontested special clash.
            if not enemy_id.is_empty(): _append(ledger,enemy_id,instance,round_number,"clash",true)
            else: _append(ledger,id,instance,round_number,"clash",false)
        if actor == "player" and (id.begins_with("ultimate_") or id.ends_with("_star10")) and outcome not in ["interrupted","resource_insufficient","insufficient","martial_failed"]:
            _append(ledger,id,"player:"+instance,round_number,"ultimate",bool(action.get("grade_non_cost_applied",false)) or int(action.get("damage",0))>0)
    return ledger

static func _append(ledger: Dictionary, card_id: String, instance: String, round_number: int, kind: String, applied: bool) -> void:
    if card_id.is_empty(): ledger.complete = false; return
    if ledger.events.size()>=512: ledger.complete=false; return
    var source_type := "basic" if card_id.begins_with("basic_") else ("ultimate" if card_id.begins_with("ultimate_") else "martial")
    ledger.events.append({"source":source_type+":"+card_id,"instance":instance,"round":round_number,"kind":kind,"applied":applied})

static func explanation(summary: Dictionary) -> String:
    if summary.get("evidence_status") != "RECORDED": return "유효 성과 · 이전 전투의 상세 집계 근거 없음"
    var e: Dictionary = summary.effective
    var text := "유효 성과 · 합 %.2f · 회피 %.2f · 절초 %.0f\n첫 3라운드 기준 · 같은 기술 대응 1→0.5→0 · 합/회피 각 최대 3 · 유효 절초 최대 1" % [e.clash,e.dodge,e.ultimate]
    var labels := {"SCORING_WINDOW":"기준 라운드 이후 제외","NO_APPLIED_EFFECT":"효과 없는 절초 제외","ULTIMATE_CAP":"첫 유효 절초만 반영","REPEATED_SOURCE":"같은 기술 반복 대응 감쇠","DEFENSE_CAP":"합/회피 반영 상한","NO_OPPOSING_ACTION":"대응한 상대 행동이 없는 합 제외"}
    var reasons: PackedStringArray = []
    for reason in summary.get("reasons",[]):
        if labels.has(reason): reasons.append(labels[reason])
    if not reasons.is_empty(): text += "\n집계 이유 · " + " · ".join(reasons)
    return text

static func valid_summary(value: Variant) -> bool:
    if not value is Dictionary or not value.has_all(["raw","effective","reasons","formula_version","aggregation_version","grade_status","grade","grade_target_rounds","evidence_status"]): return false
    if value.aggregation_version!=VERSION or typeof(value.aggregation_version)==TYPE_BOOL or value.grade!="" or value.formula_version!="" or value.grade_status!="FORMULA_PENDING" or value.grade_target_rounds!=TARGET_ROUNDS: return false
    if not value.raw is Dictionary or not value.effective is Dictionary or not value.reasons is Array: return false
    if value.raw.size()!=METRICS.METRIC_KEYS.size() or not value.raw.has_all(METRICS.METRIC_KEYS): return false
    for n in value.raw.values():
        if typeof(n) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(n)) or n<0 or n!=floor(n): return false
    for reason in value.reasons:
        if reason not in ["SCORING_WINDOW","NO_APPLIED_EFFECT","ULTIMATE_CAP","REPEATED_SOURCE","DEFENSE_CAP","NO_OPPOSING_ACTION"]: return false
    if value.evidence_status in ["LEGACY_UNAVAILABLE","CONFLICTING_SOURCE"]: return value.effective.is_empty()
    if value.evidence_status!="RECORDED" or value.effective.size()!=3 or not value.effective.has_all(["clash","dodge","ultimate"]): return false
    for key in value.effective:
        var n = value.effective[key]
        if typeof(n) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(n)) or n<0 or n>(1 if key=="ultimate" else 3): return false
    return true
