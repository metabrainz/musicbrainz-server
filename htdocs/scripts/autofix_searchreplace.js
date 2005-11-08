
var afFindReplace = {
	presets : [
		["Remove all round parantheses ()", "\\(|\\)", "", 1],
		["Remove all square brackets []", "\\[|\\]", "", 1],
		["Remove all curly braces {}", "\\{|\\}", "", 1],
		["Remove all bracketing punctuation ()[]{}", "\\(|\\)|\\[|\\]|\\{|\\}", "", 1],
		["Replace [] with ()", "\\[([^\\]]*)\\]", "($1)", 1],
		["Replace () with []", "\\(([^\\)]*)\\)", "[$1]", 1],
		["Replace #1 with No. 1 for any number", "#(\\d*)", "No. $1", 1]
	],
	formRef : null,

	BTN_FIND : "srfind",
	BTN_REPLACE : "srreplace",
	BTN_LOADPRESET : "srloadpreset",
	BTN_SWAP : "srswap",
	SR_COOKIE_EXPANDED : "SR_COOKIE_EXPANDED",
		// name of cookie value for the expanded/collapsed setting
	SR_COOKIE_PRESETEXPANDED : "SR_COOKIE_PRESETEXPANDED",
		// name of cookie value for the preset expanded/collapsed setting

	// ----------------------------------------------------------------------------
	// af_writeButton()
	// -- write a guess case button to the document.
	writeButton : function(theType, theID, theID2) {
		var sTitle = '';
		var sFunc = '';
		var sBtnText = '';
		switch (theType) {
			case this.BTN_FIND:
				sBtnText = "Find";
				sTitle = "";
				sFunc = 'afFindReplace.find(this.form)';
				break;
			case this.BTN_REPLACE:
				sBtnText = "Replace";
				sTitle = "";
				sFunc = 'afFindReplace.doReplace(this.form)';
				break;
			case this.BTN_LOADPRESET:
				sBtnText = "Show/Hide Presets";
				sTitle = "";
				sFunc = 'afFindReplace.showPresets(this)';
				break;
			case this.BTN_SWAP:
				sBtnText = "Swap fields";
				sTitle = "";
				sFunc = 'afFindReplace.swapFields(this.form)';
				break;
			default:
				alert("af_writeButton() :: unhandled type!");
				return;
		}
		var btnHTML = ('<input type="button" class="button" value="'+sBtnText+'" ');
		btnHTML += ('title="'+sTitle+'" ');
		btnHTML += ('onclick="'+sFunc+'">');
		document.writeln(btnHTML);
	},

	// ----------------------------------------------------------------------------
	// writeGUI()
	// -- Write HTML for the find/replace functionality.
	writeGUI : function() {
		document.writeln('            <tr valign="top" id="findreplace-tr-expanded" style="display: none">');
		document.writeln('              <td nowrap><b>Find/Replace:</td>');
		document.writeln('              <td width="100%">');
		document.writeln('                <table cellspacing="0" cellpadding="0" border="0" width="100%">');
		document.writeln('                  <tr>');
		document.writeln('                    <td>Find: &nbsp;</td>');
		document.writeln('                    <td><input type="input" size="30" value="my" name="srSearch">');
		this.writeButton(this.BTN_SWAP);
		document.writeln('                    </td>');
		document.writeln('                  </tr>');
		document.writeln('                  <tr>');
		document.writeln('                    <td>Replace: &nbsp;</td>');
		document.writeln('                    <td><input type="input" size="30" value="your" name="srReplace"></td>');
		document.writeln('                  </tr>');
		document.writeln('                  <tr>');
		document.writeln('                    <td></td>');
		document.writeln('                    <td>');
		// this.writeButton(this.BTN_FIND); not implemented yet.
		this.writeButton(this.BTN_REPLACE);
		this.writeButton(this.BTN_LOADPRESET);
		document.writeln('                    <br/>');
		document.writeln('                    <input type="checkbox" name="srRegex" value="true"><small>Regular expression</small>');
		document.writeln('                    <input type="checkbox" name="srCaseSensitive" value="true"><small>Match case</small>');
		document.writeln('                    <input type="checkbox" name="srAllFields" value="true" checked><small>For all fields</small>');
		document.writeln('                  </tr>');
		document.writeln('                </table>');
		this.writePresets();
		document.writeln('              </td>');
		document.writeln('              <td>&nbsp;</td>');
		document.writeln('              <td align="right">');
		document.writeln('                <a href="javascript:; // collapse" onClick="afFindReplace.setExpanded(false)" title="Hide Find & Replace"><img src="/images/minus.gif" width="13" height="13" alt="Collapse Find & Replace function" border="0"></a>');
		document.writeln('              </td>');
		document.writeln('            </tr>');
		document.writeln('            <tr valign="top" id="findreplace-tr-collapsed">');
		document.writeln('              <td nowrap><b>Find/Replace:</td>');
		document.writeln('              <td width="100%">');
		document.writeln('                <small>Currently in collapsed mode, press [+] to access functions</small>');
		document.writeln('              </td>');
		document.writeln('              <td>&nbsp;</td>');
		document.writeln('              <td align="right">');
		document.writeln('                <a href="javascript:; // expand" onClick="afFindReplace.setExpanded(true)"><img src="/images/plus.gif" width="13" height="13" alt="Expand Find & Replace function" border="0"></a>');
		document.writeln('              </td>');
		document.writeln('            </tr>');

		var ex = getCookie(this.SR_COOKIE_EXPANDED);
		if (ex == "1") this.setExpanded(true);
	},

	// ----------------------------------------------------------------------------
	// writePresets()
	// -- Creates the presets div.
	writePresets : function() {
		document.writeln('  <table id="srPresetsTable" style="display: none" border="0" cellpadding="0" cellspacing="0" width="100%">');
		document.writeln('    <tr>');
		document.writeln('      <td style="font-size: 11px" colspan="6"><img src="/images/spacer.gif" alt="" height="4" width="1"><br/><i>Search & Replace presets</td>');
		document.writeln('    </tr>');
		document.writeln('    <tr>');
		document.writeln('      <td style="font-size: 11px"><b>Description</b> &nbsp;</td>');
		document.writeln('      <td rowspan="100"><img src="/images/spacer.gif" alt="" width="10" height="1"></td>');
		document.writeln('      <td style="font-size: 11px"><b>Find</b> &nbsp;</td>');
		document.writeln('      <td rowspan="100"><img src="/images/spacer.gif" alt="" width="10" height="1"></td>');
		document.writeln('      <td style="font-size: 11px" nowrap><b>Replace</b> &nbsp;</td>');
		document.writeln('      <td style="font-size: 11px; text-align: center" nowrap><b>Regex</b> &nbsp;</td>');
		document.writeln('    </tr>');
		document.writeln('    <tr>');
		document.writeln('      <td colspan="6" bgcolor="#999999"><img src="/images/spacer.gif" alt="" height="1" width="1"></td>');
		document.writeln('    </tr>');
		document.writeln('    <tr>');
		document.writeln('      <td colspan="6"><img src="/images/spacer.gif" alt="" height="3" width="1"></td>');
		document.writeln('    </tr>');
		for (var i=0; i<this.presets.length; i++) {
			document.writeln('  <tr>');
			document.writeln('    <td style="font-size: 11px"><a href="javascript: // select preset" onClick="afFindReplace.selectPreset('+i+')">'+(this.presets[i][0])+'</td>');
			document.writeln('    <td style="font-size: 11px">'+(this.presets[i][1])+'</td>');
			document.writeln('    <td style="font-size: 11px">'+(this.presets[i][2])+'</td>');
			document.writeln('    <td style="font-size: 11px; text-align: center">'+(this.presets[i][3]==1?'yes':'no')+'</td>');
			document.writeln('  </tr>');
		}
		document.writeln('    <tr>');
		document.writeln('    <tr>');
		document.writeln('      <td colspan="6"><img src="/images/spacer.gif" alt="" height="1" width="3"></td>');
		document.writeln('    </tr>');
		document.writeln('    <tr>');
		document.writeln('      <td colspan="6" bgcolor="#999999"><img src="/images/spacer.gif" alt="" height="1" width="1"></td>');
		document.writeln('    </tr>');
		document.writeln('      <td colspan="6"><input type="checkbox" name="srApplyPreset" value="1" checked>Execute Search & Replace when selected.</td>');
		document.writeln('    </tr>');
		document.writeln('    <tr>');
		document.writeln('      <td colspan="6"><img src="/images/spacer.gif" alt="" height="1" width="2"></td>');
		document.writeln('    </tr>');
		document.writeln('</table>');

		var ex = getCookie(this.SR_COOKIE_PRESETEXPANDED);
		if (ex == "1") this.setPresetsVisible(true);
	},

	// ----------------------------------------------------------------------------
	// showPresets()
	// -- Is called from the ">> Load Preset" button
	//    reference to the form is saved for later use.
	showPresets : function(btn) {
		this.setPresetsVisible();
	},

	// ----------------------------------------------------------------------------
	// setExpanded()
	// -- Shows/Hides the find & replace expanded mode according to
	//    the flag.
	setExpanded : function(flag) {
		document.getElementById("findreplace-tr-collapsed").style.display = (!flag ? "" : "none");
		document.getElementById("findreplace-tr-expanded").style.display = (flag ? "" : "none");
		setCookie(this.SR_COOKIE_EXPANDED, (flag ? "1" : "0"), 365); // persistent 365 days.
	},

	// ----------------------------------------------------------------------------
	// setPresetsVisible()
	// -- Shows/Hides the presets overlay visible, according to
	//    the flag.
	setPresetsVisible : function(flag) {
		var obj;
		if ((obj = document.getElementById("srPresetsTable")) != null) {
			if (!flag) {
				// toggle the flag (hide if visible, vice-versa)
				flag = (obj.style.display != "block");
			}
			obj.style.display = flag ? "block" : "none";
		}
		setCookie(this.SR_COOKIE_PRESETEXPANDED, (flag ? "1" : "0"), 365); // persistent 365 days.
	},

	// ----------------------------------------------------------------------------
	// selectPreset()
	// -- Is called from the "Use" links. The index
	//    refers to the offset in the srPresets array
	//    which was selected. If the srApplyPreset
	//    checkbox is checked, the function is executed
	//    immediately.
	selectPreset : function(index) {
		var f;
		if ((f = afCommons.getForm()) != null) {
			f.srSearch.value = this.presets[index][1];
			f.srReplace.value = this.presets[index][2];
			f.srRegex.checked = (this.presets[index][3]==1);
			if (f.srApplyPreset.checked) this.doReplace(f);
		}
	},

	// ----------------------------------------------------------------------------
	// swapFields()
	// -- swaps the contents of the search and the replace field.
	swapFields : function(formRef) {
		this.formRef = formRef;
		var temp = this.formRef.srReplace.value;
		this.formRef.srReplace.value = this.formRef.srSearch.value;
		this.formRef.srSearch.value = temp;
	},

	// ----------------------------------------------------------------------------
	// doReplace()
	// -- Creates a regular expression from the
	//    contents of the srSearch field, and
	//    replaces the occurences in the currently
	//    focussed field.
	doReplace : function(theForm) {
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
			var fields = afCommons.getEditTextFields();
			for (fi in fields) {
				this.replaceField(fields[fi], sv, rv, useCase, useRegex);
			}
		} else if (af_onFocusField) {
			this.replaceField(af_onFocusField, sv, rv, useCase, useRegex);
		}
	},

	replaceField : function(f, sv, rv, useCase, useRegex) {
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
				afUndo.addUndo(new UndoItem(f, 'searchreplace', currvalue, newvalue));
				return true;
			}
		}
		return false;
	}
};



