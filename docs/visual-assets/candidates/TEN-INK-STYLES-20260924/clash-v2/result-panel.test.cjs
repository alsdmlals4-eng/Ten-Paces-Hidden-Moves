const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const fixture=require('./result-fixtures.json');
const {readResult,presentationAt}=require('./result-panel.cjs');
const item=id=>fixture.cases.find(c=>c.id===id);

test('resolved clash reports one damage result and excludes bundle completion reward',()=>{
  const m=readResult(item('clash_win'));
  assert.deepEqual(m.compare.values,[11,9]);
  assert.equal(m.compare.difference,2);
  assert.deepEqual(m.health_loss,{player:0,enemy:2});
  assert.deepEqual(m.momentum_gain,{player:1,enemy:0});
  assert.equal(item('clash_win').result.state.player.momentum[0],2);
  assert.deepEqual(m.sides.player.paid,{stamina:1,internal:2});
  assert.match(m.result,/상대 체력 30 → 28/);
});
test('a losing attack record is not treated as outgoing damage',()=>{
  const m=readResult(item('clash_loss'));
  assert.deepEqual(m.health_loss,{player:4,enemy:0});
  assert.deepEqual(m.momentum_gain,{player:0,enemy:1});
  assert.match(m.result,/내 체력 30 → 26/);
});
test('draw, evade, block and range failure keep their distinct causes',()=>{
  assert.match(readResult(item('clash_draw')).result,/상쇄/);
  const e=readResult(item('evade'));
  assert.equal(e.compare.kind,'evade');
  assert.equal(e.compare.difference,null);
  assert.deepEqual(e.compare.values,[11,null]);
  assert.equal(e.sides.enemy.paid.stamina,1);
  assert.match(e.result,/회피 성공.*피해 0.*상대 절초 기세 \+1/);
  const g=readResult(item('guard'));
  assert.equal(g.compare.after_block,7);
  assert.equal(g.health_loss.enemy,3);
  const r=readResult(item('miss_range'));
  assert.equal(r.compare.kind,'miss_range');
  assert.deepEqual(r.compare.values,[null,null]);
  assert.match(r.result,/사거리 밖.*피해 0/);
});
test('planning conceals opponent; impact reveals verdict before damage, then holds last result',()=>{
  const m=readResult(item('clash_win'));
  assert.equal(presentationAt(m,0).enemy_visible,false);
  assert.equal(presentationAt(m,1.2).enemy_visible,true);
  assert.equal(presentationAt(m,2.49).verdict_visible,false);
  assert.equal(presentationAt(m,2.5).verdict_visible,true);
  assert.equal(presentationAt(m,3).damage_visible,false);
  assert.equal(presentationAt(m,3.12).damage_visible,true);
  assert.equal(presentationAt(m,5.5).last_result,true);
});
test('fixtures retain current source hashes and six distinct domain results',()=>{
  const root=path.resolve(__dirname,'../../../../..');
  for(const source of fixture.sources){
    const digest=crypto.createHash('sha256').update(fs.readFileSync(path.join(root,source.path))).digest('hex');
    assert.equal(digest,source.sha256,source.path);
  }
  assert.equal(new Set(fixture.cases.map(c=>c.id)).size,6);
});
