/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable sort-keys */
const NULL_DATE: PartialDateT = Object.freeze({
  year: -Infinity,
  month: 1,
  day: 1,
});
/* eslint-enable sort-keys */

export default function compareDates(a: ?PartialDateT, b: ?PartialDateT): number {
  a = a || NULL_DATE;
  b = b || NULL_DATE;

  const result = (a.year || -Infinity) - (b.year || -Infinity);
  // Both have no year
  if (isNaN(result)) {
    return 0;
  } else if (result) {
    return result;
  }

  return (
    ((a.month || 1) - (b.month || 1)) ||
    ((a.day || 1) - (b.day || 1))
  );
}

export function compareDatePeriods(
  a: ?$ReadOnly<{...DatePeriodRoleT, ...}>,
  b: ?$ReadOnly<{...DatePeriodRoleT, ...}>,
): number {
  // Sort null values first
  if (!a) {
    return b ? -1 : 0;
  } else if (!b) {
    return 1;
  }
  return (
    compareDates(a.begin_date, b.begin_date) ||
    compareDates(a.end_date, b.end_date) ||
    // Sort ended dates before non-ended ones
    ((a.ended ? 0 : 1) - (b.ended ? 0 : 1))
  );
}
