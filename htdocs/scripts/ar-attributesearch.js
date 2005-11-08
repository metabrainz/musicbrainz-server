var dds_eventMode = "";
var dds_busy = false;
var dds_theDropdown = null;
var dds_currentIndex = 0;
var dds_currChar = null;
var dds_charsArr = new Array();
var dds_theSubstr = null;
var dds_lastChar = "";
var dds_objTimeout = new Array();
var dds_lastFocusObj = null;
var dds_searchTimeOut = 0;
var dds_searchFindNext = false;
var dds_searchFindNextAsc = true;


// dds_OnLoadHandler()
// -----------------------------------------------------
// setup the eventModel, and register the
// keyHandler method.
function dds_OnLoadHandler(e) {
   dds_eventMode = (e) ? ((e.eventPhase) ? "W3C" : "NN4") : ((window.event) ? "IE" : "unknown");
   if (dds_eventMode == "NN4") document.captureEvents(Event.KEYDOWN); 
   document.onkeydown = dds_handleKeyPressed;
}
window.onload = dds_OnLoadHandler;

// dds_handleKeyPressed()
// -----------------------------------------------------
function dds_handleKeyPressed(e) {
	var event = (dds_eventMode == "IE" ? window.event : e);
	var keyCode = (dds_eventMode == "IE" ? event.keyCode : event.which);
	var theObj = (dds_eventMode == "IE" ? event.srcElement : event.target);
	dds_log("", true); // reset textarea.
	dds_theDropdown = dds_getDropDown(theObj);
	return dds_handleKeyCode(keyCode);
}

// dds_handleKeyPressed()
// -----------------------------------------------------
function dds_handleKeyCode(keyCode, btnClicked) {
	if (btnClicked == null) btnClicked = false;
	var inputFocus = dds_inputHasFocus();
	var selectFocus = dds_selectHasFocus();
	dds_log("dds_handleKeyCode() :: keyCode='"+keyCode+"', focus on='"+(inputFocus?"Input":selectFocus?"Dropdown":"none")+"'");
	if (! (dds_theDropdown == null || dds_theDropdown.options == null || keyCode == null)) {
		dds_currChar = String.fromCharCode(keyCode);
		dds_currChar = (dds_currChar != null ? dds_currChar.toLowerCase() : "");
		dds_searchFindNext = false;
		// window.status = keyCode;
		if (keyCode == 8 || keyCode == 46) { // 46:DELETE, 8:BACKSPACE
			if (dds_charsArr.length > 1) { // pop one element from 
				dds_updateObjTimeout(dds_theDropdown);
				dds_currChar = "";
				dds_currOp = "BACKTRACE";
				dds_charsArr.pop(); // the search string
				dds_theSubstr = dds_charsArr.join("");
				dds_search();
				if (keyCode == 46) dds_updateStats(dds_theDropdown, false, true);
				return true;
			} else {
				dds_theDropdown.selectedIndex = 0;
				dds_updateStats(dds_theDropdown, true); // reset if query = ""
				return true;
			}
		} else if (keyCode == 27) { // ESC=reset substring
			dds_charsArr = new Array(); // and start from scratch
			dds_currChar = "";
			dds_currOp = "RESET";
			dds_theDropdown.selectedIndex = 0;
			dds_updateStats(dds_theDropdown, true);
			dds_log("", true);			
			return false;
		} else if ((btnClicked && keyCode == 39) ||
				   (selectFocus && keyCode == 39) || 
				   (inputFocus && keyCode == 40)) { // 39:ARROW_RIGHT, 40:ARROW_DOWN
			dds_updateObjTimeout(dds_theDropdown);
			dds_currChar = "FINDNEXT";
			dds_searchFindNextAsc = true;
			dds_searchFindNext = true; // dropdown list.
			dds_currentIndex = dds_theDropdown.selectedIndex;
			dds_search();
			return false;
		} else if ((btnClicked && keyCode == 37) ||
				   (selectFocus && keyCode == 37) || 
				   (inputFocus && keyCode == 38)) { // 37:ARROW_LEFT, ARROW_UP:38
			dds_updateObjTimeout(dds_theDropdown);
			dds_currChar = "FINDNEXT";
			dds_searchFindNext = true;
			dds_searchFindNextAsc = false;
			dds_currentIndex = dds_theDropdown.selectedIndex;
			dds_search();
			return false;
		} else if ((("abcdefghijklmnopqrstuvwxyz ").indexOf(dds_currChar) > -1)) {
			dds_checkObjTimeOut(dds_theDropdown);
			dds_charsArr[dds_charsArr.length] = dds_currChar;
			dds_theSubstr = dds_charsArr.join("");
			dds_currOp = "ALPHANUM";
			dds_lastChar = dds_currChar;
			dds_search();
			return inputFocus;
		} else {
			dds_log("dds_handleKeyCode() :: No update required.");
			return true;
		}
	} else {
		dds_log("dds_handleKeyCode() :: No reference to dropdown found.");
		return true;
	}
}

// dds_checkObjTimeOut() 
// -----------------------------------------------------
function dds_checkObjTimeOut(theObj) {
	dds_theDropdown = dds_getDropDown(theObj);
	if (dds_theDropdown != null) {			
		var lastEvent = dds_objTimeout[dds_theDropdown.id];
		var now = new Date().getTime();
		lastEvent = (lastEvent != null ? lastEvent : 0);
		if ((now - lastEvent) > 3000) dds_updateStats(theObj, true);
		dds_log("dds_checkObjTimeOut() :: obj: "+objToString(theObj)+", last event: "+(now-lastEvent)+"[ms]");
		dds_updateObjTimeout(theObj);
	} else dds_log("dds_checkObjTimeOut() :: WARNING: theObj is invalid reference; "+objToString(theObj));
}

// dds_updateObjTimeout() 
// -----------------------------------------------------
function dds_updateObjTimeout(theObj) {
	dds_theDropdown = dds_getDropDown(theObj);
	if (dds_theDropdown != null) {			
		dds_objTimeout[dds_theDropdown.id] = new Date().getTime();
	} else dds_log("dds_updateObjTimeout() :: WARNING: theObj is invalid reference; "+objToString(theObj));
}


// dds_getDropDown() 
// -----------------------------------------------------			
function dds_getDropDown(theObj) {
	if (theObj != null &&  theObj.id != null) {
		var theName = theObj.id;
		var nameSplit = theName.split("_");
		if (nameSplit[0] == "attr" && (nameSplit[1] == "instrument" || nameSplit[1] == "vocal")) {
			var lastSplit = nameSplit[nameSplit.length-1];
			if (lastSplit == "substr" || lastSplit == "findprev" || lastSplit == "findnext" || lastSplit == "remove" ) {
				nameSplit.pop(); // loose last part of id
				var theDropDownId = nameSplit.join("_");
				var theDropDown = document.getElementById(theDropDownId);
				if (theDropDown != null) return theDropDown;
				dds_log("dds_getDropDown() :: WARNING: Could not get reference to DropDown with id="+theDropDownId);
			} else return theObj;
		} else dds_log("dds_getDropDown() :: WARNING: Object is not of the type attr_instrument or attr_vocal");
	} else dds_log("dds_getDropDown() :: WARNING: theObj is invalid reference; "+objToString(theObj));
	return null;
}

// dds_getInputField() 
// -----------------------------------------------------			
function dds_getInputField(theObj) {
	dds_theDropdown = dds_getDropDown(theObj);
	if (dds_theDropdown != null) {			
		var inputElemId = dds_theDropdown.id + "_substr";
		var inputElem = document.getElementById(inputElemId);
		if (inputElem != null) {
			return inputElem;
		} else dds_log("dds_getInputField() :: WARNING: did not find inputElem with id='"+inputElemId+"'");
	} else dds_log("dds_getInputField() :: WARNING: theObj is invalid reference; "+objToString(theObj));
	return null;
}

// dds_inputHasFocus() 
// -----------------------------------------------------	
function dds_inputHasFocus() {				
	var retval = ((dds_lastFocusObj != null) && 
				  (dds_lastFocusObj.id != null) && 
				  (dds_lastFocusObj.id.match(/attr_(instrument|vocal)_\d+_substr/i) != null));
	return retval;
}

// dds_selectHasFocus() 
// -----------------------------------------------------	
function dds_selectHasFocus() {
	var retval = ((dds_lastFocusObj != null) && 
				  (dds_lastFocusObj.id != null) && 
				  (dds_lastFocusObj.id.match(/attr_(instrument|vocal)_\d+/i) != null));
	return retval;
}			

// dds_updateStats() 
// -----------------------------------------------------
// @param flag 	if true, timeout has expired
//                  reset the charsArray
function dds_updateStats(theObj, bReset, bOverride) {
	dds_log("dds_updateStats() :: theObj="+objToString(theObj)+", bReset="+(bReset==true?"true":"false"));
	bReset = (bReset == null ? false : bReset);
	bOverride = (bOverride == null ? false : bOverride);
	if (bReset) {
		dds_theSubstr = "";
		dds_charsArr = new Array();
	}
	dds_updateDisplay(theObj, bReset, bOverride);
	if (bReset) {
		dds_currentIndex = 0;
		dds_theDropdown = null;
	}
}

// dds_updateDisplay() 
// -----------------------------------------------------
// @param flag 	if true, timeout has expired
//                  reset the charsArray	
function dds_updateDisplay(theObj, bReset, bOverride) {
	var inputElem = dds_getInputField(theObj);
	if (inputElem != null) {
		dds_theSubstr = (dds_theSubstr == null ? "" : dds_theSubstr);
		if ((!dds_inputHasFocus() || bOverride) || bReset) inputElem.value = dds_theSubstr;
		dds_log("dds_updateDisplay() :: active: "+dds_inputHasFocus()+"; "+dds_theSubstr);
	} else dds_log("dds_updateDisplay() :: WARNING: theObj is invalid reference; "+objToString(theObj));
}

// dds_onFocus() 
// -----------------------------------------------------
// @param flag 	if true, timeout has expired
//                  reset the charsArray	
function dds_onFocus(theObj) {
	var inputElem = dds_getInputField(theObj);
	if (inputElem != null) {
		dds_lastFocusObj = theObj;
		if (inputElem.value == "Search...") inputElem.value = "";
		dds_theSubstr = (inputElem.value != null ? inputElem.value : "");
		dds_charsArr = dds_theSubstr.split("");
		dds_updateStats(theObj, false); 
		dds_log("dds_onFocus() :: Initialized search string: '"+dds_theSubstr+"', focusObj="+objToString(dds_lastFocusObj));	
	} else dds_log("dds_onFocus() :: WARNING: theObj is invalid reference; theObj="+objToString(theObj)+", inputElem="+objToString(inputElem));
}

// objToString() 
// -----------------------------------------------------
function objToString(theObj) {
	return (theObj == null || theObj.id == null ? "null" : theObj.id);
}

// dds_findPrev() 
// -----------------------------------------------------
function dds_doFindPrev(theObj) {
	dds_log("", true);
	dds_theDropdown = dds_getDropDown(theObj);
	if (dds_theDropdown != null && dds_theDropdown.options != null) {
		dds_handleKeyCode(37, true);
	} else dds_log("dds_doFindPrev() :: WARNING: theObj is invalid reference; "+objToString(theObj));
}

// dds_searchFindNext() 
// -----------------------------------------------------
function dds_doFindNext(theObj) {
	dds_log("", true);				
	dds_theDropdown = dds_getDropDown(theObj);
	if (dds_theDropdown != null && dds_theDropdown.options != null) {
		dds_handleKeyCode(39, true);
	} else dds_log("dds_doFindNext() :: WARNING: theObj is invalid reference; "+objToString(theObj));
}


// dds_search() 
// -----------------------------------------------------
// search theObj.options for an element that
// has theSubstr as a substring and select
// first found occurence, else select index 0
function dds_search(hasWrapped) {
	if (dds_theDropdown == null) {
		dds_log("dds_search() :: ERROR: dds_theDropdown = null");
		return;
	}
	if (dds_theSubstr == null || dds_theSubstr == "") {
		dds_log("dds_search() :: dds_theSubstr is empty/null");
		return;
	}				
	clearTimeout(dds_searchTimeOut);
	if (dds_busy) { // wait until interrupt was detected and busy was reset
		dds_interrupted = true;
		dds_searchTimeOut = setTimeout("dds_search()", 10);
	}
	var foundMatch = false;
	var hasMatched = false;
	var strWords = dds_theSubstr.split(" ");
	var regexStr =  strWords.join("[^ ]* \\b");
	var re = new RegExp("\\b"+regexStr, "i");
	var dds_i_min = 0;
	var dds_i_max  = dds_theDropdown.options.length - 1;
	var dds_i = (dds_searchFindNext ? dds_currentIndex : dds_i_min);
	dds_log("dds_search() :: ("+(hasWrapped?"2nd run":"1st run")+")---------------------------------------------------------------------------");
	dds_log("  Q: '"+dds_theSubstr+"', re='"+re+"'");
	dds_log("  OP: '"+dds_currOp+"', CHAR='"+dds_currChar+"', LAST='"+dds_lastChar+"'");
	dds_log("  findnext="+dds_searchFindNext+" ("+(dds_searchFindNextAsc?"asc":"desc")+"), index="+dds_currentIndex+", value='"+(dds_currentIndex != -1 ? dds_theDropdown.options[dds_currentIndex].text : "")+"'");
	dds_interrupted = false;
	while (!dds_interrupted) {
		if (dds_searchFindNextAsc && dds_i == dds_i_max) break; // if ascending search, stop at maximum
		if (!dds_searchFindNextAsc && dds_i == dds_i_min) break; // if descending search, stop at minimum
		dds_i += (dds_searchFindNextAsc ? 1 : -1); // if ascending search, +1, else +(-1)
		if (!(dds_searchFindNext && dds_i == dds_currentIndex)) {
			var probe = dds_theDropdown.options[dds_i].text;
			var m = re.exec(probe);						
			if (m != null) {
				hasMatched = true;
				if (dds_searchFindNext) {
					if ((dds_searchFindNextAsc && dds_i > dds_currentIndex) || 
						(!dds_searchFindNextAsc && dds_i < dds_currentIndex)) {
						foundMatch = true; // if we are looking for the next occurence of a substring
						break; // and the index is bigger than the previous match, end search successful.
					}
				} else {
					foundMatch = true; // if we are looking for a new string and 
					break; // it matched, end search successful.
				}
			}
		} else hasMatched = true; // if no other entry was matched, remember current entry as the one that has matched.
	}
	dds_log("  dds_interrupted="+dds_interrupted+", hasMatched="+hasMatched+", foundMatch="+foundMatch+", index="+dds_i+"'");
	if (!dds_interrupted) { // if search was not interrupted
		if (foundMatch && dds_i != 0) { // if foundMatch, select index, else 0
			dds_theDropdown.selectedIndex = dds_i;
		} else { // we have not found a valid match.
			if (dds_searchFindNext && !hasWrapped) {
				dds_busy = false; // reset busy flag.
				dds_currentIndex = (dds_searchFindNextAsc ? dds_i_min : dds_i_max);
				dds_log("  => We need to wrap, searching again...");
				dds_searchTimeOut = setTimeout("dds_search(true)", 10);
				return;
			} else dds_theDropdown.selectedIndex = 0;
		}
		dds_currentIndex = dds_theDropdown.selectedIndex;
	}
	dds_busy = false; // reset busy flag.
	dds_updateStats(dds_theDropdown);
}

// dds_log() 
// -----------------------------------------------------
function dds_log(theMsg, bReset) {
	// if (!bReset) document.getElementById("logmessages").value += (theMsg+"\n");
	// else document.getElementById("logmessages").value = theMsg;
}	


// dds_removeAttribute() 
// -----------------------------------------------------
function dds_removeAttribute(theObj) {
	dds_theDropdown = dds_getDropDown(theObj);
	if (dds_theDropdown != null) {		
		var nameSplit = dds_theDropdown.name.split("_");
		var attr = nameSplit[1];
		var index = parseInt(nameSplit[2]);
		if (index < 1) return; // do not remove element '0'
		var elemParent = document.getElementById(attr);
		if (elemParent) {
			var elemItem = document.getElementById(dds_theDropdown.name + "_item");
			if (elemItem ) {
				// remove dropdown, previous button, input field, next button and remove button
				var items = new Array("", "_findprev", "_substr", "_findnext", "_remove"); 
				for (var i=0; i<items.length; i++) {
					var childId = 'attr_' + attr + "_" + index + "" + items[i];
					var elem = document.getElementById(childId);
					if (elem != null) {
						try { elemItem.removeChild(elem);
						} catch (e) { dds_log("dds_removeAttribute() :: WARNING: Could not removing id="+childId+" from "+elemItem.id); }
					} else dds_log("dds_removeAttribute() :: WARNING: Did not find node to delete; "+childId);
					if (items[i] == "_remove" && index > 1) { 
						var elemBtn = document.getElementById("attr_" + attr + "_" + (index-1) + items[i]);
						if (elemBtn) elemBtn.style.display = "inline";
							// hide all remove buttons but the lowest one 
							// (to prevent the removal of a button from the 
							//  middle of the list)				
					}
				}
			}
			try { elemParent.removeChild(elemItem);
			} catch (e) { dds_log("dds_removeAttribute() :: WARNING: Could not remove id="+elemItem.id+" from "+elemParent.id); }
		} else dds_log("dds_removeAttribute() :: WARNING: Did not find parent; "+objToString(theObj));
	} else dds_log("dds_removeAttribute() :: WARNING: theObj is invalid reference; "+objToString(theObj));
}

// dds_addAttribute() 
// -----------------------------------------------------
function dds_addAttribute(attr) {
	var parent = document.getElementById(attr);
	var elements = document.getElementsByName('attr_' + attr + "_0");
	if (elements && parent) {
		var attrElement = elements[0];
		if (attrElement) {
			var index = dds_findAttrIndex(attr);
			if (index == 0) return; // do not add element '0' again
			dds_log("dds_addAttribute() :: Adding new index="+index+" to "+objToString(attrElement));
			// clone dropdown, previous button, input field, next button and remove button
			var items = new Array("", "_findprev", "_substr", "_findnext", "_remove");
			var pId = 'attr_' + attr + "_" + index + "_item";
			var divElem = document.createElement("div");
			divElem .setAttribute("id", pId);
			divElem .className = "ar-attribute-item";
			parent.appendChild(divElem);     
			for (var i=0; i<items.length; i++) {
				var childId = 'attr_' + attr + "_0" + items[i];
				var elem = document.getElementById(childId);
				if (elem != null) {
					var newNodeId = "attr_" + attr + "_" + index + items[i];
					var newNode = elem.cloneNode(true);
					if (newNode != null) {
						newNode.setAttribute("id", newNodeId);
						newNode.setAttribute("name", newNodeId);
						divElem.appendChild(newNode);      
						if (items[i] == "_substr") newNode.value = "Search...";
						if (items[i] == "_remove") { 
							if (index > 1) { 
								// hide remove button of the previous
								// dropdown (to prevent the removal of a button from 
								//  the middle of the list)
								var elemBtn = document.getElementById("attr_" + attr + "_" + (index-1) + items[i]);
								if (elemBtn) elemBtn.style.display = "none";
							}
							newNode.style.display = "inline";
						}
					} else window.status = ("new node with id='"+newNodeId+"' could not be cloned!");
				} else window.status = ("elem with id='"+childId+"' not found!");
			}
		}
	} 
}

// dds_findAttrIndex() 
// -----------------------------------------------------
function dds_findAttrIndex(attr) {
	var elements, index;
	for(index = 1;; index++) {
		elements = document.getElementsByName('attr_' + attr + "_" + index);
		if (elements.length > 0) continue;
		else return index;
	}
}

// dds_writeUI() 
// -----------------------------------------------------
function dds_writeUI(attr, index) {
	document.write('<input type="button" class="ar-attr-button" name="attr_' + attr + '_' + index + '_findprev" ');
	document.write('id="attr_' + attr + '_' + index + '_findprev" value="&laquo;" onClick="dds_doFindPrev(this)" ');
	document.write('title="Find previous ' + attr + ' matching the search string" /><input ');
	document.write('type="text" class="ar-attr-textfield" size="6" name="attr_' + attr + '_' + index + '_substr" ');
	document.write('id="attr_' + attr + '_' + index + '_substr" value="Search..." onFocus="dds_onFocus(this);" ');
	document.write('title="Search for a ' + attr + ' attribute" /><input type="button" class="ar-attr-button" ');
	document.write('name="attr_' + attr + '_' + index + '_findnext" id="attr_' + attr + '_' + index + '_findnext" value="&raquo;" onClick="dds_doFindNext(this)" ');
	document.write('title="Find next ' + attr + ' matching the search string" /><input type="button" class="ar-attr-button" ');
	document.write('name="attr_' + attr + '_' + index + '_remove" id="attr_' + attr + '_' + index + '_remove" value="Remove" onClick="dds_removeAttribute(this)" ');
	document.write('style="display: '+(index == 0 ? 'none' : 'inline') + '" title="Remove this ' + attr + '" /> ');
	if (index == 0) {
		document.write('[ <a href="/popup/dropdownsearchhelp.html" onClick="MyWindow=window.open(\'/popup/dropdownsearchhelp.html\',\'DropdownSearchHelp\',\'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=400,height=275\'); return false;">Help</a> ]');
	}
}