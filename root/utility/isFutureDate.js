/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function isFutureDate(
  givenDate: PartialDateT | null,
): boolean {
  const givenYear = givenDate?.year;
  if (givenDate == null || givenYear == null) {
    return false;
  }

  const now = new Date();
  const currentDate = {
    day: now.getUTCDate(),
    // Months in JavaScript are 0-based. (Days and years are not.)
    month: now.getUTCMonth() + 1,
    year: now.getUTCFullYear(),
  };

  if (givenYear > currentDate.year) {
    return true;
  }

  if (givenYear === currentDate.year) {
    if (givenDate.month == null) {
      return false;
    }
    if (givenDate.month > currentDate.month) {
      return true;
    }
    if (givenDate.month === currentDate.month) {
      if (givenDate.day == null) {
        return false;
      }
      if (givenDate.day > currentDate.day) {
        return true;
      }
    }
  }

  return false;
}
