/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isDateEmpty from './isDateEmpty.js';

export default function areDatesEqual(
  a: PartialDateT | null,
  b: PartialDateT | null,
): boolean %checks {
  return (isDateEmpty(a) && isDateEmpty(b)) || (
    a !== null && b !== null &&
    a.year === b.year && a.month === b.month && a.day === b.day
  );
}
