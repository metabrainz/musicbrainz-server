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

MB.GuessCase = MB.GuessCase ? MB.GuessCase : {};

/**
 * Main class of the GC functionality
 **/
MB.GuessCase.Main = function () {
    var self = MB.Object ();

    // ----------------------------------------------------------------------------
    // placeholders for stuff which used to be inherited from the edit suite.
    // ---------------------------------------------------------------------------
    self.isConfigTrue = function (cfg) { return cfg (); };
    window.gc = self; /* FIXME: ugly hack. --warp. */

    /* config. */
    self.CFG_AUTOFIX = function () { return false; };
    self.CFG_UC_ROMANNUMERALS = function () { return $('#gc-roman').is(':checked'); };
    self.CFG_UC_UPPERCASED = function () { return $('#gc-keepuppercase').is(':checked'); };

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

    self.modes = MB.GuessCase.Modes ();

    /* FIXME: inconsistent. */
    self.artistmode = self.modes.artist_mode;

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

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
     * Selects the current value from the DropDown.
     **/
    self.useSelectedMode = function () {
        gc.mode = self.modes.getMode ();
    };

    self.getMode = function () {
        return self.modes.getMode ();
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
};
