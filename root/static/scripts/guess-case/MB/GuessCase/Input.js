/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as utils from '../../utils';

/*
 * Holds the input variables
 */
class GuessCaseInput {
  constructor(gc) {
    // Member variables
    this.gc = gc;
    this.source = '';
    this.wordList = [];
    this.wordIndex = 0;
  }

  // Member functions

  // Initialise the GcInput object
  init(inputString, wordlist) {
    this.source = (inputString || '');
    this.wordList = (wordlist || []);
    this.wordIndex = 0;
  }

  // Returns the length of the wordlist
  getLength() {
    return this.wordList.length;
  }

  isEmpty() {
    return this.getLength() === 0;
  }

  getCursorPosition() {
    return this.wordIndex;
  }

  setCursorPosition(index) {
    if (index >= 0 && index < this.getLength()) {
      this.wordIndex = index;
    }
  }

  getWordAtIndex(index) {
    return (this.wordList[index] || null);
  }

  getNextWord() {
    return this.getWordAtIndex(this.wordIndex + 1);
  }

  getCurrentWord() {
    return this.getWordAtIndex(this.wordIndex);
  }

  getPreviousWord() {
    return this.getWordAtIndex(this.wordIndex - 1);
  }

  isFirstWord() {
    return (this.wordIndex === 0);
  }

  isLastWord() {
    return (this.getLength() === this.wordIndex - 1);
  }

  isNextWord(word) {
    return (this.hasMoreWords() && this.getNextWord() === word);
  }

  isPreviousWord(word) {
    return (!this.isFirstWord() && this.getPreviousWord() === word);
  }

  /*
   * Match the word at the current index against the
   * regular expression or string given
   */
  matchCurrentWord(regex) {
    return this.matchWordAtIndex(this.getCursorPosition(), regex);
  }

  /*
   * Match the word at the given index against the
   * regular expression or string given
   */
  matchWordAtIndex(index, regex) {
    const word = (this.getWordAtIndex(index) || '');
    let result;
    if (typeof regex === 'string') {
      result = (regex === word);
    } else {
      result = (word.match(regex) != null);
    }
    return result;
  }

  hasMoreWords() {
    return (this.wordIndex === 0 && this.getLength() > 0 ||
            this.wordIndex - 1 < this.getLength());
  }

  isIndexAtEnd() {
    return (this.wordIndex === this.getLength());
  }

  nextIndex() {
    this.wordIndex++;
  }

  // Returns the last word of the wordlist
  dropLastWord() {
    if (this.getLength() > 0) {
      this.wordList.pop();
      if (this.isIndexAtEnd()) {
        this.wordIndex--;
      }
    }
  }

  insertWordsAtIndex(index, newWords) {
    const part1 = this.wordList.slice(0, index);
    const part2 = this.wordList.slice(index, this.wordList.length);
    this.wordList = part1.concat(newWords).concat(part2);
  }

  capitalizeCurrentWord() {
    const word = this.getCurrentWord();
    if (word != null) {
      const output = utils.titleString(this.gc, word);
      if (word !== output) {
        this.updateCurrentWord(output);
      }
      return output;
    }
    return null;
  }

  updateCurrentWord(word) {
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
  splitWordsAndPunctuation(inputString) {
    inputString = inputString.replace(/^\s\s*/, ''); // delete leading space
    inputString = inputString.replace(/\s\s*$/, ''); // delete trailing space
    inputString = inputString.replace(/\s\s*/g, ' '); // compress whitespace:
    const chars = inputString.split('');
    const splitwords = [];
    let word = [];
    if (!this.gc.regexes.SPLITWORDSANDPUNCTUATION) {
      this.gc.regexes.SPLITWORDSANDPUNCTUATION = /[^!¿¡\"%&'´`‘’‹›“”„“«»()\[\]\{\}\*\+,-\.\/:;<=>\?\s#]/;
    }
    for (let i = 0; i < chars.length; i++) {
      if (chars[i].match(this.gc.regexes.SPLITWORDSANDPUNCTUATION)) {
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

export default GuessCaseInput;
