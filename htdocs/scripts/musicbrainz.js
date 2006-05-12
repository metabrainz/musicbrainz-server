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
this.getLevel=function(_14){
this.enter(this.GID,"getLevel");
_14=(_14||true);
var cv=mb.cookie.get(this.COOKIE_LEVEL);
this.setLevel(cv||this.INFO,_14);
this.exit();
};
this.setLevel=function(l,_17){
this.enter(this.GID,"setLevel");
if(l!=this._level){
if(l>=this.TRACE&&l<=this.ERROR){
this._level=l;
if(!_17){
this.info("Changing log level to: $",this.LEVEL_DESC[this._level]);
}
}
}else{
if(!_17){
this.info("No change, level is: $",this.LEVEL_DESC[this._level]);
}
}
this.exit();
};
this.onSetLevelClicked=function(_18){
this.scopeStart("Handling click on loglevel checkbox");
this.enter(this.GID,"onSetLevelClicked");
this.setLevel(_18);
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
this.scopeStart=function(_1b){
var m=this.getMethodFromStack();
if(mb.isPageLoading&&!mb.isPageLoading()){
this._start=new Date().getTime();
}
if(_1b){
var s=[];
s.push("<div class=\"log-scope\">");
s.push(_1b);
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
this.enter=function(_1f,_20){
this._stack.push([_1f,_20]);
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
this.getMethodFromStack=function(_27){
var m=" ";
if(this._stack.length!=0){
_27=(_27||this._stack.length-1);
m=this._stack[_27];
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
var _2f=(new Date().getTime()-this._start);
if(_2f<10){
_2f="  "+_2f;
}else{
if(_2f<100){
_2f=" "+_2f;
}else{
_2f=""+_2f;
}
}
return _2f.replace(/\s/g,"&nbsp;");
};
this.getMessageStartHtml=function(_30){
var s=[];
s.push("<div class=\"log-level-");
switch(_30){
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
s.push(this.LEVEL_DESC[_30]);
s.push(" - ");
return s.join("");
};
this.getMessageEndHtml=function(_32){
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
var _36=arguments[0];
var _37=arguments[1];
var msg="";
if(_37&&(msg=_37[0])!=null){
msg=msg.split(" ").join("&nbsp;");
msg=msg.split(/\n/).join("<br/>");
if(typeof (gc)!="undefined"&&gc!=null&&gc.getCurrentWord){
var cw;
if((cw=gc.getCurrentWord())!=null){
msg=msg.replace("#cw",this.getHighlightHtml(cw));
}
}
if(_37.length>1){
for(var i=1;i<_37.length;i++){
msg=msg.replace(/\$/,this.getHighlightHtml(_37[i]));
}
}
var t=[];
t.push(this.getMessageStartHtml(_36));
if(this.LOG_METHODS){
t.push(this.getMethodFromStack());
t.push(" :: ");
}
t.push(msg);
t.push(this.getMessageEndHtml(_36));
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
function MbDiff(){
this.CN="MbDiff";
this.GID="mb.diff";
mb.log.enter(this.CN,"__constructor");
this.escape=function(s){
mb.log.enter(this.GID,"escape");
var n=(s||"");
n=n.replace(/&/g,"&amp;");
n=n.replace(/</g,"&lt;");
n=n.replace(/>/g,"&gt;");
n=n.replace(/"/g,"&quot;");
mb.log.exit();
return n;
};
this.diffStringInline=function(o,n){
mb.log.enter(this.GID,"diffStringInline");
o=o.replace(/\s+$/,"");
n=n.replace(/\s+$/,"");
var out=this.diff(o==""?[]:o.split(/\s+/),n==""?[]:n.split(/\s+/));
var str="";
var _52=o.match(/\s+/g);
if(_52==null){
_52=["\n"];
}else{
_52.push("\n");
}
var _53=n.match(/\s+/g);
if(_53==null){
_53=["\n"];
}else{
_53.push("\n");
}
var i;
if(out.n.length==0){
for(i=0;i<out.o.length;i++){
str+="<del>"+this.escape(out.o[i])+_52[i]+"</del>";
}
}else{
if(out.n[0].text==null){
for(n=0;n<out.o.length&&out.o[n].text==null;n++){
str+="<del>"+this.escape(out.o[n])+_52[n]+"</del>";
}
}
for(i=0;i<out.n.length;i++){
if(out.n[i].text==null){
str+="<ins>"+this.escape(out.n[i])+_53[i]+"</ins>";
}else{
var pre="";
for(n=out.n[i].row+1;n<out.o.length&&out.o[n].text==null;n++){
pre+="<del>"+this.escape(out.o[n])+_52[n]+"</del>";
}
str+=" "+out.n[i].text+_53[i]+pre;
}
}
}
mb.log.exit();
return str;
};
this.diffStringSeparate=function(o,n){
mb.log.enter(this.GID,"diffStringSeparate");
o=o.replace(/\s+$/,"");
n=n.replace(/\s+$/,"");
var out=this.diff(o==""?[]:o.split(/\s+/),n==""?[]:n.split(/\s+/));
var _59=o.match(/\s+/g);
if(_59==null){
_59=["\n"];
}else{
_59.push("\n");
}
var _5a=n.match(/\s+/g);
if(_5a==null){
_5a=["\n"];
}else{
_5a.push("\n");
}
var os=[];
var i;
for(i=0;i<out.o.length;i++){
if(out.o[i].text!=null){
os.push("<span class=\"text\">");
os.push(out.o[i].text);
os.push("</span>");
os.push(_59[i]);
}else{
os.push("<span class=\"del\">");
os.push(out.o[i]);
os.push("</span>");
os.push(_59[i]);
}
}
var ns=[];
for(i=0;i<out.n.length;i++){
if(out.n[i].text!=null){
ns.push("<span class=\"text\">");
ns.push(out.n[i].text);
ns.push("</span>");
ns.push(_5a[i]);
}else{
ns.push("<span class=\"ins\">");
ns.push(out.n[i]);
ns.push("</span>");
ns.push(_5a[i]);
}
}
mb.log.exit();
return {o:os.join(""),n:ns.join("")};
};
this.diff=function(o,n){
mb.log.enter(this.GID,"diff");
var ns=new Object();
var os=new Object();
var i;
for(i=0;i<n.length;i++){
if(ns[n[i]]==null){
ns[n[i]]={rows:new Array(),o:null};
}
ns[n[i]].rows.push(i);
}
for(i=0;i<o.length;i++){
if(os[o[i]]==null){
os[o[i]]={rows:new Array(),n:null};
}
os[o[i]].rows.push(i);
}
for(i in ns){
if(ns[i].rows.length==1&&typeof (os[i])!="undefined"&&os[i].rows.length==1){
n[ns[i].rows[0]]={text:n[ns[i].rows[0]],row:os[i].rows[0]};
o[os[i].rows[0]]={text:o[os[i].rows[0]],row:ns[i].rows[0]};
}
}
for(i=0;i<n.length-1;i++){
if((n[i].text!=null)&&(n[i+1].text==null)&&(n[i].row+1<o.length)&&(o[n[i].row+1].text==null)&&(n[i+1]==o[n[i].row+1])){
n[i+1]={text:n[i+1],row:n[i].row+1};
o[n[i].row+1]={text:o[n[i].row+1],row:i+1};
}
}
for(i=n.length-1;i>0;i--){
if((n[i].text!=null)&&(n[i-1].text==null)&&(n[i].row>0)&&(o[n[i].row-1].text==null)&&(n[i-1]==o[n[i].row-1])){
n[i-1]={text:n[i-1],row:n[i].row-1};
o[n[i].row-1]={text:o[n[i].row-1],row:i-1};
}
}
mb.log.exit();
return {o:o,n:n};
};
this.runDiff=function(){
mb.log.enter(this.GID,"runDiff");
if(showedit==null||showedit.isDiffEnabled()){
var _63=mb.ui.getByTag("td");
var _64=[];
var i,obj,id,name,ids=[];
for(i=0;i<_63.length;i++){
obj=_63[i];
id=(obj.id||"");
if(id.match(/^(nv\::(album|release|track|edit.*|artist.*)\d+|ov\::(album|release|track|edit.*|artist.*)\d+)/i)){
mb.log.info(id);
var c=id.split("::");
var s=c[0];
id=c[1];
if(!_64[id]){
_64[id]={ov:null,nv:null};
ids.push(id);
}
eval("fields[\""+id+"\"]."+s+" = obj");
}
}
mb.log.info("ids: $",ids);
for(i=0;i<ids.length;i++){
id=ids[i];
if((obj=_64[id])!=null){
if(obj.ov&&obj.nv){
mb.log.info("id: $, ov: $, nv: $",id,obj.ov,obj.nv);
var ov=(obj.ov.innerHTML||"").replace("&nbsp;"," ");
var nv=(obj.nv.innerHTML||"").replace("&nbsp;"," ");
var out=this.diffStringSeparate(ov,nv);
obj.ov.innerHTML=out.o.replace(/not_set/gi,"Not set");
obj.nv.innerHTML=out.n.replace(/not_set/gi,"Not set");
}else{
mb.log.warning("Obj does not define ov: $, nv: $",obj.ov||"",obj.nv||"");
}
}else{
mb.log.warning("No element with id: $ found",id);
}
}
}
mb.log.exit();
};
mb.log.exit();
}
function MbEventAction(_6b,_6c,_6d){
mb.log.enter("MbEventAction","__constructor");
this.CN="MbEventAction";
this.GID="";
var _6e=_6b;
var _6f=_6c;
var _70=_6d;
this.getObject=function(){
return _6e;
};
this.getMethod=function(){
return _6f;
};
this.getDescription=function(){
return _70;
};
this.toString=function(){
var s=[];
s.push(this.CN);
s.push(" [");
s.push(_70);
s.push(", ");
s.push(this.getCode());
s.push("]");
return s.join("");
};
this.getCode=function(){
var s=[];
s.push(_6e);
s.push(".");
s.push(_6f);
s.push("()");
return s.join("");
};
mb.log.exit();
}
function MbUI(){
this.CN="MbUI";
this.GID="mb.ui";
this.SPLITSEQ="::";
this.get=function(id,_74){
mb.log.enter(this.GID,"get");
var el,nn;
if(id){
_74=(_74||document);
if(_74.getElementById){
el=_74.getElementById(id);
nn=(el&&el.nodeName?el.nodeName:"?");
mb.log.trace("Querying element id: $, el: $",id,nn);
}else{
mb.log.error("Element parent $ does not support getElementById!",_74);
}
}else{
mb.log.error("Required parameter $ was null","id");
}
return mb.log.exit(el);
};
this.getByTag=function(tag,_77){
mb.log.enter(this.GID,"getByTag");
var _78=[];
if(tag){
_77=(_77||document);
if(_77.getElementsByTagName){
_78=_77.getElementsByTagName(tag);
mb.log.trace("Querying elements with tag: $, parent: $, length: $",tag,(_77.nodeName||_77),_78.length);
}else{
mb.log.error("Element parent $ does not support getElementsByTagName!",_77);
}
}else{
mb.log.error("Required parameter $ was null","tag");
}
return mb.log.exit(_78);
};
this.getByName=function(_79,_7a){
mb.log.enter(this.GID,"getByName");
var _7b=[];
if(_79){
_7a=(_7a||document);
if(_7a.getElementsByName){
_7b=_7a.getElementsByName(_79);
mb.log.trace("Querying elements with name: $, parent: $, length: $",_79,(_7a.nodeName||_7a),_7b.length);
}else{
mb.log.error("Element parent $ does not support getElementsByName!",_7a);
}
}else{
mb.log.error("Required parameter $ was null","name");
}
return mb.log.exit(_7b);
};
this.setDisplay=function(el,_7d){
mb.log.enter(this.GID,"get");
if(mb.utils.isString(el)){
var obj;
if((obj=this.get(el))==null){
mb.log.error("Could not find element with id: $",el);
}
el=obj;
}
if(el){
el.style.display=(_7d?"":"none");
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
var _87,spans=mb.ui.getByTag("span",div);
var _88,spanText;
for(var j=0;j<spans.length;j++){
_87=spans[j];
id=(_87.id||"");
if(id=="header"){
_88=_87;
}
if(id=="text"){
spanText=_87;
}
}
if(_88&&spanText){
id="feedbackBox"+this.fbBoxCounter;
var a=document.createElement("a");
a.id=id+"|toggle";
a.href="javascript:; // Toggle box";
a.className="readmore";
a.onfocus=function onfocus(_8b){
this.blur();
};
a.onclick=function onclick(){
var obj;
var id=this.id.split(mb.ui.SPLITSEQ)[0];
if((obj=mb.ui.get(id))!=null){
var _8e=(obj.style.display=="none");
this.firstChild.nodeValue=(_8e?"Close":"Read more");
mb.ui.setDisplay(obj,_8e);
}else{
mb.log.warning("Did not find: $",this.id);
}
return false;
};
a.appendChild(document.createTextNode("Read more"));
var _8f=_88.parentNode;
_8f.appendChild(a);
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
var _92=id.split(mb.ui.SPLITSEQ)[1];
var _93=a.href;
if(_93.match(/ispopup/)==null){
if(_93.match(/\&/)!=null){
_93+="&amp;ispopup=1";
}else{
_93+="?ispopup=1";
}
}
a.id=id+mb.ui.SPLITSEQ+_93+mb.ui.SPLITSEQ+i;
a.title=_92;
a.onclick=function(_94){
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
var _9a=id[4];
var win=window.open(_9a,t,"toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width="+w+",height="+h);
}
}
return false;
};
this.setupKeyboardFocus=function(){
mb.log.enter(this.GID,"setupKeyboardFocus");
var el,list=mb.ui.getByTag("input");
var _9d;
if((el=mb.ui.get("ONLOAD::focusfield"))!=null){
if((_9d=el.value)!=null){
var _9e,form=el.form;
for(var i=0;i<list.length;i++){
el=list[i];
name=(el.name||"");
_9e=el.form;
if((_9e==form)&&(name==_9d)&&(el.focus)){
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
function MbAlbumArtResizer(){
mb.log.enter("MbAlbumArtResizer","__constructor");
this.CN="MbAlbumArtResizer";
this.GID="mb.albumart";
this.unscaleAlbumArt=function(_a1){
mb.log.enter(this.GID,"unscaleAlbumArt");
var w,h;
if(!_a1){
mb.log.error("imgRef is null");
return mb.log.exit();
}
if(!(w=_a1.naturalWidth)||!(h=_a1.naturalHeight)){
return mb.log.exit();
}
var _a3=200,max_h=200;
if(w>_a3||h>max_h){
var _a4=w/_a3,scale_h=h/max_h;
if(_a4>scale_h){
w/=_a4;
h/=_a4;
}else{
w/=scale_h;
h/=scale_h;
}
}
_a1.width=w;
_a1.height=h;
mb.log.info("New size: $x$",w,h);
var obj;
if((obj=_a1.parentNode.nextSibling)!=null){
obj.style.marginRight=""+(w+10)+"px";
}
return mb.log.exit();
};
this.setupAmazonCoverart=function(){
mb.log.enter(this.GID,"setupAmazonCoverart");
var _a6=document.images;
var cnt=0;
for(var i=_a6.length-1;i>=0;i--){
var _a9=_a6[i];
if(_a9.className=="amazon_coverart"&&_a9.complete){
this.unscaleAlbumArt(_a9);
cnt++;
}
}
mb.log.debug("Resized $ images.",cnt);
mb.log.exit();
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
var _aa=mb.cookie.get(this.COOKIE_SIDEBAR);
_aa=(_aa||"1");
this.toggle((_aa=="1"));
mb.log.exit();
};
this.toggle=function(_ab){
mb.log.enter(this.GID,"toggle");
var el;
if((el=mb.ui.get(this.ID_SIDEBAR))!=null){
_ab=(_ab||(el.style.display=="none"));
if(el){
el.style.display=(_ab?"":"none");
el.style.width=(_ab?"140px":"0px");
}
if((el=mb.ui.get(this.ID_CONTENT))!=null){
el.style.width="100%";
}
if((el=mb.ui.get(this.ID_SHOW))!=null){
el.style.display=(_ab?"none":"inline");
}
if((el=mb.ui.get(this.ID_HIDE))!=null){
el.style.display=(_ab?"inline":"none");
}
mb.cookie.set(this.COOKIE_SIDEBAR,(_ab?"1":"0"),365);
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
this.init=function(ty,tr,_b0){
if(tr&&tr.match(/mouseover|click/i)){
this.trigger=tr.toLowerCase();
}
if(ty&&ty.match(/both|dropdownonly|staticonly/i)){
this.type=ty.toLowerCase();
}
this.items=_b0;
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
this.activateMenuItem=function(id,_b6){
if(_b6){
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
this.mouseOver=function(id,_b8){
mb.log.enter(this.GID,"mouseOver");
mb.log.trace("id: $, flag: $",id,_b8);
var obj=null;
if((obj=this.h.m[id])!=null){
var cn=obj.className;
if(_b8&&cn.indexOf("hover")==-1){
obj.className=cn+"hover";
}else{
if(!_b8&&cn.indexOf("hover")!=-1){
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
this.hideRelatedModsIframe=function(_be){
var obj=null;
if((obj=mb.ui.get("RelatedModsBox"))!=null){
obj.style.display=(_be?"none":"block");
}
};
this.setupTopMenu=function(){
mb.log.enter(this.GID,"setupTopMenu");
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
obj.onmouseover=function(_c2){
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
obj.onmouseout=function(_c3){
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
obj.onclick=function(_c4){
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
obj.onfocus=function(_c5){
this.blur();
};
obj.onmouseover=function(_c6){
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
obj.onmouseout=function(_c7){
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
obj.onclick=function(_c8){
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
var _c9=this.OFFSET_LEFT+mOffsetLeft;
obj.style.left=""+_c9+"px";
this.h.sm[mName]=obj;
obj.onmouseover=function(_ca){
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
obj.onmouseout=function(_cb){
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
this.writeUI=function(_cc){
var s=[];
s.push("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\"><tr>");
for(var i=0;i<this.items.length;i++){
var _cf=this.items[i][0];
var url=this.items[i][1];
var _d1=this.items[i][2];
this.h.ml[_cf]=url;
var cn=(_cc==_cf?"selected":"");
cn=(cn!=""?"class=\""+cn+"\"":"");
s.push("<td nowrap "+cn);
s.push("id=\""+_cf+".mouseover\" ");
s.push("><a ");
s.push("title=\""+_d1+"\" ");
s.push("href=\""+url+"\">"+_d1+"</a>");
if(this.allowClickTrigger()){
s.push("<a ");
s.push("id=\""+_cf+".click\" ");
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
this.activateMenuItem=function(id,_d4){
if(this.stateChangeTimer[id]!=null){
clearTimeout(this.stateChangeTimer[id]);
}
this.clear();
this.openTimer=setTimeout("mb.topmenu.activateMenuItem('"+id+"', "+_d4+");",this.activateTime);
this.stateChangeTimer[id]=setTimeout("mb.topmenu.timer.onStateChange('"+id+"', "+_d4+");",this.stateChangeTime);
};
this.onStateChange=function(id,_d6){
this.stateChangeTimer[id]=null;
mb.topmenu.mouseOver(id,_d6);
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
mb.registerPageLoadedAction=function(_d7){
mb.log.enter(mb.GID,"registerPageLoadedAction");
if(_d7 instanceof MbEventAction){
mb.onPageLoadedActions.push(_d7);
}else{
mb.log.error("Invalid argument, expected MbEventAction: $",_d7);
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
mb.registerDOMReadyAction=function(_d8){
mb.log.enter(mb.GID,"registerDOMReadyAction");
if(_d8 instanceof MbEventAction){
mb.onDomReadyActions.push(_d8);
}else{
mb.log.error("Invalid argument, expected MbEventAction: $",_d8);
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
mb.runRegisteredFunctions=function(_d9){
var i=0,len=_d9.length;
if(len>0){
mb.log.trace("Running $ actions...",len);
do{
var _db=_d9[i];
if(_db instanceof MbEventAction){
mb.log.info("* $",_db);
try{
eval(_db.getCode());
}
catch(e){
mb.log.error("Caught exception: ",e);
mb.log.error(mb.log.getStackTrace());
}
}else{
mb.log.error("Invalid object, expected MbEventAction: $",_db);
}
}while(len>++i);
}
};
mb.ua=new MbUserAgent();
mb.sidebar=new MbSideBar();
mb.topmenu=new MbTopMenu();
mb.albumart=new MbAlbumArtResizer();
mb.diff=new MbDiff();
mb.registerDOMReadyAction(new MbEventAction(mb.topmenu.GID,"setupTopMenu","Setting up topmenu events."));
mb.registerDOMReadyAction(new MbEventAction(mb.ui.GID,"setupKeyboardFocus","Setting up focussed field for keyboard input."));
mb.registerDOMReadyAction(new MbEventAction(mb.ui.GID,"setupPopupLinks","Setting up popup links"));
mb.registerDOMReadyAction(new MbEventAction(mb.ui.GID,"setupFeedbackBoxes","Setting up feedback boxes"));
mb.registerPageLoadedAction(new MbEventAction(mb.albumart.GID,"setupAmazonCoverart","Resize amazon coverart"));
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

