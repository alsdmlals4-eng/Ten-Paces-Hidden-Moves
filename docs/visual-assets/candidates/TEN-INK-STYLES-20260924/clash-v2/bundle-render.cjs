/* A 3/3/4 resolution film. No replacement planning screen and no combat calculations. */
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const {loadStage,drawStage,state,createCanvas,inkBar}=require('./render.cjs');
const {buildSequence,frameAt,changes}=require('./bundle-model.cjs');
const sequence=buildSequence(require('./bundle-fixtures.json'));
const HERE=__dirname,ROOT=path.resolve(HERE,'../../../../..'),OUT=path.join(ROOT,'output/ink-clash-bundles');
const W=1280,H=1104,FPS=20;
const clamp=x=>Math.max(0,Math.min(1,x)),smooth=x=>{x=clamp(x);return x*x*(3-2*x);};
function blend(a,b,u){u=smooth(u);const s={...b};for(const k of ['px','py','ex','ey','pr','er','zoom'])s[k]=a[k]+(b[k]-a[k])*u;if(u<.35){s.p=a.p;s.e=a.e;}return s;}
function endPose(start,step){
 if(step.kind==='preparation')return state(1.08);
 if(step.kind==='clash')return state(4.12);
 if(step.kind==='guard')return {...state(2.01),p:4,e:8,pr:0,er:0,zoom:1.025};
 if(step.kind==='move')return {...start,p:0,e:0,px:start.px+65,pr:0,er:0,zoom:1.025};
 return {...start,p:8,e:8,pr:0,er:0,zoom:1.015};
}
let last=state(0);
for(const b of sequence.bundles){b.startPose=last;for(const s of b.steps){s.startPose={...last};s.endPose=endPose(last,s);last=s.endPose;}b.endPose=last;}
function choreography(frame){
 const {step:s,ratio:u}=frame;
 if(!s){const b=sequence.bundles[frame.bundle-1];return {pose:frame.kind==='opening'?b.startPose:b.endPose,effectTime:null};}
 if(s.kind==='clash'){
  // The entry blends from the previous action's actual last pose. The continuous
  // scene does not teleport back to neutral between timings.
  const t=1.1+clamp((u-.10)/.90)*3.02;
  return {pose:u<.10?blend(s.startPose,state(1.1),u/.10):state(t),effectTime:u<.10?null:t};
 }
 if(s.kind==='guard'){
  if(u<.18)return {pose:blend(s.startPose,state(1.61),u/.18),effectTime:null};
  if(u<.73){const t=1.61+(u-.18)/.55*.40;return {pose:state(t),effectTime:t};}
  return {pose:blend(state(2.01),s.endPose,(u-.73)/.27),effectTime:null};
 }
 let pose=blend(s.startPose,s.endPose,u);
 if(s.kind==='move'&&u>.12&&u<.86)pose.p=2;
 return {pose,effectTime:null};
}
function text(q,value,x,y,size=24,color='#302d24',max=1180,align='center'){
 q.font=size+'px Book';q.textAlign=align;q.fillStyle=color;
 while(q.measureText(value).width>max&&size>15){size--;q.font=size+'px Book';}q.fillText(value,x,y);
}
function paper(q,x,y,w,h){q.fillStyle='#e9ddc2';q.fillRect(x,y,w,h);q.strokeStyle='#83704c';q.lineWidth=2;q.strokeRect(x,y,w,h);q.strokeStyle='#bba881';q.lineWidth=1;q.strokeRect(x+5,y+5,w-10,h-10);}
function drawUI(q,f){
 const b=sequence.bundles[f.bundle-1];
 inkBar(q,35,20,540,43,'rgba(240,232,211,.96)');text(q,`제 ${f.bundle} 묶음 · ${b.slots.length}수   |   ${f.phase}`,55,49,25,'#302d24',500,'left');
 inkBar(q,923,20,315,43,'rgba(35,40,35,.91)');text(q,'3수 → 3수 → 4수',1080,49,24,'#eee4cb',285);
 const source=f.step?(f.result_visible?f.step.after:f.step.before):(f.kind==='opening'?b.before:b.after);
 text(q,'거리 '+Math.abs(source.enemy.tile-source.player.tile),1128,99,24);
 if(f.kind==='planning-boundary'){
  paper(q,225,255,830,170);text(q,'다음 묶음은 기존 준비 화면에서 설계',640,319,33);text(q,'다음 장면은 준비를 마친 뒤 확정한 행동의 예시입니다',640,370,25);
 }
 paper(q,34,694,1212,146);
 text(q,'확정한 행동 묶음',56,721,21,'#4d4535',260,'left');
 const slots=f.slots.length?f.slots:b.slots.map(s=>({player:s.player.label,enemy:s.enemy.label,local:s.local,timing:s.timing,status:'완료'}));
 const gap=12,cw=(1166-(slots.length-1)*gap)/slots.length;
 slots.forEach((s,i)=>{const x=57+i*(cw+gap),active=s.status==='진행',done=s.status==='완료';
  q.fillStyle=active?'#293e3c':done?'#d0c5aa':'#f1e8d4';q.fillRect(x,732,cw,90);q.strokeStyle=active?'#b08846':'#aa9771';q.lineWidth=active?3:1;q.strokeRect(x,732,cw,90);
  const color=active?'#f6edd6':'#302d24';text(q,`${s.local}수 · ${s.status}`,x+cw/2,755,19,color,cw-20);text(q,s.player,x+cw/2,783,24,color,cw-20);text(q,'상대 · '+s.enemy,x+cw/2,808,18,color,cw-20);
 });
 paper(q,34,851,1212,209);
 if(f.step){
  const s=f.step;
  for(const [a,cx,color] of [['player',255,'#385762'],['enemy',1025,'#824437']]){
   text(q,a==='player'?'플레이어':'상대',cx,879,21,color);inkBar(q,cx-166,890,332,35,color);text(q,s[a].label,cx,916,25,'#f7efdb',312);
   const d=s.delta[a],prepaid=s[a].event?.outcome==='response';
   const cost=prepaid?`기력 ${s[a].event.stamina_cost} · 묶음 시작에 지불`:f.result_visible?`기력 ${d.stamina>0?'+':''}${d.stamina} · 내력 ${d.internal>0?'+':''}${d.internal}`:'자원 변화 · 해결 뒤 표시';
   text(q,cost,cx,959,21,'#302d24',345);
  }
  text(q,f.verdict_visible?s.verdict:'이번 수 · 해결 중',640,890,25,'#343329',382);
  text(q,s.compare?`${s.compare[0]}  對  ${s.compare[1]}`:s.kind==='preparation'?'전조 → 실행':s.kind==='guard'?'공격 → 막기':s.kind==='move'?'발걸음':'호흡',640,953,s.compare?44:30,'#794737',380);
  inkBar(q,54,985,1172,50,'#262b25');
  text(q,f.result_visible?s.result:f.verdict_visible?'판정 확정 · 동작의 끝까지 이어집니다':'앞 수의 회수에서 다음 움직임으로',640,1019,24,'#f5e9cd',1130);
 }else{
  text(q,f.kind==='opening'?'확정한 수를 이어서 해결합니다':f.kind==='complete'?'묶음의 모든 수 해결 완료':'기존 행동설계 방식 유지',640,902,31);
  text(q,f.kind==='opening'?f.response:f.kind==='complete'?f.conclusion:'준비를 마치고 확정한 뒤, 다음 묶음의 연출이 시작됩니다',640,948,24,'#514b3b',1130);
  text(q,f.kind==='complete'?'묶음 완료 기세는 개별 합의 결과와 따로 표시합니다':'수의 개수는 공격 횟수가 아닙니다 · 전조와 실행을 구분합니다',640,1018,22,'#6c6048',1130);
 }
 text(q,'전투 합 연출 시안 · 실제 판정 기록 / 준비 화면은 기존 방식 유지',640,1091,19,'#605b4e');
}
async function main(){
 const art=await loadStage();fs.mkdirSync(path.join(OUT,'frames'),{recursive:true});fs.mkdirSync(path.join(OUT,'qa'),{recursive:true});
 const c=createCanvas(W,H),q=c.getContext('2d'),only=process.argv.includes('--samples'),frames=[];
 const sampleTimes=[.4,...sequence.bundles.flatMap(b=>b.steps.map(s=>s.start+(s.end-s.start)*.80)),...sequence.bundles.map(b=>b.end-.4),sequence.bundles[1].start-.8];
 const samples=new Set(sampleTimes.map(t=>Math.round(t*FPS))),count=Math.ceil(sequence.duration*FPS);
 for(let i=0;i<count;i++){
  if(only&&!samples.has(i))continue;
  const t=i/FPS,f=frameAt(sequence,t),motion=choreography(f);q.fillStyle='#e9e2d1';q.fillRect(0,0,W,H);
  drawStage(q,art,motion.pose,{clock:t,effectTime:motion.effectTime,hero:f.step?.player.event?.action_slots===2});drawUI(q,f);
  const bytes=c.toBuffer('image/png'),name=String(i).padStart(4,'0')+'.png';
  if(!only)fs.writeFileSync(path.join(OUT,'frames',name),bytes);if(samples.has(i))fs.writeFileSync(path.join(OUT,'qa',name),bytes);
  if(i===Math.round((sequence.bundles[2].steps[1].start+(sequence.bundles[2].steps[1].end-sequence.bundles[2].steps[1].start)*.80)*FPS))fs.writeFileSync(path.join(HERE,'bundle-poster.png'),bytes);
  frames.push({frame:i,time:t,bundle:f.bundle,timing:f.step?.timing??null,phase:f.phase,sha256:crypto.createHash('sha256').update(bytes).digest('hex')});
  if(!only&&i%100===0)console.log(`Rendered ${i}/${count}`);
 }
 const report={method:'OFFLINE_APPROVED_ART_COMPOSITING_WITH_ACTUAL_RESOLVER_RECORDS',fps:FPS,size:[W,H],duration_seconds:count/FPS,frame_count:frames.length,samples_only:only,sequence:sequence.bundles.map(b=>({index:b.index,start:b.start,end:b.end,slots:b.slots.length,timings:b.steps.map(s=>({timing:s.timing,start:s.start,end:s.end,kind:s.kind}))})),frames};
 fs.writeFileSync(path.join(only?path.join(OUT,'qa'):HERE,only?'sample-check.json':'bundle-render-check.json'),JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify({frames:frames.length,seconds:count/FPS,out:OUT}));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
