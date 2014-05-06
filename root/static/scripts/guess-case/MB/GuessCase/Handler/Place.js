/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2013 MetaBrainz Foundation

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
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

/**
 * Place specific GuessCase functionality
 **/
MB.GuessCase.Handler.Place = function () {
    var self = MB.GuessCase.Handler.Base();

    /**
     * Checks special cases
     **/
    self.checkSpecialCase = function(is) {
        return self.NOT_A_SPECIALCASE;
    };

    /**
     * Guess the releasename given in string is, and
     * returns the guessed name.
     *
     * @param        is                the inputstring
     * @returns os                the processed string
     **/
    self.process = function(is) {
        is = gc.mode.preProcessCommons(is);
        var words = gc.i.splitWordsAndPunctuation(is);
        gc.o.init();
        gc.i.init(is, words);
        while (!gc.i.isIndexAtEnd()) {
            self.processWord();
        }
        var os = gc.o.getOutput();
        os = gc.mode.runPostProcess(os);
        return os;
    };

    /**
     * Delegate function which handles words not handled
     * in the common word handlers.
     *
     * - Handles VersusStyle
     * - Handles VolumeNumberStyle
     * - Handles PartNumberStyle
     *
     **/
    self.doWord = function() {
        if (self.doVersusStyle()) {
        } else if (self.doIgnoreWords()) {
        } else if (self.doVolumeNumberStyle()) {
        } else if (self.doPartNumberStyle()) {
        } else if (gc.mode.doWord()) {
        } else {
            // handle normal word.
            gc.o.appendSpaceIfNeeded();
            gc.i.capitalizeCurrentWord();
            gc.o.appendCurrentWord();
            gc.f.resetContext();
            gc.f.forceCaps = false;
            gc.f.spaceNextWord = true;
        }
        gc.f.number = false;
        return null;
    };

    /**
     * Guesses the sortname for place aliases
     **/
    self.guessSortName = function(is) {
        is = gc.u.trim(is);

        // let's see if we got a compound place
        var collabSplit = " and ";
        collabSplit = (is.indexOf(" + ") != -1 ? " + " : collabSplit);
        collabSplit = (is.indexOf(" & ") != -1 ? " & " : collabSplit);

        var as = is.split(collabSplit);
        for (var splitindex=0; splitindex<as.length; splitindex++) {
            var place = as[splitindex];
            if (!MB.utility.isNullOrEmpty(place)) {
                place = gc.u.trim(place);
                var append = "";

                var words = place.split(" ");

                // handle some special cases, like The and Los which
                // are sorted at the end.
                if (!gc.re.SORTNAME_THE) {
                    gc.re.SORTNAME_THE = /^The$/i; // match The
                }
                var firstWord = words[0];
                if (firstWord.match(gc.re.SORTNAME_THE)) {
                    append = (", The" + append); // handle The xyz -> xyz, The
                    words[0] = null;
                }

                var t = [];
                for (i=0; i<words.length; i++) {
                    var w = words[i];
                    if (!MB.utility.isNullOrEmpty(w)) {
                        // skip empty names
                        t.push(w);
                    }
                    if (i < words.length-1) {
                        // if not last word, add space
                        t.push(" ");
                    }
                }

                // append string
                if (!MB.utility.isNullOrEmpty(append)) {
                    t.push(append);
                }
                place = gc.u.trim(t.join(""));
            }
            if (!MB.utility.isNullOrEmpty(place)) {
                as[splitindex] = place;
            } else {
                delete as[splitindex];
            }
        }
        return gc.u.trim(as.join(collabSplit));
    };

    return self;
};
