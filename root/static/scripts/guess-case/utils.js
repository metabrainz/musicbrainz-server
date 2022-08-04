/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import clean from '../common/utility/clean';

import * as flags from './flags';
import * as modes from './modes';
import type {GuessCaseModeT} from './types';
import gc from './MB/GuessCase/Main';
import input from './MB/GuessCase/Input';
import output from './MB/GuessCase/Output';


/*
 * Words which are turned to lowercase if in brackets, but
 * are *not* put in brackets if they're found at the end of the sentence.
 */
const preBracketSingleWordsList = [
  'acoustic',
  'airplay',
  'album',
  'alternate',
  'alternative',
  'ambient',
  'bonus',
  'censored',
  'chillout',
  'clean',
  'club',
  'composition',
  'cut',
  'dance',
  'dialogue',
  'dirty',
  'disc',
  'disco',
  'dub',
  'early',
  'explicit',
  'extended',
  'feat',
  'featuring',
  'ft',
  'instrumental',
  'live',
  'long',
  'main',
  'megamix',
  'mix',
  'official',
  'original',
  'piano',
  'radio',
  'rap',
  'rehearsal',
  'remixed',
  'remode',
  'rework',
  'reworked',
  'session',
  'short',
  'take',
  'takes',
  'techno',
  'trance',
  'uncensored',
  'unknown',
  'untitled',
  'version',
  'video',
  'vocal',
  'with',
  'without',
];

const preBracketSingleWords = new RegExp(
  '^(' + preBracketSingleWordsList.join('|') + ')$', 'i',
);

export function isPrepBracketSingleWord(word: string): boolean {
  return preBracketSingleWords.test(word);
}

/*
 * Words which are turned to lowercase if in brackets, and
 * put in brackets if they're found at the end of the sentence.
 */
const lowerCaseBracketWordsList = [
  'a_cappella',
  'clubmix',
  'demo',
  'edit',
  'excerpt',
  'interlude',
  'intro',
  'karaoke',
  'maxi',
  'mono',
  'orchestral',
  'outro',
  'outtake',
  'outtakes',
  'quadraphonic',
  'reedit',
  'reinterpreted',
  'remake',
  'remix',
  'rmx',
  'reprise',
  'single',
  'skit',
  'stereo',
  'studio',
  'unplugged',
  'vs',
].concat(preBracketSingleWordsList);

const lowerCaseBracketWords = new RegExp(
  '^(' + lowerCaseBracketWordsList.join('|') + ')$', 'i',
);

export function turkishUpperCase(word: string): string {
  return word.replace(/i/g, 'İ').toUpperCase();
}

export function turkishLowerCase(word: string): string {
  return word.replace(/I\u0307/g, 'i').replace(/I/g, 'ı').replace(/İ/g, 'i')
    .toLowerCase();
}

export function isLowerCaseBracketWord(word: string | null): boolean {
  if (word == null) {
    return false;
  }
  return lowerCaseBracketWords.test(word);
}

// Words which are put into brackets if they aren't yet.
const prepBracketWords = /^(?:cd|disk|12["”]|7["”]|a_cappella|re_edit)$/i;

export function isPrepBracketWord(word: string | null): boolean {
  if (word == null) {
    return false;
  }
  return prepBracketWords.test(word) || isLowerCaseBracketWord(word);
}

const sentenceStopChars = /^[:.;?!\/]$/;

export function isSentenceStopChar(word: string | null): boolean {
  if (word == null) {
    return false;
  }
  return sentenceStopChars.test(word);
}

const apostropheChars = /^['’]$/;

export function isApostrophe(word: string | null): boolean {
  if (word == null) {
    return false;
  }
  return apostropheChars.test(word);
}

const punctuationChars = /^[:.;?!,]$/;

export function isPunctuationChar(word: string | null): boolean {
  if (word == null) {
    return false;
  }
  return punctuationChars.test(word);
}

// Trim leading, trailing and running-line whitespace from the given string.
export function trim(word: string): string {
  const cleanedWord = clean(word);
  return cleanedWord.replace(/([(\[])\s+/, '$1').replace(/\s+([)\]])/, '$1');
}

/*
 * Uppercase first letter of word unless it's one of the words
 * in the lowercase words array.
 */
export function titleString(
  inputString: string | null,
  forceCaps?: boolean,
): string {
  if (!nonEmpty(inputString)) {
    return '';
  }
  const guessCaseMode = modes[gc.modeName];
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
      gc.CFG_KEEP_UPPERCASED) {
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
      guessCaseMode.isRomanNumber(lowercase) && !followedByApostrophe
    ) {
      /*
       * Uppercase Roman numerals unless followed by apostrophe
       * (likely false positive, "d'amore", "c'est")
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
  guessCaseMode: GuessCaseModeT,
  inputString: string | null,
  forceCaps: boolean,
): string {
  if (!nonEmpty(inputString)) {
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
