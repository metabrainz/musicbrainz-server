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
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

/**
 * Label specific GuessCase functionality
 **/
MB.GuessCase.Handler.Label = function () {
    var self = MB.GuessCase.Handler.Base();

    // ----------------------------------------------------------------------------
    // member variables
    // ---------------------------------------------------------------------------
    self.UNKNOWN = "[unknown]";
    self.NOLABEL = "[unknown]";

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

    /**
     * Guess the label name given in string is, and
     * returns the guessed name.
     *
     * @param   is        the inputstring
     * @returns os        the processed string
     **/
    self.process = function (is) {
        is = gc.artistmode.preProcessCommons(is);
        var w = gc.i.splitWordsAndPunctuation(is);
        gc.o.init();
        gc.i.init(is, w);
        while (!gc.i.isIndexAtEnd()) {
            self.processWord();
        }
        var os = gc.o.getOutput();
        return gc.artistmode.runPostProcess(os);
    };

    /**
     * Checks special cases of labels
     * - empty, unknown -> [unknown]
     * - none, no label, not applicable, n/a -> [no label]
     **/
    self.checkSpecialCase = function (is) {
        if (is) {
            if (!gc.re.LABEL_EMPTY) {
                // match empty
                gc.re.LABEL_EMPTY = /^\s*$/i;
                // match "unknown" and variants
                gc.re.LABEL_UNKNOWN = /^[\(\[]?\s*Unknown\s*[\)\]]?$/i;
                // match "none" and variants
                gc.re.LABEL_NONE = /^[\(\[]?\s*none\s*[\)\]]?$/i;
                // match "no label" and variants
                gc.re.LABEL_NOLABEL = /^[\(\[]?\s*no[\s-]+label\s*[\)\]]?$/i;
                // match "not applicable" and variants
                gc.re.LABEL_NOTAPPLICABLE = /^[\(\[]?\s*not[\s-]+applicable\s*[\)\]]?$/i;
                // match "n/a" and variants
                gc.re.LABEL_NA = /^[\(\[]?\s*n\s*[\\\/]\s*a\s*[\)\]]?$/i;
            }
            var os = is;
            if (is.match(gc.re.LABEL_EMPTY)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_UNKNOWN)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_NONE)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_NOLABEL)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_NOTAPPLICABLE)) {
                return self.SPECIALCASE_UNKNOWN;

            } else if (is.match(gc.re.LABEL_NA)) {
                return self.SPECIALCASE_UNKNOWN;
            }
        }
        return self.NOT_A_SPECIALCASE;
    };

    /**
     * Delegate function which handles words not handled
     * in the common word handlers.
     *
     * - Handles VersusStyle
     *
     **/
    self.doWord = function () {
        if (self.doVersusStyle()) {
        } else if (self.doPresentsStyle()) {
        } else {
            // no special case, append
            gc.o.appendSpaceIfNeeded();
            gc.i.capitalizeCurrentWord();
            gc.o.appendCurrentWord();
        }
        gc.f.resetContext();
        gc.f.number = false;
        gc.f.forceCaps = false;
        gc.f.spaceNextWord = true;
        return null;
    };

    /**
     * Reformat pres/presents -> presents
     *
     * - Handles DiscNumberStyle (DiscNumberWithNameStyle)
     * - Handles FeaturingArtistStyle
     * - Handles VersusStyle
     * - Handles VolumeNumberStyle
     * - Handles PartNumberStyle
     *
     **/
    self.doPresentsStyle = function () {
        if (!self.doPresentsRE) {
            self.doPresentsRE = /^(presents?|pres)$/i;
        }
        if (gc.i.matchCurrentWord(self.doPresentsRE)) {
            gc.o.appendSpace();
            gc.o.appendWord("presents");
            if (gc.i.isNextWord(".")) {
                gc.i.nextIndex();
            }
            return true;
        }
        return false;
    };

    /**
     * Guesses the sortname for labels
     **/
    self.guessSortName = function (is) {
        is = gc.u.trim(is);

        // let's see if we got a compound label
        var collabSplit = " and ";
        collabSplit = (is.indexOf(" + ") != -1 ? " + " : collabSplit);
        collabSplit = (is.indexOf(" & ") != -1 ? " & " : collabSplit);

        var as = is.split(collabSplit);
        for (var splitindex = 0; splitindex < as.length; splitindex++) {
            var label = as[splitindex];

            if (!MB.utility.isNullOrEmpty(label)) {
                label = gc.u.trim(label);
                var append = "";

                var words = label.split(" ");

                // handle some special cases, like The and Los which
                // are sorted at the end.
                if (!gc.re.SORTNAME_THE) {
                    gc.re.SORTNAME_THE = /^The$/i; // match The
                    gc.re.SORTNAME_LOS = /^Los$/i; // match Los
                }
                var firstWord = words[0];
                if (firstWord.match(gc.re.SORTNAME_THE)) {
                    append = (", The" + append); // handle The xyz -> xyz, The
                    words[0] = null;
                } else if (firstWord.match(gc.re.SORTNAME_LOS)) {
                    append = (", Los" + append); // handle Los xyz -> xyz, Los
                    words[0] = null;
                }

                var t = [];
                for (i = 0; i < words.length; i++) {
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
                label = gc.u.trim(t.join(""));
            }

            if (!MB.utility.isNullOrEmpty(label)) {
                as[splitindex] = label;
            } else {
                delete as[splitindex];
            }
        }
        return gc.u.trim(as.join(collabSplit));
    };

    return self;
};
