/* Source-level rendering tests. This does not claim a browser or canvas run. */
const fs=require('fs'),path=require('path'),vm=require('vm'),assert=require('assert');
const root=path.resolve(__dirname,'..'),html=fs.readFileSync(path.join(root,'output/blueprint/index.html'),'utf8');
const data=JSON.parse(html.match(/<script id="blueprint-data" type="application\/json">([\s\S]*?)<\/script>/)[1]);
const elements=new Map();
function element(id){if(!elements.has(id))elements.set(id,{value:'',textContent:'',innerHTML:'',dataset:{},addEventListener(){},insertAdjacentHTML(){},classList:{toggle(){}},setAttribute(){},removeAttribute(){}});return elements.get(id);}
element('blueprint-data').textContent=JSON.stringify(data);
const env={document:{getElementById:element,querySelector:()=>null,querySelectorAll:()=>[],addEventListener(){}},window:{addEventListener(){},scrollTo(){}},location:{hash:'#home'},navigator:{},setTimeout,clearTimeout,clearInterval,setInterval,console};
vm.createContext(env);vm.runInContext(html.slice(html.lastIndexOf('<script>')+8,html.lastIndexOf('</script>')),env);
const manifest=JSON.parse(fs.readFileSync(path.join(root,'output/blueprint/manifest.json'),'utf8'));
for(const dependency of ['tools/blueprint_layout.py','tools/build_opponent_stage_blueprint.py','tools/blueprint_readiness_pages.py'])assert(manifest.inputs[dependency],'Untracked display dependency: '+dependency);
const allow=new Set([...Object.keys(manifest.inputs),...Object.keys(manifest.media),'output/blueprint/index.html','output/blueprint/manifest.json','output/blueprint/resume-index.json']);
let renders=0,links=0;
function check(expression){const result=vm.runInContext(expression,env);assert.equal(typeof result,'string');assert(!result.includes('undefined'),'Undefined text in '+expression);
 for(const hit of result.matchAll(/(?:href|src)="([^"]+)"/g)){
  const url=hit[1].replaceAll('&amp;','&');
  assert(!/^javascript:|^data:|^file:/i.test(url),'Unsafe URL');
  if(url.startsWith('#')||/^https?:/.test(url))continue;
  const file=path.resolve(root,'output/blueprint',decodeURI(url));
  assert(file.startsWith(root+path.sep),'Escaped root: '+url);
  assert(fs.existsSync(file),'Missing link in '+expression+': '+url);
  assert(allow.has(path.relative(root,file).split(path.sep).join('/')),'Link excluded from HTTP preview: '+url);links++;
 }
 renders++;return result;
}
for(const expression of ['home()','reader()','people()','assets()','pm()','evidence()','resume()','inspect()','changes()','searchResults()'])check(expression);
for(const r of data.inspection.records)check(`inspect(${JSON.stringify(r.id)})`);
assert(check("maps('game-loop','menu')").includes('atlas-workbench'));
assert(check("maps('game-loop','menu')").includes('screen-actions'));
for(const clip of data.experience.clips){
 const result=check(`movie(${JSON.stringify(clip)})`);
 assert(result.includes('data-inspect-copy'));
 if(clip.timeline?.length)assert(result.includes('data-phase-video'));
}
const first=data.inspection.records[0];
assert.equal(vm.runInContext("typeof reviewSeekTime",env),'function','Short review loops need a frame-level boundary');
assert.equal(vm.runInContext("reviewSeekTime(1.31,{start:1.01,end:1.16},true)",env),1.01);
assert.equal(vm.runInContext("reviewSeekTime(1.31,{start:1.01,end:1.16},false)",env),null);
assert(vm.runInContext(`changedRecords({${JSON.stringify(first.id)}:'old'}).some(r=>r.id===${JSON.stringify(first.id)})`,env));
assert(vm.runInContext(`changedRecords({retired:'old'}).some(r=>r.change==='added')`,env),'New entries must be visible');
assert(vm.runInContext(`changedRecords({retired:'old'}).some(r=>r.id==='retired'&&r.change==='removed')`,env),'Removed entries must be visible');
assert(vm.runInContext(`requestFor(recordById('clip:clash-lose'),.5)`,env).includes('0.500초'));
assert(vm.runInContext(`requestFor(recordById('clip:clash-lose'),.5)`,env).includes('사용자 검수=항목별 사용자 검수 미기록'));
const candidateRecord=data.inspection.records.find(r=>r.id==='asset:pr342-clash_sparks_ink_gold_v2');
assert(candidateRecord.tasks.some(t=>t.id==='PRESENTATION-PREFERENCES'&&t.scope==='PR342_CANDIDATE'),'Candidate asset lost its candidate PM');
assert(vm.runInContext(`requestFor(recordById(${JSON.stringify(candidateRecord.id)}))`,env).includes(data.candidate.revision),'Candidate request lost exact source revision');
const all=check('home()');
for(const page of data.pages)assert(all.includes(`data-reader="${page.id}"`),'Overview omits explanation '+page.id);
for(const person of data.people)assert(all.includes(person.name),'Overview omits person');
for(const manual of data.manuals)for(const card of Object.values(manual.cards))assert(all.includes(`data-card="${card.id}"`),'Overview omits card');
assert(vm.runInContext('nav[0][0]',env)==='maps','Atlas must be the first navigation');
for(const id of ['menu','starter','brief','plan','resolve'])assert(check(`maps('game-loop','${id}')`).includes('id="stage-detail"'),'Missing usable atlas content');
for(const clip of data.experience.clips)assert(check(`movies('test',[${JSON.stringify(clip.id)}])`).includes('<video '),'Missing real movie');
for(const g of data.diagrams){check(`maps(${JSON.stringify(g.id)})`);for(const n of g.nodes)check(`maps(${JSON.stringify(g.id)},${JSON.stringify(n.id)})`);}
assert(check("reader('reader-001')").includes('Dopamine Driven Development'));
assert(check('people()').includes('성수별 성장 효과'));
for(const g of data.giyun.giyun)assert(check(`giyunCatalog(${JSON.stringify(g.id)})`).includes(g.name));
env.location.hash='#giyun';vm.runInContext('render()',env);assert.equal(vm.runInContext('lastRoute',env),'#giyun');
assert(data.pages.every(p=>p.approved_page?.url),'Missing approved page layout');
for(const t of data.pm.items)check(`pm(${JSON.stringify(t.work_item_id)})`);
for(const p of data.pages)check(`reader(${JSON.stringify(p.id)})`);
for(const a of data.assets)check(`asset(${JSON.stringify(a.id)})`);
for(const p of data.people)check(`people(${JSON.stringify(p.id)})`);
assert(vm.runInContext(`E('<img src=x onerror=alert(1)>')`,env).startsWith('&lt;'));
const initial=check('assets()');element('search').value='no-such-item-673990';assert(check('assets()').includes('검색에 맞는 자산이 없습니다.'));element('search').value='';assert.equal(check('assets()'),initial);
element('search').value='no-such-item-673990';
const completeOverview=check('home()');
for(const item of data.pm.items)assert(completeOverview.includes(item.title??item.work_item_id),'Overview must ignore another page search');
const completeBrief=check("maps('game-loop','brief')");
for(const person of data.people)assert(completeBrief.includes(person.name),'Brief must ignore another page search');
element('search').value='';
assert(!check('evidence()').includes('브라우저 실행 통과'));
assert(check(`asset(${JSON.stringify(data.assets.find(a=>a.sequence?.length)?.id)})`).includes('motion-play'),'No playable source sequence');
// Exercise the bound recovery UI across consecutive failed network retries.
let notice=null;
const listeners=[];
const image={isConnected:true,complete:false,naturalWidth:0,src:'http://127.0.0.1:8000/example.png',
 closest:()=>null,get nextElementSibling(){return notice;},
 addEventListener(type,fn,options){if(type==='error')listeners.push({fn,once:options?.once});},
 insertAdjacentElement(_,node){notice=node;},
 fail(){for(const listener of [...listeners]){listener.fn();if(listener.once)listeners.splice(listeners.indexOf(listener),1);}}};
env.URL=URL;
env.document.querySelectorAll=selector=>selector==='img'?[image]:[];
env.document.createElement=tag=>({tag,classList:{contains:name=>name==='media-recovery'},append(child){this.child=child;},remove(){notice=null;}});
vm.runInContext('bind()',env);
for(let attempt=0;attempt<3;attempt++){
 image.fail();assert(notice&&notice.child,'Failed retry must retain a recovery button');
 notice.child.onclick({preventDefault(){},stopPropagation(){}});
 assert(!notice,'Retry clears only the previous notice');
}
console.log(JSON.stringify({result:'PASS',rendered_views:renders,checked_local_links:links,evidence_level:'SOURCE_RENDERING_NOT_BROWSER'},null,2));
