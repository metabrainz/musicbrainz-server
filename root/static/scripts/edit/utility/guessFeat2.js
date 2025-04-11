/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import balanced from 'balanced-match';

import {
  BRACKET_PAIRS,
  MIN_NAME_SIMILARITY,
} from '../../common/constants.js';
import {last} from '../../common/utility/arrays.js';
import clean from '../../common/utility/clean.js';
import {cloneArrayDeep} from '../../common/utility/cloneDeep.mjs';

import {
  fromFullwidthLatin,
  hasFullwidthLatin,
  toFullwidthLatin,
} from './fullwidthLatin.js';
import getRelatedArtists from './getRelatedArtists.js';
import isEntityProbablyClassical from './isEntityProbablyClassical.js';
import getSimilarity from './similarity.js';

type GuessFeatEntityT = {
  +artistCredit: ArtistCreditT,
  +name: string,
  +relationships?: $ReadOnlyArray<RelationshipT>,
};

type ExpandedArtistCreditT = {
  artist: ArtistT,
  joinPhrase: string,
  name: string,
  similarity: number,
};

type ExtractedCreditsT = {
  +artistCredit: Array<ExpandedArtistCreditT>,
  +joinPhrase: string,
  +name: string,
};

/* eslint-disable sort-keys */
export const featRegex: RegExp = /(?:^\s*|[,，－-]\s*|\s+)((?:ft|feat|ｆｔ|ｆｅａｔ)(?:[.．]|(?=\s))|(?:featuring|ｆｅａｔｕｒｉｎｇ)(?=\s))\s*/i;
/*
 * `featQuickTestRegex` is used to quickly test whether a title *might*
 * contain featured artists. It's fine if it returns false-positives.
 * Please keep it in sync with `featRegex` above.
 */
const featQuickTestRegex = /ft|feat|ｆｔ|ｆｅａｔ/i;
const collabRegex = /([,，]?\s+(?:&|and|et|＆|ａｎｄ|ｅｔ)\s+|、|[,，;；]\s+|\s*[/／]\s*|\s+(?:vs|ｖｓ)[.．]\s+)/i;

function extractNonBracketedFeatCredits(
  str: string,
  artists: Array<ArtistT>,
  isProbablyClassical: boolean,
): ExtractedCreditsT {
  const parts = str.split(featRegex).map(clean);

  function fixFeatJoinPhrase(existing: string) {
    const joinPhrase = isProbablyClassical ? '; ' : existing ? (
      ' ' +
      fromFullwidthLatin(existing)
        .toLowerCase()
        .replace(/^feat$/i, '$&.') +
      ' '
    ) : ' feat. ';

    return hasFullwidthLatin(existing)
      ? toFullwidthLatin(joinPhrase)
      : joinPhrase;
  }

  const name = clean(parts[0]);

  const joinPhrase = (parts.length < 2)
    ? ''
    : fixFeatJoinPhrase(parts[1]);

  const artistCredit = parts
    .splice(2)
    .filter((value, key) => value && key % 2 === 0)
    .flatMap(c => expandCredit(c, artists, isProbablyClassical));

  return {
    name,
    joinPhrase,
    artistCredit,
  };
}

function extractBracketedFeatCredits(
  str: string,
  artists: Array<ArtistT>,
  isProbablyClassical: boolean,
): ExtractedCreditsT {
  return BRACKET_PAIRS.reduce(function (accum, pair) {
    let name = '';
    let joinPhrase = accum.joinPhrase;
    let credits = accum.artistCredit;
    let remainder = accum.name;
    let b;
    let m;

    while (true) {
      b = balanced(pair[0], pair[1], remainder);
      if (b) {
        m = extractFeatCredits(b.body, artists, isProbablyClassical, true);
        name += b.pre;

        if (m.name) {
          /*
           * Check if the remaining text in the brackets
           * is also an artist name.
           */
          const expandedCredits = expandCredit(
            m.name, artists, isProbablyClassical,
          );

          if (expandedCredits.some(
            c => c.similarity >= MIN_NAME_SIMILARITY,
          )) {
            credits = credits.concat(expandedCredits);
          } else {
            name += pair[0] + m.name + pair[1];
          }
        }

        joinPhrase ||= m.joinPhrase;
        credits = credits.concat(m.artistCredit);
        remainder = b.post;
      } else {
        name += remainder;
        break;
      }
    }

    return {name: clean(name), joinPhrase, artistCredit: credits};
  }, {name: str, joinPhrase: '', artistCredit: []});
}

export function extractFeatCredits(
  name: string,
  artists: Array<ArtistT>,
  isProbablyClassical: boolean,
  allowEmptyName: boolean,
): ExtractedCreditsT {
  if (!featQuickTestRegex.test(name)) {
    return {name, joinPhrase: '', artistCredit: []};
  }

  const m1 = extractBracketedFeatCredits(name, artists, isProbablyClassical);

  if (!m1.name && !allowEmptyName) {
    return {name, joinPhrase: '', artistCredit: []};
  }

  const m2 = extractNonBracketedFeatCredits(
    m1.name, artists, isProbablyClassical,
  );

  if (!m2.name && !allowEmptyName) {
    return m1;
  }

  return {
    name: m2.name,
    joinPhrase: m2.joinPhrase || m1.joinPhrase,
    artistCredit: m2.artistCredit.concat(m1.artistCredit),
  };
}

function cleanCredit(name: string, isProbablyClassical: boolean) {
  // remove classical roles
  return isProbablyClassical ? name.replace(/^[a-z]+: (.+)$/, '$1') : name;
}

function bestArtistMatch(artists: Array<ArtistT> | null, name: string) {
  if (!artists) {
    return null;
  }
  let match = null;
  for (const artist of artists) {
    const similarity = getSimilarity(name, artist.name);
    if (
      similarity >= MIN_NAME_SIMILARITY &&
      (match == null || similarity > match.similarity)
    ) {
      match = {similarity, artist, name, joinPhrase: ''};
    }
  }
  return match;
}

function expandCredit(
  fullName: string,
  artists: Array<ArtistT>,
  isProbablyClassical: boolean,
): Array<ExpandedArtistCreditT> {
  const cleanedFullName = cleanCredit(fullName, isProbablyClassical);

  /*
   * See which produces a better match to an existing artist: the full
   * credit, or the individual credits as split by collabRegex. Some artist
   * names legitimately contain characters in collabRegex, so this stops
   * those from getting split (assuming the artist appears in a relationship
   * or artist credit).
   */
  const bestFullMatch = bestArtistMatch(artists, cleanedFullName);

  function fixJoinPhrase(existing: string) {
    const joinPhrase = isProbablyClassical ? ', ' : (existing || ' & ');

    return hasFullwidthLatin(existing)
      ? toFullwidthLatin(joinPhrase)
      : joinPhrase;
  }

  const splitParts = cleanedFullName.split(collabRegex);
  const splitMatches = [];
  let bestSplitMatch: ExpandedArtistCreditT;

  for (let i = 0; i < splitParts.length; i += 2) {
    const name = cleanCredit(splitParts[i], isProbablyClassical);
    const match = {
      similarity: -1,
      artist: null,
      name,
      joinPhrase: fixJoinPhrase(splitParts[i + 1]),
      ...bestArtistMatch(artists, name),
    };
    splitMatches.push(match);
    if (!bestSplitMatch || match.similarity > bestSplitMatch.similarity) {
      bestSplitMatch = match;
    }
  }

  if (bestFullMatch && bestSplitMatch &&
      bestFullMatch.similarity > bestSplitMatch.similarity) {
    bestFullMatch.joinPhrase = fixJoinPhrase('');
    return [bestFullMatch];
  }

  return splitMatches;
}

export default function guessFeat(
  entity: GuessFeatEntityT,
): {artistCreditNames: Array<ArtistCreditNameT>, name: string} | null {
  const name = entity.name;
  console.log(entity);
  console.log(name);

  if (empty(name)) {
    // Nothing to guess from an empty name
    return null;
  }
  console.log('still here');

  const relatedArtists = getRelatedArtists(entity.relationships);

  const isProbablyClassical = isEntityProbablyClassical(entity);

  const match = extractFeatCredits(
    name, relatedArtists, isProbablyClassical, false,
  );

  if (!match.name || !match.artistCredit.length) {
    return null;
  }

  const artistCredit = cloneArrayDeep(entity.artistCredit.names);
  last(artistCredit).joinPhrase = match.joinPhrase;
  last(match.artistCredit).joinPhrase = '';

  const guessedArtistCreditNames = [...artistCredit];
  for (const name of match.artistCredit) {
    guessedArtistCreditNames.push({
      artist: name.artist,
      joinPhrase: name.joinPhrase,
      name: name.name,
    });
  }

  return {
    name: match.name,
    artistCreditNames: guessedArtistCreditNames,
  };
}
