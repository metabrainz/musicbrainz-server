/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {stripAttributes} from '../../edit/utility/linkPhrase.js';
import getRelationshipLinkType
  from '../../relationship-editor/utility/getRelationshipLinkType.js';
import type {LinkRelationshipStateT} from '../types.js';

const linkPhraseCache = new WeakMap<LinkRelationshipStateT, string>();
export default function getLinkPhrase(
  relationship: LinkRelationshipStateT,
): string {
  let linkPhrase = linkPhraseCache.get(relationship);
  if (linkPhrase != null) {
    return linkPhrase;
  }
  const linkType = getRelationshipLinkType(relationship);
  linkPhrase = linkType ? (
    linkType.type0 === 'url' ? (
      stripAttributes(
        linkType,
        linkType.l_reverse_link_phrase ?? '',
      )
    ) : (
      stripAttributes(
        linkType,
        linkType.l_link_phrase ?? '',
      )
    )
  ) : '';
  linkPhraseCache.set(relationship, linkPhrase);
  return linkPhrase;
}
