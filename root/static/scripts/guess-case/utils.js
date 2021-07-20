/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import clean from '../common/utility/clean';

import * as flags from './flags';

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
  're‐mode',
  'rework',
  'reworked',
  'session',
  'short',
  'take',
  'takes',
  'techno',
  'trance',
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

export function isPrepBracketSingleWord(w) {
  return preBracketSingleWords.test(w);
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

export function turkishUpperCase(str) {
  return str.replace(/i/g, 'İ').toUpperCase();
}

export function turkishLowerCase(str) {
  return str.replace(/I\u0307/g, 'i').replace(/I/g, 'ı').replace(/İ/g, 'i')
    .toLowerCase();
}

export function isLowerCaseBracketWord(w) {
  return lowerCaseBracketWords.test(w);
}

// Words which are put into brackets if they aren't yet.
const prepBracketWords = /^(?:cd|disk|12["”]|7["”]|a_cappella|re_edit)$/i;

export function isPrepBracketWord(w) {
  return prepBracketWords.test(w) || isLowerCaseBracketWord(w);
}

const sentenceStopChars = /^[:.;?!\/]$/;

export function isSentenceStopChar(w) {
  return sentenceStopChars.test(w);
}

const apostropheChars = /^['’]$/;

export function isApostrophe(w) {
  return apostropheChars.test(w);
}

const punctuationChars = /^[:.;?!,]$/;

export function isPunctuationChar(w) {
  return punctuationChars.test(w);
}

// Trim leading, trailing and running-line whitespace from the given string.
export function trim(is) {
  is = clean(is);
  return is.replace(/([(\[])\s+/, '$1').replace(/\s+([)\]])/, '$1');
}

/*
 * Uppercase first letter of word unless it's one of the words
 * in the lowercase words array.
 */
export function titleString(gc, is, forceCaps) {
  if (!is) {
    return '';
  }

  forceCaps = (forceCaps == null ? flags.context.forceCaps : forceCaps);

  // Get current pointer in word array.
  const len = gc.i.getLength();
  let pos = gc.i.getPos();

  /*
   * If pos === len, this means that the pointer is beyond the last position
   * in the wordlist, and that the regular processing is done. We're looking
   * at the last word before collecting the output, and have to adjust pos
   * to the last element of the wordlist again.
   */
  if (pos === len) {
    pos = len - 1;
    gc.i.setPos(pos);
  }

  let os;
  let lc = gc.mode.toLowerCase(is);
  let uc = gc.mode.toUpperCase(is);

  if (is === uc && is.length > 1 && gc.CFG_UC_UPPERCASED) {
    os = uc;
    // we got an 'x (apostrophe),keep the text lowercased
  } else if (lc.length === 1 && isApostrophe(gc.i.getPreviousWord())) {
    os = lc;
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
    gc.mode.name === 'English' &&
    isApostrophe(gc.i.getPreviousWord()) &&
    lc.match(/^(?:s|round|em|ve|ll|d|cha|re|til|way|all|mon)$/i)
  ) {
    os = lc;
    /*
     * we got an Ev'..
     * Every = Ev'ry, lowercase
     * Everything = Ev'rything, lowercase (more cases?)
     */
  } else if (
    gc.mode.name === 'English' &&
    isApostrophe(gc.i.getPreviousWord()) &&
    gc.i.getWordAtIndex(pos - 2) === 'Ev'
  ) {
    os = lc;
    // Make it O'Titled, Y'All, C'mon
  } else if (
    gc.mode.name === 'English' &&
    lc.match(/^[coy]$/i) &&
    isApostrophe(gc.i.getNextWord())
  ) {
    os = uc;
  } else {
    os = titleStringByMode(gc, lc, forceCaps);
    lc = gc.mode.toLowerCase(os);
    uc = gc.mode.toUpperCase(os);

    const nextWord = gc.i.getNextWord();
    const followedByPunctuation =
      nextWord && nextWord.length === 1 && isPunctuationChar(nextWord);
    const followedByApostrophe =
      nextWord && nextWord.length === 1 && isApostrophe(nextWord);

    /*
     * Unless forceCaps is enabled, lowercase the word
     * if it's not followed by punctuation.
     */
    if (!forceCaps && gc.mode.isLowerCaseWord(lc) && !followedByPunctuation) {
      os = lc;
    } else if (gc.mode.isRomanNumber(lc) && !followedByApostrophe) {
      /*
       * Uppercase Roman numerals unless followed by apostrophe
       * (likely false positive, "d'amore", "c'est")
       */
      os = uc;
    } else if (gc.mode.isUpperCaseWord(lc)) {
      os = uc;
    } else if (flags.isInsideBrackets() && isLowerCaseBracketWord(lc)) {
      os = lc;
    }
  }

  return os;
}

/*
 * Capitalize the string, but check if some characters inside the word
 * need to be uppercased as well.
 */
export function titleStringByMode(gc, is, forceCaps) {
  if (!is) {
    return '';
  }

  let os = gc.mode.toLowerCase(is);

  /*
   * See if the word before is a sentence stop character.
   * -- http://bugs.musicbrainz.org/ticket/40
   */
  const opos = gc.o.getLength();
  let wordBefore = '';
  if (opos > 1) {
    wordBefore = gc.o.getWordAtIndex(opos - 2);
  }

  /*
   * If in sentence caps mode, and the last char was not punctuation or an
   * opening bracket, keep the work lowercased.
   */
  const doCaps = (
    forceCaps || !gc.mode.isSentenceCaps() ||
      flags.context.slurpExtraTitleInformation ||
      flags.context.openingBracket ||
      gc.i.isFirstWord() || isSentenceStopChar(wordBefore)
  );

  if (doCaps) {
    const chars = os.split('');
    chars[0] = gc.mode.toUpperCase(chars[0]);

    if (is.length > 2 && is.substring(0, 2) === 'mc') {
      // Make it McTitled
      chars[2] = gc.mode.toUpperCase(chars[2]);
    }

    os = chars.join('');
  }

  return os;
}
