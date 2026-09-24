/* Presentation-only adapter. All state changes come from resolved timing snapshots. */
const RESOURCES=['health','stamina','internal','momentum'];
const ACTORS=['player','enemy'];
function delta(before,after){return Object.fromEntries(ACTORS.map(a=>[a,Object.fromEntries(RESOURCES.map(k=>[k,after[a][k][0]-before[a][k][0]]))]));}
function action(event,placement,timing){
 const d=placement?.definition;
 if(!event&&!d)return {label:'행동 없음',stage:'empty',event:null};
 const stage=event?.action_stage||(timing<placement.anchor_index+placement.span-1?'preparation':'execution');
 const name=event?.card_name||d.name;
 return {label:name+((event?.action_slots||placement?.span)>1?(stage==='preparation'?' · 전조':' · 실행'):''),stage,event:event||null};
}
function changes(d,{completion=false}={}){
 const names={health:'체력',stamina:'기력',internal:'내력',momentum:'기세'},out=[];
 for(const a of ACTORS)for(const k of RESOURCES)if(d[a][k])out.push(`${a==='player'?'내':'상대'} ${names[k]} ${d[a][k]>0?'+':''}${d[a][k]}`);
 return (completion?'묶음 완료 · ':'')+(out.join(' · ')||'자원 변화 없음');
}
function buildSequence(fixture){
 let cursor=0;const bundles=[];
 for(const item of fixture.bundles){
  const result=item.result,before=item.input.before,start=cursor;
  const response=result.timing_results.find(t=>t.timing===0);
  let previous=response?.state||before;
  const response_delta=delta(before,previous),slots=[],steps=[];
  const opening={kind:'opening',timing:0,start:cursor,end:cursor+1.2};cursor=opening.end;
  for(let timing=result.bundle_start;timing<=result.bundle_end;timing++){
   const tick=result.timing_results.find(t=>t.timing===timing),after=tick?.state||previous;
   const events=(tick?.events||[]).filter(e=>ACTORS.includes(e.actor));
   const actions={};
   for(const actor of ACTORS){
    // Responses are paid at bundle entry, but belong to their declared timing.
    const event=events.find(e=>e.actor===actor)||(response?.events||[]).find(e=>e.actor===actor&&e.timing===timing);
    const placement=actor==='player'?item.input.placements.find(p=>timing>=p.anchor_index&&timing<p.anchor_index+p.span):null;
    actions[actor]=action(event,placement,timing);
   }
   const pe=actions.player.event,ee=actions.enemy.event;
   const clash=events.find(e=>e.clash),attack=events.find(e=>e.damage!==undefined);
   let kind=clash?'clash':actions.player.stage==='preparation'?'preparation':attack?.defense_outcome==='block'?'guard':attack?.defense_outcome==='evade'?'evade':events.some(e=>e.outcome==='move')?'move':attack?'attack':'utility';
   const verdict=clash?(pe?.outcome==='clash_win'?'내 합 승리':ee?.outcome==='clash_win'?'상대 합 승리':'합 상쇄'):kind==='guard'?'막기 성공':kind==='evade'?'회피 성공':kind==='preparation'?'전조 · 다음 수에 실행':kind==='move'?'거리 '+Math.abs(after.enemy.tile-after.player.tile):kind==='utility'?'행동 적용':attack?.outcome==='miss_range'?'사거리 밖':'공격 해결';
   const duration=kind==='clash'?(pe?.action_slots===2?4.4:3.2):kind==='preparation'?1.4:kind==='guard'?2.4:kind==='move'?1.8:1.8;
   const d=delta(previous,after);
   const combatDelta=Object.fromEntries(ACTORS.map(a=>[a,{...d[a],stamina:0,internal:0}]));
   let resultText=changes(d);
   if(['clash','guard','evade','attack'].includes(kind)){
    resultText=changes(combatDelta);
    if(!d.player.health&&!d.enemy.health)resultText='피해 0'+(resultText==='자원 변화 없음'?'':' · '+resultText);
   }
   const slot={timing,local:timing-result.bundle_start+1,...actions,kind,verdict,before:previous,after,delta:d,result:resultText,compare:clash?[pe?.raw_damage??null,ee?.raw_damage??null]:null};
   const step={...slot,start:cursor,end:cursor+duration};
   slots.push(slot);steps.push(step);cursor=step.end;previous=after;
  }
  const completion_delta=delta(previous,result.state);
  const conclusion={kind:'complete',start:cursor,end:cursor+1.6};cursor=conclusion.end;
  bundles.push({index:result.bundle_index,start,end:cursor,opening,conclusion,steps,slots,response_delta,completion_delta,before,after:result.state});
  if(result.bundle_index<3)cursor+=1.6;
 }
 return {bundles,duration:cursor};
}
function frameAt(sequence,time){
 const t=Math.max(0,Math.min(time,sequence.duration-1e-6));
 const b=sequence.bundles.find(b=>t<b.end)||sequence.bundles.at(-1);
 if(t<b.start)return {bundle:b.index-1,phase:'다음 묶음 준비',slots:[],kind:'planning-boundary',result_visible:false};
 const step=b.steps.find(s=>t>=s.start&&t<s.end);
 const complete=t>=b.conclusion.start;
 const ratio=step?(t-step.start)/(step.end-step.start):0;
 const slots=b.slots.map(slot=>({player:slot.player.label,enemy:complete||step&&slot.timing<=step.timing?slot.enemy.label:'미공개',timing:slot.timing,local:slot.local,status:complete||step&&slot.timing<step.timing?'완료':step&&slot.timing===step.timing?'진행':'대기'}));
 const verdictAt=step?.kind==='clash'?.10+.90*(2.50-1.10)/3.02:step?.kind==='guard'?.62:.55;
 const resultAt=step?.kind==='clash'?.10+.90*(3.12-1.10)/3.02:step?.kind==='guard'?.74:.70;
 return {bundle:b.index,phase:complete?'묶음 완료':'전투진행',kind:step?.kind||(complete?'complete':'opening'),step,ratio,slots,
  verdict_visible:!!step&&ratio>=verdictAt,result_visible:!!step&&ratio>=resultAt,conclusion:complete?changes(b.completion_delta,{completion:true}):null,
  response:changes(b.response_delta),source:b};
}
module.exports={buildSequence,frameAt,changes,delta};
