/* Reuse the approved compositor's exact crop/alpha cleanup and geometry. No new art. */
const fs=require('node:fs'),path=require('node:path'),vm=require('node:vm'),crypto=require('node:crypto');
const {createCanvas,loadImage}=require(process.env.CANVAS_MODULE||'@napi-rs/canvas');
const root=path.resolve(__dirname,'..'),source=path.join(root,'docs/visual-assets/candidates/TEN-INK-STYLES-20260924/clash-v2');
const out=path.join(root,'assets/combat/ink_wuxia'),data=path.join(root,'data/presentation');
const code=fs.readFileSync(path.join(source,'render.cjs'),'utf8');
const sandbox={createCanvas};
vm.runInNewContext(code.slice(code.indexOf('const P='),code.indexOf('function state('))+code.slice(code.indexOf('function prepare('),code.indexOf('// Mild cloth/torso'))+';this.geometry={P,E,K};this.prepare=prepare;',sandbox);
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
async function main(){
 fs.mkdirSync(out,{recursive:true});fs.mkdirSync(data,{recursive:true});const provenance=[];
 for(const name of ['background.png','hero-clash.png','ink-brush.png']){const b=fs.readFileSync(path.join(source,name));fs.writeFileSync(path.join(out,name),b);provenance.push({source:name,path:'res://assets/combat/ink_wuxia/'+name,sha256:sha(b)});}
 const poses={};
 for(const [role,original,key] of [['player','player-poses.png','P'],['enemy','opponent-poses.png','E']]){
  const specs=sandbox.geometry[key];sandbox.prepare(await loadImage(path.join(source,original)),specs);
  poses[role]=specs.map((p,i)=>{const name=role+'-'+i+'.png',b=p.image.toBuffer('image/png');fs.writeFileSync(path.join(out,name),b);return {path:'res://assets/combat/ink_wuxia/'+name,size:[p.r[2],p.r[3]],foot:p.a,hilt:p.h,tip:p.tip,sha256:sha(b)};});
  provenance.push({source:original,sha256:sha(fs.readFileSync(path.join(source,original))),derivation:'Approved render.cjs prepare: region crop and disconnected neighbouring-cell alpha removal'});
 }
 fs.writeFileSync(path.join(data,'ink_combat_stage.json'),JSON.stringify({schema_version:1,style:'8+3contrast+9mist',approval:'2026-09-24 user: 지금 느낌으로 전투쪽 이미지,연출등을 변경하자. 먹 VFX 연결',source_directory:path.relative(root,source).replaceAll('\\','/'),source_renderer_sha256:sha(code),poses,keyframes:sandbox.geometry.K,contacts:[1.36,1.93,2.50],swings:[{a:1.10,b:1.36,side:'player',width:22},{a:1.11,b:1.36,side:'enemy',width:14},{a:1.73,b:1.93,side:'enemy',width:27},{a:2.28,b:2.50,side:'player',width:34},{a:2.82,b:3.10,side:'player',width:42}],provenance},null,2)+'\n');
 console.log('Approved stage exported: 18 poses, 3 original images, geometry and hashes');
}
main().catch(e=>{console.error(e);process.exitCode=1;});
