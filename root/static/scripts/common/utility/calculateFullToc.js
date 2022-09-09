/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function calculateFullToc(cdtoc: CDStubT | CDTocT): string {
  const trackOffsets = cdtoc.track_offset.join(' ');
  return `1 ${cdtoc.track_count} ${cdtoc.leadout_offset} ${trackOffsets}`;
}
