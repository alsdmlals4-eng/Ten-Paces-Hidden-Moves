/* Source-level rendering tests. This does not claim a browser or canvas run. */
const fs=require('fs'),path=require('path'),vm=require('vm'),assert=require('assert');
const root=path.resolve(__dirname,'..'),html=fs.readFileSync(path.join(root,'output/blueprint/index.html'),'utf8');
const data=JSON.parse(html.match(/<script id="blueprint-data" type="application\/json">([\s\S]*?)<\/script>/)[1]);
const elements=new Map();
function element(id){if(!elements.has(id))elements.set(id,{value:'',textContent:'',innerHTML:'',dataset:{},addEventListener(){},classList:{toggle(){}},setAttribute(){},removeAttribute(){}});return elements.get(id);}
element('blueprint-data').textContent=JSON.stringify(data);
const env={document:{getElementById:element,querySelectorAll:()=>[],addEventListener(){}},window:{addEventListener(){},scrollTo(){}},location:{hash:'#home'},navigator:{},setTimeout,clearInterval,setInterval,console};
vm.createContext(env);vm.runInContext(fs.readFileSync(path.join(root,'tools/html_blueprint_ui/app.js'),'utf8'),env);
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
for(const expression of ['home()','reader()','people()','assets()','pm()','evidence()','resume()'])check(expression);
for(const g of data.diagrams){check(`maps(${JSON.stringify(g.id)})`);for(const n of g.nodes)check(`maps(${JSON.stringify(g.id)},${JSON.stringify(n.id)})`);}
assert(data.pages.every(p=>p.approved_page?.url),'Missing approved page layout');
for(const t of data.pm.items)check(`pm(${JSON.stringify(t.work_item_id)})`);
for(const p of data.pages)check(`reader(${JSON.stringify(p.id)})`);
for(const a of data.assets)check(`asset(${JSON.stringify(a.id)})`);
for(const p of data.people)check(`people(${JSON.stringify(p.id)})`);
assert(vm.runInContext(`E('<img src=x onerror=alert(1)>')`,env).startsWith('&lt;'));
const initial=check('assets()');element('search').value='no-such-item-673990';assert(check('assets()').includes('검색에 맞는 자산이 없습니다.'));element('search').value='';assert.equal(check('assets()'),initial);
assert(!check('evidence()').includes('브라우저 실행 통과'));
assert(check(`asset(${JSON.stringify(data.assets.find(a=>a.sequence?.length)?.id)})`).includes('motion-play'),'No playable source sequence');
console.log(JSON.stringify({result:'PASS',rendered_views:renders,checked_local_links:links,evidence_level:'SOURCE_RENDERING_NOT_BROWSER'},null,2));
