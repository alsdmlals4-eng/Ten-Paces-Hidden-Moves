/* Stable source-bound captions and review inputs beside the item being reviewed. */
const imageRows=D.image_catalog||[];
function imageCaption(row){return `<div class="image-caption" data-image-number="${row.number}"><strong>${E(row.kind)} · 이미지 ${row.number} · ${E(row.usage)}</strong><small>${E(row.usage_evidence)}</small></div>`;}
function imageRowForAsset(a){return imageRows.find(row=>row.record_id==='asset:'+a.id);}
const plainTile=tile;
tile=function(a){const row=imageRowForAsset(a);return `<article class="inline-image" data-numbered-image="${E(a.id)}">${plainTile(a).replace('<div class="caption">',`<div class="caption">${row?imageCaption(row):''}`)}${userReviewPanel(recordById('asset:'+a.id))}</article>`;};
const numberedRequest=requestFor;
requestFor=function(r,time=null,mode='수정'){const row=imageRows.find(x=>x.record_id===r.id);return numberedRequest(r,time,mode)+(row?`\n이미지 번호: ${row.number}\n쓰임새: ${row.usage}\n이미지 원본: ${row.path}`:'');};
const historicalBlock=block;
function numberedBlock(b){const row=b.kind==='image'?imageRows.find(r=>r.path===b.path&&!r.key.startsWith('candidate:')):null;return row?`<div data-numbered-image="${E(row.key)}">${historicalBlock(b)}${imageCaption(row)}${userReviewPanel(recordById(row.record_id))}</div>`:historicalBlock(b);}
function currentVisual(row){return `<section class="current-visual"><h3>${E(row.title)}</h3><p>${E(row.description)}</p>${row.current_images.map(path=>numberedBlock({kind:'image',path})).join('')}<div class="clash-explanation">${row.steps.map(([title,text])=>`<div><strong>${E(title)}</strong><p>${E(text)}</p></div>`).join('')}</div><p class="notice">${E(row.evidence)}</p><a href="${E(row.next)}">${E(row.next_label)} →</a></section>`;}
block=function(b){const revision=b.kind==='image'?D.visual_revisions?.[b.path]:null;return revision?currentVisual(revision)+`<details class="historical-image"><summary>이전 참고 이미지 · 교체 전 비교</summary>${numberedBlock(b)}</details>`:numberedBlock(b);};
const numberedAsset=asset;
asset=function(id){const a=byId(id),revision=a?D.visual_revisions?.[a.path]:null;return (revision?currentVisual(revision):'')+numberedAsset(id);};

// Number any source image embedded in a reader, screen or character view too.
function attachImageReviews(){
 document.querySelectorAll('#main img').forEach(img=>{
  if(img.closest('[data-numbered-image]')||img.dataset.numberAttached)return;
  const address=img.getAttribute('src');
  const row=imageRows.find(r=>r.url===address);
  if(!row)return;
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
home=function(){return inlineHome()+`<section id="overview-audit">${auditGallery()}</section><section id="overview-reviews">${reviewQueue()}</section>`;};
const jumpDestinations={maps:'screens',home:'',reader:'chapters',people:'characters',assets:'library',motion:'library',pm:'work',evidence:'proof',resume:'continue','asset-audit':'audit',reviews:'reviews',giyun:'giyun'};
document.getElementById('nav').innerHTML=[...nav,['giyun','기연 · 사건'],['asset-audit','사용 이미지 · 정리'],['reviews','내 체크 · 코멘트']].map(([id,label])=>`<a href="#home${jumpDestinations[id]?'/'+jumpDestinations[id]:''}" data-nav="${id}">${E(label)}</a>`).join('');

document.getElementById('nav').innerHTML+=reviewNav.map(([id,label])=>`<a href="#${id}" data-nav="${id}">${E(label)}</a>`).join('');
