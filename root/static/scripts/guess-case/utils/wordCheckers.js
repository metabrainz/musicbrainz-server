/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

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
  'bit',
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
  'loop',
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
  'single',
  'studio',
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
  're_edit',
  'refix',
  'reinterpreted',
  'remake',
  'remaster',
  'remastered',
  'remix',
  'rmx',
  'reprise',
  'skit',
  'stereo',
  'unplugged',
  'vs',
].concat(preBracketSingleWordsList);

const lowerCaseBracketWords = new RegExp(
  '^(' + lowerCaseBracketWordsList.join('|') + ')$', 'i',
);

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

const sentenceStopChars = /^[:.;?!/]$/;

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
