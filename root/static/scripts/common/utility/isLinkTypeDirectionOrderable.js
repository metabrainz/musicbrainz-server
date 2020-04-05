/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function isLinkTypeDirectionOrderable(
  linkType: LinkTypeT,
  backward: boolean,
): boolean {
  // `backward` indicates whether the relationship target is entity0
  return (linkType.orderable_direction === 1 && !backward) ||
          (linkType.orderable_direction === 2 && backward);
}
