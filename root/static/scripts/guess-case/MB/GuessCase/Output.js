/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../../flags.js';
import * as modes from '../../modes.js';
import type {GuessCaseModeNameT} from '../../types.js';
import titleString from '../../utils/titleString.js';
import trim from '../../utils/trim.js';
import {isLowerCaseBracketWord} from '../../utils/wordCheckers.js';

import type GuessCaseInput from './Input.js';

// Holds the output variables
class GuessCaseOutput {
  CFG_KEEP_UPPERCASED: boolean;

  input: GuessCaseInput;

  modeName: GuessCaseModeNameT;

  wordList: Array<string>;

  constructor(
    input: GuessCaseInput,
    modeName: GuessCaseModeNameT,
    CFG_KEEP_UPPERCASED: boolean,
  ) {
    this.CFG_KEEP_UPPERCASED = CFG_KEEP_UPPERCASED;
    this.modeName = modeName;
    this.input = input;
    this.wordList = [];
  }

  // Member functions

  // Returns the length of the wordlist
  getLength(): number {
    return this.wordList.length;
  }

  isEmpty(): boolean {
    return this.getLength() === 0;
  }

  /*
   * Fetches the current word from the GcInput
   * object, and appends it to the wordlist.
   */
  appendCurrentWord() {
    const currentWord = this.input.getCurrentWord();
    if (currentWord != null) {
      this.appendWord(currentWord);
    }
  }

  appendWord(word: string | null) {
    if (word === ' ') {
      this.appendSpace();
    } else if (word !== '' && word != null) {
      this.wordList.push(word);
    }
  }

  // Adds a space to the processed wordlist
  appendSpace() {
    this.wordList.push(' ');
  }

  /*
   * Checks the global flag spaceNextWord and adds a space to the
   * processed wordlist if needed. The flag is *NOT* reset.
   */
  appendSpaceIfNeeded() {
    if (flags.context.spaceNextWord) {
      this.appendSpace();
    }
  }

  getWordAtIndex(index: number): string | null {
    if (this.wordList[index]) {
      return this.wordList[index];
    }
    return null;
  }

  setWordAtIndex(index: number, word: string) {
    if (this.getWordAtIndex(index)) {
      this.wordList[index] = word;
    }
  }

  getLastWord(): string | null {
    if (this.isEmpty()) {
      return null;
    }
    return this.wordList[this.wordList.length - 1];
  }

  capitalizeWordAtIndex(index: number, overrideCaps?: boolean) {
    const forceCaps = overrideCaps == null
      ? flags.context.forceCaps
      : overrideCaps;
    if ((!modes[this.modeName].isSentenceCaps() || forceCaps) &&
        (!this.isEmpty())) {
      const word = this.getWordAtIndex(index);
      if (word != null) {
        let output = word;

        // Check that last word is NOT an acronym.
        if (word.match(/^\w\..*/) == null) {
          // Some words that were manipulated might have space padding
          const probe = trim(word.toLowerCase());

          if (!forceCaps &&
              flags.isInsideBrackets() &&
              isLowerCaseBracketWord(probe)) {
            // If inside brackets, do nothing.
          } else if (
            !forceCaps && modes[this.modeName].isUpperCaseWord(probe)
          ) {
            // If it is an UPPERCASE word,do nothing.
          } else { // Else capitalize the current word.
            // Rewind pos pointer on input
            const originalPosition = this.input.getCursorPosition();
            let position = originalPosition - 1;
            while (position >= 0) {
              const word = this.input.getWordAtIndex(position);
              if (word == null || trim(word.toLowerCase()) === probe) {
                break;
              }
              position--;
            }
            this.input.setCursorPosition(position);
            output = titleString(
              this.input,
              this,
              word,
              this.modeName,
              this.CFG_KEEP_UPPERCASED,
              forceCaps,
            );
            // Restore pos pointer on input
            this.input.setCursorPosition(originalPosition);
            if (word !== output) {
              this.setWordAtIndex(index, output);
            }
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
  capitalizeLastWord(overrideCaps?: boolean) {
    this.capitalizeWordAtIndex(this.getLength() - 1, overrideCaps);
  }

  // Apply post-processing, and return the string
  getOutput(): string {
    // If *not* sentence mode, force caps on last word.
    flags.context.forceCaps = !modes[this.modeName].isSentenceCaps();
    this.capitalizeLastWord();

    this.closeOpenBrackets();
    return trim(this.wordList.join(''));
  }

  // Work through the stack of opened parentheses and close them
  closeOpenBrackets() {
    const parts = [];
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
   */
  appendWordPreserveWhiteSpace(capitalizeLast: boolean) {
    const whitespace = {
      after: this.input.isNextWord(' '),
      before: this.input.isPreviousWord(' '),
    };
    if (capitalizeLast) {
      // capitalize last word before current
      this.capitalizeLastWord(!modes[this.modeName].isSentenceCaps());
    }
    if (whitespace.before) {
      // preserve whitespace before,
      this.appendSpace();
    }
    this.appendCurrentWord();
    // preserve whitespace after
    flags.context.spaceNextWord = (whitespace.after);
  }
}

export default GuessCaseOutput;
