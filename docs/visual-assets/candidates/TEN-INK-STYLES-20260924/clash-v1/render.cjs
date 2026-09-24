/* Offline choreography preview; consumes original generated art, never game rules. */
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const {createCanvas,loadImage,GlobalFonts}=require(process.env.CANVAS_MODULE||'@napi-rs/canvas');
const HERE=__dirname,ROOT=path.resolve(HERE,'../../../../..'),OUT=path.join(ROOT,'output','ink-clash-v1','frames');
const W=1280,H=720,FPS=25,SECONDS=8.4;
const clamp=(x,a=0,b=1)=>Math.max(a,Math.min(b,x)),lerp=(a,b,t)=>a+(b-a)*t,smooth=t=>t*t*(3-2*t);
const rand=n=>{const v=Math.sin(n*127.1+43.7)*43758.5453;return v-Math.floor(v);};
// Inspected atlas rectangles and foot anchors. Preserve original pixels and alpha.
const P=[
{r:[0,0,500,495],a:[232,482],h:[309,262],tip:[472,451]},
{r:[506,0,444,489],a:[247,472],h:[107,108],tip:[274,18]},
{r:[969,0,567,490],a:[252,458],h:[396,153],tip:[551,41]},
{r:[0,498,483,479],a:[234,457],h:[305,137],tip:[476,9]},
{r:[489,499,579,477],a:[247,455],h:[391,244],tip:[574,386]},
{r:[1101,513,431,470],a:[214,437],h:[157,163],tip:[421,17]}
];
const E=[
{r:[0,60,503,476],a:[299,465],h:[209,257],tip:[54,411]},
{r:[550,24,423,510],a:[229,497],h:[174,88],tip:[402,15]},
{r:[988,48,548,463],a:[292,458],h:[186,148],tip:[23,20]},
{r:[47,539,453,452],a:[226,438],h:[187,170],tip:[13,6]},
{r:[512,595,530,407],a:[278,393],h:[194,207],tip:[4,343]},
{r:[1057,505,478,496],a:[264,476],h:[375,96],tip:[246,7]}
];
// One artistic scenario. Contact beats are exchanges, never extra damage events.
const keys=[
[0,0,0,310,588,945,548,0,0],[.65,0,0,310,588,945,548,0,0],
[.90,1,1,315,590,938,550,-3,3],[1.24,1,1,330,590,923,550,-4,4],
[1.46,2,2,449,589,789,549,0,0],[1.63,2,2,460,586,778,550,0,0],
[1.79,2,2,460,586,778,550,0,0],[2.04,3,3,421,588,827,550,-2,2],
[2.24,1,1,423,590,825,552,-3,3],[2.46,2,3,460,586,768,550,0,0],
[2.62,2,3,460,586,768,550,0,0],[2.89,3,2,435,588,805,550,-2,1],
[3.13,1,1,439,588,804,550,-3,2],[3.36,2,3,480,586,790,550,0,0],
[3.54,2,3,480,586,790,550,0,0],[3.83,3,5,499,586,841,551,1,5],
[4.00,1,5,493,586,850,551,-2,6],[4.20,4,5,535,586,867,552,1,9],
[4.40,4,5,535,586,885,553,1,10],[4.78,5,3,520,588,887,550,0,0],
[5.04,5,3,491,588,905,550,0,0],[5.42,0,0,413,588,929,548,0,0],
[5.95,0,0,310,588,945,548,0,0],[8.4,0,0,310,588,945,548,0,0]
];
function state(t){
 let i=0;while(i<keys.length-2&&keys[i+1][0]<=t)i++;
 const a=keys[i],b=keys[i+1],u=clamp((t-a[0])/(b[0]-a[0]));
 return {p:a[1],e:a[2],px:lerp(a[3],b[3],smooth(u)),py:lerp(a[4],b[4],smooth(u)),ex:lerp(a[5],b[5],smooth(u)),ey:lerp(a[6],b[6],smooth(u)),pr:lerp(a[7],b[7],smooth(u)),er:lerp(a[8],b[8],smooth(u))};
}
function transformed(pose,at,s,r,q){
 const x=(q[0]-pose.a[0])*s,y=(q[1]-pose.a[1])*s,angle=r*Math.PI/180;
 return [at[0]+x*Math.cos(angle)-y*Math.sin(angle),at[1]+x*Math.sin(angle)+y*Math.cos(angle)];
}
function segmentCross(a,b,c,d){
 const u=[b[0]-a[0],b[1]-a[1]],v=[d[0]-c[0],d[1]-c[1]],den=u[0]*v[1]-u[1]*v[0];if(Math.abs(den)<.01)return null;
 const q=[c[0]-a[0],c[1]-a[1]],s=(q[0]*v[1]-q[1]*v[0])/den,r=(q[0]*u[1]-q[1]*u[0])/den;
 return s>=0&&s<=1&&r>=0&&r<=1?[a[0]+s*u[0],a[1]+s*u[1]]:null;
}
function geometry(s){
 const p=P[s.p],e=E[s.e],pa=[s.px,s.py],ea=[s.ex,s.ey];
 return {ph:transformed(p,pa,.87,s.pr,p.h),pt:transformed(p,pa,.87,s.pr,p.tip),eh:transformed(e,ea,.79,s.er,e.h),et:transformed(e,ea,.79,s.er,e.tip)};
}
function drawActor(ctx,img,pose,x,y,scale,rotation,alpha=1){
 ctx.save();ctx.globalAlpha=alpha;ctx.translate(x,y);ctx.rotate(rotation*Math.PI/180);ctx.scale(scale,scale);
 ctx.drawImage(pose.image,-pose.a[0],-pose.a[1]);ctx.restore();
}
function prepareAtlas(img,poses){
 for(const pose of poses){
  const w=pose.r[2],h=pose.r[3],c=createCanvas(w,h),q=c.getContext('2d');q.drawImage(img,...pose.r,0,0,w,h);
  const pixels=q.getImageData(0,0,w,h),d=pixels.data,seen=new Uint8Array(w*h);
  // Remove tiny disconnected neighbouring-cell fragments from the display copy.
  for(let n=0;n<w*h;n++)if(!seen[n]&&d[n*4+3]>8){
   const queue=[n];seen[n]=1;let at=0;
   while(at<queue.length){const a=queue[at++],x=a%w,y=Math.floor(a/w);
    for(const b of [x? a-1:-1,x<w-1?a+1:-1,y?a-w:-1,y<h-1?a+w:-1])if(b>=0&&!seen[b]&&d[b*4+3]>8){seen[b]=1;queue.push(b);}
   }
   if(queue.length<450)for(const a of queue)d[a*4+3]=0;
  }
  q.putImageData(pixels,0,0);pose.image=c;
 }
}
const strokeEpisodes=[[1.21,1.65,'p'],[1.23,1.65,'e'],[2.23,2.50,'p'],[2.23,2.50,'e'],[3.10,3.40,'p'],[3.10,3.40,'e'],[3.96,4.35,'p']];
function brush(ctx,t,start,end,side){
 const progress=clamp((t-start)/(end-start)),fade=1-clamp((t-end)/.31);if(t<start||fade<=0)return;
 const finish=geometry(state(Math.min(t,end))),tip=side==='p'?finish.pt:finish.et;
 const origin=geometry(state(start)),old=side==='p'?origin.pt:origin.et;
 const ctrl=[(old[0]+tip[0])/2+(side==='p'?110:-90),Math.min(old[1],tip[1])-85];
 const curve=u=>{const a=1-u;return [a*a*old[0]+2*a*u*ctrl[0]+u*u*tip[0],a*a*old[1]+2*a*u*ctrl[1]+u*u*tip[1]];};
 ctx.save();ctx.globalAlpha=.72*fade;
 const edge=[];
 for(let k=0;k<=34;k++){const u=1-progress+progress*k/34,p=curve(u),p2=curve(Math.min(1,u+.01)),dx=p2[0]-p[0],dy=p2[1]-p[1],norm=Math.hypot(dx,dy)||1,width=(1+10*Math.sin(Math.PI*k/34))*(.7+rand(k+4)*.3);edge.push([p[0],p[1],-dy/norm*width,dx/norm*width]);}
 ctx.fillStyle=side==='p'?'#1c231f':'#40514a';ctx.beginPath();
 edge.forEach((p,i)=>{if(!i)ctx.moveTo(p[0]+p[2],p[1]+p[3]);else ctx.lineTo(p[0]+p[2],p[1]+p[3]);});
 for(const p of [...edge].reverse())ctx.lineTo(p[0]-p[2],p[1]-p[3]);ctx.closePath();ctx.fill();
 for(let br=0;br<17;br++){
  const shift=(br-8)*1.4;ctx.beginPath();
  for(let k=0;k<=34;k++){const u=1-progress+progress*k/34,p=curve(u),j=(rand(br*13+k)-.5)*2,x=p[0]+shift,y=p[1]+shift*.48+j;if(!k)ctx.moveTo(x,y);else ctx.lineTo(x,y);}
  ctx.strokeStyle=br%5===0?'#5b6258':side==='p'?'#161b1a':'#435555';ctx.lineWidth=br%4===0?2.6:1;ctx.stroke();
 }
 const head=curve(1);
 for(let n=0;n<13;n++){let a=rand(n+51)*Math.PI*2,rad=4+rand(n+24)*32;ctx.fillStyle='#242b28';ctx.globalAlpha=.5*fade;ctx.beginPath();ctx.ellipse(head[0]+Math.cos(a)*rad,head[1]+Math.sin(a)*rad*.45,.7+rand(n)*1.9,.8,a,0,Math.PI*2);ctx.fill();}
 ctx.restore();
}
const contacts=[1.65,2.50,3.40],contactChecks=[];
function impact(ctx,t){
 for(let ci=0;ci<contacts.length;ci++){
  const when=contacts[ci],dt=t-when;if(dt<0||dt>.38)continue;
  const g=geometry(state(when)),hit=segmentCross(g.ph,g.pt,g.eh,g.et);if(!hit)continue;
  const [x,y]=hit,fade=1-dt/.38;ctx.save();
  for(let n=0;n<19;n++){
   const a=rand(ci*100+n)*Math.PI*2,len=(10+rand(n+18)*47)*(dt/.38+.12);
   ctx.strokeStyle=n%4===0?'rgba(155,121,63,'+(fade*.9)+')':'rgba(26,31,27,'+(fade*.8)+')';
   ctx.lineWidth=n%3===0?2:1;ctx.beginPath();ctx.moveTo(x+Math.cos(a)*len*.36,y+Math.sin(a)*len*.36);ctx.lineTo(x+Math.cos(a)*len,y+Math.sin(a)*len);ctx.stroke();
  }
  ctx.globalAlpha=fade;ctx.strokeStyle='#fffae8';ctx.lineWidth=3;ctx.beginPath();ctx.moveTo(x-10,y-14);ctx.lineTo(x+10,y+14);ctx.moveTo(x-14,y+8);ctx.lineTo(x+14,y-8);ctx.stroke();ctx.restore();
 }
}
function label(t){
 if(t<.90)return ['행동설계','서로의 수를 읽다','다가서기  →  검을 맞대기  →  빈틈을 잇기'];
 if(t<1.65)return ['전투진행','검끝이 먼저 길을 그린다','발을 딛고 · 몸을 낮추고 · 같은 접점으로'];
 if(t<2.28)return ['전투진행','첫 격돌','받아낸 힘을 거두어 다음 검로로 잇는다'];
 if(t<3.14)return ['전투진행','되받아치는 검','짧은 멈춤 뒤, 역방향으로 다시 흐른다'];
 if(t<3.80)return ['전투진행','합이 갈리다','검을 맞댄 축을 유지하며 상대의 검을 밀어낸다'];
 if(t<4.60)return ['전투진행','합 승리  ·  공격으로 연결','열린 틈을 따라 먹의 궤적이 한 번 더 흐른다'];
 if(t<6.05)return ['전투진행','검을 거두고, 다음 수로','승자는 중심을 정리하고 · 상대는 자세를 회복한다'];
 return ['행동설계','다시, 서로의 수를 읽다','먹은 흩어지고 · 안개 속에서 다음 계획을 기다린다'];
}
async function main(){
 fs.mkdirSync(OUT,{recursive:true});
 const fontPath=process.env.KOREAN_FONT||'C:/Windows/Fonts/malgun.ttf';if(fs.existsSync(fontPath))GlobalFonts.registerFromPath(fontPath,'Korean');
 const serif='C:/Windows/Fonts/batang.ttc';if(fs.existsSync(serif))GlobalFonts.registerFromPath(serif,'Book');
 const [bg,p,e]=await Promise.all(['background.png','player-poses.png','opponent-poses.png'].map(f=>loadImage(path.join(HERE,f))));
 prepareAtlas(p,P);prepareAtlas(e,E);
 const canvas=createCanvas(W,H),ctx=canvas.getContext('2d'),frames=[];
 contacts.forEach(time=>{const g=geometry(state(time));contactChecks.push({time,intersection:segmentCross(g.ph,g.pt,g.eh,g.et),...g});});
 if(contactChecks.some(x=>!x.intersection))throw new Error('A blade contact is not aligned: '+JSON.stringify(contactChecks));
 const samples=new Set([0,41,62,85,106,132,182]);
 for(let f=0;f<FPS*SECONDS;f++){
  const t=f/FPS,s=state(t),[stage,title,sub]=label(t);ctx.fillStyle='#eee9de';ctx.fillRect(0,0,W,H);ctx.drawImage(bg,0,0,W,720);
  ctx.save();let shake=0;for(const hit of contacts)if(t>=hit&&t<hit+.16)shake=2*Math.sin((t-hit)*80)*(1-(t-hit)/.16);ctx.translate(shake,0);
  for(let i=0;i<3;i++){const x=220+i*360+Math.sin(t*.35+i)*18;let fog=ctx.createRadialGradient(x,370,5,x,370,235);fog.addColorStop(0,'rgba(249,247,239,.08)');fog.addColorStop(1,'rgba(249,247,239,0)');ctx.fillStyle=fog;ctx.fillRect(x-240,220,480,300);}
  for(const [x,y,r] of [[s.ex,s.ey,61],[s.px,s.py,72]]){ctx.fillStyle='rgba(20,24,20,.11)';ctx.beginPath();ctx.ellipse(x,y,r,9,0,0,Math.PI*2);ctx.fill();}
  const breathe=t<.9||t>6.05?Math.sin(t*3)*1.25:0;drawActor(ctx,e,E[s.e],s.ex,s.ey+breathe,.79,s.er);
  if((t>1.28&&t<1.48)||(t>4.04&&t<4.20))drawActor(ctx,p,P[s.p],s.px-22,s.py,.87,s.pr,.10);
  drawActor(ctx,p,P[s.p],s.px,s.py+breathe,.87,s.pr);
  for(const [start,end,side] of strokeEpisodes)brush(ctx,t,start,end,side);impact(ctx,t);ctx.restore();
  ctx.fillStyle='rgba(242,237,225,.95)';ctx.fillRect(0,0,W,72);ctx.strokeStyle='#8e8878';ctx.lineWidth=1;ctx.beginPath();ctx.moveTo(32,72);ctx.lineTo(W-32,72);ctx.stroke();
  ctx.fillStyle='#212620';ctx.font='bold 24px Book,Korean';ctx.fillText('십보강호',38,43);ctx.font='18px Korean';ctx.fillStyle='#52594e';ctx.fillText('먹으로 잇는 합',183,42);
  ctx.textAlign='right';ctx.font='17px Korean';ctx.fillText(stage,W-38,42);ctx.textAlign='left';
  ctx.fillStyle='rgba(241,235,222,.97)';ctx.fillRect(0,628,W,92);ctx.fillStyle='#242923';ctx.fillRect(33,644,4,53);
  ctx.font='bold 22px Book,Korean';ctx.fillText(title,52,666);ctx.font='16px Korean';ctx.fillStyle='#555c51';ctx.fillText(sub,52,696);
  ctx.textAlign='right';ctx.font='13px Korean';ctx.fillStyle='#777c70';ctx.fillText('전투 · 연출 시안 01',W-32,663);ctx.fillText('화풍 8 + 대비 3 + 안개 9',W-32,691);ctx.textAlign='left';
  ctx.fillStyle='#8a4032';ctx.fillRect(0,H-3,W*f/(FPS*SECONDS-1),3);
  const buffer=canvas.toBuffer('image/png'),name=String(f).padStart(4,'0')+'.png';fs.writeFileSync(path.join(OUT,name),buffer);
  if(samples.has(f)){const qa=path.join(OUT,'..','qa');fs.mkdirSync(qa,{recursive:true});fs.writeFileSync(path.join(f===41?HERE:qa,'contact-'+f+'.png'),buffer);}
  frames.push({frame:f,time:t,p:s.p,e:s.e,sha256:crypto.createHash('sha256').update(buffer).digest('hex')});
 }
 fs.writeFileSync(path.join(HERE,'render-check.json'),JSON.stringify({method:'OFFLINE_KEYPOSE_CHOREOGRAPHY_NOT_GAME_CAPTURE',fps:FPS,seconds:SECONDS,size:[W,H],frames:frames.length,distinct_frames:new Set(frames.map(f=>f.sha256)).size,contacts:contactChecks,frames_directory:path.relative(ROOT,OUT).replaceAll('\\','/'),frames},null,2)+'\n');
 console.log(JSON.stringify({frames:frames.length,output:OUT,contacts:contactChecks.map(x=>({time:x.time,point:x.intersection}))}));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
