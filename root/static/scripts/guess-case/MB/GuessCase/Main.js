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
    if (window.gc) {
        return window.gc; /* yay. we're a singleton now. */
    }

    var self = {};

    self.modeName = $.cookie("guesscase_mode") || "English";
    self.mode = MB.GuessCase.Mode[self.modeName]();

    /* config. */
    self.CFG_UC_ROMANNUMERALS = $.cookie("guesscase_roman") !== "false";
    self.CFG_UC_UPPERCASED = $.cookie("guesscase_keepuppercase") !== "false";

    // ----------------------------------------------------------------------------
    // member variables
    // ----------------------------------------------------------------------------
    self.u = MB.GuessCase.Utils();
    self.f = MB.GuessCase.Flags();
    self.i = MB.GuessCase.Input();
    self.o = MB.GuessCase.Output();
    self.artistHandler = null;
    self.labelHandler = null;
    self.releaseHandler = null;
    self.trackHandler = null;
    self.re = {
        // define commonly used RE's
        SPACES_DOTS: /\s|\./i,
        SERIES_NUMBER: /^(\d+|[ivx]+)$/i
    }; // holder for the regular expressions

    /* FIXME: inconsistent. */
    self.artistmode = MB.GuessCase.Mode.Artist();

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

    /**
     * Initialise the GuessCase object for another run
     **/
    self.init = function () {
        self.f.init(); // init flags object
    };

    function guess(handlerConstructor, method, mode) {
        var handler;

        /**
         * Guesses the name (e.g. capitalization) or sort name (for aliases)
         * of a given entity.
         * @param {string} is The unprocessed input string.
         * @return {string} The processed string.
         **/
        return function (is) {
            gc.init();

            if (mode) {
                var previousMode = self.mode;
                self.mode = mode;
            }

            handler = handler || handlerConstructor();

            // we need to query the handler if the input string is
            // a special case, fetch the correct format, if the
            // returned case is indeed a special case.
            var num = handler.checkSpecialCase(is);
            if (handler.isSpecialCase(num)) {
                var os = handler.getSpecialCaseFormatted(is, num);
            } else {
                // if it was not a special case, start Guessing
                var os = handler[method].apply(handler, arguments);
            }

            if (mode) {
                self.mode = previousMode;
            }

            return os;
        };
    }

    self.guessArtist = guess(MB.GuessCase.Handler.Artist, "process", self.artistmode);
    self.guessArtistSortname = guess(MB.GuessCase.Handler.Artist, "guessSortName", self.artistmode);

    self.guessLabel = guess(MB.GuessCase.Handler.Label, "process");
    self.guessLabelSortname = guess(MB.GuessCase.Handler.Label, "guessSortName");

    self.guessWork = guess(MB.GuessCase.Handler.Work, "process");
    self.guessWorkSortname = guess(MB.GuessCase.Handler.Work, "guessSortName");

    self.guessArea = guess(MB.GuessCase.Handler.Area, "process");
    self.guessAreaSortname = guess(MB.GuessCase.Handler.Area, "guessSortName");

    self.guessPlace = guess(MB.GuessCase.Handler.Place, "process");
    self.guessPlaceSortname = guess(MB.GuessCase.Handler.Place, "guessSortName");

    self.guessSeries = guess(MB.GuessCase.Handler.Work, "process");
    self.guessSeriesSortname = guess(MB.GuessCase.Handler.Work, "guessSortName");

    self.guessRelease = guess(MB.GuessCase.Handler.Release, "process");

    self.guessTrack = guess(MB.GuessCase.Handler.Track, "process");

    /* FIXME: ugly hack, need to get rid of using a global 'gc' everywhere. */
    window.gc = self;

    return self;
};
