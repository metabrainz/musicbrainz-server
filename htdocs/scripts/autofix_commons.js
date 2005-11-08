
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
var AF_BTNTEXT_ALBUMARTISTANDTRACKS = 'Guess Album, Artist and Track Names according to Guess Case settings';

var AF_BTN_SR_FIND = "srfind";
var AF_BTN_SR_REPLACE = "srreplace";
var AF_BTN_SR_LOADPRESET = "srloadpreset";
var AF_BTN_SR_SWAP = "srswap";


var AF_MODE_AUTOFIX = 'autofix';
var AF_MODE_SENTENCECAPS = 'ucfirst';
var af_mode = AF_MODE_AUTOFIX;











// AutoFixCommons afc
var afCommons = {
	FORMFIELD_ID 	: "AUTOFIX_FORMFIELD_ID",
	focusField 		: null,
	focusValue		: null,
	formRef 		: null,
		// holds a reference to the form which the autofix framework is in.

	// ----------------------------------------------------------------------------
	// getFocusField()
	// -- returns the field which currently has focus.
	getFocusField : function() {
		return this.focusField;
	},

	// ----------------------------------------------------------------------------
	// setFocusField()
	// -- sets the field which currently has focus.
	setFocusField : function(field) {
		this.focusField = field;
	},

	// ----------------------------------------------------------------------------
	// getFocusValue()
	// -- returns the (stored) field value of the focussed field.
	getFocusValue : function() {
		return this.focusValue;
	},

	// ----------------------------------------------------------------------------
	// setFocusValue()
	// -- sets the (stored) field value of the focussed field.
	setFocusValue : function(v) {
		this.focusValue = v;
	},


	// ----------------------------------------------------------------------------
	// getForm()
	// -- Return the form the autofix function is working on.
	getForm : function() {
		if (!this.formRef) {
			var obj;
			if ((obj = document.getElementById(this.FORMFIELD_ID)) != null) {
				this.formRef = obj.form;
			}
		}
		return this.formRef;
	},

	// ----------------------------------------------------------------------------
	// getField()
	// -- returns the field named fid in the current form, if
	getField : function(fid) {
		var f;
		if ((f = this.getForm()) != null) {
			return f[fid];
		}
		return null;
	},

	// ----------------------------------------------------------------------------
	// resetSelection()
	// -- resets the selection on the field currently
	//    having an active selection
	resetSelection : function() {
		if(typeof document.selection != 'undefined') {
			// ie support
			try {
				document.selection.empty();
			} catch (e) {}
		} else {
			try {
				if ((this.focusField != null) &&
					(this.focusField.selectionStart != 'undefined')) {
					this.focusField.selectionStart = 0; // mozilla, and other gecko-based browsers.
					this.focusField.selectionEnd = 0; // set cursor at pos 0
				}
			} catch (e) {}
		}
	},

	// ----------------------------------------------------------------------------
	// myOnFocus()
	// -- remembers the current field the user clicked into
	//    and the value when editing started
	onFocusHandler : function(field) {
		var cn = null;
		if (this.focusField) {
			cn = ((cn = this.focusField.className) != null ? cn : "");
			if (cn.indexOf("focus") != -1) {
				this.focusField.className = cn.replace(/focus/i, "");
			}
			// see if we have to remove quick functions
			afQuickOps.removeQuickFuncs(this.focusField);
		}
		if (field && field.className) {
			if (field.className.indexOf("focus") == -1) {
				field.className += "focus";
			}
			this.setFocusField(field);
			this.setFocusValue(field.value);

			// if we are editing a tracktime field, and the value is the
			// default NULL value, clear the field for editing.
			if (field.value == "?:??") field.value = "";

			// see if we have to add quick functions
			afQuickOps.addQuickFuncs(field);
		}
	},

	// ----------------------------------------------------------------------------
	// onBlurHandler()
	// -- checks if its the same field the user started
	//    editing and checks for changes. if the value
	//    was changed the edit is saved into the changelog.
	onBlurHandler : function(field) {
		var newvalue = field.value;
		var oldvalue = this.getFocusValue();

		// check if we are editing a tracktime field. if no changes were made,
		// reset to "?:??"
		if (oldvalue == "?:??" && newvalue == "") field.value = oldvalue;

		// handle normal blur event (if value changed, add to undo stack)
		if (this.isFocusField(field) && oldvalue != field.value) {
			afUndo.addUndo(new UndoItem(field, 'manual', oldvalue, newvalue));
		}
	},

	// ----------------------------------------------------------------------------
	// isFocusField()
	// -- returns true if the given parameter is equal to the focussed field.
	isFocusField : function(field) {
		return (this.getFocusField() == field);
	},

	// ----------------------------------------------------------------------------
	// getEditTextFields()
	// -- returns all the edit text fields (class="textfield")
	//    of the current form.
	getEditTextFields : function() {
		var fields = [];
		if (this.getForm()) {
			var cnRE = /textfield(focus)?/i;
			return this.getFieldsWalker(cnRE, null);
		}
		return [];
	},

	// ----------------------------------------------------------------------------
	// getArtistFields()
	// -- returns all the artist fields (class="textfield")
	//    of the current form.
	getArtistFields : function() {
		if (this.getForm()) {
			var cnRE   = /textfield(focus)?/i;
			var nameRE = /artistname\d+/i;
			return this.getFieldsWalker(cnRE, nameRE);
		}
		return [];
	},

	// ----------------------------------------------------------------------------
	// getAlbumNameField()
	// -- returns the album name field (class="textfield")
	getAlbumNameField : function() {
		var fields = [];
		if (this.getForm()) {
			var cnRE   = /textfield(focus)?/i;
			var nameRE = /title|albumname|album/i;
			fields = this.getFieldsWalker(cnRE, nameRE);
		}
		return fields[0];
	},

	// ----------------------------------------------------------------------------
	// getTrackNameFields()
	// -- returns all the edit text fields (class="textfield")
	//    of the current form.
	getTrackNameFields : function() {
		if (this.getForm()) {
			var cnRE = /textfield(focus)?/i;
			var nameRE = /track\d+/i;
			return this.getFieldsWalker(cnRE, nameRE);
		}
		return [];
	},

	// ----------------------------------------------------------------------------
	// getTrackTimeFields()
	// -- returns all the time edit fields (class="numberfield")
	//    of the current form.
	getTrackTimeFields : function() {
		if (this.getForm()) {
			var cnRE = /numberfield(focus)?/i;
			var nameRE = /tracklength\d+/i;
			return this.getFieldsWalker(cnRE, nameRE);
		}
		return [];
	},

	// ----------------------------------------------------------------------------
	// getFieldsWalker()
	// -- Iterate over all fields of the form and collect
	//    the items matching the selection criteria.
	getFieldsWalker : function(cnRE, nameRE) {
		var fields = [];
		if (this.getForm()) {
			var f = this.getForm();
			for (var i=0; i<f.elements.length; i++) {
				var el = f.elements[i];
				if (el) {
					// get classname from element, and match against RE (if RE is set)
					var className = (el.className ? el.className : "");
					var bCN = (cnRE == null || (cnRE != null && className.match(cnRE)));

					// get element name, and match against RE (if RE is set)
					var elName = (el.name ? el.name : "");
					var bName = (nameRE == null || (nameRE != null && elName.match(nameRE))); // if set, must match
					if ((el.type == "text") && bCN && bName) {
						fields.push(el);
					}
				}
			}
		}
		return fields;
	}
};
function myOnFocus(field) { afCommons.onFocusHandler(field); } // for backwards compatibility
function myOnBlur(field) { afCommons.onBlurHandler(field); } // for backwards compatibility


// ----------------------------------------------------------------------------
// AutoFixUndoRedo afUndo
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// class UndoItem
// - Models one step of the Undo/Redo stack
// ----------------------------------------------------------------------------
function UndoItem(_field, _op, _old, _new) {
	this._field = _field;
	this._op = _op;
	this._old = _old;
	this._new = _new;
	this.getField = function() { return this._field; };
	this.getOp = function() { return this._op; };
	this.getOld = function() { return this._old; };
	this.getNew = function() { return this._new; };
	this.setField = function(v) { this._field = v; };
	this.setOp = function(v) { this._op = v; };
	this.setOld = function(v) { this._old = v; };
	this.setNew = function(v) { this._new = v; };
	this.toString = function() { return  "UndoItem [field="+this.getField()
										+", op="+this.getOp()
										+", old="+this.getOld()
										+", new="+this.getNew()+"]"; };
}

// ----------------------------------------------------------------------------
// class UndoItemList
// - Models a multiple-part step of the Undo/Redo stack
// ----------------------------------------------------------------------------
function UndoItemList() {
	this._list = [];
	for (var i=0;i<arguments.length; i++) {
		if (arguments[i] instanceof UndoItem) {
			this._list[this._list.length] = arguments[i];
		}
	}
	this.getList = function() { return this._list; };
	this.iterate = function() { this._cnt = 0; };
	this.getNext = function() { return this._list[this._cnt++]; };
	this.hasNext = function() { return this._cnt < this._list.length; };
}

// ----------------------------------------------------------------------------
// class afUndo
// - Handles the undo/redo functionality of the autofix box.
// ----------------------------------------------------------------------------
var afUndo = {
	stack : [],
	index : 0,
	UNDO_LIST : "UNDO_LIST",
	SPAN_UNDOSTATUS : "AFUR_SPAN_UNDOSTATUS",
	BTN_UNDO_ALL : "AFUR_BTN_UNDO_ALL",
	BTN_UNDO_ONE : "AFUR_BTN_UNDO_ONE",
	BTN_REDO_ONE : "AFUR_BTN_REDO_ONE",
	BTN_REDO_ALL : "AFUR_BTN_REDO_ALL",

	// ----------------------------------------------------------------------------
	// addUndo()
	// -- Track back one step in the changelog
	addUndo : function(undoObj) {
		this.stack = this.stack.slice(0, this.index);
		this.stack.push(undoObj);
		this.index = this.stack.length;

		// updated remembered value (such that leaving the field does
		// not add another UNDO step)
		var f = null;
		var ff = afCommons.getFocusField();
		if (undoObj instanceof UndoItemList) {
			// we have multiple undo steps combined
			var undoList = undoObj;
			for (undoList.iterate(); undoList.hasNext();) {
				undoObj = undoList.getNext();
				if (undoObj.getField() == ff) {
					// update remembered value for the focussed field
					afCommons.setFocusValue(undoObj.getNew());
				}
			}
		} else {
			// we have a single undo step
			if (undoObj.getField() == ff) {
				// update remembered value for the focussed field
				afCommons.setFocusValue(undoObj.getNew());
			}
		}
		this.updateGUI();
	},

	// ----------------------------------------------------------------------------
	// undoOne()
	// -- Track back one step in the changelog
	undoOne : function() {
		if (this.stack.length > 0) {
			if (this.index > 0) {
				var undoObj = this.stack[--this.index]; // move pointer, get item
				if (undoObj instanceof UndoItemList) {
					// we have multiple undo steps combined
					for (undoObj.iterate(); undoObj.hasNext();) {
						var o = undoObj.getNext(); // undo step of each of the items
						o.getField().value = o.getOld();
					}
				} else {
					undoObj.getField().value = undoObj.getOld(); // undo single change
				}
			}
			this.updateGUI();
		}
		afCommons.resetSelection();
	},

	// ----------------------------------------------------------------------------
	// redoOne()
	// -- Re-apply one step which was undone previously
	redoOne : function() {
		if (this.index < this.stack.length) {
			var undoObj = this.stack[this.index]; // move pointer, get item
			if (undoObj instanceof UndoItemList) {
				// we have multiple undo steps combined
				for (undoObj.iterate(); undoObj.hasNext();) {
					var o = undoObj.getNext(); // redo step of each of the items
					o.getField().value = o.getNew();
				}
			} else {
				undoObj.getField().value = undoObj.getNew(); // redo single change
			}
			this.index++;
			this.updateGUI();
		}
		afCommons.resetSelection();
	},

	// ----------------------------------------------------------------------------
	// undoAll()
	// -- Track back one step in the changelog
	undoAll : function() {
		if (this.stack.length > 0)
			while(this.index > 0) this.undoOne();
	},

	// ----------------------------------------------------------------------------
	// redoAll()
	// -- Re-apply one step which was undone previously
	redoAll : function() {
		while (this.index < this.stack.length) this.redoOne();
	},

	// ----------------------------------------------------------------------------
	// writeGUI()
	writeGUI : function() {
		document.writeln('<tr valign="middle">');
		document.writeln('  <td nowrap><b>Undo/Redo:</td>');
		document.writeln('  <td colspan="3">');
		document.writeln('    <input disabled type="button" class="buttondisabled" name="'+this.BTN_UNDO_ALL+'" onclick="afUndo.undoAll(this.form)" value="Undo All">');
		document.writeln('    <input disabled type="button" class="buttondisabled" name="'+this.BTN_UNDO_ONE+'" onclick="afUndo.undoOne(this.form)" value="Undo">');
		document.writeln('    <input disabled type="button" class="buttondisabled" name="'+this.BTN_REDO_ONE+'" onclick="afUndo.redoOne(this.form)" value="Redo">');
		document.writeln('    <input disabled type="button" class="buttondisabled" name="'+this.BTN_REDO_ALL+'" onclick="afUndo.redoAll(this.form)" value="Redo All">');
		document.writeln('    <small>&nbsp;&nbsp;&nbsp;Steps:<span id="'+this.SPAN_UNDOSTATUS+'">0/0</span><small>');
		document.writeln('  </td>');
		document.writeln('</tr>');
	},

	// ----------------------------------------------------------------------------
	// updateGUI()
	// -- Set the state of the buttons and display
	//    where in the changelog the pointer is.
	updateGUI : function() {
		var theForm;
		if ((theForm = afCommons.getForm()) != null) {
			this.setBtnState(theForm[this.BTN_UNDO_ONE], (this.index == 0));
			this.setBtnState(theForm[this.BTN_REDO_ONE], (this.index == this.stack.length));
			this.setBtnState(theForm[this.BTN_UNDO_ALL], (this.index == 0));
			this.setBtnState(theForm[this.BTN_REDO_ALL], (this.index == this.stack.length));
			var obj = null;
			if ((obj = document.getElementById(this.SPAN_UNDOSTATUS)) != null) {
				obj.innerHTML = this.index+"/"+this.stack.length;
			}
		}
	},

	// ----------------------------------------------------------------------------
	// setBtnState()
	// -- Set css class to disabled/enabeled and disabled attribute as well
	setBtnState : function(theButton, isDisabled) {
		if (theButton) {
			theButton.disabled = isDisabled;
			theButton.className = "button"+(isDisabled? "disabled" : "");
		}
	}
};

// AutoFixUtilityFunctions
var afQuickOps = {

	AF_QOPS_UPPERCASE 			: 'AF_QOPS_UPPERCASE',
	AF_QOPS_LOWERCASE 			: 'AF_QOPS_LOWERCASE',
	AF_QOPS_TITLED 				: 'AF_QOPS_TILED',
	AF_QOPS_ADD_ROUNDBRACKETS 	: 'AF_QOPS_ADD_ROUNDBRACKETS',
	AF_QOPS_ADD_SQUAREBRACKETS 	: 'AF_QOPS_ADD_SQUAREBRACKETS',
	AF_QOPS_REM_ROUNDBRACKETS 	: 'AF_QOPS_REM_ROUNDBRACKETS',
	AF_QOPS_REM_SQUAREBRACKETS 	: 'AF_QOPS_REM_SQUAREBRACKETS',

	UF_CHECKBOX_CONF	: "UF_CHECKBOX_CONF",
	UF_COOKIE_EXPANDED 	: "UF_COOKIE_EXPANDED",

	configCheckBoxes : [
						["uf_addQuickFuncs", 0,
						 "Show per-input field util functions",
						 "Add Titlecase, Uppercase, Lowercase, Brackets manipulation and Undo/Redo functions near the form field when it gets the focus."]
					   ],
	config : [],

	// ----------------------------------------------------------------------------
	// writeGUI()
	// -- Write HTML
	writeGUI : function() {
		document.writeln('            <tr valign="top" id="quickops-tr-expanded" style="display: none">');
		document.writeln('              <td nowrap><b>Util functions:</td>');
		document.writeln('              <td width="100%">');
		document.writeln('<input type="button" class="button" value="Capital" title="Capitalize first character only" onClick="afQuickOps.runOp(\''+this.AF_QOPS_TITLED+'\')">');
		document.writeln('<input type="button" class="button" value="UPPER" title="CONVERT CHARACTERS TO UPPERCASE" onClick="afQuickOps.runOp(\''+this.AF_QOPS_UPPERCASE+'\')">');
		document.writeln('<input type="button" class="button" value="lower" title="convert characters to lowercase" onClick="afQuickOps.runOp(\''+this.AF_QOPS_LOWERCASE+'\')">');
		document.writeln('<input type="button" class="button" value="Add ()" title="Add round parentheses () around selection" onClick="afQuickOps.runOp(\''+this.AF_QOPS_ADD_ROUNDBRACKETS+'\')">');
		document.writeln('<input type="button" class="button" value="Add []" title="Add square brackets [] around selection" onClick="afQuickOps.runOp(\''+this.AF_QOPS_ADD_SQUAREBRACKETS+'\')">');
		//document.writeln('&nbsp;&nbsp;&nbsp;');
		//document.writeln('[ <a href="/wd/GuessCaseTool" target="_blank" title="Select text in titles, then press one of the buttons at left. Click on this link if you want to know more...">help</a> ]');
		document.writeln('              <br/><small>');
		this.writeConfiguration();
		document.writeln('              </small>');
		document.writeln('              </td>');
		document.writeln('              <td>&nbsp;</td>');
		document.writeln('              <td align="right">');
		document.writeln('                <a href="javascript:; // collapse" onClick="afQuickOps.setExpanded(false)" ');
		document.writeln('                ><img src="/images/minus.gif" width="13" height="13" alt="Collapse Util functions" border="0"></a>');
		document.writeln('              </td>');
		document.writeln('            </tr>');
		document.writeln('            </tr>');
		document.writeln('            <tr valign="top" id="quickops-tr-collapsed">');
		document.writeln('              <td nowrap><b>Util functions:</td>');
		document.writeln('              <td width="100%">');
		document.writeln('                <small>Currently in collapsed mode, press [+] to access functions</small>');
		document.writeln('              </td>');
		document.writeln('              <td>&nbsp;</td>');
		document.writeln('              <td align="right">');
		document.writeln('                <a href="javascript:; // expand" onClick="afQuickOps.setExpanded(true)"');
		document.writeln('                ><img src="/images/plus.gif" width="13" height="13" alt="Expand Util functions" border="0"></a>');
		document.writeln('              </td>');
		document.writeln('            </tr>');

		var ex = getCookie(this.UF_COOKIE_EXPANDED);
		if (ex == "1") this.setExpanded(true);
	},

	// ----------------------------------------------------------------------------
	// setExpanded()
	// -- toggle the GUI (collapsed|expanded)
	setExpanded : function(flag) {
		document.getElementById("quickops-tr-collapsed").style.display = (!flag ? "" : "none");
		document.getElementById("quickops-tr-expanded").style.display = (flag ? "" : "none");
		setCookie(this.UF_COOKIE_EXPANDED, (flag ? "1" : "0"), 365); // persistent 365 days.
	},


	// ----------------------------------------------------------------------------
	// writeConfiguration() -
	// write the different checkboxes
	writeConfiguration : function() {
		for (var i=0; i<this.configCheckBoxes.length; i++) {
			var cb = this.configCheckBoxes[i];
			var helpText = cb[3];
			helpText = helpText.replace("'", "´"); // make sure overlib does not choke on single-quotes.
			var _html = '<input type="checkbox" name="' + this.UF_CHECKBOX_CONF
					  + '" id="' + cb[0] + '" value="on" '
					  + (getCookie(cb[0]) == "1" ? " checked " : "")
					  + ' onChange="afQuickOps.onConfigurationChange(this)" '
					  + (cb[1]?'checked':'') + '>' + cb[2]
					  + '&nbsp; '
					  + '[ <a href="javascript:; // help" '
					  + 'onmouseover="return overlib(\''+helpText+'\');"'
					  + 'onmouseout="return nd();">help</a> ]<br/>';
			document.writeln(_html);
		}
	},

	// ----------------------------------------------------------------------------
	// writeConfiguration() -
	// write the different checkboxes
	onConfigurationChange : function(el) {
		setCookie(el.id, (el.checked ? "1" : "0"), 365);
	},

	// ----------------------------------------------------------------------------
	// getConfiguration() -
	// Get values from the config checkboxes
	getConfiguration : function() {
		var obj = null;
		if ((obj = document.getElementsByName(this.UF_CHECKBOX_CONF)) != null) {
			this.formRef = obj[0].form;
			for (var i=0; i<obj.length; i++) {
				var el = obj[i];
				this.config[el.id] = el.checked;
			}
		}
	},

	// ----------------------------------------------------------------------------
	// getConf() -
	// Get value for a specific configuration
	getConf : function(key) {
		return (this.config[key] == true);
	},

	// ----------------------------------------------------------------------------
	// addQuickFuncs() -
	// Get value for a specific configuration
	addQuickFuncs : function(field) {
		this.getConfiguration();
		if (this.getConf("uf_addQuickFuncs")) {
			if (field.className.match("textfieldfocus")) {
				var divName = field.name + "_quickfuncs";
				var obj;
				if ((obj = document.getElementById(divName)) == null) {
					var _div = document.createElement("div");
					_div.id = divName;
					_div.style.marginTop = "2px";
					_div.style.padding = "2px";
					_div.style.border = "1px dotted black";
					_div.style.paddingTop = "0px";
					_div.style.borderRight = "none";
					_div.style.borderTop = "none";
					field.parentNode.appendChild(_div);
					_div.innerHTML = afQuickOps.getTextFieldUtilityFuncs();

					try {
						// alert(field.parentNode.parentNode.nodeName);
						field.parentNode.parentNode.style.verticalAlign = "top";
						field.parentNode.parentNode.setAttribute("valign", "top");
					} catch (e) {}
				}
			}
		}
	},

	// ----------------------------------------------------------------------------
	// removeQuickFuncs() -
	// Get value for a specific configuration
	removeQuickFuncs : function(field) {
		var divName = field.name + "_quickfuncs";
		var obj;
		if ((obj = document.getElementById(divName)) != null) {
			field.parentNode.removeChild(obj);
			try {
				field.parentNode.parentNode.setAttribute("valign", "");
			} catch (e) {}
		}
	},

	// ----------------------------------------------------------------------------
	// getTextFieldUtilityFuncs()
	// -- HTML for the individual AF functionalities
	//    per input field.
	getTextFieldUtilityFuncs : function() {
		var writeFunc = function(title, helpText, op) {
			helpText = helpText.replace("'", "´"); // make sure overlib does not choke on single-quotes.
			var _html = '<a href="javascript:; // '+title+'" '
					  + 'onClick="afQuickOps.runOp(\''+op+'\')"'
					  + 'onFocus="this.blur()"'
					  + 'tabindex = "10000" '
					  + 'onMouseOver="return overlib(\''+helpText+'\');"'
					  + 'onMouseOut="return nd();">'+title+'</a>';
			return _html;
		};

		var func = '<table cellspacing="0" cellpadding="0" border="0"><tr>'
			  + '<td rowspan="3">&nbsp;</td>'
			  + '<td nowrap style="font-size: 11px">Change case:&nbsp;&nbsp;</td>'
			  + '<td nowrap style="font-size: 11px">'
			  + '   ' + writeFunc('Titled', 'All characters of selection/field are made lowercase but the first', this.AF_QOPS_TITLED)
			  + ' | ' + writeFunc('Uppercase', 'Convert all characters of the selection/field to UPPERCASE', this.AF_QOPS_UPPERCASE)
			  + ' | ' + writeFunc('Lowercase', 'Convert all characters of the selection/field to lowercase', this.AF_QOPS_LOWERCASE)
			  + '</td></tr><tr>'
			  + '<td nowrap style="font-size: 11px">Modify:&nbsp;&nbsp;</td>'
			  + '<td nowrap style="font-size: 11px">'
			  + '   ' + writeFunc('Add ()', 'Add round parentheses () around selection/field', this.AF_QOPS_ADD_ROUNDBRACKETS)
			  + ' | ' + writeFunc('Rem ()', 'Remove round parentheses () from selection/field', this.AF_QOPS_REM_ROUNDBRACKETS)
			  + ' | ' + writeFunc('Add []', 'Add square brackets [] around selection/field', this.AF_QOPS_ADD_SQUAREBRACKETS)
			  + ' | ' + writeFunc('Rem []', 'Remove square brackets [] from selection/field', this.AF_QOPS_REM_SQUAREBRACKETS)
			  + '</td></tr><tr>'
			  + '<td nowrap style="font-size: 11px">Undo/Redo:&nbsp;&nbsp;</td>'
			  + '<td nowrap style="font-size: 11px">'
			  + '   <a href="javascript:; // Undo" onMouseOver="return overlib(\'Undo the last change (Attention: Not only the selected field)\');" onMouseOut="return nd();" onFocus="this.blur()" onClick="afUndo.undoOne()">Undo</a>'
			  + ' | <a href="javascript:; // Redo" onMouseOver="return overlib(\'Redo the last undo step (Attention: Not only the selected field)\');" onMouseOut="return nd();"  onFocus="this.blur()" onClick="afUndo.redoOne()">Redo</a>'
			  + '</td></tr></table>';
		return func;
	},

	// ----------------------------------------------------------------------------
	// formatText()
	// -- returns the text formatted depending on the op parameter
	formatText : function(fText, op) {
		if (op == this.AF_QOPS_UPPERCASE) fText = fText.toUpperCase();
		if (op == this.AF_QOPS_LOWERCASE) fText = fText.toLowerCase();
		if (op == this.AF_QOPS_TITLED) {
			fText = fText.toLowerCase();
			var tArr = fText.split("");
			tArr[0] = tArr[0].toUpperCase();
			fText = tArr.join("");
		}
		return fText;
	},

	// ----------------------------------------------------------------------------
	// runOp()
	// -- applies the current operation to the selected text
	//    in the field the cursor was last placed in.
	// -- djce suggested, that the method should work on the full text of the
	// 	  field the cursor is currently placed in if nothing is selected
	// -- adapted code from: http://www.quirksmode.org/js/selected.html
	// 	  http://www.scriptygoddess.com/archives/2004/06/08/mozilla-and-ie-decoder
	// -- IE document.selection object API: http://www.html-world.de/program/js_o_sel.php
	runOp : function(op) {
		var f = null;
		if ((f = afCommons.getFocusField()) != null) {
			var oldvalue = f.value;
			var after,before = "";
			if(typeof document.selection != 'undefined') {
				// ie support
				try {
					var fRange = document.selection.createRange();
					before = (fRange.text == '' ? f.value : fRange.text);
					after = before;
						// initialise test- and result string to
						// full string if selection is empty
					switch (op) {
						case this.AF_QOPS_UPPERCASE:
						case this.AF_QOPS_LOWERCASE:
						case this.AF_QOPS_TITLED:
							after = this.formatText(before, op);
							break;
						case this.AF_QOPS_ADD_ROUNDBRACKETS:
							after = "("+before+")";
							break;
						case this.AF_QOPS_ADD_SQUAREBRACKETS:
							after = "["+before+"]";
							break;
						case this.AF_QOPS_REM_ROUNDBRACKETS:
							after = after.replace(/\(|\)/g, "");
							break;
						case this.AF_QOPS_REM_SQUAREBRACKETS:
							after = after.replace(/\[|\]/g, "");
							break;
					}
					if (before == f.value) f.value = after;
					else fRange.text = after;
				} catch (e) {}

			} else if (typeof f.selectionStart != 'undefined') {
				// MOZILLA/NETSCAPE support
				f.focus();
				var fFullText = f.value;
				var sPos = f.selectionStart;
				var ePos = f.selectionEnd;
				before = (sPos == ePos ? fFullText : fFullText.substring(sPos, ePos));
				after = before;
				switch (op) {
					case this.AF_QOPS_UPPERCASE:
					case this.AF_QOPS_LOWERCASE:
					case this.AF_QOPS_TITLED:
						after = this.formatText(before, op);
						break;
					case this.AF_QOPS_ADD_ROUNDBRACKETS:
						after = "("+before+")";
						break;
					case this.AF_QOPS_ADD_SQUAREBRACKETS:
						after = "["+before+"]";
						break;
					case this.AF_QOPS_REM_ROUNDBRACKETS:
						after = after.replace(/\(|\)/g, "");
						break;
					case this.AF_QOPS_REM_SQUAREBRACKETS:
						after = after.replace(/\[|\]/g, "");
						break;
				}
				if (sPos == ePos) f.value = after; // e.g. no selection
				else {
					f.value = fFullText.substring(0, sPos) + after +
							  fFullText.substring(ePos, fFullText.length);
					f.selectionStart = sPos;
					f.selectionEnd = sPos + after.length;
				}
			}
			var newvalue = f.value;
			if (newvalue != oldvalue) {
				afUndo.addUndo(new UndoItem(f, 'changecase', oldvalue, newvalue));
			}
		}
	}
};





// ----------------------------------------------------------------------------
// AutoFixMenu
// ----------------------------------------------------------------------------
var afMenu = {

	AF_COOKIE_MODE 			: "AF_COOKIE_MODE",
	AF_COOKIE_TABLE 		: "AF_COOKIE_TABLE",


	// ----------------------------------------------------------------------------
	// onAutoFixModeChanged()
	// -- set the autofixmode to the selected mode from the dropdown box.
	onAutoFixModeChanged : function(el) {
		if (el && el.options) {
			af_mode = el.options[el.selectedIndex].value;
			this.updateAutoFixModeText();
			setCookie(this.AF_COOKIE_MODE, af_mode, 365); // persistent 365 days.
		}
	},

	// ----------------------------------------------------------------------------
	// updateAutoFixModeText()
	// -- set the text explaining the current mode, once for the expanded and
	//    for the collapsed mode
	updateAutoFixModeText : function() {
		var t = "";
		if (af_mode == AF_MODE_AUTOFIX) {
			t = 'Standard Guess Case mode, according to the <a target="_blank" href="http://www.musicbrainz.org/style.html">Style Guidelines</a>';
		} else if (af_mode == AF_MODE_SENTENCECAPS) {
			t = 'First word uppercase, rest lowercase for non-English languages. Read the capitalization guides here: <a target="_blank" href="http://wiki.musicbrainz.org/wiki.pl?CapitalizationStandard">CapitalizationStandard</a>';
		}
		document.getElementById("autofix-mode-text-collapsed").innerHTML = t;
		document.getElementById("autofix-mode-text-expanded").innerHTML = t;
	},

	// ----------------------------------------------------------------------------
	// setExpanded()
	// -- toggle display of the autofix table
	setExpanded : function(flag) {
		document.getElementById("autofix-table-collapsed").style.display = (!flag ? "block" : "none");
		document.getElementById("autofix-table-expanded").style.display = (flag ? "block" : "none");
		setCookie(this.AF_COOKIE_TABLE, (flag ? "1" : "0"), 365); // persistent 365 days.
	},

	// writeGUISpacer()
	// -- write HTML for a horizontal spacer gif
	writeGUISpacer : function() {
		document.writeln('            <tr><td colspan="4"><img src="/images/spacer.gif" height="4" alt="" /></td></tr>');
	},

	// writeGUIRuler()
	// -- write HTML for a horizontal black ruler
	writeGUIRuler : function() {
		document.writeln('            <tr><td colspan="4"><img src="/images/spacer.gif" height="2" alt="" /></td></tr>');
		document.writeln('            <tr><td colspan="4" bgcolor="black"><img src="/images/spacer.gif" height="1" alt="" /></td></tr>');
		document.writeln('            <tr><td colspan="4"><img src="/images/spacer.gif" height="2" alt="" /></td></tr>');
	},

	// ----------------------------------------------------------------------------
	// writeGUI(fOpen)
	//
	writeGUI : function(fOpen) {
		var cMode = getCookie(this.AF_COOKIE_MODE); // get autofix mode from cookie.
		if (cMode) af_mode = cMode;

		// this line is very important. it writes out the hidden field which is used
		// to get a reference to the form the autofix function is placed in.
		document.writeln('      <input type="hidden" name="jsProxy" id="'+afCommons.FORMFIELD_ID+'" value="">');

		// write autofix HTML
		document.writeln('      <div id="autofix-box-jsenabled">');
		document.writeln('        <div id="autofix-table-collapsed">');
		document.writeln('          <table width="600" border="0" cellspacing="0" cellpadding="0">');
		document.writeln('            <tr valign="top">');
		document.writeln('              <td width="120" nowrap><b>Guess Case:<br><img src="/images/spacer.gif" alt="" height="1" width="120"/></td>');
		document.writeln('              <td width="100%">');
		document.writeln('                <small><span id="autofix-mode-text-collapsed"></span></small></td>');
		document.writeln('              <td>&nbsp;</td>');
		document.writeln('              <td><a href="javascript:; // expand" onClick="afMenu.setExpanded(true)" title="Expand table"><img src="/images/plus.gif" width="13" height="13" alt="Expand Guess Case panel" border="0"></a></td>');
		document.writeln('            </tr>');
		document.writeln('          </table>');
		document.writeln('        </div>');
		document.writeln('        <div id="autofix-table-expanded" style="display: none">');
		document.writeln('          <table width="600" border="0" cellspacing="0" cellpadding="0">');
		document.writeln('            <tr valign="top">');
		document.writeln('              <td width="120" nowrap><b>Guess Case:<br><img src="/images/spacer.gif" alt="" height="1" width="120"/></td>');
		document.writeln('              <td width="100%" id="autofix-mode-cell">');
		document.writeln('                <table cellspacing="0" cellpadding="0" border="0" width="100%">');
		document.writeln('                  <tr valign="top">');
		document.writeln('                    <td width="10">');
		document.writeln('                      <select name="autofix-mode" onchange="afMenu.onAutoFixModeChanged(this)">');
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
		document.writeln('              <td width="10"><a href="javascript:; // collapse" onClick="afMenu.setExpanded(false)" title="Collapse table"><img src="/images/minus.gif" width="13" height="13" alt="Collapse Guess Case panel" border="0"></a></td>');
		document.writeln('            </tr>');

		afMenu.writeGUISpacer();
		afUndo.writeGUI();

		// write input fields resizer GUI
		afMenu.writeGUIRuler();
		document.writeln('            <tr valign="middle">');
		document.writeln('              <td nowrap><b>Input fields:</td>');
		document.writeln('              <td colspan="3">');
		document.writeln('                <a href="javascript: void(0); // make narrower" onClick="afFunc.resizeTextFields(-20)">Make narrower</a> | ');
		document.writeln('                <a href="javascript: void(0); // make wider" onClick="afFunc.resizeTextFields(20)">Make wider</a> | ');
		document.writeln('                <a href="javascript: void(0); // fit text" onClick="afFunc.resizeTextFields()">Try to fit text</a>');
		document.writeln('              </td>');
		document.writeln('            </tr>');

		// write utility functions GUI
		afMenu.writeGUIRuler();
		afQuickOps.writeGUI();

		// write search/replace GUI
		afMenu.writeGUIRuler();
		afFindReplace.writeGUI();

		// write trackparser GUI
		afMenu.writeGUIRuler();
		afTrackParser.writeGUI();

		document.writeln('          </table>');
		document.writeln('        </div>');

		this.updateAutoFixModeText(); // update description texts.

		// Show the table or not?
		if (fOpen == null) fOpen = getCookie(this.AF_COOKIE_TABLE);
		this.setExpanded(fOpen == "1");
	},


	// ----------------------------------------------------------------------------
	// writeButton()
	// -- write a guess case button to the document.
	writeButton : function(type, bid, bid2) {
		var theTitle = '';
		var theFunction = '';
		var theButtonText = 'Guess Case';
		switch (type) {
			case AF_BTN_ALIAS:
				theTitle = "Guess Artist Alias according to MusicBrainz Artist Name Guidelines";
				theFunction = 'doArtistName(this.form, \''+bid+'\')';
				break;
			case AF_BTN_ARTIST:
				theTitle = "Guess Artist Name according to MusicBrainz Artist Name Guidelines";
				theFunction = 'doArtistName(this.form, \''+bid+'\')';
				break;
			case AF_BTN_SORTGUESS:
				theButtonText = "Guess";
				theTitle = "Guess Sort Name from Artist Name field";
				theFunction = 'doSortNameGuess(this.form, \''+bid+'\', \''+bid2+'\')';
				break;
			case AF_BTN_SORTCOPY:
				theButtonText = "Copy";
				theTitle = "Copy Sort Name from Artist Name field";
				theFunction = 'doSortNameCopy(this.form, \''+bid+'\', \''+bid2+'\')';
				break;
			case AF_BTN_ALBUM:
				theTitle = "Guess Album Name according to Guess Case settings";
				theFunction = 'doAlbumName(this.form, \''+bid+'\')';
				break;
			case AF_BTN_TRACK:
				theTitle = "Guess Track Name according to Guess Case settings";
				theFunction = 'doTrackName(this.form, \''+bid+'\')';
				break;
			case AF_BTN_ALL:
				theTitle = bid;
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
	}
};
function af_writeGUI(fOpen) { afMenu.writeGUI(fOpen); }
function af_writeButton(type, bid, bid2) { afMenu.writeButton(type, bid, bid2); }
