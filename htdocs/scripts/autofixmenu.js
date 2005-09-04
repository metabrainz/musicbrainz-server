var AF_MODE_AUTOFIX = 'autofix';
var AF_MODE_SENTENCECAPS = 'ucfirst';
var af_mode = AF_MODE_AUTOFIX;

var af_modeDescription = new Array();
af_modeDescription[AF_MODE_AUTOFIX] = 'Standard Guess Case mode, according to the <a target="_blank" href="http://www.musicbrainz.org/style.html">Style Guidelines</a>';
af_modeDescription[AF_MODE_SENTENCECAPS] = 'First word uppercase, rest lowercase for non-English languages. Read the capitalization guides here: <a target="_blank" href="http://wiki.musicbrainz.org/wiki.pl?CapitalizationStandard">CapitalizationStandard</a>';

var AF_OP_UPPERCASE = 'uppercase';
var AF_OP_LOWERCASE = 'lowercase';
var AF_OP_TITLED = 'titled';
var AF_OP_ROUNDBRACKETS = 'roundbrackets';
var AF_OP_SQUAREBRACKETS = 'squarebrackets';

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
	var cn = null;
	if (af_onFocusField) {
		cn = ((cn = af_onFocusField.className) != null ? cn : "");
		if (cn.indexOf("focus") != -1) {
			af_onFocusField.className = cn.replace(/focus/i, "");
		} 
	}
	if (theField && theField.className) {
		if (theField.className.indexOf("focus") == -1) {
			theField.className += "focus";
		}
		af_onFocusField = theField;
		af_onFocusFieldState = new Array(theField, theField.value);
	}
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
	} else {
		try {
			if (af_onFocusField != null &&
			   af_onFocusField.selectionStart != 'undefined') { 
			   // mozilla, and other gecko-based browsers.
				af_onFocusField.selectionStart = 0; // set cursor at pos 0
				af_onFocusField.selectionEnd = 0;
			}
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
// af_writeGui()
//
function af_writeGUI() {
	var temp = null;
	if ((temp = document.getElementById("autofix-box-jsdiabled")) != null) {
		temp.style.display = "none"; // toggle the JS enabled/disabled box.
	}
	var cMode = getCookie(AF_COOKIE_MODE); // get autofix mode from cookie.
	if (cMode) af_mode = cMode;

	document.writeln('      <div id="autofix-box-jsenabled">');
	document.writeln('        <div id="autofix-table-collapsed" style="display: block">');
	document.writeln('          <table width="600" border="0" cellspacing="0" cellpadding="0">');
	document.writeln('            <tr valign="top">');
	document.writeln('              <td width="120" nowrap><b>Guess Case:<br><img src="/images/spacer.gif" alt="" height="1" width="120"/></td>');
	document.writeln('              <td width="100%">');
	document.writeln('                <small><span id="autofix-mode-text-collapsed"></span></small></td>');
	document.writeln('              <td>&nbsp;</td>');
	document.writeln('              <td><a href="javascript: void(0)" title="Expand table" onFocus="this.blur()" onClick="af_ShowTable(true); return false;"><img src="/images/plus.gif" width="13" height="13" alt="Expand Guess Case panel" border="0"></a></td>');
	document.writeln('            </tr>');
	document.writeln('          </table>');
	document.writeln('        </div>');
	document.writeln('        <div id="autofix-table-expanded" style="display: none">');
	document.writeln('          <table width="600" border="0" cellspacing="0" cellpadding="0">');
	document.writeln('            <tr valign="top">');
	document.writeln('              <td width="120" nowrap><b>Guess Case:<br><img src="/images/spacer.gif" alt="" height="1" width="120"/></td>');
	document.writeln('              <td width="100%" id="autofix-mode-cell">');

	// write out current state.
	document.writeln('                <table cellspacing="0" cellpadding="0" border="0" width="100%">');
	document.writeln('                  <tr valign="top">');
	document.writeln('                    <td width="10">');
	document.writeln('                      <select name="autofix-mode" onchange="af_modeChanged(this)">');
	document.writeln('                        <option value="' + AF_MODE_AUTOFIX + '" ' + (af_mode == AF_MODE_AUTOFIX ? 'selected' : '') + '>Title Capitalization</option>');
	document.writeln('                        <option value="' + AF_MODE_SENTENCECAPS + '" ' + (af_mode == AF_MODE_SENTENCECAPS ? 'selected' : '') + '>Sentence Capitalization</option>');
	document.writeln('                      </select></td>');
	document.writeln('                    <td width="10">&nbsp;</td>');
	document.writeln('                    <td width="100%">');
	document.writeln('                      <small><span id="autofix-mode-text-expanded"></span></small>');
	document.writeln('                    </td>');
	document.writeln('                  </tr>');
	document.writeln('                </table>');
	document.writeln('              </td>');
	document.writeln('              <td>&nbsp;</td>');
	document.writeln('              <td width="10"><a href="javascript: void(0)" title="Collapse table" onFocus="this.blur()" onClick="af_ShowTable(false); return false;"><img src="/images/minus.gif" width="13" height="13" alt="Collapse Guess Case panel" border="0"></a></td>');
	document.writeln('            </tr>');
	document.writeln('            <tr><td colspan="4"><img src="/images/spacer.gif" height="4" alt="" /></td></tr>');
	document.writeln('            <tr valign="middle">');
	document.writeln('              <td nowrap><b>Selected Text:</td>');
	document.writeln('              <td>');
	document.writeln('                <table cellspacing="0" cellpadding="0" border="0">');
	document.writeln('                <tr valign="top"><td nowrap>');
	document.writeln('                <input type="button" class="button" value="Capital" title="Capitalize first character only" onClick="doApplyOperation(AF_OP_TITLED)">');
	document.writeln('                <input type="button" class="button" value="UPPER" title="CONVERT CHARACTERS TO UPPERCASE" onClick="doApplyOperation(AF_OP_UPPERCASE)">');
	document.writeln('                <input type="button" class="button" value="lower" title="convert characters to lowercase" onClick="doApplyOperation(AF_OP_LOWERCASE)">');
	document.writeln('                <input type="button" class="button" value="Add ()" title="Add round parentheses () around selection" onClick="doApplyOperation(AF_OP_ROUNDBRACKETS)">');
	document.writeln('                <input type="button" class="button" value="Add []" title="Add square brackets [] around selection" onClick="doApplyOperation(AF_OP_SQUAREBRACKETS)">');
	document.writeln('                </td><td>&nbsp;&nbsp;&nbsp;</td><td>');
	document.writeln('                  [ <a href="/wd/GuessCaseTool" target="_blank" title="Select text in titles, then press one of the buttons at left. Click on this link if you want to know more...">help</a> ] <br/></td>');
	document.writeln('                </tr></table>');
	document.writeln('              </td>');
	document.writeln('            </tr>');
	document.writeln('            <tr><td colspan="4"><img src="/images/spacer.gif" height="4" alt="" /></td></tr>');
	document.writeln('            <tr valign="middle">');
	document.writeln('              <td nowrap><b>Undo/Redo:</td>');
	document.writeln('              <td>');
	document.writeln('                <input disabled type="button" class="buttondisabled" name="undoAllButton" onclick="af_undoAll(this.form)" value="Undo All">');
	document.writeln('                <input disabled type="button" class="buttondisabled" name="undoButton" onclick="af_doUndo(this.form)" value="Undo">');
	document.writeln('                <input disabled type="button" class="buttondisabled" name="redoButton" onclick="af_doRedo(this.form)" value="Redo">');
	document.writeln('                <input disabled type="button" class="buttondisabled" name="redoAllButton" onclick="af_doRedoAll(this.form)" value="Redo All">');
	document.writeln('                <small>&nbsp;&nbsp;&nbsp;Steps:<span id="autofix-text">0/0</span><small>');
	document.writeln('              </td>');
	document.writeln('            </tr>');
	document.writeln('            <tr><td colspan="4"><img src="/images/spacer.gif" height="4" alt="" /></td></tr>');
	document.writeln('            <tr><td colspan="4" bgcolor="1"><img src="/images/spacer.gif" height="1" alt="" /></td></tr>');
	document.writeln('            <tr><td colspan="4"><img src="/images/spacer.gif" height="4" alt="" /></td></tr>');
	document.writeln('            <tr valign="middle">');
	document.writeln('              <td nowrap><b>Textfields:</td>');
	document.writeln('              <td>');
	document.writeln(' 				  <input type="hidden" name="jsProxy" id="jsFormField" value="">');
	document.writeln(' 				  <a href="javascript:;" onClick="af_resizeTextFields(-20)">Make smaller</a> | ');
	document.writeln(' 				  <a href="javascript:;" onClick="af_resizeTextFields(20)">Make bigger</a> | ');
	document.writeln(' 				  <a href="javascript:;" onClick="af_resizeTextFields()">Fit all text</a>');
	document.writeln('              </td>');
	document.writeln('            </tr>');
	document.writeln('            <tr><td colspan="4"><img src="/images/spacer.gif" height="4" alt="" /></td></tr>');
	document.writeln('            <tr valign="top">');
	document.writeln('            <td nowrap><b>Find/Replace:</td>');
	document.writeln('            <td>');
	document.writeln('              <table cellspacing="0" cellpadding="0" border="0">');
	document.writeln('              <tr>');
	document.writeln('                <td class="small">Find what? &nbsp;</td>');
	document.writeln('                <td><input type="input" size="30" value="my" name="srSearch">');
	af_writeButton(AF_BTN_SR_SWAP); 
	document.writeln('                </td>');
	document.writeln('              </tr>');
	document.writeln('              <tr>');
	document.writeln('                <td class="small">Replace with: &nbsp;</td>');
	document.writeln('                <td><input type="input" size="30" value="your" name="srReplace"></td>');
	document.writeln('              </tr>');
	document.writeln('              <tr>');
	document.writeln('                <td></td>');
	document.writeln('                <td class="small">');
	// af_writeButton(AF_BTN_SR_FIND);
	af_writeButton(AF_BTN_SR_REPLACE);
	af_writeButton(AF_BTN_SR_LOADPRESET);
	document.writeln('                <br/>');
	document.writeln('                <input type="checkbox" name="srRegex" value="true"><small>Regular expression</small>');
	document.writeln('                <input type="checkbox" name="srCaseSensitive" value="true"><small>Case sensitive</small>');
	document.writeln('                <input type="checkbox" name="srAllFields" value="true" checked><small>All textfields</small>');
	document.writeln('              </tr>');
	document.writeln('              </table>');
	af_srWritePresets();
	document.writeln('            </td>');
	document.writeln('            </tr>');
	document.writeln('          </table>');
	document.writeln('        </div>');

	af_modeSet(); // update description texts.
	var cTable = getCookie(AF_COOKIE_TABLE); // restore previous expand/collapsed state from cookie.
	if (cTable) { af_ShowTable(cTable == "1"); }
}

// ----------------------------------------------------------------------------
// af_resizeTextFields()
// -- add/remove amount from size attribute on edit fields in
//    the form.
function af_resizeTextFields(amount) {
	var obj, el;
	if ((obj = document.getElementById("jsFormField")) != null) {
		var f = obj.form;
		var fields = af_getEditTextFields(f);
		if (amount == null || amount == 'undefined') {
			var max = 0;
			for (fi in fields) {
				var lx = fields[fi].value.length;
				if (lx > max) max = lx;
			}
			for (fi in fields) {
				fields[fi].size = (max < 50 ? 50 : max); // + parseInt((max/50.0)*20);
			}
		} else {
			for (fi in fields) {
				fields[fi].size += amount;
			}
		}
	}		
}

// ----------------------------------------------------------------------------
// af_getEditTextFields()
// -- returns all the edit text fields (class="textfield")
//    of the current form.
function af_getEditTextFields(f) {
	var fields = new Array();
	if (f) {
		var tfRE = /textfield(focus)?/i;
		for (var i=0; i<f.elements.length; i++) {
			if (el = f.elements[i]) {
				if ((el.type == "text") && 
					(el.className == null ? "" : el.className).match(tfRE)) {
					fields.push(el);
				}
			}
		}
	}  
	return fields;
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

var AF_BTN_SR_FIND = "srfind";
var AF_BTN_SR_REPLACE = "srreplace";
var AF_BTN_SR_LOADPRESET = "srloadpreset";
var AF_BTN_SR_SWAP = "srswap";

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
		case AF_BTN_SR_FIND:
			theButtonText = "Find";
			theTitle = "";
			theFunction = 'af_srFind(this.form)';
			break;		
		case AF_BTN_SR_REPLACE:
			theButtonText = "Replace";
			theTitle = "";
			theFunction = 'af_srReplace(this.form)';
			break;
		case AF_BTN_SR_LOADPRESET:
			theButtonText = "Show/Hide Presets";
			theTitle = "";
			theFunction = 'af_srShowPresets(this)';
			break;
		case AF_BTN_SR_SWAP:
			theButtonText = "Swap fields";
			theTitle = "";
			theFunction = 'af_srSwapFields(this.form)';
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






var srPresets = new Array(
	new Array("Remove all round parantheses ()", "\\(|\\)", "", 1),
	new Array("Remove all square parantheses []", "\\[|\\]", "", 1),
	new Array("Remove all curly parantheses {}", "\\{|\\}", "", 1),
	new Array("Remove all types parantheses ()[]{}", "\\(|\\)|\\[|\\]|\\{|\\}", "", 1),
	new Array("Replace [] with ()", "\\[([^\\]]*)\\]", "($1)", 1),
	new Array("Replace () with []", "\\(([^\\)]*)\\)", "[$1]", 1),
	new Array("Replace #1 with No. 1 for any number", "#(\\d*)", "No. $1", 1)
);
var srForm = null;

// ----------------------------------------------------------------------------
// af_srShowPresets()
// -- Is called from the ">> Load Preset" button
//    reference to the form is saved for later use.
function af_srShowPresets(b) {
	if (b && b.form) {
		srForm = b.form;
		af_srSetVisible();
	}
}

// ----------------------------------------------------------------------------
// af_srSetVisible()
// -- Shows/Hides the presets overlay visible, according to
//    the flag.
function af_srSetVisible(flag) {
	var obj;
	if ((obj = document.getElementById("srPresetsTable")) != null) {
		if (flag) {
			obj.style.display = flag ? "block" : "none";
		} else {
			obj.style.display = (obj.style.display == "none" ? "block" : "none");
		}
	}
}

// ----------------------------------------------------------------------------
// af_srWritePresets()
// -- Creates the presets div.
function af_srWritePresets() {
	document.writeln('<style type="text/css">');
	document.writeln('  #srPresetsTable * { font-size: 10px }');
	document.writeln('</style>');
	document.writeln('  <table id="srPresetsTable" style="display: none" border="0" cellpadding="0" cellspacing="0">');
	document.writeln('    <tr>');
	document.writeln('      <td rowspan="100"><img src="/images/spacer.gif" alt="" width="2" height="1"></td>');
	document.writeln('      <td>&nbsp;</td>');
	document.writeln('      <td nowrap><b>Description</b> &nbsp;</td>');
	document.writeln('      <td rowspan="100"><img src="/images/spacer.gif" alt="" width="10" height="1"></td>');
	document.writeln('      <td nowrap><b>Find</b> &nbsp;</td>');
	document.writeln('      <td rowspan="100"><img src="/images/spacer.gif" alt="" width="10" height="1"></td>');
	document.writeln('      <td nowrap><b>Replace</b> &nbsp;</td>');
	document.writeln('      <td nowrap><b>Regex</b> &nbsp;</td>');
	document.writeln('    </tr>');
	document.writeln('    <tr>');
	document.writeln('      <td></td>');
	document.writeln('      <td colspan="6" bgcolor="black"><img src="/images/spacer.gif" alt="" height="1" width="1"></td>');
	document.writeln('    </tr>');
	document.writeln('    <tr>');
	document.writeln('      <td colspan="5"><img src="/images/spacer.gif" alt="" height="3" width="1"></td>');
	document.writeln('    </tr>');	
	for (var i=0; i<srPresets.length; i++) {
		document.writeln('  <tr>');
		document.writeln('    <td nowrap><a href="javascript: void(0)" onClick="af_srSelectPreset('+i+')">Use</a> &nbsp;</td>');
		document.writeln('    <td nowrap>'+(srPresets[i][0])+'</td>');
		document.writeln('    <td nowrap>'+(srPresets[i][1])+'</td>');
		document.writeln('    <td nowrap>'+(srPresets[i][2])+'</td>');
		document.writeln('    <td align="center">'+(srPresets[i][3]==1?'yes':'no')+'</td>');
		document.writeln('  </tr>');
	}
	document.writeln('    <tr>');
	document.writeln('    <tr>');
	document.writeln('      <td colspan="5"><img src="/images/spacer.gif" alt="" height="1" width="3"></td>');
	document.writeln('    </tr>');	
	document.writeln('    <tr>');
	document.writeln('      <td></td>');
	document.writeln('      <td colspan="7" bgcolor="black"><img src="/images/spacer.gif" alt="" height="1" width="1"></td>');
	document.writeln('    </tr>');
	document.writeln('      <td></td>');
	document.writeln('      <td colspan="5"><input type="checkbox" name="srApplyPreset" value="1" checked>Apply pattern directly after pressing \'use\'.</td>');
	document.writeln('    </tr>');	
	document.writeln('    <tr>');
	document.writeln('      <td colspan="5"><img src="/images/spacer.gif" alt="" height="1" width="2"></td>');
	document.writeln('    </tr>');
	document.writeln('</table>');
}

// ----------------------------------------------------------------------------
// af_srSelectPreset()
// -- Is called from the "Use" links. The index
//    refers to the offset in the srPresets array
//    which was selected. If the srApplyPreset
//    checkbox is checked, the function is executed
//    immediately.
function af_srSelectPreset(index) {
	af_srSetVisible(false);
	if (srForm != null) {
		srForm.srSearch.value = srPresets[index][1];
		srForm.srReplace.value = srPresets[index][2];
		srForm.srRegex.checked = (srPresets[index][3]==1);
		if (srForm.srApplyPreset.checked) af_srReplace(srForm);
	}
}

// ----------------------------------------------------------------------------
// af_srSwapFields()
// -- swaps the contents of the search and the replace field.
function af_srSwapFields(srForm) {
	var temp = srForm.srReplace.value;
	srForm.srReplace.value = srForm.srSearch.value;
	srForm.srSearch.value = temp;
}

// ----------------------------------------------------------------------------
// af_srReplace()
// -- Creates a regular expression from the
//    contents of the srSearch field, and
//    replaces the occurences in the currently
//    focussed field.
function af_srReplace(theForm) {
	resetMessages();
	var sv = theForm.srSearch.value;
	var rv = theForm.srReplace.value;
	var useRegex = theForm.srRegex.checked;
	var useCase = theForm.srCaseSensitive.checked;
	var allFields = theForm.srAllFields.checked;
	if (sv == "") {
		addMessage('af_srReplace() :: Search is empty, aborting.');	
		return;
	}
	if (allFields) {
		var fields = af_getEditTextFields(theForm);
		for (fi in fields) {
			af_srDoReplace(fields[fi], sv, rv, useCase, useRegex);
		}
	} else if (af_onFocusField) {
		af_srDoReplace(af_onFocusField, sv, rv, useCase, useRegex);
	}
}

function af_srDoReplace(f, sv, rv, useCase, useRegex) { 
	if (f) {
		var currvalue = f.value;
		var newvalue = currvalue;
		addMessage('af_srDoStringReplace() :: Current value @@@'+currvalue+'###');	
		addMessage('af_srDoStringReplace() :: search=@@@'+sv+'###, replace=@@@'+rv+'###');
		addMessage('af_srDoStringReplace() ::   flags: case sensitive='+useCase+', regular expressions='+useRegex+'');
		if (useRegex) {
			try {
				var re = new RegExp(sv, "g"+(useCase ? "":"i"));
				newvalue = currvalue.replace(re, rv);
			} catch (e) {
				addMessage('af_srDoStringReplace() :: Caught error while executing Regex re=@@@'+re+'###, e=@@@'+e+'###');
			}
		} else {
			var vi = -1;
			var replaced = new Array();
			var needle = (useCase ? sv : sv.toLowerCase());
			while ((vi = (useCase ? newvalue : newvalue.toLowerCase()).indexOf(needle)) != -1) {
				newvalue = newvalue.substring(0, vi) + rv +
						   newvalue.substring(vi + sv.length, newvalue.length);
				replaced.push(vi);
			}
			if (replaced.length < 1) addMessage('af_srDoStringReplace() :: search @@@'+sv+'### was not found');
			else addMessage('af_srDoStringReplace() :: search @@@'+sv+'### replaced with @@@'+rv+'### at index(es) ['+replaced.join(",")+']');
		}
		if (newvalue != currvalue) {
			addMessage('af_srDoStringReplace() :: New value @@@'+newvalue+'###');	
			f.value = newvalue;
			af_addUndo(
				f.form, 
				new Array(f, 'replace', currvalue, newvalue)
			);
			if (f == af_onFocusField) {
				af_onFocusFieldState[1] = af_onFocusFieldState[0].value; 
				// updated remembered value (such that leaving the field does 
				// not add another UNDO step)
			}
			return true;
		}
	}
	return false;
}




/*
<script>
if (!document.layers)
document.write('<div id="divStayTopLeft" style="position:absolute">')
</script>

<layer id="divStayTopLeft">

<!--EDIT BELOW CODE TO YOUR OWN MENU-->
<table border="1" width="130" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" bgcolor="#FFFFCC">
      <p align="center"><b><font size="4">Menu</font></b></td>
  </tr>
  <tr>
    <td width="100%" bgcolor="#FFFFFF">
      <p align="left"> <a href="http://www.dynamicdrive.com">Dynamic Drive</a><br>
       <a href="http://www.dynamicdrive.com/new.htm">What's New</a><br>
       <a href="http://www.dynamicdrive.com/hot.htm">What's Hot</a><br>
       <a href="http://www.dynamicdrive.com/faqs.htm">FAQs</a><br>
       <a href="http://www.dynamicdrive.com/morezone/">More Zone</a></td>
  </tr>
</table>
<!--END OF EDIT-->

</layer>


<script type="text/javascript">

//Enter "frombottom" or "fromtop"
var verticalpos="frombottom"

if (!document.layers)
document.write('</div>')

function JSFX_FloatTopDiv()
{
	var startX = 3,
	startY = 150;
	var ns = (navigator.appName.indexOf("Netscape") != -1);
	var d = document;
	function ml(id)
	{
		var el=d.getElementById?d.getElementById(id):d.all?d.all[id]:d.layers[id];
		if(d.layers)el.style=el;
		el.sP=function(x,y){this.style.left=x;this.style.top=y;};
		el.x = startX;
		if (verticalpos=="fromtop")
		el.y = startY;
		else{
		el.y = ns ? pageYOffset + innerHeight : document.body.scrollTop + document.body.clientHeight;
		el.y -= startY;
		}
		return el;
	}
	window.stayTopLeft=function()
	{
		if (verticalpos=="fromtop"){
		var pY = ns ? pageYOffset : document.body.scrollTop;
		ftlObj.y += (pY + startY - ftlObj.y)/8;
		}
		else{
		var pY = ns ? pageYOffset + innerHeight : document.body.scrollTop + document.body.clientHeight;
		ftlObj.y += (pY - startY - ftlObj.y)/8;
		}
		ftlObj.sP(ftlObj.x, ftlObj.y);
		setTimeout("stayTopLeft()", 10);
	}
	ftlObj = ml("divStayTopLeft");
	stayTopLeft();
}
JSFX_FloatTopDiv();
</script>
*/
