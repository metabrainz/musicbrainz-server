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
 * Field Resizer module
 *
 **/
function EsFieldResizer() {
	mb.log.enter("EsFieldResizer", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsFieldResizer";
	this.GID = "es.fr";

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.fr"; };
	this.getModName = function() { return "Field resizer"; };

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	/* configuration checkbox */
	this.CFG_REMEMBERSIZE = this.getModID()+".remembersize";
	this.CFG_AUTORESIZE = this.getModID()+".autoresize";
	this.CONFIG_LIST = [
		new EsModuleConfig(this.CFG_REMEMBERSIZE,
						 false,
			 			 "Remember the size of the fields",
		 				 "Always resize the input fields to the preferred size."),
		new EsModuleConfig(this.CFG_AUTORESIZE,
						 true,
			 			 "Automatically resize fields to fit the text",
		 				 "Resize the input fields such that the longest text fits the field without scrolling")

	];

	/* buttons */
	this.BTN_NARROWER 	= "BTN_FR_NARROWER";
	this.BTN_WIDER 		= "BTN_FR_WIDER";
	this.BTN_GUESSSIZE	= "BTN_FR_GUESSSIZE";

	/* cookie definitions */
	this.COOKIE_SIZE	= this.getModID()+".size";

	this.currentWidth	= es.ui.TEXTFIELD_SIZE;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Override this method for initial configuration (register buttons etc.)
	 **/
	this.setupModuleDelegate =  function() {
		es.ui.registerButtons(
			new EsButton(this.BTN_NARROWER, "Make narrower", "Make input fields 25px smaller", this.getModID()+".onSetSizeClicked(-25)"),
			new EsButton(this.BTN_WIDER, "Make wider", "Make input fields 25px wider", this.getModID()+".onSetSizeClicked(+25)"),
			new EsButton(this.BTN_GUESSSIZE, "Try to fit text", "Set the size of the fields to the size of the longest value", this.getModID()+".onSetSizeClicked()"));
	};

	/**
	 * Returns the html code for this module
	 **/
	this.getModuleHtml = function() {
		var s = [];
		s.push(this.getModuleStartHtml({x: true}));
		s.push(es.ui.getButtonHtml(this.BTN_NARROWER));
		s.push(es.ui.getButtonHtml(this.BTN_WIDER));
		s.push(es.ui.getButtonHtml(this.BTN_GUESSSIZE));
		s.push('<br/><small>');
		s.push(this.getConfigHtml());
		s.push('</small>');
		s.push(this.getModuleEndHtml({x: true}));
		s.push(this.getModuleStartHtml({x: false, dt: 'Collapsed'}));
		s.push(this.getModuleEndHtml({x: false}));

		// register form-resize action
		return s.join("");
	};

	/**
	 *
	 **/
	this.onModuleHtmlWrittenDelegate = function() {
		if (this.isConfigTrue(this.CFG_AUTORESIZE) ||
			this.isConfigTrue(this.CFG_REMEMBERSIZE)) {
			mb.registerDOMReadyAction(new MbEventAction(this.GID, "onSetRememberedSize", "Setting remembered fieldsize"));
		}
	};

	/**
	 * Add/remove amount from size attribute on edit fields in the form.
	 * CFG_AUTORESIZE takes precedence over the CFG_REMEMBERSIZE flag
	 **/
	this.onSetRememberedSize = function() {
		mb.log.enter(this.GID, "onSetRememberedSize");
		if (this.isConfigTrue(this.CFG_AUTORESIZE)) {
			this.setSize();
		} else if (this.isConfigTrue(this.CFG_REMEMBERSIZE)) {
			var cv = mb.cookie.get(this.COOKIE_SIZE); // get size from cookie.
			if ((cv || "").match(/px/i)) {
				mb.log.debug("Found size in cookie: $", cv);
				this.setSize(cv);
			} else {
				mb.log.debug("No cookie value found...");
			}
		}
		mb.log.exit();
	};

	/**
	 * Add/remove amount from size attribute on edit fields in the form.
	 **/
	this.onSetSizeClicked = function(amount) {
		mb.log.enter(this.GID, "onSetSizeClicked");
		this.setSize(amount);
		mb.log.exit();
	};

	/**
	 * Add/remove amount from size attribute on edit fields in the form.
	 **/
	this.setSize = function(amount) {
		mb.log.enter(this.GID, "setSize");
		var cn, w, nw, i, f, fields = es.ui.getResizableFields();
		if (mb.utils.isString(amount) && amount.match(/px/i)) {
			// value is 99em (a css width)
			mb.log.debug("Setting field size to: $", amount);
			for (i=0; i<fields.length; i++) {
				f = fields[i];
				if ((this.getWidth(f)) != null) {
					f.style.width = amount;
				}
			}
			this.currentWidth = nw;

		} else if (mb.utils.isNumber(amount)) {
			// value is a number (add/subtract from current size)
			mb.log.info((amount > 0 ? "Adding $ to size" : "Removing $ from size"), Math.abs(amount));
			var cookieSet = false;
			for (i=0; i<fields.length; i++) {
				f = fields[i];
				if ((nw = this.getWidth(f, amount)) != null) {
					mb.log.debug("Setting field: $ to width: $", f.name, nw);
					f.style.width = nw;
					if (!cookieSet) {
						mb.cookie.set(this.COOKIE_SIZE, nw);
						cookieSet = true;
					}
				} else {
					mb.log.warning("Field $ does not define width!");
				}
			}
			this.currentWidth = nw;

		} else {
			// examine the length of the fields, and set the size of
			// the fields such that the longest text is displayed
			// in it's full size.
			var maxlen = 0, fl = 0;
			for (i=0; i<fields.length; i++) {
				f = fields[i];
				cn = (f.className || "");
				if (!cn.match(/hidden/)) {
					if (f.value) {
						if ((fl = f.value.length) > maxlen) {
							maxlen = fl;
						}
						mb.log.debug("Checked field: $, length: $", f.name, fl);
					}
				}
			}
			var deflen = parseInt(es.ui.TEXTFIELD_SIZE/es.ui.SIZE_PX_FACTOR);
			if (maxlen < deflen) {
				mb.log.debug("Maximum length $ is smaller than default length $", maxlen, deflen);
				maxlen = deflen;
				nw = this.getCss(null);
			} else {
				nw = this.getCss(parseInt(maxlen * es.ui.SIZE_PX_FACTOR));
			}
			mb.log.debug("Adjusting fields to longest value: $, css: $", maxlen, nw);
			for (i=0; i<fields.length; i++) {
				f = fields[i];
				cn = (f.className || "");
				if (f.style.width) {
					f.style.width = nw;
					mb.log.debug("Set field: $ to size: $ (cn: $)", (f.name || "?"), f.style.width, cn);
				} else {
					mb.log.warning("Field $ does not define width!", (f.name || "?"));
				}
			}
			this.currentWidth = nw;
		}
		mb.log.exit();
	};

	/**
	 * Strips em from the input, and returns the
	 * value of the input.
	 **/
	this.getValue = function(s) {
		mb.log.enter(this.GID, "getValue");
		var ov = s;
		if (s != null) {
			ov = parseInt(new String(s).replace(/px/ig, ""));
		}
		mb.log.debug("ov: $", ov);
		return mb.log.exit(ov);
	};

	/**
	 * Strips px from the input string, and returns the
	 * string formatted as as an px string.
	 * If s is not given, the default lenght is returned.
	 **/
	this.getCss = function(s) {
		mb.log.enter(this.GID, "getCss");
		var ov;
		if (s != null) {
			ov = parseInt(new String(s).replace(/px/ig, "")) + "px";
		} else {
			ov = es.ui.TEXTFIELD_SIZE + "px";
		}
		mb.log.debug("ov: $", ov);
		return mb.log.exit(ov);
	};

	/**
	 * Returns the with of the textfield el, and
	 * adds amount to the value.
	 **/
	this.getWidth = function(el, amount) {
		mb.log.enter(this.GID, "getWidth");
		amount = (amount || 0);
		var w,nw;
		if (el && el.style.width) {
			w = el.style.width;
			nw = this.getCss(this.getValue(w) + amount);
			mb.log.debug("Field f: $, oldwidth: $, newwidth: $", el.name, w, nw);
		}
		return mb.log.exit(nw);
	};

	// leave constructor
	mb.log.exit();
}

// register prototype of module superclass
try {
	EsFieldResizer.prototype = new EsModuleBase;
} catch (e) {
	mb.log.error("EsFieldResizer: Could not register EsModuleBase prototype");
}