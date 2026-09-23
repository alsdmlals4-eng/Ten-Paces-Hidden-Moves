/* Stable source-bound captions and review inputs beside the item being reviewed. */
const imageRows=D.image_catalog||[];
function imageCaption(row){return `<div class="image-caption" data-image-number="${row.number}"><strong>${E(row.kind)} · 이미지 ${row.number} (${E(row.usage)})</strong><small>${E(row.usage_evidence)}</small></div>`;}
const imageByRecord=new Map(imageRows.map(r=>[r.record_id,r])),imageByPath=new Map(imageRows.filter(r=>!r.key.startsWith('candidate:')).map(r=>[r.path,r])),imageByUrl=new Map(imageRows.map(r=>[r.url,r]));
function imageRowForAsset(a){return imageByRecord.get('asset:'+a.id);}
const plainTile=tile;
tile=function(a){const row=imageRowForAsset(a);return `<article class="inline-image" data-numbered-image="${E(a.id)}">${(a.details?.reference_edit?plainTile(a).replace(/<img[^>]*>/,`<svg viewBox="0 0 ${a.size[0]} ${Math.round(a.size[1]*a.details.provenance.display_fraction)}" role="img" aria-label="상태창 여백 수정안"><image href="${E(a.url)}" width="${a.size[0]}" height="${a.size[1]}"/></svg>`):plainTile(a)).replace('<div class="caption">',`<div class="caption">${row?imageCaption(row):''}`)}${userReviewPanel(recordById('asset:'+a.id))}</article>`;};
const numberedRequest=requestFor;
requestFor=function(r,time=null,mode='수정'){const row=imageRows.find(x=>x.record_id===r.id);return numberedRequest(r,time,mode)+(row?`\n이미지 번호: ${row.number}\n쓰임새: ${row.usage}\n이미지 원본: ${row.path}`:'');};
const historicalBlock=block;
function numberedBlock(b){const replacement=(D.image_replacements||[]).find(r=>r.path===b.path);if(replacement&&b.kind==='image'){const a=D.assets.find(x=>x.path===b.path&&x.scope==='MAIN_SOURCE');if(a?.size)b={...b,size:a.size,region:[0,0,a.size[0],Math.round(a.size[1]*replacement.display_fraction)]};}const sourceRow=b.kind==='image'?imageByPath.get(b.path):null;const row=sourceRow&&b.screen_kind?{...sourceRow,kind:b.screen_kind,usage:b.screen_usage}:sourceRow;const rendered=replacement?historicalBlock(b).replace(/<button[^>]*>/,'<div class="reference-surface">').replace('</button>','</div>'):historicalBlock(b);return row?`<div data-numbered-image="${E(row.key)}">${rendered}${imageCaption(row)}${b.defer_review?'':userReviewPanel(recordById(row.record_id))}</div>`:historicalBlock(b);}
function currentVisual(row){return `<section class="current-visual"><h3>${E(row.title)}</h3><p>${E(row.description)}</p>${row.current_images.map(path=>numberedBlock({kind:'image',path})).join('')}<div class="clash-explanation">${row.steps.map(([title,text])=>`<div><strong>${E(title)}</strong><p>${E(text)}</p></div>`).join('')}</div><p class="notice">${E(row.evidence)}</p><a href="${E(row.next)}">${E(row.next_label)} →</a></section>`;}
block=function(b){if(b.kind==='basic_actions')return basicActionCards(b.start??0,b.count??10);const candidate=b.kind==='image'?D.visual_revisions?.[b.path]:null;const revision=candidate?.page_ids?.includes(b.page_id)&&!b.region?candidate:null;return revision?currentVisual(revision)+`<details class="historical-image"><summary>이전 참고 이미지 · 교체 전 비교</summary>${numberedBlock(b)}</details>`:numberedBlock(b);};
const numberedAsset=asset;
function editedReference(a){const row=imageRowForAsset(a);return title('REFERENCE EDIT',a.name)+`<p class="notice">${E(a.approval_record)}</p>${numberedBlock({kind:'image',path:a.path})}<p>수정 전142 파일은 사용자 지시에 따라 삭제했습니다. 그림 아래의 실제 카드 설명은 게임 데이터에서 읽습니다.</p><a href="#maps/game-loop/plan">수 배치와 기초 행동 보기 →</a>`;}

asset=function(id){const a=byId(id),revision=a?D.visual_revisions?.[a.path]:null;if(a?.details?.reference_edit)return editedReference(a);return a?.details?.retired?title('DISPOSAL',a.name)+`<p class="notice">${a.details.disposal.status==='DELETED_BY_USER_REQUEST'?'사용자 요청으로 파일을 삭제했습니다. 옛 그림은 표시하지 않습니다.':'폐기 요청에 따라 삭제대기 폴더로 옮겼습니다.'} 번호와 검토 기록으로 처리 결과를 확인합니다.</p>${imageCaption(imageRowForAsset(a))}${table(['기록','내용'],[['요청 이유',a.details.disposal.reason],['원래 경로',a.path],['처리 결과',a.details.disposal.moved_to||'파일 삭제 완료'],['원본 SHA-256',a.sha256],['복구 기준',a.details.disposal.restore_revision]])}${userReviewPanel(recordById('asset:'+id))}`:(revision?currentVisual(revision):'')+numberedAsset(id);};

// Number any source image embedded in a reader, screen or character view too.
function attachImageReviews(){
 document.querySelectorAll('#main img').forEach(img=>{
  const address=img.getAttribute('src');
  const row=imageByUrl.get(address);
  if(!row)return;
  if(row.size){img.setAttribute('width',row.size[0]);img.setAttribute('height',row.size[1]);}
  if(img.closest('[data-numbered-image]')||img.dataset.numberAttached)return;
  img.dataset.numberAttached='true';
  const anchor=img.closest('button.media-button, a.tile')||img;
  anchor.insertAdjacentHTML('afterend',imageCaption(row)+userReviewPanel(recordById(row.record_id)));
 });
}
const inlineBind=bind;
bind=function(){attachImageReviews();inlineBind();};
const inlineControls=recordControls;
recordControls=function(r,video=null){return inlineControls(r,video)+userReviewPanel(r);};

// A full-width atlas followed by the selected content avoids a second narrow rail.
const inlineMaps=maps;
maps=function(id,focus){return inlineMaps(id,focus).replace('class="atlas-workbench"','class="atlas-workbench atlas-stacked"');};
const inlineHome=home;
home=function(){return inlineHome()+`<section id="overview-reviews">${reviewQueue(true)}</section>`;};
document.getElementById('nav').innerHTML=[['','전체 보기'],...D.reader_groups.map(g=>[g.id,g.label]),['work','작업·일정'],['proof','실행·검수'],['reviews','내 코멘트'],['continue','이어가기']].map(([id,label])=>`<a href="#home${id?'/'+id:''}" data-nav="${id||'home'}">${E(label)}</a>`).join('');

document.getElementById('nav').innerHTML+=reviewNav.map(([id,label])=>`<a href="#${id}" data-nav="${id}">${E(label)}</a>`).join('');
