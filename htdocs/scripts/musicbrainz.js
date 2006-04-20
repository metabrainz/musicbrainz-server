function MbCookie(){
this.CN="MbCookie";
this.GID="mb.cookie";
this.set=function(_1,_2,_3,_4,_5,_6){
mb.log.enter(this.GID,"set");
_4=(_4||"/");
var _7=null;
if(_3){
var _8=new Date().getTime();
_8+=parseInt(_3)*24*60*60*1000;
_7=new Date(_8);
}
var s=[];
s.push(_1+"="+escape(_2));
s.push(((_7)?"; expires="+_7.toGMTString():""));
s.push(((_4)?"; path="+_4:""));
s.push(((_5)?"; domain="+_5:""));
s.push(((_6)?"; secure":""));
s=s.join("");
document.cookie=s;
mb.log.debug("Setting cookie: $",s);
mb.log.exit();
};
this.get=function(_a){
mb.log.enter(this.GID,"get");
var dc=document.cookie;
var _c,_to,_key=_a+"=";
if((_c=dc.indexOf("; "+_key))==-1){
_c=dc.indexOf(_key);
if(_c!=0){
return mb.log.exit(null);
}
}else{
_c+=2;
}
if((_to=dc.indexOf(";",_c))==-1){
_to=dc.length;
}
var v=dc.substring(_c+_key.length,_to);
v=unescape(v);
return mb.log.exit(v);
};
this.getBool=function(_e){
mb.log.enter(this.GID,"getBool");
var cv=this.get(_e);
var f=null;
if(cv&&cv!="null"){
f=(cv=="1");
}
return mb.log.exit(f);
};
this.remove=function(_11,_12,_13){
mb.log.enter(this.GID,"remove");
if(this.get(_11)){
_12=(_12||"/");
document.cookie=_11+"=null"+((_12)?"; path="+_12:"")+((_13)?"; domain="+_13:"")+"; expires=Thu, 01-Jan-70 00:00:01 GMT";
mb.log.debug("Deleted cookie: $",_11);
}
mb.log.exit();
};
}
function MbUtils(){
this.CN="MbUtils";
this.GID="mb.utils";
this.leadZero=function(){
var n=arguments[0];
var s=(arguments[1]?arguments[1]:"0");
return (n<10?new String(s)+n:n);
};
this.getInt=function(s){
return parseInt(("0"+s),10);
};
this.trim=function(s){
if(this.isNullOrEmpty(s)){
return "";
}else{
return s.replace(/^\s*/,"").replace(/\s*$/,"");
}
};
this.isArray=function(o){
return (o instanceof Array||typeof o=="array");
};
this.isFunction=function(wh){
return (o instanceof Function||typeof o=="function");
};
this.isString=function(o){
return (o instanceof String||typeof o=="string");
};
this.isNumber=function(o){
return (o instanceof Number||typeof o=="number");
};
this.isBoolean=function(o){
return (o instanceof Boolean||typeof o=="boolean");
};
this.isUndefined=function(o){
return ((o==undefined)&&(typeof o=="undefined"));
};
this.isNullOrEmpty=function(is){
return (!is||is=="");
};
}
function MbLog(){
mb.log=this;
this.CN="MbLog";
this.GID="mb.log";
this.TRACE=0;
this.DEBUG=1;
this.INFO=2;
this.WARNING=3;
this.ERROR=4;
this.LEVEL_DESC=["TRACE","DEBUG","INFO&nbsp;","WARN&nbsp;","ERROR"];
this.COOKIE_LEVEL=this.CN+".level";
this._level=this.INFO;
this._list=[];
this._stack=[];
this._start=new Date().getTime();
this.LOG_METHODS=true;
this.LOGDIV="MbLogDiv";
this.getLevel=function(_1f){
this.enter(this.GID,"getLevel");
_1f=(_1f||true);
var cv=mb.cookie.get(this.COOKIE_LEVEL);
this.setLevel(cv||this.INFO,_1f);
this.exit();
};
this.setLevel=function(l,_22){
this.enter(this.GID,"setLevel");
if(l!=this._level){
if(l>=this.TRACE&&l<=this.ERROR){
this._level=l;
if(!_22){
this.info("Changing log level to: $",this.LEVEL_DESC[this._level]);
}
}
}else{
if(!_22){
this.info("No change, level is: $",this.LEVEL_DESC[this._level]);
}
}
this.exit();
};
this.onSetLevelClicked=function(_23){
this.scopeStart("Handling click on loglevel checkbox");
this.enter(this.GID,"onSetLevelClicked");
this.setLevel(_23);
mb.cookie.set(this.COOKIE_LEVEL,this._level,365);
this.exit();
this.scopeEnd();
};
this.checkLevel=function(l){
return (l>=this._level);
};
this.isDebugMode=function(){
this.enter(this.GID,"isDebugMode");
var f=(this._level==this.DEBUG);
return this.exit(f);
};
this.scopeStart=function(_26){
var m=this.getMethodFromStack();
if(mb.isPageLoading&&!mb.isPageLoading()){
this._start=new Date().getTime();
}
if(_26){
var s=[];
s.push("<div class=\"log-scope\">");
s.push(_26);
s.push((m!=" "?" &nbsp;&mdash;&nbsp; <i>"+m+"</i>":""));
s.push("&#x2026;");
s.push("</div>");
this._list.push(s.join(""));
}
};
this.scopeEnd=function(){
var obj;
if(mb.ui){
if((obj=mb.ui.get(this.LOGDIV))!=null){
obj.innerHTML=this._list.join("");
}else{
this.error("Did not find the LOGDIV!");
}
}
this._list=[];
this._stack=[];
};
this.getMessages=function(){
this.enter(this.GID,"getMessages");
return this.exit(this._list||[]);
};
this.enter=function(_2a,_2b){
this._stack.push([_2a,_2b]);
if(this.checkLevel(this.TRACE)){
var s=[];
s.push("<div class=\"log-enter\">");
s.push(this.getStackIndent());
s.push("Entering: ");
var m=this.getMethodFromStack();
s.push((m!=" "?m:"???"));
s.push("</div>");
this._list.push(s.join(""));
}
};
this.exit=function(r){
if(this.checkLevel(this.TRACE)){
var s=[];
s.push("<div class=\"log-exit\">");
s.push(this.getStackIndent());
s.push("Leaving: &nbsp;");
var m=this.getMethodFromStack();
s.push((m!=" "?m:"???"));
s.push("</div>");
this._list.push(s.join(""));
}
this._stack.pop();
return r;
};
this.getStackIndent=function(s){
s=(s||"&nbsp;&nbsp;");
return (new Array(this._stack.length)).join(s);
};
this.getMethodFromStack=function(_32){
var m=" ";
if(this._stack.length!=0){
_32=(_32||this._stack.length-1);
m=this._stack[_32];
m=(m[0]?m[0]+".":"")+(m[1]?m[1]+"() ":" ");
}
return m;
};
this.getStackTrace=function(){
this.enter(this.GID,"getStackTrace");
var s=["Stacktrace: "];
for(var i=this._stack.length-1;i>=0;i--){
s.push(this.getMethodFromStack(i).replace(/[\s:]*$/,""));
}
s=s.join("\n * ");
return this.exit(s);
};
this.getHighlightHtml=function(w){
var s=[];
var pre="<span class=\"log-highlight\">";
var end="</span>";
if(mb.utils.isArray(w)){
s.push("[");
s.push(pre);
s.push(w.join(end+", "+pre));
s.push(end);
s.push("]");
}else{
if(mb.utils.isString(w)){
w=w.replace(/\$/g,"&#36;");
}
s.push(pre);
try{
s.push(w.toString());
}
catch(ex){
s.push(w);
}
s.push(end);
}
return s.join("");
};
this.getTimeSinceStart=function(){
var _3a=(new Date().getTime()-this._start);
if(_3a<10){
_3a="  "+_3a;
}else{
if(_3a<100){
_3a=" "+_3a;
}else{
_3a=""+_3a;
}
}
return _3a.replace(/\s/g,"&nbsp;");
};
this.getMessageStartHtml=function(_3b){
var s=[];
s.push("<div class=\"log-level-");
switch(_3b){
case this.DEBUG:
s.push("debug");
break;
case this.INFO:
s.push("info");
break;
case this.WARNING:
s.push("warning");
break;
case this.ERROR:
s.push("error");
break;
}
s.push("\">");
s.push(this.getTimeSinceStart());
s.push("ms - ");
s.push(this.LEVEL_DESC[_3b]);
s.push(" - ");
return s.join("");
};
this.getMessageEndHtml=function(_3d){
return "</div>";
};
this.writeUI=function(){
this.enter(this.GID,"writeUI");
this.getLevel(true);
var s=[];
s.push("<table class=\"log-messages\">");
s.push("  <tr><td class=\"header\">");
s.push("    Set Debug Level: &nbsp;");
var f="mb.log.onSetLevelClicked(this.id)";
for(var i=0;i<this.LEVEL_DESC.length;i++){
s.push("<input name=\"debuglevel\" id=\""+i+"\" type=\"radio\" ");
s.push((this._level==i?" checked=\"checked\" ":""));
s.push("onClick=\""+f+"\">"+this.LEVEL_DESC[i]+" &nbsp;");
}
s.push("&nbsp; <input type=\"button\" onclick=\"mb.log.scopeEnd()\" value=\"Dump\"/>");
s.push("  </td></tr>");
s.push("  <tr><td class=\"title\">");
s.push("    Log Messages:");
s.push("  </td></tr>");
s.push("  <tr><td>");
s.push("<div id=\""+this.LOGDIV+"\" class=\"inner\"></td>");
s.push("</tr>");
s.push("</table>");
document.write(s.join(""));
this.exit();
};
this.trace=function(){
if(this.checkLevel(this.TRACE)){
this.logMessage(this.TRACE,arguments);
}
};
this.debug=function(){
if(this.checkLevel(this.DEBUG)){
this.logMessage(this.DEBUG,arguments);
}
};
this.info=function(){
if(this.checkLevel(this.INFO)){
this.logMessage(this.INFO,arguments);
}
};
this.warning=function(){
if(this.checkLevel(this.WARNING)){
this.logMessage(this.WARNING,arguments);
}
};
this.error=function(){
if(this.checkLevel(this.ERROR)){
this.logMessage(this.ERROR,arguments);
}
};
this.logMessage=function(){
if(arguments.length!=2){
this.enter(this.GID,"logMessage");
this.error("Expected level, message arguments, but got $ arguments",arguments.length);
this.exit();
}else{
var _41=arguments[0];
var _42=arguments[1];
var msg="";
if(_42&&(msg=_42[0])!=null){
msg=msg.split(" ").join("&nbsp;");
msg=msg.split(/\n/).join("<br/>");
if(typeof (gc)!="undefined"&&gc!=null&&gc.getCurrentWord){
var cw;
if((cw=gc.getCurrentWord())!=null){
msg=msg.replace("#cw",this.getHighlightHtml(cw));
}
}
if(_42.length>1){
for(var i=1;i<_42.length;i++){
msg=msg.replace(/\$/,this.getHighlightHtml(_42[i]));
}
}
var t=[];
t.push(this.getMessageStartHtml(_41));
if(this.LOG_METHODS){
t.push(this.getMethodFromStack());
t.push(" :: ");
}
t.push(msg);
t.push(this.getMessageEndHtml(_41));
msg=t.join("");
this._list.push(msg);
}else{
this.enter(this.GID,"logMessage");
this.error("Expected args[0] to be the message, but got null.");
}
}
};
this.getLevel();
this.scopeEnd();
this.scopeStart("Loading the Logging object");
this.enter(this.GID,"__constructor");
this.exit();
}
if(Array.prototype.push&&([0].push(true)==true)){
Array.prototype.push=null;
}
if(Array.prototype.splice&&typeof ([0].splice(0))=="number"){
Array.prototype.splice=null;
}
if(!Array.prototype.shift){
Array.prototype.shift=function(){
firstElement=this[0];
this.reverse();
this.length=Math.max(this.length-1,0);
this.reverse();
return firstElement;
};
}
if(!Array.prototype.unshift){
Array.prototype.unshift=function(){
this.reverse();
for(var i=arguments.length-1;i>=0;i--){
this[this.length]=arguments[i];
}
this.reverse();
return this.length;
};
}
if(!Array.prototype.push){
Array.prototype.push=function(){
for(var i=0;i<arguments.length;i++){
this[this.length]=arguments[i];
}
return this.length;
};
}
if(!Array.prototype.pop){
Array.prototype.pop=function(){
lastElement=this[this.length-1];
this.length=Math.max(this.length-1,0);
return lastElement;
};
}
if(!Array.prototype.splice){
Array.prototype.splice=function(ind,cnt){
if(arguments.length==0){
return ind;
}
if(typeof ind!="number"){
ind=0;
}
if(ind<0){
ind=Math.max(0,this.length+ind);
}
if(ind>this.length){
if(arguments.length>2){
ind=this.length;
}else{
return [];
}
}
if(arguments.length<2){
cnt=this.length-ind;
}
cnt=(typeof cnt=="number")?Math.max(0,cnt):0;
removeArray=this.slice(ind,ind+cnt);
endArray=this.slice(ind+cnt);
this.length=ind;
var i;
for(i=2;i<arguments.length;i++){
this[this.length]=arguments[i];
}
for(i=0;i<endArray.length;i++){
this[this.length]=endArray[i];
}
return removeArray;
};
}
function MbUI(){
this.CN="MbUI";
this.GID="mb.ui";
this.SPLITSEQ="::";
this.get=function(id,_4d){
mb.log.enter(this.GID,"get");
var el,nn;
if(id){
_4d=(_4d||document);
if(_4d.getElementById){
el=_4d.getElementById(id);
nn=(el&&el.nodeName?el.nodeName:"?");
mb.log.trace("Querying element id: $, el: $",id,nn);
}else{
mb.log.error("Element parent $ does not support getElementById!",_4d);
}
}else{
mb.log.error("Required parameter $ was null","id");
}
return mb.log.exit(el);
};
this.getByTag=function(tag,_50){
mb.log.enter(this.GID,"getByTag");
var _51=[];
if(tag){
_50=(_50||document);
if(_50.getElementsByTagName){
_51=_50.getElementsByTagName(tag);
mb.log.trace("Querying elements with tag: $, parent: $, length: $",tag,(_50.nodeName||_50),_51.length);
}else{
mb.log.error("Element parent $ does not support getElementsByTagName!",_50);
}
}else{
mb.log.error("Required parameter $ was null","tag");
}
return mb.log.exit(_51);
};
this.getByName=function(_52,_53){
mb.log.enter(this.GID,"getByName");
var _54=[];
if(_52){
_53=(_53||document);
if(_53.getElementsByName){
_54=_53.getElementsByName(_52);
mb.log.trace("Querying elements with name: $, parent: $, length: $",_52,(_53.nodeName||_53),_54.length);
}else{
mb.log.error("Element parent $ does not support getElementsByName!",_53);
}
}else{
mb.log.error("Required parameter $ was null","name");
}
return mb.log.exit(_54);
};
this.setDisplay=function(el,_56){
mb.log.enter(this.GID,"get");
if(mb.utils.isString(el)){
var obj;
if((obj=this.get(el))==null){
mb.log.error("Could not find element with id: $",el);
}
el=obj;
}
if(el){
el.style.display=(_56?"":"none");
}else{
mb.log.error("Required parameter el is null!");
}
return mb.log.exit(el);
};
this.getOffsetTop=function(el){
mb.log.enter(this.GID,"getOffsetTop");
if(mb.utils.isString(el)){
var obj;
if((obj=this.get(el))==null){
mb.log.warning("Could not find element with id: $",el);
}
el=obj;
}
var elo=el;
var o=-1;
if(el){
if(mb.ua.nav4){
o=el.pageY;
}else{
if(mb.ua.ie4up||mb.ua.gecko){
o=0;
while(el.offsetParent!=null){
o+=el.offsetTop;
el=el.offsetParent;
}
o+=el.offsetTop;
}else{
if(mb.ua.mac&&mb.ua.ie5){
o=stringToNumber(document.body.currentStyle.marginTop);
}
}
}
}else{
mb.log.warning("Element el is null!");
}
mb.log.debug("el: $, top: $",elo,o);
return mb.log.exit(o);
};
this.getLeft=function(el){
mb.log.enter(this.GID,"getLeft");
var o=0;
if(mb.ua.nav4){
o=el.left;
}else{
if(mb.ua.ie4up){
o=el.style.pixelLeft;
}else{
if(mb.ua.gecko){
o=stringToNumber(el.style.left);
}
}
}
mb.log.debug("left: $",o);
return mb.log.exit(o);
};
this.fbBoxCounter=0;
this.setupFeedbackBoxes=function(){
mb.log.enter(this.GID,"setupFeedbackBoxes");
var div,cn,id,list=mb.ui.getByTag("div");
for(var i=0;i<list.length;i++){
div=list[i];
cn=(div.className||"");
if(cn.match(/^feedbackbox info/i)){
this.fbBoxCounter++;
var _60,spans=mb.ui.getByTag("span",div);
var _61,spanText;
for(var j=0;j<spans.length;j++){
_60=spans[j];
id=(_60.id||"");
if(id=="header"){
_61=_60;
}
if(id=="text"){
spanText=_60;
}
}
if(_61&&spanText){
id="feedbackBox"+this.fbBoxCounter;
var a=document.createElement("a");
a.id=id+"|toggle";
a.href="javascript:; // Toggle box";
a.className="readmore";
a.onfocus=function onfocus(_64){
this.blur();
};
a.onclick=function onclick(){
var obj;
var id=this.id.split(mb.ui.SPLITSEQ)[0];
if((obj=mb.ui.get(id))!=null){
var _67=(obj.style.display=="none");
this.firstChild.nodeValue=(_67?"Close":"Read more");
mb.ui.setDisplay(obj,_67);
}else{
mb.log.warning("Did not find: $",this.id);
}
return false;
};
a.appendChild(document.createTextNode("Read more"));
var _68=_61.parentNode;
_68.appendChild(a);
spanText.id=id;
spanText.style.display="none";
}
}
}
return mb.log.exit();
};
this.setupPopupLinks=function(){
mb.log.enter(this.GID,"setupPopupLinks");
var a,id,href,list=mb.ui.getByTag("a");
for(var i=0;i<list.length;i++){
a=list[i];
id=(a.id||"");
href=(a.href||"");
if(id.match(/^POPUP/i)&&href!=""){
var _6b=id.split(mb.ui.SPLITSEQ)[1];
var _6c=a.href;
if(_6c.match(/ispopup/)==null){
if(_6c.match(/\&/)!=null){
_6c+="&amp;ispopup=1";
}else{
_6c+="?ispopup=1";
}
}
a.id=id+mb.ui.SPLITSEQ+_6c+mb.ui.SPLITSEQ+i;
a.title=_6b;
a.onclick=function(_6d){
mb.ui.clickPopupLink(this);
return false;
};
mb.log.debug("id: $, href: $, onclick: $",a.id,a.href,a.onclick);
}
}
return mb.log.exit();
};
this.clickPopupLink=function(el){
var id,href;
if(el){
id=(el.id||"");
if(id.match(/^POPUP/i)){
id=id.split(mb.ui.SPLITSEQ);
var t=id[1];
var w=id[2];
var h=id[3];
var _73=id[4];
var win=window.open(_73,t,"toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width="+w+",height="+h);
}
}
return false;
};
this.moveFocus=function(){
mb.log.enter(this.GID,"moveFocus");
var el,list=mb.ui.getByTag("input");
var _76;
if((el=mb.ui.get("ONLOAD::focusfield"))!=null){
if((_76=el.value)!=null){
var _77,form=el.form;
for(var i=0;i<list.length;i++){
el=list[i];
name=(el.name||"");
_77=el.form;
if((_77==form)&&(name==_76)&&(el.focus)){
el.focus();
break;
}
}
}else{
mb.log.warning("ONLOAD::focusfield has no value!");
}
}else{
mb.log.debug("ONLOAD::focusfield not found.");
}
return mb.log.exit();
};
}
function MbUserAgent(){
mb.log.enter("MbUserAgent","__constructor");
this.CN="MbUserAgent";
this.GID="mb.ua";
var id=navigator.userAgent.toLowerCase();
this.major=mb.utils.getInt(navigator.appVersion);
this.minor=parseFloat(navigator.appVersion);
this.nav=((id.indexOf("mozilla")!=-1)&&((id.indexOf("spoofer")==-1)&&(id.indexOf("compatible")==-1)));
this.nav2=(this.nav&&(this.major==2));
this.nav3=(this.nav&&(this.major==3));
this.nav4=(this.nav&&(this.major==4));
this.nav5=(this.nav&&(this.major==5));
this.nav6=(this.nav&&(this.major==5));
this.gecko=(this.nav&&(this.major>=5));
this.ie=(id.indexOf("msie")!=-1);
this.ie3=(this.ie&&(this.major==2));
this.ie4=(this.ie&&(this.major==3));
this.ie5=(this.ie&&(this.major==4));
this.opera=(id.indexOf("opera")!=-1);
this.nav4up=this.nav&&(this.major>=4);
this.ie4up=this.ie&&(this.major>=4);
mb.log.exit();
}
function MbEventAction(_7a,_7b,_7c){
mb.log.enter("MbEventAction","__constructor");
this.CN="MbEventAction";
this.GID="";
var _7d=_7a;
var _7e=_7b;
var _7f=_7c;
this.getObject=function(){
return _7d;
};
this.getMethod=function(){
return _7e;
};
this.getDescription=function(){
return _7f;
};
this.toString=function(){
var s=[];
s.push(this.CN);
s.push(" [");
s.push(_7f);
s.push(", ");
s.push(this.getCode());
s.push("]");
return s.join("");
};
this.getCode=function(){
var s=[];
s.push(_7d);
s.push(".");
s.push(_7e);
s.push("()");
return s.join("");
};
mb.log.exit();
}
function MbStyleAbbr(){
mb.log.enter("MbStyleAbbr","__constructor");
this.CN="MbStyleAbbr";
this.GID="mb.styleabbr";
this.process=function(){
mb.log.enter(this.GID,"process");
try{
if(document.all){
var el=document.getElementsByTagName("body")[0];
var re=/<abbr([^>]*)>([^<]*)<\/abbr>/gi;
var _84=el.innerHTML;
var _85=_84.replace(re,"<abbr $1><span class=\"abbr\" $1>$2</span></abbr>");
el.innerHTML=_85;
}
}
catch(ex){
}
};
mb.log.exit();
}
function MbTopMenu(){
mb.log.enter("MbTopMenu","__constructor");
this.CN="MbTopMenu";
this.GID="mb.topmenu";
this.status="load",this.timer=new MbTopMenuTimer();
this.OFFSET_LEFT=157;
this.MENUITEM_CLICKED="MENUITEM_CLICKED";
this.MENUITEM_OVER="MENUITEM_OVER";
this.MENUITEM_OUT="MENUITEM_OUT";
this.CLICK_CLICKED="CLICK_CLICKED";
this.CLICK_OVER="CLICK_OVER";
this.CLICK_OUT="CLICK_OUT";
this.DROPDOWN_OVER="DROPDOWN_OVER";
this.DROPDOWN_OUT="DROPDOWN_OUT";
this.items=[];
this.type="both";
this.trigger="mouseover";
this.isClickAllowed=false;
this.displayedDropDown=null;
this.h={m:[],ml:[],sm:[]};
this.init=function(ty,tr,_88){
if(tr&&tr.match(/mouseover|click/i)){
this.trigger=tr.toLowerCase();
}
if(ty&&ty.match(/both|dropdownonly|staticonly/i)){
this.type=ty.toLowerCase();
}
this.items=_88;
};
this.isDropDownEnabled=function(){
return this.type.match(/both|dropdownonly/i);
};
this.allowMouseTrigger=function(){
return ((this.isDropDownEnabled())&&(this.trigger=="mouseover"));
};
this.allowClickTrigger=function(){
return ((this.isDropDownEnabled())&&(this.trigger=="click"));
};
this.handleEvent=function(el,ev){
mb.log.enter(this.GID,"handleEvent");
var id,returncode=true;
if(this.status=="load"){
this.setupEvents();
}
if(this.status=="ready"){
ev=(ev||"");
id=(el.id||"");
id=id.split(".")[0];
if(id!=""&&ev!=""){
mb.log.debug("id: $, ev: $, allow click: $",id,ev,this.isClickAllowed);
if(ev==this.MENUITEM_OVER){
this.timer.activateMenuItem(id,true);
}else{
if(ev==this.MENUITEM_OUT){
this.timer.activateMenuItem(id,false);
}else{
if(ev==this.MENUITEM_CLICKED){
if(this.isClickAllowed){
var url=null;
if((url=this.h.ml[id])!=null){
try{
mb.log.debug("Menu item selected: $",url);
document.location.href=url;
}
catch(e){
mb.log.error("Caught exception: $",e);
}
}
}
}else{
if(ev==this.CLICK_OVER){
this.isClickAllowed=false;
this.timer.clear();
}else{
if(ev==this.CLICK_OUT){
this.isClickAllowed=true;
this.timer.clear();
}else{
if(ev==this.CLICK_CLICKED){
if(this.allowClickTrigger()){
this.timer.clear();
if(this.displayedDropDown){
this.hideDisplayedDropDown();
}else{
this.openDropdown(id);
}
}
returncode=false;
}else{
if(ev==this.DROPDOWN_OVER){
this.timer.hasEnteredSubMenu();
}else{
if(ev==this.DROPDOWN_OUT){
this.timer.hasLeftSubMenu();
}else{
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
mb.log.exit();
return returncode;
};
this.activateMenuItem=function(id,_8e){
if(_8e){
if(this.allowMouseTrigger()){
this.timer.clear();
this.openDropdown(id);
}else{
if(this.displayedDropDown!=null){
this.timer.clear();
this.openDropdown(id);
}
}
}else{
mb.topmenu.hideDisplayedDropDown();
}
};
this.mouseOver=function(id,_90){
mb.log.enter(this.GID,"mouseOver");
mb.log.trace("id: $, flag: $",id,_90);
var obj=null;
if((obj=this.h.m[id])!=null){
var cn=obj.className;
if(_90&&cn.indexOf("hover")==-1){
obj.className=cn+"hover";
}else{
if(!_90&&cn.indexOf("hover")!=-1){
obj.className=cn.replace("hover","");
}
}
}
mb.log.exit();
};
this.hideDisplayedDropDown=function(){
mb.log.enter(this.GID,"hideDisplayedDropDown");
mb.log.debug("Current: $",this.displayedDropDown);
if(this.displayedDropDown){
var obj=null;
if((obj=this.h.sm[this.displayedDropDown])!=null){
obj.style.display="none";
}
}
this.hideRelatedModsIframe(false);
this.displayedDropDown=null;
mb.log.exit();
};
this.openDropdown=function(id){
mb.log.enter(this.GID,"openDropdown");
mb.log.debug("Opening: $",id);
var obj=null;
this.hideDisplayedDropDown();
if((obj=this.h.sm[id])!=null){
this.hideRelatedModsIframe(true);
obj.style.display="block";
this.displayedDropDown=id;
}
mb.log.exit();
};
this.hideRelatedModsIframe=function(_96){
var obj=null;
if((obj=mb.ui.get("RelatedModsBox"))!=null){
obj.style.display=(_96?"none":"block");
}
};
this.setupEvents=function(){
mb.log.enter(this.GID,"setupEvents");
mb.log.debug("Status: $",this.status);
if(this.status=="load"){
this.status="init";
var obj,oName,mName,mOffsetLeft,j;
var len=this.items.length;
mb.log.debug("Setting up $ items...",len);
for(j=len-1;j>=0;j--){
mName=this.items[j][0];
oName=mName+".mouseover";
if((obj=mb.ui.get(oName))!=null){
this.h.m[mName]=obj;
mOffsetLeft=obj.offsetLeft;
obj.onmouseover=function(_9a){
try{
return mb.topmenu.handleEvent(this,mb.topmenu.MENUITEM_OVER);
}
catch(e){
try{
mb.log.error("Caught error, e: $",e);
}
catch(e){
}
}
return true;
};
obj.onmouseout=function(_9b){
try{
return mb.topmenu.handleEvent(this,mb.topmenu.MENUITEM_OUT);
}
catch(e){
try{
mb.log.error("Caught error, e: $",e);
}
catch(e){
}
}
return true;
};
obj.onclick=function(_9c){
try{
return mb.topmenu.handleEvent(this,mb.topmenu.MENUITEM_CLICKED);
}
catch(e){
try{
mb.log.error("Caught error, e: $",e);
}
catch(e){
}
}
return true;
};
oName=mName+".click";
if((obj=mb.ui.get(oName))!=null){
obj.href="javascript:; // Click to open submenu";
obj.onfocus=function(_9d){
this.blur();
};
obj.onmouseover=function(_9e){
try{
return mb.topmenu.handleEvent(this,mb.topmenu.CLICK_OVER);
}
catch(e){
try{
mb.log.error("Caught error, e: $",e);
}
catch(e){
}
}
return true;
};
obj.onmouseout=function(_9f){
try{
return mb.topmenu.handleEvent(this,mb.topmenu.CLICK_OUT);
}
catch(e){
try{
mb.log.error("Caught error, e: $",e);
}
catch(e){
}
}
return true;
};
obj.onclick=function(_a0){
try{
return mb.topmenu.handleEvent(this,mb.topmenu.CLICK_CLICKED);
}
catch(e){
try{
mb.log.error("Caught error, e: $",e);
}
catch(e){
}
}
return true;
};
}else{
mb.log.debug("Object $ not found...",oName);
}
oName=mName+".submenu";
if((obj=mb.ui.get(oName))!=null){
var _a1=this.OFFSET_LEFT+mOffsetLeft;
obj.style.left=""+_a1+"px";
this.h.sm[mName]=obj;
obj.onmouseover=function(_a2){
try{
mb.topmenu.handleEvent(this,mb.topmenu.DROPDOWN_OVER);
}
catch(e){
try{
mb.log.error("Caught error, e: $",e);
}
catch(e){
}
}
return true;
};
obj.onmouseout=function(_a3){
try{
return mb.topmenu.handleEvent(this,mb.topmenu.DROPDOWN_OUT);
}
catch(e){
try{
mb.log.error("Caught error, e: $",e);
}
catch(e){
}
}
return true;
};
}else{
mb.log.debug("Object $ not found...",oName);
}
}else{
mb.log.debug("Object $ not found...",oName);
}
}
this.status="ready";
}
mb.log.debug("Status: $",this.status);
mb.log.exit();
};
this.writeUI=function(_a4){
var s=[];
s.push("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\"><tr>");
for(var i=0;i<this.items.length;i++){
var _a7=this.items[i][0];
var url=this.items[i][1];
var _a9=this.items[i][2];
this.h.ml[_a7]=url;
var cn=(_a4==_a7?"selected":"");
cn=(cn!=""?"class=\""+cn+"\"":"");
s.push("<td nowrap "+cn);
s.push("id=\""+_a7+".mouseover\" ");
s.push("><a ");
s.push("title=\""+_a9+"\" ");
s.push("href=\""+url+"\">"+_a9+"</a>");
if(this.allowClickTrigger()){
s.push("<a ");
s.push("id=\""+_a7+".click\" ");
s.push("><img style=\"padding-left: 3px;\" src=\"/images/dropdown.gif\" alt=\"\" border=\"0\"></a>");
}
s.push("</td>");
}
s.push("<td class=\"mainmenuright\">&nbsp</td></tr></table>");
s=s.join("");
document.write(s);
};
mb.log.exit();
}
function MbSideBar(){
mb.log.enter("MbSideBar","__constructor");
this.CN="MbSideBar";
this.GID="mb.sidebar";
this.COOKIE_SIDEBAR="sidebar";
this.ID_SHOW="sidebar-toggle-show";
this.ID_HIDE="sidebar-toggle-hide";
this.ID_SIDEBAR="sidebar-td";
this.ID_CONTENT="content-td";
this.STATES=[{id:"hide",title:"Hide side bar",icon:"minimize.gif"},{id:"show",title:"Show side bar",icon:"maximize.gif"}];
this.init=function(){
mb.log.enter(this.GID,"init");
var _ab=mb.cookie.get(this.COOKIE_SIDEBAR);
_ab=(_ab||"1");
this.toggle((_ab=="1"));
mb.log.exit();
};
this.toggle=function(_ac){
mb.log.enter(this.GID,"toggle");
var el;
if((el=mb.ui.get(this.ID_SIDEBAR))!=null){
_ac=(_ac||(el.style.display=="none"));
if(el){
el.style.display=(_ac?"":"none");
el.style.width=(_ac?"140px":"0px");
}
if((el=mb.ui.get(this.ID_CONTENT))!=null){
el.style.width="100%";
}
if((el=mb.ui.get(this.ID_SHOW))!=null){
el.style.display=(_ac?"none":"inline");
}
if((el=mb.ui.get(this.ID_HIDE))!=null){
el.style.display=(_ac?"inline":"none");
}
mb.cookie.set(this.COOKIE_SIDEBAR,(_ac?"1":"0"),365);
}else{
mb.log.error("Did not find el: $",this.ID_SIDEBAR);
}
mb.log.exit();
};
this.getUI=function(){
mb.log.enter(this.GID,"getUI");
var j,state,s=[];
for(j=0;j<this.STATES.length;j++){
state=this.STATES[j];
s.push("<table id=\"sidebar-toggle-");
s.push(state.id);
s.push("\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">");
s.push("<tr><td>");
s.push("<a href=\"javascript:; // Toggle side bar\" ");
s.push("onClick=\"try { mb.sidebar.toggle(null); } ");
s.push("catch (e) { /* fail quietly */ }\" ");
s.push("title=\"");
s.push(state.title);
s.push("\">");
s.push(state.title);
s.push("</a>");
s.push("</td><td>");
s.push("<img src=\"/images/icon/");
s.push(state.icon);
s.push("\" alt=\"\">");
s.push("</td></tr></table>");
}
mb.log.exit();
return s.join("");
};
mb.log.exit();
}
function MbTopMenuTimer(){
mb.log.enter("MbTopMenuTimer","__constructor");
this.CN="MbTopMenuTimer";
this.GID="mb.topmenu.timer";
this.closeTimer=null;
this.openTimer=null;
this.closeFunc="mb.topmenu.hideDisplayedDropDown()";
this.activateTime=150;
this.closeMenuTime=350;
this.closeSubmenuTime=350;
this.stateChangeTimer=[];
this.stateChangeTime=40;
this.clear=function(){
clearTimeout(this.openTimer);
clearTimeout(this.closeTimer);
};
this.activateMenuItem=function(id,_b0){
if(this.stateChangeTimer[id]!=null){
clearTimeout(this.stateChangeTimer[id]);
}
this.clear();
this.openTimer=setTimeout("mb.topmenu.activateMenuItem('"+id+"', "+_b0+");",this.activateTime);
this.stateChangeTimer[id]=setTimeout("mb.topmenu.timer.onStateChange('"+id+"', "+_b0+");",this.stateChangeTime);
};
this.onStateChange=function(id,_b2){
this.stateChangeTimer[id]=null;
mb.topmenu.mouseOver(id,_b2);
};
this.hasEnteredSubMenu=function(){
this.clear();
};
this.hasLeftSubMenu=function(){
clearTimeout(this.closeTimer);
this.closeTimer=setTimeout(this.closeFunc,this.closeSubmenuTime);
};
mb.log.exit();
}
function MbAlbumArtResizer(){
mb.log.enter("MbAlbumArtResizer","__constructor");
this.CN="MbAlbumArtResizer";
this.GID="mb.albumart";
this.unscaleAlbumArt=function(_b3){
mb.log.enter(this.GID,"unscaleAlbumArt");
var w,h;
if(!_b3){
mb.log.error("imgRef is null");
return mb.log.exit();
}
if(!(w=_b3.naturalWidth)||!(h=_b3.naturalHeight)){
return mb.log.exit();
}
var _b5=200,max_h=200;
if(w>_b5||h>max_h){
var _b6=w/_b5,scale_h=h/max_h;
if(_b6>scale_h){
w/=_b6;
h/=_b6;
}else{
w/=scale_h;
h/=scale_h;
}
}
_b3.width=w;
_b3.height=h;
mb.log.info("New size: $x$",w,h);
var obj;
if((obj=_b3.parentNode.nextSibling)!=null){
obj.style.marginRight=""+(w+10)+"px";
}
return mb.log.exit();
};
this.process=function(){
mb.log.enter(this.GID,"process");
var _b8=document.images;
var cnt=0;
for(var i=_b8.length-1;i>=0;i--){
var _bb=_b8[i];
if(_bb.className=="amazon_coverart"&&_bb.complete){
this.unscaleAlbumArt(_bb);
cnt++;
}
}
mb.log.debug("Resized $ images.",cnt);
mb.log.exit();
};
mb.log.exit();
}
var mb=null;
var es=null;
var gc=null;
try{
mb=new MusicBrainz();
}
catch(e){
if(mb.log.error){
mb.log.error("Caught exception: ",e);
mb.log.error(mb.log.getStackTrace());
}else{
alert("Caught exception: "+e);
}
}
function MusicBrainz(){
this.CN="MusicBrainz";
this.GID="mb";
mb=this;
mb.utils=new MbUtils();
mb.cookie=new MbCookie();
mb.log=new MbLog();
mb.ui=new MbUI();
mb.log.scopeStart("Loading the Musicbrainz object");
mb.log.enter("MusicBrainz","__constructor");
mb.onPageLoadedActions=[];
mb.onPageLoadedFlag=false;
mb.onDomReadyActions=[];
mb.onDomReadyFlag=false;
mb.isPageLoading=function(){
return !mb.onPageLoadedFlag;
};
mb.registerPageLoadedAction=function(_bc){
mb.log.enter(mb.GID,"registerPageLoadedAction");
if(_bc instanceof MbEventAction){
mb.onPageLoadedActions.push(_bc);
}else{
mb.log.error("Invalid argument, expected MbEventAction: $",_bc);
}
mb.log.exit();
};
mb.onPageLoaded=function(){
if(mb.onPageLoadedActions.length>0){
mb.log.scopeStart("Executing onPageLoaded functions");
mb.log.enter(mb.GID,"onPageLoaded");
if(!mb.onPageLoadedFlag){
if(!mb.onDomReadyFlag){
mb.runRegisteredFunctions(mb.onDomReadyActions,"onDomReady");
}
mb.onPageLoadedFlag=true;
mb.runRegisteredFunctions(mb.onPageLoadedActions,"onPageLoaded");
}
mb.log.exit();
}
mb.log.scopeEnd();
};
window.onload=mb.onPageLoaded;
mb.registerDOMReadyAction=function(_bd){
mb.log.enter(mb.GID,"registerDOMReadyAction");
if(_bd instanceof MbEventAction){
mb.onDomReadyActions.push(_bd);
}else{
mb.log.error("Invalid argument, expected MbEventAction: $",_bd);
}
mb.log.exit();
};
mb.onDomReady=function(){
if(mb.onDomReadyActions.length>0){
mb.log.scopeStart("Executing onDomReady functions");
mb.log.enter(mb.GID,"onDomReady");
if(!mb.onDomReadyFlag){
mb.onDomReadyFlag=true;
mb.log.enter(mb.GID,"onDomReady");
mb.runRegisteredFunctions(mb.onDomReadyActions,"onDomReady");
mb.log.exit();
}
}
mb.log.exit();
};
mb.runRegisteredFunctions=function(_be){
var i=0,len=_be.length;
if(len>0){
mb.log.trace("Running $ actions...",len);
do{
var _c0=_be[i];
if(_c0 instanceof MbEventAction){
mb.log.info("* $",_c0);
try{
eval(_c0.getCode());
}
catch(e){
mb.log.error("Caught exception: ",e);
mb.log.error(mb.log.getStackTrace());
}
}else{
mb.log.error("Invalid object, expected MbEventAction: $",_c0);
}
}while(len>++i);
}
};
mb.ua=new MbUserAgent();
mb.sidebar=new MbSideBar();
mb.topmenu=new MbTopMenu();
mb.styleabbr=new MbStyleAbbr();
mb.registerDOMReadyAction(new MbEventAction(mb.styleabbr.GID,"process","Correct IE handling of <abbr>"));
mb.registerDOMReadyAction(new MbEventAction(mb.topmenu.GID,"setupEvents","Setup dropdown menu events."));
mb.registerDOMReadyAction(new MbEventAction(mb.ui.GID,"moveFocus","Find ONLOAD|focusfield and set this field to receive keyboard input."));
mb.registerDOMReadyAction(new MbEventAction(mb.ui.GID,"setupPopupLinks","Setup javascript popup links"));
mb.registerDOMReadyAction(new MbEventAction(mb.ui.GID,"setupFeedbackBoxes","Decorate feedback boxes"));
mb.albumart=new MbAlbumArtResizer();
mb.registerPageLoadedAction(new MbEventAction(mb.albumart.GID,"process","Resize amazon coverart"));
mb.log.exit();
}

