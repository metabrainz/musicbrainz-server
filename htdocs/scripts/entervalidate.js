function Relationship(_1){
this.CN="Relationship";
this.GID="rel";
if(_1==null){
_1={};
}
this.nodeid=_1.nodeid?_1.nodeid:"*";
this.typeid=_1.typeid?_1.typeid:0;
this.mp=_1.mp?_1.mp:0;
this.begindate=_1.begindate?_1.begindate:"";
this.enddate=_1.enddate?_1.enddate:"";
this.attr=_1.attr?_1.attr:[];
this.entitytype=_1.rtype?_1.rtype:null;
this.entity={};
this.entity.id=_1.rid?_1.rid:null;
this.entity.name=_1.rname?_1.rname:null;
this.entity.resolution="";
this.getEntityType=function(){
return this.entitytype;
};
this.getEntity=function(){
return this.entity;
};
this.getEntityId=function(){
return this.entity.id;
};
this.getEntityName=function(){
return this.entity.name;
};
this.getEntityResolution=function(){
return this.entity.resolution;
};
this.setEntityType=function(v){
this.entitytype=v;
};
this.setEntity=function(v){
this.entity=v;
};
this.getNodeId=function(){
return this.nodeid;
};
this.getTypeId=function(){
return this.typeid;
};
this.setNodeId=function(v){
this.nodeid=v;
};
this.setTypeId=function(v){
this.typeid=v;
};
this.isModPending=function(){
return this.mp;
};
this.getBeginDate=function(){
return this.begindate;
};
this.getEndDate=function(){
return this.enddate;
};
this.isModPending=function(){
return this.mp;
};
this.getAttributeList=function(){
return this.attr;
};
this.setBeginDate=function(v){
this.begindate=v;
};
this.setEndDate=function(v){
this.enddate=v;
};
this.setModPending=function(v){
this.mp=v;
};
this.getType=function(){
return rel_types[this.typeid];
};
this.editstate=false;
this.setEditState=function(f){
this.editstate=f;
};
this.getEditState=function(){
return this.editstate;
};
this.getPhrase=function(){
var rt,phrase=null;
if((rt=this.getType())!=null){
phrase=rt.phrase;
}
return phrase;
};
this.getAttributesByType=function(){
mb.log.enter(this.GID,"getAttributesByType");
if(!this.attr_by_type){
var _b=[];
if(this.attr&&this.attr.length>0){
for(var k=this.attr.length-1;k>=0;k--){
var id=this.attr[k];
var _e=false;
var _f=id;
var _10=rel_attrs[_f];
if(_10){
_b[_10.name]=_10.name;
_e=true;
mb.log.trace("Simple: id: $, name: $",_f,_10.name);
}else{
for(var l=rel_attrs.list.length-1;l>=0;l--){
_f=rel_attrs.list[l];
_10=rel_attrs[_f];
if(_10){
if(_10.children){
var _12=_10.children[id];
if(_12){
if(_b[_10.name]==null){
_b[_10.name]=[];
}
_e=true;
_b[_10.name].push(_12.name);
mb.log.trace("Child: id: $, category: $, name: $",id,_10.name,_12.name);
}
}
}
}
}
if(!_e){
mb.log.error("attribute id: $ does not exist!",id);
}
}
}
this.attr_by_type=_b;
}
mb.log.exit();
return this.attr_by_type;
};
this.getAttribute=function(_13){
mb.log.enter(this.GID,"getAttribute");
var _14=this.getAttributesByType();
var _15=null;
if(_14){
_15=_14[_13];
}
mb.log.trace("type: $, value: $",_13,_15);
mb.log.exit();
return _15;
};
this.getDisplayPhrase=function(){
mb.log.enter(this.GID,"getDisplayPhrase");
var _16,rt;
if((rt=this.getType())!=null){
var _17=rt.phrase;
var _18=_17.split(" ");
for(var j=0;j<_18.length;j++){
var _1a=_18[j];
if(_1a.match(/^\{[^\}]+\}$/)){
var _1b=_1a.replace(/\{|\}/g,"");
_1b=_1b.replace(/ly$/i,"");
var _1c=this.getAttribute(_1b);
var _1d="";
if(_1c){
if(mb.utils.isArray(_1c)){
_1d="";
if(_1c.length==1){
_1d=_1c[0];
}else{
if(_1c.length==2){
_1d=_1c.join(" and ");
}else{
_1d="and "+_1c[_1c.length-1];
delete _1c[_1c.length-1];
_1d=_1c.join(", ")+_1d;
}
}
}else{
_1d=_1a.replace(/\{|\}/g,"");
}
mb.log.trace("Type $ defined... value: $, replace: $",_1b,_1c,_1d);
}else{
mb.log.trace("Type $ not defined, removed from phrase",_1b);
}
_17=_17.replace(_1a,_1d);
}
}
_16=_17.replace(/(\s+)on$/,"");
}else{
_16="RelationShipType id="+this.typeid+" not found!";
}
mb.log.exit();
return _16;
};
this.getDisplayHiddenFields=function(_1e,_1f,_20){
mb.log.enter(this.GID,"getDisplayHiddenFields");
var s=[];
s.push(this.getHiddenField(_1e,"nodeid",this.getNodeId(),_1f,_20));
s.push(this.getHiddenField(_1e,"typeid",this.getTypeId(),_1f,_20));
s.push(this.getHiddenField(_1e,"rtype",this.getEntityType(),_1f,_20));
s.push(this.getHiddenField(_1e,"rid",this.getEntityId(),_1f,_20));
s.push(this.getHiddenField(_1e,"rname",this.getEntityName(),_1f,_20));
s.push(this.getHiddenField(_1e,"rresolution",this.getEntityResolution(),_1f,_20));
s.push(this.getHiddenField(_1e,"begindate",this.getBeginDate(),_1f,_20));
s.push(this.getHiddenField(_1e,"enddate",this.getEndDate(),_1f,_20));
for(var i=0;i<this.attr.length;i++){
s.push(this.getHiddenField(_1e,"attr",this.attr[i],_1f,_20,i));
}
mb.log.exit();
return s.join("");
};
this.getEditHiddenFields=function(_23,_24,_25){
mb.log.enter(this.GID,"getEditHiddenFields");
var s=[];
s.push(this.getHiddenField(_23,"nodeid",this.getNodeId(),_24,_25));
s.push(this.getHiddenField(_23,"rtype",this.getEntityType(),_24,_25));
s.push(this.getHiddenField(_23,"rid",this.getEntityId(),_24,_25));
s.push(this.getHiddenField(_23,"rname",this.getEntityName(),_24,_25));
s.push(this.getHiddenField(_23,"rresolution",this.getEntityResolution(),_24,_25));
mb.log.exit();
return s.join("");
};
this.getHiddenField=function(_27,_28,_29,_2a,_2b,_2c){
mb.log.enter(this.GID,"getHiddenField");
var s=[];
s.push("<input type=\"hidden\" name=\"");
s.push(this.getFieldName(_27,_28,_2a,_2b,_2c));
s.push("\" value=\"");
s.push(_29);
s.push("\" />");
mb.log.exit();
return s.join("");
};
this.getFieldName=function(_2e,_2f,_30,_31,_32){
mb.log.enter(this.GID,"getFieldName");
_31=(_31!=null?_31:0);
_32=(_32!=null?_32:-1);
var fn="";
if(_2e=="album_rel"){
fn="al_rel"+_30+"_"+_2f;
}else{
if(_2e=="track_rel"){
fn="tr"+_30+"_rel"+_31+"_"+_2f;
}else{
mb.log.error("unhandled type: $",_2e);
mb.log.error("  other parameters: name: $, index: $, subindex: $, subseq: $",_2f,_30,_31,_32);
}
}
if(_32!=-1){
fn+=_32;
}
mb.log.exit();
return fn;
};
this.toString=function(){
return "Relationship [id="+this.nodeid+", type="+this.getPhrase()+"]";
};
}
function RelationShipsFieldParser(){
this.CN="RelationShipsFieldParser";
this.GID="rsfp";
this._rel=new Relationship();
this.fields=["nodeid|0","mp|0","rid|1","rname|1","rtype|1","begindate|0","enddate|0","attr|0"];
this.getValue=function(_34,_35,_36,_37,_38,_39){
mb.log.enter(this.GID,"getValue");
var fn=this._rel.getFieldName(_35,_36,_37,_38,_39);
var _3b=null;
if((obj=es.ui.getField(fn,true))!=null){
if(obj.value){
_3b=obj.value;
mb.log.trace("$$=$",fn,_34?"*":"",_3b);
if(obj.parentNode){
obj.parentNode.removeChild(obj);
}
}else{
if(_34){
mb.log.error("Found fn: $, but does not define 'value' property",fn);
}
}
}else{
if(_34){
mb.log.error("Did not find fn: $",fn);
}else{
mb.log.trace("Did not find fn: $",fn);
}
}
mb.log.exit();
return _3b;
};
this.loadRelationship=function(_3c,_3d,_3e){
mb.log.enter(this.GID,"loadRelationship");
var rel;
var _40=false,value=null;
var _41=this.getValue(false,_3c,"typeid",_3d,_3e);
if(_41==null){
}else{
var _42={"typeid":_41};
for(var i=0;i<this.fields.length;i++){
var _44=this.fields[i];
var cf=_44.split("|")[0];
var _46=(_44.split("|")[1]=="1");
_42[cf]=null;
if(cf=="attr"){
var _47=[];
for(var _48=0;;_48++){
if((value=this.getValue(_46,_3c,"attr",_3d,_3e,_48))!=null){
_47.push(value);
}else{
break;
}
}
_42[cf]=_47;
}else{
if((value=this.getValue(_46,_3c,cf,_3d,_3e))!=null){
_42[cf]=value;
}
}
if(_42[cf]==null&&_46){
mb.log.error("Required field: $ is missing",cf);
_40=true;
break;
}
}
if(!_40){
rel=new Relationship(_42);
}
mb.log.trace("type: $, index: $, subindex: $, rel: $",_3c,_3d,_3e,rel);
}
mb.log.exit();
return rel;
};
}
function RelationShipsEditor(){
this.CN="RelationShipsEditor";
this.GID="rse";
this._initialised=false;
this._visible=false;
this._initialising=false;
this._trackrel=[];
this._albumrel=[];
this._rsfp=new RelationShipsFieldParser();
this.linkable_entities=["Artist","Album","Track","Url"];
this.initialise=function(){
mb.log.enter(this.GID,"initialise");
if(!this._initialising){
this._initialising=true;
var _49=true,rel,index,subindex;
this._albumrel=[];
this._trackrel=[];
for(index=0;_49;index++){
if((_49=((rel=this._rsfp.loadRelationship("album_rel",index))!=null))){
this._albumrel[index]=rel;
}
}
var _4a=ae.getTracks();
for(index=0;index<_4a;index++){
_49=true;
this._trackrel[index]=[];
for(subindex=0;_49;subindex++){
if((_49=((rel=this._rsfp.loadRelationship("track_rel",index,subindex))!=null))){
this._trackrel[index][subindex]=rel;
}
}
}
this.writeUI(_4a);
this._initialised=true;
}
mb.log.exit();
};
this.isInitialised=function(){
return this._initialised;
};
this.removeRelationship=function(el,_4c,_4d,_4e){
mb.log.enter(this.GID,"removeRelationship");
if(el!=null&&_4d!=null){
var _4f;
_4f=(_4c=="album_rel"?this._albumrel:_4f);
_4f=(_4c=="track_rel"?this._trackrel[_4d]:_4f);
if(_4f){
var obj,id=ae.getFieldId(_4c,"newrel",_4d,_4e);
if((obj=mb.ui.get(id))!=null){
if(obj.parentNode){
obj.parentNode.removeChild(obj);
if(_4c=="album_rel"){
delete this._albumrel[_4d];
}else{
if(_4c=="track_rel"){
delete this._trackrel[_4d][_4e];
}else{
mb.log.error("unhandled type: $",_4c);
}
}
}else{
mb.log.error("object id: $ does not define parentNode",id);
}
}else{
mb.log.error("did not find object id: $",id);
}
}else{
mb.log.error("Did not find relationships, type: $",_4c);
}
}
mb.log.exit();
return false;
};
this.addRelationship=function(el,_52,_53){
mb.log.enter(this.GID,"addRelationship");
if(el!=null&&_53!=null){
var _54=null,subindex=null;
if(_52=="album_rel"){
_54=this._albumrel;
_53=_54.length;
subindex=0;
}else{
if(_52=="track_rel"){
_54=this._trackrel[_53];
subindex=_54.length;
}
}
if(_54!=null&&subindex!=null){
var td,tr,tbody=null;
if((td=el.parentNode)!=null&&td.nodeName&&td.nodeName.toLowerCase()=="td"){
if((tr=td.parentNode)!=null&&tr.nodeName&&tr.nodeName.toLowerCase()=="tr"){
if((tbody=tr.parentNode)!=null&&tbody.nodeName&&tbody.nodeName.toLowerCase()=="tbody"){
var rel=new Relationship();
rel.setEditState(true);
_54.push(rel);
var _57=document.createElement("tr");
_57.setAttribute("id",ae.getFieldId(_52,"newrel",_53,subindex));
var _58=document.createElement("td");
_58.setAttribute("width","18");
_58.innerHTML="&nbsp;";
var _59=document.createElement("td");
_59.setAttribute("width","18");
_59.innerHTML=this.getRemoveIcon(_52,_53,subindex);
var _5a=document.createElement("td");
_5a.setAttribute("width","18");
_5a.setAttribute("id",ae.getFieldId(_52,"entityicon",_53,subindex));
_5a.innerHTML=ae.getEntityTypeIcon("unknown");
var _5b=document.createElement("td");
_5b.setAttribute("width","400");
_5b.setAttribute("id",ae.getFieldId(_52,"rel",_53,subindex));
_5b.innerHTML=this.getEditUI(_52,rel,_53,subindex);
_57.appendChild(_58);
_57.appendChild(_59);
_57.appendChild(_5a);
_57.appendChild(_5b);
tbody.insertBefore(_57,tr);
_57.valign="top";
_57.style.verticalAlign="top";
}else{
mb.log.error("Unexpected parentNode, expected tbody, got: "+(tbody?tbody.nodeName:"?"));
}
}else{
mb.log.error("Unexpected parentNode, expected tr, got: "+(tr?tr.nodeName:"?"));
}
}else{
mb.log.error("Unexpected parentNode, expected td, got: "+(td?td.nodeName:"?"));
}
}else{
mb.log.error("Did not find relationships for track "+_53+"/"+subindex);
}
}else{
mb.log.error("Elements el/index not given, aborting");
}
mb.log.exit();
return false;
};
this.getRemoveIcon=function(_5c,_5d,_5e){
mb.log.enter(this.GID,"getRemoveIcon");
var s=[];
s.push("<a href=\"#\" title=\"Remove this relationship\" ");
s.push("onClick=\"return rse.removeRelationship(this, "+ae.toParamStrings([_5c,_5d,_5e])+");\">");
s.push("<img src=\"/images/es/remove.gif\" ");
s.push("alt=\"\" /></a>");
mb.log.exit();
return s.join("");
};
this.onRelTypeChanged=function(el){
mb.log.enter(this.GID,"onRelTypeChanged");
if(el&&el.options){
var id=(el.id||"");
if(id.match(/(album|track)_rel\|newtype\|\d+\|\d+/)){
var rel,conf=id.split("|");
var _63,index,subindex;
if((_63=conf[0])!=null&&(index=conf[2])!=null&&(subindex=conf[3])!=null&&(rel=this.findRelationship(_63,index,subindex))!=null){
var nt=el.options[el.selectedIndex].value;
rel.setTypeId(nt);
this.updateUI(_63,rel,index,subindex,true);
}
}else{
mb.log.error("Unexpected element id: $",id);
}
}else{
mb.log.error("Element el: $ does not define options",el);
}
mb.log.exit();
};
this.updateRelationshipEntity=function(_65,_66,_67,_68,_69){
mb.log.enter(this.GID,"updateRelationshipEntity");
if((rel=this.findRelationship(_65,_66,_67))!=null){
rel.setEntityType(_68);
rel.setEntity(_69);
this.updateUI(_65,rel,_66,_67,false);
}
mb.log.exit();
};
this.onToggleEditorClicked=function(_6a,_6b,_6c){
mb.log.enter(this.GID,"onToggleEditorClicked");
var rel;
if((rel=this.findRelationship(_6a,_6b,_6c))!=null){
rel.setEditState(!rel.getEditState());
this.updateUI(_6a,rel,_6b,_6c,false);
}
mb.log.exit();
return false;
};
this.findRelationship=function(_6e,_6f,_70){
mb.log.enter(this.GID,"findRelationship");
var rel,list;
if(_6e=="track_rel"){
list=this._trackrel[_6f];
if(list){
if((rel=list[_70])==null){
mb.log.error("No relationship found at subindex: $",_70);
}
}
}else{
if(_6e=="album_rel"){
list=this._albumrel;
if((rel=list[_6f])==null){
mb.log.error("No relationship found at index: $",_6f);
}
}else{
mb.log.error("unhandled type: $",_6e);
}
}
mb.log.exit();
return rel;
};
this.showUI=function(_72){
var id,obj,tracks=ae.getTracks();
for(var _74=0;_74<tracks;_74++){
id=ae.getFieldId("track","relationship",_74);
if((obj=mb.ui.get(id))!=null){
obj.style.display=_72?"":"none";
}
}
id=ae.getFieldId("release","relationship","");
if((obj=mb.ui.get(id))!=null){
obj.style.display=_72?"":"none";
}
this._visible=_72;
};
this.isVisible=function(){
return this._visible;
};
this.updateUI=function(_75,rel,_77,_78,_79){
var _7a=ae.getFieldId(_75,_79?"rel_attr":"rel",_77,_78);
var _7b;
if((_7b=mb.ui.get(_7a))!=null){
var _7c=(rel.getEditState()?this.getEditUI(_75,rel,_77,_78,_79):this.getDisplayUI(_75,rel,_77,_78));
_7b.innerHTML=_7c;
_7b.style.display=(_7c==""?"none":"");
var _7d=ae.getFieldId(_75,"entityicon",_77,_78);
var _7e;
if((_7e=mb.ui.get(_7d))!=null){
_7e.innerHTML=ae.getEntityTypeIcon(rel.getEntityType());
}else{
mb.log.error("EntityIcon id: $ not found",_7d);
}
}else{
mb.log.error("RelationShipEditorUI id: $ not found",_7a);
}
};
this.writeUI=function(_7f){
mb.log.enter(this.GID,"writeUI");
var _80,index,obj;
if((obj=mb.ui.get("album_rel_div"))!=null){
var s=[];
s.push("<label class=\"label hidden\"></label>");
s.push("<input class=\"numberfield hidden\" readonly=\"readonly\" />");
s.push("<div class=\"float\">");
s.push("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"435\">");
list=this._albumrel;
_80=list?list.length:0;
for(index=0;index<_80;index++){
var rel=list[index];
s.push(this.getRelUI("album_rel",rel,index));
}
s.push(this.getAddRelUI("album_rel"));
s.push("</table>");
s.push("</div>");
obj.innerHTML=s.join("");
obj.style.display="";
}else{
mb.log.error("album_rel_div not found");
}
for(index=0;index<_7f;index++){
var _83=this._trackrel[index];
if((obj=mb.ui.get("tr"+index+"_rel_div"))!=null){
var s=[];
s.push("<label class=\"label hidden\"></label>");
s.push("<input class=\"numberfield hidden\" readonly=\"readonly\" />");
s.push("<div class=\"float\">");
s.push("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"435\">");
var _80=_83?_83.length:0;
if(_80){
for(var _84=0;_84<_80;_84++){
var rel=_83[_84];
s.push(this.getRelUI("track_rel",rel,index,_84));
}
}
s.push(this.getAddRelUI("track_rel",index));
s.push("</table>");
s.push("</div>");
s.push("<br/>");
obj.innerHTML=s.join("");
obj.style.display="";
}else{
mb.log.error("tr_[index]_rel_div not found for track: $",index);
}
}
mb.log.exit();
};
this.getAddRelUI=function(_85,_86){
mb.log.enter(this.GID,"getAddRelUI");
_86=(_86!=null?_86:"");
var s=[];
var _88="<a href=\"#\" title=\"Add new relationship\" "+"onClick=\"return rse.addRelationship(this, "+ae.toParamStrings([_85,_86])+");\" />";
s.push("<tr>");
s.push("<td valign=\"top\" width=\"18\">&nbsp;</td>");
s.push("<td valign=\"top\" width=\"18\">");
s.push(_88);
s.push("<img src=\"/images/es/create.gif\" border=\"0\" alt=\"Add new relationship\">");
s.push("</a></td>");
s.push("<td valign=\"top\" colspan=\"2\">");
s.push(_88);
s.push("Add new relationship</a></td>");
s.push("</tr>");
s.push("<tr><td colspan=\"4\">&nbsp;</td></tr>");
mb.log.exit();
return s.join("");
};
this.getRelUI=function(_89,rel,_8b,_8c,_8d){
mb.log.enter(this.GID,"getRelUI");
_89=(_89||"");
_8c=(_8c||0);
_8d=(_8d||false);
retval=null;
if(!_89.match(/track|album/)){
mb.log.error("Unhandled type: $",_89);
}else{
if(rel==null||!rel instanceof Relationship){
mb.log.error("Expected Relationship, but got $",rel);
}else{
if(parseInt(_8b)==NaN){
mb.log.error("index: $ is invalid, expected number",_8b);
}else{
if(parseInt(_8c)==NaN){
mb.log.error("subindex: $ is invalid, expected number",_8c);
}else{
var s=[];
mb.log.trace("type: $, rel: $, index: $, subindex: $, inneronly: $",_89,rel,_8b,_8c,_8d);
if(!_8d){
s.push("<tr "+(rel.isModPending()?"class=\"mp\"":""));
s.push(">");
}
s.push("<td valign=\"top\" width=\"18\">");
s.push("<input type=\"checkbox\" class=\"checkbox\" ");
if(mb.ua.ie){
s.push("style=\"margin-top: -3px; margin-left: -3px; margin-right: 1px;\"");
}
s.push("name=\"");
s.push(rel.getFieldName(_89,"del",_8b,_8c));
s.push("\" value=\"1\" ");
s.push("title=\"Tick this checkbox to delete this relationship\" /></td>");
s.push("<td valign=\"top\" width=\"18\">");
s.push("<a href=\"#\" title=\"Toggle Relationship Editor\" ");
s.push("onClick=\"return rse.onToggleEditorClicked(");
s.push(ae.toParamStrings([_89,_8b,_8c]));
s.push(");\" />");
s.push("<img src=\"/images/es/edit.gif\" border=\"0\" alt=\"Edit this relationship\">");
s.push("</a></td>");
s.push("<td valign=\"top\" width=\"18\" id=\"");
s.push(ae.getFieldId(_89,"entityicon",_8b,_8c));
s.push("\">");
s.push(ae.getEntityTypeIcon(rel.getEntityType()));
s.push("</td>");
s.push("<td id=\"");
s.push(ae.getFieldId(_89,"rel",_8b,_8c));
s.push("\">");
s.push(rel.getEditState()?this.getEditUI(_89,rel,_8b,_8c):this.getDisplayUI(_89,rel,_8b,_8c));
s.push("</td>");
if(!_8d){
s.push("</tr>");
}
retval=s.join("");
}
}
}
}
mb.log.exit();
return retval;
};
this.getDisplayUI=function(_8f,rel,_91,_92){
mb.log.enter(this.GID,"getDisplayUI");
var s=[];
s.push("<a target=\"_blank\" href=\"/show");
s.push(rel.getEntityType().toLowerCase());
s.push(".html?");
s.push(rel.getEntityType().toLowerCase());
s.push("id=");
s.push(rel.getEntityId());
s.push("\">");
s.push(rel.getEntityName());
s.push("</a>");
s.push(" - ");
s.push(rel.getDisplayPhrase());
s.push("<span style=\"display: none\">");
s.push(rel.getDisplayHiddenFields(_8f,_91,_92));
s.push("</span>");
mb.log.exit();
return s.join("");
};
this.getEditUI=function(_94,rel,_96,_97,_98){
if(_98==null){
_98=false;
}
mb.log.enter(this.GID,"getEditUI");
var rt,j;
var s=[];
if((rt=rel.getType())!=null){
if(!_98){
s.push("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">");
s.push("<tr valign=\"top\">");
var _9b=rel.getEntityType()!=null;
var _9c=rel.getEntityName();
if(!_9b){
s.push("<td nowrap>");
s.push("<select id=\"");
s.push(ae.getFieldId(_94,"entitytype",_96,_97));
s.push("\">");
for(j=0;j<this.linkable_entities.length;j++){
var _9d=this.linkable_entities[j];
s.push("<option value=\""+_9d+"\">");
s.push(_9d);
s.push("</option>");
}
s.push("</select>");
s.push("</td><td>");
s.push("<input type=\"text\" id=\"");
s.push(ae.getFieldId(_94,"entityquery",_96,_97));
s.push("\" class=\"entityfield\" value=\"\" />");
s.push("</td><td>");
s.push("<input type=\"button\" value=\"Lookup\" onClick=\"ae.onLookupClicked("+ae.toParamStrings([_94,_96,_97])+");\" />");
s.push("</td>");
s.push("<td class=\"entitywarning\" id=\"");
s.push(ae.getFieldId(_94,"entitywarning",_96,_97));
s.push("\" nowrap>");
}
if(_9b){
s.push("<td nowrap>");
s.push("<a target=\"_blank\" href=\"/show");
s.push(rel.getEntityType().toLowerCase());
s.push(".html?");
s.push(rel.getEntityType().toLowerCase());
s.push("id=");
s.push(rel.getEntityId());
s.push("\">");
s.push(rel.getEntityName());
s.push("</a> &nbsp;");
s.push("</td><td>");
s.push("<select name=\"");
s.push(rel.getFieldName(_94,"typeid",_96,_97));
s.push("\" id=\"");
s.push(ae.getFieldId(_94,"newtype",_96,_97));
s.push("\" onChange=\"rse.onRelTypeChanged(this)\" onKeyUp=\"rse.onRelTypeChanged(this)\">");
for(j=0;j<rel_types.list.length;j++){
var rtj=rel_types[j];
s.push("<option value=\""+j+"\"");
if(j==rel.getTypeId()){
s.push(" selected ");
}
s.push(">");
s.push("           ".substring(0,rtj.indent).replace(/ /g,"&nbsp;&nbsp;"));
s.push(rtj.phrase);
s.push("</option>");
}
s.push("</select>");
}
s.push("</td>");
s.push("</tr>");
s.push("</table>");
}
var _9f=rt.attr;
s.push("<div id=\"");
s.push(ae.getFieldId(_94,"rel_attr",_96,_97));
s.push("\">");
if(_9f!=""){
s.push("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"margin-bottom: 4px\"><tr valign=\"top\">");
var arr=_9f.split(" ");
var _a1=[];
var _a2,id;
for(j=arr.length-1;j>=0;j--){
_9c=arr[j].split("=")[0];
if((id=rel_attrs[_9c])!=null){
if((_a2=rel_attrs[id])!=null){
_a1[id]=_a2;
}else{
mb.log.error("Did not find an attribute type with id: "+id);
}
}else{
mb.log.error("Did not find an attribute type with name: "+_9c);
}
}
var _a3=rel_attrs["displayorder"];
for(j=0;j<_a3.length-1;j++){
id=_a3[j];
if((_a2=_a1[id])!=null){
var _a4=rel.getAttribute(_9c);
s.push("<tr>");
s.push("<td>");
if(!_a2.children){
s.push("<input type=\"checkbox\" class=\"checkbox\" name=\"\" value=\"1\" ");
if(mb.ua.ie){
s.push("style=\"margin-top: -3px; margin-left: -3px; margin-right: 1px;\"");
}
if(_a4){
s.push(" checked=\"checked\" ");
}
s.push(" />");
}
s.push("</td>");
s.push("<td><a href=\"");
s.push(rel_attrs_help[_a2.name]?"http://wiki.musicbrainz.org/"+rel_attrs_help[_a2.name]:"#");
s.push("\" onmouseover=\"overlib('");
s.push(_a2.desc.replace(/&#39;/g,""));
s.push("')\" onmouseout=\"nd()\" target=\"_blank\">");
s.push("<img src=\"/images/es/help.gif\" border=\"0\" alt=\"\" /></a></td>");
s.push("<td width=\"100%\" valign=\"top\">");
if(_a2.children){
var _a5=_a2.children.list;
if(!_a4){
_a4=[0];
}
for(var vi=0;vi<_a4.length;vi++){
var _a7=_a4[vi];
s.push("<select>");
for(var li=0;li<_a5.length;li++){
var _a9=_a5[li];
var _aa=_a2.children[_a9];
s.push("<option value=\""+li+"\"");
if(_a7==_aa.name){
s.push(" selected ");
}
s.push(">");
s.push("           ".substring(0,_aa.indent).replace(/ /g,"&nbsp;&nbsp;"));
s.push(_aa.name);
s.push("&nbsp;&nbsp;");
s.push("</option>");
}
s.push("</select>");
}
}else{
s.push(_a2.name);
}
s.push("</td>");
s.push("</tr>");
}
}
s.push("</table>");
}
s.push("</div>");
s.push("<span style=\"display: none\">");
s.push(rel.getEditHiddenFields(_94,_96,_97));
s.push("</span>");
}else{
mb.log.error("RelationShipType id: $ not found!",rel.getTypeId());
}
mb.log.exit();
return s.join("");
};
}
var rse=new RelationShipsEditor();

