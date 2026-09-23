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
const starterEvidence=data.inspection.records.find(r=>r.id==='screen:starter');
assert(starterEvidence.states.runtime.includes('정지화면 촬영'),'Starter screen must show its verified still capture');
assert(!starterEvidence.flags.includes('capture'));
const starterAsset=data.inspection.records.find(r=>r.image_number===319);
assert(starterAsset.states.runtime.includes('정지화면 촬영'),'Starter asset must retain the same evidence');
assert(data.inspection.records.find(r=>r.id==='screen:plan').flags.includes('capture'),'AI-edited reference must not count as runtime capture');
// Approved media/table correction: compact overview, shared progression and exact card playback.
const screenCards=check("reader('reader-006')");
assert(screenCards.includes('screen-gallery'),'Atlas must group screen/label/comment in one card');
assert.equal((screenCards.match(/data-screen-context=/g)||[]).length,9);
assert(screenCards.includes('전투 준비 화면'));
const manualComparison=check('manualCatalog()');
assert.equal((manualComparison.match(/data-common-growth/g)||[]).length,1,'Growth belongs in one common table');
assert.equal((manualComparison.match(/data-card=/g)||[]).length,30);
assert(!manualComparison.includes('<video '),'Catalog must open a chosen clip without mounting30players');
for(const m of data.manuals)for(const c of Object.values(m.cards))assert(manualComparison.includes('href="#motion/'+c.id+'"'));
const eventReading=check("reader('reader-011')");
assert.equal((eventReading.match(/data-event-id=/g)||[]).length,10,'Each event is a separately titled situation');
assert.equal((eventReading.match(/class="choice-number"/g)||[]).length,30,'Three outcomes stay visible per event');
assert(eventReading.includes('일반 사건 · 기연 없음')&&eventReading.includes('성공 후 추가 10%'));
const escapedEvent=vm.runInContext(`eventCatalogView({chance_rule:D.giyun.chance_rule,events:[{id:'evil',title:'<img onerror=alert(1)>',text:'<script>',choices:[]}]})`,env);
assert(!escapedEvent.includes('<img onerror')&&!escapedEvent.includes('<script>'),'Event source text must be escaped');
assert(!check('movies()').includes('<video '),'Clip index should use selectable medium thumbnails');
assert(check('basicActionCards()').includes('sprite-window'),'Crop real img elements to recover clear image errors');
const growthOverview=check('home()');
assert(growthOverview.indexOf('id="overview-manuals"')<growthOverview.indexOf('data-common-growth'),'Existing growth links must land before the common table');
assert.equal((check("reader('reader-030')").match(/class="screen-card card"/g)||[]).length,16,'Portrait list should use16compact cells');
for(let n=97;n<=104;n++){const comparison=check('reader('+JSON.stringify('reader-'+String(n).padStart(3,'0'))+')');assert(comparison.includes('class="tactics-table"'));assert(comparison.includes('약점')&&comparison.includes('대응'));}
assert(check("reader('reader-005')").includes('screen-gallery'));
assert(check("reader('reader-020')").includes('image-comparison-table'));
const executionComparison=check("reader('reader-020')");
assert(executionComparison.includes('common-screen-info'),'Shared progress/result needs its own screen-wide row');
assert(!executionComparison.split('</tbody>')[0].includes('현재 계획  1 / 3'),'Whole-screen result must not be attached to opponent card');

const sequence=check("reader('reader-022')");assert(sequence.includes('sequence-comparison'));assert(sequence.includes('첫째 타격')&&sequence.includes('셋째 타격'));
const actionCatalog=check('basicActionCards()');
const basicArt=data.image_catalog.find(r=>r.number===19);
assert.equal((actionCatalog.match(/data-basic-action=/g)||[]).length,10);
assert.equal((actionCatalog.match(new RegExp('data-user-review="'+basicArt.record_id+'"','g'))||[]).length,1,'Basic action atlas must keep its shared inline comment');
const planThumb=check('atlasPreview(D.experience.contexts.plan.preview,0,0,200,88)');
assert(planThumb.includes('viewBox="'+data.experience.contexts.plan.preview.region.join(' ')+'"'),'Atlas thumbnail must respect the edited reference crop');
const removedImage=data.assets.find(a=>a.image_number===141);
assert(check(`userReviewPanel(recordById('asset:${removedImage.id}'))`).includes('삭제 완료'),'Direct deletion must not be labelled as a move');
for(const page of data.pages)assert(all.includes(`data-reader="${page.id}"`),'Overview omits explanation '+page.id);
for(const person of data.people)assert(all.includes(person.name),'Overview omits person');
for(const manual of data.manuals)for(const card of Object.values(manual.cards))assert(all.includes(`data-card="${card.id}"`),'Overview omits card');
assert(vm.runInContext('nav[0][0]',env)==='maps','Atlas must be the first navigation');
assert(!html.includes('<aside>'),'Persistent sidebar wastes the reading area');
assert(element('nav').innerHTML.includes('#home/audit'),'Image navigation must jump to its complete section');
for(const g of data.reader_groups)assert(element('nav').innerHTML.includes('#home/'+g.id));
assert.equal((all.match(/class="overview-group"/g)||[]).length,6);
const beforeQuery=env.document.querySelector;
env.document.querySelector=selector=>selector==='.overview-group'?{}:null;
env.location.hash='#home/route';element('main').innerHTML='keep-mounted-items';
vm.runInContext("lastRoute='#home';render()",env);
assert.equal(element('main').innerHTML,'keep-mounted-items','Section jump must preserve mounted forms, focus and image layout');
env.document.querySelector=beforeQuery;env.location.hash='#home';vm.runInContext('render()',env);
const firstNumbered=data.assets.find(a=>a.image_number===1);
assert(element('nav').innerHTML.includes('#changes'),'Change comparison must remain reachable');
for(const n of [50,300]){
 element('search').value='이미지 '+n;
 const row=data.image_catalog.find(r=>r.number===n);
 assert(check('searchResults()').includes(encodeURIComponent(row.record_id)),'Exact image number search missing');
}
element('search').value='';
const cropped=data.pages.flatMap(p=>p.blocks).find(b=>b.region);
assert(check('block('+JSON.stringify(cropped)+')').includes('data-image-number='),'Cropped image caption missing');
assert(firstNumbered,'The numbered image catalog must start at one');
const firstTile=check(`tile(${JSON.stringify(firstNumbered)})`);
assert(firstTile.includes('data-image-number="1"'));
assert(firstTile.includes('data-user-review="asset:'+firstNumbered.id+'"'),'Inline image comment missing');
assert(data.image_catalog.every(r=>r.kind&&r.usage&&r.usage_evidence),'Image captions need kind, number and evidenced usage');
assert.equal(new Set(data.image_catalog.map(r=>r.number)).size,data.image_catalog.length,'Image numbers collide');
assert(check('home()').includes('id="overview-audit"'));
assert(check('home()').includes('id="overview-reviews"'));
const replacement=check(`block({kind:'image',path:'docs/blueprint/evidence/reference-screens/54d7b849fff7d6b9a639007f08147401.png',page_id:'reader-006'})`);
assert(replacement.includes('assets/blueprint/clash_explanation_v1.png')&&replacement.includes('이전 참고 이미지'));
for(const id of ['reader-013','reader-015']){
 const html=check(`reader('${id}')`);assert(!html.includes('planning-1440.png')&&!html.includes('planning-960.png'),'Unrelated battle image in '+id);
}
assert(!check("block({kind:'image',path:'docs/blueprint/evidence/reference-screens/54d7b849fff7d6b9a639007f08147401.png',page_id:'reader-013'})").includes('clash_explanation_v1'),'Replacement must be scoped to a semantic page');
const whole=check('home()');assert(whole.indexOf('id="all-reader-010"')<whole.indexOf('id="all-reader-009"'));
assert.equal((whole.match(/data-numbered-image="inventory-13fcfaaa5d6cee4a"/g)||[]).length,1,'Disposal tombstone appears once in the overview');
assert(check('userReviewPanel(inspections[0])').includes('자동 저장'));
assert(check('auditGallery()').includes('폐기 요청'));

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

assert.equal(vm.runInContext('typeof userReviewPanel',env),'function','Missing user status/comment editing');
assert(check('reviewQueue()').includes('코멘트'));
assert(check('auditGallery()').includes('정리'));
assert(check("intentPanel(recordById('screen:menu'))").includes('만든 이유'));
assert(vm.runInContext("requestFor(recordById('screen:menu'))",env).includes('만든 이유'));
assert(check("userReviewPanel(recordById('screen:menu'))").includes('textarea'));
assert(!check("userReviewPanel(recordById('screen:menu'))").includes('value="approved"'));
assert(vm.runInContext("feedbackText({status:'changes',comment:'<script>x</script>'})",env).includes('&lt;script&gt;'));

const candidateDocAsset=data.assets.find(a=>a.scope==='PR342_CANDIDATE'&&a.audit.document_references.length);
assert(candidateDocAsset,'Candidate document references must be inventoried');
const candidateAudit=check(`auditDetail(${JSON.stringify(candidateDocAsset)})`);
assert(candidateAudit.includes('/blob/'+candidateDocAsset.revision+'/'),'Candidate document must use candidate revision');
assert(!candidateDocAsset.audit.flags.includes('unreferenced'));
assert(check('auditGallery()').includes('종류 · 같은 캐릭터'));
console.log(JSON.stringify({result:'PASS',rendered_views:renders,checked_local_links:links,evidence_level:'SOURCE_RENDERING_NOT_BROWSER'},null,2));
