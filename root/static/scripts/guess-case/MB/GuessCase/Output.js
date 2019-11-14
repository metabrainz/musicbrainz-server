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
import * as flags from '../../flags';
import * as utils from '../../utils';

MB.GuessCase = MB.GuessCase ? MB.GuessCase : {};

/**
 * Holds the output variables
 **/
MB.GuessCase.Output = function (gc) {
    var self = {};

    // ----------------------------------------------------------------------------
    // member variables
    // ---------------------------------------------------------------------------
    self._w = [];

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

    /**
     * Initialise the GcOutput object for another run
     **/
    self.init = function () {
        self._w = [];
        self._output = '';
    };

    /**
     * @returns the length
     **/
    self.getLength = function () {
       return self._w.length;
    };

    /**
     * @returns if the array is empty
     **/
    self.isEmpty = function () {
        var f = (self.getLength() == 0);
        return f;
    };

    /**
     * Fetches the current word from the GcInput
     * object, and appends it to the wordlist.
     **/
    self.appendCurrentWord = function () {
        var w;
        if ((w = gc.i.getCurrentWord()) != null) {
            self.appendWord(w);
        }
    };

    /**
     * Append the word w to the worlist
     *
     * @param w        the word
     **/
    self.appendWord = function (w) {
        if (w == ' ') {
            gc.o.appendSpace();
        } else if (w != '' && w != null) {
            self._w[self._w.length] = w;
        }
    };

    /**
     * Adds a space to the processed wordslist
     **/
    self.appendSpace = function () {
       self._w[self._w.length] = ' ';
    };

    /**
     * Checks the global flag spaceNextWord and adds a space to the
     * processed wordlist if needed. The flag is *NOT* reset.
     **/
    self.appendSpaceIfNeeded = function () {
        if (flags.context.spaceNextWord) {
            gc.o.appendSpace();
        }
    };

    /**
     * Returns the word at the index, or null if index outside bounds
     **/
    self.getWordAtIndex = function (index) {
        if (self._w[index]) {
            return self._w[index];
        }
        return null;
    };

    /**
     * Returns the word at the index, or null if index outside bounds
     **/
    self.setWordAtIndex = function (index, word) {
        if (self.getWordAtIndex(index)) {
            self._w[index] = word;
        }
    };

    /**
     * Returns the last word of the wordlist
     **/
    self.getLastWord = function () {
        if (!self.isEmpty()) {
            return self._w[self._w.length-1];
        }
        return null;
    };

    /**
     * Returns the last word of the wordlist
     **/
    self.dropLastWord = function () {
        if (!self.isEmpty()) {
            return self._w.pop();
        }
        return null;
    };

    /**
     * Capitalize the word at the current cursor position.
     **/
    self.capitalizeWordAtIndex = function (index, overrideCaps) {
        overrideCaps = (overrideCaps != null ? overrideCaps : flags.context.forceCaps);
        if ((!gc.mode.isSentenceCaps() || overrideCaps) &&
            (!self.isEmpty()) &&
            (self.getWordAtIndex(index) != null)) {
            // don't capitalize last word before puncuation/end of string in sentence mode.
            var w = self.getWordAtIndex(index), o = w;

            // check that last word is NOT an acronym.
            if (w.match(/^\w\..*/) == null) {
                // some words that were manipulated might have space padding
                var probe = utils.trim(w.toLowerCase());

                // If inside brackets, do nothing.
                if (!overrideCaps &&
                    flags.isInsideBrackets() &&
                    utils.isLowerCaseBracketWord(probe)) {

                    // If it is an UPPERCASE word,do nothing.
                } else if (!overrideCaps && gc.mode.isUpperCaseWord(probe)) {
                    // else capitalize the current word.
                } else {
                    // rewind pos pointer on input
                    var bef = gc.i.getPos(), pos = bef-1;
                    while (pos >= 0 && utils.trim(gc.i.getWordAtIndex(pos).toLowerCase()) != probe) {
                        pos--;
                    }
                    gc.i.setPos(pos);
                    o = utils.titleString(gc, w, overrideCaps);
                    // restore pos pointer on input
                    gc.i.setPos(bef);
                    if (w != o) {
                        self.setWordAtIndex(index, o);
                    }
                }
            }
        }
    };

    /**
     * Capitalize the word at the current cursor position.
     * Modifies the last element of the processed wordlist
     *
     * @param    overrideCaps    can be used to override
     *                            the flags.context.forceCaps parameter.
     **/
    self.capitalizeLastWord = function (overrideCaps) {
        self.capitalizeWordAtIndex(self.getLength()-1, overrideCaps);
    };

    /**
     * Apply post-processing, and return the string
     **/
    self.getOutput = function () {
        // if *not* sentence mode, force caps on last word.
        flags.context.forceCaps = !gc.mode.isSentenceCaps();
        self.capitalizeLastWord();

        self.closeOpenBrackets();
        return utils.trim(self._w.join(''));
    };

    /**
     * Work through the stack of opened parentheses and close them
     **/
    self.closeOpenBrackets = function () {
        var parts = new Array();
        while (flags.isInsideBrackets()) {
            // close brackets that were opened before
            parts[parts.length] = flags.popBracket();
        }
        self.appendWord(parts.join(''));
    };

    /**
     * This function checks the wordlist for spaces before
     * and after the current cursor position, and modifies
     * the spaces of the input string.
     *
     * @param c        configuration wrapper
     *                c.apply:     if true, apply changes
     *                c.capslast: if true, capitalize word before
     **/
    self.appendWordPreserveWhiteSpace = function (c) {
        if (c) {
            var ws = {before: gc.i.isPreviousWord(' '), after: gc.i.isNextWord(' ')};
            if (c.apply) {
                // do not register method, such that this message appears as
                // it were sent from the calling method.
                if (c.capslast) {
                    // capitalize last word before current
                    self.capitalizeLastWord(!gc.mode.isSentenceCaps());
                }
                if (ws.before) {
                    self.appendSpace();  // preserve whitespace before,
                }
                self.appendCurrentWord(); // append current word
                flags.context.spaceNextWord = (ws.after); // and afterwards as well
            }
            return ws;
        }
        return null;
    };

    return self;
}

export default MB.GuessCase.Output;
