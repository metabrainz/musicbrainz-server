/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import balanced from 'balanced-match';
import $ from 'jquery';
import mutate from 'mutate-cow';

import '../../common/entity.js';

import {expect} from '../../../../utility/invariant.js';
import {
  BRACKET_PAIRS,
  MIN_NAME_SIMILARITY,
} from '../../common/constants.js';
import MB from '../../common/MB.js';
import {last} from '../../common/utility/arrays.js';
import clean from '../../common/utility/clean.js';
import {cloneArrayDeep} from '../../common/utility/cloneDeep.mjs';
import setInputValueForReact
  from '../../common/utility/setInputValueForReact.mjs';

import {
  fromFullwidthLatin,
  hasFullwidthLatin,
  toFullwidthLatin,
} from './fullwidthLatin.js';
import getRelatedArtists from './getRelatedArtists.js';
import getSimilarity from './similarity.js';

type GuessFeatEntityT = {
  +artistCredit: IncompleteArtistCreditT,
  +entityType: EntityWithArtistCreditsTypeT,
  +name: string,
  +recording?: {
    +relationships?: $ReadOnlyArray<RelationshipT>,
  },
  +relationships?: $ReadOnlyArray<RelationshipT>,
};

type GuessFeatResultT = {
  artistCreditNames: $ReadOnlyArray<IncompleteArtistCreditNameT>,
  name: string,
};

type ExpandedArtistCreditNameT = {
  ...IncompleteArtistCreditNameT,
  similarity: number,
};

type ExtractedCreditsT = {
  +artistCredit: Array<ExpandedArtistCreditNameT>,
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
): ExtractedCreditsT {
  const parts = str.split(featRegex).map(clean);

  function fixFeatJoinPhrase(existing: string) {
    const joinPhrase = existing ? (
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
    .flatMap(c => expandCredit(c, artists));

  return {
    name,
    joinPhrase,
    artistCredit,
  };
}

function extractBracketedFeatCredits(
  str: string,
  artists: Array<ArtistT>,
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
        m = extractFeatCredits(b.body, artists, true);
        name += b.pre;

        if (m.name) {
          /*
           * Check if the remaining text in the brackets
           * is also an artist name.
           */
          const expandedCredits = expandCredit(
            m.name, artists,
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
  allowEmptyName: boolean,
): ExtractedCreditsT {
  if (!featQuickTestRegex.test(name)) {
    return {name, joinPhrase: '', artistCredit: []};
  }

  const m1 = extractBracketedFeatCredits(name, artists);

  if (!m1.name && !allowEmptyName) {
    return {name, joinPhrase: '', artistCredit: []};
  }

  const m2 = extractNonBracketedFeatCredits(
    m1.name, artists,
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

function bestArtistMatch(
  artists: Array<ArtistT> | null,
  name: string,
): ExpandedArtistCreditNameT | null {
  if (!artists) {
    return null;
  }
  let match: ExpandedArtistCreditNameT | null = null;
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
): Array<ExpandedArtistCreditNameT> {
  /*
   * See which produces a better match to an existing artist: the full
   * credit, or the individual credits as split by collabRegex. Some artist
   * names legitimately contain characters in collabRegex, so this stops
   * those from getting split (assuming the artist appears in a relationship
   * or artist credit).
   */
  const bestFullMatch = bestArtistMatch(artists, fullName);

  function fixJoinPhrase(existing: string) {
    const joinPhrase = (existing || ' & ');

    return hasFullwidthLatin(existing)
      ? toFullwidthLatin(joinPhrase)
      : joinPhrase;
  }

  const splitParts = fullName.split(collabRegex);
  const splitMatches: Array<ExpandedArtistCreditNameT> = [];
  let bestSplitMatch: ExpandedArtistCreditNameT;

  for (let i = 0; i < splitParts.length; i += 2) {
    const name = splitParts[i];
    const match: ExpandedArtistCreditNameT = {
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
): GuessFeatResultT | null {
  const name = entity.name;

  if (empty(name)) {
    // Nothing to guess from an empty name
    return null;
  }

  const isTrack = entity.entityType === 'track';
  const relatedArtists = isTrack
    ? getRelatedArtists(entity.recording?.relationships)
    : getRelatedArtists(entity.relationships);

  const match = extractFeatCredits(
    name, relatedArtists, false,
  );

  if (!match.name || !match.artistCredit.length) {
    return null;
  }

  const artistCreditNamesCtx = mutate(entity.artistCredit.names);
  artistCreditNamesCtx.set(
    entity.artistCredit.names.length - 1,
    'joinPhrase',
    match.joinPhrase,
  );
  expect(last(match.artistCredit)).joinPhrase = '';

  for (const name of match.artistCredit) {
    artistCreditNamesCtx.write().push({
      artist: name.artist,
      joinPhrase: name.joinPhrase,
      name: name.name,
    });
  }

  return {
    name: match.name,
    artistCreditNames: artistCreditNamesCtx.final(),
  };
}

/*
 * The following bits are deprecated and shouldn't be needed after
 * we finish the React conversion. I'm not bothering to add Flow
 * to them.
 */

export function guessFeatForReleaseEditor(
  // eslint-disable-next-line ft-flow/no-weak-types
  entity: any,
  // eslint-disable-next-line ft-flow/no-weak-types
): any {
  const name = entity.name();

  if (empty(name)) {
    // Nothing to guess from an empty name
    return;
  }

  let relatedArtists = entity.relatedArtists;
  if (relatedArtists == null) {
    relatedArtists = getRelatedArtists(entity.relationships);
  } else if (typeof relatedArtists === 'function') {
    relatedArtists = relatedArtists.call(entity);
  }

  const match = extractFeatCredits(
    name, relatedArtists, false,
  );

  if (!match.name || !match.artistCredit.length) {
    return;
  }

  entity.name(match.name);

  const artistCredit = cloneArrayDeep(entity.artistCredit().names);
  // $FlowExpectedError[incompatible-use]
  last(artistCredit).joinPhrase = match.joinPhrase;
  // $FlowExpectedError[incompatible-use]
  last(match.artistCredit).joinPhrase = '';

  for (const name of match.artistCredit) {
  // $FlowExpectedError[incompatible-type]
    delete name.similarity;
  }

  entity.artistCredit({
    names: artistCredit.concat(match.artistCredit),
  });
}

// For use outside of the release editor.
// eslint-disable-next-line ft-flow/no-weak-types
export function initGuessFeatButton(formName: any): any {
  // $FlowExpectedError[prop-missing]
  const source = MB.getSourceEntityInstance();
  /* eslint-disable-next-line @stylistic/multiline-comment-style */
  // $FlowExpectedError[unsafe-object-assign]
  // $FlowExpectedError[prop-missing]
  const augmentedEntity = Object.assign(
    Object.create(source),
    {
      /*
       * Emulate an observable that just reads/writes
       * to the name input directly.
       */
      // $FlowExpectedError[missing-local-annot]
      name(...args) {
        const nameInput = document.getElementById('id-' + formName + '.name');
        if (args.length) {
          // $FlowExpectedError[incompatible-type]
          setInputValueForReact(nameInput, args[0]);
          return undefined;
        }
        /* eslint-disable-next-line @stylistic/multiline-comment-style */
        // $FlowExpectedError[prop-missing]
        // $FlowExpectedError[incompatible-use]
        return nameInput.value;
      },
    },
  );

  $(document).on('click', 'button.guessfeat.icon', function () {
    guessFeatForReleaseEditor(augmentedEntity);
  });
}
