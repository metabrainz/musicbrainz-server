/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type TocDetails = {
  +leadout_offset: number | null,
  +track_count: number,
  +track_offset: $ReadOnlyArray<number> | null,
};

export default function calculateFullToc(
  cdtoc: $ReadOnly<{...TocDetails, ...}>,
): string {
  const trackOffset = cdtoc.track_offset;
  invariant(trackOffset != null, 'Expected a defined track offset');

  const leadoutOffset = cdtoc.leadout_offset;
  invariant(leadoutOffset != null, 'Expected a defined leadout offset');

  const trackOffsets = trackOffset.join(' ');

  return `1 ${cdtoc.track_count} ${leadoutOffset} ${trackOffsets}`;
}
