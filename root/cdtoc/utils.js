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
