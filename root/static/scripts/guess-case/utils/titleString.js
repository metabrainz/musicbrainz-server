/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as flags from '../flags.js';
import type GuessCaseInput from '../MB/GuessCase/Input.js';
import type GuessCaseOutput from '../MB/GuessCase/Output.js';
import * as modes from '../modes.js';
import type {GuessCaseModeNameT, GuessCaseModeT} from '../types.js';

import {
  isApostrophe,
  isLowerCaseBracketWord,
  isPunctuationChar,
  isSentenceStopChar,
} from './wordCheckers.js';

/*
 * Uppercase first letter of word unless it's one of the words
 * in the lowercase words array.
 */
function titleString(
  input: GuessCaseInput,
  output: GuessCaseOutput,
  inputString: string | null,
  modeName: GuessCaseModeNameT,
  CFG_KEEP_UPPERCASED: boolean,
  forceCaps?: boolean,
): string {
  if (empty(inputString)) {
    return '';
  }
  const guessCaseMode = modes[modeName];
  const localForceCaps = forceCaps == null
    ? flags.context.forceCaps
    : forceCaps;

  // Get current pointer in word array.
  const len = input.getLength();
  let pos = input.getCursorPosition();

  /*
   * If pos === len, this means that the pointer is beyond the last position
   * in the wordlist, and that the regular processing is done. We're looking
   * at the last word before collecting the output, and have to adjust pos
   * to the last element of the wordlist again.
   */
  if (pos === len) {
    pos = len - 1;
    input.setCursorPosition(pos);
  }

  let outputString;
  let lowercase = guessCaseMode.toLowerCase(inputString);
  let uppercase = guessCaseMode.toUpperCase(inputString);

  if (inputString === uppercase &&
      inputString.length > 1 &&
      CFG_KEEP_UPPERCASED) {
    outputString = uppercase;
    // we got an 'x (apostrophe),keep the text lowercased
  } else if (lowercase.length === 1 &&
             isApostrophe(input.getPreviousWord())) {
    outputString = lowercase;
    /*
     * we got an 's (It is = It's), lowercase
     * we got an 'all (Y'all = You all), lowercase
     * we got an 'em (Them = 'em), lowercase.
     * we got an 've (They have = They've), lowercase.
     * we got an 'd (He had = He'd), lowercase.
     * we got an 'cha (What you = What'cha), lowercase.
     * we got an 're (You are = You're), lowercase.
     * we got an 'til (Until = 'til), lowercase.
     * we got an 'way (Away = 'way), lowercase.
     * we got an 'round (Around = 'round), lowercase
     * we got a 'mon (Come on = C'mon), lowercase
     */
  } else if (
    guessCaseMode.name === 'English' &&
    isApostrophe(input.getPreviousWord()) &&
    lowercase.match(/^(?:s|round|em|ve|ll|d|cha|re|til|way|all|mon)$/i)
  ) {
    outputString = lowercase;
    /*
     * we got an Ev'..
     * Every = Ev'ry, lowercase
     * Everything = Ev'rything, lowercase (more cases?)
     */
  } else if (
    guessCaseMode.name === 'English' &&
    isApostrophe(input.getPreviousWord()) &&
    input.getWordAtIndex(pos - 2) === 'Ev'
  ) {
    outputString = lowercase;
    // Make it O'Titled, Y'All, C'mon
  } else if (
    guessCaseMode.name === 'English' &&
    lowercase.match(/^[coy]$/i) &&
    isApostrophe(input.getNextWord())
  ) {
    outputString = uppercase;
  } else {
    outputString = titleStringByMode(
      input,
      output,
      guessCaseMode,
      lowercase,
      localForceCaps,
    );
    lowercase = guessCaseMode.toLowerCase(outputString);
    uppercase = guessCaseMode.toUpperCase(outputString);

    const nextWord = input.getNextWord();
    const followedByPunctuation =
      nonEmpty(nextWord) && nextWord.length === 1 &&
      isPunctuationChar(nextWord);
    const followedByApostrophe =
      nonEmpty(nextWord) && nextWord.length === 1 && isApostrophe(nextWord);

    /*
     * Unless forceCaps is enabled, lowercase the word
     * if it's not followed by punctuation.
     */
    if (!localForceCaps && guessCaseMode.isLowerCaseWord(lowercase) &&
        !followedByPunctuation) {
      outputString = lowercase;
    } else if (
      guessCaseMode.isRomanNumber(lowercase) &&
      !followedByApostrophe &&
      !(flags.isInsideBrackets() && isLowerCaseBracketWord(lowercase))
    ) {
      /*
       * Uppercase Roman numerals unless followed by apostrophe
       * (likely false positive, "d'amore", "c'est") or a bracketed word
       * that's typically lowercased (e.g. "mix").
       */
      outputString = uppercase;
    } else if (guessCaseMode.isUpperCaseWord(lowercase)) {
      outputString = uppercase;
    } else if (
      flags.isInsideBrackets() && isLowerCaseBracketWord(lowercase)
    ) {
      outputString = lowercase;
    }
  }

  return outputString;
}

/*
 * Capitalize the string, but check if some characters inside the word
 * need to be uppercased as well.
 */
export function titleStringByMode(
  input: GuessCaseInput,
  output: GuessCaseOutput,
  guessCaseMode: GuessCaseModeT,
  inputString: string | null,
  forceCaps: boolean,
): string {
  if (empty(inputString)) {
    return '';
  }

  let outputString = guessCaseMode.toLowerCase(inputString);

  /*
   * See if the word before is a sentence stop character.
   * -- http://bugs.musicbrainz.org/ticket/40
   */
  const opos = output.getLength();
  let wordBefore: string | null = '';
  if (opos > 1) {
    wordBefore = output.getWordAtIndex(opos - 2);
  }

  /*
   * If in sentence caps mode, and the last char was not punctuation or an
   * opening bracket, keep the work lowercased.
   */
  const doCaps = (
    forceCaps || !guessCaseMode.isSentenceCaps() ||
      flags.context.slurpExtraTitleInformation ||
      flags.context.openingBracket ||
      input.isFirstWord() || isSentenceStopChar(wordBefore)
  );

  if (doCaps) {
    const chars = outputString.split('');
    chars[0] = guessCaseMode.toUpperCase(chars[0]);

    if (inputString.length > 2 && inputString.substring(0, 2) === 'mc') {
      // Make it McTitled
      chars[2] = guessCaseMode.toUpperCase(chars[2]);
    }

    outputString = chars.join('');
  }

  return outputString;
}

export default titleString;
