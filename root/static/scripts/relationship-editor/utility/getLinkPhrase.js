/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';

import {
  isLinkTypeOrderableByUser,
} from '../../common/utility/isLinkTypeDirectionOrderable.js';
import {interpolateText} from '../../edit/utility/linkPhrase.js';
import type {
  RelationshipStateT,
} from '../types.js';

import getRelationshipLinkType from './getRelationshipLinkType.js';

const linkPhraseCache:
  // The tuple stores [forward, backward] link phrases.
  WeakMap<RelationshipStateT, [string | null, string | null]> = new WeakMap();

export default function getLinkPhrase(
  relationship: RelationshipStateT,
  backward: boolean,
): string {
  let linkPhrases = linkPhraseCache.get(relationship);
  const index = backward ? 1 : 0;
  if (linkPhrases != null && linkPhrases[index] != null) {
    return linkPhrases[index];
  }
  const linkType = getRelationshipLinkType(relationship);
  if (!linkType) {
    return '';
  }
  if (linkPhrases == null) {
    linkPhrases = ([null, null]: [string | null, string | null]);
  }
  const textPhrase = interpolateText(
    linkType,
    tree.toArray(relationship.attributes),
    backward ? 'reverse_link_phrase' : 'link_phrase',
    isLinkTypeOrderableByUser(
      linkType.id,
      backward ? relationship.entity1 : relationship.entity0,
      backward,
    ),
  );
  linkPhrases[index] = textPhrase;
  linkPhraseCache.set(relationship, linkPhrases);
  return textPhrase;
}
