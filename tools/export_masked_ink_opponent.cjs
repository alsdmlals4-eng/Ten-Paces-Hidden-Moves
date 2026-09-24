/* Reuse the approved pose registration for the minimally edited mask atlas. */
const fs=require('node:fs'),path=require('node:path'),vm=require('node:vm'),crypto=require('node:crypto');
const {createCanvas,loadImage}=require(process.env.CANVAS_MODULE||'@napi-rs/canvas');
const root=path.resolve(__dirname,'..');
const dir='docs/visual-assets/candidates/TEN-INK-SCREENS-20260925';
const out='assets/combat/ink_wuxia/masked_baekmujin';
const code=fs.readFileSync(path.join(root,'docs/visual-assets/candidates/TEN-INK-STYLES-20260924/clash-v2/render.cjs'),'utf8');
const context={createCanvas};
vm.runInNewContext(code.slice(code.indexOf('const P='),code.indexOf('function state('))+code.slice(code.indexOf('function prepare('),code.indexOf('// Mild cloth/torso'))+';this.poses=E;this.prepare=prepare;',context);
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
async function main(){
 fs.mkdirSync(path.join(root,out),{recursive:true});
 const original=await loadImage(path.join(root,dir,'masked-poses.png'));
 if(original.width!==1254||original.height!==1254)throw new Error('Mask edit must retain approved 1254 x 1254 registration');
 context.prepare(original,context.poses);
 const poses=context.poses.map((p,i)=>{const name='enemy-'+i+'.png',bytes=p.image.toBuffer('image/png');fs.writeFileSync(path.join(root,out,name),bytes);return {path:'res://'+out+'/'+name,size:[p.r[2],p.r[3]],foot:p.a,hilt:p.h,tip:p.tip,sha256:sha(bytes)};});
 const portrait=createCanvas(340,330),q=portrait.getContext('2d');q.drawImage(context.poses[0].image,60,0,340,330,0,0,340,330);
 fs.writeFileSync(path.join(root,'assets/characters/portraits/masked_baekmujin_ink_20260925.png'),portrait.toBuffer('image/png'));
 fs.writeFileSync(path.join(root,'data/presentation/masked_ink_opponent.json'),JSON.stringify({schema_version:1,candidate_id:'masked_baekmujin',preview_name:'배외검객',source:dir+'/masked-poses.png',source_sha256:sha(fs.readFileSync(path.join(root,dir,'masked-poses.png'))),poses,hero:'res://'+out+'/hero-clash.png'},null,2)+'\n');
 console.log('Masked opponent: nine registered poses and derived portrait');
 const dogDir='assets/combat/ink_wuxia/slot1_dogyeom';
 fs.mkdirSync(path.join(root,dogDir),{recursive:true});
 const dog=await loadImage(path.join(root,dir,'dogyeom-poses.png'));
 if(dog.width!==1254||dog.height!==1254)throw new Error('Dogyeom pose registration must be 1254 square');
 context.prepare(dog,context.poses);
 const hands=[[[104,255],[86,270]],[[516,126],[512,84]],[[901,252],[878,258]],[[63,477],[41,451]],[[586,554],[554,530]],[[901,546],[856,543]],[[191,867],[213,853]],[[579,1154],[557,1190]],[[941,1040],[920,1061]]];
 const dogPoses=context.poses.map((p,i)=>{const bytes=p.image.toBuffer('image/png'),file=dogDir+'/enemy-'+i+'.png';fs.writeFileSync(path.join(root,file),bytes);return {path:'res://'+file,size:[p.r[2],p.r[3]],foot:p.a,hilt:hands[i][0].map((n,j)=>n-p.r[j]),tip:hands[i][1].map((n,j)=>n-p.r[j]),sha256:sha(bytes)};});
 const dogPortrait=createCanvas(340,330);dogPortrait.getContext('2d').drawImage(context.poses[0].image,60,0,340,330,0,0,340,330);
 fs.writeFileSync(path.join(root,'assets/characters/portraits/slot1_dogyeom_ink_20260925.png'),dogPortrait.toBuffer('image/png'));
 fs.writeFileSync(path.join(root,'data/presentation/dogyeom_ink_opponent.json'),JSON.stringify({schema_version:1,candidate_id:'slot1_dogyeom',unarmed:true,source:dir+'/dogyeom-poses.png',source_sha256:sha(fs.readFileSync(path.join(root,dir,'dogyeom-poses.png'))),poses:dogPoses,hero:''},null,2)+'\n');
 console.log('Dogyeom: nine unarmed poses with hand anchors and derived portrait');
}
main().catch(error=>{console.error(error);process.exitCode=1;});
