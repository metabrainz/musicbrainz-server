/*
 * @flow strict
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isLeapYear from './isLeapYear.js';

const daysInMonth = [
  // non-leap year
  [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
  // leap year
  [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
];

export default function getDaysInMonth(year: number, month: number): number {
  return daysInMonth[isLeapYear(year) ? 1 : 0][month - 1];
}
