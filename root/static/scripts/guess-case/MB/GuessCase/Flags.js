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
 * Holds the state of the current GC operation
 */
MB.GuessCase.Flags = function () {
    var self = {};

    /**
     * Reset the context
     **/
    self.resetContext = function () {
        self.whitespace = false;
        self.openingBracket = false;
        self.hypen = false;
        self.colon = false;
        self.acronym_split = false;
        self.singlequote = false;
        self.ellipsis = false;
    };

    /**
     * Reset the variables for the SeriesNumberStyle
     **/
    self.resetSeriesNumberStyleFlags = function () {
        self.disc = false; // flag is used for the detection of SeriesStyles
        self.part = false;
        self.volume = false;
        self.feat = false;
    };

    /**
     * Reset the variables for the processed string
     **/
    self.resetOutputFlags = function () {
        // flag to force next to caps first letter.
        // seeded true because the first word is always capped
        self.forceCaps = true;
         // flag to force a space before the next word
        self.spaceNextWord = false;
    };

    /**
     * Reset the open/closed bracket variables
     **/
    self.resetBrackets = function () {
        self.openBrackets = new Array();
        self.slurpExtraTitleInformation = false;
    };

    /**
     * Returns if there are opened brackets at current position
     * in the string.
     **/
    self.isInsideBrackets = function () {
        return (self.openBrackets.length > 0);
    };

    self.pushBracket = function (b) {
        self.openBrackets.push(b);
    };

    self.popBracket = function (b) {
        if (self.openBrackets.length == 0) {
            return null;
        } else {
            var cb = self.getCurrentCloseBracket();
            self.openBrackets.pop();
            return cb;
        }
    };

    self.getOpenedBracket = function (b) {
        if (self.openBrackets.length == 0) {
            return null;
        } else {
            return self.openBrackets[self.openBrackets.length-1];
        }
    };

    self.getCurrentCloseBracket = function () {
        var ob;
        if ((ob = self.getOpenedBracket()) != null) {
            return gc.u.getCorrespondingBracket(ob);
        }
        return null;
    };

    /**
     * Initialise GcFlags object for another run
     **/
    self.init = function () {
        self.resetOutputFlags();
        self.resetBrackets();
        self.resetContext();
        self.resetSeriesNumberStyleFlags();
        self.acronym = false; // flag so we know not to lowercase acronyms if followed by major punctuation
        self.number = false; // flag is used for the number splitting routine (ie: 10,000,000)

        // defines the current number split. note that this will not be cleared, which
        // has the side-effect of forcing the first type of number split encountered
        // to be the only one used for the entire string,assuming that people aren't
        // going to be mixing grammar in titles.
        self.numberSplitChar = null;
        self.numberSplitExpect = false;
    };

    self.init();

    return self;
}
