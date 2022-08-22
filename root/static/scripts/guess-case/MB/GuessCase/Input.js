/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as utils from '../../utils.js';

import gc from './Main.js';

/*
 * Holds the input variables
 */
class GuessCaseInput {
  source: string;

  wordIndex: number;

  wordList: Array<string>;

  constructor() {
    // Member variables
    this.source = '';
    this.wordList = [];
    this.wordIndex = 0;
  }

  // Member functions

  // Initialise the GcInput object
  init(inputString: string, wordlist: Array<string>) {
    this.source = (inputString || '');
    this.wordList = (wordlist || []);
    this.wordIndex = 0;
  }

  // Returns the length of the wordlist
  getLength(): number {
    return this.wordList.length;
  }

  isEmpty(): boolean {
    return this.getLength() === 0;
  }

  getCursorPosition(): number {
    return this.wordIndex;
  }

  setCursorPosition(index: number) {
    if (index >= 0 && index < this.getLength()) {
      this.wordIndex = index;
    }
  }

  getWordAtIndex(index: number): string | null {
    return (this.wordList[index] || null);
  }

  getNextWord(): string | null {
    return this.getWordAtIndex(this.wordIndex + 1);
  }

  getCurrentWord(): string | null {
    return this.getWordAtIndex(this.wordIndex);
  }

  getPreviousWord(): string | null {
    return this.getWordAtIndex(this.wordIndex - 1);
  }

  isFirstWord(): boolean {
    return (this.wordIndex === 0);
  }

  isLastWord(): boolean {
    return (this.getLength() === this.wordIndex - 1);
  }

  isNextWord(word: string): boolean {
    return (this.hasMoreWords() && this.getNextWord() === word);
  }

  isPreviousWord(word: string): boolean {
    return (!this.isFirstWord() && this.getPreviousWord() === word);
  }

  /*
   * Match the word at the current index against the
   * regular expression or string given
   */
  matchCurrentWord(regex: RegExp | string): boolean {
    return this.matchWordAtIndex(this.getCursorPosition(), regex);
  }

  /*
   * Match the word at the given index against the
   * regular expression or string given
   */
  matchWordAtIndex(index: number, regex: RegExp | string): boolean {
    const word = (this.getWordAtIndex(index) || '');
    let result;
    if (typeof regex === 'string') {
      result = (regex === word);
    } else {
      result = (word.match(regex) != null);
    }
    return result;
  }

  hasMoreWords(): boolean {
    return (this.wordIndex === 0 && this.getLength() > 0 ||
            this.wordIndex - 1 < this.getLength());
  }

  isIndexAtEnd(): boolean {
    return (this.wordIndex === this.getLength());
  }

  nextIndex() {
    this.wordIndex++;
  }

  dropLastWord() {
    if (this.getLength() > 0) {
      this.wordList.pop();
      if (this.isIndexAtEnd()) {
        this.wordIndex--;
      }
    }
  }

  insertWordsAtIndex(index: number, newWords: $ReadOnlyArray<string>) {
    const part1 = this.wordList.slice(0, index);
    const part2 = this.wordList.slice(index, this.wordList.length);
    this.wordList = part1.concat(newWords).concat(part2);
  }

  capitalizeCurrentWord(): string | null {
    const word = this.getCurrentWord();
    if (word == null) {
      return null;
    }
    const output = utils.titleString(word);
    if (word !== output) {
      this.updateCurrentWord(output);
    }
    return output;
  }

  updateCurrentWord(word: string) {
    if (this.wordIndex < this.wordList.length) {
      this.wordList[this.wordIndex] = word;
    }
  }

  /*
   * This function returns an array of all the words, punctuation and
   * spaces of the input string
   *
   * Before splitting the string into the different candidates,
   * the following actions are taken:
   * 1) remove leading and trailing whitespace
   * 2) compress whitespace, e.g replace all instances
   *    of multiple space with a single space
   * @param is the un-processed input string
   * @returns sets the GLOBAL array of words and puctuation characters
   */
  splitWordsAndPunctuation(inputString: string): Array<string> {
    let input = inputString;
    input = input.replace(/^\s\s*/, ''); // delete leading space
    input = input.replace(/\s\s*$/, ''); // delete trailing space
    input = input.replace(/\s\s*/g, ' '); // compress whitespace:
    const chars = input.split('');
    const splitwords = [];
    let word: Array<string> = [];
    if (!gc.regexes.SPLITWORDSANDPUNCTUATION) {
      gc.regexes.SPLITWORDSANDPUNCTUATION = /[^!¿¡\"%&'´`‘’‹›“”„“«»()\[\]\{\}\*\+‐\-,\.\/:;<=>\?\s#]/;
    }
    for (let i = 0; i < chars.length; i++) {
      if (chars[i].match(gc.regexes.SPLITWORDSANDPUNCTUATION)) {
        /*
         * See http://www.codingforums.com/archive/index.php/t-49001
         * for reference (escaping the sequence)
         */
        // greedy match anything except our stop characters
        word.push(chars[i]);
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
  }
}

export default (new GuessCaseInput(): GuessCaseInput);
