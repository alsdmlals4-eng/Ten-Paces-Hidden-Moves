const fs=require('node:fs'),path=require('node:path');
const {buildSequence}=require('./bundle-model.cjs');
const sequence=buildSequence(require('./bundle-fixtures.json'));
const escape=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const file=path.join(__dirname,'../index.html');let html=fs.readFileSync(file,'utf8');
function replace(start,end,value){const a=html.indexOf(start),b=html.indexOf(end);if(a<0||b<a)throw Error('Missing marker');html=html.slice(0,a+start.length)+'\n'+value+'\n'+html.slice(b);}
replace('<!-- bundle-chapters:start -->','<!-- bundle-chapters:end -->','<nav class="bundle-chapters" aria-label="행동 묶음으로 이동">'+sequence.bundles.map(b=>`<button type="button" data-bundle="${b.index}" data-start="${b.start.toFixed(2)}">${b.index}묶음 · ${b.slots.length}수</button>`).join('')+'</nav>');
replace('<!-- bundle-records:start -->','<!-- bundle-records:end -->','<details class="result-examples bundle-records"><summary>움직임 없이 읽기 · 세 묶음의 완료 기록</summary><p>영상 전체의 결과를 읽는 복기 표입니다. 재생 화면에서는 아직 진행하지 않은 상대 행동을 공개하지 않습니다.</p>'+sequence.bundles.map(b=>`<h3>${b.index}묶음 · ${b.slots.length}수</h3><div class="table-scroll" tabindex="0" role="region" aria-label="${b.index}묶음 완료 기록"><table><thead><tr><th>수</th><th>내 행동</th><th>상대 행동</th><th>실제 결과</th></tr></thead><tbody>${b.slots.map(s=>`<tr><th scope="row">${s.local}</th><td>${escape(s.player.label)}</td><td>${escape(s.enemy.label)}</td><td>${escape(s.verdict+' · '+s.result)}</td></tr>`).join('')}</tbody></table></div>`).join('')+'<p>막기 비용은 2묶음 시작 때 한 번 지불됩니다. 각 합의 기세와 묶음 완료 기세를 구분하며, 기세가 이미 가득 차면 증가량은 0입니다.</p></details>');
replace('// bundle-player:start','// bundle-player:end',`const bundleChapters=${JSON.stringify(sequence.bundles.map(b=>({index:b.index,start:b.start,end:b.end})))};
document.querySelectorAll('[data-bundle]').forEach(button=>button.addEventListener('click',async()=>{exitGif();motionVideo.currentTime=Number(button.dataset.start);try{await motionVideo.play();motionStatus.textContent=button.textContent+'부터 재생합니다.';}catch{motionStatus.textContent='재생 버튼으로 시작하세요.';}}));
let shownBundle=0;
motionVideo.addEventListener('timeupdate',()=>{const chapter=bundleChapters.find(b=>motionVideo.currentTime<b.end)||bundleChapters.at(-1);if(chapter.index===shownBundle)return;shownBundle=chapter.index;document.querySelectorAll('[data-bundle]').forEach(button=>button.setAttribute('aria-current',String(Number(button.dataset.bundle)===shownBundle)));});`);
fs.writeFileSync(file,html);console.log('Published 3/3/4 chapter controls and resolver-backed recap.');
