const assert=require('node:assert/strict'),fs=require('node:fs'),vm=require('node:vm');
const source=fs.readFileSync('tools/html_blueprint_ui/review.js','utf8');
const start=source.indexOf('function syncReviewPanels('),end=source.indexOf('function updateReviewState',start);
const input={value:'',selectionStart:0,selectionEnd:0,selectionDirection:'none',setSelectionRange(a,b,d){this.selectionStart=a;this.selectionEnd=b;this.selectionDirection=d;}};
const fields={'[data-user-comment]':input,'[data-user-status]':{},'[data-history-count]':{},'[data-user-stale]':{},'[data-user-history]':{open:false},'[data-user-result]':{}};
const draft=new Map(),last={id:'stored',status:'changes',comment:'기존 사용자 코멘트',fingerprint:'f'};
const env={reviewPanels:new Map([['asset:a',[{querySelector:s=>fields[s]}]]]),reviewDrafts:draft,lastReview:()=>last,userReviews:{items:{'asset:a':[last]}},recordById:()=>({fingerprint:'f'}),reviewAutosave:{states:new Map()},document:{activeElement:input},refreshReviewQueue(){}};
vm.createContext(env);vm.runInContext(source.slice(start,end),env);
vm.runInContext('syncReviewPanels()',env);
assert.equal(input.value,last.comment,'A focused but pristine field must receive the late initial saved comment');
assert.equal(input.selectionStart,0);
input.value='사용자가 작성 중';draft.set('asset:a',{comment:input.value});
vm.runInContext('syncReviewPanels()',env);
assert.equal(input.value,'사용자가 작성 중','A dirty focused field must not be replaced by a server read');
let untouchedReads=0;
env.reviewPanels.set('asset:unrelated',[{querySelector:s=>{untouchedReads++;return {...fields[s]};}}]);
vm.runInContext("syncReviewPanels(['asset:a'])",env);
assert.equal(untouchedReads,0,'Saving one item must not touch unrelated mounted forms');
async function checkImportSuccess(){
 const imported={project:'ten-paces-hidden-moves',revision:1,items:{'asset:a':[{id:'imported',comment:'가져온 코멘트'}]}},serverResponse={...imported,revision:2};
 const message={textContent:''},notices=[];let importHandler,accepted,request;
 const browserDocument={getElementById:id=>id==='review-import'?{addEventListener:(type,handler)=>{assert.equal(type,'change');importHandler=handler;}}:null,
  querySelectorAll:selector=>{assert.equal(selector,'[data-review-message]');return [message];}};
 const importEnv={document:browserDocument,reviewLoaded:true,userReviews:{revision:1,items:{}},reviewMessage:'',
  reviewAutosave:{flush:async()=>{},accept:value=>{accepted=value;}},reviewRequest:async body=>{request=body;return serverResponse;},reviewNotice:value=>notices.push(value)};
 vm.createContext(importEnv);
 const listener=source.split('\n').find(line=>line.trim().startsWith("document.getElementById('review-import')"));
 assert(listener,'The import event handler must remain connected to the review input');
 vm.runInContext(listener,importEnv);
 await importHandler({target:{files:[{size:100,text:async()=>JSON.stringify(imported)}]}});
 assert.deepEqual(JSON.parse(JSON.stringify(request.document)),imported,'The selected review document must reach the import request');
 assert.equal(accepted,serverResponse,'The successful server response must be accepted');
 assert.deepEqual(notices,[],'A successful import must not report a post-save browser document error');
 assert.equal(message.textContent,'기존 이력을 보존하고 검토 파일을 합쳤습니다.','A successful import must update the mounted success message');
 console.log('Review panel synchronization passed: late initial response, active draft protection, targeted updates and import success message');
}
checkImportSuccess().catch(error=>{console.error(error);process.exitCode=1;});
