/*
 * @flow strict
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {isDateValid} from '../../edit/utility/dates.js';

export default function mergeDates(
  a: PartialDateT | null,
  b: PartialDateT | null,
): PartialDateT | null {
  const ay = a?.year;
  const by = b?.year;
  const am = a?.month;
  const bm = b?.month;
  const ad = a?.day;
  const bd = b?.day;
  if (
    (ay != null && by != null && ay !== by) ||
    (am != null && bm != null && am !== bm) ||
    (ad != null && bd != null && ad !== bd)
  ) {
    return null;
  }
  /* eslint-disable no-multi-spaces */
  const mergedDate: PartialDateT = {
    day:   ad ?? bd ?? null,
    month: am ?? bm ?? null,
    year:  ay ?? by ?? null,
  };
  /* eslint-enable no-multi-spaces */
  if (isDateValid(mergedDate)) {
    return mergedDate;
  }
  return null;
}
