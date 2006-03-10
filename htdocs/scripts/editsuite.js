function EsButton(_1,_2,_3,_4){
mb.log.enter("EsButton","__constructor");
this.bid=_1;
this.value=_2;
this.tooltip=_3;
this.func=_4;
this.getID=function(){
return this.bid;
};
this.getValue=function(){
return this.value;
};
this.getTooltip=function(){
return this.tooltip;
};
this.getFunction=function(){
return this.func;
};
this.toString=function(){
var s=[];
s.push("EsButton [");
s.push("bid: '");
s.push(this.bid);
s.push("', value: '");
s.push(this.value);
s.push("', tooltip: '");
s.push(this.tooltip);
s.push("', func: '");
s.push(this.func);
s.push("']");
return s.join("");
};
mb.log.exit();
}
function EsModuleBase(){
this.CN="EsModuleBase";
this.GID="es.base";
mb.log.enter(this.CN,"__constructor");
this.getModID=function(){
return "es.base";
};
this.getModName=function(){
return "EsModuleBase";
};
this.getModKey=function(_6){
return this.getModID()+(_6||"");
};
this.CONFIG_LIST=[];
this.CONFIG_VALUES=[];
this.CONFIG_CHECKBOX=this.getModKey(".config");
this.DEFAULT_EXPANDED=false;
this.DEFAULT_VISIBLE=false;
this.uiAvailable=false;
this.setupModule=function(){
mb.log.enter(this.GID,"setupModule");
this.COOKIE_VISIBLE=this.getModKey(".visible");
this.COOKIE_EXPANDED=this.getModKey(".expanded");
this.CONFIG_LIST=(!this.CONFIG_LIST?[]:this.CONFIG_LIST);
this.CONFIG_VALUES=(!this.CONFIG_VALUES?[]:this.CONFIG_VALUES);
this.CONFIG_CHECKBOX=this.getModKey(".config");
this.configRead=false;
this.visible=null;
this.expanded=null;
for(var i=0;i<this.CONFIG_LIST.length;i++){
var cb=this.CONFIG_LIST[i];
this.setConfigValue(cb.getID(),cb.isDefaultOn());
}
this.setupModuleDelegate();
mb.log.exit();
};
this.setupModuleDelegate=function(){
};
this.getConfigFromUI=function(){
mb.log.enter(this.GID,"getConfigFromUI");
var _9=null;
if((_9=mb.ui.getByName(this.CONFIG_CHECKBOX))!=null){
var l=_9.length;
for(var i=0;i<l;i++){
var el=_9[i];
this.CONFIG_VALUES[el.id]=el.checked;
mb.log.debug("$ = $",el.id,el.checked);
}
}else{
mb.log.warning("Config checkboxes $ are null!",this.CONFIG_CHECKBOX);
}
this.getConfigFromUIDelegate();
mb.log.exit();
};
this.getConfigFromUIDelegate=function(){
};
this.onConfigurationChange=function(el){
mb.log.scopeStart("Handling click on config checkbox");
mb.log.enter(this.GID,"onConfigurationChange");
var _e=el.id,value=el.checked;
mb.cookie.set(_e,(value?"1":"0"),365);
this.setConfigValue(_e,value);
mb.log.exit();
mb.log.scopeEnd();
};
this.setConfigValue=function(_f,_10){
mb.log.enter(this.GID,"setConfigValue");
this.CONFIG_VALUES[_f]=_10;
mb.log.trace("Set $ = $",_f,_10);
mb.log.exit();
};
this.isConfigTrue=function(key){
mb.log.enter(this.GID,"isConfigTrue");
if(!this.CONFIG_VALUES[key]){
this.getConfigFromUI();
}
var o=(this.CONFIG_VALUES[key]||false);
mb.log.trace("$=$",key,o);
return mb.log.exit(o);
};
this.getConfigFromCookie=function(_13,_14){
mb.log.enter(this.GID,"getConfigFromCookie");
var cv=mb.cookie.getBool(_13);
var _16=(cv==null?"null":cv);
var f=((cv!=null&&cv)||(cv==null&&_14));
mb.log.trace("key: $ (default:$ || cookie:$) = $",_13,_14,_16,f);
return mb.log.exit(f);
};
this.onResetModuleClicked=function(){
mb.log.scopeStart("Handling click on Reset Module link");
mb.log.enter(this.GID,"onResetModuleClicked");
this.resetModule();
mb.log.exit();
mb.log.scopeEnd();
};
this.resetModule=function(){
mb.log.enter(this.GID,"resetModule");
mb.log.debug("Deleting configuration values...");
for(var i=this.CONFIG_LIST.length-1;i>=0;i--){
var cb=this.CONFIG_LIST[i];
mb.cookie.remove(cb.getID());
}
mb.log.debug("Deleting visible/expanded cookies...");
mb.cookie.remove(this.COOKIE_VISIBLE);
mb.cookie.remove(this.COOKIE_EXPANDED);
this.resetModuleDelegate();
mb.log.debug("Reset visible/expanded state...");
this.visible=null;
this.expanded=null;
this.setVisible();
return mb.log.exit();
};
this.resetModuleDelegate=function(){
};
this.isVisible=function(){
mb.log.enter(this.GID,"isVisible");
if(this.visible==null){
var f=this.getConfigFromCookie(this.COOKIE_VISIBLE,this.DEFAULT_VISIBLE);
this.visible=f;
}
return mb.log.exit(this.visible);
};
this.setVisible=function(_1b,_1c){
mb.log.enter(this.GID,"setVisible");
if(_1b!=null){
this.visible=_1b;
if(_1c||this.expanded==null){
if(this.visible){
this.setExpanded(true);
}else{
es.cfg.updateExpanded(this.getModID(),false);
}
}
mb.log.debug("New state: $",(this.visible?"visible":"hidden"));
mb.ui.setDisplay(this.getModKey("-tr-expanded"),this.visible&&this.expanded);
if(this!=es.cfg){
mb.ui.setDisplay(this.getModKey("-tr-collapsed"),this.visible&&!this.expanded);
mb.cookie.set(this.COOKIE_VISIBLE,(this.visible?"1":"0"),365);
es.cfg.updateVisible(this.getModID(),this.visible);
}
}else{
mb.log.debug("No flag given, reading from cookie/default value...");
this.setVisible(this.isVisible());
}
mb.log.exit();
};
this.onSetVisibleClicked=function(_1d){
mb.log.scopeStart("Handling click on Visible checkbox");
mb.log.enter(this.GID,"onSetVisibleClicked");
this.setVisible(_1d,_1d);
mb.log.exit();
mb.log.scopeEnd();
};
this.isExpanded=function(_1e){
mb.log.enter(this.GID,"isExpanded");
if(this.expanded==null){
var f=this.getConfigFromCookie(this.COOKIE_EXPANDED,this.DEFAULT_EXPANDED);
this.expanded=f;
}
return mb.log.exit(this.expanded);
};
this.setExpanded=function(_20){
mb.log.enter(this.GID,"setExpanded");
if(_20!=null){
mb.log.debug("New state: $",(_20?"expanded":"collapsed"));
this.expanded=_20;
mb.ui.setDisplay(this.getModKey("-tr-expanded"),this.visible&&this.expanded);
if(this!=es.cfg){
mb.ui.setDisplay(this.getModKey("-tr-collapsed"),this.visible&&!this.expanded);
mb.cookie.set(this.COOKIE_EXPANDED,(this.expanded?"1":"0"),365);
es.cfg.updateExpanded(this.getModID(),this.expanded);
}
}else{
mb.log.debug("No flag given, reading from cookie/default value...");
this.setExpanded(this.isExpanded());
}
mb.log.exit();
};
this.onSetExpandedClicked=function(_21){
mb.log.scopeStart("Handling click on Expanded checkbox");
mb.log.enter(this.GID,"onSetExpandedClicked");
this.setExpanded(_21);
mb.log.scopeEnd();
mb.log.exit();
};
this.getConfigHtml=function(){
mb.log.enter(this.GID,"getConfigHtml");
var s=[];
for(var i=0;i<this.CONFIG_LIST.length;i++){
var cb=this.CONFIG_LIST[i];
var _25=cb.getHelpText();
_25=_25.replace("'","?");
s.push("<input type=\"checkbox\" name=\"");
s.push(this.CONFIG_CHECKBOX);
s.push("\" id=\"");
s.push(cb.getID());
s.push("\" value=\"on\" ");
var _26=this.getConfigFromCookie(cb.getID(),cb.isDefaultOn());
s.push(_26?" checked=\"checked\" ":" ");
this.setConfigValue(cb.getID(),_26);
s.push("onChange=\"");
s.push(this.getModID());
s.push(".onConfigurationChange(this)\" ");
s.push(">");
s.push(cb.getDescription());
s.push("&nbsp; ");
s.push("[ <a href=\"javascript:; // help\" ");
s.push("onmouseover=\"return overlib('"+_25+"');\"");
s.push("onmouseout=\"return nd();\">help</a> ]<br/>");
}
return mb.log.exit(s.join(""));
};
this.getExpandButton=function(_27){
var s=[];
var _29=[];
_29.push(_27?"Expand":"Collapse");
_29.push(" "+this.getModName());
_29.push(" module");
s.push("<td class=\"toggle\">");
s.push("<a href=\"javascript:; // ");
s.push(_27?"expand":"collapse");
s.push("\" onClick=\"");
s.push(this.getModID());
s.push(".onSetExpandedClicked(");
s.push(_27?"true":"false");
s.push(")\" title=\"");
s.push(_29.join(""));
s.push("\" ><img src=\"/images/es/");
s.push(_27?"maximize":"minimize");
s.push(".gif\" width=\"13\" height=\"13\" alt=\"");
s.push(_29.join(""));
s.push("\" style=\"padding-left: 3px\" border=\"0\"></a>");
s.push("</td>");
return s.join("");
};
this.getCloseButton=function(){
var s=[];
var _2b=[];
_2b.push("Close");
_2b.push(" "+this.getModName());
_2b.push(" module");
s.push("<td class=\"toggle\">");
s.push("<a href=\"javascript:; // close");
s.push("\" onClick=\"");
s.push(this.getModID());
s.push(".onSetVisibleClicked(false)\" ");
s.push("title=\"");
s.push(_2b.join(""));
s.push("\"><img src=\"/images/es/");
s.push("close.gif\" width=\"13\" height=\"13\" alt=\"");
s.push(_2b.join(""));
s.push("\" style=\"padding-left: 3px\" border=\"0\"></a>");
s.push("</td>");
return s.join("");
};
this.getModuleStartHtml=function(c){
mb.log.enter(this.GID,"getModuleStartHtml");
var mv=this.isVisible();
var mx=this.isExpanded();
var _2f=(c.x?"expanded":"collapsed");
var _30="";
if(!mv){
_30="none";
}
if(mv&&mx&&!c.x){
_30="none";
}
if(mv&&!mx&&c.x){
_30="none";
}
var s=[];
s.push("<tr valign=\"top\" class=\"editsuite-box-tr\" id=\"");
s.push(this.getModID());
s.push("-tr-"+_2f+"\" ");
s.push(_30!=""?"style=\"display: "+_30+"\"":"");
s.push(">");
s.push("<td width=\"130\" nowrap><b>"+this.getModName()+":</b></td>");
s.push("<td width=\"100%\">");
if(!c.x){
var t=(c.dt||"");
if(mb.ua.ie){
s.push("<div style=\"padding-top: 2px\">");
}
s.push("<small><span id=\""+this.getModID()+"-text-collapsed\">"+t+"</span></small>");
if(mb.ua.ie){
s.push("</div>");
}
}
return mb.log.exit(s.join(""));
};
this.getModuleEndHtml=function(c){
mb.log.enter(this.GID,"getModuleEndHtml");
var s=[];
s.push("</td>");
s.push("<td>&nbsp;</td>");
s.push(this.getExpandButton(!c.x));
s.push(this.getCloseButton());
s.push("</tr>");
return mb.log.exit(s.join(""));
};
this.onModuleHtmlWritten=function(){
this.uiAvailable=true;
this.onModuleHtmlWrittenDelegate();
};
this.onModuleHtmlWrittenDelegate=function(){
};
this.isUIAvailable=function(){
return this.uiAvailable;
};
mb.log.exit();
}
EsModuleBase.prototype=new EsModuleBase;
function EsModuleConfig(id,_36,_37,_38){
mb.log.enter("EsModuleConfig","__constructor");
this.CN="EsModuleConfig";
this.id=id;
this.defaultOn=_36;
this.desc=_37;
this.helpText=_38;
this.getID=function(){
return this.id;
};
this.isDefaultOn=function(){
return this.defaultOn;
};
this.getDescription=function(){
return this.desc;
};
this.getHelpText=function(){
return this.helpText;
};
mb.log.exit();
}
function EsChangeArtistModule(){
mb.log.enter("EsChangeArtistModule","__constructor");
this.CN="EsChangeArtistModule";
this.GID="es.changeartist";
this.getModID=function(){
return "es.changeartist";
};
this.getModName=function(){
return "Change Artist functions";
};
this.guessBothWarning="",this.useCurrent=function(){
mb.log.enter(this.GID,"useCurrent");
var fs,ft,fos,fot;
if(((fs=es.ui.getField("search"))!=null)&&((fos=es.ui.getField("orig_artname"))!=null)&&((ft=es.ui.getField("trackname"))!=null)&&((fot=es.ui.getField("orig_track"))!=null)){
var sa=fos.value;
var st=fot.value;
es.ur.addUndo(es.ur.createItemList(es.ur.createItem(fs,"usecurrent",fs.value,sa),es.ur.createItem(ft,"usecurrent",ft.value,st)));
fs.value=sa;
ft.value=st;
}else{
mb.log.error("Did not find the fields! $,$,$,$",fs,ft,fos,fot);
}
mb.log.exit();
};
this.useSplit=function(){
mb.log.enter(this.GID,"useSplit");
var fs,ft,fsa,fst;
if(((fs=es.ui.getField("search"))!=null)&&((ft=es.ui.getField("trackname"))!=null)&&((fsa=es.ui.getField("split_artname"))!=null)&&((fst=es.ui.getField("split_track"))!=null)){
var sa=fsa.value;
var st=fst.value;
es.ur.addUndo(es.ur.createItemList(es.ur.createItem(fs,"usesplit",fs.value,sa),es.ur.createItem(ft,"usesplit",ft.value,st)));
fs.value=sa;
ft.value=st;
}else{
mb.log.error("Did not find the fields! $,$,$,$",fs,ft,fsa,fst);
}
mb.log.exit();
};
this.guessBoth=function(_3f,_40){
mb.log.enter(this.GID,"guessBoth");
var f,fa,ft;
_3f=(_3f||"search");
_40=(_40||"trackname");
if(((fa=es.ui.getField(_3f))!=null)&&((ft=es.ui.getField(_40))!=null)){
var ov={artist:fa.value,track:ft.value};
var cv={artist:fa.value,track:ft.value};
if(!mb.utils.isNullOrEmpty(ov.artist)&&!mb.utils.isNullOrEmpty(ov.track)){
mb.log.debug("Trying to guess artist & trackname ");
mb.log.debug("* Artist (original): $",cv.artist);
mb.log.debug("* Track (original): $",cv.track);
if(cv.track.match(/\sfeat/i)&&cv.artist.match(/\smix/i)){
if(this.guessBothWarning!=cv.track+"|"+cv.artist){
alert("Please swap artist / trackname fields. they are most likely wrong.");
this.guessBothWarning=cv.track+"|"+cv.artist;
return;
}
}
if(cv.artist!=""){
cv.artist=gc.guessArtist(cv.artist);
}
if(cv.track!=""){
cv.track=gc.guessTrack(cv.track);
}
mb.log.scopeStart("After first guess");
mb.log.debug("* Artist (guessed): $",cv.artist);
mb.log.debug("* Track (guessed): $",cv.track);
var i=-1;
var a=cv.artist.toLowerCase();
i=(a.match(/\s\(feat[\.]?[^$]?/i)?a.indexOf("(feat"):i);
i=(a.match(/\sFeat[\.]?[^$]?/i)?a.indexOf("feat"):i);
i=(a.match(/\sFt[\.]?[^$]/i)?a.indexOf("ft"):i);
i=(a.match(/\sFeaturing[^$]/i)?a.indexOf("featuring"):i);
if(i!=-1){
var _46=(a.charAt(i)!="(");
cv.track=cv.track+(_46?" (":"")+cv.artist.substring(i,cv.artist.length)+(_46?")":"");
cv.artist=cv.artist.substring(0,i);
mb.log.scopeStart("Found feat at position: "+i);
mb.log.debug("Artist (-feat): $",cv.artist);
mb.log.debug("Track (+feat): $",cv.track);
if(cv.artist!=""){
cv.artist=gc.guessArtist(cv.artist);
}
if(cv.track!=""){
cv.track=gc.guessTrack(cv.track);
}
mb.log.scopeStart("After second guess");
mb.log.debug("Artist (final): $",cv.artist);
mb.log.debug("Track (final): $",cv.track);
}
var _47={artist:(ov.artist!=cv.artist?es.ur.createItem(fa,"guessboth",ov.artist,cv.artist):null),track:(ov.track!=cv.track?es.ur.createItem(ft,"guessboth",ov.track,cv.track):null)};
if(_47.artist&&!_47.track){
fa.value=cv.artist;
es.ur.addUndo(_47.artist);
}else{
if(!_47.artist&&_47.track){
ft.value=cv.track;
es.ur.addUndo(_47.track);
}else{
fa.value=cv.artist;
ft.value=cv.track;
es.ur.addUndo(es.ur.createItemList(_47.artist,_47.track));
}
}
mb.log.scopeStart("After guess both");
mb.log.info("* Artist: $",cv.artist);
mb.log.info("* Track: $",cv.track);
}else{
mb.log.info("Field values are empty, skipped");
}
}else{
mb.log.error("Did not find the fields! $,$",_3f,_40);
}
mb.log.exit();
};
mb.log.exit();
}
function EsConfigModule(){
this.CN="EsConfigModule";
this.GID="es.cfg";
mb.log.enter(this.CN,"__constructor");
this.getModID=function(){
return "es.cfg";
};
this.getModName=function(){
return "Configuration";
};
this.CHECKBOX_VISIBLE=this.getModID()+".cb_visible";
this.CHECKBOX_EXPANDED=this.getModID()+".cb_expanded";
this.getModuleHtml=function(){
var s=[];
s.push(this.getModuleStartHtml({x:true}));
s.push("<table cellspacing=\"0\" cellpadding=\"0\" class=\"moduletable\">");
s.push("<tr>");
s.push("<td><b>Module</td>");
s.push("<td rowspan=\"100\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>");
s.push("<td><b>Visible</td>");
s.push("<td rowspan=\"100\">&nbsp;&nbsp;&nbsp;&nbsp;</td>");
s.push("<td><b>Expanded</td>");
s.push("<td rowspan=\"100\">&nbsp;&nbsp;&nbsp;&nbsp;</td>");
s.push("<td width=\"100%\"><b>Reset</td>");
s.push("</tr>");
s.push("<tr class=\"editsuite-box-tr\"><td colspan=\"7\"/>");
s.push("</tr>");
var id,i,m,mods=es.getRegisteredModules();
for(i=0;i<mods.length;i++){
if((m=mods[i])!=es.ui&&m!=this){
id=m.getModID();
var vis=m.isVisible();
var exp=m.isExpanded();
s.push("<tr><td nowrap>");
s.push(m.getModName());
s.push("</td><td>");
s.push("<input type=\"checkbox\" name=\"");
s.push(this.CHECKBOX_VISIBLE);
s.push("\" ");
s.push("id=\"");
s.push(id);
s.push("\"");
s.push(vis?" checked=\"checked\" ":" ");
s.push("onClick=\"");
s.push(id);
s.push(".onSetVisibleClicked(this.checked);\">");
s.push("</td><td>");
s.push("<input type=\"checkbox\" name=\"");
s.push(this.CHECKBOX_EXPANDED);
s.push("\" ");
s.push("id=\"");
s.push(id);
s.push("\"");
s.push(exp?" checked=\"checked\" ":" ");
s.push("onClick=\"");
s.push(id);
s.push(".onSetExpandedClicked(this.checked);\">");
s.push("</td><td>");
s.push("<a href=\"javascript:; // reset\" ");
s.push("onClick=\"");
s.push(id);
s.push(".onResetModuleClicked(); return false;\">");
s.push("Reset</a>");
s.push("</td></tr>");
mb.log.trace("Mod: $, Visible: $, Expanded: $",id,vis,exp);
}
}
s.push("</tr><tr class=\"editsuite-box-tr\"><td colspan=\"7\"/></tr>");
s.push("<tr><td>All modules:</td><td nowrap>");
var f="onSetAllVisibleClicked";
var sep=" | ";
id=this.getModID();
s.push(this.getLinkHtml("Show",id,f,true,sep));
s.push(this.getLinkHtml("Hide",id,f,false,""));
f="onSetAllExpandedClicked";
s.push("</td><td nowrap>");
s.push(this.getLinkHtml("Expand",id,f,true,sep));
s.push(this.getLinkHtml("Collapse",id,f,false,""));
s.push("</td><td nowrap>");
f="onResetAllClicked";
s.push(this.getLinkHtml("Reset",id,f,true,""));
s.push("</td></tr></table>");
s.push(this.getModuleEndHtml({x:true}));
return s.join("");
};
this.getLinkHtml=function(_4e,id,_50,_51,sep){
var s=[];
s.push("<a href=\"javascript:; // ");
s.push(_4e);
s.push(" All\" ");
s.push("onClick=\"return ");
s.push(id);
s.push(".");
s.push(_50);
s.push("(");
s.push(_51);
s.push(");\">");
s.push(_4e);
s.push("</a>");
s.push(sep);
return s.join("");
};
this.getConfigureLinkHtml=function(){
var s=[];
s.push("<div style=\"font-size: 10px; background-image: url(/images/es/configure.gif); background-position: bottom right; vertical-align: bottom; text-align: right; height: 19px; background-repeat: no-repeat\">");
s.push("<div style=\"padding-top: 2px\"><img src=\"/images/edit.gif\" border=\"0\" alt=\"\">");
s.push("<a href=\"javascript: void(0); // Configure modules\" onClick=\"es.cfg.onConfigureLinkClicked()\">Configure</a> ");
s.push("&nbsp;</div>");
s.push("</div>");
return s.join("");
};
this.onConfigureLinkClicked=function(){
if(!this.isVisible()||!this.isExpanded()){
this.setVisible(true);
this.setExpanded(true);
}else{
this.setExpanded(false);
this.setVisible(false);
}
};
this.updateVisible=function(mod,_56){
mb.log.enter(this.GID,"updateVisible");
mb.log.info("Setting module: $ visible: $",mod,_56);
this.traverseAndCheck(this.CHECKBOX_VISIBLE,mod,_56);
mb.log.exit();
};
this.updateExpanded=function(mod,_58){
mb.log.enter(this.GID,"updateExpanded");
mb.log.info("Setting module: $ expanded: $",mod,_58);
this.traverseAndCheck(this.CHECKBOX_EXPANDED,mod,_58);
mb.log.exit();
};
this.traverseAndCheck=function(_59,mod,_5b){
var _5c;
if((_5c=mb.ui.getByName(_59))!=null){
var len=_5c.length;
for(var i=0;i<len;i++){
if(_5c[i].id==mod){
_5c[i].checked=_5b;
break;
}
}
}
};
this.onSetAllVisibleClicked=function(_5f){
mb.log.enter(this.GID,"onSetAllVisibleClicked");
mb.log.debug("flag: $",_5f);
this.traverseAndClick(this.CHECKBOX_VISIBLE,_5f);
return mb.log.exit(false);
};
this.onSetAllExpandedClicked=function(_60){
mb.log.enter(this.GID,"onSetAllExpandedClicked");
mb.log.debug("flag: $",_60);
this.traverseAndClick(this.CHECKBOX_EXPANDED,_60);
return mb.log.exit(false);
};
this.traverseAndClick=function(_61,_62){
var _63;
if((_63=mb.ui.getByName(_61))!=null){
var len=_63.length;
for(var i=0;i<_63.length;i++){
_63[i].checked=!_62;
_63[i].click();
}
}
};
this.onResetAllClicked=function(_66){
mb.log.enter(this.GID,"onResetAllClicked");
var id,i,m,mods=es.getRegisteredModules();
for(i=0;i<mods.length;i++){
if((m=mods[i])!=es.ui&&m!=this){
m.resetModule();
}
}
return mb.log.exit(false);
};
mb.log.exit();
}
try{
EsConfigModule.prototype=new EsModuleBase;
}
catch(e){
mb.log.error("EsConfigModule: Could not register EsModuleBase prototype");
}
function EsFieldResizer(){
mb.log.enter("EsFieldResizer","__constructor");
this.CN="EsFieldResizer";
this.GID="es.fr";
this.getModID=function(){
return "es.fr";
};
this.getModName=function(){
return "Field Resizer";
};
this.CFG_REMEMBERSIZE=this.getModID()+".remembersize";
this.CFG_AUTORESIZE=this.getModID()+".autoresize";
this.CONFIG_LIST=[new EsModuleConfig(this.CFG_REMEMBERSIZE,false,"Remember the size of the fields","Always resize the input fields to the preferred size."),new EsModuleConfig(this.CFG_AUTORESIZE,true,"Automatically resize fields to fit the text","Resize the input fields such that the longest text fits the field without scrolling")];
this.BTN_NARROWER="BTN_FR_NARROWER";
this.BTN_WIDER="BTN_FR_WIDER";
this.BTN_GUESSSIZE="BTN_FR_GUESSSIZE";
this.COOKIE_SIZE=this.getModID()+".size";
this.setupModuleDelegate=function(){
es.ui.registerButtons(new EsButton(this.BTN_NARROWER,"Make narrower","Make input fields 25px smaller",this.getModID()+".onSetSizeClicked(-25)"),new EsButton(this.BTN_WIDER,"Make wider","Make input fields 25px wider",this.getModID()+".onSetSizeClicked(+25)"),new EsButton(this.BTN_GUESSSIZE,"Try to fit text","Set the size of the fields to the size of the longest value",this.getModID()+".onSetSizeClicked()"));
};
this.getModuleHtml=function(){
var s=[];
s.push(this.getModuleStartHtml({x:true}));
s.push(es.ui.getButtonHtml(this.BTN_NARROWER));
s.push(es.ui.getButtonHtml(this.BTN_WIDER));
s.push(es.ui.getButtonHtml(this.BTN_GUESSSIZE));
s.push("<br/><small>");
s.push(this.getConfigHtml());
s.push("</small>");
s.push(this.getModuleEndHtml({x:true}));
s.push(this.getModuleStartHtml({x:false,dt:"Collapsed"}));
s.push(this.getModuleEndHtml({x:false}));
return s.join("");
};
this.onModuleHtmlWrittenDelegate=function(){
if(this.isConfigTrue(this.CFG_AUTORESIZE)||this.isConfigTrue(this.CFG_REMEMBERSIZE)){
mb.registerDOMReadyAction(new MbEventAction(this.GID,"onSetRememberedSize","Setting remembered fieldsize"));
}
};
this.onSetRememberedSize=function(){
mb.log.enter(this.GID,"onSetRememberedSize");
if(this.isConfigTrue(this.CFG_AUTORESIZE)){
this.setSize();
}else{
if(this.isConfigTrue(this.CFG_REMEMBERSIZE)){
var cv=mb.cookie.get(this.COOKIE_SIZE);
if((cv||"").match(/px/i)){
mb.log.debug("Found size in cookie: $",cv);
this.setSize(cv);
}else{
mb.log.debug("No cookie value found...");
}
}
}
mb.log.exit();
};
this.onSetSizeClicked=function(_6a){
mb.log.enter(this.GID,"onSetSizeClicked");
this.setSize(_6a);
mb.log.exit();
};
this.setSize=function(_6b){
mb.log.enter(this.GID,"setSize");
var cn,w,nw,i,f,fields=es.ui.getResizableFields();
if(mb.utils.isString(_6b)&&_6b.match(/px/i)){
mb.log.debug("Setting field size to: $",_6b);
for(i=0;i<fields.length;i++){
f=fields[i];
if((this.getWidth(f))!=null){
f.style.width=_6b;
}
}
}else{
if(mb.utils.isNumber(_6b)){
mb.log.info((_6b>0?"Adding $ to size":"Removing $ from size"),Math.abs(_6b));
var _6d=false;
for(i=0;i<fields.length;i++){
f=fields[i];
if((nw=this.getWidth(f,_6b))!=null){
mb.log.debug("Setting field: $ to width: $",f.name,nw);
f.style.width=nw;
if(!_6d){
mb.cookie.set(this.COOKIE_SIZE,nw);
_6d=true;
}
}else{
mb.log.warning("Field $ does not define width!");
alert(f+" "+f.type);
}
}
}else{
var _6e=0,fl=0;
for(i=0;i<fields.length;i++){
f=fields[i];
cn=(f.className||"");
if(!cn.match(/hidden/)){
if(f.value){
if((fl=f.value.length)>_6e){
_6e=fl;
}
mb.log.debug("Checked field: $, length: $",f.name,fl);
}
}
}
var _6f=parseInt(es.ui.TEXTFIELD_SIZE/es.ui.SIZE_PX_FACTOR);
if(_6e<_6f){
mb.log.debug("Maximum length $ is smaller than default length $",_6e,_6f);
_6e=_6f;
nw=this.getCss(null);
}else{
nw=this.getCss(parseInt(_6e*es.ui.SIZE_PX_FACTOR));
}
mb.log.debug("Adjusting fields to longest value: $, css: $",_6e,nw);
for(i=0;i<fields.length;i++){
f=fields[i];
cn=(f.className||"");
if(f.style.width){
f.style.width=nw;
mb.log.debug("Set field: $ to size: $ (cn: $)",(f.name||"?"),f.style.width,cn);
}else{
mb.log.warning("Field $ does not define width!",(f.name||"?"));
}
}
}
}
mb.log.exit();
};
this.getValue=function(s){
mb.log.enter(this.GID,"getValue");
var ov=s;
if(s!=null){
ov=parseInt(new String(s).replace(/px/ig,""));
}
mb.log.debug("ov: $",ov);
return mb.log.exit(ov);
};
this.getCss=function(s){
mb.log.enter(this.GID,"getCss");
var ov;
if(s!=null){
ov=parseInt(new String(s).replace(/px/ig,""))+"px";
}else{
ov=es.ui.TEXTFIELD_SIZE+"px";
}
mb.log.debug("ov: $",ov);
return mb.log.exit(ov);
};
this.getWidth=function(el,_75){
mb.log.enter(this.GID,"getWidth");
_75=(_75||0);
var w,nw;
if(el&&el.style.width){
w=el.style.width;
nw=this.getCss(this.getValue(w)+_75);
mb.log.debug("Field f: $, oldwidth: $, newwidth: $",el.name,w,nw);
}
return mb.log.exit(nw);
};
mb.log.exit();
}
try{
EsFieldResizer.prototype=new EsModuleBase;
}
catch(e){
mb.log.error("EsFieldResizer: Could not register EsModuleBase prototype");
}
function EsModNoteModule(){
mb.log.enter("EsModNoteModule","__constructor");
this.CN="EsModNoteModule";
this.GID="es.modnote";
this.getModID=function(){
return "es.modnote";
};
this.getModName=function(){
return "Mod Note Resizer";
};
this.el=null;
this.busy=false;
this.rows=0;
this.minrows=3;
this.disabled=false;
this.splitRE=/\r\n|\r|\n/g;
this.whitespaceRE=/\s/g;
this.defaultText="Please enter a moderation note here. Thank you";
this.title="We'd like to know where you got the information from, and why you are attempting to moderate this data...\nThank you";
this.checkedText="";
this.runCheck=function(){
mb.log.enter(this.GID,"runCheck");
if(this.disabled){
return mb.log.exit();
}
var el;
if((el=this.el)==null){
es.modnote.disabled=true;
if((el=mb.ui.get("notetext"))!=null){
mb.log.debug("Setting up event handlers...");
var _78=function(_79){
es.modnote.handleEvent(_79);
};
el.title=this.title;
el.onblur=_78;
el.onfocus=_78;
el.onchange=_78;
el.onkeyup=_78;
el.onkeydown=_78;
if(mb.utils.isNullOrEmpty(el.value)){
el.value=this.defaultText;
this.recalc(el);
}
this.el=el;
el.form.onsubmit=function(_7a){
es.modnote.handleEvent("submit-check");
return true;
};
}
es.modnote.disabled=false;
}else{
if(!this.busy){
this.busy=true;
mb.log.debug("Busy: $",this.busy);
if(!this.isSameText(this.checkedText)){
this.recalc(el);
mb.log.debug("Wraps: $, Rows: $",this.rows,el.rows);
mb.log.debug("Text: $",this.checkedText);
}else{
mb.log.debug("Text has not changed...");
}
this.busy=false;
}
}
return mb.log.exit();
};
mb.registerDOMReadyAction(new MbEventAction(this.GID,"runCheck","Setting up modnote area resizer"));
this.handleEvent=function(e){
mb.log.enter(this.GID,"handleEvent");
e=(e||window.event);
mb.log.info("Handling event: $",(e.type||e));
if(!this.disabled){
this.isSameText(this.defaultText,true);
this.runCheck();
mb.log.info("Event handled!");
return mb.log.exit(true);
}else{
mb.log.warning("Event handling disabled!");
return mb.log.exit(false);
}
};
this.isSameText=function(_7c,_7d){
mb.log.enter(this.GID,"isSameText");
var el;
if((el=this.el)!=null){
if((el.value.replace(this.whitespaceRE,""))==(_7c.replace(this.whitespaceRE,""))){
if(_7d){
this.disabled=true;
el.value="";
this.disabled=false;
mb.log.warning("Cleared default text...");
}
return mb.log.exit(true);
}
}
return mb.log.exit(false);
};
this.recalc=function(el){
mb.log.enter(this.GID,"recalc");
if(el){
var t=el.value,c=el.cols;
if(t!=null&&c!=null){
var _81=t.split(this.splitRE);
var len;
this.rows=1+_81.length;
for(var i=0;i<_81.length;i++){
if((len=_81[i].length)>c){
this.rows+=Math.floor(len*parseFloat(1/c));
}
}
this.rows=(this.rows<this.minrows?this.minrows:this.rows)+(mb.ua.gecko?-1:0);
el.rows=this.rows;
mb.log.debug("Setting rows: $",this.rows);
this.checkedText=t;
}else{
mb.log.error("Did not find text: $, or cols: $",t||"?",c||"?");
}
}else{
mb.log.error("Element el is null!");
}
mb.log.exit();
};
mb.log.exit();
}
function EsQuickFunctions(){
mb.log.enter("EsQuickFunctions","__constructor");
this.CN="EsQuickFunctions";
this.GID="es.qf";
this.getModID=function(){
return "es.qf";
};
this.getModName=function(){
return "Quick functions";
};
this.CFG_ENABLED=this.getModID()+".enabled";
this.CONFIG_LIST=[new EsModuleConfig(this.CFG_ENABLED,true,"Enable the Editor Toolboxes","<img src=/images/es/tools.gif> This function adds icons to the right of the edit fields, which enable quick access to the most needed functions for the current field.")];
this.OP_UPPERCASE="QO_UPPERCASE";
this.OP_LOWERCASE="QO_LOWERCASE";
this.OP_TITLED="QO_TILED";
this.OP_ADD_ROUNDBRACKETS="QO_ADD_ROUNDBRACKETS";
this.OP_ADD_SQUAREBRACKETS="QO_ADD_SQUAREBRACKETS";
this.OP_REM_ROUNDBRACKETS="QO_REM_ROUNDBRACKETS";
this.OP_REM_SQUAREBRACKETS="QO_REM_SQUAREBRACKETS";
this.OP_TB_GUESS="QO_TB_GUESS";
this.BTN_CAPITAL="BTN_QF_CAPITAL";
this.BTN_UPPER="BTN_QF_UPPER";
this.BTN_LOWER="BTN_QF_LOWER";
this.BTN_ADDROUNDBRACKETS="BTN_QF_ADDROUNDBRACKETS";
this.BTN_ADDSQUAREBRACKETS="BTN_QF_ADDSQUAREBRACKETS";
this.BTN_TB_GUESS="BTN_TB_GUESS";
this.tbFieldId=null;
this.TB_GC_DROPDOWN="TB_GC_DROPDOWN";
this.tbGuessCaseMode=null;
this.setupModuleDelegate=function(){
es.ui.registerButtons(new EsButton(this.BTN_CAPITAL,"Capital","Capitalize first character only",this.getModID()+".runOp("+this.getModID()+".OP_TITLED)"),new EsButton(this.BTN_UPPER,"UPPER","Convert characters to UPPERCASE",this.getModID()+".runOp("+this.getModID()+".OP_UPPERCASE)"),new EsButton(this.BTN_LOWER,"lower","Convert characters to lowercase",this.getModID()+".runOp("+this.getModID()+".OP_LOWERCASE)"),new EsButton(this.BTN_ADDROUNDBRACKETS,"Add ()","Add round parentheses () around selection",this.getModID()+".runOp("+this.getModID()+".OP_ADD_ROUNDBRACKETS)"),new EsButton(this.BTN_ADDSQUAREBRACKETS,"Add []","Add square brackets [] around selection",this.getModID()+".runOp("+this.getModID()+".OP_ADD_SQUAREBRACKETS)"),new EsButton(this.BTN_TB_GUESS,"Guess","Guess Case using this method",this.getModID()+".onGuessCaseClicked()"));
};
this.getModuleHtml=function(){
var s=[];
s.push(this.getModuleStartHtml({x:true}));
s.push(es.ui.getButtonHtml(this.BTN_CAPITAL));
s.push(es.ui.getButtonHtml(this.BTN_UPPER));
s.push(es.ui.getButtonHtml(this.BTN_LOWER));
s.push(es.ui.getButtonHtml(this.BTN_ADDROUNDBRACKETS));
s.push(es.ui.getButtonHtml(this.BTN_ADDSQUAREBRACKETS));
s.push("<br/><small>");
s.push(this.getConfigHtml());
s.push("</small>");
s.push(this.getModuleEndHtml({x:true}));
s.push(this.getModuleStartHtml({x:false,dt:"Collapsed"}));
s.push(this.getModuleEndHtml({x:false}));
return s.join("");
};
this.isToolboxEnabled=function(){
return (this.isConfigTrue(this.CFG_ENABLED));
};
this.dummyCount=0;
this.addToolboxDummy=function(_85){
mb.log.enter(this.GID,"addToolboxDummy");
if(this.isToolboxEnabled()){
var id=_85.name+"|et";
var obj;
if((obj=mb.ui.get(id))==null){
var a=document.createElement("a");
a.className="toolbox dummy";
a.onclick=function onclick(_89){
return false;
};
a.id=id;
var img=document.createElement("img");
a.appendChild(img);
img.className="toolbox dummy";
img.src="/images/es/toolsdummy.gif";
img.alt="";
img.border="0";
var _8b=_85.parentNode;
_8b.insertBefore(a,_85.nextSibling);
}
}
mb.log.exit();
};
this.addToolboxIcon=function(_8c){
mb.log.enter(this.GID,"addToolboxIcon");
if(this.isToolboxEnabled()){
var id=_8c.name+"|et";
var obj;
if((obj=mb.ui.get(id))==null){
var a=document.createElement("a");
a.className="toolbox";
a.href="javascript:; // editor tools";
a.onclick=function onclick(_90){
return es.qf.onShowToolboxClicked(this);
};
a.id=id;
a.title="Click to access Toolbox";
var img=document.createElement("img");
a.appendChild(img);
img.className="toolbox";
img.src="/images/es/tools.gif";
img.alt="Click to access Toolbox";
img.border="0";
var _92=_8c.parentNode;
_92.insertBefore(a,_8c.nextSibling);
}
}
mb.log.exit();
};
this.getToolboxLink=function(_93,_94,op){
var s=[];
s.push("<a href=\"javascript: void(); // ");
s.push(_93);
s.push("\" ");
s.push("onClick=\"return "+this.getModID()+".onToolboxLinkClicked('");
s.push(op);
s.push("');\"");
s.push("onFocus=\"this.blur()\"");
s.push("title=\""+_94+"\"");
s.push(">"+_93+"</a>");
return s.join("");
};
this.onShowToolboxClicked=function(el){
mb.log.scopeStart("Handling click on Show toolbox icon");
mb.log.enter(this.GID,"onShowToolboxClicked");
if(o3_showingsticky){
cClick();
}
this.showOverlib(el);
mb.log.exit();
mb.log.scopeEnd();
return false;
};
this.showOverlib=function(el){
ol_bgclass="editor-toolbox-bg";
ol_fgclass="editor-toolbox-fg";
ol_border=0;
ol_width=300;
ol_vauto=1;
ol_fgcolor="#ffffff";
ol_textsize="11px";
ol_closefontclass="editor-toolbox-close";
ol_captionfontclass="editor-toolbox-caption";
this.tbFieldId=el.id.split("|")[0];
this.tbField=es.ui.getField(this.tbFieldId);
this.tbField.focus();
overlib(this.getToolboxHtml(),STICKY,CLOSECLICK,CAPTION,"Editor Toolbox:");
this.tbBoxX=parseInt(over.style.left);
this.tbBoxY=parseInt(over.style.top);
this.tbFieldY=mb.ui.getOffsetTop(this.tbField);
mb.log.debug("xy: $/$, field: $, y: $",this.tbBoxX,this.tbBoxY,this.tbField.name,this.tbFieldY);
};
this.updateToolbox=function(el){
mb.log.enter(this.GID,"updateToolbox");
if(o3_showingsticky){
this.tbFieldId=el.name;
this.tbField=el;
var _9a=mb.ui.getOffsetTop(el);
var _9b=this.tbBoxY+(_9a-this.tbFieldY);
mb.log.debug("xy: $/$, field: $, y: $",this.tbBoxX,this.tbBoxY,this.tbField.name,this.tbFieldY);
mb.log.debug("newY: $, xy: $/$",_9a,this.tbBoxX,_9b);
repositionTo(over,this.tbBoxX,_9b);
}
mb.log.exit();
};
this.onModeChanged=function(el){
mb.log.scopeStart("Handling change of GC dropdown");
mb.log.enter(this.GID,"onModeChanged");
if(el&&el.options&&(el.id==this.TB_GC_DROPDOWN)){
var _9d=el.options[el.selectedIndex].value;
var m;
if((m=gc.modes.getModeFromID(_9d,true))!=null){
this.tbGuessCaseMode=m;
mb.log.debug("Set mode: $",m);
}else{
mb.log.warning("Unknown modeID given: $",_9d);
}
}else{
mb.log.error("Unsupported element: $",(el.name||"?"));
}
mb.log.exit();
mb.log.scopeEnd();
};
this.onGuessCaseClicked=function(){
mb.log.enter(this.GID,"onGuessCaseClicked");
var f;
if((f=es.ui.getField(this.tbFieldId))!=null){
es.guessByFieldName(f.name,this.tbGuessCaseMode);
}
mb.log.exit();
};
this.getToolboxHtml=function(){
var t="Convert all characters of the selection/field to ";
var s=[];
var sep=" | ";
var row="<tr class\"row\"><td class=\"label\">";
var _a4="<tr class=\"row-spacer\"><td class=\"label\">";
var _a5="</td><td class=\"text\">";
var _a6="</td></tr>";
s.push("<table border=\"0\" class=\"editortoolbox\">");
s.push(row);
s.push("Guess case:");
s.push(_a5);
this.tbGuessCaseMode=(this.tbGuessCaseMode||gc.getMode());
s.push(gc.modes.getDropdownHtml(this.TB_GC_DROPDOWN,this.GID,this.tbGuessCaseMode));
s.push(es.ui.getButtonHtml(this.BTN_TB_GUESS));
s.push(_a6);
s.push(_a4);
s.push("Modify case:");
s.push(_a5);
s.push(this.getToolboxLink("Titled",t+"lowercase but the first",this.OP_TITLED));
s.push(sep);
s.push(this.getToolboxLink("Uppercase",t+"UPPERCASE",this.OP_UPPERCASE));
s.push(sep);
s.push(this.getToolboxLink("Lowercase",t+"lowercase",this.OP_LOWERCASE));
s.push(_a6);
s.push(_a4);
s.push("Brackets:");
s.push(_a5);
s.push(this.getToolboxLink("Add ()","Add round parentheses () to selection/field",this.OP_ADD_ROUNDBRACKETS));
s.push(sep);
s.push(this.getToolboxLink("Add []","Add square brackets [] to selection/field",this.OP_ADD_SQUAREBRACKETS));
s.push(sep);
s.push(this.getToolboxLink("Rem ()","Remove round parentheses () from selection/field",this.OP_REM_ROUNDBRACKETS));
s.push(sep);
s.push(this.getToolboxLink("Rem []","Remove square brackets [] from selection/field",this.OP_REM_SQUAREBRACKETS));
s.push(_a6);
s.push(_a4);
s.push("Undo/Redo:");
s.push(_a5);
s.push("<a href=\"javascript:; // Undo\" title=\"Undo the last change (Attention: Not only the selected field)\" onFocus=\"this.blur()\" onClick=\"es.ur.undoStep(); return false;\">Undo</a>");
s.push(sep);
s.push("<a href=\"javascript:; // Redo\" title=\"Redo the last undo step (Attention: Not only the selected field)\" onFocus=\"this.blur()\" onClick=\"es.ur.redoStep(); return false;\">Redo</a>");
s.push(_a6);
s.push("</table>");
return s.join("");
};
this.onToolboxLinkClicked=function(op){
mb.log.scopeStart("Handling click on toolbox link");
mb.log.enter(this.GID,"onToolboxLinkClicked");
mb.log.info("el: $",this.tbFieldId);
var f;
if((f=es.ui.getField(this.tbFieldId))!=null){
this.runOp(op,f);
}
mb.log.exit();
mb.log.scopeEnd();
return false;
};
this.runOp=function(op,f){
mb.log.enter(this.GID,"runOp");
if(!f){
f=es.ui.getFocusField();
}
if(f!=null){
var ov=f.value,nv=ov;
mb.log.info("Applying op: $",op);
var _ac=false,isIE=(typeof document.selection!="undefined");
if(!isIE){
f.focus();
_ac=(typeof f.selectionStart!="undefined");
}
if(isIE||_ac){
var ft=f.value;
var a,r,rs,re;
if(isIE){
try{
r=document.selection.createRange();
a=(r.text!=""?r.text:ft);
}
catch(e){
mb.log.error("could not get range!");
}
}else{
if(_ac){
rs=f.selectionStart;
re=f.selectionEnd;
a=(rs==re?ft:ft.substring(rs,re));
}
}
mb.log.info("Operating on "+(a==ft?"full text":"range")+": $",a);
var b=a;
switch(op){
case this.OP_UPPERCASE:
case this.OP_LOWERCASE:
case this.OP_TITLED:
b=this.formatText(a,op);
break;
case this.OP_ADD_ROUNDBRACKETS:
b="("+a+")";
break;
case this.OP_ADD_SQUAREBRACKETS:
b="["+a+"]";
break;
case this.OP_REM_ROUNDBRACKETS:
b=b.replace(/\(|\)/g,"");
break;
case this.OP_REM_SQUAREBRACKETS:
b=b.replace(/\[|\]/g,"");
break;
}
if(a==ft){
f.value=b;
}else{
if(isIE){
r.text=b;
}else{
if(_ac){
var s=[];
s.push(ft.substring(0,rs));
s.push(b);
s.push(ft.substring(re,ft.length));
f.value=s.join("");
f.selectionStart=rs;
f.selectionEnd=rs+b.length;
}
}
}
nv=f.value;
if(nv!=ov){
es.ur.addUndo(es.ur.createItem(f,"runOp",ov,nv));
mb.log.info("New value: $",nv);
}
}
}
mb.log.exit();
};
this.formatText=function(_b1,op){
if(op==this.OP_UPPERCASE){
_b1=_b1.toUpperCase();
}
if(op==this.OP_LOWERCASE){
_b1=_b1.toLowerCase();
}
if(op==this.OP_TITLED){
_b1=_b1.toLowerCase();
var _b3=_b1.split("");
_b3[0]=_b3[0].toUpperCase();
_b1=_b3.join("");
}
return _b1;
};
mb.log.exit();
}
try{
EsQuickFunctions.prototype=new EsModuleBase;
}
catch(e){
mb.log.error("EsQuickFunctions: Could not register EsModuleBase prototype");
}
function EsSearchReplace(){
mb.log.enter("EsSearchReplace","__constructor");
this.CN="EsSearchReplace";
this.GID="es.sr";
this.getModID=function(){
return "es.sr";
};
this.getModName=function(){
return "Search/Replace";
};
this.BTN_SEARCH="BTN_SR_SEARCH";
this.BTN_REPLACE="BTN_SR_REPLACE";
this.BTN_LOADPRESET="BTN_SR_LOADPRESET";
this.BTN_SWAP="BTN_SR_SWAP";
this.BTN_RESET="BTN_SR_CLEAR";
this.FIELD_SEARCH=this.getModID()+".search";
this.FIELD_REPLACE=this.getModID()+".replace";
this.FIELD_REGEX=this.getModID()+".regex";
this.FIELD_AUTOAPPLY=this.getModID()+".autoapply";
this.FIELD_MATCHCASE=this.getModID()+".matchcase";
this.FIELD_ALLFIELDS=this.getModID()+".allfields";
this.PRESETS_LIST=[["Remove all round parentheses ()","\\(|\\)","",1],["Remove all square brackets []","\\[|\\]","",1],["Remove all curly braces {}","\\{|\\}","",1],["Remove all bracketing punctuation ()[]{}","\\(|\\)|\\[|\\]|\\{|\\}","",1],["Replace [] with ()","\\[([^\\]]*)\\]","($1)",1],["Replace () with []","\\(([^\\)]*)\\)","[$1]",1],["Replace #1 with No. 1 for any number","#(\\d*)","No. $1",1]];
this.COOKIE_PRESETEXPANDED="SR_COOKIE_PRESETEXPANDED";
this.setupModuleDelegate=function(){
es.ui.registerButtons(new EsButton(this.BTN_SEARCH,"Search","",this.getModID()+".onSearchClicked()"),new EsButton(this.BTN_REPLACE,"Replace","",this.getModID()+".onReplaceClicked()"),new EsButton(this.BTN_LOADPRESET,"Show/Hide Presets","",this.getModID()+".onShowPresetsClicked()"),new EsButton(this.BTN_SWAP,"Swap fields","",this.getModID()+".onSwapFieldsClicked()"),new EsButton(this.BTN_RESET,"Reset","",this.getModID()+".onResetFieldsClicked()"));
};
this.getModuleHtml=function(){
var s=[];
s.push(this.getModuleStartHtml({x:true}));
s.push("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" class=\"moduletable\">");
s.push("<tr>");
s.push("<td>Search: &nbsp;</td>");
s.push("<td><input type=\"input\" class=\"srfield\" size=\"30\" value=\"\" name=\""+this.FIELD_SEARCH+"\">&nbsp;");
s.push(es.ui.getButtonHtml(this.BTN_SWAP));
s.push(es.ui.getButtonHtml(this.BTN_RESET));
s.push("</td>");
s.push("</tr>");
s.push("<tr>");
s.push("<td>Replace: &nbsp;</td>");
s.push("<td><input type=\"input\" class=\"srfield\" size=\"30\" value=\"\" name=\""+this.FIELD_REPLACE+"\"></td>");
s.push("</tr>");
s.push("<tr>");
s.push("<td></td>");
s.push("<td>");
s.push(es.ui.getButtonHtml(this.BTN_SEARCH));
s.push(es.ui.getButtonHtml(this.BTN_REPLACE));
s.push(es.ui.getButtonHtml(this.BTN_LOADPRESET));
s.push("<br/>");
s.push("<input type=\"hidden\" name=\""+this.FIELD_AUTOAPPLY+"\" value=\"1\">");
s.push("<input type=\"checkbox\" name=\""+this.FIELD_REGEX+"\" value=\"true\"><small>Regular expression</small>");
s.push("<input type=\"checkbox\" name=\""+this.FIELD_MATCHCASE+"\" value=\"true\"><small>Match case</small>");
s.push("<input type=\"checkbox\" name=\""+this.FIELD_ALLFIELDS+"\" value=\"true\" checked><small>For all fields</small>");
s.push("</tr>");
s.push("</table>");
s.push(this.getModuleEndHtml({x:true}));
s.push(this.getModuleStartHtml({x:false,dt:"Collapsed"}));
s.push(this.getModuleEndHtml({x:false}));
return s.join("");
};
this.getPresetsHtml=function(){
var s=[];
s.push("<table id=\"srPresetsTable\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"moduletable\">");
s.push("<tr>");
s.push("<td><b>Description</b> &nbsp;</td>");
s.push("<td><img src=\"/images/spacer.gif\" alt=\"\" width=\"10\" height=\"1\"></td>");
s.push("<td><b>Search</b> &nbsp;</td>");
s.push("<td><img src=\"/images/spacer.gif\" alt=\"\" width=\"10\" height=\"1\"></td>");
s.push("<td nowrap><b>Replace</b> &nbsp;</td>");
s.push("<td nowrap><b>Regex</b> &nbsp;</td>");
s.push("</tr>");
for(var i=0;i<this.PRESETS_LIST.length;i++){
var p=this.PRESETS_LIST[i];
if(i==0){
s.push("<tr class=\"editsuite-box-tr\">");
}else{
s.push("<tr>");
}
s.push("<td nowrap><a href=\"javascript: // select preset\" onClick=\""+this.getModID()+".onSelectPresetClicked("+i+")\">");
s.push("<b>&middot;</b>&nbsp;"+(p[0])+"</td>");
s.push("<td/>");
s.push("<td nowrap>"+(p[1])+"</td>");
s.push("<td/>");
s.push("<td nowrap>"+(p[2])+"</td>");
s.push("<td>"+(p[3]==1?"Yes":"No")+"</td>");
s.push("</tr>");
}
s.push("<tr class=\"editsuite-box-tr\">");
s.push("<td colspan=\"6\"><input type=\"checkbox\" ");
s.push("name=\"srApplyPreset\" value=\"on\" ");
s.push(this.getPresetChooseApply()?"checked":"");
s.push("onClick=\""+this.getModID()+".onPresetChooseApplyChanged(this.checked)\">Execute Search & Replace when selected.</td>");
s.push("</tr>");
s.push("</table>");
var t=s.join("");
return t;
};
this.onShowPresetsClicked=function(){
if(!o3_showingsticky){
ol_bgclass="sr-presets-bg";
ol_fgclass="sr-presets-fg";
ol_border=0;
ol_vauto=1;
ol_fgcolor="#ffffff";
ol_textsize="11px";
ol_closefontclass="sr-presets-close";
ol_captionfontclass="sr-presets-caption";
overlib(this.getPresetsHtml(),STICKY,CLOSECLICK,CAPTION,"Search/Replace Presets:");
}else{
cClick();
}
};
this.onSwapFieldsClicked=function(){
mb.log.enter(this.GID,"onSwapFieldsClicked");
var fs,fr;
if((fs=es.ui.getField(this.FIELD_SEARCH))!=null&&(fr=es.ui.getField(this.FIELD_REPLACE))!=null){
var _ba=fs.value;
fs.value=fr.value;
fr.value=_ba;
}else{
mb.log.error("One of the fields $,$ not found!",this.FIELD_SEARCH,this.FIELD_REPLACE);
}
mb.log.exit();
};
this.onResetFieldsClicked=function(){
mb.log.enter(this.GID,"onResetFieldsClicked");
var fs,fr;
if((fs=es.ui.getField(this.FIELD_SEARCH))!=null&&(fr=es.ui.getField(this.FIELD_REPLACE))!=null){
fs.value="";
fr.value="";
}else{
mb.log.error("One of the fields $,$ not found!",this.FIELD_SEARCH,this.FIELD_REPLACE);
}
mb.log.exit();
};
this.onSearchClicked=function(){
mb.log.enter(this.GID,"onSearchClicked");
mb.log.warning("Not implemented yet.");
mb.log.exit();
};
this.onSelectPresetClicked=function(_bc){
mb.log.enter(this.GID,"onResetFieldsClicked");
var fs,fr,freg,faa;
if((fs=es.ui.getField(this.FIELD_SEARCH))!=null&&(fr=es.ui.getField(this.FIELD_REPLACE))!=null&&(freg=es.ui.getField(this.FIELD_REGEX))!=null&&(faa=es.ui.getField(this.FIELD_AUTOAPPLY))!=null){
var p=this.PRESETS_LIST[_bc];
if(p){
fs.value=p[1];
fr.value=p[2];
freg.checked=(p[3]==1);
mb.log.info("Preset $ selected",p[0]);
}
if(faa.value=="1"){
this.onReplaceClicked();
}
}else{
mb.log.error("One of the fields not found!");
}
mb.log.exit();
};
this.onPresetChooseApplyChanged=function(_bf){
var faa;
if((faa=es.ui.getField(this.FIELD_AUTOAPPLY))!=null){
faa.value=(_bf?"1":"0");
}else{
mb.log.error("Field $ not found!",this.FIELD_AUTOAPPLY);
}
};
this.getPresetChooseApply=function(){
var faa;
if((faa=es.ui.getField(this.FIELD_AUTOAPPLY))!=null){
return (faa.value=="1");
}else{
mb.log.error("Field $ not found!",this.FIELD_AUTOAPPLY);
}
return false;
};
this.onReplaceClicked=function(){
mb.log.enter(this.GID,"onReplaceClicked");
var fs,fr,freg,fmc,faf;
if((fs=es.ui.getField(this.FIELD_SEARCH))!=null&&(fr=es.ui.getField(this.FIELD_REPLACE))!=null&&(freg=es.ui.getField(this.FIELD_REGEX))!=null&&(fmc=es.ui.getField(this.FIELD_MATCHCASE))!=null&&(faf=es.ui.getField(this.FIELD_ALLFIELDS))!=null){
var sv=fs.value;
var rv=fr.value;
if(sv==""){
mb.log.warning("Search is empty, aborting.");
return;
}
var f;
if(faf.checked){
var _c6=es.ui.getEditTextFields();
for(var i=0;i<_c6.length;i++){
f=_c6[i];
this.replaceField(f,sv,rv,fmc.checked,freg.checked);
}
}else{
if((f=es.ui.getFocusField())!=null){
this.replaceField(f,sv,rv,fmc.checked,freg.checked);
}
}
}else{
mb.log.error("One of the fields not found!");
}
mb.log.exit();
};
this.replaceField=function(f,sv,rv,_cb,_cc){
if(f){
var cv=f.value;
var nv=cv;
mb.log.debug("Current: $",cv);
mb.log.debug("Search: $, Replace: $",sv,rv);
mb.log.debug("Flags: Case Sensitive: $, Regex: $",_cb,_cc);
if(_cc){
try{
var re=new RegExp(sv,"g"+(_cb?"":"i"));
nv=cv.replace(re,rv);
}
catch(e){
mb.log.error("Caught error while trying to Match re: $, e: $",re,e);
}
}else{
var vi=-1;
var _d1=new Array();
var _d2=(_cb?sv:sv.toLowerCase());
while((vi=(_cb?nv:nv.toLowerCase()).indexOf(_d2))!=-1){
nv=nv.substring(0,vi)+rv+nv.substring(vi+sv.length,nv.length);
_d1.push(vi);
}
if(_d1.length<1){
mb.log.debug("Search value $ was not found",sv);
}else{
mb.log.debug("Search value $ replaced with $ at index [$]",sv,rv,_d1.join(","));
}
}
if(nv!=cv){
mb.log.debug("New value $",nv);
es.ur.addUndo(es.ur.createItem(f,"searchreplace",cv,nv));
f.value=nv;
return mb.log.exit(true);
}
}
return mb.log.exit(false);
};
mb.log.exit();
}
try{
EsSearchReplace.prototype=new EsModuleBase;
}
catch(e){
mb.log.error("EsSearchReplace: Could not register EsModuleBase prototype");
}
function EsTrackParser(){
mb.log.enter("EsTrackParser","__constructor");
this.CN="EsTrackParser";
this.GID="es.tp";
this.getModID=function(){
return "es.tp";
};
this.getModName=function(){
return "Track Parser";
};
this.CFG_ISVA=this.getModID()+".isVA";
this.CFG_PARSETIMESONLY=this.getModID()+".timesonly";
this.CFG_ALBUMTITLE=this.getModID()+".albumtitle";
this.CFG_TRACKNUMBER=this.getModID()+".tracknumber";
this.CFG_VINYLNUMBERS=this.getModID()+".vinylnumbers";
this.CFG_TRACKTIMES=this.getModID()+".tracktimes";
this.CFG_STRIPBRACKETS=this.getModID()+".stripbrackets";
this.CONFIG_LIST=[new EsModuleConfig(this.CFG_ALBUMTITLE,false,"First line is album title","The First line is handled as the album title, which is filled into the album title field. The tracks are expected to start from line 2"),new EsModuleConfig(this.CFG_TRACKNUMBER,true,"All tracknames start with a number","Lines which do not start with a number are inspected for usable information, which is added to the previous track (this allows to import ExtraTitleInformation from discogs)"),new EsModuleConfig(this.CFG_VINYLNUMBERS,false,"Detect Vinyl track numbers","Characters which are used for numbering of the tracks may include alphanummeric characters (0-9,a-z) (A1,A2,...C,D...)"),new EsModuleConfig(this.CFG_TRACKTIMES,true,"Detect track times ?:??","The line is inspected for an occurence of numbers separated by a colon. If such a value is found the track time is read and removed from the track title. Round parentheses surrounding the time are removed as well."),new EsModuleConfig(this.CFG_STRIPBRACKETS,true,"Remove text in brackets [...]","Text in square brackets (usually links to other pages) is removed")];
this.TRACKSAREA=this.getModID()+".tracksarea";
this.BTN_SWAP="BTN_TP_SWAP";
this.BTN_PARSE="BTN_TP_PARSE";
this.BTN_PARSETIMES="BTN_TP_PARSETIMES";
this.WARNINGTR="TP_WARNINGTR";
this.WARNINGTD="TP_WARNINGTD";
this.RE_TrackNumber=/^[\s\(]*[0-9\.]+(-[0-9]+)?[\.\)\s]+/g;
this.RE_TrackNumberVinyl=/^[\s\(]*[0-9a-z]+[\.\)\s]+/gi;
this.RE_TrackTimes=/\(?[0-9]+[:,.][0-9]+\)?/gi;
this.RE_RemoveParens=/\(|\)/g;
this.RE_StripSquareBrackets=/\[.*\]/gi;
this.RE_StripTrailingListen=/\s\s*(listen(music)?|\s)+$/gi;
this.RE_StripListenNow=/listen now!/gi;
this.RE_StripAmgPick=/amg pick/gi;
this.RE_VariousSeparator=/  |\s+-\s+|\t/gi;
this.setupModuleDelegate=function(){
es.ui.registerButtons(new EsButton(this.BTN_PARSE,"Parse All","Fill in the artist and track titles with values parsed from the textarea",this.getModID()+".onParseClicked()"),new EsButton(this.BTN_PARSETIMES,"Parse Times","Fill in the track times only with values parsed from the textarea",this.getModID()+".onParseClicked(true)"),new EsButton(this.BTN_SWAP,"Swap titles","If the Artist and Track titles are mixed up, click here to swap the fields",this.getModID()+".onSwapArtistTrackClicked()"));
};
this.getModuleHtml=function(){
var s=[];
s.push(this.getModuleStartHtml({x:true}));
s.push("<table cellspacing=\"0\" cellpadding=\"0\" class=\"moduletable\">");
s.push("<tr>");
s.push("<td colspan=\"2\">");
s.push("<textarea name=\""+this.TRACKSAREA+"\" rows=\"10\" cols=\"90\" id=\""+this.TRACKSAREA+"\" wrap=\"off\" style=\"width: 97%; font-family: Arial,Helvetica, Verdana; font-size: 11px; overflow: auto\"></textarea>");
s.push("</td></tr>");
s.push("<tr valign=\"top\" id=\""+this.WARNINGTR+"\" style=\"display: none\">");
s.push("<td colspan=\"2\" style=\"padding: 2px; color: red; font-size: 11px\" id=\""+this.WARNINGTD+"\"><small>");
s.push("</small></td></tr>");
s.push("<tr valign=\"top\">");
s.push("<td><div style=\"margin-bottom: 2px\">");
s.push(es.ui.getButtonHtml(this.BTN_PARSE));
s.push("</div><div style=\"margin-bottom: 2px\"/>");
s.push(es.ui.getButtonHtml(this.BTN_PARSETIMES));
s.push("</div><div style=\"margin-bottom: 2px\"/>");
s.push(es.ui.getButtonHtml(this.BTN_SWAP));
s.push("</div></td><td><small>");
s.push(this.getConfigHtml());
s.push("</small></td>");
s.push("</tr></table>");
s.push(this.getModuleEndHtml({x:true}));
s.push(this.getModuleStartHtml({x:false,dt:"Collapsed"}));
s.push(this.getModuleEndHtml({x:false}));
return s.join("");
};
this.onParseClicked=function(_d4){
mb.log.enter(this.GID,"onParseClicked");
_d4=(_d4||false);
this.setConfigValue(this.CFG_PARSETIMESONLY,_d4);
this.parseNow();
es.ui.setDisabled(this.BTN_SWAP,false);
mb.log.exit();
};
this.onSwapArtistTrackClicked=function(){
mb.log.scopeStart("Handling click on Swap button");
mb.log.enter(this.GID,"onSwapArtistTrackClicked");
if(this.isConfigTrue(this.CFG_ISVA)){
var _d5=es.ui.getArtistFields();
var _d6=es.ui.getTrackNameFields();
if(_d5&&_d6&&_d5.length==_d6.length){
for(var i=0;i<_d5.length;i++){
var _d8=_d5[i].value;
_d5[i].value=_d6[i].value;
_d6[i].value=_d8;
}
}
}
mb.log.exit();
mb.log.scopeEnd();
};
this.checkVAMode=function(){
mb.log.enter(this.GID,"checkVAMode");
if(this.isUIAvailable()){
this.setVA(es.ui.getField("artistname0",true)!=null);
if(!this.isConfigTrue(this.CFG_ISVA)){
es.ui.setDisabled(this.BTN_SWAP,false);
}else{
es.ui.setDisabled(this.BTN_SWAP,true);
}
}
mb.log.exit();
};
mb.registerDOMReadyAction(new MbEventAction(this.GID,"checkVAMode","Setting various artists mode"));
this.setVA=function(_d9){
mb.log.enter(this.GID,"setVA");
mb.log.trace("New VA mode: $",_d9);
this.setConfigValue(this.CFG_ISVA,_d9);
mb.log.exit();
};
this.showWarning=function(s){
var obj;
if(s){
if((obj=mb.ui.get(this.WARNINGTR))!=null){
obj.style.display="";
}
if((obj=mb.ui.get(this.WARNINGTD))!=null){
obj.innerHTML+="<b>&middot;</b> "+s+"<br/>";
}
}else{
if((obj=mb.ui.get(this.WARNINGTR))!=null){
obj.style.display="none";
}
if((obj=mb.ui.get(this.WARNINGTD))!=null){
obj.innerHTML="";
}
}
};
this.parseNow=function(_dc){
mb.log.enter(this.GID,"parseNow");
if(_dc){
this.setVA(_dc);
}else{
this.checkVAMode();
}
var obj=null;
var _de=new Array();
this.showWarning();
if((obj=mb.ui.get(this.TRACKSAREA))!=null){
var _df=obj.value;
var _e0=_df.split("\n");
var _e1,title,artistName;
var si=0;
var _e3="";
if(this.isConfigTrue(this.CFG_ALBUMTITLE)){
_e3=_e0[0];
mb.log.info("Album Title: $",_e3);
si++;
}
var s,counter=1;
var _e5=true;
for(var i=si;i<_e0.length;i++){
title=_e0[i];
title=title.replace(this.RE_StripListenNow,"");
title=title.replace(this.RE_StripAmgPick,"");
title=mb.utils.trim(title);
mb.log.trace("Parsing line: $",title);
if(title!=""){
var _e7=false;
var _e8=false;
var re=this.RE_TrackNumber;
if(this.isConfigTrue(this.CFG_VINYLNUMBERS)){
re=this.RE_TrackNumberVinyl;
_e8=true;
}
_e1=title.match(re);
if(_e1!=null){
mb.log.debug("Checking number, found: $ (vinyl: $)",_e1[0],_e8);
_e7=true;
if(this.isConfigTrue(this.CFG_TRACKNUMBER)){
title=title.replace(re,"");
}
}
_e1=counter;
var _ea="";
if(this.isConfigTrue(this.CFG_TRACKTIMES)){
_ea=title.match(this.RE_TrackTimes);
if(_ea!=null){
_ea=mb.utils.trim(_ea[0]);
mb.log.debug("Checking time, found: $",_ea);
_ea=_ea.replace(this.RE_RemoveParens,"");
}
title=title.replace(this.RE_TrackTimes,"");
}
if(this.isConfigTrue(this.CFG_STRIPBRACKETS)){
s=title.replace(this.RE_StripSquareBrackets,"");
if(s!=title){
mb.log.debug("Stripped brackets");
title=s;
}
}
s=title.replace(this.RE_StripTrailingListen,"");
if(s!=title){
mb.log.debug("Stripped trailing 'Listen'");
title=s;
}
artistName="";
if(this.isConfigTrue(this.CFG_ISVA)){
if(!this.isConfigTrue(this.CFG_TRACKNUMBER)||_e7){
mb.log.debug("Looking for Artist/Track split");
if(title.match(this.RE_VariousSeparator)){
var _eb=title.split(this.RE_VariousSeparator);
artistName=mb.utils.trim(_eb[0]);
mb.log.debug("Found artist: $",artistName);
if(_e5&&artistName.match(/\(|\)|remix/gi)){
this.showWarning("Track "+counter+": Possibly Artist/Tracknames swapped: Parentheses in Artist name!");
_e5=false;
}
_eb[0]="";
while(!_eb[0].match(/\S/g)){
_eb.splice(0,1);
}
if(_eb.length>1){
this.showWarning("Track "+counter+": Possibly wrong split of Artist and Trackname:<br/>&nbsp; ["+_eb.join(",")+"]");
}
title=_eb.join(" ");
}
}
}
title=mb.utils.trim(title);
if(!this.isConfigTrue(this.CFG_TRACKNUMBER)||_e7){
_de[_de.length]={artist:artistName,title:title,time:_ea,feat:[]};
counter++;
mb.log.debug("Added track: $",counter);
}else{
if(_de.length>0){
mb.log.debug("Analyzing string for ExtraTitleInformation: $",title);
var x=title.split(" - ");
if(x[0].match(/remix|producer|mixed/i)==null){
if(x.length>1){
x.splice(0,1);
title=x.join("");
title=title.replace(/\s*,/g,",");
title=title.replace(/^\s*/g,"");
title=title.replace(/[ \s\r\n]*$/g,"");
title=title.replace(/(.*), The$/i,"The $1");
if(title!=""){
_de[_de.length-1].feat.push(title);
}
}
}
}
}
}
}
mb.log.scopeStart("Parsed the following fields");
for(i=0;i<_de.length;i++){
var _ed=_de[i];
if(_ed.feat.length>0){
_ed.title+=" (feat. "+_ed.feat.join(", ")+")";
}
mb.log.info("no: $, title: $, time: $ (artist: $)",mb.utils.leadZero(i+1),_ed.title,_ed.time,_ed.artist);
}
this.fillFields(_e3,_de);
}
mb.log.exit();
};
this.fillField=function(_ee,_ef){
mb.log.enter(this.GID,"fillField");
if(_ee!=null&&_ef!=null){
es.ur.addUndo(es.ur.createItem(_ee,"trackparser",_ee.value,_ef));
_ee.value=_ef;
}
mb.log.exit();
};
this.fillFields=function(_f0,_f1){
var i,j,field,fields,newvalue;
mb.log.enter(this.GID,"fillFields");
if(!this.isConfigTrue(this.CFG_PARSETIMESONLY)){
if(this.isConfigTrue(this.CFG_ALBUMTITLE)){
field=es.ui.getAlbumNameField();
this.fillField(field,_f0);
}
i=0;
fields=es.ui.getArtistFields();
for(j=0;j<fields.length;j++){
field=fields[j];
if(_f1[i]&&_f1[i].artist){
this.fillField(field,_f1[i].artist);
i++;
}
}
i=0;
fields=es.ui.getTrackNameFields();
for(j=0;j<fields.length;j++){
field=fields[j];
if(_f1[i]&&_f1[i].title){
this.fillField(field,_f1[i].title);
i++;
}
}
}
i=0;
fields=es.ui.getTrackTimeFields();
for(j=0;j<fields.length;j++){
field=fields[j];
if(_f1[i]&&_f1[i].time){
this.fillField(field,_f1[i].time);
i++;
}
}
mb.log.exit();
};
mb.log.exit();
}
try{
EsTrackParser.prototype=new EsModuleBase;
}
catch(e){
mb.log.error("EsTrackParser: Could not register EsModuleBase prototype");
}
function EsUiModule(){
this.CN="EsUiModule";
this.GID="es.ui";
mb.log.enter(this.CN,"__constructor");
this.getModID=function(){
return "es.ui";
};
this.getModName=function(){
return "User Interface";
};
this.BTN_ALIAS="BTN_ALIAS";
this.BTN_ARTIST="BTN_ARTIST";
this.BTN_SORTGUESS="BTN_SORTGUESS";
this.BTN_SORTCOPY="BTN_SORTCOPY";
this.BTN_ALBUM="BTN_ALBUM";
this.BTN_TRACK="BTN_TRACK";
this.BTN_ALL="BTN_ALL";
this.BTN_USESWAP="BTN_USESWAP";
this.BTN_USESPLIT="BTN_USESPLIT";
this.BTN_USECURRENT="BTN_USECURRENT";
this.BTN_GUESSBOTH="BTN_GUESSBOTH";
this.BTN_CANCEL="BTN_CANCEL";
this.BTN_TEXT_NONALBUMTRACKS="Guess All Track Names according to Guess Case settings";
this.BTN_TEXT_ALBUMANDTRACKS="Guess Album Name and Track Names according to Guess Case settings";
this.BTN_TEXT_ALBUMARTISTANDTRACKS="Guess Album, Artist and Track Names according to Guess Case settings";
this.GC_MODE=null;
this.focusField=null;
this.focusValue=null;
this.FORMFIELD_ID="ES_FORMFIELD_ID";
this.formRef=null;
this.buttonRegistry=[];
this.re={ARTISTFIELD:/^(search|artistname|newartistname|newartistalias)/i,SORTNAMEFIELD:/^(artistsortname|newartistsortname)/i,ALBUMFIELD:/^(newalbumname|albumname|album|name)/i,TRACKFIELD:/^(newtrackname|trackname|track)/i,TRACKLENGTHFIELD:/tracklength\d+/i,TEXTFIELD:/^textfield(\sfocus|\smissing)*$/i,RESIZEABLEFIELD:/^textfield(\sfocus|\shidden|\soldvalue|\sheader)*$/i,NUMBERFIELD:/^numberfield(\sfocus|\shidden|oldvalue|header)*$/i};
this.TEXTFIELD_SIZE=350;
this.SIZE_PX_FACTOR=5.7;
this.setupModuleDelegate=function(){
mb.log.enter(this.GID,"setupModuleDelegate");
var def="Guess Case";
this.registerButtons(new EsButton(this.BTN_ALIAS,def,"Guess Artist Alias according to MusicBrainz Artist Name Guidelines","es.guessArtistField($);"),new EsButton(this.BTN_ARTIST,def,"Guess Artist Name according to MusicBrainz Artist Name Guidelines","es.guessArtistField($);"),new EsButton(this.BTN_SORTGUESS,"Guess","Guess Sort Name from Artist Name field","es.guessSortnameField($, $);"),new EsButton(this.BTN_SORTCOPY,"Copy","Copy Sort Name from Artist Name field","es.copySortnameField($, $);"),new EsButton(this.BTN_ALBUM,def,"Guess Album Name according to Guess Case settings","es.guessAlbumField($);"),new EsButton(this.BTN_TRACK,def,"Guess Track Name according to Guess Case settings","es.guessTrackField($)"),new EsButton(this.BTN_ALL,"Guess All","Guess all fields according to Guess Case settings","es.guessAllFields()"),new EsButton(this.BTN_USESWAP,"Swap","Swap Artist Name and Track Name fields","es.swapFields($,$,$)"),new EsButton(this.BTN_USECURRENT,"Use Current","Reset to current Artist Name and Track Name","es.changeartist.useCurrent()"),new EsButton(this.BTN_USESPLIT,"Split","Use Artist Name and Track Name from split function","es.changeartist.useSplit()"),new EsButton(this.BTN_GUESSBOTH,"Guess Both","Guess both Artist Name and Track Name","es.changeartist.guessBoth($, $)"),new EsButton(this.BTN_CANCEL,"Cancel","Return to the previous page","es.ui.cancelForm($)"));
mb.registerDOMReadyAction(new MbEventAction(this.GID,"setupFormFields","Add event handlers on form elements"));
mb.log.exit();
};
this.writeUI=function(el,_f5){
mb.log.enter(this.GID,"writeUI");
var s=[];
s.push("<input type=\"hidden\" name=\"jsProxy\" id=\""+this.FORMFIELD_ID+"\" value=\"\">");
s.push("<div id=\"editsuite-table\" class=\"editsuite-table\">");
s.push("<table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">");
var i,m,mods=es.getRegisteredModules();
for(i=0;i<mods.length;i++){
if((m=mods[i])!=this){
s.push(m.getModuleHtml());
}
}
s.push("</table>");
s.push("</div>");
var div=document.createElement("div");
div.innerHTML=s.join("");
el.appendChild(div);
for(i=0;i<mods.length-1;i++){
if((m=mods[i])!=this){
m.onModuleHtmlWritten();
}
}
mb.log.exit();
};
this.getHelpButton=function(mod,_fa){
var s=[];
s.push("<td class=\"toggle\">");
s.push("<a href=\"javascript:; // ");
s.push(_fa?"expand":"collapse");
s.push("\" onClick=\"");
s.push(mod.getModID());
s.push(".setExpanded(");
s.push(_fa?"true":"false");
s.push(")\"><img src=\"/images/es/");
s.push(_fa?"maximize":"minimize");
s.push(".gif\" width=\"13\" height=\"13\" alt=\"");
s.push(_fa?"Expand ":"Collapse ");
s.push(mod.getModName());
s.push("function\" border=\"0\"></a>");
s.push("</td>");
return s.join("");
};
this.registerButtons=function(){
mb.log.enter(this.GID,"registerButtons");
for(var i=arguments.length-1;i>=0;i--){
var btn=arguments[i];
if(btn instanceof EsButton){
this.buttonRegistry[btn.getID()]=btn;
}
}
mb.log.exit();
};
this.getButtonHtml=function(bid){
mb.log.enter(this.GID,"getButtonHtml");
var btn,s=null;
if(bid!=""){
if((btn=this.buttonRegistry[bid])!=null){
s=[];
s.push("<input type=\"button\" class=\"button\" ");
s.push("id=\""+bid+"\" ");
s.push("value=\""+btn.getValue()+"\" ");
s.push("title=\""+btn.getTooltip()+"\" ");
s.push("onClick=\"es.ui.onButtonClicked(this);\"> ");
s=s.join("");
}
}
return mb.log.exit(s);
};
this.writeButton=function(){
mb.log.enter(this.GID,"writeButton");
var btn=null,bid=arguments[0];
if((btn=this.getButtonHtml(bid))!=null){
if(arguments.length>1){
for(var i=1;i<arguments.length;i++){
btn=btn.replace(/\$/,"'"+arguments[i]+"'");
}
}
document.write(btn);
}else{
mb.log.error("Button with id: $ not registered!",id);
}
mb.log.exit();
};
this.setupFormFields=function(){
mb.log.enter(es.ui.GID,"setupFormFields");
var all=mb.ui.getByTag("input");
var l=all.length;
var cn,el,log,id,type,name,value;
var _105,hasOnFocus,hasOnBlur,isToolboxEnabled=es.qf.isToolboxEnabled();
for(var i=0;i<l;i++){
el=all[i];
id=el.id;
value=(el.value||"");
name=(el.name||"noname");
type=(el.type||"notype");
cn=(el.className||"");
log=[];
if(el&&type=="text"&&cn.match(/textfield/)){
el.style.width=this.TEXTFIELD_SIZE+"px";
_105=!cn.match(/hidden|header|oldvalue/i);
if(_105){
el.onfocus=function onfocus(_107){
es.ui.handleFocus(this);
};
el.onblur=function onblur(_108){
es.ui.handleBlur(this);
};
if(isToolboxEnabled){
es.qf.addToolboxIcon(el);
log.push("toolbox");
}
}else{
el.onfocus=function onfocus(_109){
return false;
};
el.onblur=function onblur(_10a){
};
if(isToolboxEnabled){
es.qf.addToolboxDummy(el);
log.push("toolbox dummy");
}
}
}
if(el&&type=="button"&&value==""){
var oid=id,btn=null,bid=oid.split("|")[0];
if((btn=es.ui.buttonRegistry[bid])!=null){
el.value=btn.getValue();
el.title=btn.getTooltip();
el.className="button";
el.style.display="inline";
el.onclick=function onclick(_10c){
es.ui.onButtonClicked(this);
};
log.push("Registered: "+bid);
}
}
if(log.length>0){
mb.log.debug("Handled $, id: $ ("+log.join(", ")+")",type,id||name);
}
}
mb.log.exit();
};
this.onButtonClicked=function(el){
mb.log.scopeStart("Handling click on button");
mb.log.enter(this.GID,"onButtonClicked");
if(el){
if(el.id){
mb.log.trace("Button $ was clicked",el.id);
var id=el.id,args=id.split("|");
var btn,bid=args[0];
if((btn=es.ui.buttonRegistry[bid])!=null){
var f=btn.func;
mb.log.trace("Arguments: $",args);
for(var j=1;j<args.length;j++){
f=f.replace(/\$/,"'"+args[j]+"'");
}
try{
eval(f);
}
catch(e){
mb.log.error("Caught exception in eval'd code! ex: $, f: $",(e.message||"?"),f);
mb.log.error(mb.log.getStackTrace());
}
}else{
mb.log.error("Button $ not found in registry!",id);
}
}else{
mb.log.error("Button has no id set!");
}
mb.log.trace("Done.");
}else{
mb.log.error("Required parameter el is missing.");
}
mb.log.exit();
mb.log.scopeEnd();
};
this.cancelForm=function(url){
if(url){
document.location.replace(url);
}
};
this.getFocusField=function(){
return this.focusField;
};
this.setFocusField=function(_113){
this.focusField=_113;
};
this.getFocusValue=function(){
return this.focusValue;
};
this.setFocusValue=function(v){
this.focusValue=v;
};
this.getFormField=function(){
return mb.ui.get(this.FORMFIELD_ID);
};
this.getForm=function(){
if(!this.formRef){
var obj;
if((obj=this.getFormField())!=null){
this.formRef=obj.form;
}
}
return this.formRef;
};
this.getField=function(fid,_117){
_117=(_117||false);
mb.log.enter(this.GID,"getField");
var f,fr;
if((f=this.getForm())!=null){
if((fr=f[fid])==null){
if(!_117){
mb.log.error("Field $ does not exist in form...",fid);
}
}
return mb.log.exit(fr);
}else{
mb.log.error("Form f not found!");
}
return mb.log.exit(null);
};
this.resetSelection=function(){
if(typeof document.selection!="undefined"){
try{
document.selection.empty();
}
catch(e){
}
}else{
try{
if((this.focusField!=null)&&(this.focusField.selectionStart!="undefined")){
this.focusField.selectionStart=0;
this.focusField.selectionEnd=0;
}
}
catch(e){
}
}
};
this.handleFocus=function(_119){
mb.log.scopeStart("Handling onfocus event on field: "+_119.name);
mb.log.enter(this.GID,"handleFocus");
var cn=null;
if(this.focusField){
cn=((cn=this.focusField.className)!=null?cn:"");
if(cn.indexOf(" focus")!=-1){
this.focusField.className=cn.replace(/\s+focus/i,"");
}
}
if(_119&&_119.className){
if(_119.className.indexOf(" focus")==-1){
_119.className+=" focus";
}
this.setFocusField(_119);
this.setFocusValue(_119.value);
es.qf.updateToolbox(_119);
if(_119.value=="?:??"){
_119.value="";
}
}
mb.log.exit();
};
this.handleBlur=function(_11b){
mb.log.scopeStart("Handling onblur event on field: "+_11b.name);
mb.log.enter(this.GID,"handleBlur");
var _11c=_11b.value;
var _11d=this.getFocusValue();
if(_11d=="?:??"&&_11c==""){
_11b.value=_11d;
}
if(this.isFocusField(_11b)&&_11d!=_11b.value){
es.ur.addUndo(es.ur.createItem(_11b,"manual",_11d,_11c));
}
mb.log.exit();
};
this.isFocusField=function(_11e){
return (this.getFocusField()==_11e);
};
this.getResizableFields=function(){
mb.log.enter(this.GID,"getResizableFields");
var _11f=[];
if(this.getForm()){
_11f=this.getFieldsWalker(this.re.RESIZEABLEFIELD,null);
}
mb.log.exit();
return _11f;
};
this.getEditTextFields=function(){
mb.log.enter(this.GID,"getEditTextFields");
var _120=[];
if(this.getForm()){
_120=this.getFieldsWalker(this.re.TEXTFIELD,null);
}
mb.log.exit();
return _120;
};
this.getArtistFields=function(){
mb.log.enter(this.GID,"getArtistFields");
var _121=[];
if(this.getForm()){
_121=this.getFieldsWalker(this.re.TEXTFIELD,this.re.ARTISTFIELD);
}
mb.log.exit();
return _121;
};
this.getAlbumNameField=function(){
mb.log.enter(this.GID,"getAlbumNameField");
var _122=[];
if(this.getForm()){
_122=this.getFieldsWalker(this.re.TEXTFIELD,this.re.ALBUMFIELD);
}
return (_122[0]||null);
};
this.getTrackNameFields=function(){
mb.log.enter(this.GID,"getTrackNameFields");
var _123=[];
if(this.getForm()){
_123=this.getFieldsWalker(this.re.TEXTFIELD,this.re.TRACKFIELD);
}
mb.log.exit();
return _123;
};
this.getTrackTimeFields=function(){
mb.log.enter(this.GID,"getTrackTimeFields");
var _124=[];
if(this.getForm()){
_124=this.getFieldsWalker(this.re.NUMBERFIELD,this.re.TRACKLENGTHFIELD);
}
mb.log.exit();
return _124;
};
this.getFieldsWalker=function(cnRE,_126){
var _127=[];
var f,el;
if((f=this.getForm())!=null){
for(var i=0;i<f.elements.length;i++){
if((el=f.elements[i])!=null){
var cn=(el.className||"");
var name=(el.name||"");
var type=(el.type||"");
var bCN=(cnRE==null||(cnRE!=null&&cn.match(cnRE)));
var _12e=(_126==null||(_126!=null&&name.match(_126)));
if((type=="text")&&bCN&&_12e){
_127.push(el);
}
}
}
}
return _127;
};
this.setDisabled=function(el,flag){
var obj=null;
if((obj=mb.ui.get(el))!=null){
if(obj.disabled!=null){
obj.disabled=flag;
}
}
};
mb.log.exit();
}
try{
EsUiModule.prototype=new EsModuleBase;
}
catch(e){
mb.log.error("EsUiModule: Could not register EsModuleBase prototype");
}
function EsUndoItem(){
mb.log.enter("EsUndoItem","__constructor");
this.CN="EsUndoItem";
var args=arguments[0];
this._field=args[0];
this._op=args[1];
this._old=args[2];
this._new=args[3];
this.getField=function(){
return this._field;
};
this.getOp=function(){
return this._op;
};
this.getOld=function(){
return this._old;
};
this.getNew=function(){
return this._new;
};
this.setField=function(v){
this._field=v;
};
this.setOp=function(v){
this._op=v;
};
this.setOld=function(v){
this._old=v;
};
this.setNew=function(v){
this._new=v;
};
this.toString=function(){
var s=[this.CN];
s.push(" [field=");
s.push(this.getField().name);
s.push(", op=");
s.push(this.getOp());
s.push(", old=");
s.push(this.getOld());
s.push(", new=");
s.push(this.getNew());
s.push("]");
return s.join("");
};
mb.log.exit();
}
function EsUndoItemList(){
mb.log.enter("EsUndoItemList","__constructor");
this.CN="EsUndoItemList";
var args=arguments[0];
this._list=[];
for(var i=0;i<args.length;i++){
if(args[i] instanceof EsUndoItem){
this._list.push(args[i]);
}
}
this.getList=function(){
return this._list;
};
this.iterate=function(){
this._cnt=0;
};
this.getNext=function(){
return this._list[this._cnt++];
};
this.hasNext=function(){
return this._cnt<this._list.length;
};
this.toString=function(){
var s=[this.CN];
s.push(" [");
s.push(this.getList().join(", "));
s.push("]");
return s.join("");
};
mb.log.exit();
}
function EsUndoModule(){
mb.log.enter("EsUndoModule","__constructor");
this.CN="EsUndoModule";
this.GID="es.ur";
this.getModID=function(){
return "es.ur";
};
this.getModName=function(){
return "Undo/Redo";
};
this.stack=[];
this.index=0;
this.UNDO_LIST="UNDO_LIST";
this.STATUS_EXPANDED=this.getModID()+"-text-expanded";
this.STATUS_COLLAPSED=this.getModID()+"-text-collapsed";
this.BTN_UNDO_ALL="BTN_UNDO_ALL";
this.BTN_UNDO_ONE="BTN_UNDO_ONE";
this.BTN_REDO_ONE="BTN_REDO_ONE";
this.BTN_REDO_ALL="BTN_REDO_ALL";
this.setupModuleDelegate=function(){
this.DEFAULT_VISIBLE=true;
this.DEFAULT_EXPANDED=true;
es.ui.registerButtons(new EsButton(this.BTN_UNDO_ALL,"Undo All","Undo all changes","es.ur.undoAllSteps()"),new EsButton(this.BTN_UNDO_ONE,"Undo","Undo the last change","es.ur.undoStep()"),new EsButton(this.BTN_REDO_ONE,"Redo","Redo the last undid change","es.ur.redoStep()"),new EsButton(this.BTN_REDO_ALL,"Redo All","Redo all the undid changes","es.ur.redoAllSteps()"));
};
this.getModuleHtml=function(){
var s=[];
var _13c="Steps 0/0";
s.push(this.getModuleStartHtml({x:true}));
s.push(es.ui.getButtonHtml(this.BTN_UNDO_ALL));
s.push(es.ui.getButtonHtml(this.BTN_UNDO_ONE));
s.push(es.ui.getButtonHtml(this.BTN_REDO_ONE));
s.push(es.ui.getButtonHtml(this.BTN_REDO_ALL));
s.push("<small><span id=\""+this.STATUS_EXPANDED+"\">"+_13c+"</span><small>");
s.push(this.getModuleEndHtml({x:true}));
s.push(this.getModuleStartHtml({x:false,dt:_13c}));
s.push(this.getModuleEndHtml({x:false}));
return s.join("");
};
this.onModuleHtmlWrittenDelegate=function(){
es.ui.setDisabled(this.BTN_UNDO_ALL,true);
es.ui.setDisabled(this.BTN_UNDO_ONE,true);
es.ui.setDisabled(this.BTN_REDO_ONE,true);
es.ui.setDisabled(this.BTN_REDO_ALL,true);
};
this.createItem=function(){
return new EsUndoItem(arguments);
};
this.createItemList=function(){
return new EsUndoItemList(arguments);
};
this.addUndo=function(_13d){
mb.log.enter(this.GID,"addUndo");
this.stack=this.stack.slice(0,this.index);
this.stack.push(_13d);
this.index=this.stack.length;
var f=null;
var ff=es.ui.getFocusField();
if(_13d instanceof EsUndoItemList){
var _140=_13d;
for(_140.iterate();_140.hasNext();){
_13d=_140.getNext();
if(_13d.getField()==ff){
es.ui.setFocusValue(_13d.getNew());
}
}
}else{
if(_13d.getField()==ff){
es.ui.setFocusValue(_13d.getNew());
}
}
this.updateUI();
mb.log.exit();
};
this.undoStep=function(){
mb.log.enter(this.GID,"undoStep");
if(this.stack.length>0){
if(this.index>0){
var _141=this.stack[--this.index];
var f,o;
if(_141 instanceof EsUndoItemList){
mb.log.info("Undoing combined step...");
for(_141.iterate();_141.hasNext();){
o=_141.getNext();
f=o.getField();
f.value=o.getOld();
mb.log.debug("* op: $, field: $, value: $",o.getOp(),f.name,f.value);
}
}else{
mb.log.info("Undoing single step...");
o=_141;
f=o.getField();
f.value=o.getOld();
mb.log.debug("* op: $, field: $, value: $",o.getOp(),f.name,f.value);
}
this.updateUI();
es.ui.resetSelection();
}
}
mb.log.exit();
};
this.redoStep=function(_143){
mb.log.enter(this.GID,"redoStep");
if(this.index<this.stack.length){
var _144=this.stack[this.index];
var f,o;
if(_144 instanceof EsUndoItemList){
mb.log.info("Redoing combined step...");
for(_144.iterate();_144.hasNext();){
o=_144.getNext();
f=o.getField();
f.value.value=o.getNew();
mb.log.debug("* op: $, field: $, value: $",o.getOp(),f.name,f.value);
}
}else{
mb.log.info("Redoing single step...");
o=_144;
f=o.getField();
f.value=o.getNew();
mb.log.debug("* op: $, field: $, value: $",o.getOp(),f.name,f.value);
}
this.index++;
this.updateUI();
es.ui.resetSelection();
}
mb.log.exit();
};
this.undoAllSteps=function(){
mb.log.enter(this.GID,"undoAllSteps");
mb.log.info("Undoing $ steps",this.stack.length);
if(this.stack.length>0){
while(this.index>0){
this.undoStep(true);
}
}
mb.log.exit();
};
this.redoAllSteps=function(){
mb.log.enter(this.GID,"redoAllSteps");
mb.log.info("Redoing $ steps",(this.stack.length-this.index));
while(this.index<this.stack.length){
this.redoStep(true);
}
mb.log.exit();
};
this.updateUI=function(){
var f;
if((f=es.ui.getForm())!=null){
es.ui.setDisabled(this.BTN_UNDO_ONE,(this.index==0));
es.ui.setDisabled(this.BTN_REDO_ONE,(this.index==this.stack.length));
es.ui.setDisabled(this.BTN_UNDO_ALL,(this.index==0));
es.ui.setDisabled(this.BTN_REDO_ALL,(this.index==this.stack.length));
var obj=null;
if((obj=mb.ui.get(this.STATUS_COLLAPSED))!=null){
obj.innerHTML="Steps: "+this.index+"/"+this.stack.length;
}
if((obj=mb.ui.get(this.STATUS_EXPANDED))!=null){
obj.innerHTML="Steps: "+this.index+"/"+this.stack.length;
}
}
};
mb.log.exit();
}
try{
EsUndoModule.prototype=new EsModuleBase;
}
catch(e){
mb.log.error("EsUndoModule: Could not register EsModuleBase prototype");
}
function GcFix(name,re,_14a){
mb.log.enter("GcFix","__constructor");
this.CN="GcFix";
this._name=name;
this._re=re;
this._replace=_14a;
this.getName=function(){
return this._name;
};
this.getRe=function(){
return this._re;
};
this.getReplace=function(){
return this._replace;
};
mb.log.exit();
}
function GcFlags(){
mb.log.enter("GcFlags","__constructor");
this.CN="GcFlags";
this.GID="gc.f";
this.resetContext=function(){
mb.log.enter(this.GID,"resetContext");
this.whitespace=false;
this.openingBracket=false;
this.hypen=false;
this.colon=false;
this.acronym_split=false;
this.singlequote=false;
this.ellipsis=false;
mb.log.exit();
};
this.resetSeriesNumberStyleFlags=function(){
this.disc=false;
this.part=false;
this.volume=false;
this.feat=false;
};
this.resetOutputFlags=function(){
this.forceCaps=true;
this.spaceNextWord=false;
};
this.resetBrackets=function(){
this.openBrackets=new Array();
this.slurpExtraTitleInformation=false;
};
this.isInsideBrackets=function(){
return (this.openBrackets.length>0);
};
this.pushBracket=function(b){
this.openBrackets.push(b);
};
this.popBracket=function(b){
if(this.openBrackets.length==0){
return null;
}else{
var cb=this.getCurrentCloseBracket();
this.openBrackets.pop();
return cb;
}
};
this.getOpenedBracket=function(b){
if(this.openBrackets.length==0){
return null;
}else{
return this.openBrackets[this.openBrackets.length-1];
}
};
this.getCurrentCloseBracket=function(){
var ob;
if((ob=this.getOpenedBracket())!=null){
return gc.u.getCorrespondingBracket(ob);
}
return null;
};
this.init=function(){
this.resetOutputFlags();
this.resetBrackets();
this.resetContext();
this.resetSeriesNumberStyleFlags();
this.acronym=false;
this.number=false;
this.numberSplitChar=null;
this.numberSplitExpect=false;
};
this.dumpRaisedFlags=function(){
var s=this.toString();
if(s!=""){
mb.log.debug("Current flags: [$]",s);
}else{
mb.log.debug("No specific flags set!");
}
};
this.toString=function(){
var dump=[];
var nl=", ";
if(!gc.fdef){
gc.fdef=new GcFlags();
gc.fdef.init();
}
if(!gc.i.isFirstWord()&&this.forceCaps==gc.fdef.forceCaps){
dump.push(nl);
dump.push("forceCaps="+this.forceCaps);
}
if(!gc.i.isFirstWord()&&this.spaceNextWord==gc.fdef.spaceNextWord){
dump.push(nl);
dump.push("spaceNextWord="+this.spaceNextWord);
}
if(this.whitespace!=gc.fdef.whitespace){
dump.push(nl);
dump.push("whitespace="+this.whitespace);
}
if(this.openingBracket!=gc.fdef.openingBracket){
dump.push(nl);
dump.push("openingBracket="+this.openingBracket);
}
if(this.hypen!=gc.fdef.hypen){
dump.push(nl);
dump.push("hypen="+this.hypen);
}
if(this.colon!=gc.fdef.colon){
dump.push(nl);
dump.push("colon="+this.colon);
}
if(this.acronym_split!=gc.fdef.acronym_split){
dump.push(nl);
dump.push("acronym_split="+this.acronym_split);
}
if(this.singlequote!=gc.fdef.singlequote){
dump.push(nl);
dump.push("singlequote="+this.singlequote);
}
if(this.ellipsis!=gc.fdef.ellipsis){
dump.push(nl);
dump.push("ellipsis="+this.ellipsis);
}
if(this.disc!=gc.fdef.disc){
dump.push(nl);
dump.push("disc="+this.disc);
}
if(this.part!=gc.fdef.part){
dump.push(nl);
dump.push("part="+this.part);
}
if(this.volume!=gc.fdef.volume){
dump.push(nl);
dump.push("volume="+this.volume);
}
if(this.feat!=gc.fdef.feat){
dump.push(nl);
dump.push("feat="+this.feat);
}
if(dump.length>1){
dump[0]=null;
}else{
dump=[];
}
return dump.join("");
};
mb.log.exit();
}
function GcInput(){
mb.log.enter("GcInput","__constructor");
this.CN="GcInput";
this.GID="gc.i";
this._source="";
this._w=[];
this._l=0;
this._wi=0;
this.init=function(is,w){
mb.log.enter(this.GID,"init");
mb.log.debug("words: $",w);
this._source=(is||"");
this._w=(w||[]);
this._l=this._w.length;
this._wi=0;
mb.log.exit();
};
this.toString=function(){
return this.CN+" ["+this._w.join(",")+"]";
};
this.getLength=function(){
return this._l;
};
this.isEmpty=function(){
var f=(this.getLength()==0);
return f;
};
this.getPos=function(){
return this._wi;
};
this.setPos=function(_156){
if(_156>=0&&_156<this.getLength()){
this._wi=_156;
}
};
this.getWordAtIndex=function(_157){
if(this._w[_157]){
return this._w[_157];
}else{
return null;
}
};
this.getNextWord=function(){
return this.getWordAtIndex(this._wi+1);
};
this.getCurrentWord=function(){
return this.getWordAtIndex(this._wi);
};
this.getPreviousWord=function(){
return this.getWordAtIndex(this._wi-1);
};
this.isFirstWord=function(){
return (0==this._wi);
};
this.isLastWord=function(){
return (this.getLength()==this._wi-1);
};
this.isNextWord=function(s){
return (this.hasMoreWords()&&this.getNextWord()==s);
};
this.isPreviousWord=function(s){
return (!this.isFirstWord()&&this.getPreviousWord()==s);
};
this.matchCurrentWord=function(re){
mb.log.enter(this.GID,"matchCurrentWord");
var f=(this.matchWordAtIndex(this.getPos(),re));
return mb.log.exit(f);
};
this.matchWordAtIndex=function(_15c,re){
mb.log.enter(this.GID,"matchWordAtIndex");
var cw=(this.getWordAtIndex(_15c)||"");
var f;
if(mb.utils.isString(re)){
f=(re==cw);
if(f){
mb.log.debug("Matched w: $ at index: $, string: $",cw,_15c,re);
}
}else{
f=(cw.match(re)!=null);
if(f){
mb.log.debug("Matched w: $ at index: $, re: $",cw,_15c,re);
}
}
return mb.log.exit(f);
};
this.hasMoreWords=function(){
return (this._wi==0&&this.getLength()>0||this._wi-1<this.getLength());
};
this.isIndexAtEnd=function(){
return (this._wi==this.getLength());
};
this.nextIndex=function(){
this._wi++;
};
this.dropLastWord=function(){
if(this.getLength()>0){
this._w.pop();
if(this.isIndexAtEnd()){
this._wi--;
}
}
};
this.insertWordsAtIndex=function(_160,w){
mb.log.enter(this.GID,"insertWordsAtIndex");
var _162=this._w.slice(0,_160);
var _163=this._w.slice(_160,this._w.length);
this._w=_162.concat(w).concat(_163);
this._l=this._w.length;
mb.log.debug("Inserted $ at index $",w,_160);
mb.log.exit();
};
this.capitalizeCurrentWord=function(){
mb.log.enter(this.GID,"capitalizeCurrentWord");
var w;
if((w=this.getCurrentWord())!=null){
var o=gc.u.titleString(w);
if(w!=o){
this.updateCurrentWord(o);
mb.log.debug("Before: $, After: $",w,o);
}
return mb.log.exit(o);
}else{
mb.log.error("Attempted to modify currentWord, but it is null!");
}
return mb.log.exit(null);
};
this.updateCurrentWord=function(o){
mb.log.enter(this.GID,"updateCurrentWord");
var w=this.getCurrentWord();
if(w!=null){
this._w[this._wi]=o;
}else{
mb.log.error("Attempted to modify currentWord, but it is null!");
}
mb.log.exit();
};
this.insertWordAtEnd=function(w){
mb.log.enter(this.GID,"insertWordAtEnd");
mb.log.debug("Added word $ at the end",w);
this._w[this._w.length]=w;
this._l++;
mb.log.exit();
};
this.splitWordsAndPunctuation=function(is){
mb.log.enter(this.GID,"splitWordsAndPunctuation");
is=is.replace(/^\s\s*/,"");
is=is.replace(/\s\s*$/,"");
is=is.replace(/\s\s*/g," ");
var _16a=is.split("");
var _16b=[];
var word=[];
if(!gc.re.SPLITWORDSANDPUNCTUATION){
gc.re.SPLITWORDSANDPUNCTUATION=/[^!\"%&'??`()\[\]\{\}\*\+,-\.\/:;<=>\?\s#]/;
}
for(var i=0;i<_16a.length;i++){
if(_16a[i].match(gc.re.SPLITWORDSANDPUNCTUATION)){
word.push(_16a[i]);
}else{
if(word.length>0){
_16b.push(word.join(""));
}
_16b.push(_16a[i]);
word=[];
}
}
if(word.length>0){
_16b.push(word.join(""));
}
mb.log.debug("words: $",_16b);
return mb.log.exit(_16b);
};
mb.log.exit();
}
function GcMode(_16e,name,lang,desc,url){
mb.log.enter("GcMode","__constructor");
this.CN="GcMode";
this.GID="gc.mode";
this._modes=_16e;
this._name=name;
this._lang=lang;
this._desc=(desc||"");
this._url=(url||"");
this._id=null;
this.getID=function(){
if(!this._id){
var s=(this._name+" "+this._lang).toLowerCase();
s=s.replace(/\s*/g,"");
s=s.replace(/\([^\)]*\)/g,"");
this._id=s;
}
return this._id;
};
this.getName=function(){
return this._name;
};
this.getURL=function(){
return this._url;
};
this.getLanguage=function(){
return this._lang;
};
this.getDescription=function(){
var s=this._desc;
s=s.replace("[url]","<a href=\""+this.getURL()+"\" target=\"_blank\">"+this.getName()+" ");
s=s.replace("[/url]","</a>");
return s;
};
this.isSentenceCaps=function(){
mb.log.enter(this.GID,"isSentenceCaps");
var f=!(this._modes.EN==this.getLanguage());
return mb.log.exit(f);
};
this.toString=function(){
var s=[];
s.push(this.CN);
s.push(" [");
s.push("id: ");
s.push(this.getID());
s.push(", SentenceCaps: ");
s.push(this.isSentenceCaps());
s.push("]");
return s.join("");
};
mb.log.exit();
}
function GcModes(){
mb.log.enter("GcModes","__constructor");
this.CN="GcModes";
this.GID="es.gc.modes";
this.EN="en";
this.XX="xx";
this.DE="de";
this.ES="es";
this.FR="fr";
this.IT="it";
this.NO="no";
this.MODES_DROPDOWN="GC_MODES_DROPDOWN";
this.DEFAULT_TEXT="Read the [url]description[/url] for more details.";
this.SENTENCECAPS_TEXT="First word titled, lowercase for <i>most</i> of the other words. Read the [url]description[/url] for more details.";
this.MODES_INDEX=0;
this.MODES_LIST=[new GcMode(this,"Default (English)",this.EN,this.DEFAULT_TEXT,"http://wiki.musicbrainz.org/GuessCaseMode/DefaultMode"),new GcMode(this,"SentenceMode",this.XX,this.SENTENCECAPS_TEXT,"http://wiki.musicbrainz.org/GuessCaseMode/SentenceMode")];
this.getDefaultMode=function(){
mb.log.enter(this.GID,"getDefaultMode");
if(!this.DEFAULT_MODE){
this.DEFAULT_MODE=this.MODES_LIST[0];
}
return mb.log.exit(this.DEFAULT_MODE);
};
this.getArtistMode=function(){
mb.log.enter(this.GID,"getArtistMode");
if(!this.ARTIST_MODE){
this.ARTIST_MODE=new GcMode(this,"Artist",this.EN);
}
return mb.log.exit(this.ARTIST_MODE);
};
this.getModeFromID=function(_177,_178){
mb.log.enter(this.GID,"getModeFromID");
var mode=null;
for(var i=0;i<this.MODES_LIST.length;i++){
mode=this.MODES_LIST[i];
if(mode){
if(mode.getID()!=_177){
mode=null;
}else{
break;
}
}
}
mb.log.debug("Id: $, mode: $",_177,(mode||"undefined"));
return mb.log.exit(mode);
};
this.onModeChanged=function(el){
mb.log.scopeStart("Handle selection on the Mode Dropdown");
mb.log.enter(this.GID,"onModeChanged");
if((el&&el.options)&&(el.id==this.MODES_DROPDOWN)){
var si=el.selectedIndex;
var _17d=el.options[si].value;
if(_17d!=""){
mb.log.debug("New ModeId: $",_17d);
if(_17d!=es.gc.getMode().getID()){
es.gc.setMode(_17d);
mb.cookie.set(es.gc.COOKIE_MODE,_17d,365);
mb.log.debug("Changed mode to: $",_17d);
this.updateUI();
}else{
mb.log.debug("No mode change required...");
}
}
}else{
mb.log.error("Unsupported element: $",(el.name||"?"));
}
mb.log.exit();
mb.log.scopeEnd();
};
this.getDropdownHtml=function(id,mod,sm){
mb.log.enter(this.GID,"getDropdownHtml");
id=(id||this.MODES_DROPDOWN);
mod=(mod||this.GID);
sm=(sm||es.gc.getMode());
mb.log.debug("Id: $, Mod: $, Sm: $",id,mod,sm);
var ev=mod+".onModeChanged(this)";
var smid=sm.getID(),m,mid,s=[];
s.push("<select id=\""+id+"\" onChange=\""+ev+"\">");
for(var i=0;i<this.MODES_LIST.length;i++){
m=this.MODES_LIST[i];
if(m!=null){
mid=m.getID();
s.push("<option value=\"");
s.push(mid);
s.push("\" ");
s.push((smid==mid?"selected":""));
s.push(">");
s.push(m.getName());
s.push("</option>");
}else{
s.push("<option value=\"\">---------------------</option>");
}
}
s.push("</select>");
s=s.join("");
return mb.log.exit(s);
};
this.updateUI=function(mode){
mb.log.enter(this.GID,"updateUI");
var m=es.gc.getMode();
var obj;
if((obj=mb.ui.get(es.gc.getModID()+"-text-collapsed"))!=null){
obj.innerHTML=m.getDescription();
}
if((obj=mb.ui.get(es.gc.getModID()+"-text-expanded"))!=null){
obj.innerHTML=m.getDescription();
}
mb.log.exit();
};
this.useModeFromUI=function(){
mb.log.enter(this.GID,"useModeFromUI");
var obj;
if((obj=mb.ui.get(this.MODES_DROPDOWN))!=null){
var _188=obj.options[obj.selectedIndex].value;
if(_188!=""){
es.gc.setMode(_188);
}
}else{
mb.log.error("Unsupported element: $",this.MODES_DROPDOWN);
}
mb.log.exit();
};
mb.log.exit();
}
function GcOutput(){
mb.log.enter("GcOutput","__constructor");
this.CN="GcOutput";
this.GID="gc.o";
this._w=[];
this.init=function(){
this._w=[];
this._output="";
};
this.toString=function(){
return this.CN;
};
this.getLength=function(){
return this._w.length;
};
this.isEmpty=function(){
var f=(this.getLength()==0);
return f;
};
this.appendCurrentWord=function(){
mb.log.enter(this.GID,"appendWord");
var w;
if((w=gc.i.getCurrentWord())!=null){
this.appendWord(w);
}
mb.log.exit();
};
this.appendWord=function(w){
mb.log.enter(this.GID,"appendWord");
if(w==" "){
gc.o.appendSpace();
}else{
if(w!=""&&w!=null){
mb.log.debug("Added $ to output.",w);
this._w[this._w.length]=w;
}
}
mb.log.exit();
};
this.appendSpace=function(){
mb.log.enter(this.GID,"appendSpace");
this._w[this._w.length]=" ";
mb.log.exit();
};
this.appendSpaceIfNeeded=function(){
mb.log.enter(this.GID,"appendSpaceIfNeeded");
if(gc.f.spaceNextWord){
gc.o.appendSpace();
}
mb.log.exit();
};
this.getWordAtIndex=function(_18c){
if(this._w[_18c]){
return this._w[_18c];
}else{
return null;
}
};
this.setWordAtIndex=function(_18d,word){
if(this.getWordAtIndex(_18d)){
this._w[_18d]=word;
}
};
this.getLastWord=function(){
if(!this.isEmpty()){
return this._w[this._w.length-1];
}else{
return null;
}
};
this.dropLastWord=function(){
if(!this.isEmpty()){
return this._w.pop();
}
return null;
};
this.capitalizeWordAtIndex=function(_18f){
mb.log.enter(this.GID,"capitalizeWordAtIndex");
gc.f.forceCaps=true;
if((!gc.getMode().isSentenceCaps())&&(!this.isEmpty())&&(this.getWordAtIndex(_18f)!=null)){
var w=this.getWordAtIndex(_18f),o=w;
if(w.match(/^\w\..*/)==null){
var _191=gc.u.trim(w.toLowerCase());
if(gc.f.isInsideBrackets()&&gc.u.isLowerCaseBracketWord(_191)){
}else{
if(gc.u.isUpperCaseWord(_191)){
}else{
o=gc.u.titleString(w);
if(w!=o){
this.setWordAtIndex(_18f,o);
mb.log.debug("index=$/$, before: $, after: $",_18f,this.getLength()-1,w,o);
}
}
}
}
}
mb.log.exit();
};
this.capitalizeLastWord=function(){
mb.log.enter(this.GID,"capitalizeLastWord");
mb.log.debug("Capitalizing last word... index: $",this.getLength()-1);
this.capitalizeWordAtIndex(this.getLength()-1);
mb.log.exit();
};
this.getOutput=function(){
mb.log.enter(this.GID,"getOutput");
mb.log.debug("Collecting words...");
gc.f.forceCaps=true;
this.capitalizeLastWord();
this.closeOpenBrackets();
var os=gc.u.trim(this._w.join(""));
return mb.log.exit(os);
};
this.closeOpenBrackets=function(){
mb.log.enter(this.GID,"closeOpenBrackets");
mb.log.debug("Open brackets stack: $",gc.f.openBrackets);
var _193=new Array();
while(gc.f.isInsideBrackets()){
_193[_193.length]=gc.f.popBracket();
}
this.appendWord(_193.join(""));
mb.log.exit();
};
this.appendWordPreserveWhiteSpace=function(c){
if(c){
var ws={before:gc.i.isPreviousWord(" "),after:gc.i.isNextWord(" ")};
if(c.apply){
mb.log.debug("Consumed #cw, space before: $, after: $",ws.before,ws.after);
if(c.capslast){
this.capitalizeLastWord();
}
if(ws.before){
this.appendSpace();
}
this.appendCurrentWord();
gc.f.spaceNextWord=(ws.after);
}
return ws;
}
return null;
};
mb.log.exit();
}
function GcUtils(){
mb.log.enter("GcUtils","__constructor");
this.CN="GcUtils";
this.GID="gc.u";
this.toAssocArray=function(a){
var t=[];
try{
for(var m=0;m<a.length;m++){
var curr=a[m].toLowerCase();
t[curr]=curr;
}
}
catch(e){
}
return t;
};
this.inArray=function(a,k){
mb.log.enter(this.GID,"inArray");
if(a==null||k==null){
mb.log.error("One of key/array is null. k: $, a: $",k,a);
return mb.log.exit(false);
}
k=k.toLowerCase();
var v=(a[k]||null);
var f=(k!=null&&a!=null&&v!=null&&v==k&&typeof (v)=="string");
return mb.log.exit(f);
};
this.isSomeWord=function(w){
if(!this.someWord){
this.someWord=this.toAssocArray([]);
}
return this.inArray(this.someWord,w);
};
this.getLowerCaseWords=function(lang){
lang=(lang||"en");
var _1a0=[];
_1a0["en"]=["a","and","n","an","as","at","but","by","for","in","nor","of","o","on","or","the","to","tha"];
return _1a0[lang];
};
this.isLowerCaseWord=function(w){
mb.log.enter(this.GID,"isLowerCaseWord");
if(!this.lowerCaseWords){
this.lowerCaseWords=this.toAssocArray(this.getLowerCaseWords());
}
var f=this.inArray(this.lowerCaseWords,w);
mb.log.debug("$=$",w,f);
return mb.log.exit(f);
};
this.getPrepBracketSingleWords=function(){
return ["acoustic","album","alternate","bonus","clean","club","dance","dirty","extended","instrumental","live","original","radio","take","disc","mix","version","feat","cut","vocal","alternative","megamix","disco","video","dub","long","short","main","composition","session","rework","reworked","remixed","dirty","airplay"];
};
this.isPrepBracketSingleWord=function(w){
mb.log.enter(this.GID,"isPrepBracketSingleWord");
if(!this.preBracketSingleWords){
this.preBracketSingleWords=this.toAssocArray(this.getPrepBracketSingleWords());
}
var f=this.inArray(this.preBracketSingleWords,w);
mb.log.debug("$=$",w,f);
return mb.log.exit(f);
};
this.getUpperCaseWords=function(){
return ["dj","mc","tv","mtv","ep","lp","ymca","nyc","ny","ussr","usa","r&b","bbc","fm","bc","ac","dc","uk","bpm","ok","nba","rv","kv","bwv","rza","gza","odb","dmx","2xlc"];
};
this.getRomanNumberals=function(){
return ["i","ii","iii","iv","v","vi","vii","viii","ix","x"];
};
this.isUpperCaseWord=function(w){
mb.log.enter(this.GID,"isUpperCaseWord");
if(!this.upperCaseWords){
this.upperCaseWords=this.toAssocArray(this.getUpperCaseWords());
}
if(!this.romanNumerals){
this.romanNumerals=this.toAssocArray(this.getRomanNumberals());
}
var f=this.inArray(this.upperCaseWords,w);
if(!f&&gc.isConfigTrue(gc.CFG_UC_ROMANNUMERALS)){
f=this.inArray(this.romanNumerals,w);
}
mb.log.debug("$=$",w,f);
return mb.log.exit(f);
};
this.getLowerCaseBracketWords=function(){
return ["acoustic","album","alternate","bonus","clean","dirty","disc","extended","instrumental","live","original","radio","single","take","demo","club","dance","edit","skit","mix","remix","version","reprise","megamix","maxi","feat","interlude","dub","dialogue","cut","karaoke","vs","vocal","alternative","disco","unplugged","video","outtake","outtakes","rehearsal","intro","outro","long","short","main","remake","clubmix","composition","reinterpreted","session","rework","reworked","remixed","reedit","airplay","a_cappella"];
};
this.isLowerCaseBracketWord=function(w){
mb.log.enter(this.GID,"isLowerCaseBracketWord");
if(!this.lowerCaseBracketWords){
this.lowerCaseBracketWords=this.toAssocArray(this.getLowerCaseBracketWords());
}
var f=this.inArray(this.lowerCaseBracketWords,w);
mb.log.debug("$=$",w,f);
return mb.log.exit(f);
};
this.isPrepBracketWord=function(w){
mb.log.enter(this.GID,"isPrepBracketWord");
if(!this.prepBracketWords){
this.prepBracketWords=this.toAssocArray(new Array("cd","disk","12\"","7\"","a_cappella","re_edit").concat(this.getLowerCaseBracketWords()));
}
var f=this.inArray(this.prepBracketWords,w);
mb.log.debug("$=$",w,f);
return mb.log.exit(f);
};
this.isSentenceStopChar=function(w){
mb.log.enter(this.GID,"isSentenceStopChar");
if(!this.sentenceStopChars){
this.sentenceStopChars=this.toAssocArray([":",".",";","?","!"]);
}
var f=this.inArray(this.sentenceStopChars,w);
mb.log.debug("$=$",w,f);
return mb.log.exit(f);
};
this.isPunctuationChar=function(w){
if(!this.punctuationChars){
this.punctuationChars=this.toAssocArray([":",".",";","?","!",","]);
}
return this.inArray(this.punctuationChars,w);
};
this.getContractionWords=function(){
return [];
};
this.isContractionWord=function(pw,nw){
mb.log.enter(this.GID,"isContractionWord");
if(!this.contractionWords){
var a=this.getContractionWords();
var temp=[];
try{
for(var i=0;i<a.length;i++){
var curr=a[i].toLowerCase();
var _1b4=curr.split("'");
var _1b5=_1b4[0];
var _1b6=_1b4[1];
if(_1b5&&_1b6){
if(!temp[_1b5]){
temp[_1b5]=[];
}
temp[_1b5][temp[_1b5].length]=_1b6;
}
}
}
catch(e){
mb.log.error("caught exception: $",(e.message||""));
}
this.contractionWords=temp;
}
var _1b7=false,haystack=this.contractionWords[pw];
if(haystack!=null&&nw!=" "){
for(var cwi=0;cwi<haystack.length;cwi++){
if(haystack[cwi]==nw){
_1b7=true;
break;
}
}
}
mb.log.debug("Tested $'$ -> $",pw,nw,_1b7);
return mb.log.exit(_1b7);
};
this.getMacTitledWords=function(){
var nm=["achallies","achounich","adam","adie","aindra","aldonich","alduie","allan","allister","alonie","andeoir","andrew","angus","ara","aree","arthur","askill","aslan","aulay","auselan","ay","baxter","bean","beath","beolain","beth","bheath","bride","brieve","burie","caa","cabe","caig","caishe","call","callum","calman","calmont","camie","cammon","cammond","canish","cansh","cartney","cartair","carter","cash","caskill","casland","caul","cause","caw","cay","ceallaich","chlerich","chlery","choiter","chruiter","cloy","clure","cluskie","clymont","codrum","coll","colman","comas","combe","combich","combie","conacher","conachie","conchy","condy","connach","connechy","connell","conochie","cooish","cook","corkill","corkindale","corkle","cormack","cormick","corquodale","corry","cosram","coull","cowan","crae","crain","craken","craw","creath","crie","crimmon","crimmor","crindle","cririe","crouther","cruithein","cuag","cuaig","cubbin","cuish","culloch","cune","cunn","currach","cutchen","cutcheon","dade","daniell","david","dermid","diarmid","donachie","donald","donleavy","dougall","dowall","drain","duff","duffie","dulothe","eachan","eachern","eachin","eachran","earachar","elfrish","elheran","eoin","eol","erracher","ewen","fadzean","fall","farquhar","farlane","fater","feat","fergus","fie","gaw","geachie","geachin","geoch","ghee","gilbert","gilchrist","gill","gilledon","gillegowie","gillivantic","gillivour","gillivray","gillonie","gilp","gilroy","gilvernock","gilvra","gilvray","glashan","glasrich","gorrie","gorry","goun","gowan","grath","gregor","greusich","grewar","grime","grory","growther","gruder","gruer","gruther","guaran","guffie","gugan","guire","haffie","hardie","hardy","harold","hendrie","hendry","howell","hugh","hutchen","hutcheon","iain","ildowie","ilduy","ilreach","illeriach","ilriach","ilrevie","ilvain","ilvora","ilvrae","ilvride","ilwhom","ilwraith","ilzegowie","immey","inally","indeor","indoe","innes","inroy","instalker","intyre","iock","issac","ivor","james","kail","kames","kaskill","kay","keachan","keamish","kean","kechnie","kee","keggie","keith","kellachie","kellaigh","kellar","kelloch","kelvie","kendrick","kenzie","keochan","kerchar","kerlich","kerracher","kerras","kersey","kessock","kichan","kie","kieson","kiggan","killigan","killop","kim","kimmie","kindlay","kinley","kinnell","kinney","kinning","kinnon","kintosh","kinven","kirdy","kissock","knight","lachlan","lae","lagan","laghlan","laine of lochbuie","laren","lairish","lamond","lardie","laverty","laws","lea","lean","leay","lehose","leish","leister","lellan","lennan","leod","lergain","lerie","leverty","lewis","lintock","lise","liver","lucas","lugash","lulich","lure","lymont","manus","martin","master","math","maurice","menzies","michael","millan","minn","monies","morran","munn","murchie","murchy","murdo","murdoch","murray","murrich","mutrie","nab","nair","namell","naughton","nayer","nee","neilage","neill","neilly","neish","neur","ney","nicol","nider","niter","niven","nuir","nuyer","omie","omish","onie","oran","o","oull","ourlic","owen","owl","patrick","petrie","phadden","phail","phater","phee","phedran","phedron","pheidiran","pherson","phillip","phorich","phun","quarrie","queen","quey","quilkan","quistan","quisten","quoid","ra","rach","rae","raild","raith","rankin","rath","ritchie","rob","robb","robbie","robert","robie","rorie","rory","ruer","rurie","rury","shannachan","shimes","simon","sorley","sporran","swan","sween","swen","symon","taggart","tary","tause","tavish","tear","thomas","tier","tire","ulric","ure","vail","vanish","varish","veagh","vean","vicar","vinish","vurich","vurie","walrick","walter","wattie","whannell","whirr","whirter","william","intosh","intyre"];
for(var i=nm.length-1;i>=0;i--){
nm[i]="mac"+nm[i];
}
return nm;
};
this.isMacTitledWord=function(w){
mb.log.enter(this.GID,"isMacTitledWord");
if(!this.macTitledWords){
this.macTitledWords=this.toAssocArray(this.getMacTitledWords());
}
var f=this.inArray(this.macTitledWords,w);
mb.log.debug("$=$",w,f);
return mb.log.exit(f);
};
this.getCorrespondingBracket=function(w){
mb.log.enter(this.GID,"getCorrespondingBracket");
if(!this.bracketPairs){
var t=[];
t["("]=")";
t[")"]="(";
t["["]="]";
t["]"]="[";
t["{"]="}";
t["}"]="{";
t["<"]=">";
t[">"]="<";
this.bracketPairs=t;
}
var cb=this.bracketPairs[w];
if(mb.utils.isNullOrEmpty(cb)){
mb.log.warning("Did not find bracket for w: $",w);
return mb.log.exit("");
}
return mb.log.exit(cb);
};
this.trim=function(is){
mb.log.enter(this.GID,"trim");
if(mb.utils.isNullOrEmpty(is)){
mb.log.error("Parameter is was empty!");
is="";
}else{
if(typeof is!="string"){
mb.log.error("Parameter is was not a string!");
is="";
}
}
var os=(is.replace(/^\s\s*/,"").replace(/\s\s*$/,"").replace(/([\(\[])\s+/,"$1").replace(/\s+([\)\]])/,"$1").replace(/\s\s*/g," "));
return mb.log.exit(os);
};
this.titleString=function(is){
mb.log.enter(this.GID,"titleString");
if(mb.utils.isNullOrEmpty(is)){
mb.log.warning("Required parameter is was empty!",is);
return mb.log.exit("");
}
if(!gc.re.TITLESTRING){
gc.re.TITLESTRING=/[!\"%&'?`()\[\]\{\}\*\+,-\.\/:;<=>\?\s#]/;
}
var len=gc.i.getLength();
var pos=gc.i.getPos();
if(pos==len){
gc.i.setPos((pos=len-1));
}
mb.log.debug("Titling word: $ (pos: $, length: $)",is,pos,len);
gc.f.dumpRaisedFlags();
var _1c5=gc.i.getWordAtIndex(pos-2);
var os;
var LC=is.toLowerCase();
var UC=is.toUpperCase();
if((is==UC)&&(is.length>1)&&gc.isConfigTrue(gc.CFG_UC_UPPERCASED)){
mb.log.debug("Respect uppercase word: $",is);
os=UC;
}else{
if(LC.length==1&&gc.i.isPreviousWord("'")){
os=LC;
}else{
if(gc.i.isPreviousWord("'")&&LC.match(/^(s|round|em|ve|ll|d|cha|re|til|way|all)$/i)){
mb.log.debug("Found contraction: $",_1c5+"'"+LC);
os=LC;
}else{
if(gc.i.isPreviousWord("'")&&_1c5=="Ev"){
mb.log.debug("Found contraction: $",_1c5+"'"+LC);
os=LC;
}else{
if(LC.match(/^(o|y)$/i)&&gc.i.isNextWord("'")){
os=UC;
}else{
os=this.titleStringByMode(LC);
LC=os.toLowerCase();
UC=os.toUpperCase();
if(gc.u.isLowerCaseWord(LC)&&!gc.f.forceCaps){
os=LC;
}else{
if(gc.u.isUpperCaseWord(LC)){
os=UC;
}else{
if(gc.f.isInsideBrackets()){
if(gc.u.isLowerCaseBracketWord(LC)){
if(gc.f.colon&&LC=="disc"){
}else{
os=LC;
}
}
}
}
}
}
}
}
}
}
mb.log.debug("forceCaps: $, in: $, out: $",gc.f.forceCaps,is,os);
return mb.log.exit(os);
};
this.titleStringByMode=function(is){
mb.log.enter(this.GID,"titleStringByMode");
if(is==null||is==""){
return mb.log.exit("");
}
var os=is.toLowerCase();
if((!gc.f.slurpExtraTitleInformation)&&(gc.getMode().isSentenceCaps())&&(!gc.i.isFirstWord())&&(!gc.u.isSentenceStopChar(gc.o.getLastWord()))&&(!gc.f.openingBracket)){
mb.log.debug("SentenceCaps, before: $, after: $",is,os);
}else{
var _1cb=is.toLowerCase().split("");
_1cb[0]=_1cb[0].toUpperCase();
if(is.length>2&&is.substring(0,2)=="mc"){
_1cb[2]=_1cb[2].toUpperCase();
}else{
if(gc.u.isMacTitledWord(is)){
_1cb[3]=_1cb[3].toUpperCase();
}
}
os=_1cb.join("");
mb.log.debug("Capitalized, before: $, after: $",is,os);
}
return mb.log.exit(os);
};
mb.log.exit();
}
function GcAlbumHandler(){
mb.log.enter("GcAlbumHandler","__constructor");
this.CN="GcAlbumHandler";
this.GID="gc.album";
this.checkSpecialCase=function(is){
mb.log.enter(this.GID,"checkSpecialCase");
if(is){
if(!gc.re.ALBUM_UNTITLED){
gc.re.ALBUM_UNTITLED=/^([\(\[]?\s*untitled\s*[\)\]]?)$/i;
}
if(is.match(gc.re.ALBUM_UNTITLED)){
return mb.log.exit(this.SPECIALCASE_UNTITLED);
}
}
return mb.log.exit(this.NOT_A_SPECIALCASE);
};
this.process=function(is){
mb.log.enter(this.GID,"process");
is=this.stripInformationToOmit(is);
is=this.preProcessCommons(is);
is=this.preProcessTitles(is);
is=this.runVinylChecks(is);
var ow=gc.i.splitWordsAndPunctuation(is);
var nw=this.prepExtraTitleInfo(ow);
gc.o.init();
gc.i.init(is,nw);
while(!gc.i.isIndexAtEnd()){
this.processWord();
}
var os=this.getOutput();
return mb.log.exit(os);
};
this.doWord=function(){
mb.log.enter(this.GID,"doWord");
mb.log.debug("Guessing Word: #cw");
if(this.doDiscNumberStyle()){
}else{
if(this.doFeaturingArtistStyle()){
}else{
if(this.doVersusStyle()){
}else{
if(this.doVolumeNumberStyle()){
}else{
if(this.doPartNumberStyle()){
}else{
gc.o.appendSpaceIfNeeded();
gc.i.capitalizeCurrentWord();
mb.log.debug("Plain word: #cw");
gc.o.appendCurrentWord();
gc.f.resetContext();
gc.f.forceCaps=false;
gc.f.spaceNextWord=true;
}
}
}
}
}
gc.f.number=false;
return mb.log.exit(null);
};
mb.log.exit();
}
GcAlbumHandler.prototype=new GcHandler;
function GcArtistHandler(){
mb.log.enter("GcArtistHandler","__constructor");
this.CN="GcArtistHandler";
this.GID="gc.artist";
this.UNKNOWN="[unknown]";
this.NOARTIST="[unknown]";
this.process=function(is){
mb.log.enter(this.GID,"process");
is=this.preProcessCommons(is);
var w=gc.i.splitWordsAndPunctuation(is);
gc.o.init();
gc.i.init(is,w);
while(!gc.i.isIndexAtEnd()){
this.processWord();
}
var os=this.getOutput();
return mb.log.exit(os);
};
this.checkSpecialCase=function(is){
mb.log.enter(this.GID,"checkSpecialCase");
if(is){
if(!gc.re.ARTIST_EMPTY){
gc.re.ARTIST_EMPTY=/^\s*$/i;
gc.re.ARTIST_UNKNOWN=/^[\(\[]?\s*Unknown\s*[\)\]]?$/i;
gc.re.ARTIST_NONE=/^[\(\[]?\s*none\s*[\)\]]?$/i;
gc.re.ARTIST_NOARTIST=/^[\(\[]?\s*no[\s-]+artist\s*[\)\]]?$/i;
gc.re.ARTIST_NOTAPPLICABLE=/^[\(\[]?\s*not[\s-]+applicable\s*[\)\]]?$/i;
gc.re.ARTIST_NA=/^[\(\[]?\s*n\s*[\\\/]\s*a\s*[\)\]]?$/i;
}
var os=is;
if(is.match(gc.re.ARTIST_EMPTY)){
return mb.log.exit(this.SPECIALCASE_UNKNOWN);
}else{
if(is.match(gc.re.ARTIST_UNKNOWN)){
return mb.log.exit(this.SPECIALCASE_UNKNOWN);
}else{
if(is.match(gc.re.ARTIST_NONE)){
return mb.log.exit(this.SPECIALCASE_UNKNOWN);
}else{
if(is.match(gc.re.ARTIST_NOARTIST)){
return mb.log.exit(this.SPECIALCASE_UNKNOWN);
}else{
if(is.match(gc.re.ARTIST_NOTAPPLICABLE)){
return mb.log.exit(this.SPECIALCASE_UNKNOWN);
}else{
if(is.match(gc.re.ARTIST_NA)){
return mb.log.exit(this.SPECIALCASE_UNKNOWN);
}
}
}
}
}
}
}
return mb.log.exit(this.NOT_A_SPECIALCASE);
};
this.doWord=function(){
mb.log.enter(this.GID,"doWord");
mb.log.debug("Guessing Word: #cw");
if(this.doVersusStyle()){
}else{
if(this.doPresentsStyle()){
}else{
gc.o.appendSpaceIfNeeded();
gc.i.capitalizeCurrentWord();
mb.log.debug("Plain word: #cw");
gc.o.appendCurrentWord();
}
}
gc.f.resetContext();
gc.f.number=false;
gc.f.forceCaps=false;
gc.f.spaceNextWord=true;
return mb.log.exit(null);
};
this.doPresentsStyle=function(){
if(!this.doPresentsRE){
this.doPresentsRE=/^(presents|pres)$/i;
}
if(gc.i.matchCurrentWord(this.doPresentsRE)){
gc.o.appendSpace();
gc.o.appendCurrentWord();
if(gc.i.isNextWord(".")){
gc.i.nextIndex();
}
}
};
this.guessSortName=function(is){
mb.log.enter(this.GID,"guessSortName");
is=gc.u.trim(is);
var _1d7=" and ";
_1d7=(is.indexOf(" + ")!=-1?" + ":_1d7);
_1d7=(is.indexOf(" & ")!=-1?" & ":_1d7);
var as=is.split(_1d7);
for(var _1d9=0;_1d9<as.length;_1d9++){
var _1da=as[_1d9];
if(!mb.utils.isNullOrEmpty(_1da)){
_1da=gc.u.trim(_1da);
var _1db="";
mb.log.debug("Handling artist part: $",_1da);
if(!gc.re.SORTNAME_SR){
gc.re.SORTNAME_SR=/,\s*Sr[\.]?$/i;
gc.re.SORTNAME_JR=/,\s*Jr[\.]?$/i;
}
if(_1da.match(gc.re.SORTNAME_SR)){
_1da=_1da.replace(gc.re.SORTNAME_SR,"");
_1db=", Sr.";
}else{
if(_1da.match(gc.re.SORTNAME_JR)){
_1da=_1da.replace(gc.re.SORTNAME_JR,"");
_1db=", Jr.";
}
}
var _1dc=_1da.split(" ");
mb.log.debug("names: $",_1dc);
var _1dd=false;
if(!gc.re.SORTNAME_DJ){
gc.re.SORTNAME_DJ=/^DJ$/i;
gc.re.SORTNAME_THE=/^The$/i;
gc.re.SORTNAME_LOS=/^Los$/i;
gc.re.SORTNAME_DR=/^Dr\.$/i;
}
var _1de=_1dc[0];
if(_1de.match(gc.re.SORTNAME_DJ)){
_1db=(", DJ"+_1db);
_1dc[0]=null;
}else{
if(_1de.match(gc.re.SORTNAME_THE)){
_1db=(", The"+_1db);
_1dc[0]=null;
}else{
if(_1de.match(gc.re.SORTNAME_LOS)){
_1db=(", Los"+_1db);
_1dc[0]=null;
}else{
if(_1de.match(gc.re.SORTNAME_DR)){
_1db=(", Dr."+_1db);
_1dc[0]=null;
_1dd=true;
}else{
_1dd=true;
}
}
}
}
var i=0;
if(_1dd){
var _1e0=[];
if(_1dc.length>1){
for(i=0;i<_1dc.length-1;i++){
if(i==_1dc.length-2&&_1dc[i]=="St."){
_1dc[i+1]=_1dc[i]+" "+_1dc[i+1];
}else{
if(!mb.utils.isNullOrEmpty(_1dc[i])){
_1e0[i+1]=_1dc[i];
}
}
}
_1e0[0]=_1dc[_1dc.length-1];
if(_1e0.length>1){
_1e0[0]+=",";
}
_1dc=_1e0;
}
}
mb.log.debug("Sorted names: $, append: $",_1dc,_1db);
var t=[];
for(i=0;i<_1dc.length;i++){
var w=_1dc[i];
if(!mb.utils.isNullOrEmpty(w)){
t.push(w);
}
if(i<_1dc.length-1){
t.push(" ");
}
}
if(!mb.utils.isNullOrEmpty(_1db)){
t.push(_1db);
}
_1da=gc.u.trim(t.join(""));
}
if(!mb.utils.isNullOrEmpty(_1da)){
as[_1d9]=_1da;
}else{
delete as[_1d9];
}
}
var os=gc.u.trim(as.join(_1d7));
mb.log.debug("Result: $",os);
return mb.log.exit(os);
};
mb.log.exit();
}
GcArtistHandler.prototype=new GcHandler;
function GcHandler(){
this.CN="GcHandler";
this.GID="gc.base";
mb.log.enter(this.CN,"__constructor");
this.NOT_A_SPECIALCASE=-1;
this.SPECIALCASE_UNKNOWN=10;
this.SPECIALCASE_DATA_TRACK=20;
this.SPECIALCASE_DATA_TRACK=30;
this.SPECIALCASE_SILENCE=31;
this.SPECIALCASE_UNTITLED=32;
this.SPECIALCASE_CROWD_NOISE=33;
this.SPECIALCASE_GUITAR_SOLO=34;
this.SPECIALCASE_DIALOGUE=35;
this.isSpecialCase=function(num){
return (num!=this.NOT_A_SPECIALCASE);
};
this.getSpecialCaseFormatted=function(is,num){
mb.log.enter(this.GID,"getSpecialCaseFormatted");
switch(num){
case this.SPECIALCASE_DATA_TRACK:
return mb.log.exit("[data track]");
case this.SPECIALCASE_SILENCE:
return mb.log.exit("[silence]");
case this.SPECIALCASE_UNTITLED:
return mb.log.exit("[untitled]");
case this.SPECIALCASE_UNKNOWN:
return mb.log.exit("[unknown]");
case this.SPECIALCASE_CROWD_NOISE:
return mb.log.exit("[crowd noise]");
case this.SPECIALCASE_GUITAR_SOLO:
return mb.log.exit("[guitar solo]");
case this.SPECIALCASE_DIALOGUE:
return mb.log.exit("[dialogue]");
case this.NOT_A_SPECIALCASE:
default:
return mb.log.exit(is);
}
};
this.getOutput=function(){
var is=gc.o.getOutput();
var os=this.runPostProcess(is);
return os;
};
this.processWord=function(){
mb.log.enter(this.GID,"processWord");
if(this.doWhiteSpace()){
}else{
if(mb.log.isDebugMode()){
mb.log.scopeStart("Handle next word: "+gc.i.getCurrentWord()+"");
mb.log.debug("  Index: $/$ Word: #cw",gc.i.getPos(),gc.i.getLength()-1);
gc.f.dumpRaisedFlags();
}
if(this.doColon()){
}else{
if(this.doAmpersand()){
}else{
if(this.doLineStop()){
}else{
if(this.doHyphen()){
}else{
if(this.doPlus()){
}else{
if(this.doComma()){
}else{
if(this.doPeriod()){
}else{
if(this.doAsterix()){
}else{
if(this.doDiamond()){
}else{
if(this.doPercent()){
}else{
if(this.doSlash()){
}else{
if(this.doDoubleQuote()){
}else{
if(this.doSingleQuote()){
}else{
if(this.doOpeningBracket()){
}else{
if(this.doClosingBracket()){
}else{
if(this.doDigits()){
}else{
if(this.doAcronym()){
}else{
this.doWord();
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
gc.i.nextIndex();
mb.log.exit();
};
this.doWord=function(){
};
this.doWhiteSpace=function(){
mb.log.enter(this.GID,"doWhiteSpace");
if(!gc.re.WHITESPACE){
gc.re.WHITESPACE=" ";
}
if(gc.i.matchCurrentWord(gc.re.WHITESPACE)){
gc.f.whitespace=true;
gc.f.spaceNextWord=true;
if(gc.f.openingBracket){
gc.f.spaceNextWord=false;
}
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doColon=function(){
mb.log.enter(this.GID,"doColon");
if(!gc.re.COLON){
gc.re.COLON=":";
}
if(gc.i.matchCurrentWord(gc.re.COLON)){
mb.log.debug("Handled #cw");
gc.o.capitalizeLastWord();
var skip=false;
var pos=gc.i.getPos();
var len=gc.i.getLength();
if(pos<len-2){
var _1ec=gc.i.getWordAtIndex(pos+1);
var _1ed=gc.i.getWordAtIndex(pos+2);
if(_1ec.match(gc.re.OPENBRACKET)){
skip=true;
gc.f.spaceNextWord=true;
}
if(gc.i.isNextWord(" ")&&_1ed.match(gc.re.OPENBRACKET)){
gc.f.spaceNextWord=true;
skip=true;
gc.i.nextIndex();
}
}
if(!skip){
gc.o.appendCurrentWord();
gc.f.resetContext();
gc.f.forceCaps=true;
gc.f.colon=true;
gc.f.spaceNextWord=(gc.i.isNextWord(" "));
}
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doAsterix=function(){
mb.log.enter(this.GID,"doAsterix");
if(!gc.re.ASTERIX){
gc.re.ASTERIX="*";
}
if(gc.i.matchCurrentWord(gc.re.ASTERIX)){
gc.o.appendWordPreserveWhiteSpace({apply:true,capslast:true});
gc.f.resetContext();
gc.f.forceCaps=true;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doDiamond=function(){
mb.log.enter(this.GID,"doDiamond");
if(!gc.re.DIAMOND){
gc.re.DIAMOND="#";
}
if(gc.i.matchCurrentWord(gc.re.DIAMOND)){
gc.o.appendWordPreserveWhiteSpace({apply:true,capslast:true});
gc.f.resetContext();
gc.f.forceCaps=true;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doPercent=function(){
mb.log.enter(this.GID,"doPercent");
if(!gc.re.PERCENT){
gc.re.PERCENT="%";
}
if(gc.i.matchCurrentWord(gc.re.PERCENT)){
gc.o.appendWordPreserveWhiteSpace({apply:true,capslast:true});
gc.f.resetContext();
gc.f.forceCaps=true;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doAmpersand=function(){
mb.log.enter(this.GID,"doAmpersand");
if(!gc.re.AMPERSAND){
gc.re.AMPERSAND="&";
}
if(gc.i.matchCurrentWord(gc.re.AMPERSAND)){
mb.log.debug("Handled #cw");
gc.f.resetContext();
gc.f.forceCaps=true;
gc.o.appendSpace();
gc.f.spaceNextWord=true;
gc.o.appendCurrentWord();
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doLineStop=function(){
mb.log.enter(this.GID,"doLineStop");
if(!gc.re.LINESTOP){
gc.re.LINESTOP=/[\?\!\;]/;
}
if(gc.i.matchCurrentWord(gc.re.LINESTOP)){
mb.log.debug("Handled #cw");
gc.f.resetContext();
gc.o.capitalizeLastWord();
gc.f.forceCaps=true;
gc.f.spaceNextWord=true;
gc.o.appendCurrentWord();
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doHyphen=function(){
mb.log.enter(this.GID,"doHyphen");
if(!gc.re.HYPHEN){
gc.re.HYPHEN="-";
}
if(gc.i.matchCurrentWord(gc.re.HYPHEN)){
gc.o.appendWordPreserveWhiteSpace({apply:true,capslast:true});
gc.f.resetContext();
if(gc.getMode().isSentenceCaps()){
gc.f.forceCaps=false;
}else{
gc.f.forceCaps=true;
}
gc.f.hypen=true;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doPlus=function(){
mb.log.enter(this.GID,"doPlus");
if(!gc.re.PLUS){
gc.re.PLUS="+";
}
if(gc.i.matchCurrentWord(gc.re.PLUS)){
gc.o.appendWordPreserveWhiteSpace({apply:true,capslast:true});
gc.f.resetContext();
gc.f.forceCaps=true;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doSlash=function(){
mb.log.enter(this.GID,"doSlash");
if(!gc.re.SLASH){
gc.re.SLASH=/[\\\/]/;
}
if(gc.i.matchCurrentWord(gc.re.SLASH)){
gc.o.appendWordPreserveWhiteSpace({apply:true,capslast:true});
gc.f.resetContext();
gc.f.forceCaps=true;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doDoubleQuote=function(){
mb.log.enter(this.GID,"doDoubleQuote");
if(!gc.re.DOUBLEQUOTE){
gc.re.DOUBLEQUOTE="\"";
}
if(gc.i.matchCurrentWord(gc.re.DOUBLEQUOTE)){
gc.o.appendWordPreserveWhiteSpace({apply:true,capslast:true});
gc.f.resetContext();
gc.f.forceCaps=true;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doSingleQuote=function(){
mb.log.enter(this.GID,"doSingleQuote");
if(!gc.re.SINGLEQUOTE){
gc.re.SINGLEQUOTE="'";
}
if(gc.i.matchCurrentWord(gc.re.SINGLEQUOTE)){
gc.f.forceCaps=false;
var a=gc.i.isPreviousWord(" ");
var b=gc.i.isNextWord(" ");
mb.log.debug("Consumed #cw, space before: $, after: $",a,b);
if(a&&!b){
mb.log.debug("Found opening singlequote.",a,b);
gc.o.appendSpace();
gc.f.forceCaps=true;
gc.f.openedSingleQuote=true;
}else{
if(!a&&b){
if(gc.f.openedSingleQuote){
mb.log.debug("Found closing singlequote.",a,b);
gc.f.forceCaps=true;
gc.f.openedSingleQuote=false;
}else{
mb.log.debug("Found closing singlequote, but none was opened",a,b);
}
gc.o.capitalizeLastWord();
}
}
gc.f.spaceNextWord=b;
gc.o.appendCurrentWord();
gc.f.resetContext();
gc.f.singlequote=true;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doOpeningBracket=function(){
mb.log.enter(this.GID,"doOpeningBracket");
if(!gc.re.OPENBRACKET){
gc.re.OPENBRACKET=/[\(\[\{\<]/;
}
if(gc.i.matchCurrentWord(gc.re.OPENBRACKET)){
mb.log.debug("Handled #cw, stack: $",gc.f.openBrackets);
gc.f.forceCaps=true;
gc.o.capitalizeLastWord();
gc.f.pushBracket(gc.i.getCurrentWord());
var cb=gc.f.getCurrentCloseBracket();
var _1f1=false;
var pos=gc.i.getPos()+1;
for(var i=pos;i<gc.i.getLength();i++){
var w=(gc.i.getWordAtIndex(i)||"");
if(w!=" "){
if((gc.u.isLowerCaseBracketWord(w))||(w.match(/^featuring$|^ft$|^feat$/i)!=null)){
gc.f.slurpExtraTitleInformation=true;
if(i==pos){
_1f1=true;
}
}
if(w==cb){
break;
}
}
}
gc.o.appendSpace();
gc.f.resetContext();
gc.f.spaceNextWord=false;
gc.f.openingBracket=true;
gc.f.forceCaps=!_1f1;
gc.o.appendCurrentWord();
gc.f.disc=false;
gc.f.part=false;
gc.f.volume=false;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doClosingBracket=function(){
mb.log.enter(this.GID,"doClosingBracket");
if(!gc.re.CLOSEBRACKET){
gc.re.CLOSEBRACKET=/[\)\]\}\>]/;
}
if(gc.i.matchCurrentWord(gc.re.CLOSEBRACKET)){
mb.log.debug("Handled #cw, stack: $",gc.f.openBrackets);
gc.o.capitalizeLastWord();
if(gc.f.isInsideBrackets()){
gc.f.popBracket();
gc.f.slurpExtraTitleInformation=false;
}
gc.f.resetContext();
gc.f.forceCaps=true;
gc.f.spaceNextWord=true;
gc.o.appendCurrentWord();
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doComma=function(){
mb.log.enter(this.GID,"doComma");
if(!gc.re.COMMA){
gc.re.COMMA=",";
}
if(gc.i.matchCurrentWord(gc.re.COMMA)){
mb.log.debug("Handled #cw");
if(gc.o.getLastWord()!=","){
gc.f.forceCaps=true;
gc.o.capitalizeLastWord();
gc.f.resetContext();
gc.f.spaceNextWord=true;
gc.f.forceCaps=false;
gc.o.appendCurrentWord();
}
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doPeriod=function(){
mb.log.enter(this.GID,"doPeriod");
if(!gc.re.PERIOD){
gc.re.PERIOD=".";
}
if(gc.i.matchCurrentWord(gc.re.PERIOD)){
if(gc.o.getLastWord()=="."){
if(!gc.f.ellipsis){
mb.log.debug("Handled ellipsis");
gc.o.appendWord("..");
while(gc.i.isNextWord(".")){
gc.i.nextIndex();
}
gc.f.resetContext();
gc.f.ellipsis=true;
}
gc.f.forceCaps=true;
gc.f.spaceNextWord=true;
}else{
mb.log.debug("Handled #cw");
if(!gc.i.hasMoreWords()||gc.i.getNextWord()!="."){
gc.o.capitalizeLastWord();
}
gc.o.appendWord(".");
gc.f.resetContext();
gc.f.forceCaps=true;
gc.f.spaceNextWord=(gc.i.isNextWord(" "));
}
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doAcronym=function(){
mb.log.enter(this.GID,"doAcronym");
if(!gc.re.ACRONYM){
gc.re.ACRONYM=/^\w$/;
}
var _1f5,tmp=[];
if(gc.i.matchCurrentWord(gc.re.ACRONYM)){
var cw=gc.i.getCurrentWord();
tmp.push(cw.toUpperCase());
gc.f.expectWord=false;
gc.f.gotPeriod=false;
acronymloop:
for(_1f5=gc.i.getPos()+1;_1f5<gc.i.getLength();){
cw=gc.i.getWordAtIndex(_1f5);
mb.log.debug("Word: $, i: $, expectWord: $, gotPeriod: $",cw,_1f5,gc.f.expectWord,gc.f.gotPeriod);
if(gc.f.expectWord&&cw.match(gc.re.ACRONYM)){
tmp.push(cw.toUpperCase());
gc.f.expectWord=false;
gc.f.gotPeriod=false;
}else{
if(cw=="."&&!gc.f.gotPeriod){
tmp[tmp.length]=".";
gc.f.gotPeriod=true;
gc.f.expectWord=true;
}else{
if(gc.f.gotPeriod&&cw==" "){
gc.f.expectWord=true;
}else{
if(tmp[tmp.length-1]!="."){
tmp.pop();
_1f5--;
}
break acronymloop;
}
}
}
_1f5++;
}
}
if(tmp.length>2){
var s=tmp.join("");
s=s.replace(/(\.)*$/,".");
mb.log.debug("Found acronym: $",s);
gc.o.appendSpaceIfNeeded();
gc.o.appendWord(s);
gc.f.acronym=true;
gc.f.spaceNextWord=true;
gc.f.forceCaps=false;
gc.i.setPos(_1f5-1);
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doDigits=function(){
mb.log.enter(this.GID,"doDigits");
if(!gc.re.DIGITS){
gc.re.DIGITS=/^\d+$/;
gc.re.DIGITS_NUMBERSPLIT=/[,.]/;
gc.re.DIGITS_DUPLE=/^\d\d$/;
gc.re.DIGITS_TRIPLE=/^\d\d\d$/;
gc.re.DIGITS_NTUPLE=/^\d\d\d\d+$/;
}
var _1f8=null,tmp=[];
if(gc.i.matchCurrentWord(gc.re.DIGITS)){
tmp.push(gc.i.getCurrentWord());
gc.f.numberSplitExpect=true;
numberloop:
for(_1f8=gc.i.getPos()+1;_1f8<gc.i.getLength();){
if(gc.f.numberSplitExpect){
if(gc.i.matchWordAtIndex(_1f8,gc.re.DIGITS_NUMBERSPLIT)){
tmp.push(gc.i.getWordAtIndex(_1f8));
gc.f.numberSplitExpect=false;
}else{
break numberloop;
}
}else{
if(gc.i.matchWordAtIndex(_1f8,gc.re.DIGITS_TRIPLE)){
if(gc.f.numberSplitChar==null){
gc.f.numberSplitChar=tmp[tmp.length-1];
}
tmp.push(gc.i.getWordAtIndex(_1f8));
gc.f.numberSplitExpect=true;
}else{
if(gc.i.matchWordAtIndex(_1f8,gc.re.DIGITS_DUPLE)){
if(tmp.length>2&&gc.f.numberSplitChar!=tmp[tmp.length-1]){
tmp.push(gc.i.getWordAtIndex(_1f8++));
}else{
tmp.pop();
_1f8--;
}
}else{
if(gc.i.matchWordAtIndex(_1f8,gc.re.DIGITS_NTUPLE)){
tmp.push(gc.i.getWordAtIndex(_1f8++));
}else{
tmp.pop();
_1f8--;
}
}
break numberloop;
}
}
_1f8++;
}
gc.i.setPos(_1f8-1);
var _1f9=tmp.join("");
if(gc.f.disc||gc.f.part||gc.f.volume){
_1f9=_1f9.replace(/^0*/,"");
}
mb.log.debug("Processed number: $",tmp.join(""));
var _1fa=false;
if(gc.f.disc||gc.f.part||gc.f.volume){
var pos=gc.i.getPos();
if(pos<gc.i.getLength()-2){
var _1fc=gc.i.getWordAtIndex(pos+1);
var _1fd=gc.i.getWordAtIndex(pos+2);
var _1fe=_1fc.match(/[\):\-&]/);
var _1ff=_1fd.match(/[\(:\-&]/);
if(_1fe==null&&_1ff==null){
_1fa=true;
}else{
if(gc.f.part&&_1fd.match(/&|-/)){
gc.o.setWordAtIndex(gc.o.getLength()-1,"Parts");
}
}
}
gc.f.disc=false;
gc.f.part=false;
gc.f.volume=false;
gc.f.spaceNextWord=true;
gc.f.forceCaps=true;
}
gc.o.appendSpaceIfNeeded();
gc.o.appendWord(_1f9);
gc.f.forceCaps=false;
gc.f.number=true;
if(_1fa){
gc.o.appendWord(":");
gc.f.forceCaps=true;
gc.f.colon=true;
}
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.prepExtraTitleInfo=function(w){
mb.log.enter(this.GID,"prepExtraTitleInfo");
var len=w.length-1,wi=len;
var _202=false;
var _203=false;
while(((w[wi]==" ")||(w[wi]=="\""&&(w[wi-1]=="7"||w[wi-1]=="12"))||((w[wi+1]||"")=="\""&&(w[wi]=="7"||w[wi]=="12"))||(gc.u.isPrepBracketWord(w[wi])))&&wi>=0){
_202=true;
wi--;
}
mb.log.debug("Preprocess: $ ($<--$)",_202,wi,len);
if(wi<len){
wi++;
while(w[wi]==" "&&wi<w.length-1){
wi++;
}
var _204=(w[wi]||"");
if((wi==len-1)&&(gc.u.isPrepBracketSingleWord(_204))){
mb.log.debug("Word found, but its a <i>singleword</i>: $",_204);
_202=false;
}
if(_202&&wi>0&&wi<w.length-1){
var nw=w.slice(0,wi);
if(nw[wi-1]=="("){
nw.pop();
}
if(nw[wi-1]=="-"){
nw.pop();
}
nw[nw.length]="(";
nw=nw.concat(w.slice(wi,w.length));
nw[nw.length]=")";
w=nw;
mb.log.debug("Processed ExtraTitleInfo: $",w);
}
}
return mb.log.exit(w);
};
this.preProcessCommons=function(is){
mb.log.enter(this.GID,"preProcessCommons");
if(!gc.re.PREPROCESS_COMMONS){
gc.re.PREPROCESS_COMMONS=[new GcFix("D.J. -> DJ",/(\b|^)D\.?J\.?(\s|\)|$)/i,"DJ"),new GcFix("M.C. -> MC",/(\b|^)M\.?C\.?(\s|\)|$)/i,"MC"),new GcFix("Backtick &#x0060;","`","'"),new GcFix("Opening single-quote &#x2018;","\u2018","'"),new GcFix("Closing single-quote &#x2019;","\u2019","'"),new GcFix("Prime &#x2023;","\u2023","'"),new GcFix("Acute accent &#x0301;","\u0301","'"),new GcFix("Grave accent &#x0300;","\u0300","'"),new GcFix("Opening double-quote &#x201C;","\u201c","\""),new GcFix("Closing double-quote &#x201D;","\u201d","\""),new GcFix("Soft hyphen &#x00AD;","\xad","-"),new GcFix("Closing Hyphen &#x2010;","\u2010","-"),new GcFix("Non-breaking hyphen &#x2011;","\u2011","-"),new GcFix("En-dash &#x2013;","\u2013","-"),new GcFix("Em-dash &#x2014;","\u2014","-"),new GcFix("hyphen bullet &#x2043;","\u2043","-"),new GcFix("Minus sign &#x2212;","\u2212","-"),new GcFix("Ellipsis &#x2026;","\u2026","...")];
}
var os=this.runFixes(is,gc.re.PREPROCESS_COMMONS);
mb.log.debug("After: $",os);
return mb.log.exit(os);
};
this.preProcessTitles=function(is){
mb.log.enter(this.GID,"preProcessTitles");
if(!gc.re.PREPROCESS_FIXLIST){
gc.re.PREPROCESS_FIXLIST=[new GcFix("re-mix -> remix",/(\b|^)re-mix(\b)/i,"remix"),new GcFix("remx -> remix",/(\b|^)remx(\b)/i,"remix"),new GcFix("re-mixes -> remixes",/(\b|^)re-mixes(\b)/i,"remixes"),new GcFix("re-make -> remake",/(\b|^)re-make(\b)/i,"remake"),new GcFix("re-makes -> remakes",/(\b|^)re-makes(\b)/i,"remakes"),new GcFix("re-edit variants, prepare for postprocess",/(\b|^)re-?edit(\b)/i,"re_edit"),new GcFix("RMX -> remix",/(\b|^)RMX(\b)/i,"remix"),new GcFix("alt.take -> alternate take",/(\b|^)alt[\.]? take(\b)/i,"alternate take"),new GcFix("instr. -> instrumental",/(\b|^)instr\.?(\b)/i,"instrumental"),new GcFix("altern. -> alternate",/(\b|^)altern\.?(\s|\)|$)/i,"alternate"),new GcFix("orig. -> original",/(\b|^)orig\.?(\s|\)|$)/i,"original"),new GcFix("vers. -> version",/(\b|^)vers\.(\s|\)|$)/i,"version"),new GcFix("Extendet -> extended",/(\b|^)Extendet(\b)/i,"extended"),new GcFix("extd. -> extended",/(\b|^)ext[d]?\.?(\s|\)|$)/i,"extended"),new GcFix("aka -> a.k.a.",/(\b|^)aka(\b)/i,"a.k.a."),new GcFix("/w -> ft. ",/(\s)[\/]w(\s)/i,"ft."),new GcFix("f. -> ft. ",/(\s)f\.(\s)/i,"ft."),new GcFix("A Capella preprocess",/(\b|^)a\s?c+ap+el+a(\b)/i,"a_cappella"),new GcFix("OC ReMix preprocess",/(\b|^)oc\sremix(\b)/i,"oc_remix"),new GcFix("Pt. -> Part",/(\b|^)Pt\.?()/i,"Part"),new GcFix("Pts. -> Parts",/(\b|^)Pts\.()/i,"Parts"),new GcFix("Vol. -> Volume",/(\b|^)Vol\.()/i,"Volume"),new GcFix("(Pt) -> , Part",/((,|\s|:|!)+)([\(\[])?\s*(Part|Pt)[\.\s#]*((\d|[ivx]|[\-&\s])+)([\)\]])?(\s|$)/i,"Part $5"),new GcFix("(Pts) -> , Parts",/((,|\s|:|!)+)([\(\[])?\s*(Parts|Pts)[\.\s#]*((\d|[ivx]|[\-&\s])+)([\)\]])?(\s|$)/i,"Parts $5"),new GcFix("(Vol) -> , Volume",/((,|\s|:|!)+)([\(\[])?\s*(Volume|Vol)[\.\s#]*((\d|[ivx]|[\-&\s])+)([\)\]])?(\s|$)/i,"Volume $5")];
}
var os=this.runFixes(is,gc.re.PREPROCESS_FIXLIST);
mb.log.debug("After pre: $",os);
return mb.log.exit(os);
};
this.runPostProcess=function(is){
mb.log.enter(this.GID,"runPostProcess");
if(!gc.re.POSTPROCESS_FIXLIST){
gc.re.POSTPROCESS_FIXLIST=[new GcFix("a_cappella inside brackets",/(\b|^)a_cappella(\b)/,"a cappella"),new GcFix("a_cappella outside brackets",/(\b|^)A_cappella(\b)/,"A Cappella"),new GcFix("oc_remix",/(\b|^)oc_remix(\b)/i,"OC ReMix"),new GcFix("re_edit inside brackets",/(\b|^)Re_edit(\b)/,"re-edit"),new GcFix("whitespace in R&B",/(\b|^)R\s*&\s*B(\b)/i,"R&B"),new GcFix("[live] to (live)",/(\b|^)\[live\](\b)/i,"(live)"),new GcFix("Djs to DJs",/(\b|^)Djs(\b)/i,"DJs"),new GcFix("a.k.a. lowercase",/(\b|^)a.k.a.(\b)/i,"a.k.a.")];
}
var os=this.runFixes(is,gc.re.POSTPROCESS_FIXLIST);
if(is!=os){
mb.log.debug("After postfixes: $",os);
is=os;
}
os=this.runVinylChecks(is);
if(is!=os){
mb.log.debug("After vinylchecks: $",os);
}
return mb.log.exit(os);
};
this.runFixes=function(is,list){
mb.log.enter(this.GID,"runFixes");
var _20e=null;
var len=list.length;
for(var i=0;i<len;i++){
var f=list[i];
if(f instanceof GcFix){
var _212="Replaced "+f.getName();
var find=f.getRe();
var _214=f.getReplace();
if(typeof (find)=="string"&&is.indexOf(find)!=-1){
mb.log.debug("Applying fix: $ (replace: $)",_212,_214);
is=is.replace(find,_214);
}else{
if((_20e=is.match(find))!=null){
var a=_20e[1];
a=(mb.utils.isNullOrEmpty(a)?"":a);
var b=_20e[_20e.length-1];
b=(mb.utils.isNullOrEmpty(b)?"":b);
var rs=[a,_214,b].join("");
is=is.replace(find,rs);
mb.log.debug("Applying fix: $ ...",_212);
mb.log.trace("* matcher[$]: $, replace: $, matcher[$]: $ --> $",1,a,_214,_20e.length-1,b,rs);
mb.log.trace("* matcher: $",_20e);
mb.log.trace("After fix: $",is);
}else{
}
}
}else{
mb.log.error("Expected GcFix object($/$), got: $",i,len,(f?f.nodeName:"null"));
}
}
return mb.log.exit(is);
};
this.stripInformationToOmit=function(is){
mb.log.enter(this.GID,"stripInformationToOmit");
if(!gc.re.PREPROCESS_STRIPINFOTOOMIT){
gc.re.PREPROCESS_STRIPINFOTOOMIT=[new GcFix("Trim 'bonus (track)?'",/[\(\[]?bonus(\s+track)?s?\s*[\)\]]?$/i,""),new GcFix("Trim 'retail (version)?'",/[\(\[]?retail(\s+version)?\s*[\)\]]?$/i,"")];
}
var os=is,list=gc.re.PREPROCESS_STRIPINFOTOOMIT;
for(var i=list.length-1;i>=0;i--){
var _21b=null;
var _21c=list[i];
var _21d="Replaced "+_21c.getName();
var find=_21c.getRe();
var _21f=_21c.getReplace();
if((_21b=os.match(find))!=null){
os=os.replace(find,_21f);
mb.log.debug("Done fix: $",_21d);
}
}
if(is!=os){
mb.log.debug("After strip info: $",os);
}
return mb.log.exit(os);
};
this.runVinylChecks=function(is){
mb.log.enter(this.GID,"runVinylChecks");
if(!gc.re.VINYL){
gc.re.VINYL=/(\s+|\()((\d+)[\s|-]?(inch\b|in\b|'+|"))([^s]|$)/i;
}
var _221=null,os=is;
if((_221=is.match(gc.re.VINYL))!=null){
var _222=_221.index;
var _223=_221[1].length+_221[2].length+_221[5].length;
var _224=is.substring(0,_222);
var _225=is.substring(_222+_223,is.length);
var _226=new Array();
_226[_226.length]=_224;
_226[_226.length]=_221[1];
_226[_226.length]=_221[3];
_226[_226.length]="\"";
_226[_226.length]=(_221[5]!=" "&&_221[5]!=")"&&_221[5]!=","?" ":"");
_226[_226.length]=_221[5];
_226[_226.length]=_225;
os=_226.join("");
}
return mb.log.exit(is);
};
this.doVersusStyle=function(){
mb.log.enter(this.GID,"handleVersus");
if(!gc.re.VERSUSSTYLE){
gc.re.VERSUSSTYLE="vs";
}
if(gc.i.matchCurrentWord(gc.re.VERSUSSTYLE)){
mb.log.debug("Found VersusStyle, cw: #cw");
gc.o.capitalizeLastWord();
if(!gc.f.openingBracket){
gc.o.appendSpace();
}
gc.o.appendWord("vs");
gc.o.appendWord(".");
if(gc.i.isNextWord(".")){
gc.i.nextIndex();
}
gc.f.forceCaps=true;
gc.f.spaceNextWord=true;
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doVolumeNumberStyle=function(){
mb.log.enter(this.GID,"doVolumeNumberStyle");
if(!gc.re.VOLUMENUMBERSTYLE){
gc.re.VOLUMENUMBERSTYLE=/^(volumes|volume)$/i;
}
if(gc.i.matchCurrentWord(gc.re.VOLUMENUMBERSTYLE)&&gc.i.hasMoreWords()){
mb.log.debug("Found VolumeNumberStyle, cw: #cw");
if(this.doSeriesNumberStyle("Volume")){
gc.f.volume=true;
return mb.log.exit(true);
}
}
return mb.log.exit(false);
};
this.doPartNumberStyle=function(){
mb.log.enter(this.GID,"doPartNumberStyle");
if(!gc.re.PARTNUMBERSTYLE){
gc.re.PARTNUMBERSTYLE=/^(parts|part)$/i;
}
if(gc.i.matchCurrentWord(gc.re.PARTNUMBERSTYLE)&&gc.i.hasMoreWords()){
mb.log.debug("Found possible PartNumberStyle, cw: #cw");
if(this.doSeriesNumberStyle("Part")){
gc.f.part=true;
return mb.log.exit(true);
}
}
return mb.log.exit(false);
};
this.doSeriesNumberStyle=function(_227){
mb.log.enter(this.GID,"doSeriesNumberStyle");
var pos=gc.i.getPos();
var len=gc.i.getLength();
var wi=pos+1,si=wi;
while((wi<len-1)&&(gc.i.getWordAtIndex(wi).match(gc.re.SPACES_DOTS)!=null)){
wi++;
}
if(si!=wi){
mb.log.debug("Skipped spaces & dots, index: $->$",si,wi);
}
var w=(gc.i.getWordAtIndex(wi)||"");
mb.log.debug("Attempting to match number/roman numeral, $",w);
if(w.match(gc.re.SERIES_NUMBER)){
if(gc.i.getPos()>=2&&!gc.u.isPunctuationChar(gc.o.getLastWord())){
var _22c=false;
while(gc.o.getLength()>0&&(gc.o.getLastWord()||"").match(/ |-/i)){
gc.o.dropLastWord();
_22c=true;
}
if(_22c){
gc.o.capitalizeLastWord();
}
gc.o.appendWord(",");
}else{
gc.o.capitalizeWordAtIndex(gc.o.getLength()-2);
}
gc.o.appendSpaceIfNeeded();
gc.o.appendWord(_227);
gc.f.number=true;
gc.f.spaceNextWord=false;
gc.f.forceCaps=true;
var _22d=false;
if(wi<gc.i.getLength()-2){
var _22e=gc.i.getWordAtIndex(wi+1);
var _22f=gc.i.getWordAtIndex(wi+2);
var _230=_22e.match(/[\):\-&\/]/);
var _231=_22f.match(/[\(:\-&\/]/);
if(_230==null&&_231==null){
_22d=true;
}else{
if(_227=="Part"&&_22f.match(/&|-/)){
gc.o.setWordAtIndex(gc.o.getLength()-1,"Parts");
}
}
}
gc.o.appendSpace();
gc.o.appendWord(w);
if(_22d){
gc.o.appendWord(":");
gc.f.forceCaps=true;
gc.f.spaceNextWord=true;
gc.f.number=false;
gc.f.colon=true;
}
gc.i.setPos(wi);
return mb.log.exit(true);
}
return mb.log.exit(false);
};
this.doDiscNumberStyle=function(){
mb.log.enter(this.GID,"doDiscNumberStyle");
if(!gc.re.DISCNUMBERSTYLE){
gc.re.DISCNUMBERSTYLE=/^(Cd|Disk|Discque|Disc)([^\s\d]*)(\s*)(\d*)/i;
}
var _232=null;
var w=gc.i.getCurrentWord();
if(!(gc.f.isInsideBrackets()&&gc.f.colon)&&!gc.i.isFirstWord()&&gc.i.hasMoreWords()&&(_232=w.match(gc.re.DISCNUMBERSTYLE))!=null){
if(_232[2]!=""){
return mb.log.exit(false);
}
mb.log.debug("Attempting to correct DiscNumberStyle, #cw");
if(_232[4]!=""){
var np=_232[4];
np=np.replace("^0","");
mb.log.debug("Expanding #cw to disc $",np);
gc.i.insertWordsAtIndex(gc.i.getPos()+1,[" ",np]);
}
var pos=gc.i.getPos();
var len=gc.i.getLength();
var wi=pos+1,si=wi;
while((wi<len-1)&&(gc.i.getWordAtIndex(wi).match(gc.re.SPACES_DOTS)!=null)){
wi++;
}
if(si!=wi){
mb.log.debug("Skipped spaces & dots, index: $->$",si,wi);
}
w=(gc.i.getWordAtIndex(wi)||"");
mb.log.debug("Attempting to match number/roman numeral $, or bonus_disc",w);
if(w.match(gc.re.SERIES_NUMBER)||gc.i.getWordAtIndex(pos-2)=="bonus"){
var lw=gc.o.getLastWord();
if(lw=="-"||lw==":"){
mb.log.debug("Dropping last word $",lw);
gc.o.dropLastWord();
}
gc.o.appendSpaceIfNeeded();
if(!gc.f.isInsideBrackets()){
mb.log.debug("Opening an new set of brackets");
gc.i.insertWordAtEnd(")");
gc.i.updateCurrentWord("(");
this.doOpeningBracket();
}
gc.o.appendWord("disc");
gc.f.openingBracket=false;
gc.f.spaceNextWord=false;
gc.f.forceCaps=false;
gc.f.number=false;
gc.f.disc=true;
return mb.log.exit(true);
}
}
return mb.log.exit(false);
};
this.doFeaturingArtistStyle=function(){
mb.log.enter(this.GID,"doFeaturingArtistStyle");
if(!gc.re.FEAT){
gc.re.FEAT=/^featuring$|^f$|^ft$|^feat$/i;
gc.re.FEAT_F=/^f$/i;
}
if(gc.i.matchCurrentWord(gc.re.FEAT)){
if((gc.i.getCurrentWord().match(gc.re.FEAT_F))&&!gc.i.isNextWord(".")){
mb.log.debug("Matched f, but next character is not a \".\"...");
return mb.log.exit(false);
}
if(!gc.f.openingBracket){
mb.log.debug("Matched feat., but previous word is not a closing bracket.");
if(gc.f.isInsideBrackets()){
var _239=new Array();
while(gc.f.isInsideBrackets()){
var cb=gc.f.popBracket();
gc.o.appendWord(cb);
if(gc.i.getWordAtIndex(gc.i.getLength()-1)==cb){
gc.i.dropLastWord();
}
}
}
var pos=gc.i.getPos();
var len=gc.i.getLength();
for(var i=pos;i<len;i++){
if(gc.i.getWordAtIndex(i)=="("){
break;
}
}
if(i!=pos&&i<len-1){
mb.log.debug("Found another opening bracket, closing feat. part");
gc.i.insertWordsAtIndex(i,[")"," "]);
}
gc.i.updateCurrentWord("(");
this.doOpeningBracket();
}
gc.o.appendWord("feat.");
gc.f.forceCaps=true;
gc.f.openingBracket=false;
gc.f.spaceNextWord=true;
gc.f.slurpExtraTitleInformation=true;
gc.f.feat=true;
if(gc.i.isNextWord(".")){
gc.i.nextIndex();
}
return mb.log.exit(true);
}
return mb.log.exit(false);
};
mb.log.exit();
}
GcHandler.prototype=new GcHandler;
function GcTrackHandler(){
mb.log.enter("GcTrackHandler","__constructor");
this.CN="GcTrackHandler";
this.GID="gc.track";
this.process=function(is){
mb.log.enter(this.GID,"process");
is=this.stripInformationToOmit(is);
is=this.preProcessCommons(is);
is=this.preProcessTitles(is);
is=this.runVinylChecks(is);
var w=gc.i.splitWordsAndPunctuation(is);
w=this.prepExtraTitleInfo(w);
gc.o.init();
gc.i.init(is,w);
while(!gc.i.isIndexAtEnd()){
this.processWord();
}
var os=this.getOutput();
return mb.log.exit(os);
};
this.checkSpecialCase=function(is){
mb.log.enter(this.GID,"checkSpecialCase");
if(is){
if(!gc.re.TRACK_DATATRACK){
gc.re.TRACK_DATATRACK=/^([\(\[]?\s*data(\s+track)?\s*[\)\]]?$)/i;
gc.re.TRACK_SILENCE=/^([\(\[]?\s*silen(t|ce)(\s+track)?\s*[\)\]]?)$/i;
gc.re.TRACK_UNTITLED=/^([\(\[]?\s*untitled(\s+track)?\s*[\)\]]?)$/i;
gc.re.TRACK_UNKNOWN=/^([\(\[]?\s*(unknown|bonus)(\s+track)?\s*[\)\]]?)$/i;
gc.re.TRACK_MYSTERY=/^\?+$/i;
}
if(is.match(gc.re.TRACK_DATATRACK)){
return mb.log.exit(this.SPECIALCASE_DATA_TRACK);
}else{
if(is.match(gc.re.TRACK_SILENCE)){
return mb.log.exit(this.SPECIALCASE_SILENCE);
}else{
if(is.match(gc.re.TRACK_UNTITLED)){
return mb.log.exit(this.SPECIALCASE_UNTITLED);
}else{
if(is.match(gc.re.TRACK_UNKNOWN)){
return mb.log.exit(this.SPECIALCASE_UNKNOWN);
}else{
if(is.match(gc.re.TRACK_MYSTERY)){
return mb.log.exit(this.SPECIALCASE_UNKNOWN);
}
}
}
}
}
}
return mb.log.exit(this.NOT_A_SPECIALCASE);
};
this.doWord=function(){
mb.log.enter(this.GID,"doWord");
var _242=gc.i.getCurrentWord();
if(this.doFeaturingArtistStyle()){
}else{
if(this.doVersusStyle()){
}else{
if(this.doVolumeNumberStyle()){
}else{
if(this.doPartNumberStyle()){
}else{
if(gc.i.matchCurrentWord(/7in/i)){
gc.o.appendSpaceIfNeeded();
gc.o.appendWord("7\"");
gc.f.resetContext();
gc.f.spaceNextWord=false;
gc.f.forceCaps=false;
}else{
if(gc.i.matchCurrentWord(/12in/i)){
gc.o.appendSpaceIfNeeded();
gc.o.appendWord("12\"");
gc.f.resetContext();
gc.f.spaceNextWord=false;
gc.f.forceCaps=false;
}else{
gc.o.appendSpaceIfNeeded();
gc.i.capitalizeCurrentWord();
mb.log.debug("Plain word: #cw");
gc.o.appendCurrentWord();
gc.f.resetContext();
gc.f.spaceNextWord=true;
gc.f.forceCaps=false;
}
}
}
}
}
}
gc.f.number=false;
return mb.log.exit(null);
};
mb.log.exit();
}
GcTrackHandler.prototype=new GcHandler;
function GuessCase(){
mb.log.enter("GuessCase","__constructor");
this.CN="GuessCase";
this.GID="gc";
this.getModID=function(){
return "es.gc";
};
this.getModName=function(){
return "Guess Case";
};
if(es){
es.gc=this;
}
this.u=new GcUtils();
this.f=new GcFlags();
this.i=new GcInput();
this.o=new GcOutput();
this.artistHandler=null;
this.albumHandler=null;
this.trackHandler=null;
this.re={SPACES_DOTS:/\s|\./i,SERIES_NUMBER:/(\d|[ivx]+)/i};
this.modes=new GcModes();
this.mode=this.modes.getDefaultMode();
this.COOKIE_MODE=this.getModID()+".mode";
this.CFG_AUTOFIX=this.getModID()+".autofix";
this.CFG_UC_ROMANNUMERALS=this.getModID()+".uc_romannumerals";
this.CFG_UC_UPPERCASED=this.getModID()+".uc_uppercased";
this.CONFIG_LIST=[new EsModuleConfig(this.CFG_AUTOFIX,false,"Apply Guess Case after page loads","The Guess Case function is automatically applied for all the fields in the form. You can press Undo All if you want to reverse the changes"),new EsModuleConfig(this.CFG_UC_ROMANNUMERALS,true,"Uppercase roman numerals","Convert roman numerals i, ii, iii, iv etc. to uppercase."),new EsModuleConfig(this.CFG_UC_UPPERCASED,true,"Keep uppercase words uppercased","If a word is all uppercase characters, it is kept that way (Overrides normal behaviour)")];
this.setupModuleDelegate=function(){
this.DEFAULT_EXPANDED=true;
this.DEFAULT_VISIBLE=true;
};
this.resetModuleDelegate=function(){
mb.cookie.remove(this.COOKIE_MODE);
};
this.getModuleHtml=function(){
var cv=mb.cookie.get(this.COOKIE_MODE);
if(cv){
this.setMode(cv);
}
var s=[];
s.push(this.getModuleStartHtml({x:true,log:true}));
s.push("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" class=\"moduletable\">");
s.push("<tr valign=\"top\">");
s.push("<td width=\"10\">");
s.push(this.modes.getDropdownHtml());
s.push("</td>");
s.push("<td width=\"10\">&nbsp;</td>");
s.push("<td width=\"100%\">");
s.push("<span id=\""+this.getModID()+"-text-expanded\"></span>");
s.push("</td></tr>");
s.push("<tr valign=\"top\">");
s.push("<td colspan=\"3\">");
s.push(this.getConfigHtml());
s.push("</td></tr>");
s.push("</table>");
s.push(this.getModuleEndHtml({x:true}));
s.push(this.getModuleStartHtml({x:false}));
s.push(this.getModuleEndHtml({x:false}));
return s.join("");
};
this.onModuleHtmlWrittenDelegate=function(){
if(this.isConfigTrue(this.CFG_AUTOFIX)){
mb.registerDOMReadyAction(new MbEventAction("es","guessAllFields","Autoguess all input fields"));
}
this.modes.updateUI();
};
this.init=function(){
this.f.init();
};
this.guessArtist=function(is){
var os,handler;
gc.init();
mb.log.enter(this.GID,"guessArtist");
if(!gc.artistHandler){
gc.artistHandler=new GcArtistHandler();
}
handler=gc.artistHandler;
mb.log.info("Input: $",is);
gc.useArtistMode();
var num=handler.checkSpecialCase(is);
if(handler.isSpecialCase(num)){
os=handler.getSpecialCaseFormatted(is,num);
mb.log.info("Result after special case check: $",os);
}else{
os=handler.process(is);
mb.log.info("Result after guess: $",os);
}
gc.restoreMode();
return mb.log.exit(os);
};
this.guessSortname=function(is){
var os,handler;
gc.init();
mb.log.enter(this.GID,"guessArtistSortame");
if(!gc.artistHandler){
gc.artistHandler=new GcArtistHandler();
}
handler=gc.artistHandler;
mb.log.info("Input: $",is);
gc.useArtistMode();
var num=handler.checkSpecialCase(is);
if(handler.isSpecialCase(num)){
os=handler.getSpecialCaseFormatted(is,num);
mb.log.info("Result after special case check: $",os);
}else{
os=handler.guessSortName(is);
mb.log.info("Result after guess: $",os);
}
gc.restoreMode();
return mb.log.exit(os);
};
this.guessAlbum=function(is,mode){
var os,handler;
gc.init();
mb.log.enter(this.GID,"guessAlbum");
if(!gc.albumHandler){
gc.albumHandler=new GcAlbumHandler();
}
handler=gc.albumHandler;
mb.log.info("Input: $",is);
this.useSelectedMode(mode);
var num=handler.checkSpecialCase(is);
if(handler.isSpecialCase(num)){
os=handler.getSpecialCaseFormatted(is,num);
mb.log.info("Result after special case check: $",os);
}else{
os=handler.process(is);
mb.log.info("Result after guess: $",os);
}
return mb.log.exit(os);
};
this.guessTrack=function(is,mode){
var os,handler;
gc.init();
mb.log.enter(this.GID,"guessTrack");
if(!gc.trackHandler){
gc.trackHandler=new GcTrackHandler();
}
handler=gc.trackHandler;
mb.log.info("Input: $",is);
this.useSelectedMode(mode);
var num=handler.checkSpecialCase(is);
if(handler.isSpecialCase(num)){
os=handler.getSpecialCaseFormatted(is,num);
mb.log.info("Result after special case check: $",os);
}else{
os=handler.process(is);
mb.log.info("Result after guess: $",os);
}
return mb.log.exit(os);
};
this.setMode=function(mode){
mb.log.enter(this.GID,"setMode");
var o;
if(mode instanceof GcMode){
this.mode=mode;
mb.log.debug("Set mode from object: $",mode);
return mb.log.exit(true);
}else{
if((o=gc.modes.getModeFromID(mode,true))!=null){
this.mode=o;
mb.log.debug("Set mode from id: $",mode);
return mb.log.exit(true);
}else{
mb.log.warning("Unhandled parameter given: $",mode);
return mb.log.exit(false);
}
}
};
this.useArtistMode=function(){
mb.log.enter(this.GID,"useArtistMode");
this.setTemporaryMode(gc.modes.getArtistMode());
mb.log.exit();
};
this.useSelectedMode=function(mode){
if(mode&&this.setMode(mode)){
}else{
if(this.isUIAvailable()){
gc.modes.useModeFromUI();
}
}
};
this.setTemporaryMode=function(mode){
mb.log.enter(this.GID,"setTemporaryMode");
if(mode instanceof GcMode){
this.oldmode=this.mode;
this.mode=mode;
mb.log.debug("Stored mode: $, new: $",this.oldmode.getID(),this.mode.getID());
}
mb.log.exit();
};
this.restoreMode=function(){
mb.log.enter(this.GID,"restoreMode");
if(this.oldmode&&this.oldmode instanceof GcMode){
this.mode=this.oldmode;
this.oldmode=null;
mb.log.debug("Restored mode: $",this.mode);
}
mb.log.exit();
};
this.getModes=function(){
return this.modes;
};
this.getMode=function(){
return this.mode;
};
this.getCurrentWord=function(){
return gc.i.getCurrentWord();
};
this.getInput=function(){
return gc.i;
};
this.getOutput=function(){
return gc.o;
};
this.getUtils=function(){
return gc.u;
};
mb.log.exit();
}
try{
GuessCase.prototype=new EsModuleBase;
}
catch(e){
mb.log.error("GuessCase: Could not register EsModuleBase prototype");
mb.log.error(e);
}
function EditSuite(){
this.CN="EditSuite";
this.GID="es";
mb.log.enter(this.CN,"__constructor");
this.modules=[];
this.loadModuleError=false;
this.registerModule=function(mod){
mb.log.enter(this.GID,"registerModule");
if(!this.loadModuleError){
if(mod.getModID){
var ref=(mod.getModID()||"");
if(ref!=""){
mb.log.debug("$ (es.$)",mod.CN,ref);
if(mod.setupModule){
mod.setupModule();
}
if(mod.isVisible){
this.modules.push(mod);
}
}else{
this.loadModuleError=true;
mb.log.error("Module $ did return \"\" as a reference!",mod.CN);
}
}else{
mb.log.error("Module $ does not define getModuleRef",mod.CN);
this.loadModuleError=true;
}
}
mb.log.exit();
return mod;
};
this.getRegisteredModules=function(){
return this.modules;
};
this.getModule=function(id){
var m=null;
for(var i=0;i<this.modules.length;i++){
if((m=this.modules[i]).getModID()==id){
break;
}
m=null;
}
return m;
};
this.getDisplayedModules=function(){
return this.modules;
};
this.guessArtistField=function(_25c){
mb.log.enter(this.GID,"guessArtistField");
_25c=(_25c||"artist");
var f;
if((f=es.ui.getField(_25c))!=null){
var ov=f.value,nv=ov;
if(!mb.utils.isNullOrEmpty(ov)){
mb.log.info("Guessing artist field, input: $",ov);
if((nv=es.gc.guessArtist(ov))!=ov){
es.ur.addUndo(es.ur.createItem(f,"Guess Artist",ov,nv));
f.value=nv;
es.ui.resetSelection();
}else{
mb.log.info("Guess yielded same result, nothing to do.");
}
}else{
mb.log.info("Field value is null or empty, nothing to do.");
}
}else{
mb.log.error("Did not find the field: $",_25c);
}
mb.log.exit();
};
this.guessAlbumField=function(_25f,mode){
mb.log.enter(this.GID,"guessAlbumField");
_25f=(_25f||"album");
var f;
if((f=es.ui.getField(_25f))!=null){
var ov=f.value,nv=ov;
if(!mb.utils.isNullOrEmpty(ov)){
mb.log.info("Guessing album field, input: $",ov);
mb.log.debug("* mode: $",mode);
if((nv=es.gc.guessAlbum(ov,mode))!=ov){
es.ur.addUndo(es.ur.createItem(f,"Guess Album ("+es.gc.getMode()+")",ov,nv));
f.value=nv;
es.ui.resetSelection();
}else{
mb.log.info("Guess yielded same result, nothing to do.");
}
}else{
mb.log.info("Field value is null or empty, nothing to do.");
}
}else{
mb.log.error("Did not find the field: $",_25f);
}
mb.log.exit();
};
this.guessTrackField=function(_263,mode){
mb.log.enter(this.GID,"guessTrackField");
var f;
if((f=es.ui.getField(_263))!=null){
var ov=f.value,nv=ov;
if(!mb.utils.isNullOrEmpty(ov)){
mb.log.info("Guessing track field, input: $",ov);
mb.log.debug("* mode: $",mode);
if((nv=es.gc.guessTrack(ov,mode))!=ov){
es.ur.addUndo(es.ur.createItem(f,"Guess Track ("+es.gc.getMode()+")",ov,nv));
f.value=nv;
es.ui.resetSelection();
}else{
mb.log.info("Guess yielded same result, nothing to do.");
}
}else{
mb.log.info("Field value is null or empty, nothing to do. $",ov);
}
}else{
mb.log.error("Did not find the field: $",_263);
}
mb.log.exit();
};
this.guessAllFields=function(){
mb.log.enter(this.GID,"guessAllFields");
var f,fields=es.ui.getEditTextFields();
var _268,name,cn;
for(var j=0;j<fields.length;j++){
f=fields[j];
_268=(f.value||"");
name=(f.name||"");
cn=(f.className||"");
if(!cn.match(/hidden/i)){
if(!mb.utils.isNullOrEmpty(_268)){
mb.log.scopeStart("Guessing next field: "+name);
this.guessByFieldName(name);
}else{
mb.log.info("Field is empty, name: $",name);
}
}
}
mb.log.exit();
};
this.guessByFieldName=function(name,mode){
mb.log.enter(this.GID,"guessByFieldName");
if(name.match(es.ui.re.TRACKFIELD)){
this.guessTrackField(name,mode);
}else{
if(name.match(es.ui.re.ALBUMFIELD)){
this.guessAlbumField(name,mode);
}else{
if(name.match(es.ui.re.ARTISTFIELD)){
this.guessArtistField(name);
}else{
if(name.match(es.ui.re.SORTNAMEFIELD)){
var _26c=name.replace("sort","");
this.guessSortnameField(artistfield,name);
}else{
mb.log.warning("Unhandled name: $",name);
}
}
}
}
mb.log.exit();
};
this.copySortnameField=function(_26d,_26e){
mb.log.enter(this.GID,"copySortnameField");
var fa,fsn;
if((fa=es.ui.getField(_26d))!=null&&(fsn=es.ui.getField(_26e))!=null){
var ov=fsn.value;
var nv=fa.value;
if(nv!=ov){
fsn.value=nv;
es.ur.addUndo(es.ur.createItem(fsn,"sortnamecopy",ov,nv));
es.ui.resetSelection();
}else{
mb.log.info("Destination is same as source, nothing to do.");
}
}else{
mb.log.error("Did not find the fields: $, $",_26d,_26e);
}
mb.log.exit();
};
this.guessSortnameField=function(_272,_273){
mb.log.enter(this.GID,"guessSortnameField");
var fa,fsn;
if((fa=es.ui.getField(_272))!=null&&(fsn=es.ui.getField(_273))!=null){
var av=fa.value,ov=fsn.value,nv=ov;
if(!mb.utils.isNullOrEmpty(av)){
mb.log.info("fa: $, fsn: $, value: $",fa.name,fsn.name,fa.value);
if((nv=es.gc.guessSortname(av))!=ov){
es.ur.addUndo(es.ur.createItem(fsn,"sortname",ov,nv));
fsn.value=nv;
es.ui.resetSelection();
}else{
mb.log.info("Guess yielded same result, nothing to do.");
}
}else{
mb.log.info("Artist name is empty, nothing to do.");
}
}else{
mb.log.error("Did not find the fields: $, $",_272,_273);
}
mb.log.exit();
};
this.swapFields=function(){
mb.log.enter(this.GID,"swapFields");
var f1,f2,fs;
var fn1=(arguments[0]||"search");
var fn2=(arguments[1]||"trackname");
var fns=(arguments[2]||"swapped");
if(((f1=es.ui.getField(fn1))!=null)&&((f2=es.ui.getField(fn2))!=null)&&((fs=es.ui.getField(fns))!=null)){
var _27a=(1-fs.value);
var f1v=f1.value;
var f2v=f2.value;
es.ur.addUndo(es.ur.createItemList(es.ur.createItem(f2,"swap",f2v,f1v),es.ur.createItem(f1,"swap",f1v,f2v),es.ur.createItem(fs,"swap",fs.value,_27a)));
f1.value=f2v;
f2.value=f1v;
fs.value=_27a;
}else{
mb.log.error("Did not find the fields: $,$,$",fn1,fn2,fns);
}
mb.log.exit();
};
es=this;
es.ui=this.registerModule(new EsUiModule());
es.gc=this.registerModule(new GuessCase());
es.ur=this.registerModule(new EsUndoModule());
es.qf=this.registerModule(new EsQuickFunctions());
es.fr=this.registerModule(new EsFieldResizer());
es.sr=this.registerModule(new EsSearchReplace());
es.tp=this.registerModule(new EsTrackParser());
es.cfg=this.registerModule(new EsConfigModule());
gc=es.gc;
es.modnote=this.registerModule(new EsModNoteModule());
es.changeartist=this.registerModule(new EsChangeArtistModule());
mb.log.exit();
}
mb.log.scopeStart("Loading the EditSuite object");
mb.log.enter("editsuite.js","__init");
try{
new EditSuite();
var obj;
if((obj=mb.ui.get("editsuite-noscript"))!=null){
obj.className="";
obj.innerHTML=es.cfg.getConfigureLinkHtml();
}
if((obj=mb.ui.get("editsuite-content"))!=null){
es.ui.writeUI(obj,null);
}
}
catch(ex){
mb.log.error("Error while initalising EditSuite! ex: $",(ex.message||"?"));
mb.log.error(mb.log.getStackTrace());
es=null;
gc=null;
}
mb.log.exit();

