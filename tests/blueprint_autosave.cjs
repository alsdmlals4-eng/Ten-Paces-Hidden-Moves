/* Behavioral queue tests; browser layout is verified separately. */
const assert=require('node:assert/strict');
const {ReviewAutosave}=require('../tools/html_blueprint_ui/review_state.js');
const pause=()=>new Promise(resolve=>setImmediate(resolve));
async function run(){
 let doc={revision:0,items:{}}, writes=[], notices=[], durable={};
 const client=new ReviewAutosave({delay:100000,read:async()=>structuredClone(doc),
  write:async body=>{if(body.revision!==doc.revision){const e=Error('conflict');e.status=409;throw e;}
   writes.push(body);doc.revision++;(doc.items[body.item_id]??=[]).push({...body,id:String(doc.revision)});return structuredClone(doc);},
  persist:items=>durable=structuredClone(items), notify:(id,state)=>notices.push([id,state]),changed:()=>{}});
 await client.load();
 client.edit('asset:a',{status:'changes',comment:'한글 초안',fingerprint:'f',source_revision:'h'});
 assert.equal(durable['asset:a'].comment,'한글 초안','Input must be durable before debounce');
 client.edit('asset:a',{status:'changes',comment:'한글 완성',fingerprint:'f',source_revision:'h'});
 await client.flush();assert.equal(writes.length,1);assert.equal(doc.items['asset:a'][0].comment,'한글 완성');
 assert.equal(Object.keys(durable).length,0);assert(notices.some(x=>x[1]==='saved'));
 client.edit('asset:a',{status:'changes',comment:'한글 완성',fingerprint:'f',source_revision:'h'});
 await client.flush();assert.equal(writes.length,1,'Unchanged input must not append history');
 client.edit('asset:a',{status:'discard',comment:'폐기',fingerprint:'f',source_revision:'h'});
 doc.revision++;doc.items['asset:b']=[{id:'external',status:'checked',comment:''}];
 await client.flush();assert.equal(doc.items['asset:a'].at(-1).status,'discard','Unrelated concurrent changes may retry safely');
 client.edit('asset:a',{status:'changes',comment:'내 수정',fingerprint:'f',source_revision:'h'});
 doc.revision++;doc.items['asset:a'].push({id:'other',status:'hold',comment:'다른 창'});
 await client.flush();assert.equal(doc.items['asset:a'].at(-1).comment,'다른 창');
 assert.equal(client.drafts.get('asset:a').comment,'내 수정');assert.equal(client.states.get('asset:a'),'conflict');
 await client.load();assert.equal(client.drafts.get('asset:a').comment,'내 수정','Refresh must preserve conflicting draft');
 client.retry('asset:a');await client.flush();assert.equal(doc.items['asset:a'].at(-1).comment,'내 수정');
 client.edit('asset:a',{status:'changes',comment:'import 이전 입력',fingerprint:'f',source_revision:'h'});
 const beforeImport=structuredClone(doc);
 doc.revision++;doc.items['asset:a'].push({id:'imported',status:'hold',comment:'합쳐진 최신 기록'});
 client.accept(structuredClone(doc));await client.flush();
 assert.equal(doc.items['asset:a'].at(-1).comment,'합쳐진 최신 기록','Accepted import must not let a stale draft overwrite it');
 assert.equal(client.states.get('asset:a'),'conflict');
 client.accept(beforeImport);assert.equal(client.document.revision,doc.revision,'Late reads must not roll back the document');
 client.retry('asset:a');await client.flush();
 let release;client.write=body=>new Promise(resolve=>{release=()=>{doc.revision++;doc.items[body.item_id].push({...body,id:String(doc.revision)});resolve(structuredClone(doc));};});
 client.edit('asset:a',{status:'changes',comment:'first',fingerprint:'f',source_revision:'h'});
 const pending=client.flush();await pause();
 client.edit('asset:a',{status:'changes',comment:'second',fingerprint:'f',source_revision:'h'});release();await pending;
 assert.equal(client.drafts.get('asset:a').comment,'second','Typing during in-flight save must survive');
 client.write=async()=>{throw Error('offline');};await client.flush();
 assert.equal(client.states.get('asset:a'),'error');assert.equal(durable['asset:a'].comment,'second');
 const restored=new ReviewAutosave({read:async()=>structuredClone(doc),write:client.write,persist:()=>{},notify:()=>{},changed:()=>{},drafts:durable,delay:100000});
 await restored.load();assert.equal(restored.drafts.get('asset:a').comment,'second');
 client.cancelTimers();restored.cancelTimers();
 let timerWrites=0;
 const timed=new ReviewAutosave({delay:15,read:async()=>({revision:0,items:{}}),write:async body=>{timerWrites++;return {revision:timerWrites,items:{[body.item_id]:[{...body,id:String(timerWrites)}]}};},persist:()=>{},notify:()=>{},changed:()=>{}});
 await timed.load();timed.edit('x',{status:'changes',comment:'ㅎ',fingerprint:'f',source_revision:'h'},{compose:true});
 await new Promise(r=>setTimeout(r,40));assert.equal(timerWrites,0,'IME composition must not save incomplete syllables');
 timed.edit('x',{status:'changes',comment:'한글',fingerprint:'f',source_revision:'h'});
 await new Promise(r=>setTimeout(r,40));assert.equal(timerWrites,1,'Pause in typing must save without a button or blur');
 timed.cancelTimers();
 console.log('Autosave behavioral checks passed: debounce, durable drafts, no-op, discard, concurrency, conflict, in-flight edit, offline, reload');
}
run().catch(e=>{console.error(e);process.exitCode=1;});
