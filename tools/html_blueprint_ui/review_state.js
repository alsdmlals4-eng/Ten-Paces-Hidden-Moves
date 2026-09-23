/* One serialized writer per page. No rendering, navigation or game rules here. */
class ReviewAutosave {
 constructor({read,write,persist,notify,changed,drafts={},delay=800}){
  Object.assign(this,{read,write,persist,notify,changed,delay});
  this.document={revision:0,items:{}};this.loaded=false;this.loading=null;this.active=null;
  this.drafts=new Map(Object.entries(drafts));this.states=new Map();this.timers=new Map();
 }
 last(id){return this.document.items[id]?.at(-1);}
 equal(a,b){return !!a&&!!b&&['status','comment','fingerprint','source_revision'].every(k=>a[k]===b[k]);}
 state(id,value,error=''){this.states.set(id,value);this.notify(id,value,error);}
 persistDrafts(){try{this.persist(Object.fromEntries(this.drafts));}catch(error){return error.message;}return '';}
 async load(){
  if(this.loading)return this.loading;
  this.loading=(async()=>{const value=await this.read(),draftIds=[...this.drafts.keys()],ids=this.accept(value,false),states=[];this.loaded=true;
   for(const [id,draft] of this.drafts){
    if(this.equal(draft,this.last(id))){this.drafts.delete(id);states.push([id,'saved']);}
    else if(draft.base_id!==(this.last(id)?.id??null))states.push([id,'conflict']);
    else {states.push([id,'pending']);this.schedule(id);}
   }this.persistDrafts();this.changed(this.document,[...new Set([...ids,...draftIds])]);
   for(const [id,state] of states)this.state(id,state);})();
  try{await this.loading;}finally{this.loading=null;}
 }
 accept(value,notify=true){
  if(value.project&&value.project!=='ten-paces-hidden-moves')throw Error('다른 프로젝트의 검토 응답입니다.');
  if(!Number.isInteger(value.revision)||!value.items)throw Error('검토 응답을 확인할 수 없습니다.');
  if(value.revision<this.document.revision)return [];
  const ids=[...new Set([...Object.keys(this.document.items),...Object.keys(value.items)])].filter(id=>JSON.stringify(this.document.items[id]||[])!==JSON.stringify(value.items[id]||[]));
  this.document=value;if(notify)this.changed(value,ids);return ids;
 }
 edit(id,entry,{compose=false}={}){
  const previous=this.drafts.get(id);
  const draft={...entry,base_id:previous?.base_id??this.last(id)?.id??null};
  // An explicit null base must remain null even after another writer creates the item.
  if(previous)draft.base_id=previous.base_id;
  this.drafts.set(id,draft);const error=this.persistDrafts();
  if(this.states.get(id)==='conflict'){this.state(id,'conflict');return;}
  this.state(id,error?'temporary-error':'pending',error);
  clearTimeout(this.timers.get(id));this.timers.delete(id);
  if(!compose)this.schedule(id);
 }
 schedule(id,delay=this.delay){clearTimeout(this.timers.get(id));this.timers.set(id,setTimeout(()=>{this.timers.delete(id);void this.flush(id);},delay));}
 retry(id){const draft=this.drafts.get(id);if(!draft)return;draft.base_id=this.last(id)?.id??null;this.state(id,'pending');this.persistDrafts();this.schedule(id,0);}
 cancelTimers(){for(const timer of this.timers.values())clearTimeout(timer);this.timers.clear();}
 async flush(only=null){
  if(only){clearTimeout(this.timers.get(only));this.timers.delete(only);}else this.cancelTimers();
  if(this.active){await this.active;return this.flush(only);}
  if(!this.loaded)return;
  const ids=only?[only]:[...this.drafts.keys()];
  this.active=(async()=>{for(const id of ids){
   const draft=this.drafts.get(id);if(!draft||this.states.get(id)==='conflict')continue;
   if(this.equal(draft,this.last(id))){this.drafts.delete(id);this.state(id,'saved');this.persistDrafts();this.changed(this.document,[id]);continue;}
   if(draft.base_id!==(this.last(id)?.id??null)){this.state(id,'conflict');continue;}
   this.state(id,'saving');
   try{
    let result;
    for(let attempt=0;attempt<2;attempt++){
     try{result=await this.write({...draft,item_id:id,revision:this.document.revision});break;}
     catch(error){
      if(error.status!==409||attempt)throw error;
      this.accept(await this.read());
      if(this.equal(draft,this.last(id))){result=this.document;break;}
      if(draft.base_id!==(this.last(id)?.id??null)){this.state(id,'conflict');break;}
     }
    }
    if(!result)continue;
    const changedIds=this.accept(result,false);
    if(this.drafts.get(id)===draft){this.drafts.delete(id);this.state(id,'saved');}
    else {this.drafts.get(id).base_id=this.last(id)?.id??null;this.state(id,'pending');}
    this.persistDrafts();
    this.changed(this.document,[...new Set([...changedIds,id])]);
   }catch(error){this.state(id,'error',error.message);}
  }})();
  try{await this.active;}finally{this.active=null;}
 }
}
if(typeof module!=='undefined')module.exports={ReviewAutosave};
