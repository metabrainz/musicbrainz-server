/*
 * @flow strict
 * Copyright (C) 2012-2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import getDaysInMonth from '../../../../utility/getDaysInMonth';
import parseInteger from '../../common/utility/parseInteger';

type PartialDateWithStringsT = {
  +day: string | null,
  +month: string | null,
  +year: string | null,
};

export const isDateValid = function (
  year: string | null,
  month: string | null,
  day: string | null,
): boolean {
  const y = nonEmpty(year) ? parseInteger(year) : null;
  const m = nonEmpty(month) ? parseInteger(month) : null;
  const d = nonEmpty(day) ? parseInteger(day) : null;

  // We couldn't parse one of the fields as a number.
  if (isNaN(y) || isNaN(m) || isNaN(d)) {
    return false;
  }

  // The year is a number less than 1.
  if (y !== null && y < 1) {
    return false;
  }

  // The month is a number less than 1 or greater than 12.
  if (m !== null && (m < 1 || m > 12)) {
    return false;
  }

  // The day is empty. There's no further validation we can do.
  if (d === null) {
    return true;
  }

  // Invalid number of days based on the year.
  if (
    d < 1 || d > 31 ||
    (y != null && m != null && d > getDaysInMonth(y, m))
  ) {
    return false;
  }

  // The date is assumed to be valid.
  return true;
};

export const isYearFourDigits = function (y: string): boolean {
  return (y === null || y === '' || y.length === 4);
};

export const isDatePeriodValid = function (
  a: PartialDateWithStringsT,
  b: PartialDateWithStringsT,
): boolean {
  const {year: y1, month: m1, day: d1} = a;
  const {year: y2, month: m2, day: d2} = b;

  if (!isDateValid(y1, m1, d1) || !isDateValid(y2, m2, d2)) {
    return false;
  }

  if (!nonEmpty(y1) || !nonEmpty(y2) || +y1 < +y2) {
    return true;
  } else if (+y2 < +y1) {
    return false;
  }
  if (!nonEmpty(m1) || !nonEmpty(m2) || +m1 < +m2) {
    return true;
  } else if (+m2 < +m1) {
    return false;
  }
  if (!nonEmpty(d1) || !nonEmpty(d2) || +d1 < +d2) {
    return true;
  } else if (+d2 < +d1) {
    return false;
  }

  return true;
};
