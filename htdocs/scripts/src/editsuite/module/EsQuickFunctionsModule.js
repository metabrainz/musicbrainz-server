/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (keschte)              |
|-----------------------------------------------------------------------------|
| This software is provided "as is", without warranty of any kind, express or |
| implied, including  but not limited  to the warranties of  merchantability, |
| fitness for a particular purpose and noninfringement. In no event shall the |
| authors or  copyright  holders be  liable for any claim,  damages or  other |
| liability, whether  in an  action of  contract, tort  or otherwise, arising |
| from,  out of  or in  connection with  the software or  the  use  or  other |
| dealings in the software.                                                   |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt |
| Permits anyone the right to use and modify the software without limitations |
| as long as proper  credits are given  and the original  and modified source |
| code are included. Requires  that the final product, software derivate from |
| the original  source or any  software  utilizing a GPL  component, such  as |
| this, is also licensed under the GPL license.                               |
|                                                                             |
| $Id$
\----------------------------------------------------------------------------*/

/**
 * Quick functions module
 *
 */
function EsQuickFunctions() {
	mb.log.enter("EsQuickFunctions", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsQuickFunctions";
	this.GID = "es.qf";

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.qf"; };
	this.getModName = function() { return "Quick functions"; };

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	/* configuration checkbox */
	this.CFG_ENABLED = this.getModID()+".enabled";
	this.CONFIG_LIST = [
		new EsModuleConfig(this.CFG_ENABLED,
						 true,
			 			 "Enable the editor toolboxes",
		 				 "<img src=/images/es/tools.gif> This function adds icons to the right of the edit fields, which enable quick access to the most needed functions for the current field.")
	];

	/* list of operations */
	this.OP_UPPERCASE = 'QO_UPPERCASE';
	this.OP_LOWERCASE = 'QO_LOWERCASE';
	this.OP_TITLED = 'QO_TILED';
	this.OP_ADD_ROUNDBRACKETS = 'QO_ADD_ROUNDBRACKETS';
	this.OP_ADD_SQUAREBRACKETS = 'QO_ADD_SQUAREBRACKETS';
	this.OP_REM_ROUNDBRACKETS = 'QO_REM_ROUNDBRACKETS';
	this.OP_REM_SQUAREBRACKETS = 'QO_REM_SQUAREBRACKETS';
	this.OP_TB_GUESS = "QO_TB_GUESS";

	/* buttons */
	this.BTN_CAPITAL = "BTN_QF_CAPITAL";
	this.BTN_UPPER = "BTN_QF_UPPER";
	this.BTN_LOWER = "BTN_QF_LOWER";
	this.BTN_ADDROUNDBRACKETS = "BTN_QF_ADDROUNDBRACKETS";
	this.BTN_ADDSQUAREBRACKETS = "BTN_QF_ADDSQUAREBRACKETS";
	this.BTN_TB_GUESS = "BTN_TB_GUESS";

	/* stores the toolbox field which triggered the editortoolbox */
	this.tbFieldId = null;

	/* toolbox GC thingies */
	this.TB_GC_DROPDOWN = 'TB_GC_DROPDOWN';
	this.tbGuessCaseMode = null;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Override this method for initial configuration (register buttons etc.)
	 **/
	this.setupModuleDelegate =  function() {
		es.ui.registerButtons(
			new EsButton(this.BTN_CAPITAL, "Capital", "Capitalize first character only", this.getModID()+".runOp("+this.getModID()+".OP_TITLED)"),
			new EsButton(this.BTN_UPPER, "UPPER", "Convert characters to UPPERCASE", this.getModID()+".runOp("+this.getModID()+".OP_UPPERCASE)"),
			new EsButton(this.BTN_LOWER, "lower", "Convert characters to lowercase", this.getModID()+".runOp("+this.getModID()+".OP_LOWERCASE)"),
			new EsButton(this.BTN_ADDROUNDBRACKETS, "Add ()", "Add round parentheses () around selection", this.getModID()+".runOp("+this.getModID()+".OP_ADD_ROUNDBRACKETS)"),
			new EsButton(this.BTN_ADDSQUAREBRACKETS, "Add []", "Add square brackets [] around selection", this.getModID()+".runOp("+this.getModID()+".OP_ADD_SQUAREBRACKETS)"),
			new EsButton(this.BTN_TB_GUESS, "Guess", "Guess case using this method", this.getModID()+".onGuessCaseClicked()"));
	};

	/**
	 * Prepare code for this module.
	 *
	 * @returns raw html code
	 **/
	this.getModuleHtml = function() {
		var s = [];
		s.push(this.getModuleStartHtml({x: true}));
		s.push(es.ui.getButtonHtml(this.BTN_CAPITAL));
		s.push(es.ui.getButtonHtml(this.BTN_UPPER));
		s.push(es.ui.getButtonHtml(this.BTN_LOWER));
		s.push(es.ui.getButtonHtml(this.BTN_ADDROUNDBRACKETS));
		s.push(es.ui.getButtonHtml(this.BTN_ADDSQUAREBRACKETS));
		s.push('<br/><small>');
		s.push(this.getConfigHtml());
		s.push('</small>');
		s.push(this.getModuleEndHtml({x: true}));
		s.push(this.getModuleStartHtml({x: false, dt: 'Collapsed'}));
		s.push(this.getModuleEndHtml({x: false}));
		return s.join("");
	};

	/**
	 * Returns if the toolbox is enabled.
	 **/
	this.isToolboxEnabled = function() {
		return (this.isConfigTrue(this.CFG_ENABLED));
	};

	/**
	 * Insert EditToolbox popup link.
	 **/
	this.dummyCount = 0;
	this.addToolboxDummy = function(field) {
		mb.log.enter(this.GID, "addToolboxDummy");
		if (this.isToolboxEnabled()) {
			var id = field.name + "|et";
			var obj;
			if ((obj = mb.ui.get(id)) == null) {
				var a = document.createElement("a");
				a.className = "toolbox dummy";
				// cancel any clicks on the dummy.
				a.onclick = function onclick(event) { return false; }
				a.id = id;
				var img = document.createElement("img");
				a.appendChild(img);
				img.className = "toolbox dummy";
				img.src = "/images/es/toolsdummy.gif";
				img.alt = "";
				img.border = "0";
				var parent = field.parentNode;
				parent.insertBefore(a, field.nextSibling);
			}
		}
		mb.log.exit();
	};

	/**
	 * Insert EditToolbox popup link.
	 **/
	this.addToolboxIcon = function(field) {
		mb.log.enter(this.GID, "addToolboxIcon");
		if (this.isToolboxEnabled()) {
			var id = field.name + "|et";
			var obj;
			if ((obj = mb.ui.get(id)) == null) {
				var a = document.createElement("a");
				a.className = "toolbox";
				a.href="javascript:; // editor tools";
				a.onclick = function onclick(event) { return es.qf.onShowToolboxClicked(this); };
				a.id = id;
				a.title = "Click to access Toolbox";
				var img = document.createElement("img");
				a.appendChild(img);
				img.className = "toolbox";
				img.src = "/images/es/tools.gif";
				img.alt = "Click to access Toolbox";
				img.border = "0";

				var parent = field.parentNode;
				parent.insertBefore(a, field.nextSibling);
			}
		}
		mb.log.exit();
	};

	/**
	 * Returns a link for the Editor Toolbox UI
	 **/
	this.getToolboxLink = function(title, helpText, op) {
		var s = [];
		s.push('<a href="javascript: void(); // ');
		s.push(title);
		s.push('" ');
		s.push('onClick="return '+this.getModID()+'.onToolboxLinkClicked(\'');
		s.push(op);
		s.push('\');" ');
		s.push('title="'+helpText+'"');
		s.push('>'+title+'</a>');
		return s.join("");
	};

	/**
	 * Show the editor toolbox
	 **/
	this.onShowToolboxClicked = function(el) {
		mb.log.scopeStart("Handling click on show toolbox icon");
		mb.log.enter(this.GID, "onShowToolboxClicked");
		if (o3_showingsticky) {
			cClick();
		}
		this.showOverlib(el);
		mb.log.exit();
		mb.log.scopeEnd();
		return false; // return false for onclick handler
	};

	/**
	 * Configure overlib for the editor toolbox.
	 **/
	this.showOverlib = function(el) {
		ol_bgclass = "editor-toolbox-bg";
		ol_fgclass = "editor-toolbox-fg";
		ol_border = 0;
		ol_width = 300;
		ol_vauto = 1;
		ol_fgcolor = "#ffffff";
		ol_textsize = '11px';
		ol_closefontclass = 'editor-toolbox-close';
		ol_captionfontclass = 'editor-toolbox-caption';

		// get fieldname from trigger
		this.tbFieldId = el.id.split("|")[0];
		this.tbField = es.ui.getField(this.tbFieldId);
		this.tbField.focus(); // force focus to the current toolbox field.

		// show overlib
		overlib(this.getToolboxHtml(), STICKY, CLOSECLICK, CAPTION, 'Editor toolbox:');

		// store overlib x/y position and y position of the trigger
		this.tbBoxX = parseInt(over.style.left);
		this.tbBoxY = parseInt(over.style.top);
		this.tbFieldY = mb.ui.getOffsetTop(this.tbField);
		mb.log.debug("xy: $/$, field: $, y: $", this.tbBoxX, this.tbBoxY, this.tbField.name, this.tbFieldY);
	};

	/**
	 * Show the editor toolbox
	 **/
	this.updateToolbox = function(el) {
		mb.log.enter(this.GID, "updateToolbox");
		if (o3_showingsticky) {
			this.tbFieldId = el.name; // get name of textfield
			this.tbField = el; // store reference to the textfield

			var newFieldY = mb.ui.getOffsetTop(el);
			var newY = this.tbBoxY + (newFieldY-this.tbFieldY);

			mb.log.debug("xy: $/$, field: $, y: $", this.tbBoxX, this.tbBoxY, this.tbField.name, this.tbFieldY);
			mb.log.debug("newY: $, xy: $/$", newFieldY, this.tbBoxX, newY);
			repositionTo(over, this.tbBoxX, newY); // move overlib
		}
		mb.log.exit();
	};

	/**
	 * Handle event of the GuessCase Mode dropdown
	 * of the Editor Toolbox.
	 **/
	this.onModeChanged = function(el) {
		mb.log.scopeStart("Handling change of GC dropdown");
		mb.log.enter(this.GID, "onModeChanged");
		if (el && el.options &&
		   (el.id == this.TB_GC_DROPDOWN)) {
			var modeID = el.options[el.selectedIndex].value;
			var m;
			if ((m = gc.modes.getModeFromID(modeID, true)) != null) {
				this.tbGuessCaseMode = m;
				mb.log.debug('Set mode: $', m);
			} else {
				mb.log.warning('Unknown modeID given: $', modeID);
			}
		} else {
			mb.log.error("Unsupported element: $", (el.name || "?"));
		}
		mb.log.exit();
		mb.log.scopeEnd();
	};

	/**
	 * Handling click on GuessCase button
	 **/
	this.onGuessCaseClicked = function() {
		mb.log.enter(this.GID, "onGuessCaseClicked");
		var f;
		if ((f = es.ui.getField(this.tbFieldId)) != null) {
			es.guessByFieldName(f.name, this.tbGuessCaseMode);
		}
		mb.log.exit();
	};

	/**
	 * Returns the HTML for Editor Toolbox.
	 **/
	this.getToolboxHtml = function() {
		var t = 'Convert all characters of the selection/field to ';
		var s = [];
		var sep = " | ";
		var row  		= '<tr class"row"><td class="label">';
		var rowspacer	= '<tr class="row-spacer"><td class="label">';
		var rowvalue  	= '</td><td class="text">';
		var rowend    	= '</td></tr>';

		s.push('<table border="0" class="editortoolbox">');
		s.push(row);
		s.push('Guess case:');
		s.push(rowvalue);
		this.tbGuessCaseMode = (this.tbGuessCaseMode || gc.getMode());
		s.push(gc.modes.getDropdownHtml(this.TB_GC_DROPDOWN, this.GID, this.tbGuessCaseMode));
		s.push(es.ui.getButtonHtml(this.BTN_TB_GUESS));
		s.push(rowend);

		s.push(rowspacer);
		s.push('Modify case:');
		s.push(rowvalue);
		s.push(this.getToolboxLink('Titled', t+'lowercase but the first', this.OP_TITLED));
		s.push(sep);
		s.push(this.getToolboxLink('Uppercase', t+'UPPERCASE', this.OP_UPPERCASE));
		s.push(sep);
		s.push(this.getToolboxLink('Lowercase', t+'lowercase', this.OP_LOWERCASE));
		s.push(rowend);

		s.push(rowspacer);
		s.push('Brackets:');
		s.push(rowvalue);
		s.push(this.getToolboxLink('Add ()', 'Add round parentheses () to selection/field', this.OP_ADD_ROUNDBRACKETS));
		s.push(sep);
		s.push(this.getToolboxLink('Add []', 'Add square brackets [] to selection/field', this.OP_ADD_SQUAREBRACKETS));
		s.push(sep);
		s.push(this.getToolboxLink('Rem ()', 'Remove round parentheses () from selection/field', this.OP_REM_ROUNDBRACKETS));
		s.push(sep);
		s.push(this.getToolboxLink('Rem []', 'Remove square brackets [] from selection/field', this.OP_REM_SQUAREBRACKETS));
		s.push(rowend);

		s.push(rowspacer);
		s.push('Undo/Redo:');
		s.push(rowvalue);
		s.push('<a href="javascript:; // Undo" title="Undo the last change (Attention: Not only the selected field)" onFocus="this.blur()" onClick="es.ur.undoStep(); return false;">Undo</a>');
		s.push(sep);
		s.push('<a href="javascript:; // Redo" title="Redo the last undo step (Attention: Not only the selected field)" onFocus="this.blur()" onClick="es.ur.redoStep(); return false;">Redo</a>');
		s.push(rowend);

		s.push('</table>');
		return s.join("");
	};

	/**
	 * Handles a click on the editor toolbox
	 **/
	this.onToolboxLinkClicked = function(op) {
		mb.log.scopeStart("Handling click on toolbox link");
		mb.log.enter(this.GID, "onToolboxLinkClicked");
		mb.log.info("el: $", this.tbFieldId);
		var f;
		if ((f = es.ui.getField(this.tbFieldId)) != null) {
			this.runOp(op, f);
		}
		mb.log.exit();
		mb.log.scopeEnd();
		// cClick(); // close toolbox
		return false;
	};

	/**
	 * applies the current operation to the selected text
	 *    in the field the cursor was last placed in.
	 * djce suggested, that the method should work on the full text of the
	 * 	  field the cursor is currently placed in if nothing is selected
	 * adapted code from: http://www.quirksmode.org/js/selected.html
	 * 	  http://www.scriptygoddess.com/archives/2004/06/08/mozilla-and-ie-decoder
	 * IE document.selection object API: http://www.html-world.de/program/js_o_sel.php
	 **/
	this.runOp = function(op, f) {
		mb.log.enter(this.GID, "runOp");
		// if no field is given, use focussed field.
		if (!f) {
			f = es.ui.getFocusField();
		}
		if (f != null) {
			var ov = f.value, nv = ov;
			mb.log.info("Applying op: $", op);

			var isMOZ = false, isIE = (typeof document.selection != 'undefined');
			if (!isIE) {
				f.focus();
				isMOZ = (typeof f.selectionStart != 'undefined');
			}
			if (isIE || isMOZ) {
				// see what source string we're looking at
				var ft = f.value;
				var a,r,rs,re;
				if (isIE) {
					try {
						r = document.selection.createRange();
						a = (r.text != "" ? r.text : ft);
					} catch (e) {
						mb.log.error("could not get range!");
					}
				} else if (isMOZ) {
					rs = f.selectionStart; // store selection start (is 0 if none)
					re = f.selectionEnd; // store selection start (is 0 if none)
					a = (rs == re ? ft : ft.substring(rs, re));
				}
				mb.log.info("Operating on "+(a == ft ? "full text" : "range")+": $", a);

				// run the operation
				var b=a;
				switch (op) {
					case this.OP_UPPERCASE:
					case this.OP_LOWERCASE:
					case this.OP_TITLED:
						b = this.formatText(a, op);
						break;
					case this.OP_ADD_ROUNDBRACKETS:
						b = "("+a+")";
						break;
					case this.OP_ADD_SQUAREBRACKETS:
						b = "["+a+"]";
						break;
					case this.OP_REM_ROUNDBRACKETS:
						b = b.replace(/\(|\)/g, "");
						break;
					case this.OP_REM_SQUAREBRACKETS:
						b = b.replace(/\[|\]/g, "");
						break;
				}

				// apply the result of the operation
				if (a == ft) {
					f.value = b; // text was fulltext, apply value
				} else if (isIE) {
					r.text = b; // IE: apply result to range
				} else if (isMOZ) {
					var s = []; // MOZILLA: set result to substring
					s.push(ft.substring(0, rs));
					s.push(b);
					s.push(ft.substring(re, ft.length));
					f.value = s.join(""); // set field value.
					f.selectionStart = rs;
					f.selectionEnd = rs + b.length; // set range to start+replacestring length
				}
				nv = f.value;
				if (nv != ov) {
					es.ur.addUndo(es.ur.createItem(f, 'runOp', ov, nv));
					mb.log.info("New value: $", nv);
				}
			}
		}
		mb.log.exit();
	};

	/**
	 * Returns the text formatted depending on the op parameter
	 **/
	this.formatText = function(fText, op) {
		if (op == this.OP_UPPERCASE) {
			fText = fText.toUpperCase();
		}
		if (op == this.OP_LOWERCASE) {
			fText = fText.toLowerCase();
		}
		if (op == this.OP_TITLED) {
			fText = fText.toLowerCase();
			var tArr = fText.split("");
			tArr[0] = tArr[0].toUpperCase();
			fText = tArr.join("");
		}
		return fText;
	};

	// exit constructor
	mb.log.exit();
}

// register prototype of module superclass
try {
	EsQuickFunctions.prototype = new EsModuleBase;
} catch (e) {
	mb.log.error("EsQuickFunctions: Could not register EsModuleBase prototype");
}