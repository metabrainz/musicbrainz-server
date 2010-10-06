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
| $Id: GcMain.js 9484 2007-09-30 11:21:04Z luks $
\----------------------------------------------------------------------------*/

/**
 * Main class of the GC functionality
 **/
function GuessCase() {
	mb.log.enter("GuessCase", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GuessCase";
	this.GID = "gc";

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.gc"; };
	this.getModName = function() { return "Guess case"; };
	if (es) {
		es.gc = this;
	}

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.u = new GcUtils();
	this.f = new GcFlags();
	this.i = new GcInput();
	this.o = new GcOutput();
	this.artistHandler = null;
	this.labelHandler = null;
	this.releaseHandler = null;
	this.trackHandler = null;
	this.re = {
		// define commonly used RE's
		SPACES_DOTS 	: /\s|\./i,
		SERIES_NUMBER 	: /^(\d+|[ivx]+)$/i
	}; // holder for the regular expressions

	// list of possible modes, mode is initialised to English.
	this.modes = new GcModes();
	this.mode = this.modes.getDefaultMode(); // setup default mode.
	this.artistmode = this.modes.getArtistMode(); // setup artist mode.

	// cookie keys
	this.COOKIE_MODE = this.getModID()+".mode";

	// configuration keys
	this.CFG_AUTOFIX = this.getModID()+".autofix";
	this.CFG_UC_ROMANNUMERALS = this.getModID()+".uc_romannumerals";
	this.CFG_UC_UPPERCASED = this.getModID()+".uc_uppercased";

	this.CONFIG_LIST = [

		new EsModuleConfig(this.CFG_AUTOFIX, false,
			 			 "Apply guess case after page loads",
			 			 "The guess case function is automatically applied for all the fields "
			 			 + "in the form. You can use Undo All if you want to reverse the changes.")

		, new EsModuleConfig(this.CFG_UC_ROMANNUMERALS, true,
			 			 "Uppercase roman numerals",
		 				 "Convert roman numerals i, ii, iii, iv etc. to uppercase.")

		, new EsModuleConfig(this.CFG_UC_UPPERCASED, true,
			 			 "Keep uppercase words uppercased",
		 				 "If a word is all uppercase characters, it is kept that way "
		 				 +"(Overrides normal behaviour).")
	];

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Override this method for initial configuration (register buttons etc.)
	 **/
	this.setupModuleDelegate =  function() {
		this.DEFAULT_EXPANDED = true;
		this.DEFAULT_VISIBLE = true;
	};

	/**
 	 * Resets the modules configuration
	 **/
	this.resetModuleDelegate = function() {
		mb.cookie.remove(this.COOKIE_MODE);
	};

	/**
	 * Prepare code for this module.
	 *
	 * @returns raw html code
	 **/
	this.getModuleHtml = function() {
		var cv = mb.cookie.get(this.COOKIE_MODE); // get editsuite mode from cookie.
		if (cv) {
			this.setMode(cv);
		}
		var s = [];
		s.push(this.getModuleStartHtml({x: true, log: true}));
		s.push('<table cellspacing="0" cellpadding="0" border="0" class="moduletable">');
		s.push('<tr valign="top">');
		s.push('<td width="10">');
		s.push(this.modes.getDropdownHtml());
		s.push('</td>');
		s.push('<td width="10">&nbsp;</td>');
		s.push('<td width="100%">');
		s.push('<span id="'+this.getModID()+'-text-expanded"></span>');
		s.push('</td></tr>');
		s.push('<tr valign="top">');
		s.push('<td colspan="3">');
		s.push(this.getConfigHtml());
		s.push('</td></tr>');
		s.push('</table>');
		s.push(this.getModuleEndHtml({x: true}));
		s.push(this.getModuleStartHtml({x: false}));
		s.push(this.getModuleEndHtml({x: false}));
		return s.join("");
	};

	/**
	 * get settings from cookie
	 **/
	this.onModuleHtmlWrittenDelegate = function() {
		if (this.isConfigTrue(this.CFG_AUTOFIX)) {
			mb.registerDOMReadyAction(new MbEventAction("es", "guessAllFields", "Autoguess all input fields"));
		}
		this.modes.updateUI();
	};

	/**
	 * Initialise the GuessCase object for another run
	 **/
	this.init = function() {
		this.f.init(); // init flags object
	};

	/**
	 * Guess the capitalization of an artist name
	 * @param	 is		the un-processed input string
	 * @returns			the processed string
	 **/
	this.guessArtist = function(is) {
		var os, handler;
		gc.init();
		mb.log.enter(this.GID, "guessArtist");
		if (!gc.artistHandler) {
			gc.artistHandler = new GcArtistHandler();
		}
		handler = gc.artistHandler;
		mb.log.info('Input: $', is);

		// we need to query the handler if the input string is
		// a special case, fetch the correct format, if the
		// returned case is indeed a special case.
		var num = handler.checkSpecialCase(is);
		if (handler.isSpecialCase(num)) {
			os = handler.getSpecialCaseFormatted(is, num);
			mb.log.info('Result after special case check: $', os);
		} else {
			// if it was not a special case, start Guessing
			os = handler.process(is);
			mb.log.info('Result after guess: $', os);
		}
		gc.restoreMode();
		return mb.log.exit(os);
	};

	/**
	 * Guess the sortname of a given artist name
	 * @param	 is		the un-processed input string
	 * @returns			the processed string
	 **/
	this.guessArtistSortname = function(is) {
		var os, handler;
		gc.init();
		mb.log.enter(this.GID, "guessArtistSortame");
		if (!gc.artistHandler) {
			gc.artistHandler = new GcArtistHandler();
		}
		handler = gc.artistHandler;
		mb.log.info('Input: $', is);

		// we need to query the handler if the input string is
		// a special case, fetch the correct format, if the
		// returned case is indeed a special case.
		var num = handler.checkSpecialCase(is);
		if (handler.isSpecialCase(num)) {
			os = handler.getSpecialCaseFormatted(is, num);
			mb.log.info('Result after special case check: $', os);
		} else {
			// if it was not a special case, start Guessing
			os = handler.guessSortName(is);
			mb.log.info('Result after guess: $', os);
		}
		gc.restoreMode();
		return mb.log.exit(os);
	};

	/**
	 * Guess the sortname of a given label name
	 * @param	 is		the un-processed input string
	 * @returns			the processed string
	 **/
	this.guessLabelSortname = function(is) {
		var os, handler;
		gc.init();
		mb.log.enter(this.GID, "guessLabelSortame");
		if (!gc.labelHandler) {
			gc.labelHandler = new GcLabelHandler();
		}
		handler = gc.labelHandler;
		mb.log.info('Input: $', is);

		// we need to query the handler if the input string is
		// a special case, fetch the correct format, if the
		// returned case is indeed a special case.
		var num = handler.checkSpecialCase(is);
		if (handler.isSpecialCase(num)) {
			os = handler.getSpecialCaseFormatted(is, num);
			mb.log.info('Result after special case check: $', os);
		} else {
			// if it was not a special case, start Guessing
			os = handler.guessSortName(is);
			mb.log.info('Result after guess: $', os);
		}
		gc.restoreMode();
		return mb.log.exit(os);
	};

	/**
	 * Guess the capitalization of n release name
	 * @param	 is		the un-processed input string
	 * @returns			the processed string
	 **/
	this.guessRelease = function(is, mode) {
		var os, handler;
		gc.init();
		mb.log.enter(this.GID, "guessRelease");
		if (!gc.releaseHandler) {
			gc.releaseHandler = new GcReleaseHandler();
		}
		handler = gc.releaseHandler;
		mb.log.info('Input: $', is);
		this.useSelectedMode(mode);

		// we need to query the handler if the input string is
		// a special case, fetch the correct format, if the
		// returned case is indeed a special case.
		var num = handler.checkSpecialCase(is);
		if (handler.isSpecialCase(num)) {
			os = handler.getSpecialCaseFormatted(is, num);
			mb.log.info('Result after special case check: $', os);
		} else {
			// if it was not a special case, start Guessing
			os = handler.process(is);
			mb.log.info('Result after guess: $', os);
		}
		return mb.log.exit(os);
	};

	/**
	 * Guess the capitalization of an track name
	 * @param	 is		the un-processed input string
	 * @returns			the processed string
	 **/
	this.guessTrack = function(is, mode) {
		var os, handler;
		gc.init();
		mb.log.enter(this.GID, "guessTrack");
		if (!gc.trackHandler) {
			gc.trackHandler = new GcTrackHandler();
		}
		handler = gc.trackHandler;
		mb.log.info('Input: $', is);
		this.useSelectedMode(mode);

		// we need to query the handler if the input string is
		// a special case, fetch the correct format, if the
		// returned case is indeed a special case.
		var num = handler.checkSpecialCase(is);
		if (handler.isSpecialCase(num)) {
			os = handler.getSpecialCaseFormatted(is, num);
			mb.log.info('Result after special case check: $', os);
		} else {
			// if it was not a special case, start Guessing
			os = handler.process(is);
			mb.log.info('Result after guess: $', os);
		}
		return mb.log.exit(os);
	};

	/**
	 * Set a new GuessCase mode
	 **/
	this.setMode = function(mode) {
		mb.log.enter(this.GID, "setMode");
		var o;
		if (mode instanceof GcMode) {
			this.mode = mode;
			mb.log.debug('Set mode from object: $', mode);
			return mb.log.exit(true);
		} else if ((o = gc.modes.getModeFromID(mode, true)) != null) {
			this.mode = o;
			mb.log.debug('Set mode from id: $', mode);
			return mb.log.exit(true);
		} else {
			mb.log.warning('Unhandled parameter given: $', mode);
			return mb.log.exit(false);
		}
	};

	/**
	 * Handles the given parameter, or selects
	// the current value from the DropDown.
	 **/
	this.useSelectedMode = function(mode) {
		if (mode && this.setMode(mode)) {
		} else {
			if (this.isUIAvailable()) {
				gc.modes.useModeFromUI(); // Get mode from dropdown
			}
		}
	};

	/**
	 * Restores the saved mode from the member variable
	 **/
	this.restoreMode = function() {
		mb.log.enter(this.GID, "restoreMode");
		if (this.oldmode && this.oldmode instanceof GcMode) {
			this.mode = this.oldmode;
			this.oldmode = null;
			mb.log.debug("Restored mode: $", this.mode);
		}
		mb.log.exit();
	};

	/**
	 * Returns the current modes object.
	 **/
	this.getModes = function() {
		return this.modes;
	};

	/**
	 * Returns the current mode object.
	 **/
	this.getMode = function() {
		return this.mode;
	};

	/**
	 * Accessor function: Returns the current word of
	 * the input object
	 *
	 * @see Log#logMessage
	 **/
	this.getCurrentWord = function() {
		return gc.i.getCurrentWord();
	};

	/**
	 * Accessor function: Returns the GcOutput object
	 *
	 * @see Sandbox/JSUnit tests
	 **/
	this.getInput = function() {
		return gc.i;
	};

	/**
	 * Accessor function: Returns the GcOutput object
	 *
	 * @see Sandbox/JSUnit tests
	 **/
	this.getOutput = function() {
		return gc.o;
	};

	/**
	 * Accessor function: Returns the GcUtils object.
	 *
	 * @see Sandbox/JSUnit tests
	 **/
	this.getUtils = function() {
		return gc.u;
	};

	// exit constructor
	mb.log.exit();
}

// register prototype of module superclass
try {
	GuessCase.prototype = new EsModuleBase;
} catch (e) {
	mb.log.error("GuessCase: Could not register EsModuleBase prototype");
	mb.log.error(e);
}
