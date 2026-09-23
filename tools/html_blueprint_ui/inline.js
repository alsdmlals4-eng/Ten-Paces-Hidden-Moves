/* Stable source-bound captions and review inputs beside the item being reviewed. */
const imageRows=D.image_catalog||[];
function imageCaption(row){return `<div class="image-caption" data-image-number="${row.number}"><strong>${E(row.kind)} · 이미지 ${row.number} · ${E(row.usage)}</strong><small>${E(row.usage_evidence)}</small></div>`;}
const imageByRecord=new Map(imageRows.map(r=>[r.record_id,r])),imageByPath=new Map(imageRows.filter(r=>!r.key.startsWith('candidate:')).map(r=>[r.path,r])),imageByUrl=new Map(imageRows.map(r=>[r.url,r]));
function imageRowForAsset(a){return imageByRecord.get('asset:'+a.id);}
const plainTile=tile;
tile=function(a){const row=imageRowForAsset(a);return `<article class="inline-image" data-numbered-image="${E(a.id)}">${plainTile(a).replace('<div class="caption">',`<div class="caption">${row?imageCaption(row):''}`)}${userReviewPanel(recordById('asset:'+a.id))}</article>`;};
const numberedRequest=requestFor;
requestFor=function(r,time=null,mode='수정'){const row=imageRows.find(x=>x.record_id===r.id);return numberedRequest(r,time,mode)+(row?`\n이미지 번호: ${row.number}\n쓰임새: ${row.usage}\n이미지 원본: ${row.path}`:'');};
const historicalBlock=block;
function numberedBlock(b){const row=b.kind==='image'?imageByPath.get(b.path):null;return row?`<div data-numbered-image="${E(row.key)}">${historicalBlock(b)}${imageCaption(row)}${userReviewPanel(recordById(row.record_id))}</div>`:historicalBlock(b);}
function currentVisual(row){return `<section class="current-visual"><h3>${E(row.title)}</h3><p>${E(row.description)}</p>${row.current_images.map(path=>numberedBlock({kind:'image',path})).join('')}<div class="clash-explanation">${row.steps.map(([title,text])=>`<div><strong>${E(title)}</strong><p>${E(text)}</p></div>`).join('')}</div><p class="notice">${E(row.evidence)}</p><a href="${E(row.next)}">${E(row.next_label)} →</a></section>`;}
block=function(b){const candidate=b.kind==='image'?D.visual_revisions?.[b.path]:null;const revision=candidate?.page_ids?.includes(b.page_id)&&!b.region?candidate:null;return revision?currentVisual(revision)+`<details class="historical-image"><summary>이전 참고 이미지 · 교체 전 비교</summary>${numberedBlock(b)}</details>`:numberedBlock(b);};
const numberedAsset=asset;
asset=function(id){const a=byId(id),revision=a?D.visual_revisions?.[a.path]:null;return a?.details?.retired?title('DISPOSAL',a.name)+`<p class="notice">폐기 요청에 따라 삭제대기 폴더로 옮겼습니다. 원본 번호와 검토 이력은 유지합니다.</p>${imageCaption(imageRowForAsset(a))}${table(['기록','내용'],[['요청 이유',a.details.disposal.reason],['원래 경로',a.path],['삭제대기 파일',a.details.disposal.moved_to],['원본 SHA-256',a.sha256],['복구 기준',a.details.disposal.restore_revision]])}${userReviewPanel(recordById('asset:'+id))}`:(revision?currentVisual(revision):'')+numberedAsset(id);};

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
