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

import MB from '../../../common/MB';
import getCookie from '../../../common/utility/getCookie';
import * as flags from '../../flags';
import * as modes from '../../modes';

import Input from './Input';
import Output from './Output';

import './Handler/Base';
import './Handler/Area';
import './Handler/Artist';
import './Handler/Label';
import './Handler/Place';
import './Handler/Release';
import './Handler/Track';
import './Handler/Work';

MB.GuessCase = MB.GuessCase || {};

/**
 * Main class of the GC functionality
 **/
    var self = {};

    self.modeName = getCookie("guesscase_mode") || "English";
    self.mode = modes[self.modeName];

    /* config. */
    self.CFG_UC_UPPERCASED = getCookie("guesscase_keepuppercase") !== "false";

    // ----------------------------------------------------------------------------
    // member variables
    // ----------------------------------------------------------------------------
    self.i = Input(self);
    self.o = Output(self);

    self.re = {
        // define commonly used RE's
        SPACES_DOTS: /\s|\./i,
        SERIES_NUMBER: /^(\d+|[ivx]+)$/i,
    }; // holder for the regular expressions

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

    function guess(handlerName, method) {
        var handler;

        /**
         * Guesses the name (e.g. capitalization) or sort name (for aliases)
         * of a given entity.
         * @param {string} is The unprocessed input string.
         * @return {string} The processed string.
         **/
        return function (is) {
            // Initialise flags for another run.
            flags.init();

            handler = handler || MB.GuessCase.Handler[handlerName](self);

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

            return os;
        };
    }

    MB.GuessCase.area = {
        guess: guess("Area", "process"),
        sortname: guess("Area", "guessSortName"),
    };

    MB.GuessCase.artist = {
        guess: guess("Artist", "process"),
        sortname: guess("Artist", "guessSortName"),
    };

    MB.GuessCase.label = {
        guess: guess("Label", "process"),
        sortname: guess("Label", "guessSortName"),
    };

    MB.GuessCase.place = {
        guess: guess("Place", "process"),
        sortname: guess("Place", "guessSortName"),
    };

    MB.GuessCase.release = {
        guess: guess("Release", "process"),
        sortname: guess("Release", "guessSortName"),
    };

    MB.GuessCase.release_group = MB.GuessCase.release;

    MB.GuessCase.track = {
        guess: guess("Track", "process"),
        sortname: guess("Track", "guessSortName"),
    };

    MB.GuessCase.recording = MB.GuessCase.track;

    MB.GuessCase.work = {
        guess: guess("Work", "process"),
        sortname: guess("Work", "guessSortName"),
    };

    // Series and Event don't have their own handler, and they use the
    // work handler because additional behavior isn't needed.
    MB.GuessCase.series = MB.GuessCase.work;
    MB.GuessCase.event = MB.GuessCase.work;

    // lol
    MB.GuessCase.instrument = {
        guess: function (string) {
            return string.toLowerCase();
        },
    };

export default self;
