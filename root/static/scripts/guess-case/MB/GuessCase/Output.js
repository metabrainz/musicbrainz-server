/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../../flags';
import * as utils from '../../utils';

// Holds the output variables
class GuessCaseOutput {
  constructor(gc) {
    // Member variables
    this.gc = gc;
    this.wordList = [];
  }

  // Member functions

  // Initialise the GcOutput object for another run
  init() {
    this.wordList = [];
  }

  // Returns the length of the wordlist
  getLength() {
    return this.wordList.length;
  }

  isEmpty() {
    return this.getLength() === 0;
  }

  /*
   * Fetches the current word from the GcInput
   * object, and appends it to the wordlist.
   */
  appendCurrentWord() {
    const w = this.gc.input.getCurrentWord();
    if (w != null) {
      this.appendWord(w);
    }
  }

  appendWord(w) {
    if (w === ' ') {
      this.gc.output.appendSpace();
    } else if (w !== '' && w != null) {
      this.wordList[this.wordList.length] = w;
    }
  }

  // Adds a space to the processed wordlist
  appendSpace() {
    this.wordList[this.wordList.length] = ' ';
  }

  /*
   * Checks the global flag spaceNextWord and adds a space to the
   * processed wordlist if needed. The flag is *NOT* reset.
   */
  appendSpaceIfNeeded() {
    if (flags.context.spaceNextWord) {
      this.gc.output.appendSpace();
    }
  }

  getWordAtIndex(index) {
    if (this.wordList[index]) {
      return this.wordList[index];
    }
    return null;
  }

  setWordAtIndex(index, word) {
    if (this.getWordAtIndex(index)) {
      this.wordList[index] = word;
    }
  }

  getLastWord() {
    if (this.isEmpty()) {
      return null;
    }
    return this.wordList[this.wordList.length - 1];
  }

  capitalizeWordAtIndex(index, overrideCaps) {
    overrideCaps = overrideCaps == null
      ? flags.context.forceCaps
      : overrideCaps;
    if ((!this.gc.mode.isSentenceCaps() || overrideCaps) &&
        (!this.isEmpty()) &&
        (this.getWordAtIndex(index) != null)) {
      /*
       * Don't capitalize last word before punctuation/end of string
       * in sentence mode.
       */
      const w = this.getWordAtIndex(index);
      let o = w;

      // Check that last word is NOT an acronym.
      if (w.match(/^\w\..*/) == null) {
        // Some words that were manipulated might have space padding
        const probe = utils.trim(w.toLowerCase());

        // If inside brackets, do nothing.
        if (!overrideCaps &&
            flags.isInsideBrackets() &&
            utils.isLowerCaseBracketWord(probe)) {

          // If it is an UPPERCASE word,do nothing.
        } else if (!overrideCaps && this.gc.mode.isUpperCaseWord(probe)) {
          // Else capitalize the current word.
        } else {
          // Rewind pos pointer on input
          const bef = this.gc.input.getCursorPosition();
          let pos = bef - 1;
          while (pos >= 0 &&
                 utils.trim(
                   this.gc.input.getWordAtIndex(pos).toLowerCase(),
                 ) !== probe) {
            pos--;
          }
          this.gc.input.setCursorPosition(pos);
          o = utils.titleString(this.gc, w, overrideCaps);
          // Restore pos pointer on input
          this.gc.input.setCursorPosition(bef);
          if (w !== o) {
            this.setWordAtIndex(index, o);
          }
        }
      }
    }
  }

  /*
   * Capitalize the last element of the processed wordlist
   *
   * overrideCaps can be used to override
   * the flags.context.forceCaps parameter.
   */
  capitalizeLastWord(overrideCaps) {
    this.capitalizeWordAtIndex(this.getLength() - 1, overrideCaps);
  }

  // Apply post-processing, and return the string
  getOutput() {
    // If *not* sentence mode, force caps on last word.
    flags.context.forceCaps = !this.gc.mode.isSentenceCaps();
    this.capitalizeLastWord();

    this.closeOpenBrackets();
    return utils.trim(this.wordList.join(''));
  }

  // Work through the stack of opened parentheses and close them
  closeOpenBrackets() {
    const parts = new Array();
    while (flags.isInsideBrackets()) {
      // Close brackets that were opened before
      parts[parts.length] = flags.popBracket();
    }
    this.appendWord(parts.join(''));
  }

  /*
   * This function checks the wordlist for spaces before
   * and after the current cursor position, and modifies
   * the spaces of the input string.
   *
   * param c is a configuration wrapper:
   * c.apply: if true, apply changes
   * c.capslast: if true, capitalize word before
   */
  appendWordPreserveWhiteSpace(c) {
    if (c) {
      const ws = {
        after: this.gc.input.isNextWord(' '),
        before: this.gc.input.isPreviousWord(' '),
      };
      if (c.apply) {
        /*
         * Do not register method, such that this message appears as
         * it were sent from the calling method.
         */
        if (c.capslast) {
          // capitalize last word before current
          this.capitalizeLastWord(!this.gc.mode.isSentenceCaps());
        }
        if (ws.before) {
          this.appendSpace();  // preserve whitespace before,
        }
        this.appendCurrentWord(); // append current word
        flags.context.spaceNextWord = (ws.after); // and afterwards as well
      }
      return ws;
    }
    return null;
  }
}

export default GuessCaseOutput;
