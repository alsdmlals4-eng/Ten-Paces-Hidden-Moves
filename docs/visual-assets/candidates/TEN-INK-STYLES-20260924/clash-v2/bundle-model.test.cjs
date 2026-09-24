const test=require('node:test'),assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const {buildSequence,frameAt}=require('./bundle-model.cjs');
const fixture=require('./bundle-fixtures.json');
test('3/3/4 slots preserve preparation and carry the real final state forward',()=>{
 const sequence=buildSequence(fixture);
 assert.deepEqual(sequence.bundles.map(b=>b.slots.length),[3,3,4]);
 assert.deepEqual(sequence.bundles[0].slots.map(s=>s.player.label),['강공 · 전조','강공 · 실행','명상']);
 for(let i=1;i<3;i++)assert.deepEqual(fixture.bundles[i].input.before,fixture.bundles[i-1].result.state);
 assert.equal(sequence.bundles[2].slots.at(-1).timing,10);
});
test('future enemy names and results stay hidden; resolved rows persist',()=>{
 const s=buildSequence(fixture),b=s.bundles[2],tick=b.steps.find(t=>t.timing===8);
 const f=frameAt(s,tick.start+.01);
 assert.equal(f.phase,'전투진행');
 assert.deepEqual(f.slots.map(x=>x.status),['완료','진행','대기','대기']);
 assert.equal(f.slots[2].enemy,'미공개');assert.equal(f.slots[3].enemy,'미공개');
 assert.equal(f.result_visible,false);
 const after=frameAt(s,tick.end-.05);
 assert.equal(after.slots[2].enemy,'미공개');assert.equal(after.result_visible,true);
});
test('no planning transition inside a bundle; bundle momentum has its own record',()=>{
 const s=buildSequence(fixture);
 for(const b of s.bundles){for(const step of b.steps)assert.equal(frameAt(s,(step.start+step.end)/2).phase,'전투진행');
 assert.equal(frameAt(s,b.end-.01).phase,'묶음 완료');}
 const first=s.bundles[0];assert.equal(first.slots[1].delta.enemy.health,-2);
 assert.equal(first.slots[1].delta.player.momentum,1);
 assert.equal(first.completion_delta.player.momentum,1);
});
test('response payments occur once before the bundle and no double-counted clash damage',()=>{
 const s=buildSequence(fixture),b=s.bundles[1];
 assert.equal(b.response_delta.player.stamina,-1);
 assert.equal(b.slots[2].delta.player.stamina,0);
 assert.equal(b.slots[1].delta.enemy.health,-1);
 assert.equal(b.slots[2].delta.player.health,0);
});
test('fixture provenance matches the unchanged product source bytes',()=>{
 const root=path.resolve(__dirname,'../../../../..');
 for(const s of fixture.sources)assert.equal(crypto.createHash('sha256').update(fs.readFileSync(path.join(root,s.path))).digest('hex'),s.sha256,s.path);
});
test('verdict and damage wait for the corresponding blade contact and follow-through',()=>{
 const s=buildSequence(fixture),step=s.bundles[0].steps[1],duration=step.end-step.start;
 const atSource=sourceTime=>step.start+duration*(.10+.90*(sourceTime-1.10)/3.02);
 assert.equal(frameAt(s,atSource(2.49)).verdict_visible,false);
 assert.equal(frameAt(s,atSource(2.51)).verdict_visible,true);
 assert.equal(frameAt(s,atSource(3.11)).result_visible,false);
 assert.equal(frameAt(s,atSource(3.13)).result_visible,true);
 const guard=s.bundles[1].steps[2];
 assert.equal(frameAt(s,guard.start+(guard.end-guard.start)*.61).verdict_visible,false);
 assert.equal(frameAt(s,guard.start+(guard.end-guard.start)*.63).verdict_visible,true);
});
