
/* Inspection controls read repository evidence. They do not approve or simulate gameplay. */
const inspections=D.inspection.records;
const inspectionById=new Map(inspections.map(r=>[r.id,r]));
const recordById=id=>inspectionById.get(id);
const statusNames={planning:'기획',asset:'자산 승인',implementation:'구현 연결',runtime:'실행 근거',human:'사용자 검수'};
const reviewNav=[['inspect','항목별 검수'],['changes','변경 · 갱신 확인']];
document.getElementById('nav').innerHTML+=reviewNav.map(([id,name])=>`<a href="#${id}" data-nav="${id}">${name}</a>`).join('');
const storageKey='tenpaces-inspection-v1:'+D.workspace;
function readVisit(){try{return JSON.parse(localStorage.getItem(storageKey)||'{}');}catch{return {};}}
let visit=readVisit(),reviewFilter='all',lastRoute='',restoreRoute=null,scrollJob=null;
const previousFingerprints={...(visit.fingerprints||{})};
function saveVisit(){try{localStorage.setItem(storageKey,JSON.stringify(visit));}catch{/* Private browsing still supports all inspection paths. */}}
function rememberPosition(){if(!lastRoute)return;visit.routes??={};visit.routes[lastRoute]={y:window.scrollY||0,search:search.value,assetFilter,assetCategory,reviewFilter};visit.lastRoute=lastRoute;saveVisit();}
function recordControls(r,video=''){
 if(!r)return '';
 return `<div class="inspection-controls"><a href="#inspect/${encodeURIComponent(r.id)}">항목별 검수 · ${E(r.name)}</a><button data-inspect-copy="${E(r.id)}" data-inspect-video="${E(video)}">이 항목 수정 요청 복사</button><button data-inspect-copy="${E(r.id)}" data-inspect-video="${E(video)}" data-resume-item="true">이 항목 이어서 작업</button></div>`;
}
function statusStrip(r){return `<dl class="status-strip">${Object.entries(r.states).map(([k,v])=>`<div><dt>${statusNames[k]}</dt><dd>${E(v)}</dd></div>`).join('')}</dl>`;}
function stateExamples(r){return `<details><summary>상태별 검수 · 기본 / 선택 / 사용 불가 / 실패 / 복귀</summary><p>관련 설명과 원본을 열어 각 상태의 정보·입력·피드백을 대조합니다. 전용 촬영·사용자 검수 기록이 없는 상태는 완료로 표시하지 않습니다.</p>${table(['상태','확인할 내용','현재 근거'],[['기본','첫 진입의 정보와 선택 가능 항목','연결된 원본·기획 자료'],['선택','선택한 대상과 다음 행동을 이해할 수 있는가','상태별 촬영 미등록'],['사용 불가','이유와 가능한 대안이 보이는가','상태별 촬영 미등록'],['실패','실패 결과·오류와 복구 방법이 구별되는가','상태별 촬영 미등록'],['복귀','이전 선택·위치와 다음 행동이 이어지는가','상태별 촬영 미등록']])}</details>`;}
function relatedTasks(r){return r.tasks.length?`<h3>연결된 PM 작업</h3>${r.tasks.map(t=>`<div class="card"><strong>${E(t.title)}</strong><p>${E(t.status)} · ${t.scope==='PR342_CANDIDATE'?'미병합 후보':'원본 작업 기록'}</p><p>${E(t.next_action||'작업 원본의 인수 조건 확인')}</p>${link(t.source,'작업·완료 조건 원본',t.revision)}</div>`).join('')}`:'<p>이 항목의 직접 연결 PM 기록은 없습니다. <a href="#pm">전체 작업 기록</a>에서 관련 범위를 확인하세요.</p>';}
function inspectionSummary(r){return statusStrip(r)+recordControls(r)+(r.kind==='화면'?stateExamples(r):'')+`<details><summary>원본 · 근거 · 남은 확인</summary><div class="links">${r.sources.map(p=>link(p)).join('')}${(r.candidate_sources||[]).map(s=>link(s.path,'후보 원본 · '+s.path,s.revision)).join('')}</div><p>다음 확인: ${r.flags.map(f=>D.inspection.filters[f]).join(' / ')||'현재 원본과 표시 대조'}. 자동 검사로 사람 검수를 완료 처리하지 않습니다.</p>${relatedTasks(r)}</details>`;}
function inspect(id){
 const r=recordById(id);
 if(id&&!r)return missing();
 if(r){let content='';
  if(r.kind==='무공'){const m=D.manuals.find(m=>Object.values(m.cards).some(c=>'card:'+c.id===id));const c=Object.values(m.cards).find(c=>'card:'+c.id===id);content=cardSummary(c);}
  return title('ITEM INSPECTION',r.name,r.kind)+inspectionSummary(r)+content+`<div class="gallery">${r.asset_ids.map(byId).filter(Boolean).map(tile).join('')}</div>`+ (r.clip_ids.length?movies('inspect',r.clip_ids):'')+`<p><a href="${E(r.route===('#inspect/'+id)?'#maps/game-loop/starter':r.route)}">연결 화면 열기 →</a></p>`;
 }
 const rows=inspections.filter(r=>(reviewFilter==='all'||r.flags.includes(reviewFilter))&&match(r));
 return title('INSPECTION QUEUE','항목별 검수','완료를 하나로 합치지 않고 기획·승인·연결·실행·사용자 확인을 나눕니다.')+`<label>확인할 항목 <select id="review-filter">${Object.entries(D.inspection.filters).map(([v,t])=>`<option value="${v}" ${v===reviewFilter?'selected':''}>${t}</option>`).join('')}</select></label><p>${rows.length}개 · ‘미기록’은 미구현이나 불합격과 다릅니다.</p><div class="grid">${rows.map(r=>`<article class="card"><small>${E(r.kind)}</small><h3><a href="#inspect/${encodeURIComponent(r.id)}">${E(r.name)}</a></h3>${statusStrip(r)}</article>`).join('')}</div>`;
}
function requestFor(r,time=null,mode='수정'){
 const clip=r?.clip_ids?.length===1?D.experience.clips.find(c=>c.id===r.clip_ids[0]):null;
 const phase=clip?.timeline?.find(p=>time>=p.start&&time<p.end);
 return resumeText(r.id)+`\n\n항목별 ${mode} 요청\n항목: ${r.kind} / ${r.name} / ${r.id}\nHTML 내부 경로: #inspect/${encodeURIComponent(r.id)}\n상태: ${Object.entries(r.states).map(([k,v])=>statusNames[k]+'='+v).join(' / ')}\n원본: ${r.sources.join('\n')}\n후보 원본: ${(r.candidate_sources||[]).map(s=>s.path+' @ '+s.revision).join('\n')}\n관련 PM: ${r.tasks.map(t=>t.id+' ['+t.scope+'] '+t.status).join(', ')||'직접 연결 미기록'}\n${clip?'영상: '+clip.path+'\n촬영 기준: '+clip.source_revision+'\n원본 일치: '+clip.freshness.status+'\n':''}${time!==null?'재생 시점: '+time.toFixed(3)+'초 / 단계: '+(phase?.phase||'시점 근거 없음')+'\n':''}남은 확인: ${r.flags.map(f=>D.inspection.filters[f]).join(', ')}\n수정할 내용: [관찰한 문제와 원하는 결과를 작성]\n완료 조건: 원본 수정 후 해당 항목의 표시·연결·실행 근거를 재확인하고 기존 PM/일지에 누적. 게임 규칙과 승인 자산은 임의 변경하지 않는다.\n공유 주소의 임시 포트·토큰에 의존하지 말고 로컬에서 미리보기를 다시 열어 이 내부 경로로 이동해줘.`;
}
const enginePhases={idle:'재생 준비',windup:'준비 자세',impact:'타격·결과 표시',settled:'정리 완료',unknown:'시점 근거 없음'};
function phaseName(clip,p){const e=clip.events[p.event_index];const actor=e?.actor==='player'?'플레이어':e?.actor==='enemy'?'상대':'';const event=e?.type==='clash'?(e.outcome==='clash_loss'?'합 패배':'합 승리'):e?.card_name||'';return [actor,event,enginePhases[p.phase]||p.phase].filter(Boolean).join(' · ');}
function reviewSeekTime(time,phase,enabled){return enabled&&phase&&time>=phase.end?phase.start:null;}
function bindPhasePlayback(video){
 const loop=document.querySelector(`[data-loop-video="${video.id}"]`);
 let frame=null;
 const tick=()=>{frame=null;if(!video.isConnected||video.paused)return;const target=reviewSeekTime(video.currentTime,video.reviewPhase,loop?.checked);if(target!==null&&!video.seeking)video.currentTime=target;frame=requestAnimationFrame(tick);};
 video.addEventListener('play',()=>{if(frame===null)frame=requestAnimationFrame(tick);});
 video.addEventListener('pause',()=>{if(frame!==null)cancelAnimationFrame(frame);frame=null;});
 video.addEventListener('ended',()=>{if(loop?.checked&&video.reviewPhase){video.currentTime=video.reviewPhase.start;video.play().catch(()=>{});}});
}
function candidatePresentation(clip){const presets=D.candidate?.presets;if(!presets)return '';const rows=clip.card_ids.map(id=>({id,setting:presets.cards[id]})).filter(x=>x.setting);if(!rows.length)return '';
 return `<details><summary>main 촬영 ↔ PR #342 후보 설정 비교</summary><p>왼쪽 근거는 위의 main 계열 촬영입니다. 아래는 아직 병합되지 않은 후보의 설정이며 후보 실행 영상이 아닙니다.</p>${rows.map(x=>{const f=presets.families[x.setting.family];return `<div class="card"><strong>${E(x.id)} · ${E(x.setting.family)}</strong><p>설정 시간 ${E(f?.duration)}초 · 이동 비율 ${E(f?.travel)} · 타격 멈춤 ${E(f?.hit_stop)}초 · 포즈 ${E(f?.pose)}</p></div>`;}).join('')}${link('data/presentation/combat_motion_presets.json','후보 설정 원본',D.candidate.revision)}<p>준비·접근·타격·복귀의 실제 후보 검수는 해당 브랜치에서 별도로 수행합니다.</p></details>`;
}
const baseMovie=movie;
movie=function(clip,prefix='clip'){
 const id=prefix+'-'+clip.id;
 const phases=clip.timeline||[];
 return baseMovie(clip,prefix).replace('</article>',`<div class="phase-track"><h4>실제 기록의 연출 단계</h4><div class="phase-buttons">${phases.map((p,i)=>`<button data-phase-video="${E(id)}" data-phase-index="${i}" data-clip-id="${E(clip.id)}">${p.start.toFixed(2)}초 · ${E(phaseName(clip,p))}</button>`).join('')||'<p>이 영상에는 단계 시점 기록이 없습니다.</p>'}</div><p><output data-phase-status="${E(id)}">단계를 선택하면 해당 시점으로 이동합니다.</output></p><label><input type="checkbox" data-loop-video="${E(id)}"> 선택 구간 반복</label><p><small>엔진의 준비·타격·정리 상태를 촬영 프레임에서 읽었습니다. 접근·복귀를 별도 단계로 나눈 시점 근거는 없습니다. 프레임 변화 수는 고유 동작 완성 판정이 아닙니다.</small></p></div><div class="notice">${clip.freshness.status==='STALE'?'촬영 갱신 필요 · 과거 영상으로 보존':'발행 시점에 촬영 입력과 일치'} · 소리 검수 제외${clip.freshness.changed_paths.length?'<details><summary>변경된 촬영 입력</summary><pre>'+E(clip.freshness.changed_paths.join('\n'))+'</pre></details>':''}</div>${candidatePresentation(clip)}${recordControls(recordById('clip:'+clip.id),id)}</article>`);
};
const baseStage=stagePanel;
stagePanel=function(id){const c=D.experience.contexts[id],r=recordById('screen:'+id);if(!c)return '';
 const previous=Object.entries(D.experience.contexts).filter(([,v])=>v.next.includes(id));
 const next=c.next.map(n=>`<a class="screen-hotspot" href="#maps/game-loop/${n}">${E(D.experience.contexts[n].title)} →</a>`).join('');
 const picture=block(c.preview).replace(/<figcaption>[\s\S]*?<\/figcaption>/,'');
 const preview=`<div class="screen-preview"><div class="screen-surface">${picture}${id==='menu'?'<a class="menu-start-hotspot" href="#maps/game-loop/starter" aria-label="화면 속 새 여정 · 시작 무공으로" title="새 여정 → 시작 무공">새 여정</a>':''}</div><nav class="screen-actions" aria-label="이 화면에서 이어지는 선택">${next}</nav></div><p><small>자료: ${E(c.preview_kind)}. 선택은 HTML 탐색이며 실제 게임 입력이 아닙니다.</small></p>`;
 return baseStage(id).replace('<div class="eyebrow">',`<nav class="breadcrumb" aria-label="화면 경로"><a href="#maps/game-loop">전체 구조</a><span> / ${E(c.title)}</span>${previous.map(([key,v])=>`<a href="#maps/game-loop/${key}">← ${E(v.title)}</a>`).join('')}</nav>${preview}${inspectionSummary(r)}<div class="eyebrow">`);
};
const inspectMaps=maps;
maps=function(id,focus){const html=inspectMaps(id,focus);if(id&&id!=='game-loop')return html;
 const detail=html.indexOf('<section id="stage-detail"');
 if(detail<0)return html;
 const graph=html.indexOf('<div class="diagram-viewport">');
 return html.slice(0,graph)+`<div class="atlas-workbench"><div class="atlas-map-column">`+html.slice(graph,detail)+`</div><div class="atlas-detail-column">`+html.slice(detail)+`</div></div>`;
};
const inspectedAsset=asset,inspectedPeople=people;
asset=function(id){return inspectionSummary(recordById('asset:'+id)||{states:{},sources:[],flags:[],tasks:[]})+inspectedAsset(id);};
people=function(id,unfiltered=false){const r=recordById('person:'+id);return (r?inspectionSummary(r):'')+inspectedPeople(id,unfiltered);};
const baseCardSummary=cardSummary;
cardSummary=function(card){return baseCardSummary(card)+recordControls(recordById('card:'+card.id));};
function searchResults(){const q=search.value.trim();if(!q)return title('SEARCH','내용 찾기','화면·인물·무공·자산·작업을 함께 찾습니다.');
 const numbered=q.match(/^(?:이미지\s*)?#?([1-9][0-9]*)$/);
 const rows=[...inspections.map(r=>({kind:r.image_number?r.image_kind+' · 이미지 '+r.image_number:r.kind,name:r.image_usage||r.name,href:'#inspect/'+encodeURIComponent(r.id),text:r})),...D.pages.map(p=>({kind:'설명',name:p.title,href:'#reader/'+p.id,text:p})),...D.pm.items.map(t=>({kind:'작업',name:t.title||t.work_item_id,href:'#pm/'+t.work_item_id,text:t}))].filter(r=>numbered?r.text.image_number===Number(numbered[1]):match(r.text));
 return title('SEARCH','통합 검색',q+' · '+rows.length+'개')+`<div class="grid">${rows.map(r=>`<a class="card" href="${E(r.href)}"><small>${E(r.kind)}</small><h3>${E(r.name)}</h3></a>`).join('')}</div>`+(rows.length?'':missing('검색 결과가 없습니다.'));
}
function changedRecords(previous=previousFingerprints){
 if(!Object.keys(previous).length)return [];
 return [...inspections.filter(r=>previous[r.id]!==r.fingerprint).map(r=>({...r,change:previous[r.id]?'modified':'added'})),
 ...Object.keys(previous).filter(id=>!recordById(id)).map(id=>({id,name:id,kind:'이전 항목',change:'removed'}))];
}
function changes(){const changed=changedRecords(),stale=D.experience.clips.filter(c=>c.freshness.status==='STALE');
 return title('CHANGES & FRESHNESS','변경 · 갱신 확인',D.inspection.freshness_policy)+`<p>HTML 발행 ${E(D.generated_at)} · 기준 ${E(D.source_revision.slice(0,10))}</p><p>비교 기준: ${Object.keys(previousFingerprints).length?'같은 브라우저·주소에서 마지막으로 확인 기준을 저장한 항목':'저장된 이전 확인 기준 없음'}. 저장은 검수 승인과 다릅니다.</p><button id="save-baseline">현재 항목을 다음 비교 기준으로 저장</button><h2>이전 기준 이후 변경 · ${changed.length}개</h2>${changed.map(r=>r.change==='removed'?`<p>삭제·이름 변경 · ${E(r.name)} · 이전 원본과 비교 필요</p>`:`<p><a href="#inspect/${encodeURIComponent(r.id)}">${r.change==='added'?'추가':'수정'} · ${E(r.kind)} · ${E(r.name)}</a></p>`).join('')||'<p>비교할 변경 항목이 없습니다.</p>'}<h2>촬영 갱신 필요 · ${stale.length}개</h2>${stale.map(c=>`<p><a href="#motion/${c.id}">${E(c.title)}</a></p>`).join('')||'<p>발행 시점에 기록된 촬영 입력과 일치합니다.</p>'}<div class="notice">브라우저 저장은 이 주소와 브라우저에 한정됩니다. 포트가 바뀌거나 다른 AI를 사용하면 기존 비교 기준이 없을 수 있습니다. 원본 재개 인덱스와 항목별 요청은 별도로 제공됩니다.</div><p><a href="resume-index.json">다른 AI용 항목·영상·PM 인덱스</a></p>`;
}
const underlyingRender=render;
render=function(){const route=location.hash||'#maps',previousRoute=lastRoute;if(lastRoute&&route!==lastRoute){rememberPosition();const state=visit.routes?.[route];search.value=state?.search||'';assetFilter=state?.assetFilter||'all';assetCategory=state?.assetCategory||'all';reviewFilter=state?.reviewFilter||'all';restoreRoute=state?route:null;}lastRoute=route;
 const [section,id]=decodeURIComponent(route.slice(1)).split('/');
 if(section==='home'&&previousRoute!==route&&previousRoute.split('/')[0]==='#home'&&document.querySelector('.overview-group')){
  document.querySelectorAll('[data-nav]').forEach(a=>{const active=a.dataset.nav===(id||'home');a.classList.toggle('active',active);if(active)a.setAttribute('aria-current','page');else a.removeAttribute('aria-current');});return;
 }
 if(['inspect','search','changes','giyun','reviews','asset-audit'].includes(section)){clearInterval(motionTimer);main.innerHTML=section==='inspect'?inspect(id):section==='search'?searchResults():section==='giyun'?giyunCatalog(id):section==='reviews'?reviewQueue():section==='asset-audit'?auditGallery():changes();bind();document.querySelectorAll('[data-nav]').forEach(a=>{const active=a.dataset.nav===section;a.classList.toggle('active',active);if(active)a.setAttribute('aria-current','page');else a.removeAttribute('aria-current');});}else underlyingRender();
};
followLocation=function(){const [section,id,focus]=decodeURIComponent((location.hash||'#maps').slice(1)).split('/');const saved=visit.routes?.[lastRoute];if(restoreRoute===lastRoute&&saved&&!(section==='home'&&id)){window.scrollTo(0,saved.y);restoreRoute=null;return;}
 const target=section==='maps'&&focus?'stage-detail':section==='home'&&id?'overview-'+id:null;const node=target?document.getElementById(target):null;
 if(node){node.scrollIntoView({behavior:'instant',block:'start'});if(section==='maps')node.focus({preventScroll:true});}else window.scrollTo(0,0);
};
const inspectionBind=bind;
bind=function(){inspectionBind();
 document.getElementById('review-filter')?.addEventListener('change',e=>{reviewFilter=e.target.value;render();});
 document.getElementById('save-baseline')?.addEventListener('click',()=>{visit.fingerprints=Object.fromEntries(inspections.map(r=>[r.id,r.fingerprint]));Object.keys(previousFingerprints).forEach(k=>delete previousFingerprints[k]);Object.assign(previousFingerprints,visit.fingerprints);saveVisit();render();});
 document.querySelectorAll('[data-inspect-copy]').forEach(b=>b.onclick=()=>{const video=b.dataset.inspectVideo?document.getElementById(b.dataset.inspectVideo):null;copy(requestFor(recordById(b.dataset.inspectCopy),video?.currentTime??null,b.dataset.resumeItem?'재개':'수정'));});
 document.querySelectorAll('video').forEach(video=>{bindPhasePlayback(video);video.addEventListener('timeupdate',()=>{const clip=D.experience.clips.find(c=>c.id===video.closest('[data-clip]')?.dataset.clip);const phase=clip?.timeline?.find(p=>video.currentTime>=p.start&&video.currentTime<p.end);const status=document.querySelector(`[data-phase-status="${video.id}"]`);if(status)status.textContent=phase?phaseName(clip,phase):'단계 시점 근거 없음';const loop=document.querySelector(`[data-loop-video="${video.id}"]`);if(loop?.checked&&video.reviewPhase&&video.currentTime>=video.reviewPhase.end)video.currentTime=video.reviewPhase.start;});});
 document.querySelectorAll('[data-phase-video]').forEach(b=>b.onclick=()=>{const v=document.getElementById(b.dataset.phaseVideo),c=D.experience.clips.find(c=>c.id===b.dataset.clipId),p=c.timeline[Number(b.dataset.phaseIndex)];v.reviewPhase=p;const seek=()=>{v.currentTime=p.start;v.play().catch(()=>{document.getElementById('notice').textContent='재생 버튼으로 영상을 시작하세요.';});};if(v.readyState)seek();else{v.addEventListener('loadedmetadata',seek,{once:true});v.load();}});
 const overview=document.querySelector('.overview-jumps');if(overview&&!document.getElementById('reading-position'))overview.insertAdjacentHTML('beforeend','<output id="reading-position" aria-live="off">읽는 구역: 전체 보기</output>');
};
search.oninput=()=>{if(location.hash!=='#search'){rememberPosition();location.hash='#search';visit.routes??={};visit.routes['#search']={search:search.value,y:0};}else render();};
document.addEventListener('click',e=>{const a=e.target.closest?.('a[href^="#"]');if(a&&a.getAttribute('href')===location.hash){e.preventDefault();restoreRoute=null;followLocation();}});
window.addEventListener('scroll',()=>{clearTimeout(scrollJob);scrollJob=setTimeout(()=>{rememberPosition();const output=document.getElementById('reading-position');if(output){let current=null;document.querySelectorAll('[id^="overview-"]').forEach(s=>{if(s.getBoundingClientRect().top<220)current=s;});const a=current?document.querySelector(`.overview-jumps a[href="#home/${current.id.slice(9)}"]`):null;output.textContent='읽는 구역: '+(a?.textContent||'전체 보기');}},150);},{passive:true});
window.addEventListener('pagehide',rememberPosition);
const savedInitial=visit.routes?.[location.hash||'#maps'];if(savedInitial){search.value=savedInitial.search||'';assetFilter=savedInitial.assetFilter||'all';assetCategory=savedInitial.assetCategory||'all';reviewFilter=savedInitial.reviewFilter||'all';restoreRoute=location.hash||'#maps';}
