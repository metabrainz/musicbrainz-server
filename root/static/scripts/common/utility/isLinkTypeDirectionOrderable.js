/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  SERIES_ORDERING_TYPE_AUTOMATIC,
} from '../constants.js';
import linkedEntities from '../linkedEntities.mjs';

export default function isLinkTypeDirectionOrderable(
  linkType: LinkTypeT,
  backward: boolean,
): boolean {
  // `backward` indicates whether the relationship target is entity0
  return (linkType.orderable_direction === 1 && !backward) ||
          (linkType.orderable_direction === 2 && backward);
}

export function isLinkTypeOrderableByUser(
  linkTypeId: number | null,
  source: RelatableEntityT,
  backward: boolean,
): boolean {
  const linkType: ?LinkTypeT = linkTypeId == null
    ? null
    : linkedEntities.link_type[linkTypeId];
  return linkType ? (
    isLinkTypeDirectionOrderable(linkType, backward) &&
    !(source.entityType === 'series' &&
      source.orderingTypeID === SERIES_ORDERING_TYPE_AUTOMATIC)
  ) : false;
}
