/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import MB from '../../../common/MB';
import * as flags from '../../flags';
import * as utils from '../../utils';

MB.GuessCase = MB.GuessCase ? MB.GuessCase : {};

// Holds the output variables
MB.GuessCase.Output = function (gc) {
  var self = {};

  // Member variables
  self._w = [];

  // Member functions

  // Initialise the GcOutput object for another run
  self.init = function () {
    self._w = [];
    self._output = '';
  };

  // @returns the length
  self.getLength = function () {
    return self._w.length;
  };

  // @returns if the array is empty
  self.isEmpty = function () {
    var f = (self.getLength() == 0);
    return f;
  };

  /*
   * Fetches the current word from the GcInput
   * object, and appends it to the wordlist.
   */
  self.appendCurrentWord = function () {
    var w;
    if ((w = gc.i.getCurrentWord()) != null) {
      self.appendWord(w);
    }
  };

  /*
   * Append the word w to the worlist
   *
   * @param w the word
   */
  self.appendWord = function (w) {
    if (w == ' ') {
      gc.o.appendSpace();
    } else if (w != '' && w != null) {
      self._w[self._w.length] = w;
    }
  };

  // Adds a space to the processed wordslist
  self.appendSpace = function () {
    self._w[self._w.length] = ' ';
  };

  /*
   * Checks the global flag spaceNextWord and adds a space to the
   * processed wordlist if needed. The flag is *NOT* reset.
   */
  self.appendSpaceIfNeeded = function () {
    if (flags.context.spaceNextWord) {
      gc.o.appendSpace();
    }
  };

  // Returns the word at the index, or null if index outside bounds
  self.getWordAtIndex = function (index) {
    if (self._w[index]) {
      return self._w[index];
    }
    return null;
  };

  // Returns the word at the index, or null if index outside bounds
  self.setWordAtIndex = function (index, word) {
    if (self.getWordAtIndex(index)) {
      self._w[index] = word;
    }
  };

  // Returns the last word of the wordlist
  self.getLastWord = function () {
    if (self.isEmpty()) {
      return null;
    }
    return self._w[self._w.length-1];
  };

  // Returns the last word of the wordlist
  self.dropLastWord = function () {
    if (!self.isEmpty()) {
      return self._w.pop();
    }
    return null;
  };

  // Capitalize the word at the current cursor position.
  self.capitalizeWordAtIndex = function (index, overrideCaps) {
    overrideCaps = overrideCaps == null
      ? flags.context.forceCaps
      : overrideCaps;
    if ((!gc.mode.isSentenceCaps() || overrideCaps) &&
        (!self.isEmpty()) &&
        (self.getWordAtIndex(index) != null)) {
      /*
       * Don't capitalize last word before punctuation/end of string
       * in sentence mode.
       */
      const w = self.getWordAtIndex(index);
      let o = w;

      // Check that last word is NOT an acronym.
      if (w.match(/^\w\..*/) == null) {
        // Some words that were manipulated might have space padding
        var probe = utils.trim(w.toLowerCase());

        // If inside brackets, do nothing.
        if (!overrideCaps &&
            flags.isInsideBrackets() &&
            utils.isLowerCaseBracketWord(probe)) {

          // If it is an UPPERCASE word,do nothing.
        } else if (!overrideCaps && gc.mode.isUpperCaseWord(probe)) {
          // Else capitalize the current word.
        } else {
          // Rewind pos pointer on input
          const bef = gc.i.getPos();
          let pos = bef-1;
          while (pos >= 0 &&
                utils.trim(gc.i.getWordAtIndex(pos).toLowerCase()) != probe) {
            pos--;
          }
          gc.i.setPos(pos);
          o = utils.titleString(gc, w, overrideCaps);
          // Restore pos pointer on input
          gc.i.setPos(bef);
          if (w != o) {
            self.setWordAtIndex(index, o);
          }
        }
      }
    }
  };

  /*
   * Capitalize the word at the current cursor position.
   * Modifies the last element of the processed wordlist
   *
   * @param    overrideCaps    can be used to override
   *                            the flags.context.forceCaps parameter.
   */
  self.capitalizeLastWord = function (overrideCaps) {
    self.capitalizeWordAtIndex(self.getLength()-1, overrideCaps);
  };

  // Apply post-processing, and return the string
  self.getOutput = function () {
    // If *not* sentence mode, force caps on last word.
    flags.context.forceCaps = !gc.mode.isSentenceCaps();
    self.capitalizeLastWord();

    self.closeOpenBrackets();
    return utils.trim(self._w.join(''));
  };

  // Work through the stack of opened parentheses and close them
  self.closeOpenBrackets = function () {
    var parts = new Array();
    while (flags.isInsideBrackets()) {
      // Close brackets that were opened before
      parts[parts.length] = flags.popBracket();
    }
    self.appendWord(parts.join(''));
  };

  /*
   * This function checks the wordlist for spaces before
   * and after the current cursor position, and modifies
   * the spaces of the input string.
   *
   * @param c        configuration wrapper
   *                c.apply:     if true, apply changes
   *                c.capslast: if true, capitalize word before
   */
  self.appendWordPreserveWhiteSpace = function (c) {
    if (c) {
      var ws = {
        after: gc.i.isNextWord(' '),
        before: gc.i.isPreviousWord(' '),
      };
      if (c.apply) {
        /*
         * Do not register method, such that this message appears as
         * it were sent from the calling method.
         */
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
};

export default MB.GuessCase.Output;
