/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (c) 2005 Stefan Kestenholz (keschte)
   Copyright (C) 2010 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

/**
 * Main class of the GC functionality
 **/
function GuessCase() {
    var self = MB.Object ();

    // ----------------------------------------------------------------------------
    // placeholders for stuff which used to be inherited from the edit suite.
    // ---------------------------------------------------------------------------
    self.isConfigTrue = function () { return false; };
    window.gc = self; /* FIXME: ugly hack. --warp. */

    // ----------------------------------------------------------------------------
    // register class/global id
    // ---------------------------------------------------------------------------
    self.CN = "GuessCase";
    self.GID = "gc";

    // ----------------------------------------------------------------------------
    // register module
    // ---------------------------------------------------------------------------
    self.getModID = function() { return "es.gc"; };
    self.getModName = function() { return "Guess case"; };

    // ----------------------------------------------------------------------------
    // member variables
    // ---------------------------------------------------------------------------
    self.u = new GcUtils();
    self.f = new GcFlags();
    self.i = new GcInput();
    self.o = new GcOutput();
    self.artistHandler = null;
    self.labelHandler = null;
    self.releaseHandler = null;
    self.trackHandler = null;
    self.re = {
	// define commonly used RE's
	SPACES_DOTS 	: /\s|\./i,
	SERIES_NUMBER 	: /^(\d+|[ivx]+)$/i
    }; // holder for the regular expressions

    // list of possible modes, mode is initialised to English.
    self.modes = new GcModes();
    self.mode = self.modes.getDefaultMode(); // setup default mode.
    self.artistmode = self.modes.getArtistMode(); // setup artist mode.

    // cookie keys
    self.COOKIE_MODE = self.getModID()+".mode";
    
    // configuration keys
    self.CFG_AUTOFIX = self.getModID()+".autofix";
    self.CFG_UC_ROMANNUMERALS = self.getModID()+".uc_romannumerals";
    self.CFG_UC_UPPERCASED = self.getModID()+".uc_uppercased";

    self.CONFIG_LIST = [];
/*
		new EsModuleConfig(self.CFG_AUTOFIX, false,
			 			 "Apply guess case after page loads",
			 			 "The guess case function is automatically applied for all the fields "
			 			 + "in the form. You can use Undo All if you want to reverse the changes.")

		, new EsModuleConfig(self.CFG_UC_ROMANNUMERALS, true,
			 			 "Uppercase roman numerals",
		 				 "Convert roman numerals i, ii, iii, iv etc. to uppercase.")

		, new EsModuleConfig(self.CFG_UC_UPPERCASED, true,
			 			 "Keep uppercase words uppercased",
		 				 "If a word is all uppercase characters, it is kept that way "
		 				 +"(Overrides normal behaviour).")
                                                 */

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

    /**
     * Override self method for initial configuration (register buttons etc.)
     **/
    self.setupModuleDelegate =  function() {
	self.DEFAULT_EXPANDED = true;
	self.DEFAULT_VISIBLE = true;
    };

    /**
     * Resets the modules configuration
     **/
    self.resetModuleDelegate = function() {
	mb.cookie.remove(self.COOKIE_MODE);
    };

    /**
     * Prepare code for self module.
     *
     * @returns raw html code
     **/
    self.getModuleHtml = function() {
	var cv = mb.cookie.get(self.COOKIE_MODE); // get editsuite mode from cookie.
	if (cv) {
	    self.setMode(cv);
	}
	var s = [];
	s.push(self.getModuleStartHtml({x: true, log: true}));
	s.push('<table cellspacing="0" cellpadding="0" border="0" class="moduletable">');
	s.push('<tr valign="top">');
	s.push('<td width="10">');
	s.push(self.modes.getDropdownHtml());
	s.push('</td>');
	s.push('<td width="10">&nbsp;</td>');
	s.push('<td width="100%">');
	s.push('<span id="'+self.getModID()+'-text-expanded"></span>');
	s.push('</td></tr>');
	s.push('<tr valign="top">');
	s.push('<td colspan="3">');
	s.push(self.getConfigHtml());
	s.push('</td></tr>');
	s.push('</table>');
	s.push(self.getModuleEndHtml({x: true}));
	s.push(self.getModuleStartHtml({x: false}));
	s.push(self.getModuleEndHtml({x: false}));
	return s.join("");
    };

    /**
     * get settings from cookie
     **/
    self.onModuleHtmlWrittenDelegate = function() {
	if (self.isConfigTrue(self.CFG_AUTOFIX)) {
	    mb.registerDOMReadyAction(new MbEventAction("es", "guessAllFields", "Autoguess all input fields"));
	}
	self.modes.updateUI();
    };

    /**
     * Initialise the GuessCase object for another run
     **/
    self.init = function() {
	self.f.init(); // init flags object
    };

    /**
     * Guess the capitalization of an artist name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessArtist = function(is) {
	var os, handler;
	gc.init();

	if (!gc.artistHandler) {
	    gc.artistHandler = new GcArtistHandler();
	}
	handler = gc.artistHandler;

	// we need to query the handler if the input string is
	// a special case, fetch the correct format, if the
	// returned case is indeed a special case.
	var num = handler.checkSpecialCase(is);
	if (handler.isSpecialCase(num)) {
	    os = handler.getSpecialCaseFormatted(is, num);
	} else {
	    // if it was not a special case, start Guessing
	    os = handler.process(is);
	}
	gc.restoreMode();
	return os;
    };

    /**
     * Guess the sortname of a given artist name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessArtistSortname = function(is) {
	var os, handler;
	gc.init();

	if (!gc.artistHandler) {
	    gc.artistHandler = new GcArtistHandler();
	}
	handler = gc.artistHandler;


	// we need to query the handler if the input string is
	// a special case, fetch the correct format, if the
	// returned case is indeed a special case.
	var num = handler.checkSpecialCase(is);
	if (handler.isSpecialCase(num)) {
	    os = handler.getSpecialCaseFormatted(is, num);

	} else {
	    // if it was not a special case, start Guessing
	    os = handler.guessSortName(is);

	}
	gc.restoreMode();
	return os;
    };

    /**
     * Guess the sortname of a given label name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessLabelSortname = function(is) {
	var os, handler;
	gc.init();

	if (!gc.labelHandler) {
	    gc.labelHandler = new GcLabelHandler();
	}
	handler = gc.labelHandler;

	// we need to query the handler if the input string is
	// a special case, fetch the correct format, if the
	// returned case is indeed a special case.
	var num = handler.checkSpecialCase(is);
	if (handler.isSpecialCase(num)) {
	    os = handler.getSpecialCaseFormatted(is, num);
	} else {
	    // if it was not a special case, start Guessing
	    os = handler.guessSortName(is);
	}
	gc.restoreMode();
	return os;
    };

    /**
     * Guess the capitalization of n release name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessRelease = function(is, mode) {
	var os, handler;
	gc.init();

	if (!gc.releaseHandler) {
	    gc.releaseHandler = new GcReleaseHandler();
	}
	handler = gc.releaseHandler;

	self.useSelectedMode(mode);

	// we need to query the handler if the input string is
	// a special case, fetch the correct format, if the
	// returned case is indeed a special case.
	var num = handler.checkSpecialCase(is);
	if (handler.isSpecialCase(num)) {
	    os = handler.getSpecialCaseFormatted(is, num);

	} else {
	    // if it was not a special case, start Guessing
	    os = handler.process(is);

	}
	return os;
    };

    /**
     * Guess the capitalization of an track name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessTrack = function(is, mode) {
	var os, handler;
	self.init();

	if (!self.trackHandler) {
	    self.trackHandler = new GcTrackHandler();
	}
	handler = self.trackHandler;

	self.useSelectedMode(mode);

	// we need to query the handler if the input string is
	// a special case, fetch the correct format, if the
	// returned case is indeed a special case.
	var num = handler.checkSpecialCase(is);
	if (handler.isSpecialCase(num)) {
	    os = handler.getSpecialCaseFormatted(is, num);

	} else {
	    // if it was not a special case, start Guessing
	    os = handler.process(is);

	}
	return os;
    };

    /**
     * Set a new GuessCase mode
     **/
    self.setMode = function(mode) {

	var o;
	if (mode instanceof GcMode) {
	    self.mode = mode;

	    return true;
	} else if ((o = gc.modes.getModeFromID(mode, true)) != null) {
	    self.mode = o;

	    return true;
	} else {

	    return false;
	}
    };

    /**
     * Handles the given parameter, or selects
     // the current value from the DropDown.
     **/
    self.useSelectedMode = function(mode) {
	if (mode && self.setMode(mode)) {
	} else {
	    if (self.isUIAvailable()) {
		gc.modes.useModeFromUI(); // Get mode from dropdown
	    }
	}
    };

    /**
     * Restores the saved mode from the member variable
     **/
    self.restoreMode = function() {

	if (self.oldmode && self.oldmode instanceof GcMode) {
	    self.mode = self.oldmode;
	    self.oldmode = null;

	}

    };

    /**
     * Returns the current modes object.
     **/
    self.getModes = function() {
	return self.modes;
    };

    /**
     * Returns the current mode object.
     **/
    self.getMode = function() {
	return self.mode;
    };

    /**
     * Accessor function: Returns the current word of
     * the input object
     *
     * @see Log#logMessage
     **/
    self.getCurrentWord = function() {
	return gc.i.getCurrentWord();
    };

    /**
     * Accessor function: Returns the GcOutput object
     *
     * @see Sandbox/JSUnit tests
     **/
    self.getInput = function() {
	return gc.i;
    };

    /**
     * Accessor function: Returns the GcOutput object
     *
     * @see Sandbox/JSUnit tests
     **/
    self.getOutput = function() {
	return gc.o;
    };

    /**
     * Accessor function: Returns the GcUtils object.
     *
     * @see Sandbox/JSUnit tests
     **/
    self.getUtils = function() {
	return gc.u;
    };

    return self;
}
