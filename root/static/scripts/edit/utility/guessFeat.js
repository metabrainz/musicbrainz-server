/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import balanced from 'balanced-match';

import {MIN_NAME_SIMILARITY} from '../../common/constants.js';
import MB from '../../common/MB.js';
import {last} from '../../common/utility/arrays.js';
import clean from '../../common/utility/clean.js';
import {cloneArrayDeep} from '../../common/utility/cloneDeep.mjs';

import {
  fromFullwidthLatin,
  hasFullwidthLatin,
  toFullwidthLatin,
} from './fullwidthLatin.js';
import getSimilarity from './similarity.js';

/* eslint-disable sort-keys */
const featRegex = /(?:^\s*|[,，－\-]\s*|\s+)((?:ft|feat|ｆｔ|ｆｅａｔ)(?:[.．]|(?=\s))|(?:featuring|ｆｅａｔｕｒｉｎｇ)(?=\s))\s*/i;
const collabRegex = /([,，]?\s+(?:&|and|et|＆|ａｎｄ|ｅｔ)\s+|、|[,，;；]\s+|\s*[\/／]\s*|\s+(?:vs|ｖｓ)[.．]\s+)/i;
const bracketPairs = [['(', ')'], ['[', ']'], ['（', '）'], ['［', '］']];

function extractNonBracketedFeatCredits(str, artists, isProbablyClassical) {
  const parts = str.split(featRegex).map(clean);

  const fixFeatJoinPhrase = function (existing) {
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
  };

  const name = clean(parts[0]);

  const joinPhrase = (parts.length < 2)
    ? ''
    : fixFeatJoinPhrase(parts[1]);

  const artistCredit = parts
    .splice(2)
    .filter((value, key) => value && key % 2 === 0)
    .flatMap(c => expandCredit(c, artists, isProbablyClassical));

  return {
    name: name,
    joinPhrase: joinPhrase,
    artistCredit: artistCredit,
  };
}

function extractBracketedFeatCredits(str, artists, isProbablyClassical) {
  return bracketPairs.reduce(function (accum, pair) {
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

        joinPhrase = joinPhrase || m.joinPhrase;
        credits = credits.concat(m.artistCredit);
        remainder = b.post;
      } else {
        name += remainder;
        break;
      }
    }

    return {name: clean(name), joinPhrase: joinPhrase, artistCredit: credits};
  }, {name: str, joinPhrase: '', artistCredit: []});
}

function extractFeatCredits(
  str, artists, isProbablyClassical, allowEmptyName,
) {
  const m1 = extractBracketedFeatCredits(str, artists, isProbablyClassical);

  if (!m1.name && !allowEmptyName) {
    return {name: str, joinPhrase: '', artistCredit: []};
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

function cleanCredit(name, isProbablyClassical) {
  // remove classical roles
  return isProbablyClassical ? name.replace(/^[a-z]+: (.+)$/, '$1') : name;
}

function bestArtistMatch(artists, name) {
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
      match = {similarity, artist, name};
    }
  }
  return match;
}

function expandCredit(fullName, artists, isProbablyClassical) {
  fullName = cleanCredit(fullName, isProbablyClassical);

  /*
   * See which produces a better match to an existing artist: the full
   * credit, or the individual credits as split by collabRegex. Some artist
   * names legitimately contain characters in collabRegex, so this stops
   * those from getting split (assuming the artist appears in a relationship
   * or artist credit).
   */
  const bestFullMatch = bestArtistMatch(artists, fullName);

  const fixJoinPhrase = function (existing) {
    const joinPhrase = isProbablyClassical ? ', ' : (existing || ' & ');

    return hasFullwidthLatin(existing)
      ? toFullwidthLatin(joinPhrase)
      : joinPhrase;
  };

  const splitParts = fullName.split(collabRegex);
  const splitMatches = [];
  let bestSplitMatch;

  for (let i = 0; i < splitParts.length; i += 2) {
    const name = cleanCredit(splitParts[i], isProbablyClassical);
    const match = {
      similarity: -1,
      artist: null,
      name: name,
      joinPhrase: fixJoinPhrase(splitParts[i + 1]),
      ...bestArtistMatch(artists, name),
    };
    splitMatches.push(match);
    if (!bestSplitMatch || match.similarity > bestSplitMatch.similarity) {
      bestSplitMatch = match;
    }
  }

  if (bestFullMatch && bestFullMatch.similarity > bestSplitMatch.similarity) {
    bestFullMatch.joinPhrase = fixJoinPhrase();
    return [bestFullMatch];
  }

  return splitMatches;
}

export default function guessFeat(entity) {
  const name = entity.name();

  if (!nonEmpty(name)) {
    // Nothing to guess from an empty name
    return;
  }

  let relatedArtists = entity.relatedArtists;
  if (typeof relatedArtists === 'function') {
    relatedArtists = relatedArtists.call(entity);
  }

  let isProbablyClassical = entity.isProbablyClassical;
  if (typeof isProbablyClassical === 'function') {
    isProbablyClassical = isProbablyClassical.call(entity);
  }

  const match = extractFeatCredits(
    name, relatedArtists, isProbablyClassical, false,
  );

  if (!match.name || !match.artistCredit.length) {
    return;
  }

  entity.name(match.name);

  const artistCredit = cloneArrayDeep(entity.artistCredit().names);
  last(artistCredit).joinPhrase = match.joinPhrase;
  last(match.artistCredit).joinPhrase = '';

  for (const name of match.artistCredit) {
    delete name.similarity;
  }

  entity.artistCredit({
    names: artistCredit.concat(match.artistCredit),
  });

  entity.artistCreditEditorInst?.current?.setState({
    artistCredit: entity.artistCredit.peek(),
  });
}

// For use outside of the release editor.
MB.Control.initGuessFeatButton = function (formName) {
  const augmentedEntity = Object.assign(
    Object.create(MB.sourceRelationshipEditor.source),
    {
      /*
       * Emulate an observable that just reads/writes
       * to the name input directly.
       */
      name: function () {
        const nameInput = document.getElementById('id-' + formName + '.name');
        if (arguments.length) {
          // XXX Allows React to see the input value change.
          Object.getOwnPropertyDescriptor(
            window.HTMLInputElement.prototype,
            'value',
          ).set.call(nameInput, arguments[0]);
          nameInput.dispatchEvent(new Event('input', {bubbles: true}));
          return undefined;
        }
        return nameInput.value;
      },
      /*
       * Confusingly, the artistCredit object used to generated hidden input
       * fields is also different from MB.sourceRelationshipEditor.source's,
       * so we have to replace this field too.
       */
      artistCredit: MB.sourceEntity.artistCredit,
    },
  );

  $(document).on('click', 'button.guessfeat.icon', function () {
    guessFeat(augmentedEntity);
  });
};
