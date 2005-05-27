var AF_MODE_AUTOFIX = 'autofix';
var AF_MODE_SENTENCECAPS = 'ucfirst';
var af_mode = AF_MODE_AUTOFIX;

var af_modeDescription = new Array();
af_modeDescription[AF_MODE_AUTOFIX] = 'Standard Guess Case mode, according to <a target="_blank" href="http://www.musicbrainz.org/style.html">Style Guidelines</a>';
af_modeDescription[AF_MODE_SENTENCECAPS] = 'First word uppercase, rest lowercase for non-English languages. <br/>Read the capitalization guides here: <a target="_blank" href="http://wiki.musicbrainz.org/wiki.pl?CapitalizationStandard">CapitalizationStandard</a>';

var AF_OP_UPPERCASE = 'uppercase';
var AF_OP_LOWERCASE = 'lowercase';
var AF_OP_TITLED = 'titled';
var AF_OP_ROUNDBRACKETS = 'roundbrackets';
var AF_OP_SQUAREBRACKETS = 'squarebrackets';
var AF_OP_REMOVEBRACKETS = 'removebrackets';
var AF_OP_CONVERTROUNDSQUARE = 'convertroundsquare';
var AF_OP_CONVERTSQUAREROUND = 'convertsquareround';



var AF_COOKIE_MODE = "afmode";
var AF_COOKIE_TABLE = "aftable";

var af_undoStack = new Array();
var af_undoIndex = 0;
var af_onFocusFieldState = new Array(null, null);
var af_onFocusField = null;
var AF_UNDOLIST = "list";


// ***********************************************************************
// handler functions for all the different kind of
// and permutation of fields.
//   * artist
//   * album
//   * artist, track
//   * artist, sortname
// ***********************************************************************

// ----------------------------------------------------------------------------
// doArtistName()
// -- Apply fix to the Artist Name field with name=theID
function doArtistName(theForm, theID) {
	if (theID == null) theID = 'artist';
	var theField = af_getField(theForm, theID);
	var oldvalue = theField.value;
	var newvalue = af_artistNameFix(oldvalue);
	if (newvalue != oldvalue) {
		theField.value = newvalue;
		af_addUndo(theForm,
				   new Array(theField, af_mode, oldvalue, newvalue)
				   );
	}
	af_resetSelection();
}

// ----------------------------------------------------------------------------
// doAlbumName()
// -- Apply fix to the Album Name field with name=theID
function doAlbumName(theForm, theID) {
	if (theID == null) theID = 'album';
	var theField = af_getField(theForm, theID);
	var oldvalue = theField.value;
	var newvalue = af_albumNameFix(theField.value);
	if (newvalue != oldvalue) {
		theField.value = newvalue;
		af_addUndo(theForm,
				   new Array(theField, af_mode, oldvalue, newvalue)
				  );
	}
	af_resetSelection();
}

// ----------------------------------------------------------------------------
// doTrackName()
// -- Apply fix to the Track Name field with name=theID
function doTrackName(theForm, theID) {
	var theField = af_getField(theForm, theID);
	var oldvalue = theField.value;
	var newvalue = af_trackNameFix(theField.value);
	if (newvalue != oldvalue) {
		theField.value = newvalue;
		af_addUndo(theForm,
				   new Array(theField, af_mode, oldvalue, newvalue)
				   );
	}
	af_resetSelection();
}

// ----------------------------------------------------------------------------
// doSortNameCopy()
// -- Copy value from the artist field to the sortname field
function doSortNameCopy(theForm, theArtistID, theSortID) {
	var theArtistField = af_getField(theForm, theArtistID);
	var theSortnameField = af_getField(theForm, theSortID);
	var oldvalue = theSortnameField.value;
	var newvalue = theArtistField.value;
	if (newvalue != oldvalue) {
		theSortnameField.value = newvalue;
		af_addUndo(theForm,
				   new Array(theSortnameField, 'sortnamecopy', oldvalue, newvalue)
				   );
	}
	af_resetSelection();
}

// ----------------------------------------------------------------------------
// doSortNameGuess()
//  -- Guess artist sortname using the artistNameGuessSortName routine in autofix.js
function doSortNameGuess(theForm, theArtistID, theSortID) {
	var theArtistField = af_getField(theForm, theArtistID);
	var theSortnameField = af_getField(theForm, theSortID);
	var artistValue = theArtistField.value;
	var newvalue = theSortnameField.value; var oldvalue = theSortnameField.value;
	newvalue = artistNameGuessSortName(artistValue);
	if (newvalue != oldvalue) {
		theSortnameField.value = newvalue;
		af_addUndo(theForm,
				   new Array(theSortnameField, 'sortname', oldvalue, newvalue)
				   );
	}
	af_resetSelection();
}

// ----------------------------------------------------------------------------
// doSwapFields()
// -- Swap artist name and track name fields
function doSwapFields(theForm) {
	if (theForm != null) {
		if (theForm.search && theForm.trackname && theForm.swapped) {
			var newSwapped = 1 - theForm.swapped.value; // hidden var which holds if fields were swapped
			var switchTempVar = theForm.search.value; // remember field for swap operation
			af_addUndo(theForm,
					   new Array(AF_UNDOLIST,
						   new Array(theForm.trackname, 'swap', theForm.trackname.value, theForm.search.value),
						   new Array(theForm.search, 'swap', theForm.search.value, theForm.trackname.value),
						   new Array(theForm.swapped, 'swap', theForm.swapped.value, newSwapped)
					   ));
			theForm.search.value = theForm.trackname.value;
			theForm.trackname.value = switchTempVar;
			theForm.swapped.value = newSwapped;
		}
	}
}

// ----------------------------------------------------------------------------
// doUseCurrent()
// -- Use the initial value (reset)
function doUseCurrent(theForm) {
	if (theForm != null) {
		if (theForm.search != null && theForm.orig_artname != null &&
			theForm.trackname != null && theForm.orig_track != null) {
			af_addUndo(theForm,
					   new Array(AF_UNDOLIST,
					       new Array(theForm.trackname, 'usecurrent', theForm.trackname.value, theForm.orig_track.value),
					       new Array(theForm.search, 'usecurrent', theForm.search.value, theForm.orig_artname.value)
					   ));
			theForm.trackname.value = theForm.orig_track.value;
			theForm.search.value = theForm.orig_artname.value;
		}
	}
}

// ----------------------------------------------------------------------------
// doUseSplit()
// -- Use the split that was guessed on the server side
function doUseSplit(theForm) {
	if (theForm != null) {
		if (theForm.split_artname != null &&
			theForm.split_track != null) {
			af_addUndo(theForm,
					   new Array(AF_UNDOLIST,
					       new Array(theForm.trackname, 'usesplit', theForm.trackname.value, theForm.split_track.value),
					       new Array(theForm.search, 'usesplit', theForm.search.value, theForm.split_artname.value)
					   ));
			theForm.search.value = theForm.split_artname.value;
			theForm.trackname.value= theForm.split_track.value;
		}
	}
}

// ----------------------------------------------------------------------------
// doArtistAndTrackName()
//  -- Guess artist and trackname first, and try to identify
//     common freedb mistakes and fix them
var changeTrackWarningString = "";
function doArtistAndTrackName(theForm) {
	var tnOldValue = theForm.trackname.value;
	var snOldValue = theForm.search.value;
	var tnValue = tnOldValue;
	var snValue = snOldValue;
	if (tnValue.match(/\sfeat/i) && snValue.match(/\smix/i)) {
		if (changeTrackWarningString != tnValue+"|"+snValue) {
			alert("Please swap artist / trackname fields. they are most likely wrong.");
			changeTrackWarningString = tnValue+"|"+snValue;
			return;
		}
	}
	var tnValueFixed = af_trackNameFix(tnValue);
	var snValueFixed = af_artistNameFix(snValue );
	var featIndex = -1;
	var haystack = snValue.toLowerCase();
	// match ft, featuring feat if not last word of searchname.
	featIndex = (snValue.match(/\s\(feat[\.]?[^$]?/i) ? haystack.indexOf("(feat") : featIndex);
	featIndex = (snValue.match(/\sFeat[\.]?[^$]?/i) ? haystack.indexOf("feat") : featIndex);
	featIndex = (snValue.match(/\sFt[\.]?[^$]/i) ? haystack.indexOf("ft") : featIndex);
	featIndex = (snValue.match(/\sFeaturing[^$]/i) ? haystack.indexOf("featuring") : featIndex);
	if (featIndex != -1) {
		var addParens = (snValue.charAt(featIndex) != "(");
		tnValue = tnValue + (addParens ? " (" : "") +
				  snValue.substring(featIndex, snValue.length) +
				  (addParens ? ")" : "");
		snValue = snValue.substring(0, featIndex);
		tnValueFixed = af_trackNameFix(tnValue);
		snValueFixed = af_artistNameFix(snValue);
	}
	theForm.trackname.value = tnValueFixed;
	theForm.search.value = snValueFixed;
	var tnChanged = (tnValueFixed != tnOldValue);
	var snChanged = (snValueFixed != snOldValue);
	var tnUndo = new Array(theForm.trackname, 'guessboth', tnOldValue, tnValueFixed);
	var snUndo = new Array(theForm.search, 'guessboth', snOldValue, snValueFixed);
	if (tnChanged && snChanged) { // Artist Name and Track Name have changed
		af_addUndo(theForm, new Array(AF_UNDOLIST, tnUndo, snUndo));
	} else if (tnChanged) { // Track Name has changed
		af_addUndo(theForm, tnUndo);
	} else if (snChanged) { // Artist Name has changed
		af_addUndo(theForm, snUndo);
	}
}






// ***********************************************************************
// autofix helper functions
// -- should not be called outside of this script
// ***********************************************************************


// ----------------------------------------------------------------------------
// af_artistNameFix()
// -- Atomic operation, which take the value and applies
//    the current selected autofix operation
// 	  af_mode is ignored, because artistname is not sentence capsed
function af_artistNameFix(theValue) {
	return artistNameFix(theValue);
}

// ----------------------------------------------------------------------------
// af_albumNameFix()
// -- Atomic operation, which take the value and applies
//    the current selected autofix operation
function af_albumNameFix(theValue) {
	if (af_mode == AF_MODE_AUTOFIX) return albumNameFix(theValue);
	else if (af_mode == AF_MODE_SENTENCECAPS) return af_upperCaseFirst(theValue);
}

// ----------------------------------------------------------------------------
// af_trackNameFix()
// -- Atomic operation, which take the value and applies
//    the current selected autofix operation
function af_trackNameFix(theValue) {
	if (af_mode == AF_MODE_AUTOFIX) return trackNameFix(theValue);
	else if (af_mode == AF_MODE_SENTENCECAPS) return af_upperCaseFirst(theValue);
}

// ----------------------------------------------------------------------------
// af_upperCaseFirst()
// -- Uppercases the first character, rest lowercase
function af_upperCaseFirst(theValue) {
	var input_string = trim(theValue.toLowerCase());
	var chars = input_string.split("");
	chars[0] = chars[0].toUpperCase();
	return chars.join("");
}

// ----------------------------------------------------------------------------
// af_getField()
// --
function af_getField(theForm, theID) {
	return theForm[theID];
}

// ----------------------------------------------------------------------------
// af_addUndo()
// -- Track back one step in the changelog
function af_addUndo(theForm, undoOp) {
	af_undoStack = af_undoStack.slice(0, af_undoIndex); 
	af_undoStack.push(undoOp);
	af_undoIndex = af_undoStack.length;
	af_setUndoRedoState(theForm);
}

// ----------------------------------------------------------------------------
// af_doUndo()
// -- Track back one step in the changelog
function af_doUndo(theForm) {
	if (af_undoStack.length > 0) {
		if (af_undoIndex > 0) {
			af_undoIndex--;
			if (af_undoStack[af_undoIndex][0] == AF_UNDOLIST) {
				var list = af_undoStack[af_undoIndex];
				for (var i=1; i<list.length; i++) // undo list of changes
					list[i][0].value = list[i][2]; // set field = oldvalue
			} else {
				af_undoStack[af_undoIndex][0].value = af_undoStack[af_undoIndex][2]; // undo single change
			}
		}
		af_setUndoRedoState(theForm);
	}
	af_resetSelection();
}

// ----------------------------------------------------------------------------
// af_doRedo()
// -- Re-apply one step which was undone previously
function af_doRedo(theForm) {
	if (af_undoIndex < af_undoStack.length) {
		if (af_undoStack[af_undoIndex][0] == AF_UNDOLIST) {
			var list = af_undoStack[af_undoIndex];
			for (var i=1; i<list.length; i++) // re-apply list of changes
				list[i][0].value = list[i][3]; // set field = newvalue
		} else {
			af_undoStack[af_undoIndex][0].value = af_undoStack[af_undoIndex][3]; // undo single change
		}
		af_undoIndex++;
		af_setUndoRedoState(theForm);
	}
	af_resetSelection();
}

// ----------------------------------------------------------------------------
// af_undoAll()
// -- Track back one step in the changelog
function af_undoAll(theForm) {
	if (af_undoStack.length > 0)
		while(af_undoIndex > 0) af_doUndo(theForm);
}

// ----------------------------------------------------------------------------
// af_doRedoAll()
// -- Re-apply one step which was undone previously
function af_doRedoAll(theForm) {
	while (af_undoIndex < af_undoStack.length) af_doRedo(theForm);
}

// ----------------------------------------------------------------------------
// af_setUndoRedoState()
// -- Set the state of the buttons and display
//    where in the changelog the pointer is.
function af_setUndoRedoState(theForm) {
	var flag = (af_undoIndex == 0);
	af_setButtonState(theForm.undoButton, (af_undoIndex == 0));
	af_setButtonState(theForm.redoButton, (af_undoIndex == af_undoStack.length));
	af_setButtonState(theForm.undoAllButton, (af_undoIndex == 0));
	af_setButtonState(theForm.redoAllButton, (af_undoIndex == af_undoStack.length));
	document.getElementById("autofix-text").innerHTML = af_undoIndex+"/"+af_undoStack.length;
}

// ----------------------------------------------------------------------------
// af_setUndoRedoState()
// -- Set css class to disabled/enabeled and disabled attribute as well
function af_setButtonState(theButton, isDisabled) {
	theButton.disabled = isDisabled; 
	theButton.className = "button"+(isDisabled? "disabled" : "");
}

// ----------------------------------------------------------------------------
// myOnFocus()
// -- remembers the current field the user clicked into
//    and the value when editing started
function myOnFocus(theField) {
	if (af_onFocusField != null && af_onFocusField.className == "textfieldfocus") {
		af_onFocusField.className = "textfield";
	}
	af_onFocusField = theField;
	if (theField.className != "textfieldfocus") theField.className = "textfieldfocus";
	af_onFocusFieldState = new Array(theField, theField.value);
}

// ----------------------------------------------------------------------------
// myOnBlur()
// -- checks if its the same field the user started
//    editing and checks for changes. if the value
//    was changed the edit is saved into the changelog.
function myOnBlur(theField) {
	var newvalue = theField.value;
	var oldvalue = af_onFocusFieldState[1];
	if (af_onFocusFieldState[0] == theField && oldvalue != theField.value) {
		af_addUndo(theField.form, 
		           new Array(theField, 'manual', oldvalue, newvalue)
		           );
	}
}

// ----------------------------------------------------------------------------
// af_modeChanged()
// -- set the autofixmode to theMode
function af_modeChanged(theSelect) {
	af_mode = theSelect.options[theSelect.selectedIndex].value;
	af_modeSet();
	setCookie(AF_COOKIE_MODE, af_mode);
	// alert(getCookie(AF_COOKIE_MODE));
}

// ----------------------------------------------------------------------------
// af_modeSet()
// -- set the text explaining the current mode, once for the expanded and
//    for the collapsed af_mode
function af_modeSet() {
	document.getElementById("autofix-mode-text-collapsed").innerHTML = af_modeDescription[af_mode];
	document.getElementById("autofix-mode-text-expanded").innerHTML = af_modeDescription[af_mode];
}

// ----------------------------------------------------------------------------
// af_ShowTable()
// -- toggle display of the autofix table
function af_ShowTable(theFlag) {
	document.getElementById("autofix-table-collapsed").style.display = (!theFlag ? "block" : "none");
	document.getElementById("autofix-table-expanded").style.display = (theFlag ? "block" : "none");
	setCookie(AF_COOKIE_TABLE, (theFlag ? "1" : "0"));
}

// ----------------------------------------------------------------------------
// af_resetSelection()
// -- resets the selection on the field currently
//    having an active selection
function af_resetSelection() {
	if(typeof document.selection != 'undefined') { // ie support
		try {
			document.selection.empty();
		} catch (e) {}
	} else if (af_onFocusField != null &&
			  typeof af_onFocusField.selectionStart != 'undefined') { // mozilla, and other gecko-based browsers.
		try {
			af_onFocusField.selectionStart = 0; // set cursor at pos 0
			af_onFocusField.selectionEnd = 0;
		} catch (e) {}
	}
}

// ----------------------------------------------------------------------------
// doFormatText()
// -- returns the text formatted depending
//    on the op parameter
function doFormatText(fText, op) {
	if (op == AF_OP_UPPERCASE) fText = fText.toUpperCase();
	if (op == AF_OP_LOWERCASE) fText = fText.toLowerCase();
	if (op == AF_OP_TITLED) {
		fText = fText.toLowerCase();
		var tArr = fText.split("");
		tArr[0] = tArr[0].toUpperCase();
		fText = tArr.join("");
	}
	return fText;
}

// ----------------------------------------------------------------------------
// doRemoveBrackets()
// -- remove all the brackets from a string
function doRemoveBrackets(fText) {
	fText = fText.split("(").join("");
	fText = fText.split(")").join("");
	fText = fText.split("[").join("");
	fText = fText.split("]").join("");
	return fText;
}

// ----------------------------------------------------------------------------
// doReplaceBrackets()
// -- remove all the brackets from a string
function doReplaceBrackets(fText, op) {
	if (op == AF_OP_CONVERTROUNDSQUARE) {
		fText = fText.split("(").join("[");
		fText = fText.split(")").join("]");
	} else if (op == AF_OP_CONVERTSQUAREROUND ) {
		fText = fText.split("[").join("(");
		fText = fText.split("]").join(")");
	}
	return fText;
}

// ----------------------------------------------------------------------------
// doApplyOperation()
// -- applies the current operation to the selected text
//    in the field the cursor was last placed in.
// -- djce suggested, that the method should work on the full text of the
// 	  field the cursor is currently placed in if nothing is selected
// -- adapted code from: http://www.quirksmode.org/js/selected.html
// 	  http://www.scriptygoddess.com/archives/2004/06/08/mozilla-and-ie-decoder
// -- IE document.selection object API: http://www.html-world.de/program/js_o_sel.php
function doApplyOperation(op) {
	if (af_onFocusField != null) {
		var oldvalue = af_onFocusField.value;
		var formattedText = ""; var fText = "";
		if(typeof document.selection != 'undefined') { // ie support
			try {
				var fRange = document.selection.createRange();
				fText = fRange.text;
				if (fText == '') fText = af_onFocusField.value;
				formattedText = fText;
				switch (op) {
					case AF_OP_UPPERCASE:
					case AF_OP_LOWERCASE:
					case AF_OP_TITLED:				formattedText = doFormatText(fText, op); break;
					case AF_OP_ROUNDBRACKETS:		formattedText = "("+fText+")"; break;
					case AF_OP_SQUAREBRACKETS:		formattedText = "["+fText+"]"; break;
					case AF_OP_REMOVEBRACKETS:		formattedText = doRemoveBrackets(fText); break;
					case AF_OP_CONVERTROUNDSQUARE:	
					case AF_OP_CONVERTSQUAREROUND:	formattedText = doReplaceBrackets(fText, op); break;
				}
				if (fText == af_onFocusField.value) af_onFocusField.value = formattedText;
				else fRange.text = formattedText;
			} catch (e) {}

		} else if ( af_onFocusField != null &&
					typeof af_onFocusField.selectionStart != 'undefined') { // MOZILLA/NETSCAPE support
			af_onFocusField.focus();
			var fFullText = af_onFocusField.value;
			var sPos = af_onFocusField.selectionStart;
			var ePos = af_onFocusField.selectionEnd;
			fText = (sPos == ePos ? fFullText : fFullText.substring(sPos, ePos));
			formattedText = fText;
			switch (op) {
				case AF_OP_UPPERCASE:
				case AF_OP_LOWERCASE:
				case AF_OP_TITLED:				formattedText = doFormatText(fText, op); break;
				case AF_OP_ROUNDBRACKETS:		formattedText = "("+fText+")"; break;
				case AF_OP_SQUAREBRACKETS:		formattedText = "["+fText+"]"; break;
				case AF_OP_REMOVEBRACKETS:		formattedText = doRemoveBrackets(fText); break;
				case AF_OP_CONVERTROUNDSQUARE:	
				case AF_OP_CONVERTSQUAREROUND:	formattedText = doReplaceBrackets(fText, op); break;
			}
			if (sPos == ePos) af_onFocusField.value = formattedText;
			else af_onFocusField.value = fFullText.substring(0, sPos) + formattedText + fFullText.substring(ePos, fFullText.length);
			af_onFocusField.selectionStart = sPos;
			af_onFocusField.selectionEnd = ePos;
		}
		var newvalue = af_onFocusField.value;
		if (newvalue != oldvalue) {
			af_addUndo(af_onFocusField.form, 
					   new Array(af_onFocusField, 'changecase', oldvalue, newvalue)
					   );
			af_onFocusFieldState[1] = af_onFocusFieldState[0].value; // updated remembered value (such that leaving the field does not add another UNDO step)
		}
	}
}

// ----------------------------------------------------------------------------
// setCookie()
// -- Sets a Cookie with the given name and value.
// @param 		name       	Name of the cookie
// @param 		value      	Value of the cookie
// @param 		[expires]  	Expiration date of the cookie (default: end of current session)
// @param 		[path]     	Path where the cookie is valid (default: path of calling document)
// @param 		[domain]   	Domain where the cookie is valid
//            				(default: domain of calling document)
// @param 		[secure]   	Boolean value indicating if the cookie
//							transmission requires a	secure transmission
function setCookie(name, value, expires, path, domain, secure) {
	document.cookie= name + "=" + escape(value) +
		((expires) ? "; expires=" + expires.toGMTString() : "") +
		((path) ? "; path=" + path : "") +
		((domain) ? "; domain=" + domain : "") +
		((secure) ? "; secure" : "");
}

// ----------------------------------------------------------------------------
// getCookie()
// -- Gets the value of the specified cookie.
// @param 		name  		Name of the desired cookie.
// @returns 				a string containing value of specified cookie,
// 							or null if cookie does not exist.
function getCookie(name) {
	var dc = document.cookie;
	var prefix = name + "=";
	var begin = dc.indexOf("; " + prefix);
	if (begin == -1) {
		begin = dc.indexOf(prefix);
		if (begin != 0) return null;
	} else begin += 2;
	var end = document.cookie.indexOf(";", begin);
	if (end == -1) end = dc.length;
	return unescape(dc.substring(begin + prefix.length, end));
}

// ----------------------------------------------------------------------------
// deleteCookie()
// -- Deletes the specified cookie.
// @param 		name      	name of the cookie
// @param 		[path]    	path of the cookie (must be same as path
//							used to create cookie)
// @param 		[domain]  	domain of the cookie (must be same as domain
// 							used to create cookie)
function deleteCookie(name, path, domain) {
	if (getCookie(name)) {
		document.cookie = name + "=" +
			((path) ? "; path=" + path : "") +
			((domain) ? "; domain=" + domain : "") +
			"; expires=Thu, 01-Jan-70 00:00:01 GMT";
	}
}

// ----------------------------------------------------------------------------
// af_onPageLoad()
// -- function is called when the page loads and
//    sets the autofix table visible, table mode, autofix
//    mode etc. to the remembered value.
function af_onPageLoad() {
	document.getElementById("autofix-box-jsdiabled").style.display = "none"; // toggle the JS enabled/disabled box.
	document.getElementById("autofix-box-jsenabled").style.display = "block";
	var cMode = getCookie(AF_COOKIE_MODE); // get autofix mode from cookie.
	if (cMode) af_mode = cMode;
	var cellObj = document.getElementById("autofix-mode-cell");
	var content = '<table cellspacing="0" cellpadding="0" border="0" width="100%">';
	content += '<tr valign="middle">';
	content += '<td>';
	content += '<select name="autofix-mode" onchange="af_modeChanged(this)">';
	content += '<option value="' + AF_MODE_AUTOFIX + '" ' + (af_mode == AF_MODE_AUTOFIX ? 'selected' : '') + '>Title Capitalization</option>';
	content += '<option value="' + AF_MODE_SENTENCECAPS + '" ' + (af_mode == AF_MODE_SENTENCECAPS ? 'selected' : '') + '>Sentence Capitalization</option>';
	content += '</select>';
	content += '</td>';
	content += '<td>&nbsp;</td>';
	content += '<td width="100%">';
	content += '<small><span id="autofix-mode-text-expanded"></span></small>';
	content += '</td>';
	content += '</tr>';
	content += '</table>';
	cellObj.innerHTML = content; // add the drop-down box the the table
	af_modeSet(); // update description texts.
	var cTable = getCookie(AF_COOKIE_TABLE); // restore previous expand/collapsed state from cookie.
	if (cTable) { af_ShowTable(cTable == "1"); }
}


var AF_BTN_ALIAS = "alias";
var AF_BTN_ARTIST = "artist";
var AF_BTN_SORTGUESS = "sortguess";
var AF_BTN_SORTCOPY = "sortcopy";
var AF_BTN_ALBUM = "album";
var AF_BTN_TRACK = "track";
var AF_BTN_ALL = "all";
var AF_BTN_USESWAP  = "useswap";
var AF_BTN_USESPLIT = "usesplit";
var AF_BTN_USECURRENT  = "usecurrent";
var AF_BTN_GUESSBOTH = "guessboth";
var AF_BTNTEXT_NONALBUMTRACKS = 'Guess All Track Names according to Guess Case settings';
var AF_BTNTEXT_ALBUMANDTRACKS = 'Guess Album Name and Track Names according to Guess Case settings';
var AF_BTNTEXT_ALBUMARTISTSORTNAMEANDTRACKS = 'Guess Album Name, Artist Names, Artist Sortnames and Track Names according to Guess Case settings';

// ----------------------------------------------------------------------------
// af_writeButton()
// -- write a guess case button to the document.
function af_writeButton(theType, theID, theID2) {
	var theTitle = '';
	var theFunction = '';
	var theButtonText = 'Guess Case';
	switch (theType) {
		case AF_BTN_ALIAS:
			theTitle = "Guess Artist Alias according to MusicBrainz Artist Name Guidelines";
			theFunction = 'doArtistName(this.form, \''+theID+'\')';
			break;
		case AF_BTN_ARTIST:
			theTitle = "Guess Artist Name according to MusicBrainz Artist Name Guidelines";
			theFunction = 'doArtistName(this.form, \''+theID+'\')';
			break;
		case AF_BTN_SORTGUESS:
			theButtonText = "Guess";
			theTitle = "Guess Sort Name from Artist Name field";
			theFunction = 'doSortNameGuess(this.form, \''+theID+'\', \''+theID2+'\')';
			break;
		case AF_BTN_SORTCOPY:
			theButtonText = "Copy";
			theTitle = "Copy Sort Name from Artist Name field";
			theFunction = 'doSortNameCopy(this.form, \''+theID+'\', \''+theID2+'\')';
			break;
		case AF_BTN_ALBUM:
			theTitle = "Guess Album Name according to Guess Case settings";
			theFunction = 'doAlbumName(this.form, \''+theID+'\')';
			break;
		case AF_BTN_TRACK:
			theTitle = "Guess Track Name according to Guess Case settings";
			theFunction = 'doTrackName(this.form, \''+theID+'\')';
			break;
		case AF_BTN_ALL:
			theTitle = theID;
			theButtonText = 'Guess All';
			theFunction = 'doGuessAll(this.form)';
			break;
		case AF_BTN_USESWAP:
			theButtonText = "Swap";
			theTitle = "Swap Artist Name and Track Name fields";
			theFunction = 'doSwapFields(this.form)';
			break;
		case AF_BTN_USECURRENT:
			theButtonText = "Use Current";
			theTitle = "Reset to current Artist Name and Track Name";
			theFunction = 'doUseCurrent(this.form)';
			break;
		case AF_BTN_USESPLIT:
			theButtonText = "Split";
			theTitle = "Use Artist Name and Track Name from split function";
			theFunction = 'doUseSplit(this.form)';
			break;
		case AF_BTN_GUESSBOTH:
			theButtonText = "Guess Both";
			theTitle = "Guess both Artist Name and Track Name";
			theFunction = 'doArtistAndTrackName(this.form)';
			break;
		default:
			alert("af_writeButton() :: unhandled type!");
			return;
	}
	var btnHTML = ('<input type="button" class="button" value="'+theButtonText+'" ');
	btnHTML += ('title="'+theTitle+'" ');
	btnHTML += ('onclick="'+theFunction+'">');
	document.writeln(btnHTML);
	// alert(bHTML);
}

