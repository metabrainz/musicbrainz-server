/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../../../flags.js';
import * as modes from '../../../modes.js';
import {type GuessCaseModeNameT} from '../../../types.js';
import trim from '../../../utils/trim.js';
import {isLowerCaseBracketWord} from '../../../utils/wordCheckers.js';
import type GuessCaseInput from '../Input.js';
import type GuessCaseOutput from '../Output.js';

// Base class of the type specific handlers
class GuessCaseHandler {
  specialCaseValues: {[name: string]: number};

  input: GuessCaseInput;

  modeName: GuessCaseModeNameT;

  output: GuessCaseOutput;

  regexes: {
    [regexName: string]: RegExp,
  };

  constructor(
    modeName: GuessCaseModeNameT,
    regexes: {[regexName: string]: RegExp},
    input: GuessCaseInput,
    output: GuessCaseOutput,
  ) {
    this.modeName = modeName;
    this.regexes = regexes;
    this.input = input;
    this.output = output;
    this.specialCaseValues = {
      NOT_A_SPECIALCASE: -1,
      SPECIALCASE_CROWD_NOISE: 33,  // [crowd noise]
      SPECIALCASE_DATA_TRACK: 30,   // [data track]
      SPECIALCASE_DIALOGUE: 35,     // [dialogue]
      SPECIALCASE_GUITAR_SOLO: 34,  // [guitar solo]
      SPECIALCASE_SILENCE: 31,      // [silence]
      SPECIALCASE_UNKNOWN: 10,      // [unknown]
      SPECIALCASE_UNTITLED: 32,     // [untitled]
    };
  }

  // Member functions

  /*
   * The `inputString` argument is specified to prevent Flow from
   * triggering an extra-arg error where we invoke `checkSpecialCase`.
   */
  checkSpecialCase(/*:: inputString?: string */): number {
    return this.specialCaseValues.NOT_A_SPECIALCASE;
  }

  // Returns true if the number corresponds to a special case.
  isSpecialCase(number: number): boolean {
    return (number !== this.specialCaseValues.NOT_A_SPECIALCASE);
  }

  /*
   * Returns the correctly formatted string of the
   * special case, or the input string if num
   * does not correspond to a special case
   */
  getSpecialCaseFormatted(inputString: string, number: number): string {
    switch (number) {
      case this.specialCaseValues.SPECIALCASE_DATA_TRACK:
        return '[data track]';

      case this.specialCaseValues.SPECIALCASE_SILENCE:
        return '[silence]';

      case this.specialCaseValues.SPECIALCASE_UNTITLED:
        return '[untitled]';

      case this.specialCaseValues.SPECIALCASE_UNKNOWN:
        return '[unknown]';

      case this.specialCaseValues.SPECIALCASE_CROWD_NOISE:
        return '[crowd noise]';

      case this.specialCaseValues.SPECIALCASE_GUITAR_SOLO:
        return '[guitar solo]';

      case this.specialCaseValues.SPECIALCASE_DIALOGUE:
        return '[dialogue]';

      case this.specialCaseValues.NOT_A_SPECIALCASE:
      default:
        return inputString;
    }
  }

  getWordsForProcessing(inputString: string): Array<string> {
    return this.input.splitWordsAndPunctuation(inputString);
  }

  process(inputString: string): string {
    this.input.init(this.getWordsForProcessing(inputString), this.output);
    while (!this.input.isIndexAtEnd()) {
      this.processWord();
    }
    return modes[this.modeName].runPostProcess(this.output.getOutput());
  }

  /*
   * Processes the next word from the GuessCaseInput
   * returns true, if there are more words, else false.
   */
  processWord() {
    if (!this.doWhiteSpace()) {
      // Dump information if in debug mode.

      /*
       * Try to decide if we need to check all the special cases,
       * or if it's possibly just a plain word. This should improve
       * performance a bit, since we don't have to go through all
       * the regex expressions to find that we didn't have to
       * check them.
       */
      let handled = false;
      if (!this.regexes.SPECIALCASES) {
        this.regexes.SPECIALCASES = /(&|¿|¡|\?|!|;|:|'|‘|’|‹|›|"|“|”|„|“|«|»|-|‐|\+|,|\*|\.|#|%|\/|\(|\)|\{|\}|\[|\])/;
      }
      if (this.input.matchCurrentWord(this.regexes.SPECIALCASES)) {
        handled = this.doDoubleQuote() ||
          this.doSingleQuote() ||
          this.doOpeningBracket() ||
          this.doClosingBracket() ||
          this.doComma() ||
          this.doPeriod() ||
          this.doLineStop() ||
          this.doAmpersand() ||
          this.doSlash() ||
          this.doColon() ||
          this.doHyphen() ||
          this.doInvertedMarks() ||
          this.doPlus() ||
          this.doAsterisk() ||
          this.doDiamond() ||
          this.doPercent();
      }
      (
        handled ||
        this.doDigits() ||
        this.doAcronym() ||
        this.doWord()
      );
    }
    this.input.nextIndex();
  }

  // Delegate function for specific handlers
  doWord(): boolean {
    return true;
  }

  doNormalWord() {
    this.output.appendSpaceIfNeeded();
    this.input.capitalizeCurrentWord();
    this.output.appendCurrentWord();
    flags.resetContext();
    flags.context.forceCaps = false;
    flags.context.spaceNextWord = true;
  }

  /*
   * Deal with whitespace (\t)
   * Primarily we only look at whitespace for context purposes
   */
  doWhiteSpace(): boolean {
    if (!this.regexes.WHITESPACE) {
      this.regexes.WHITESPACE = /^ $/;
    }
    if (this.input.matchCurrentWord(this.regexes.WHITESPACE)) {
      flags.context.whitespace = true;
      flags.context.spaceNextWord = true;
      if (flags.context.openingBracket) {
        flags.context.spaceNextWord = false;
      }
      return true;
    }
    return false;
  }

  /*
   * Deal with colons (:)
   * Colons are used as a sub-title split,and also for disc/box name splits
   */
  doColon(): boolean {
    if (!this.regexes.COLON) {
      this.regexes.COLON = /^:$/;
    }

    if (this.input.matchCurrentWord(this.regexes.COLON)) {
      /*
       * Capitalize the last word before the colon (it's a line stop)
       * -- handle special case feat. "role" lowercase.
       */
      const featIndex = this.output.getLength() - 3;
      const role = this.output.getLastWord();
      if (flags.context.slurpExtraTitleInformation &&
          featIndex > 0 &&
          this.output.getWordAtIndex(featIndex) === 'feat.' &&
          nonEmpty(role)) {
        this.output.setWordAtIndex(
          this.output.getLength() - 1,
          role.toLowerCase(),
        );
      } else {
        /*
         * Force capitalization of the last word,
         * because we are starting a new subtitle
         */
        this.output.capitalizeLastWord(
          !modes[this.modeName].isSentenceCaps(),
        );
      }

      // from next position on, skip spaces and dots.
      let skip = false;
      const cursorPosition = this.input.getCursorPosition();
      const length = this.input.getLength();
      if (cursorPosition < length - 2) {
        const nextWord = this.input.getWordAtIndex(cursorPosition + 1);
        const afterNextWord = this.input.getWordAtIndex(cursorPosition + 2);
        if (nextWord != null && nextWord.match(this.regexes.OPENBRACKET)) {
          skip = true;
          flags.context.spaceNextWord = true;
        }
        if (this.input.isNextWord(' ') && afterNextWord != null &&
          afterNextWord.match(this.regexes.OPENBRACKET)) {
          flags.context.spaceNextWord = true;
          skip = true;
          this.input.nextIndex();
        }
      }
      if (!skip) {
        // No whitespace before colons
        this.output.appendCurrentWord();
        flags.resetContext();
        flags.context.forceCaps = true;
        flags.context.colon = true;
        flags.context.spaceNextWord = (this.input.isNextWord(' '));
      }
      return true;
    }
    return false;
  }

  // Deal with asterisk (*)
  doAsterisk(): boolean {
    if (!this.regexes.ASTERISK) {
      this.regexes.ASTERISK = /^\*$/;
    }
    if (this.input.matchCurrentWord(this.regexes.ASTERISK)) {
      this.output.appendWordPreserveWhiteSpace(true);
      flags.resetContext();
      return true;
    }
    return false;
  }

  // Deal with diamond (#)
  doDiamond(): boolean {
    if (!this.regexes.DIAMOND) {
      this.regexes.DIAMOND = /^#$/;
    }
    if (this.input.matchCurrentWord(this.regexes.DIAMOND)) {
      this.output.appendWordPreserveWhiteSpace(true);
      flags.resetContext();
      return true;
    }
    return false;
  }

  /*
   * Deal with percent signs (%)
   * TODO: lots of methods for special chars look the same, combine?
   */
  doPercent(): boolean {
    if (!this.regexes.PERCENT) {
      this.regexes.PERCENT = /^%$/;
    }
    if (this.input.matchCurrentWord(this.regexes.PERCENT)) {
      this.output.appendWordPreserveWhiteSpace(true);
      flags.resetContext();
      return true;
    }
    return false;
  }

  // Deal with ampersands (&)
  doAmpersand(): boolean {
    if (!this.regexes.AMPERSAND) {
      this.regexes.AMPERSAND = /^&$/;
    }
    if (this.input.matchCurrentWord(this.regexes.AMPERSAND)) {
      flags.resetContext();
      flags.context.forceCaps = true;
      this.output.appendSpace(); // Add a space,and remember to
      flags.context.spaceNextWord = true; // Add one before the next word
      this.output.appendCurrentWord();
      return true;
    }
    return false;
  }

  // Deal with line terminators other than the period (?!;)
  doLineStop(): boolean {
    if (!this.regexes.LINESTOP) {
      this.regexes.LINESTOP = /[?!;]/;
    }
    if (this.input.matchCurrentWord(this.regexes.LINESTOP)) {
      flags.resetContext();

      /*
       * Force caps on word before the colon, if
       * the mode is not sentencecaps
       */
      this.output.capitalizeLastWord(!modes[this.modeName].isSentenceCaps());

      flags.context.forceCaps = true;
      flags.context.spaceNextWord = true;
      this.output.appendCurrentWord();
      return true;
    }
    return false;
  }

  /*
   * Deal with hyphens (-)
   * If a hyphen has a space near it, it should be spaced out and treated
   * similar to a sentence pause, if not it's a part of a hyphenated word.
   * Unfortunately it's not practical to implement real em-dashes, however
   * we'll treat a spaced hyphen as an em-dash for the purposes of caps.
   */
  doHyphen(): boolean {
    if (!this.regexes.HYPHEN) {
      this.regexes.HYPHEN = /^[-‐]$/;
    }
    if (this.input.matchCurrentWord(this.regexes.HYPHEN)) {
      this.output.appendWordPreserveWhiteSpace(true);
      flags.resetContext();

      // Don't capitalize next word after hyphen in sentence mode.
      flags.context.forceCaps = !modes[this.modeName].isSentenceCaps();
      flags.context.hyphen = true;
      return true;
    }
    return false;
  }

  // Deal with inverted question (¿) and exclamation marks (¡).
  doInvertedMarks(): boolean {
    if (!this.regexes.INVERTEDMARKS) {
      this.regexes.INVERTEDMARKS = /(¿|¡)/;
    }
    if (this.input.matchCurrentWord(this.regexes.INVERTEDMARKS)) {
      this.output.appendWordPreserveWhiteSpace(false);
      flags.resetContext();

      // Next word is start of a new sentence.
      flags.context.forceCaps = true;
      return true;
    }
    return false;
  }

  // Deal with plus symbol    (+)
  doPlus(): boolean {
    if (!this.regexes.PLUS) {
      this.regexes.PLUS = /^\+$/;
    }
    if (this.input.matchCurrentWord(this.regexes.PLUS)) {
      this.output.appendWordPreserveWhiteSpace(true);
      flags.resetContext();
      return true;
    }
    return false;
  }

  /*
   * Deal with slashes (/,\)
   * If a slash has a space near it, pad it out, otherwise leave as is.
   */
  doSlash(): boolean {
    if (!this.regexes.SLASH) {
      this.regexes.SLASH = /[\\/]/;
    }
    if (this.input.matchCurrentWord(this.regexes.SLASH)) {
      this.output.appendWordPreserveWhiteSpace(true);
      flags.resetContext();
      flags.context.forceCaps = true;
      return true;
    }
    return false;
  }

  // Deal with double quotes (")
  doDoubleQuote(): boolean {
    if (!this.regexes.DOUBLEQUOTE) {
      this.regexes.DOUBLEQUOTE = /["“”„“«»]/;
    }
    if (this.input.matchCurrentWord(this.regexes.DOUBLEQUOTE)) {
      // Changed 05/2006: do not force capitalization before quotes
      this.output.appendWordPreserveWhiteSpace(false);

      // Changed 05/2006: do not force capitalization after quotes
      flags.resetContext();
      flags.context.forceCaps = !this.input.isNextWord(' ');
      return true;
    }
    return false;
  }

  /*
   * Deal with single quotes (')
   * * Need to keep context on whether this.regexes.inside quotes or not.
   * * Look for contractions (see contractions_words for a list of
   *   contractions that are handled), and format the right part (after)
   *   the (') as lowercase.
   */
  doSingleQuote(): boolean {
    if (!this.regexes.SINGLEQUOTE) {
      this.regexes.SINGLEQUOTE = /['‘’‹›]/;
    }

    if (this.input.matchCurrentWord(this.regexes.SINGLEQUOTE)) {
      flags.context.forceCaps = false;
      const isPreviousSpace = this.input.isPreviousWord(' ');
      const isNextSpace = this.input.isNextWord(' ');
      const state = flags.context.openedSingleQuote;

      /*
       * Preserve whitespace before opening singlequote.
       * -- if it's a "Asdf 'Text in Quotes'"
       */
      if (isPreviousSpace && !isNextSpace) {
        this.output.appendSpace();
        flags.context.openedSingleQuote = true;
        flags.context.forceCaps = true;

        // Preserve whitespace after closing singlequote.
      } else if (!isPreviousSpace && isNextSpace) {
        if (state) {
          flags.context.forceCaps = true;
          flags.context.openedSingleQuote = false;
        }
        this.output.capitalizeLastWord();
      }
      flags.context.spaceNextWord = isNextSpace; // and keep whitespace intact
      this.output.appendCurrentWord(); // append current word

      /*
       * If there is a space after the '
       * then assume its a closing singlequote
       * Do not force capitalization per default, else for "Rollin' on",
       * the "On" will be titled.
       */
      flags.resetContext();

      /*
       * Default, if singlequote state was not modified, is
       * not forcing caps.
       */
      if (state === flags.context.openedSingleQuote) {
        flags.context.forceCaps = false;
      }
      flags.context.singlequote = true;
      return true;
    }
    return false;
  }

  /*
   * Deal with opening parenthesis    (([{<)
   * Knowing whether we are inside parenthesis (and multiple levels thereof)
   * is important for determining what words should be capped or not.
   */
  doOpeningBracket(): boolean {
    if (!this.regexes.OPENBRACKET) {
      this.regexes.OPENBRACKET = /[([{<]/;
    }
    const currentWord = this.input.getCurrentWord();
    if (currentWord != null && currentWord.match(this.regexes.OPENBRACKET)) {
      /*
       * Force caps on last word before the opending bracket,
       * if the current mode is not sentence mode.
       */
      this.output.capitalizeLastWord(!modes[this.modeName].isSentenceCaps());

      // register current bracket as openening bracket
      flags.pushBracket(currentWord);
      const closingBracket = flags.getCurrentCloseBracket();
      let forcelowercase = false;
      const cursorPosition = this.input.getCursorPosition() + 1;
      for (let i = cursorPosition; i < this.input.getLength(); i++) {
        const word = (this.input.getWordAtIndex(i) || '');
        if (word !== ' ') {
          if ((isLowerCaseBracketWord(word)) ||
              (word.match(/^featuring$|^ft$|^feat$/i) != null)) {
            flags.context.slurpExtraTitleInformation = true;

            if (i === cursorPosition) {
              forcelowercase = true;
            }
          }
          if (word === closingBracket) {
            break;
          }
        }
      }
      this.output.appendSpace(); // Always space brackets
      flags.resetContext();
      flags.context.spaceNextWord = false;
      flags.context.openingBracket = true;
      flags.context.forceCaps = !forcelowercase;
      this.output.appendCurrentWord();
      return true;
    }
    return false;
  }

  /*
   * Deal with closing parenthesis    (([{<)
   * Knowing whether we are inside parenthesis (and multiple levels thereof)
   * is important for determining what words should be capped or not.
   */
  doClosingBracket(): boolean {
    if (!this.regexes.CLOSEBRACKET) {
      this.regexes.CLOSEBRACKET = /[)\]}>]/;
    }
    if (this.input.matchCurrentWord(this.regexes.CLOSEBRACKET)) {
      /*
       * Capitalize the last word, if forceCaps was
       * set, else leave it like it is.
       */
      this.output.capitalizeLastWord();

      if (flags.isInsideBrackets()) {
        flags.popBracket();
        flags.context.slurpExtraTitleInformation = false;
      }
      flags.resetContext();
      flags.context.forceCaps = !modes[this.modeName].isSentenceCaps();
      flags.context.spaceNextWord = true;
      this.output.appendCurrentWord();
      return true;
    }
    return false;
  }

  /*
   * Deal with commas.            (,)
   * Commas can mean two things: a sentence pause or a number split.
   * We need context to guess which one it's meant to be, thus the digit
   * triplet checking later on. Multiple commas are removed.
   */
  doComma(): boolean {
    if (!this.regexes.COMMA) {
      this.regexes.COMMA = /^,$/;
    }
    if (this.input.matchCurrentWord(this.regexes.COMMA)) {
      // Skip duplicate commas.
      if (this.output.getLastWord() !== ',') {
        /*
         * Capitalize the last word before the colon.
         * -- Do words before comma need to be titled?
         * -- See http://bugs.musicbrainz.org/ticket/1317
         */

        // Handle comma
        flags.resetContext();
        flags.context.spaceNextWord = true;
        flags.context.forceCaps = false;
        this.output.appendCurrentWord();
      }
      return true;
    }
    return false;
  }

  /*
   * Deal with periods.         (.)
   * Periods can also mean four things:
   *   * a sentence break (full stop);
   *   * a number split in some countries
   *   * part of an ellipsis (...)
   *   * an acronym split.
   * We flag digits and digit triplets in the words routine.
   */
  doPeriod(): boolean {
    if (!this.regexes.PERIOD) {
      this.regexes.PERIOD = /^\.$/;
    }

    if (this.input.matchCurrentWord(this.regexes.PERIOD)) {
      if (this.output.getLastWord() === '.') {
        if (!flags.context.ellipsis) {
          this.output.appendWord('..');
          while (this.input.isNextWord('.')) {
            this.input.nextIndex(); // Skip trailing (.)
          }
          flags.resetContext();
          flags.context.ellipsis = true;
        }
        flags.context.forceCaps = true; // Capitalize next word in any case.
        flags.context.spaceNextWord = true;
      } else {
        if (!this.input.hasMoreWords() || this.input.getNextWord() !== '.') {
          /*
           * Capitalize the last word, if forceCaps was
           * set, else leave it like it is.
           */
          this.output.capitalizeLastWord();
        }
        this.output.appendWord('.');
        flags.resetContext();
        flags.context.forceCaps = true; // Force caps on next word
        flags.context.spaceNextWord = (this.input.isNextWord(' '));
      }
      return true;
    }
    return false;
  }

  // Check for an acronym
  doAcronym(): boolean {
    if (!this.regexes.ACRONYM) {
      this.regexes.ACRONYM = /^\w$/;
    }

    /*
     * Acronym handling was made less strict to
     * fix broken acronyms which look like this: "A. B. C."
     * The variable flags.context.gotPeriod is used such that such
     * cases do not yield false positives:
     * The method works as follows:
     * "A.B.C. I Love You"          => "A.B.C. I Love You"
     * "A. B. C. I Love You"        => "A.B.C. I Love You"
     * "A.B.C I Love You"           => "A.B. C I Love You"
     * "P.S I Love You"             => "P. S I Love You"
     */
    let subIndex = this.input.getCursorPosition() + 1;
    const tmp = [];
    const currentWord = this.input.getCurrentWord();
    if (currentWord != null && currentWord.match(this.regexes.ACRONYM)) {
      tmp.push(currentWord.toUpperCase()); // Add current word
      let expectWord = false;
      let gotPeriod = false;
      acronymloop:
      for (
        subIndex;
        subIndex < this.input.getLength();
      ) {
        // Remember current word
        const wordAtIndex = this.input.getWordAtIndex(subIndex);

        if (expectWord && wordAtIndex != null &&
            wordAtIndex.match(this.regexes.ACRONYM)) {
          tmp.push(wordAtIndex.toUpperCase()); // Do character
          expectWord = false;
          gotPeriod = false;
        } else {
          if (wordAtIndex === '.' && !gotPeriod) {
            tmp[tmp.length] = '.'; // Do dot
            gotPeriod = true;
            expectWord = true;
          } else if (gotPeriod && wordAtIndex === ' ') {
            expectWord = true; // Do a single whitespace
          } else if (tmp[tmp.length - 1] !== '.') {
            tmp.pop(); // Lose last of the acronym
            subIndex--; // It's for example "P.S. I" love you
          }
          // Found something which is not part of the acronym
          break acronymloop;
        }
        subIndex++;
      }
    }

    if (tmp.length > 2) {
      let string = tmp.join(''); // Yes, we have an acronym, get string
      string = string.replace(/(\.)*$/, '.'); // Replace any number of trailing "." with ". "

      this.output.appendSpaceIfNeeded();
      this.output.appendWord(string);

      flags.resetContext();
      flags.context.acronym = true;
      flags.context.spaceNextWord = true;
      flags.context.forceCaps = false;
      // Set pointer to after acronym
      this.input.setCursorPosition(subIndex - 1);
      return true;
    }
    return false;
  }

  // Check for a digit only string
  doDigits(): boolean {
    if (!this.regexes.DIGITS) {
      this.regexes.DIGITS = /^\d+$/;
      this.regexes.DIGITS_NUMBERSPLIT = /[,.]/;
      this.regexes.DIGITS_DUPLE = /^\d\d$/;
      this.regexes.DIGITS_TRIPLE = /^\d\d\d$/;
      this.regexes.DIGITS_NTUPLE = /^\d\d\d\d+$/;
    }

    let subIndex = this.input.getCursorPosition() + 1;
    const tmp = [];
    if (this.input.matchCurrentWord(this.regexes.DIGITS)) {
      tmp.push(this.input.getCurrentWord());
      flags.context.numberSplitExpect = true;

      numberloop:
      for (
        subIndex;
        subIndex < this.input.getLength();
      ) {
        if (flags.context.numberSplitExpect) {
          if (this.input.matchWordAtIndex(
            subIndex,
            this.regexes.DIGITS_NUMBERSPLIT,
          )) {
            // Found a potential number split
            tmp.push(this.input.getWordAtIndex(subIndex));
            flags.context.numberSplitExpect = false;
          } else {
            break numberloop;
          }
        } else if (this.input.matchWordAtIndex(
          subIndex,
          this.regexes.DIGITS_TRIPLE,
        )) {
          // Found for a group of 3 digits
          if (flags.context.numberSplitChar == null) {
            // Confirmed number split
            flags.context.numberSplitChar = tmp[tmp.length - 1];
          }
          tmp.push(this.input.getWordAtIndex(subIndex));
          flags.context.numberSplitExpect = true;
        } else {
          if (this.input.matchWordAtIndex(
            subIndex,
            this.regexes.DIGITS_DUPLE,
          )) {
            if (tmp.length > 2 &&
                flags.context.numberSplitChar !== tmp[tmp.length - 1]) {
              /*
               * Check for the opposite number splitter (, or .)
               * because numbers are generally either
               * 1,000,936.00 or 1.300.402,00 depending on
               * the country
               */
              tmp.push(this.input.getWordAtIndex(subIndex++));
            } else {
              tmp.pop(); // stand-alone number pair
              subIndex--;
            }
          } else if (this.input.matchWordAtIndex(
            subIndex,
            this.regexes.DIGITS_NTUPLE,
          )) {
            /*
             * Big number at the end, probably a decimal point,
             * end of number in any case
             */
            tmp.push(this.input.getWordAtIndex(subIndex++));
          } else {
            tmp.pop(); // Last number split was not
            subIndex--; // actually a number split
          }
          break numberloop;
        }
        subIndex++;
      }
      this.input.setCursorPosition(subIndex - 1);

      this.output.appendSpaceIfNeeded();
      this.output.appendWord(tmp.join(''));

      flags.resetContext();
      flags.context.forceCaps = false;
      flags.context.number = true;

      return true;
    }
    return false;
  }

  /*
   * Do not change the caps of certain words
   * ---------------------------------------------------
   * warp        2011-08-13        first version
   */
  doIgnoreWords(): boolean {
    // deciBel
    if (this.input.getCurrentWord() === 'dB') {
      this.output.appendSpaceIfNeeded();
      this.output.appendCurrentWord();
      return true;
    }
    return false;
  }

  /*
   * Detect featuring,f., ft[.], feat[.] and add parentheses as needed.
   * keschte        2005-11-10        added ^f\.$ to cases
   *                                  which are added converted to feat.
   * ---------------------------------------------------
   */
  doFeaturingArtistStyle(): boolean {
    if (!this.regexes.FEAT) {
      this.regexes.FEAT = /^featuring$|^f$|^ft$|^feat$/i;
      this.regexes.FEAT_F = /^f$/i; // Match word "f"
      this.regexes.FEAT_FEAT = /^feat$/i; // Match word "feat"
    }
    const currentWord = this.input.getCurrentWord();
    if (currentWord == null) {
      return false;
    }
    if (currentWord.match(this.regexes.FEAT)) {
      const nextWord = this.input.getNextWord();
      /*
       * Special cases (f.) and (f/),
       * have to check if next word is a "." or a "/"
       */
      if ((currentWord.match(this.regexes.FEAT_F)) &&
          nextWord != null && !nextWord.match(/^[/.]$/)) {
        return false;
      }

      /*
       * Only try to convert to feat. if there are
       * enough words after the keyword
       */
      if (this.input.getCursorPosition() < this.input.getLength() - 2) {
        const nextWord = this.input.getNextWord();
        const featWord = currentWord + (
          nextWord != null && (nextWord === '.' || nextWord === '/')
            ? nextWord
            // Special case (feat), fix typo by adding a "." if missing
            : currentWord.match(this.regexes.FEAT_FEAT) ? '.' : ''
        );

        if (!flags.context.openingBracket && !flags.isInsideBrackets()) {
          if (flags.isInsideBrackets()) {
            // Close open parentheses before the feat. part.
            while (flags.isInsideBrackets()) {
              // Close brackets that were opened before
              const cb = flags.popBracket();
              this.output.appendWord(cb);
              if (this.input.getWordAtIndex(
                this.input.getLength() - 1,
              ) === cb) {
                this.input.dropLastWord();
                /*
                 * Get rid of duplicate bracket at the end (will be
                 * added again by closeOpenBrackets if they wern't
                 * closed before (e.g. using feat.)
                 */
              }
            }
          }

          /*
           * Handle case:
           * Blah ft. Erroll Flynn Some Remixname remix
           * -> pre-processor added parentheses such that the string is:
           * Blah ft. erroll flynn Some Remixname (remix)
           * -> now there are parentheses needed before remix, we can't
           *    guess where the artist name ends, and the remixname starts
           *    though :]
           * Blah (feat. Erroll Flynn Some Remixname) (remix)
           */
          const cursorPosition = this.input.getCursorPosition();
          const length = this.input.getLength();
          let i = cursorPosition;
          for (; i < length; i++) {
            if (this.input.getWordAtIndex(i) === '(') {
              break;
            }
          }

          /*
           * We got a part, but not until the end of the string
           * close feat. part, and add space to next set of brackets
           */
          if (i !== cursorPosition && i < length - 1) {
            this.input.insertWordsAtIndex(i, [')', ' ']);
          }
          this.input.updateCurrentWord('(');
          this.doOpeningBracket();
        } else {
          this.output.appendWord(' ');
        }

        // output.appendSpaceIfNeeded();
        this.output.appendWord(featWord);

        flags.resetContext();
        flags.context.forceCaps = true;
        flags.context.openingBracket = false;
        flags.context.spaceNextWord = true;
        flags.context.slurpExtraTitleInformation = true;
        if (this.input.isNextWord('.') || this.input.isNextWord('/')) {
          this.input.nextIndex();  // skip trailing (.) or (/)
        }
        return true;
      }
    }
    return false;
  }

  moveArticleToEnd(inputString: string): string {
    return trim(inputString).replace(
      /^(The|Los) (.+)$/,
      function (match, article, name) {
        return name + ', ' + article;
      },
    );
  }

  sortCompoundName(
    inputString: string,
    callback: (string, {[regexName: string]: RegExp}) => string,
  ): string {
    const trimmedString = trim(inputString);

    let joinPhrase = ' and ';
    joinPhrase = (trimmedString.indexOf(' + ') === -1 ? joinPhrase : ' + ');
    joinPhrase = (trimmedString.indexOf(' & ') === -1 ? joinPhrase : ' & ');

    return trimmedString
      .split(joinPhrase)
      .map(string => callback(string, this.regexes))
      .join(joinPhrase);
  }
}

export default GuessCaseHandler;
