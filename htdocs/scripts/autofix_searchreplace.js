var srPresets = new Array(
	new Array("Remove all round parantheses ()", "\\(|\\)", "", 1),
	new Array("Remove all square brackets []", "\\[|\\]", "", 1),
	new Array("Remove all curly braces {}", "\\{|\\}", "", 1),
	new Array("Remove all bracketing punctuation ()[]{}", "\\(|\\)|\\[|\\]|\\{|\\}", "", 1),
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
		af_srSetPresetsVisible();
	}
}

// ----------------------------------------------------------------------------
// af_srSetExpanded()
// -- Shows/Hides the find & replace expanded mode according to
//    the flag.
function af_srSetExpanded(flag) {
	document.getElementById("findreplace-tr-collapsed").style.display = (!flag ? "" : "none");
	document.getElementById("findreplace-tr-expanded").style.display = (flag ? "" : "none");
	// set a persistent cookie for the next 365 days.
	setCookie(AF_COOKIE_FINDEXPANDED, (flag ? "1" : "0"), 365);
}

// ----------------------------------------------------------------------------
// af_srSetPresetsVisible()
// -- Shows/Hides the presets overlay visible, according to
//    the flag.
function af_srSetPresetsVisible(flag) {
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
// af_srWriteGUI()
// -- Write HTML for the find/replace functionality.
function af_srWriteGUI() {
	document.writeln('            <tr valign="top" id="findreplace-tr-expanded" style="display: none">');
	document.writeln('              <td nowrap><b>Find/Replace:</td>');
	document.writeln('              <td width="100%">');
	document.writeln('                <table cellspacing="0" cellpadding="0" border="0" width="100%">');
	document.writeln('                  <tr>');
	document.writeln('                    <td>Find what? &nbsp;</td>');
	document.writeln('                    <td><input type="input" size="30" value="my" name="srSearch">');
	af_writeButton(AF_BTN_SR_SWAP); 
	document.writeln('                    </td>');
	document.writeln('                  </tr>');
	document.writeln('                  <tr>');
	document.writeln('                    <td>Replace with: &nbsp;</td>');
	document.writeln('                    <td><input type="input" size="30" value="your" name="srReplace"></td>');
	document.writeln('                  </tr>');
	document.writeln('                  <tr>');
	document.writeln('                    <td></td>');
	document.writeln('                    <td>');
	af_writeButton(AF_BTN_SR_FIND);
	af_writeButton(AF_BTN_SR_REPLACE);
	af_writeButton(AF_BTN_SR_LOADPRESET);
	document.writeln('                    <br/>');
	document.writeln('                    <input type="checkbox" name="srRegex" value="true"><small>Regular expression</small>');
	document.writeln('                    <input type="checkbox" name="srCaseSensitive" value="true"><small>Case sensitive</small>');
	document.writeln('                    <input type="checkbox" name="srAllFields" value="true" checked><small>All textfields</small>');
	document.writeln('                  </tr>');
	document.writeln('                </table>');
	af_srWritePresets();
	document.writeln('              </td>');
	document.writeln('              <td>&nbsp;</td>');
	document.writeln('              <td align="right">');
	document.writeln('                <a href="javascript:; // hide" onClick="af_srSetExpanded(false)" title="Hide Find & Replace"><img src="/images/minus.gif" width="13" height="13" alt="Collapse Find & Replace function" border="0"></a>');
	document.writeln('              </td>');
	document.writeln('            </tr>');
	document.writeln('            <tr valign="top" id="findreplace-tr-collapsed">');
	document.writeln('              <td nowrap><b>Find/Replace:</td>');
	document.writeln('              <td width="100%">');
	document.writeln('                <small>Currently in collapsed mode, press [+] to access functions</small>');
	document.writeln('              </td>');
	document.writeln('              <td>&nbsp;</td>');
	document.writeln('              <td align="right">');
	document.writeln('                <a href="javascript:; // show" onClick="af_srSetExpanded(true)"><img src="/images/plus.gif" width="13" height="13" alt="Expand Find & Replace function" border="0"></a>');
	document.writeln('              </td>');
	document.writeln('            </tr>');
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
	document.writeln('      <td nowrap><b>Description</b> &nbsp;</td>');
	document.writeln('      <td rowspan="100"><img src="/images/spacer.gif" alt="" width="10" height="1"></td>');
	document.writeln('      <td nowrap><b>Find</b> &nbsp;</td>');
	document.writeln('      <td rowspan="100"><img src="/images/spacer.gif" alt="" width="10" height="1"></td>');
	document.writeln('      <td nowrap><b>Replace</b> &nbsp;</td>');
	document.writeln('      <td nowrap><b>Regex</b> &nbsp;</td>');
	document.writeln('    </tr>');
	document.writeln('    <tr>');
	document.writeln('      <td colspan="6" bgcolor="black"><img src="/images/spacer.gif" alt="" height="1" width="1"></td>');
	document.writeln('    </tr>');
	document.writeln('    <tr>');
	document.writeln('      <td colspan="6"><img src="/images/spacer.gif" alt="" height="3" width="1"></td>');
	document.writeln('    </tr>');	
	for (var i=0; i<srPresets.length; i++) {
		document.writeln('  <tr>');
		document.writeln('    <td nowrap><a href="javascript: // select preset" onClick="af_srSelectPreset('+i+')">'+(srPresets[i][0])+'</td>');
		document.writeln('    <td nowrap>'+(srPresets[i][1])+'</td>');
		document.writeln('    <td nowrap>'+(srPresets[i][2])+'</td>');
		document.writeln('    <td align="center">'+(srPresets[i][3]==1?'yes':'no')+'</td>');
		document.writeln('  </tr>');
	}
	document.writeln('    <tr>');
	document.writeln('    <tr>');
	document.writeln('      <td colspan="6"><img src="/images/spacer.gif" alt="" height="1" width="3"></td>');
	document.writeln('    </tr>');	
	document.writeln('    <tr>');
	document.writeln('      <td colspan="6" bgcolor="black"><img src="/images/spacer.gif" alt="" height="1" width="1"></td>');
	document.writeln('    </tr>');
	document.writeln('      <td colspan="6"><input type="checkbox" name="srApplyPreset" value="1" checked>Execute Search & Replace when selected.</td>');
	document.writeln('    </tr>');	
	document.writeln('    <tr>');
	document.writeln('      <td colspan="6"><img src="/images/spacer.gif" alt="" height="1" width="2"></td>');
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
