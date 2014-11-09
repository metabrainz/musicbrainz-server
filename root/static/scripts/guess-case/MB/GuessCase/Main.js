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
(function () {
    var self = {};

    self.modeName = $.cookie("guesscase_mode") || "English";
    self.mode = MB.GuessCase.Mode[self.modeName];

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

    self.re = {
        // define commonly used RE's
        SPACES_DOTS: /\s|\./i,
        SERIES_NUMBER: /^(\d+|[ivx]+)$/i
    }; // holder for the regular expressions

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

    /**
     * Initialise the GuessCase object for another run
     **/
    self.init = function () {
        self.f.init(); // init flags object
    };

    function guess(handlerName, method, modeName) {
        var handler;

        /**
         * Guesses the name (e.g. capitalization) or sort name (for aliases)
         * of a given entity.
         * @param {string} is The unprocessed input string.
         * @return {string} The processed string.
         **/
        return function (is) {
            gc.init();

            if (modeName) {
                var previousMode = self.mode;
                self.mode = MB.GuessCase.Mode[modeName];
            }

            handler = handler || MB.GuessCase.Handler[handlerName]();

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

            if (modeName) {
                self.mode = previousMode;
            }

            return os;
        };
    }

    MB.GuessCase.area = {
        guess: guess("Area", "process"),
        sortname: guess("Area", "guessSortName")
    };

    MB.GuessCase.artist = {
        guess: guess("Artist", "process", "Artist"),
        sortname: guess("Artist", "guessSortName", "Artist")
    };

    MB.GuessCase.label = {
        // This probably shouldn't be using the "Artist" mode, but it always has been.
        guess: guess("Label", "process", "Artist"),
        sortname: guess("Label", "guessSortName", "Artist")
    };

    MB.GuessCase.place = {
        guess: guess("Place", "process"),
        sortname: guess("Place", "guessSortName")
    };

    MB.GuessCase.release = {
        guess: guess("Release", "process")
    };

    MB.GuessCase["release_group"] = MB.GuessCase.release;
    MB.GuessCase["release-group"] = MB.GuessCase.release;

    MB.GuessCase.track = {
        guess: guess("Track", "process")
    };

    MB.GuessCase.recording = MB.GuessCase.track;

    MB.GuessCase.work = {
        guess: guess("Work", "process"),
        sortname: guess("Work", "guessSortName")
    };

    // Series doesn't have it's own handler, and just uses the work handler
    // because additional behavior isn't needed.
    MB.GuessCase.series = MB.GuessCase.work;

    // lol
    MB.GuessCase.instrument = {
        guess: function (string) {
            return string.toLowerCase();
        }
    };

    /* FIXME: ugly hack, need to get rid of using a global 'gc' everywhere. */
    window.gc = self;
}());
