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

import _ from 'lodash';

import MB from '../../../common/MB';
import * as utils from '../../utils';


MB.GuessCase = MB.GuessCase ? MB.GuessCase : {};

/**
 * Holds the input variables
 **/
MB.GuessCase.Input = function (gc) {
    var self = {};

    // ----------------------------------------------------------------------------
    // member variables
    // ---------------------------------------------------------------------------
    self._source = '';
    self._w = [];
    self._l = 0;
    self._wi = 0;

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

    /**
     * Initialise the GcInput object
     **/
    self.init = function (is, w) {
        self._source = (is || '');
        self._w = (w || []);
        self._l = self._w.length;
        self._wi = 0;
    };

    /**
     * Returns the length of the wordlist
     **/
    self.getLength = function () {
        return self._l;
    };

    /**
     * Returns true if the lenght==0
     **/
    self.isEmpty = function () {
        var f = (self.getLength() == 0);
        return f;
    };

    /**
     * Get the cursor position
     **/
    self.getPos = function () {
        return self._wi;
    };

    /**
     * Set the cursor to a new position
     **/
    self.setPos = function (index) {
        if (index >= 0 && index < self.getLength()) {
            self._wi = index;
        }
    };

    /**
     * Accessors for strings at certain positions.
     **/
    self.getWordAtIndex = function (index) {
        return (self._w[index] || null);
    };

    self.getNextWord = function () {
        return self.getWordAtIndex(self._wi+1);
    };

    self.getCurrentWord = function () {
        return self.getWordAtIndex(self._wi);
    };

    self.getPreviousWord = function () {
        return self.getWordAtIndex(self._wi-1);
    };

    /**
     * Test methods
     **/
    self.isFirstWord = function () {
        return (0 == self._wi);
    };

    self.isLastWord = function () {
        return (self.getLength() == self._wi-1);
    };

    self.isNextWord = function (s) {
        return (self.hasMoreWords() && self.getNextWord() == s);
    };

    self.isPreviousWord = function (s) {
        return (!self.isFirstWord() && self.getPreviousWord() == s);
    };

    /**
     * Match the word at the current index against the
     * regular expression or string given
     **/
    self.matchCurrentWord = function (re) {
        return self.matchWordAtIndex(self.getPos(), re);
    };

    /**
     * Match the word at index wi against the
     * regular expression or string given
     **/
    self.matchWordAtIndex = function (index, re) {
        var cw = (self.getWordAtIndex(index) || '');
        var f;
        if (_.isString(re)) {
            f = (re == cw);
        } else {
            f = (cw.match(re) != null);
        }
        return f;
    };

    /**
     * Index methods
     **/
    self.hasMoreWords = function () {
        return (self._wi == 0 && self.getLength() > 0 || self._wi-1 < self.getLength());
    };

    self.isIndexAtEnd = function () {
        return (self._wi == self.getLength());
    };

    self.nextIndex = function () {
        self._wi++;
    };

    /**
     * Returns the last word of the wordlist
     **/
    self.dropLastWord = function () {
        if (self.getLength() > 0) {
            self._w.pop();
            if (self.isIndexAtEnd()) {
                self._wi--;
            }
        }
    };

    /**
     * Capitalize the word at the current position
     **/
    self.insertWordsAtIndex = function (index, w) {
        var part1 = self._w.slice(0, index);
        var part2 = self._w.slice(index, self._w.length);
        self._w = part1.concat(w).concat(part2);
        self._l = self._w.length;
    };

    /**
     * Capitalize the word at the current position
     **/
    self.capitalizeCurrentWord = function () {
        var w;
        if ((w = self.getCurrentWord()) != null) {
            var o = utils.titleString(gc, w);
            if (w != o) {
                self.updateCurrentWord(o);
            }
            return o;
        }
        return null;
    };

    /**
     * Update the word at the current position
     **/
    self.updateCurrentWord = function (o) {
        var w = self.getCurrentWord();
        if (w != null) {
            self._w[self._wi] = o;
        }
    };

    /**
     * Insert a word at the end of the wordlist
     **/
    self.insertWordAtEnd = function (w) {
        self._w[self._w.length] = w;
        self._l++;
    };

    /**
     * This function returns an array of all the words, punctuation and
     * spaces of the input string
     *
     * Before splitting the string into the different candidates,the following actions are taken:
     *  * remove leading and trailing whitespace
     *  * compress whitespace,e.g replace all instances of multiple space with a single space
     * @param   is      the un-processed input string
     * @returns         sets the GLOBAL array of words and puctuation characters
     **/
    self.splitWordsAndPunctuation = function (is) {
        is = is.replace(/^\s\s*/, ''); // delete leading space
        is = is.replace(/\s\s*$/, ''); // delete trailing space
        is = is.replace(/\s\s*/g, ' '); // compress whitespace:
        var chars = is.split('');
        var splitwords = [];
        var word = [];
        if (!gc.re.SPLITWORDSANDPUNCTUATION) {
            gc.re.SPLITWORDSANDPUNCTUATION = /[^!¿¡\"%&'´`‘’()\[\]\{\}\*\+,-\.\/:;<=>\?\s#]/;
        }
        for (var i = 0; i < chars.length; i++) {
            if (chars[i].match(gc.re.SPLITWORDSANDPUNCTUATION)) {
                // see http://www.codingforums.com/archive/index.php/t-49001
                // for reference (escaping the sequence)
                word.push(chars[i]); // greedy match anything except our stop characters
            } else {
                if (word.length > 0) {
                    splitwords.push(word.join(''));
                }
                splitwords.push(chars[i]);
                word = [];
            }
        }
        if (word.length > 0) {
            splitwords.push(word.join(''));
        }
        return splitwords;
    };

    return self;
};

export default MB.GuessCase.Input;
