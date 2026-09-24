/* Original generated art + offline key-pose choreography. No game rule simulation. */
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const {createCanvas,loadImage,GlobalFonts}=require(process.env.CANVAS_MODULE||'@napi-rs/canvas');
const HERE=__dirname,ROOT=path.resolve(HERE,'../../../../..'),OUT=path.join(ROOT,'output/ink-clash-v2');
const W=1280,H=928,ARENA_H=720,FPS=30,SECONDS=6.4;
const {readResult,presentationAt,drawResultPanel}=require('./result-panel.cjs');
const resultFixture=require('./result-fixtures.json');
const resultModel=readResult(resultFixture.cases.find(c=>c.id==='clash_win'));
const clamp=(x,a=0,b=1)=>Math.max(a,Math.min(b,x)),mix=(a,b,t)=>a+(b-a)*t,ease=t=>t*t*(3-2*t);
const rand=n=>{const x=Math.sin(n*127.1+43.7)*43758.5453;return x-Math.floor(x);};
// Coordinates inspected against the full original 1254px atlases; units are source pixels.
const P=[
 [[0,0,464,409],[228,393],[332,249],[458,359]],
 [[449,0,370,413],[630,404],[688,96],[497,14]],
 [[819,72,435,337],[1090,395],[980,156],[838,119]],
 [[0,416,453,389],[208,793],[353,497],[447,420]],
 [[423,435,399,372],[636,798],[698,541],[797,435]],
 [[788,490,466,316],[1023,791],[1127,583],[1249,584]],
 [[0,803,395,451],[181,1223],[215,875],[70,807]],
 [[389,817,486,437],[644,1233],[729,1057],[872,1190]],
 [[867,812,387,442],[1066,1239],[1145,1051],[1246,1175]]
].map(([r,a,h,tip])=>({r,a:a.map((n,i)=>n-r[i]),h:h.map((n,i)=>n-r[i]),tip:tip.map((n,i)=>n-r[i])}));
const E=[
 [[0,0,440,422],[218,414],[117,231],[9,354]],
 [[429,0,386,421],[615,413],[517,115],[727,24]],
 [[819,73,435,349],[1055,413],[1066,160],[1205,95]],
 [[0,405,437,425],[217,822],[96,489],[14,407]],
 [[418,435,435,394],[606,822],[547,556],[426,440]],
 [[737,473,517,357],[1060,817],[901,559],[741,559]],
 [[0,820,431,434],[215,1236],[177,866],[238,820]],
 [[389,880,475,374],[635,1240],[566,1100],[397,1204]],
 [[827,837,427,417],[1060,1240],[928,1065],[830,1173]]
].map(([r,a,h,tip])=>({r,a:a.map((n,i)=>n-r[i]),h:h.map((n,i)=>n-r[i]),tip:tip.map((n,i)=>n-r[i])}));
// Exclude a neighbouring-cell cloth shard from the display crop, not the source.
E[4].exclude=[0,175,27,148];
// Feet remain anchored during pose holds; root travel occurs during dash, recoil and recovery.
// time, poses, feet, lean, camera. Three visual exchanges belong to one illustrated clash.
const K=[
 [0,0,0,338,622,968,590,0,0,1],
 [.63,0,0,338,622,968,590,0,0,1.025],
 [.78,1,1,344,626,961,593,-3,3,1.035],
 [1.04,1,1,345,626,958,593,-3,3,1.045],
 [1.13,2,2,358,624,946,594,-2,2,1.065],
 [1.27,2,2,429,620,866,588,-1,1,1.095],
 [1.34,3,4,450,616,877,589,0,0,1.10],
 [1.47,3,4,450,616,877,589,0,0,1.10],
 [1.61,4,1,426,622,888,593,-2,4,1.07],
 [1.77,4,1,430,622,861,594,-2,2,1.07],
 [1.91,4,3,457,616,800,589,0,0,1.10],
 [2.01,4,3,457,616,800,589,0,0,1.10],
 [2.15,6,4,453,622,842,589,-3,1,1.075],
 [2.35,6,4,455,624,842,589,-3,1,1.085],
 [2.47,3,4,472,616,899,589,0,0,1.115],
 [2.73,3,4,472,616,899,589,0,0,1.115],
 [2.82,6,6,494,620,906,590,-3,5,1.09],
 [2.98,7,6,541,621,936,591,1,9,1.075],
 [3.12,7,6,551,621,966,596,1,12,1.075],
 [3.34,7,6,551,621,991,599,0,9,1.06],
 [3.53,8,8,534,619,1002,594,0,2,1.045],
 [4.12,8,8,512,620,1012,590,0,0,1.025],
 [5.10,8,8,489,620,1008,590,0,0,1.015],
 [6.4,8,8,489,620,1008,590,0,0,1.0]
];
function state(t){let i=0;while(i<K.length-2&&K[i+1][0]<=t)i++;const a=K[i],b=K[i+1],u=ease(clamp((t-a[0])/(b[0]-a[0])));const v=a.map((n,j)=>j<3?n:mix(n,b[j],u));return {p:a[1],e:a[2],px:v[3],py:v[4],ex:v[5],ey:v[6],pr:v[7],er:v[8],zoom:v[9]};}
function transform(pose,x,y,scale,r,q){const u=(q[0]-pose.a[0])*scale,v=(q[1]-pose.a[1])*scale,a=r*Math.PI/180;return [x+u*Math.cos(a)-v*Math.sin(a),y+u*Math.sin(a)+v*Math.cos(a)];}
function geometry(s){return {ph:transform(P[s.p],s.px,s.py,1.22,s.pr,P[s.p].h),pt:transform(P[s.p],s.px,s.py,1.22,s.pr,P[s.p].tip),eh:transform(E[s.e],s.ex,s.ey,1.10,s.er,E[s.e].h),et:transform(E[s.e],s.ex,s.ey,1.10,s.er,E[s.e].tip)};}
function crossing(a,b,c,d){const u=[b[0]-a[0],b[1]-a[1]],v=[d[0]-c[0],d[1]-c[1]],det=u[0]*v[1]-u[1]*v[0];if(Math.abs(det)<.01)return null;const q=[c[0]-a[0],c[1]-a[1]],s=(q[0]*v[1]-q[1]*v[0])/det,r=(q[0]*u[1]-q[1]*u[0])/det;return s>=0&&s<=1&&r>=0&&r<=1?[a[0]+s*u[0],a[1]+s*u[1]]:null;}
function prepare(img,poses){for(const p of poses){const [x,y,w,h]=p.r,c=createCanvas(w,h),q=c.getContext('2d');q.drawImage(img,x,y,w,h,0,0,w,h);const data=q.getImageData(0,0,w,h),d=data.data,seen=new Uint8Array(w*h),components=[];for(let n=0;n<w*h;n++){if(seen[n]||d[n*4+3]<9)continue;const list=[n];seen[n]=1;let at=0;while(at<list.length){const a=list[at++],xx=a%w,yy=Math.floor(a/w);for(const b of [xx?a-1:-1,xx<w-1?a+1:-1,yy?a-w:-1,yy<h-1?a+w:-1])if(b>=0&&!seen[b]&&d[b*4+3]>=9){seen[b]=1;list.push(b);}}components.push(list);}components.sort((a,b)=>b.length-a.length);const largest=components[0],keep=new Uint8Array(w*h);for(const n of largest)keep[n]=1;
 // Only discard disconnected pieces from neighbouring cells, without mutating source art.
 for(const comp of components.slice(1)){if(comp.length<4)continue;let near=false;for(const n of comp){for(const delta of [-2,-1,1,2,-w,w,-2*w,2*w])if(keep[n+delta]){near=true;break;}if(near)break;}if(near)for(const n of comp)keep[n]=1;}
 for(let n=0;n<w*h;n++)if(!keep[n])d[n*4+3]=0;q.putImageData(data,0,0);if(p.exclude)q.clearRect(...p.exclude);p.image=c;p.opaque=largest.length;}}
// Mild cloth/torso follow-through, while the foot row stays fixed. This is a compositing
// deformation of original character art, not a substitute for final articulated animation.
function actor(ctx,p,x,y,scale,r,t,side,alpha=1){ctx.save();ctx.globalAlpha=alpha;ctx.translate(x,y);ctx.rotate(r*Math.PI/180);ctx.scale(scale,scale);const h=p.image.height,w=p.image.width,move=t>1.05&&t<3.5;for(let sy=0;sy<h;sy+=4){const sh=Math.min(4,h-sy),height=clamp((p.a[1]-sy)/h),sway=Math.sin(t*(move?19:3.5)+sy*.02)*(move?1.7:.7)*height;ctx.drawImage(p.image,0,sy,w,sh,-p.a[0]+sway*side,sy-p.a[1],w,sh);}ctx.restore();}
const hits=[1.36,1.93,2.50];
const swings=[{a:1.10,b:1.36,side:'p',width:22},{a:1.11,b:1.36,side:'e',width:14},{a:1.73,b:1.93,side:'e',width:27},{a:2.28,b:2.50,side:'p',width:34},{a:2.82,b:3.10,side:'p',width:42}];
let brushTexture,brushPixels;
// Rasterize the curved UV field once per stroke instead of overlapping rotated strips.
// This keeps transparent bristle edges continuous without dark seams at segment joins.
function paintBrush(ctx,point,thick){
 const half=thick/2,N=64,ps=Array.from({length:N+1},(_,i)=>point(i/N));
 const x0=Math.max(0,Math.floor(Math.min(...ps.map(p=>p[0]))-half-2)),y0=Math.max(0,Math.floor(Math.min(...ps.map(p=>p[1]))-half-2));
 const x1=Math.min(W,Math.ceil(Math.max(...ps.map(p=>p[0]))+half+2)),y1=Math.min(H,Math.ceil(Math.max(...ps.map(p=>p[1]))+half+2)),w=x1-x0,h=y1-y0;
 if(w<1||h<1)return;const cv=createCanvas(w,h),q=cv.getContext('2d'),out=q.createImageData(w,h),dst=out.data,best=new Float32Array(w*h);best.fill(Infinity);
 const tw=brushTexture.width,th=brushTexture.height,src=brushPixels;
 for(let n=0;n<N;n++){const [ax,ay]=ps[n],[bx,by]=ps[n+1],dx=bx-ax,dy=by-ay,len=Math.hypot(dx,dy);if(len<.01)continue;const nx=-dy/len,ny=dx/len;
  const left=Math.max(x0,Math.floor(Math.min(ax,bx)-Math.abs(nx)*half-2)),right=Math.min(x1,Math.ceil(Math.max(ax,bx)+Math.abs(nx)*half+2));
  const top=Math.max(y0,Math.floor(Math.min(ay,by)-Math.abs(ny)*half-2)),bottom=Math.min(y1,Math.ceil(Math.max(ay,by)+Math.abs(ny)*half+2));
  for(let y=top;y<bottom;y++)for(let x=left;x<right;x++){const px=x+.5-ax,py=y+.5-ay,along=(px*dx+py*dy)/(len*len);if(along<-.08||along>1.08)continue;const u=clamp(along),signed=px*nx+py*ny,dist=(px-u*dx)**2+(py-u*dy)**2;if(Math.abs(signed)>half)continue;const at=(y-y0)*w+x-x0;if(dist>=best[at])continue;best[at]=dist;
   const tx=clamp((n+u)/N*tw,0,tw-1),ty=clamp((signed/thick+.5)*th,0,th-1),ix=Math.floor(tx),iy=Math.floor(ty),fx=tx-ix,fy=ty-iy;
   for(let ch=0;ch<4;ch++){const v00=src[(iy*tw+ix)*4+ch],v10=src[(iy*tw+Math.min(ix+1,tw-1))*4+ch],v01=src[(Math.min(iy+1,th-1)*tw+ix)*4+ch],v11=src[(Math.min(iy+1,th-1)*tw+Math.min(ix+1,tw-1))*4+ch];dst[at*4+ch]=mix(mix(v00,v10,fx),mix(v01,v11,fx),fy);}
  }
 }
 q.putImageData(out,0,0);ctx.drawImage(cv,x0,y0);
}
function slash(ctx,t,beat){
 const {a,b,side,width}=beat;if(t<a||t>b+.20)return;
 const u=clamp((t-a)/(b-a)),fade=1-clamp((t-b)/.20),g0=geometry(state(a)),g1=geometry(state(Math.min(t,b)));
 const from=side==='p'?g0.pt:g0.et,to=side==='p'?g1.pt:g1.et;
 const ctrl=[mix(from[0],to[0],.5)+(side==='p'?-35:35),Math.min(from[1],to[1])-55];
 const point=q=>[(1-q)**2*from[0]+2*(1-q)*q*ctrl[0]+q*q*to[0],(1-q)**2*from[1]+2*(1-q)*q*ctrl[1]+q*q*to[1]];
 ctx.save();ctx.globalAlpha=fade*.85;
 paintBrush(ctx,point,width*3.1);
 for(let n=0;n<19;n++){const k=.2+rand(n)*.8,p=point(k),spread=18+rand(n+29)*width;ctx.globalAlpha=fade*.6;ctx.fillStyle='#25231f';ctx.beginPath();ctx.ellipse(p[0]+(rand(n+5)-.5)*spread,p[1]+(rand(n+13)-.5)*spread,1+rand(n+41)*2.5,.6+rand(n+8)*1.1,rand(n)*6,0,Math.PI*2);ctx.fill();}
 ctx.restore();
}
function impact(ctx,t,checks){for(let i=0;i<hits.length;i++){const d=t-hits[i];if(d<0||d>.34)continue;const [x,y]=checks[i].intersection,fade=1-d/.34;ctx.save();ctx.globalAlpha=fade;for(let n=0;n<24;n++){const a=rand(n+i*35)*Math.PI*2,r=(12+rand(n+80)*64)*(d/.34+.16);ctx.strokeStyle=n%5===0?'#b9914c':'#24231f';ctx.lineWidth=n%3?1:2.4;ctx.beginPath();ctx.moveTo(x+Math.cos(a)*r*.4,y+Math.sin(a)*r*.4);ctx.lineTo(x+Math.cos(a)*r,y+Math.sin(a)*r);ctx.stroke();}ctx.strokeStyle='#fff9e6';ctx.lineWidth=3.8;ctx.beginPath();ctx.moveTo(x-17*fade,y-25*fade);ctx.lineTo(x+17*fade,y+25*fade);ctx.moveTo(x-27*fade,y+12*fade);ctx.lineTo(x+27*fade,y-12*fade);ctx.stroke();ctx.restore();}}
function sweepLines(ctx,t){if(!((t>1.10&&t<1.31)||(t>2.86&&t<3.10)))return;const u=t<2?(t-1.1)/.21:(t-2.86)/.24;ctx.save();ctx.globalAlpha=Math.sin(u*Math.PI)*.20;ctx.strokeStyle='#202422';for(let i=0;i<18;i++){const y=92+rand(i)*515,x=rand(i+30)*1120;ctx.lineWidth=.5+rand(i+60)*1.5;ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(x+40+rand(i+7)*130,y-10);ctx.stroke();}ctx.restore();}
function inkBar(ctx,x,y,w,h,color){ctx.fillStyle=color;ctx.beginPath();for(let i=0;i<=48;i++){const xx=x+i*w/48,yy=y+(rand(i+23)-.5)*5;if(!i)ctx.moveTo(xx,yy);else ctx.lineTo(xx,yy);}for(let i=48;i>=0;i--)ctx.lineTo(x+i*w/48,y+h+(rand(i+88)-.5)*7);ctx.closePath();ctx.fill();}
function captions(ctx,t){
 const stage=presentationAt(resultModel,t);ctx.save();
 inkBar(ctx,1110,24,126,34,'rgba(242,234,216,.93)');ctx.font='17px Book';ctx.fillStyle='#37382e';ctx.textAlign='center';ctx.fillText(stage.phase,1173,48);
 ctx.restore();drawResultPanel(ctx,resultModel,t);
}
async function main(){fs.mkdirSync(path.join(OUT,'frames'),{recursive:true});fs.mkdirSync(path.join(OUT,'qa'),{recursive:true});for(const [p,n] of [['C:/Windows/Fonts/batang.ttc','Book'],['C:/Windows/Fonts/malgun.ttf','Korean']])if(fs.existsSync(p))GlobalFonts.registerFromPath(p,n);const [bg,player,enemy,hero,ink]=await Promise.all(['background.png','player-poses.png','opponent-poses.png','hero-clash.png','ink-brush.png'].map(n=>loadImage(path.join(HERE,n))));brushTexture=ink;const bc=createCanvas(ink.width,ink.height),bq=bc.getContext('2d');bq.drawImage(ink,0,0);brushPixels=bq.getImageData(0,0,ink.width,ink.height).data;prepare(player,P);prepare(enemy,E);const checks=hits.map(time=>{const g=geometry(state(time));return {time,intersection:crossing(g.ph,g.pt,g.eh,g.et),...g};});if(checks.some(c=>!c.intersection))throw new Error('Blade contact failed: '+JSON.stringify(checks));const c=createCanvas(W,H),q=c.getContext('2d'),frames=[];const sample=new Set([0,34,41,58,75,78,91,101,126,168]);const only=process.argv.includes('--samples');for(let f=0;f<FPS*SECONDS;f++){if(only&&!sample.has(f))continue;const t=f/FPS,s=state(t);q.fillStyle='#e9e2d1';q.fillRect(0,0,W,H);q.save();let shake=0;for(const hit of hits){const d=t-hit;if(d>=0&&d<.13)shake=3.8*Math.sin(d*100)*(1-d/.13);}q.translate(W/2+shake,360+shake*.35);q.scale(s.zoom,s.zoom);q.translate(-W/2,-360);q.drawImage(bg,0,0,W,ARENA_H);
 for(let i=0;i<2;i++){const x=320+i*650+Math.sin(t*.28+i)*24,g=q.createRadialGradient(x,450,20,x,450,310);g.addColorStop(0,'rgba(249,244,230,.06)');g.addColorStop(1,'rgba(249,244,230,0)');q.fillStyle=g;q.fillRect(x-320,240,640,370);}
 for(const [x,y,r] of [[s.px,s.py,80],[s.ex,s.ey,69]]){q.fillStyle='rgba(21,23,20,.14)';q.beginPath();q.ellipse(x,y+1,r,6,0,0,Math.PI*2);q.fill();}
 if((t>1.14&&t<1.29)||(t>2.91&&t<3.08)){for(let n=3;n>0;n--)actor(q,P[s.p],s.px-18*n,s.py,1.22,s.pr,t,1,.035*(4-n));}
 actor(q,E[s.e],s.ex,s.ey,1.10,s.er,t,-1);actor(q,P[s.p],s.px,s.py,1.22,s.pr,t,1);
 for(const sw of swings)slash(q,t,sw);impact(q,t,checks);sweepLines(q,t);q.restore();
 // A six-frame, closer hand-drawn key shot emphasizes the deciding contact, then
 // returns to the continuous scene. It is not presented as extra animation frames.
 if(t>=2.50&&t<2.70){const u=(t-2.5)/.2,z=1+u*.045;q.save();q.translate(W*.66,ARENA_H*.4);q.scale(z,z);q.translate(-W*.66,-ARENA_H*.4);q.drawImage(hero,0,0,W,ARENA_H);q.restore();}
 // Near foreground leaves drift across the stone, never across the weapon contact.
 for(let n=0;n<7;n++){const x=(rand(n+6)*1500-t*(14+rand(n)*16)+1600)%1500-100,y=592+rand(n+10)*49+Math.sin(t*1.7+n)*3;q.save();q.translate(x,y);q.rotate(t*.5+n);q.fillStyle='rgba(30,30,25,.36)';q.beginPath();q.ellipse(0,0,3.4,1.3,0,0,Math.PI*2);q.fill();q.restore();}
 captions(q,t);const bytes=c.toBuffer('image/png');const filename=String(f).padStart(4,'0')+'.png';if(!only)fs.writeFileSync(path.join(OUT,'frames',filename),bytes);if(sample.has(f))fs.writeFileSync(path.join(OUT,'qa',filename),bytes);if(f===126)fs.writeFileSync(path.join(HERE,'poster.png'),bytes);frames.push({frame:f,time:t,p:s.p,e:s.e,sha256:crypto.createHash('sha256').update(bytes).digest('hex')});}
 const report={result_panel:{fixture:'result-fixtures.json',case_id:resultModel.id,source:'actual product resolver fixed-input capture',timeline:{reveal:1.10,verdict:2.50,damage:3.12,next_planning:5.12},protects_original_arena:[W,ARENA_H]},method:'OFFLINE_KEYPOSE_AND_COMPOSITING_PREVIEW_NOT_GAME_CAPTURE',fps:FPS,seconds:SECONDS,size:[W,H],frame_count:frames.length,samples_only:only,distinct_frames:new Set(frames.map(f=>f.sha256)).size,contacts:checks,hero_insert:{start:2.5,end:2.7,original_key_art:true},art_pose_count:{player:P.length,opponent:E.length},used_pose_count:{player:new Set(frames.map(f=>f.p)).size,opponent:new Set(frames.map(f=>f.e)).size},frames_directory:path.relative(ROOT,path.join(OUT,'frames')).replaceAll('\\','/'),frames};fs.writeFileSync((only?path.join(OUT,'qa/sample-check.json'):path.join(HERE,'render-check.json')),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({frames:frames.length,output:OUT,contacts:checks.map(v=>({time:v.time,point:v.intersection}))}));}
// The bundle preview reuses the approved art, contact geometry and brush renderer.
async function loadStage(){
 for(const [p,n] of [['C:/Windows/Fonts/batang.ttc','Book'],['C:/Windows/Fonts/malgun.ttf','Korean']])if(fs.existsSync(p))GlobalFonts.registerFromPath(p,n);
 const [bg,player,enemy,hero,ink]=await Promise.all(['background.png','player-poses.png','opponent-poses.png','hero-clash.png','ink-brush.png'].map(n=>loadImage(path.join(HERE,n))));
 brushTexture=ink;const bc=createCanvas(ink.width,ink.height),bq=bc.getContext('2d');bq.drawImage(ink,0,0);brushPixels=bq.getImageData(0,0,ink.width,ink.height).data;
 prepare(player,P);prepare(enemy,E);
 const checks=hits.map(time=>{const g=geometry(state(time));return {time,intersection:crossing(g.ph,g.pt,g.eh,g.et),...g};});
 if(checks.some(c=>!c.intersection))throw new Error('Missing blade contact');
 return {bg,hero,checks};
}
function drawStage(q,art,s,{clock=0,effectTime=null,hero=true}={}){
 q.save();q.beginPath();q.rect(0,0,W,ARENA_H);q.clip();
 let shake=0;if(effectTime!==null)for(const hit of hits){const d=effectTime-hit;if(d>=0&&d<.13)shake=3.8*Math.sin(d*100)*(1-d/.13);}
 q.translate(W/2+shake,360+shake*.35);q.scale(s.zoom,s.zoom);q.translate(-W/2,-360);q.drawImage(art.bg,0,0,W,ARENA_H);
 for(const [x,y,r] of [[s.px,s.py,80],[s.ex,s.ey,69]]){q.fillStyle='rgba(21,23,20,.14)';q.beginPath();q.ellipse(x,y+1,r,6,0,0,Math.PI*2);q.fill();}
 actor(q,E[s.e],s.ex,s.ey,1.10,s.er,clock,-1);actor(q,P[s.p],s.px,s.py,1.22,s.pr,clock,1);
 if(effectTime!==null){for(const sw of swings)slash(q,effectTime,sw);impact(q,effectTime,art.checks);sweepLines(q,effectTime);}
 q.restore();
 if(hero&&effectTime>=2.50&&effectTime<2.70){q.save();q.drawImage(art.hero,0,0,W,ARENA_H);q.restore();}
 for(let n=0;n<7;n++){const x=(rand(n+6)*1500-clock*(14+rand(n)*16)+1600)%1500-100,y=592+rand(n+10)*49+Math.sin(clock*1.7+n)*3;q.save();q.translate(x,y);q.rotate(clock*.5+n);q.fillStyle='rgba(30,30,25,.36)';q.beginPath();q.ellipse(0,0,3.4,1.3,0,0,Math.PI*2);q.fill();q.restore();}
}
module.exports={loadStage,drawStage,state,createCanvas,inkBar};
if(require.main===module)main().catch(e=>{console.error(e);process.exitCode=1;});
