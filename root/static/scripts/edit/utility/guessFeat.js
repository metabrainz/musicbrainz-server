/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import balanced from 'balanced-match';
import _ from 'lodash';

import {MIN_NAME_SIMILARITY} from '../../common/constants';
import MB from '../../common/MB';
import clean from '../../common/utility/clean';

import {
  fromFullwidthLatin,
  hasFullwidthLatin,
  toFullwidthLatin,
} from './fullwidthLatin';
import getSimilarity from './similarity';

/* eslint-disable sort-keys */
const featRegex = /(?:^\s*|[,，－\-]\s*|\s+)((?:ft|feat|ｆｔ|ｆｅａｔ)(?:[.．]|(?=\s))|(?:featuring|ｆｅａｔｕｒｉｎｇ)(?=\s))\s*/i;
const collabRegex = /([,，]?\s+(?:&|and|et|＆|ａｎｄ|ｅｔ)\s+|、|[,，;；]\s+|\s*[\/／]\s*|\s+(?:vs|ｖｓ)[.．]\s+)/i;
const bracketPairs = [['(', ')'], ['[', ']'], ['（', '）'], ['［', '］']];

function extractNonBracketedFeatCredits(str, artists, isProbablyClassical) {
  const wrapped = _(str.split(featRegex)).map(clean);

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

  const name = clean(wrapped.head());

  const joinPhrase = (wrapped.size() < 2)
    ? ''
    : fixFeatJoinPhrase(wrapped.pullAt(1));

  const artistCredit = wrapped
    .splice(2)
    .filter((value, key) => key % 2 === 0)
    .compact()
    .map(c => expandCredit(c, artists, isProbablyClassical))
    .flatten()
    .value();

  return {
    name: name,
    joinPhrase: joinPhrase,
    artistCredit: artistCredit,
  };
}

function extractBracketedFeatCredits(str, artists, isProbablyClassical) {
  return _.reduce(bracketPairs, function (accum, pair) {
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

          if (_.some(
            expandedCredits, c => c.similarity >= MIN_NAME_SIMILARITY,
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
  return _(artists)
    .map(function (a) {
      const similarity = getSimilarity(name, a.name);
      if (similarity >= MIN_NAME_SIMILARITY) {
        return {similarity: similarity, artist: a, name: name};
      }
      return null;
    })
    .compact()
    .sortBy('similarity')
    .reverse()
    .head();
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

  const splitMatches = _(fullName.split(collabRegex))
    .chunk(2)
    .map(function (pair) {
      const name = cleanCredit(pair[0], isProbablyClassical);

      return Object.assign(
        {
          similarity: -1,
          artist: null,
          name: name,
          joinPhrase: fixJoinPhrase(pair[1]),
        },
        bestArtistMatch(artists, name) || {},
      );
    });

  if (bestFullMatch &&
    bestFullMatch.similarity > splitMatches
      .sortBy('similarity')
      .reverse()
      .head()
      .similarity) {
    bestFullMatch.joinPhrase = fixJoinPhrase();
    return [bestFullMatch];
  }

  return splitMatches.value();
}

export default function guessFeat(entity) {
  const relatedArtists = _.result(entity, 'relatedArtists');
  const isProbablyClassical = _.result(entity, 'isProbablyClassical');

  const name = entity.name();
  const match = extractFeatCredits(
    name, relatedArtists, isProbablyClassical, false,
  );

  if (!match.name || !match.artistCredit.length) {
    return;
  }

  entity.name(match.name);

  const artistCredit = entity.artistCredit().names.slice(0);
  _.last(artistCredit).joinPhrase = match.joinPhrase;
  _.last(match.artistCredit).joinPhrase = '';

  for (const name of match.artistCredit) {
    delete name.similarity;
  }

  entity.artistCredit({
    names: artistCredit.concat(match.artistCredit),
  });

  entity.artistCreditEditorInst && entity.artistCreditEditorInst.setState({
    artistCredit: entity.artistCredit.peek(),
  });
}

// For use outside of the release editor.
MB.Control.initGuessFeatButton = function (formName) {
  const nameInput = document.getElementById('id-' + formName + '.name');

  const augmentedEntity = Object.assign(
    Object.create(MB.sourceRelationshipEditor.source),
    {
      /*
       * Emulate an observable that just reads/writes
       * to the name input directly.
       */
      name: function () {
        if (arguments.length) {
          nameInput.value = arguments[0];
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
