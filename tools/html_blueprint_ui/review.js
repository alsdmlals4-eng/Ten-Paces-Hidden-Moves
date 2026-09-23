/* User review is editable; source implementation and approval evidence stay separate. */
const userStatuses={pending:'미검토',checked:'확인 완료',changes:'수정 요청',hold:'보류',discard:'폐기 요청'};
let userReviews={schema_version:1,project:'ten-paces-hidden-moves',revision:0,items:{}},reviewLoaded=false,reviewLoading=false,reviewMessage='검토 기록을 불러오는 중입니다.';
const reviewPanels=new Map();
const reviewMessages={pending:'작성 중 · 잠시 멈추면 자동 저장',saving:'저장 중…',saved:'저장됨',error:'저장 실패 · 입력을 보존했습니다.',conflict:'다른 창에서 이 항목을 수정했습니다. 입력을 보존했습니다.', 'temporary-error':'임시 보관 실패 · 창을 닫지 말고 저장 결과를 확인하세요.'};
let draftStorageKey='',draftStorageError='';
function recoverReviewDrafts(){try{
 const key='tenpaces-review-tab';let client=sessionStorage.getItem(key);
 if(!client){client=Date.now().toString(36)+Math.random().toString(36).slice(2);sessionStorage.setItem(key,client);}
 draftStorageKey='tenpaces-review-drafts:'+D.review_location+':'+client;
 const items=JSON.parse(localStorage.getItem(draftStorageKey)||'{}');
 return Object.fromEntries(Object.entries(items).filter(([id,d])=>recordById(id)&&d&&d.status in userStatuses&&typeof d.comment==='string'&&d.comment.length<=10000));
 }catch(error){draftStorageError=error.message;return {};}}
const reviewAutosave=new ReviewAutosave({drafts:recoverReviewDrafts(),read:()=>reviewRequest(),write:body=>reviewRequest(body),
 persist:items=>{if(!draftStorageKey)throw Error(draftStorageError||'브라우저 임시 보관을 사용할 수 없습니다.');if(Object.keys(items).length)localStorage.setItem(draftStorageKey,JSON.stringify(items));else localStorage.removeItem(draftStorageKey);},
 changed:(value,ids)=>{userReviews=value;syncReviewPanels(ids);},notify:(id,state,error)=>{updateReviewState(id,state,error);refreshReviewCounts();}});
const reviewDrafts=reviewAutosave.drafts;
let noteFilter='all',auditFilter='all',auditGroup='all';
const auditNames={discarded:'폐기 처리 완료',all:'전체 이미지',runtime:'게임 참조 있음',documents:'문서·기획·테스트 참조',unverified:'승인 근거 미확인',approval_gap:'승인 미확인 · 게임 참조',replaced:'교체 이력 있음',duplicate:'동일 파일 있음',unreferenced:'직접 참조 미확인',retain:'보존 필요'};
function lastReview(id){return userReviews.items[id]?.at(-1);}
function feedbackText(row){return row?`${E(userStatuses[row.status]||row.status)} · ${E(row.comment||'코멘트 없음')}`:'미검토 · 코멘트 없음';}
function intentPanel(r){const i=r?.intent;if(!i)return '';
 const pairs=[['만든 이유',i.purpose],['의도한 경험',i.experience],['설계 이유',i.rationale],['성공 기준',i.success],['실패 징후',i.failure]].filter(x=>x[1]);
 return `<section class="panel intent-panel"><h3>의도 · 목표</h3><p>${E(i.status)}</p>${pairs.length?table(['관점','내용'],pairs):'<p>이 항목의 제작 의도를 확정한 기록이 없습니다. 용도·파일 이름으로 의도를 추정하지 않습니다.</p>'}<div class="links">${(i.sources||[]).map(p=>link(p,'기획·결정 원본')).join('')}${(i.related_items||[]).map(id=>`<a href="#inspect/${encodeURIComponent(id)}">연결된 ${E(recordById(id)?.name||id)}의 목적 →</a>`).join('')}</div></section>`;
}
function reviewHistory(id){return (userReviews.items[id]||[]).slice().reverse().map(row=>`<article class="review-history"><small>${E(row.updated_at)} · 기준 ${E(row.source_revision)}</small><p>${feedbackText(row)}</p></article>`).join('');}
function userReviewPanel(r){if(!r?.id)return '';const last=lastReview(r.id),draft=reviewDrafts.get(r.id),current=draft||last||{status:'pending',comment:''};
 return `<section class="user-review" data-user-review="${E(r.id)}"><div class="review-toolbar"><label>검토 상태 <select data-user-status>${Object.entries(userStatuses).map(([v,t])=>`<option value="${v}" ${v===current.status?'selected':''}>${t}</option>`).join('')}</select></label>${r.kind==='자산'||r.id.startsWith('asset:')||r.kind==='설명 이미지'?`<button data-user-discard ${byId(r.id.replace('asset:',''))?.details?.retired?'disabled':''}>${byId(r.id.replace('asset:',''))?.details?.retired?(byId(r.id.replace('asset:','')).details.disposal.status==='DELETED_BY_USER_REQUEST'?'삭제 완료':'이동 완료'):'폐기 요청'}</button>`:''}</div><label>코멘트<textarea data-user-comment maxlength="10000" rows="2" placeholder="수정할 점이나 원하는 모습을 쓰면 자동 저장됩니다.">${E(current.comment)}</textarea></label><output data-user-result aria-live="polite">${E(draft?'작성 중 · 자동 저장 대기':last?'저장됨':'입력하면 자동 저장됩니다.')}</output><p data-user-conflict class="review-conflict" hidden></p><button data-user-retry hidden>내 입력으로 다시 저장</button><small data-user-stale ${last&&last.fingerprint!==r.fingerprint?'':'hidden'}>기록 이후 원본 변경 · 이전 의견을 보존했습니다.</small><details data-user-history><summary>변경 이력 · <span data-history-count>${(userReviews.items[r.id]||[]).length}</span>개</summary><div data-history-body></div></details></section>`;
}
function syncReviewPanels(ids=null){for(const id of ids??reviewPanels.keys()){const panels=reviewPanels.get(id)||[],draft=reviewDrafts.get(id),last=lastReview(id),current=draft||last||{status:'pending',comment:''};for(const panel of panels){
 if(!draft){panel.querySelector('[data-user-status]').value=current.status;const input=panel.querySelector('[data-user-comment]');if(input.value!==current.comment){const selection=[input.selectionStart,input.selectionEnd,input.selectionDirection];input.value=current.comment;if(input===document.activeElement)input.setSelectionRange(...selection);}}
 panel.querySelector('[data-history-count]').textContent=String((userReviews.items[id]||[]).length);
 panel.querySelector('[data-user-stale]').hidden=!(last&&last.fingerprint!==recordById(id)?.fingerprint);
 const history=panel.querySelector('[data-user-history]');if(history.open)panel.querySelector('[data-history-body]').innerHTML=reviewHistory(id);
 if(!draft&&!reviewAutosave.states.has(id))panel.querySelector('[data-user-result]').textContent=last?'저장됨':'입력하면 자동 저장됩니다.';
 }}
 refreshReviewQueue(ids);
}
function updateReviewState(id,state,error=''){for(const panel of reviewPanels.get(id)||[]){
 panel.querySelector('[data-user-result]').textContent=reviewMessages[state]+(error?' · '+error:'');
 const conflict=panel.querySelector('[data-user-conflict]');conflict.hidden=state!=='conflict';
 conflict.textContent=state==='conflict'?'다른 창의 최신 기록: '+(lastReview(id)?.comment||userStatuses[lastReview(id)?.status]||'없음'):'';
 panel.querySelector('[data-user-retry]').hidden=!['error','conflict'].includes(state);
 }}
function reviewQueueRows(compact){return inspections.filter(r=>(!compact||lastReview(r.id)||reviewDrafts.has(r.id))&&match(r)&&(noteFilter==='all'||(lastReview(r.id)?.status||'pending')===noteFilter));}
function reviewQueueCard(r){return `<small>${E(r.kind)}</small><h3><a href="#inspect/${encodeURIComponent(r.id)}">${E(r.name)}</a></h3><p class="review-comment" data-review-feedback="${E(r.id)}">${feedbackText(lastReview(r.id))}</p>${lastReview(r.id)&&lastReview(r.id).fingerprint!==r.fingerprint?'<p>원본 변경 · 재검토 필요</p>':''}`;}
function reviewQueueCards(rows){return rows.map(r=>`<article class="card" data-review-row="${E(r.id)}">${reviewQueueCard(r)}</article>`).join('');}
function refreshReviewCounts(){document.querySelectorAll('[data-review-count]').forEach(el=>{el.textContent=reviewQueueRows(el.dataset.reviewCount==='compact').length+'개 · 입력 중 '+reviewDrafts.size+'개';});}
function refreshReviewQueue(ids=null){document.querySelectorAll('[data-review-rows]').forEach(el=>{
 const rows=reviewQueueRows(el.dataset.reviewRows==='compact');
 if(ids===null){el.innerHTML=reviewQueueCards(rows);return;}
 const changed=new Set(ids),included=new Set(rows.map(r=>r.id)),mounted=new Map([...el.children].map(c=>[c.dataset.reviewRow,c]));
 for(const id of changed)if(!included.has(id)){mounted.get(id)?.remove();mounted.delete(id);}
 let next=null;
 for(let i=rows.length-1;i>=0;i--){const r=rows[i];let card=mounted.get(r.id);
  if(changed.has(r.id)){if(!card){card=document.createElement('article');card.className='card';card.dataset.reviewRow=r.id;el.insertBefore(card,next);}
   const body=reviewQueueCard(r);if(card.innerHTML!==body)card.innerHTML=body;}
  if(card)next=card;
 }
 });refreshReviewCounts();}
function reviewQueue(compact=false){const rows=reviewQueueRows(compact);
 const missingIds=Object.keys(userReviews.items).filter(id=>!recordById(id));
 return title('USER REVIEW','내 체크 · 코멘트','기능·화면·이미지의 의견과 폐기 요청을 모아 봅니다. 폐기는 사용처 확인 후 삭제대기로 이동하며 자동 영구 삭제하지 않습니다.')+`<div class="panel"><p data-review-message>${E(reviewMessage)}</p><p>저장 위치: <code>${E(D.review_location)}</code><br>같은 프로젝트의 작업 폴더와 포트가 달라도 이 파일을 함께 사용합니다. GitHub에 자동 업로드하지 않습니다.</p><button data-user-refresh>최신 기록 불러오기</button><a id="review-export" href="${E(reviewEndpoint()?reviewEndpoint()+'/export':'#reviews')}" download="ten-paces-user-review.json">저장된 검토 내보내기</a><label>검토 파일 합쳐 불러오기 <input id="review-import" type="file" accept="application/json,.json"></label><p>불러오기는 기존 이력을 지우지 않고 합칩니다. 다른 PC·AI에는 내보낸 JSON과 프로젝트를 함께 전달하세요.</p></div><label>사용자 상태 <select id="note-filter">${[['all','전체'],...Object.entries(userStatuses)].map(([v,t])=>`<option value="${v}" ${v===noteFilter?'selected':''}>${t}</option>`).join('')}</select></label><p data-review-count="${compact?'compact':'all'}">${rows.length}개 · 입력 중 ${reviewDrafts.size}개</p>${compact?'<p><a href="#reviews">모든 항목의 검토 상태 보기 →</a></p>':''}<div class="grid" data-review-rows="${compact?'compact':'all'}">${reviewQueueCards(rows)}</div>${missingIds.length?`<h2>현재 목록에서 사라진 항목의 기록</h2><p>이전 이력을 삭제하지 않았습니다.</p>${missingIds.map(id=>`<article class="card"><h3>${E(id)}</h3>${(userReviews.items[id]||[]).map(r=>`<p>${E(r.updated_at)} · ${feedbackText(r)}</p>`).join('')}</article>`).join('')}`:''}`;
}
function auditGallery(unfiltered=false){
 const groupNumber=g=>Math.min(...D.assets.filter(a=>a.group.id===g.id).map(a=>a.image_number));
 const groups=[...new Map(D.assets.map(a=>[a.group.id,a.group])).values()].sort((a,b)=>groupNumber(a)-groupNumber(b));
 const list=D.assets.filter(a=>(unfiltered||match(a))&&(auditFilter==='all'||a.audit.flags.includes(auditFilter))&&(auditGroup==='all'||a.group.id===auditGroup));
 const sections=groups.map(g=>({group:g,items:list.filter(a=>a.group.id===g.id)})).filter(g=>g.items.length);
 return title('ASSET AUDIT','사용 이미지 · 종류별 정리',D.asset_audit.policy)+`<p>${E(D.asset_audit.coverage)}</p><div class="audit-filters"><label>종류 · 같은 캐릭터 <select id="audit-group"><option value="all">모든 종류</option>${groups.map(g=>`<option value="${E(g.id)}" ${g.id===auditGroup?'selected':''}>${E(g.label)}</option>`).join('')}</select></label><label>확인할 상태 <select id="audit-filter">${Object.entries(auditNames).map(([v,t])=>`<option value="${v}" ${v===auditFilter?'selected':''}>${t}</option>`).join('')}</select></label></div><p>${list.length}개 / 전체 ${D.assets.length}개 · ${sections.length}묶음</p><p>같은 캐릭터·화면의 이미지를 나란히 비교합니다. 경로에 따른 탐색 분류이며 승인/동일 인물/교체 확정 근거와 구분합니다. 모호한 분류는 이미지 코멘트에 남겨 주세요.</p><p class="notice">${E(D.asset_audit.move_status)}. ‘참조 없음’이나 ‘승인 미확인’ 표시는 삭제 허가가 아닙니다.</p><div class="links">${sections.map(g=>`<button data-audit-jump="${E(g.group.id)}">${E(g.group.label)} · ${g.items.length}</button>`).join('')}</div>${sections.map(({group:g,items})=>`<section class="audit-group" data-audit-section="${E(g.id)}"><h2>${E(g.label)} <small>${items.length}개</small></h2><div class="gallery">${items.map(a=>`<article>${tile(a)}<p><strong>${E(a.group.role)}</strong> · ${E(a.audit.disposition)}</p><p>${a.audit.flags.map(f=>badge(auditNames[f])).join('')}</p><small>${E(a.path)}</small><p><a href="#inspect/${encodeURIComponent('asset:'+a.id)}">의도·상태·코멘트 →</a></p></article>`).join('')}</div></section>`).join('')}`;
}
function auditDetail(a){const x=a.audit;if(!x)return '';
 const related=[...new Set([...x.replacement_ids,...x.duplicate_ids])].map(byId).filter(Boolean);
 return `<section class="panel"><h2>사용 · 교체 · 정리 판단</h2><p>${E(a.group.label)} / ${E(a.group.role)} · ${E(a.group.basis)}</p><p>${x.flags.map(f=>badge(auditNames[f])).join('')}</p><ul>${x.reasons.map(t=>`<li>${E(t)}</li>`).join('')}</ul><p><strong>판정: ${E(x.disposition)}</strong> · 자동 이동/삭제하지 않음</p>${x.replacement_ids.length?'<h3>현재 파일과 대체 이미지 비교</h3>':related.length?'<h3>같은 내용의 다른 파일</h3>':''}${related.length?`<div class="gallery">${[a,...related].map(tile).join('')}</div>`:''}<details><summary>문서·기획·테스트 참조 ${x.document_references.length}곳</summary>${x.document_references.map(p=>link(p,p,a.scope==='PR342_CANDIDATE'?a.revision:null)).join('<br>')}</details><a href="#asset-audit">이미지 정리 전체 목록 →</a></section>`;
}
function reviewEndpoint(){const m=(location.pathname||'').match(/^\/p\/([A-Za-z0-9_-]+)\//);return m?'/p/'+m[1]+'/_review':null;}
function reviewNotice(message){reviewMessage=message;document.querySelectorAll('[data-review-message],[data-user-result]').forEach(el=>el.textContent=message);}
async function reviewRequest(body){const endpoint=reviewEndpoint();if(!endpoint)throw Error('블루프린트 열기.cmd로 열면 검토 기록을 저장할 수 있습니다.');
 const response=await fetch(endpoint,{method:body?'POST':'GET',headers:body?{'Content-Type':'application/json','X-Blueprint-Review':'1'}:{},body:body?JSON.stringify(body):undefined,cache:'no-store'});
 const raw=await response.text();let value;try{value=JSON.parse(raw);}catch{throw Error('검토 서버가 종료되었거나 이전 버전입니다. 실행 파일로 다시 열어 주세요. 입력은 이 창에 유지됩니다.');}
 if(!response.ok){const error=Error(value.error||'검토 저장 실패');error.status=response.status;throw error;}return value;
}
async function loadUserReviews(){if(reviewLoading)return;reviewLoading=true;try{await reviewAutosave.load();reviewLoaded=true;reviewMessage='자동 저장 · 같은 프로젝트의 로컬 검토 파일에 기록합니다.';document.querySelectorAll('[data-review-message]').forEach(el=>el.textContent=reviewMessage);}catch(error){reviewNotice(error.message);}finally{reviewLoading=false;}}
function captureReviewDraft(panel,event={}){const id=panel.dataset.userReview,r=recordById(id);if(!r)return;
 const draft={status:panel.querySelector('[data-user-status]').value,comment:panel.querySelector('[data-user-comment]').value,fingerprint:r.fingerprint,source_revision:D.source_revision};
 reviewAutosave.edit(id,draft,{compose:event.isComposing});
 for(const other of reviewPanels.get(id)||[]){if(other===panel)continue;other.querySelector('[data-user-status]').value=draft.status;other.querySelector('[data-user-comment]').value=draft.comment;}
 return draft;
}
const intentSummary=inspectionSummary;
inspectionSummary=function(r){return intentSummary(r)+intentPanel(r);};
const auditedAsset=asset;
asset=function(id){const a=byId(id);return auditedAsset(id)+(a?auditDetail(a):'');};
const withIntentRequest=requestFor;
requestFor=function(r,time=null,mode='수정'){return withIntentRequest(r,time,mode)+`\n만든 이유: ${r.intent?.purpose||'기록 없음'}\n성공 기준: ${r.intent?.success||'기록 없음'}\n사용자 검토: ${JSON.stringify(lastReview(r.id)||null)}\n사용자 코멘트 원본: ${D.review_location}`;};
const reviewBind=bind;
bind=function(){reviewBind();
 document.getElementById('note-filter')?.addEventListener('change',e=>{noteFilter=e.target.value;render();});
 document.getElementById('audit-group')?.addEventListener('change',e=>{auditGroup=e.target.value;render();});
 document.querySelectorAll('[data-audit-jump]').forEach(b=>b.onclick=()=>{document.querySelectorAll('[data-audit-section]').forEach(s=>{if(s.dataset.auditSection===b.dataset.auditJump)s.scrollIntoView({behavior:'smooth',block:'start'});});});
 document.getElementById('audit-filter')?.addEventListener('change',e=>{auditFilter=e.target.value;render();});
 document.querySelectorAll('[data-user-refresh]').forEach(b=>b.onclick=()=>loadUserReviews());
 reviewPanels.clear();document.querySelectorAll('[data-user-review]').forEach(panel=>{const id=panel.dataset.userReview;if(!reviewPanels.has(id))reviewPanels.set(id,[]);reviewPanels.get(id).push(panel);panel.querySelector('[data-user-history]').ontoggle=e=>{if(e.currentTarget.open)panel.querySelector('[data-history-body]').innerHTML=reviewHistory(id);};});
 syncReviewPanels();for(const [id,state] of reviewAutosave.states)updateReviewState(id,state);
 document.getElementById('review-import')?.addEventListener('change',async e=>{const file=e.target.files[0];if(!file)return;try{if(!reviewLoaded)throw Error('먼저 최신 기록을 불러와 주세요.');if(file.size>2097152)throw Error('검토 파일은 2MB 이하만 불러올 수 있습니다.');const importedDocument=JSON.parse(await file.text());await reviewAutosave.flush();reviewAutosave.accept(await reviewRequest({action:'import',revision:userReviews.revision,document:importedDocument}));reviewMessage='기존 이력을 보존하고 검토 파일을 합쳤습니다.';document.querySelectorAll('[data-review-message]').forEach(el=>el.textContent=reviewMessage);}catch(error){reviewNotice(error.message);}});
};
document.getElementById('nav').innerHTML+='<a href="#asset-audit" data-nav="asset-audit">사용 이미지 · 정리</a><a href="#reviews" data-nav="reviews">내 체크 · 코멘트</a>';
// Delegation keeps typing work proportional to occurrences of this item, not all forms.
main.addEventListener('input',e=>{if(e.target.matches('[data-user-comment]'))captureReviewDraft(e.target.closest('[data-user-review]'),e);});
main.addEventListener('compositionend',e=>{if(e.target.matches('[data-user-comment]'))captureReviewDraft(e.target.closest('[data-user-review]'));});
main.addEventListener('change',e=>{if(e.target.matches('[data-user-status]')){const panel=e.target.closest('[data-user-review]');captureReviewDraft(panel);void reviewAutosave.flush(panel.dataset.userReview);}});
main.addEventListener('focusout',e=>{if(e.target.matches('[data-user-comment]')&&!e.isComposing)void reviewAutosave.flush(e.target.closest('[data-user-review]').dataset.userReview);});
main.addEventListener('click',async e=>{const panel=e.target.closest('[data-user-review]');if(!panel)return;const id=panel.dataset.userReview;
 if(e.target.matches('[data-user-discard]')){panel.querySelector('[data-user-status]').value='discard';captureReviewDraft(panel);await reviewAutosave.flush(id);}
 if(e.target.matches('[data-user-retry]')){await loadUserReviews();reviewAutosave.retry(id);await reviewAutosave.flush(id);}
});
window.addEventListener('online',()=>void loadUserReviews());
if(typeof fetch==='function'&&reviewEndpoint())loadUserReviews();

const userResumeText=resumeText;
resumeText=function(id=''){return userResumeText(id)+`\n사용자 의도·검토 코멘트: ${D.review_location}를 읽고 항목 ID와 기준 fingerprint를 대조해줘. 사용자 체크는 최종 자산 승인이나 실행 검증을 대신하지 않아. 원본을 바꾸기 전 현재 요청 범위와 코멘트 의도를 확인해줘.`;};
window.addEventListener('beforeunload',e=>{if(reviewDrafts.size){e.preventDefault();e.returnValue='';}});
