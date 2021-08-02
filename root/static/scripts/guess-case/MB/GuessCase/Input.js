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
    this._source = '';
    this._w = [];
    this._l = 0;
    this._wi = 0;
  }

  // Member functions

  // Initialise the GcInput object
  init(is, w) {
    this._source = (is || '');
    this._w = (w || []);
    this._l = this._w.length;
    this._wi = 0;
  }

  // Returns the length of the wordlist
  getLength() {
    return this._l;
  }

  // Returns true if the lenght==0
  isEmpty() {
    const f = (this.getLength() === 0);
    return f;
  }

  // Get the cursor position
  getPos() {
    return this._wi;
  }

  // Set the cursor to a new position
  setPos(index) {
    if (index >= 0 && index < this.getLength()) {
      this._wi = index;
    }
  }

  // Accessors for strings at certain positions.
  getWordAtIndex(index) {
    return (this._w[index] || null);
  }

  getNextWord() {
    return this.getWordAtIndex(this._wi + 1);
  }

  getCurrentWord() {
    return this.getWordAtIndex(this._wi);
  }

  getPreviousWord() {
    return this.getWordAtIndex(this._wi - 1);
  }

  // Test methods
  isFirstWord() {
    return (0 === this._wi);
  }

  isLastWord() {
    return (this.getLength() === this._wi - 1);
  }

  isNextWord(s) {
    return (this.hasMoreWords() && this.getNextWord() === s);
  }

  isPreviousWord(s) {
    return (!this.isFirstWord() && this.getPreviousWord() === s);
  }

  /*
   * Match the word at the current index against the
   * regular expression or string given
   */
  matchCurrentWord(re) {
    return this.matchWordAtIndex(this.getPos(), re);
  }

  /*
   * Match the word at index wi against the
   * regular expression or string given
   */
  matchWordAtIndex(index, re) {
    const cw = (this.getWordAtIndex(index) || '');
    let f;
    if (typeof re === 'string') {
      f = (re === cw);
    } else {
      f = (cw.match(re) != null);
    }
    return f;
  }

  // Index methods
  hasMoreWords() {
    return (this._wi === 0 && this.getLength() > 0 ||
            this._wi - 1 < this.getLength());
  }

  isIndexAtEnd() {
    return (this._wi === this.getLength());
  }

  nextIndex() {
    this._wi++;
  }

  // Returns the last word of the wordlist
  dropLastWord() {
    if (this.getLength() > 0) {
      this._w.pop();
      if (this.isIndexAtEnd()) {
        this._wi--;
      }
    }
  }

  // Capitalize the word at the current position
  insertWordsAtIndex(index, w) {
    const part1 = this._w.slice(0, index);
    const part2 = this._w.slice(index, this._w.length);
    this._w = part1.concat(w).concat(part2);
    this._l = this._w.length;
  }

  // Capitalize the word at the current position
  capitalizeCurrentWord() {
    const w = this.getCurrentWord();
    if (w != null) {
      const o = utils.titleString(this.gc, w);
      if (w !== o) {
        this.updateCurrentWord(o);
      }
      return o;
    }
    return null;
  }

  // Update the word at the current position
  updateCurrentWord(o) {
    const w = this.getCurrentWord();
    if (w != null) {
      this._w[this._wi] = o;
    }
  }

  // Insert a word at the end of the wordlist
  insertWordAtEnd(w) {
    this._w[this._w.length] = w;
    this._l++;
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
  splitWordsAndPunctuation(is) {
    is = is.replace(/^\s\s*/, ''); // delete leading space
    is = is.replace(/\s\s*$/, ''); // delete trailing space
    is = is.replace(/\s\s*/g, ' '); // compress whitespace:
    const chars = is.split('');
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
