/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {arraysEqual} from '../static/scripts/common/utility/arrays.js';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength.js';

export function areFormattedLengthsEqual(
  mediumLengths: $ReadOnlyArray<number>,
  cdTocLengths: $ReadOnlyArray<number>,
): boolean {
  return arraysEqual(
    mediumLengths,
    cdTocLengths,
    (a, b) => formatTrackLength(a) === formatTrackLength(b),
  );
}

export function isPerfectMatch(
  medium: MediumT,
  cdToc: CDTocT,
): boolean {
  const mediumLengths = medium.cdtoc_track_lengths;
  if (!mediumLengths) {
    throw new Error('cdtoc_track_lengths were not loaded');
  }

  const cdTocLengths = cdToc.track_details.map(track => track.length_time);

  return arraysEqual(mediumLengths, cdTocLengths);
}
