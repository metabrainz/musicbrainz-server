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
 * Edit Note Resizer
 *
 * Resize TextArea based on the amount of text (soft and hard wraps)
 * inspired by: http://tuckey.org/textareasizer
 */
function EsModNoteModule() {
	mb.log.enter("EsModNoteModule", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsModNoteModule";
	this.GID = "es.modnote";

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.modnote"; };
	this.getModName = function() { return "Edit note resizer"; };

	/** reference of the notetext obj **/
	this.el = null;
	this.busy = false;
	this.rows = 0;
	this.minrows = 3;
	this.disabled = false;

	/** RegExp to split the text into lines **/
	this.splitRE = /\r\n|\r|\n/g; // compile only once
	this.whitespaceRE = /\s/g;
	this.defaultText = "Please enter an edit note here. Thank you";
	this.title = "We'd like to know where you got the information from, and why you are attempting to edit this data...\nThank you";
	this.checkedText = "";

	/**
	 * Anonymous handler function which gets
	 * called when an event on the textarea
	 * occurs that requires recalculation of the rows.
	 */
	this.runCheck = function() {
		mb.log.enter(this.GID, "runCheck");
		if (this.disabled) {
			return mb.log.exit();
		}
		var el;
		if ((el = this.el) == null) {
			es.modnote.disabled = true;
			if ((el = mb.ui.get("notetext")) != null) {
				// only add handlers if there is a "notetext"
				// element in the DOM-tree
				mb.log.debug("Setting up event handlers...");
				var func = function(event) {
					es.modnote.handleEvent(event);
				};
				el.title = this.title;
				el.onblur = func;    // register every possible
				el.onfocus = func;   // event hander such that
				el.onchange = func;  // the check happens on copy+paste,
				el.onkeyup = func;   // page resize and regular typing
				el.onkeydown = func; // in the textarea. (duplicate checks
				// el.onresize = func;  // with same values are skpped)

				// register element
				if (mb.utils.isNullOrEmpty(el.value)) {
					el.value = this.defaultText;
					this.recalc(el);
				}
				this.el = el;

				// register forms submit event, which will
				// clear the modnote if it's the default text.
				el.form.onsubmit = function(event) {
					es.modnote.handleEvent("submit-check");
					return true;
				};
			}
			es.modnote.disabled = false;

		} else if (!this.busy) {
			this.busy = true;
			mb.log.debug("Busy: $", this.busy);
			if (!this.isSameText(this.checkedText)) {
				this.recalc(el);
				mb.log.debug("Wraps: $, Rows: $", this.rows, el.rows);
				mb.log.debug("Text: $", this.checkedText);
			} else {
				mb.log.debug("Text has not changed...");
			}
			this.busy = false;
		}
		return mb.log.exit();
	};
	mb.registerDOMReadyAction(new MbEventAction(this.GID, "runCheck", "Setting up editnote area resizer"));


	/**
	 * Handle a registered event on the TEXTAREA.
	 *
	 * @param	e		the Event being handled currently
	 */
	this.handleEvent = function(e) {
		mb.log.enter(this.GID, "handleEvent");
		e = (e || window.event);
		mb.log.info("Handling event: $", (e.type || e));
		if (!this.disabled) {
			// test the values from the title, and the text
			// without whitespace, should be equal upon
			// first focus of the field. (if it wasn't set
			// properly, clear it anyway).
			this.isSameText(this.defaultText, true);
			this.runCheck();
			mb.log.info("Event handled!");
			return mb.log.exit(true);
		} else {
			mb.log.warning("Event handling disabled!");
			return mb.log.exit(false);
		}
	};

	/**
	 * Check the value of the textarea against the default text
	 * and clear it if necessary.
	 *
	 * @param	text	the text to test the current value against
	 * @param	reset	if true, the text of the TEXTAREA is cleared
	 *					(e.g. on first focus of the field, if the default
	 *					 help text is displayed)
	 */
	this.isSameText = function(text, reset) {
		mb.log.enter(this.GID, "isSameText");
		var el;
		if ((el = this.el) != null) {
			if ((el.value.replace(this.whitespaceRE, "")) ==
				(text.replace(this.whitespaceRE, ""))) {
				if (reset) {
					this.disabled = true;
					el.value = "";
					this.disabled = false;
					mb.log.warning("Cleared default text...");
				}
				return mb.log.exit(true);
			}
		}
		return mb.log.exit(false);
	};

	/**
	 * Recalculate the number of rows the text wants to take up
	 * @param strText  	the current text of the textarea
	 * @param cols  	the cols="x" property of the textarea
	 * @returns 		the number of rows the text in the
	 *					textarea occupies currently
	 */
	this.recalc = function(el) {
		mb.log.enter(this.GID, "recalc");
		if (el) {
			var t = el.value, c = el.cols;
			if (t != null && c != null) {
				var lines = t.split(this.splitRE);
				var len;
				this.rows = 1 + lines.length;
				for (var i=0; i<lines.length; i++) {
					// iterate through all the lines and see
					// if we have to add virtual linewraps
					if ((len = lines[i].length) > c) {
						this.rows += Math.floor(len*parseFloat(1/c));
					}
				}
				this.rows = (this.rows < this.minrows ? this.minrows : this.rows) + (mb.ua.gecko ? -1 : 0);
				// subtract one row for gecko browsers, because
				// they render one to many if set by JS compared
				// to IE and opera.
				el.rows = this.rows;
				mb.log.debug("Setting rows: $", this.rows);
				this.checkedText = t;
			} else {
				mb.log.error("Did not find text: $, or cols: $", t || "?", c || "?");
			}
		} else {
			mb.log.error("Element el is null!");
		}
		mb.log.exit();
	};

	// exit constructor
	mb.log.exit();
}
