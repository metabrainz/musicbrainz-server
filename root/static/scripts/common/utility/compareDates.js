/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {EMPTY_PARTIAL_DATE} from '../constants.js';

/* eslint-disable sort-keys */
const NULL_DATE_PERIOD: DatePeriodRoleT = Object.freeze({
  begin_date: EMPTY_PARTIAL_DATE,
  end_date: EMPTY_PARTIAL_DATE,
  ended: false,
});
/* eslint-enable sort-keys */

function compareNullableNumbers(a: ?number, b: ?number) {
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
  const aOrEmpty = a ?? EMPTY_PARTIAL_DATE;
  const bOrEmpty = b ?? EMPTY_PARTIAL_DATE;

  return (
    compareNullableNumbers(aOrEmpty.year, bOrEmpty.year) ||
    compareNullableNumbers(aOrEmpty.month, bOrEmpty.month) ||
    compareNullableNumbers(aOrEmpty.day, bOrEmpty.day)
  );
}

export function compareDatePeriods(
  a: ?$ReadOnly<{...DatePeriodRoleT, ...}>,
  b: ?$ReadOnly<{...DatePeriodRoleT, ...}>,
): number {
  const aOrEmpty = a ?? NULL_DATE_PERIOD;
  const bOrEmpty = b ?? NULL_DATE_PERIOD;

  const beginDateA = aOrEmpty.begin_date ?? EMPTY_PARTIAL_DATE;
  const beginDateB = bOrEmpty.begin_date ?? EMPTY_PARTIAL_DATE;
  const endDateA = aOrEmpty.end_date ?? EMPTY_PARTIAL_DATE;
  const endDateB = bOrEmpty.end_date ?? EMPTY_PARTIAL_DATE;

  return (
    compareNullableNumbers(beginDateA.year, beginDateB.year) ||
    compareNullableNumbers(endDateA.year, endDateB.year) ||
    compareNullableNumbers(beginDateA.month, beginDateB.month) ||
    compareNullableNumbers(endDateA.month, endDateB.month) ||
    compareNullableNumbers(beginDateA.day, beginDateB.day) ||
    compareNullableNumbers(endDateA.day, endDateB.day) ||
    // Sort ended dates before non-ended ones
    ((aOrEmpty.ended ? 0 : 1) - (bOrEmpty.ended ? 0 : 1))
  );
}
