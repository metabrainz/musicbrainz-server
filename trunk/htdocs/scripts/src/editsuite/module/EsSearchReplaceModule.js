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
 * Search/Replace module
 *
 */
function EsSearchReplace() {
	mb.log.enter("EsSearchReplace", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsSearchReplace";
	this.GID = "es.sr";

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.sr"; };
	this.getModName = function() { return "Search/Replace"; };

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	// button identifiers
	this.BTN_SEARCH 	= "BTN_SR_SEARCH";
	this.BTN_REPLACE 	= "BTN_SR_REPLACE";
	this.BTN_LOADPRESET = "BTN_SR_LOADPRESET";
	this.BTN_SWAP 		= "BTN_SR_SWAP";
	this.BTN_RESET 		= "BTN_SR_CLEAR";

	// fieldnames
	this.FIELD_SEARCH		= this.getModID() +".search";
	this.FIELD_REPLACE		= this.getModID() +".replace";
	this.FIELD_REGEX		= this.getModID() +".regex";
	this.FIELD_AUTOAPPLY	= this.getModID() +".autoapply";
	this.FIELD_MATCHCASE	= this.getModID() +".matchcase";
	this.FIELD_ALLFIELDS	= this.getModID() +".allfields";

	// search/replace presets
	this.PRESETS_LIST = [
		["Remove all round parentheses ()", "\\(|\\)", "", 1],
		["Remove all square brackets []", "\\[|\\]", "", 1],
		["Remove all curly braces {}", "\\{|\\}", "", 1],
		["Remove all bracketing punctuation ()[]{}", "\\(|\\)|\\[|\\]|\\{|\\}", "", 1],
		["Replace [] with ()", "\\[([^\\]]*)\\]", "($1)", 1],
		["Replace () with []", "\\(([^\\)]*)\\)", "[$1]", 1],
		["Replace #1 with No. 1 for any number", "#(\\d*)", "No. $1", 1]
	];

	// name of cookie value for the preset expanded/collapsed setting
	this.COOKIE_PRESETEXPANDED = "SR_COOKIE_PRESETEXPANDED";


	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	this.setupModuleDelegate =  function() {
		es.ui.registerButtons(
			new EsButton(this.BTN_SEARCH, "Search", "", this.getModID()+".onSearchClicked()"),
			new EsButton(this.BTN_REPLACE, "Replace", "", this.getModID()+".onReplaceClicked()"),
			new EsButton(this.BTN_SWAP, "Swap fields", "", this.getModID()+".onSwapFieldsClicked()"),
			new EsButton(this.BTN_RESET, "Reset", "", this.getModID()+".onResetFieldsClicked()"));
	};

	/**
	 * Prepare code for this module.
	 *
	 * @returns raw html code
	 **/
	this.getModuleHtml = function() {
		var s = [];
		s.push(this.getModuleStartHtml({x: true}));
		s.push('<table cellspacing="0" cellpadding="0" border="0" class="moduletable">');
		s.push('<tr>');
		s.push('<td>Search: &nbsp;</td>');
		s.push('<td><input type="input" class="srfield" size="30" tabindex="500" value="" name="'+this.FIELD_SEARCH+'">&nbsp;');
		s.push(es.ui.getButtonHtml(this.BTN_SWAP));
		s.push(es.ui.getButtonHtml(this.BTN_RESET));
		s.push('</td>');
		s.push('</tr>');
		s.push('<tr>');
		s.push('<td>Replace: &nbsp;</td>');
		s.push('<td><input type="input" class="srfield" size="30" tabindex="501" value="" name="'+this.FIELD_REPLACE+'"></td>');
		s.push('</tr>');
		s.push('<tr>');
		s.push('<td></td>');
		s.push('<td>');
		s.push(es.ui.getButtonHtml(this.BTN_SEARCH)); // not implemented yet.
		s.push(es.ui.getButtonHtml(this.BTN_REPLACE));
		s.push('<input type="button" value="Show/hide presets" onclick="'+this.getModID()+'.onShowPresetsClicked(this, event)" />');
		s.push('<br/>');
		s.push('<input type="hidden" name="'+this.FIELD_AUTOAPPLY+'" value="1">');
		s.push('<input type="checkbox" name="'+this.FIELD_REGEX+'" value="true"><small>Regular expression</small>');
		s.push('<input type="checkbox" name="'+this.FIELD_MATCHCASE+'" value="true"><small>Match case</small>');
		s.push('<input type="checkbox" name="'+this.FIELD_ALLFIELDS+'" value="true" checked><small>For all fields</small>');
		s.push('</tr>');
		s.push('</table>');
		s.push(this.getModuleEndHtml({x: true}));
		s.push(this.getModuleStartHtml({x: false, dt: 'Collapsed'}));
		s.push(this.getModuleEndHtml({x: false}));
		return s.join("");
	};


	/**
	 * Creates the presets div.
	 **/
	this.getPresetsHtml = function() {
		var s = [];
		s.push('<table id="srPresetsTable" border="0" cellpadding="0" cellspacing="0" class="moduletable">');
		s.push('<tr>');
		s.push('<td><b>Description</b> &nbsp;</td>');
		s.push('<td><img src="/images/spacer.gif" alt="" width="10" height="1"></td>');
		s.push('<td><b>Search</b> &nbsp;</td>');
		s.push('<td><img src="/images/spacer.gif" alt="" width="10" height="1"></td>');
		s.push('<td nowrap><b>Replace</b> &nbsp;</td>');
		s.push('<td nowrap><b>Regex</b> &nbsp;</td>');
		s.push('</tr>');
		for (var i=0; i<this.PRESETS_LIST.length; i++) {
			var p = this.PRESETS_LIST[i];
			if (i==0) {
				s.push('<tr class="editsuite-box-tr">');
			} else {
				s.push('<tr>');
			}
			s.push('<td nowrap><a href="javascript: // select preset" onClick="'+this.getModID()+'.onSelectPresetClicked('+i+')">');
			s.push('<b>&middot;</b>&nbsp;'+(p[0])+'</td>');
			s.push('<td/>');
			s.push('<td nowrap>'+(p[1])+'</td>');
			s.push('<td/>');
			s.push('<td nowrap>'+(p[2])+'</td>');
			s.push('<td>'+(p[3] == 1 ? 'Yes' : 'No')+'</td>');
			s.push('</tr>');
		}
		s.push('<tr class="editsuite-box-tr">');
		s.push('<td colspan="6"><input type="checkbox" ');
		s.push('name="srApplyPreset" value="on" ');
		s.push(this.getPresetChooseApply() ? "checked" : "");
		s.push('onClick="'+this.getModID()+'.onPresetChooseApplyChanged(this.checked)">Execute Search & Replace when selected.</td>');
		s.push('</tr>');
		s.push('</table>');
		var t = s.join("");
		return t;
	};

	/**
	 * onShowPresetsClicked()
	 * -- Is called from the ">> Load Preset" button
	 *   reference to the form is saved for later use.
	 **/
	this.onShowPresetsClicked = function(src, ev) {
		ev = new MochiKit.Signal.Event(src, ev);
		if (!mb.popup.isVisible()) {
			// show presets popup
			mb.popup.show(ev.mouse().page, this.getPresetsHtml(), 'Search/Replace Presets:', {
				'bgclass': 'sr-presets-bg',
				'fgclass': 'sr-presets-fg',
				'captionfontclass': 'sr-presets-caption',
				'closefontclass': 'sr-presets-close'
			});
		} else {
			// close presets popup
			mb.popup.hide();
		}
	};

	/**
	 * onSwapFieldsClicked()
	 * -- swaps the contents of the search and the replace field.
	 */
	this.onSwapFieldsClicked = function() {
		mb.log.enter(this.GID, "onSwapFieldsClicked");
		var fs, fr;
		if ((fs = es.ui.getField(this.FIELD_SEARCH)) != null &&
			(fr = es.ui.getField(this.FIELD_REPLACE)) != null) {
			var temp = fs.value;
			fs.value = fr.value;
			fr.value = temp;
		} else {
			mb.log.error('One of the fields $,$ not found!', this.FIELD_SEARCH, this.FIELD_REPLACE);
		}
		mb.log.exit();
	};

	/**
	 * Resets the contents of the search and replace field.
	 **/
	this.onResetFieldsClicked = function() {
		mb.log.enter(this.GID, "onResetFieldsClicked");
		var fs, fr;
		if ((fs = es.ui.getField(this.FIELD_SEARCH)) != null &&
			(fr = es.ui.getField(this.FIELD_REPLACE)) != null) {
			fs.value = "";
			fr.value = "";
		} else {
			mb.log.error('One of the fields $,$ not found!', this.FIELD_SEARCH, this.FIELD_REPLACE);
		}
		mb.log.exit();
	};

	/**
	 * Is called from the "Use" links. The index refers to the offset in
	 * the srPresets array which was selected. If the srApplyPreset
	 * checkbox is checked, the function is executed immediately.
	 **/
	this.onSelectPresetClicked = function(index) {
		mb.log.enter(this.GID, "onResetFieldsClicked");
		var fs, fr, freg, faa;
		if ((fs = es.ui.getField(this.FIELD_SEARCH)) != null &&
			(fr = es.ui.getField(this.FIELD_REPLACE)) != null &&
			(freg = es.ui.getField(this.FIELD_REGEX)) != null &&
			(faa = es.ui.getField(this.FIELD_AUTOAPPLY)) != null) {
			var p = this.PRESETS_LIST[index];
			if (p) {
				fs.value = p[1];
				fr.value = p[2];
				freg.checked = (p[3]==1);
				mb.log.info('Preset $ selected', p[0]);
			}
			if (faa.value == "1") {
				this.onReplaceClicked();
			}
		} else {
			mb.log.error('One of the fields not found!');
		}
		mb.log.exit();
	};

	/**
	 * Checks if the user wants to work on all fields
	 * or the currently focussed. Respects the configuration flags
	 **/
	this.onPresetChooseApplyChanged = function(flag) {
		var faa;
		if ((faa = es.ui.getField(this.FIELD_AUTOAPPLY)) != null) {
			faa.value = (flag ? "1" : "0");
		} else {
			mb.log.error('Field $ not found!', this.FIELD_AUTOAPPLY);
		}
	};

	/**
	 * Returns the value of the hidden field which stores
	 * if a preset should be directly applied after it is selected
	 **/
	this.getPresetChooseApply = function() {
		var faa;
		if ((faa = es.ui.getField(this.FIELD_AUTOAPPLY)) != null) {
			return (faa.value == "1");
		} else {
			mb.log.error('Field $ not found!', this.FIELD_AUTOAPPLY);
		}
		return false;
	};

	/**
	 * Handle a click on the "search" button.
	 **/
	this.onSearchClicked = function() {
		mb.log.enter(this.GID, "onSearchClicked");
		this.handleSearch("search");
		mb.log.exit();
	};

	/**
	 * Handle a click on the "replace" button.
	 **/
	this.onReplaceClicked = function() {
		mb.log.enter(this.GID, "onReplaceClicked");
		this.handleSearch("replace");
		mb.log.exit();
	}

	/**
	 * Checks if the user wants to work on all fields
	 * or the currently focussed. Respects the configuration flags
	 **/
	this.handleSearch = function(op) {
		mb.log.enter(this.GID, "handleSearch");
		var fs,fr,freg,fmc,faf;
		if ((fs = es.ui.getField(this.FIELD_SEARCH)) != null &&
			(fr = es.ui.getField(this.FIELD_REPLACE)) != null &&
			(freg = es.ui.getField(this.FIELD_REGEX)) != null &&
			(fmc = es.ui.getField(this.FIELD_MATCHCASE)) != null &&
			(faf = es.ui.getField(this.FIELD_ALLFIELDS)) != null) {
			var sv = fs.value;
			var rv = fr.value;
			if (sv == "") {
				mb.log.warning('Search is empty, aborting.');
				return;
			}

			// if work on all fields
			var f;
			if (faf.checked) {
				var fields = es.ui.getEditTextFields();
				for (var i=0; i<fields.length; i++) {
					f = fields[i];
					this.handleField(f, sv, rv, fmc.checked, freg.checked, op);
				}
			} else if ((f = es.ui.getFocusField()) != null) {
				// if work on focussed field
				this.handleField(f, sv, rv, fmc.checked, freg.checked, op);
			}
		} else {
			mb.log.error('One of the fields not found!');
		}
		mb.log.exit();
	};

	/**
	 * Creates a regular expression from the contents of the srSearch field,
	 * and, depending of the given "op", search/replace the occurences
	 * in the current field.
	 **/
	this.handleField = function(f, searchValue, replaceValue, useCase, useRegex, op) {
		mb.log.enter(this.GID, "handleField");
		if (f) {

			// remove old search result.
			var obj, resultElemID = f.name+"::result";
			try {
				if ((obj = mb.ui.get(resultElemID)) != null) {
					obj.parentNode.removeChild(obj);
				}
			} catch (e) { /* steam ahead ;) */ }

			var currentValue = f.value;
			var newValue = currentValue;
			var newList = [];
			mb.log.debug('Current: $', currentValue);
			mb.log.debug('Search: $, Replace: $', searchValue, replaceValue);
			mb.log.debug('Flags: Case Sensitive: $, Regex: $', useCase, useRegex);
			if (useRegex) {
				try {
					var re = new RegExp(searchValue, "g"+(useCase ? "":"i"));
					newValue = currentValue.replace(re, replaceValue);
				} catch (e) {
					mb.log.error('Caught error while trying to Match re: $, e: $', re, e);
				}
			} else {
				// use indexOf(needle, lastPos) to prevent endless loops.
				var pos = -1, lastpos = 0;
				var replaced = new Array();
				var needle = (useCase ? searchValue : searchValue.toLowerCase());
				var before = "", after = "", inbetween = "";
				while ((pos = (useCase ? newValue : newValue.toLowerCase()).indexOf(needle, lastpos)) != -1) {

					// replace searchValue with replaceValue.
					before = newValue.substring(0, pos);
					after = newValue.substring(pos + searchValue.length, newValue.length);
					inbetween = newValue.substring(lastpos, pos);

					// replace substring in newValue.
					var s = [];
					s.push(before);
					s.push(replaceValue);
					s.push(after);
					newValue = s.join("");

					// save position that matched.
					replaced.push(pos);
					newList.push(inbetween);
					newList.push(searchValue);

					// prevent possible case like:
					// S: "Test ."
					// R: ".." will append replace a stop character
					// at position 7, but since at 8 there will be another
					// one this will result in an endless loop.
					// Skip to the end of the replaced string to search for further
					// occurences to replace.
					lastpos = pos + replaceValue.length;
				}

				if (replaced.length < 1) {
					mb.log.debug('Search value $ was not found', searchValue);
				} else {
					mb.log.debug('Search value $ replaced with $ at index [$]',
						searchValue, replaceValue, replaced.join(","));
					newList.push(after);
				}
			}
			if (newValue != currentValue) {
				mb.log.debug('New value $', newValue);
				if (op == "replace") {
					es.ur.addUndo(es.ur.createItem(f, 'searchreplace', currentValue, newValue));
					f.value = newValue;
				} else {
					var parentNode = f.parentNode;
					var result = document.createElement("div");
					result.id = resultElemID;
					result.style.border = "1px dotted #999";
					result.style.borderTop = "none";
					result.style.padding = "2px";
					result.style.marginBottom = "5px";
					result.style.marginRight = "18px";
					result.style.fontSize = "10px";
					var s = [];
					for (var i=0; i<newList.length; i++) {
						var w = newList[i];
						s.push(w == searchValue ? '<span style="background-color: #fc5">'+w+'</span>': w);
					}
					result.innerHTML = s.join("");
					parentNode.appendChild(result);

					// make sure the TR aligns to top.
					parentNode.parentNode.style.verticalAlign = "top";
				}
				return mb.log.exit(true);
			}
		}
		return mb.log.exit(false);
	};

	// exit constructor
	mb.log.exit();
}

// register prototype of module superclass
try {
	EsSearchReplace.prototype = new EsModuleBase;
} catch (e) {
	mb.log.error("EsSearchReplace: Could not register EsModuleBase prototype");
}