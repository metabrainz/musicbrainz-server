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
  year: null,
  month: null,
  day: null,
});

const NULL_DATE_PERIOD: DatePeriodRoleT = Object.freeze({
  begin_date: NULL_DATE,
  end_date: NULL_DATE,
  ended: false,
});
/* eslint-enable sort-keys */

function compareNullableNumbers(a, b) {
  // Sort null values first
  if (a == null) {
    return b == null ? 0 : -1;
  } else if (b == null) {
    return 1;
  }
  return a - b;
}

export default function compareDates(
  a: ?PartialDateT,
  b: ?PartialDateT,
): number {
  a = a ?? NULL_DATE;
  b = b ?? NULL_DATE;

  return (
    compareNullableNumbers(a.year, b.year) ||
    compareNullableNumbers(a.month, b.month) ||
    compareNullableNumbers(a.day, b.day)
  );
}

export function compareDatePeriods(
  a: ?$ReadOnly<{...DatePeriodRoleT, ...}>,
  b: ?$ReadOnly<{...DatePeriodRoleT, ...}>,
): number {
  a = a ?? NULL_DATE_PERIOD;
  b = b ?? NULL_DATE_PERIOD;

  const beginDateA = a.begin_date ?? NULL_DATE;
  const beginDateB = b.begin_date ?? NULL_DATE;
  const endDateA = a.end_date ?? NULL_DATE;
  const endDateB = b.end_date ?? NULL_DATE;

  return (
    compareNullableNumbers(beginDateA.year, beginDateB.year) ||
    compareNullableNumbers(endDateA.year, endDateB.year) ||
    compareNullableNumbers(beginDateA.month, beginDateB.month) ||
    compareNullableNumbers(endDateA.month, endDateB.month) ||
    compareNullableNumbers(beginDateA.day, beginDateB.day) ||
    compareNullableNumbers(endDateA.day, endDateB.day) ||
    // Sort ended dates before non-ended ones
    ((a.ended ? 0 : 1) - (b.ended ? 0 : 1))
  );
}
