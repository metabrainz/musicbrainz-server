/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {
  LinkRelationshipStateT,
  LinkStateT,
} from '../types.js';

function canMergeLinkRelationship(
  relationship: LinkRelationshipStateT,
): boolean {
  return relationship.error == null ||
    relationship.error.blockMerge !== true;
}

export default function canMergeLink(link: LinkStateT): boolean {
  return (
    link.isNew &&
    link.duplicateOf != null &&
    (link.error == null || link.error.blockMerge !== true) &&
    link.relationships.every(canMergeLinkRelationship)
  );
}
