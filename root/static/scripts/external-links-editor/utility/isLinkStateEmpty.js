/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {LinkStateT} from '../types.js';

export function areLinkRelationshipsEmpty(link: LinkStateT): boolean {
  for (const relationship of link.relationships) {
    if (relationship.linkTypeID != null) {
      return false;
    }
  }
  return true;
}

export default function isLinkStateEmpty(link: LinkStateT): boolean {
  return empty(link.url) && areLinkRelationshipsEmpty(link);
}
