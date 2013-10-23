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

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};

/**
 * Main class of the GC functionality
 **/
MB.GuessCase.Main = function () {
    if (window.gc)
    {
        return window.gc; /* yay. we're a singleton now. */
    }

    var self = MB.Object ();

    self.modeName = $.cookie("guesscase_mode") || "English";
    self.mode = MB.GuessCase.Mode[self.modeName]();

    /* config. */
    self.CFG_UC_ROMANNUMERALS = $.cookie("guesscase_roman") !== "false";
    self.CFG_UC_UPPERCASED = $.cookie("guesscase_keepuppercase") !== "false";

    // ----------------------------------------------------------------------------
    // member variables
    // ----------------------------------------------------------------------------
    self.u = MB.GuessCase.Utils ();
    self.f = MB.GuessCase.Flags ();
    self.i = MB.GuessCase.Input ();
    self.o = MB.GuessCase.Output ();
    self.artistHandler = null;
    self.labelHandler = null;
    self.releaseHandler = null;
    self.trackHandler = null;
    self.re = {
	// define commonly used RE's
	SPACES_DOTS 	: /\s|\./i,
	SERIES_NUMBER 	: /^(\d+|[ivx]+)$/i
    }; // holder for the regular expressions

    /* FIXME: inconsistent. */
    self.artistmode = MB.GuessCase.Mode.Artist();

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

        var mode_backup = self.mode;
        self.mode = self.artistmode;

	if (!self.artistHandler) {
	    self.artistHandler = MB.GuessCase.Handler.Artist ();
	}
	handler = self.artistHandler;

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

        self.mode = mode_backup;

	return os;
    };

    /**
     * Guess the sortname of a given artist name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessArtistSortname = function(is, person) {
	var os, handler;
	gc.init();

	if (!self.artistHandler) {
	    self.artistHandler = MB.GuessCase.Handler.Artist ();
	}
	handler = self.artistHandler;

	// we need to query the handler if the input string is
	// a special case, fetch the correct format, if the
	// returned case is indeed a special case.
	var num = handler.checkSpecialCase(is);
	if (handler.isSpecialCase(num)) {
	    os = handler.getSpecialCaseFormatted(is, num);
	} else {
	    // if it was not a special case, start Guessing
	    os = handler.guessSortName(is, person);
	}

	return os;
    };

    /**
     * Guess the capitalization of a label name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessLabel = function(is) {
	var os, handler;
	gc.init();

        var mode_backup = self.mode;
        self.mode = MB.GuessCase.Mode.English();;

	if (!self.labelHandler) {
	    self.labelHandler = MB.GuessCase.Handler.Label ();
	}
	handler = self.labelHandler;

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

        self.mode = mode_backup;

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

	if (!self.labelHandler) {
	    self.labelHandler = MB.GuessCase.Handler.Label ();
	}
	handler = self.labelHandler;

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

	return os;
    };

    /**
     * Guess the capitalization of a work name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessWork = function(is) {
	var os, handler;
	gc.init();

	if (!self.workHandler) {
	    self.workHandler = MB.GuessCase.Handler.Work ();
	}
	handler = self.workHandler;

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
     * Guess the sortname of a given work name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessWorkSortname = function(is) {
	var os, handler;
	gc.init();

	if (!self.workHandler) {
	    self.workHandler = MB.GuessCase.Handler.Work ();
	}
	handler = self.workHandler;

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

	return os;
    };

    /**
     * Guess the capitalization of a area name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessArea = function(is) {
	var os, handler;
	gc.init();

	if (!self.areaHandler) {
	    self.areaHandler = MB.GuessCase.Handler.Area ();
	}
	handler = self.areaHandler;

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
     * Guess the sortname of a given area name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessAreaSortname = function(is) {
	var os, handler;
	gc.init();

	if (!self.areaHandler) {
	    self.areaHandler = MB.GuessCase.Handler.Area ();
	}
	handler = self.areaHandler;

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

	return os;
    };

    /**
     * Guess the capitalization of a place name
     * @param    is             the un-processed input string
     * @returns                 the processed string
     **/
    self.guessPlace = function(is, mode) {
        var os, handler;
        gc.init();

        if (!self.placeHandler) {
            self.placeHandler = MB.GuessCase.Handler.Place ();
        }
        handler = self.placeHandler;

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
     * Guess the sortname of a given place name (for aliases)
     * @param    is             the un-processed input string
     * @returns                 the processed string
     **/
    self.guessPlaceSortname = function(is) {
        var os, handler;
        gc.init();

        if (!self.placeHandler) {
            self.placeHandler = MB.GuessCase.Handler.Place ();
        }
        handler = self.placeHandler;

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

        return os;
    };

    /**
     * Guess the capitalization of n release name
     * @param	 is		the un-processed input string
     * @returns			the processed string
     **/
    self.guessRelease = function(is) {
	var os, handler;
	gc.init();

	if (!self.releaseHandler) {
	    self.releaseHandler = MB.GuessCase.Handler.Release ();
	}
	handler = self.releaseHandler;

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
    self.guessTrack = function(is) {
	var os, handler;
	self.init();

	if (!self.trackHandler) {
	    self.trackHandler = MB.GuessCase.Handler.Track ();
	}
	handler = self.trackHandler;

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

    /* FIXME: ugly hack, need to get rid of using a global 'gc' everywhere. */
    window.gc = self;

    return self;
};

