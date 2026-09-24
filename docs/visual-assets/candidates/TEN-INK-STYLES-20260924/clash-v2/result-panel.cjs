/* Read-only presentation of one fixed resolver case, never a combat calculator. */
const names={player:'내',enemy:'상대'};
function readResult(item){
  const before=item.input.before;
  // The isolated fixture has one action per actor, both resolving at timing 2.
  // Use that timing snapshot; the bundle snapshot also awards a separate +1.
  const tick=item.result.timing_results.find(t=>t.timing===2);
  if(!tick)throw new Error('Missing resolved timing');
  const after=tick.state,sides={},health_loss={},momentum_gain={};
  for(const side of ['player','enemy']){
    const event=item.result.presentation_events.find(e=>e.actor===side&&e.timing===2&&e.action_stage==='execution');
    if(!event)throw new Error('Missing revealed action: '+side);
    sides[side]={event,name:before[side].name,action:event.card_name,
      paid:{stamina:before[side].stamina[0]-after[side].stamina[0],internal:before[side].internal[0]-after[side].internal[0]},
      before:before[side],after:after[side]};
    health_loss[side]=Math.max(0,before[side].health[0]-after[side].health[0]);
    momentum_gain[side]=after[side].momentum[0]-before[side].momentum[0];
  }
  const p=sides.player.event,e=sides.enemy.event;
  let kind=p.clash?'clash':p.outcome==='miss_range'?'miss_range':p.defense_outcome==='evade'?'evade':p.defense_outcome==='block'?'guard':'hit';
  const compare={kind,values:[p.raw_damage??null,e.raw_damage??null],difference:p.clash_difference??null,after_block:p.damage_after_block??null};
  const winner=p.outcome==='clash_win'?'player':e.outcome==='clash_win'?'enemy':null;
  let verdict=kind==='clash'?(winner?names[winner]+' 합 승리':'합 상쇄'):kind==='evade'?'상대 회피 성공':kind==='guard'?'상대 막기 적용':kind==='miss_range'?'사거리 밖':'공격 적중';
  const changes=[];
  for(const side of ['player','enemy'])if(health_loss[side]>0)changes.push(`${names[side]} 체력 ${before[side].health[0]} → ${after[side].health[0]} (피해 ${health_loss[side]})`);
  if(!changes.length)changes.push('피해 0');
  for(const side of ['player','enemy'])if(momentum_gain[side]>0)changes.push(`${names[side]} 절초 기세 +${momentum_gain[side]}`);
  return {id:item.id,timing:2,sides,compare,winner,verdict,health_loss,momentum_gain,result:verdict+' · '+changes.join(' · ')};
}
function presentationAt(model,t){return {enemy_visible:t>=1.10,verdict_visible:t>=2.50,damage_visible:t>=3.12,last_result:t>=5.12,phase:t<1.10||t>=5.12?'행동설계':'전투진행'};}

const noise=n=>{const x=Math.sin(n*127.1+51.7)*43758.5453;return x-Math.floor(x);};
function wash(ctx,x,y,w,h,color){ctx.fillStyle=color;ctx.beginPath();for(let i=0;i<=54;i++){const xx=x+i*w/54,yy=y+(noise(i+34)-.5)*3;if(i)ctx.lineTo(xx,yy);else ctx.moveTo(xx,yy);}for(let i=54;i>=0;i--)ctx.lineTo(x+i*w/54,y+h+(noise(i+78)-.5)*4);ctx.closePath();ctx.fill();}
function label(ctx,text,x,y,size=23,color='#302c23',max=1000){ctx.font=size+'px Book';ctx.textAlign='center';ctx.fillStyle=color;while(ctx.measureText(text).width>max&&size>17){size--;ctx.font=size+'px Book';}ctx.fillText(text,x,y);}
function drawResultPanel(ctx,model,t,{top=694}={}){
  const stage=presentationAt(model,t),x=42,w=1196,h=204;
  ctx.save();
  ctx.fillStyle='#252a23';ctx.fillRect(x-3,top-4,w+6,h+8);
  const paper=ctx.createLinearGradient(0,top,0,top+h);paper.addColorStop(0,'#e6d9bc');paper.addColorStop(.5,'#efe5cd');paper.addColorStop(1,'#daccaa');
  wash(ctx,x,top,w,h,paper);
  ctx.strokeStyle='#a88d58';ctx.lineWidth=1;ctx.strokeRect(x+6,top+5,w-12,h-10);
  ctx.strokeStyle='rgba(93,76,44,.23)';ctx.strokeRect(x+11,top+10,w-22,h-20);
  // Fine paper flecks are drawn behind text; they do not compete with the numerals.
  for(let n=0;n<360;n++){ctx.fillStyle='rgba(60,46,25,.045)';ctx.fillRect(x+noise(n)*w,top+noise(n+411)*h,1+noise(n+75)*3,1);}
  for(const [side,cx,color] of [['player',263,'#385762'],['enemy',1017,'#824437']]){
    const s=model.sides[side],visible=side==='player'||stage.enemy_visible;
    label(ctx,side==='player'?'플레이어 · '+s.name:'상대 · '+s.name,cx,top+26,21,color,335);
    wash(ctx,cx-164,top+36,328,33,color);
    label(ctx,visible?s.action:'행동 미공개',cx,top+61,25,'#f5edda',310);
    if(visible&&stage.enemy_visible){
      label(ctx,`기력  ${s.before.stamina[0]} → ${s.after.stamina[0]}  (−${s.paid.stamina})`,cx,top+98,22);
      label(ctx,`내력  ${s.before.internal[0]} → ${s.after.internal[0]}  (−${s.paid.internal})`,cx,top+126,22);
    }else if(side==='player'){
      label(ctx,`예정 소모 · 기력 ${s.event.stamina_cost} · 내력 ${s.event.internal_cost}`,cx,top+100,22);
      label(ctx,'준비 후 2수에 실행',cx,top+128,20,'#665943');
    }else{
      label(ctx,'공개된 단서로 상대의 수를 읽는다',cx,top+100,20,'#665943');
      label(ctx,'확정 후 행동과 소모를 표시',cx,top+128,20,'#665943');
    }
  }
  ctx.strokeStyle='rgba(91,75,49,.24)';ctx.beginPath();for(const xx of [449,831]){ctx.moveTo(xx,top+20);ctx.lineTo(xx,top+133);}ctx.stroke();
  const kind=model.compare.kind;
  const title=stage.last_result?'직전 수 · '+model.timing+'수':!stage.enemy_visible?'이번 수 · 공개 대기':kind==='clash'?'합 · 공격 위력 비교':kind==='evade'?'공격과 회피':kind==='guard'?'공격과 방어':'공격 결과';
  label(ctx,title,640,top+27,22);
  label(ctx,model.compare.values[0]===null?'—':String(model.compare.values[0]),537,top+93,52,'#385762');
  let right=stage.enemy_visible?(kind==='evade'?'회피':kind==='guard'?'막기':model.compare.values[1]??'—'):'?';
  label(ctx,String(right),743,top+93,String(right).length>1&&typeof right==='string'?35:52,'#824437',125);
  label(ctx,kind==='clash'||!stage.enemy_visible?'對':'→',640,top+91,38,'#302c23');
  const detail=!stage.verdict_visible?'판정 대기':kind==='clash'?(model.compare.difference===null?'같은 위력 · 상쇄':'합 위력 차이 '+model.compare.difference):kind==='evade'?'회피 조건 충족':kind==='guard'?'방어도 적용 후 '+model.compare.after_block:kind==='miss_range'?'사거리 밖':'적중';
  label(ctx,detail,640,top+128,21,'#554830',338);
  wash(ctx,80,top+147,1120,41,'#252b24');
  const result=stage.damage_visible?'결과 · '+model.result:stage.verdict_visible?model.verdict+' · 타격 결과 대기':stage.enemy_visible?'검을 겨루는 중 · 판정 결과 대기':'상대의 수를 읽고, 내 검로를 정한다';
  label(ctx,result,640,top+175,23,'#f4e6c7',1084);
  label(ctx,stage.last_result?'직전 결과를 남기고, 다음 행동설계로':stage.damage_visible?'검을 거둔다 · 다음 수읽기로':stage.verdict_visible?'다음 연출 · 승자의 공격':stage.enemy_visible?'전투진행 · 확정한 수의 흐름':'행동설계 · 결과는 확정된 순서에 따라 공개',640,top+226,18,'#524b3c');
  ctx.restore();
}
module.exports={readResult,presentationAt,drawResultPanel};
