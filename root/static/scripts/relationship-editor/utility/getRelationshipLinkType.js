/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import linkedEntities from '../../common/linkedEntities.mjs';

export default function getRelationshipLinkType(
  relationship: {+linkTypeID: number | null, ...} | null,
): LinkTypeT | null {
  const linkTypeId = relationship ? relationship.linkTypeID : null;
  // $FlowIgnore[sketchy-null-number]
  if (linkTypeId) {
    return linkedEntities.link_type[linkTypeId] || null;
  }
  return null;
}
