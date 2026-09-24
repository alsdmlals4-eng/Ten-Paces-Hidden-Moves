const fs=require('node:fs'),path=require('node:path');
const {readResult}=require('./result-panel.cjs');
const fixture=require('./result-fixtures.json');
const esc=s=>String(s).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
const rows=fixture.cases.map(item=>{
  const m=readResult(item),c=m.compare;
  const comparison=c.kind==='clash'?`${c.values[0]} 대 ${c.values[1]}`:c.kind==='evade'?`공격 위력 ${c.values[0]} / 같은 수 회피`:c.kind==='guard'?`공격 ${c.values[0]} → 방어도 후 ${c.after_block} → 같은 수 막기`:c.kind==='miss_range'?'거리 3 / 강공 사거리 1~2':'공격';
  return `<tr><th scope="row">${esc(m.verdict)}</th><td>${esc(comparison)}</td><td>${esc(m.result)}</td></tr>`;
}).join('\n');
const content=`<details class="result-examples"><summary>결과를 글로 보기 · 합·회피·막기 표시 예시</summary><p>동일한 게임 판정 코드에 고정된 입력을 넣어 얻은 기록입니다. 아래 표는 정지 결과이며, 위 영상은 첫 번째 합 승리 상황의 연출입니다.</p><div class="table-scroll" tabindex="0" role="region" aria-label="판정별 결과 표"><table><thead><tr><th>판정</th><th>비교·원인</th><th>실제 변화</th></tr></thead><tbody>${rows}</tbody></table></div><p>강공 소모: 양측 기력 1 · 내력 2. 회피·막기는 상대 기력 1 · 내력 0. 기세는 해당 수에서 실제 늘어난 양이며 묶음 완료 보상은 포함하지 않습니다. 회피는 위력 숫자의 대소 비교가 아닙니다.</p></details>`;
const file=path.join(__dirname,'../index.html'),html=fs.readFileSync(file,'utf8');
if(!html.includes('<!-- result-examples:start -->'))throw new Error('Result examples marker missing');
fs.writeFileSync(file,html.replace(/<!-- result-examples:start -->[\s\S]*?<!-- result-examples:end -->/,'<!-- result-examples:start -->\n'+content+'\n<!-- result-examples:end -->'));
console.log('Published six resolver result examples');
