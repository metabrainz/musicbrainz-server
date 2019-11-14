/*
 * @flow strict
 * Copyright (C) 2009 Kuno Woudt
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import getDaysInMonth from './getDaysInMonth';

function timestamp(date) {
  return Date.UTC(
    (date.year ?? 1),
    (date.month ?? 1) - 1,
    (date.day ?? 1),
  );
}

export function hasAge<+T: {...DatePeriodRoleT, ...}>(entity: T) {
  const begin = entity.begin_date;
  const end = entity.end_date;
  const ended = entity.ended;
  const beginYear = begin && begin.year;

  /*
   * If there is no begin year, there is no age.
   * Only compute ages when the begin date is AD.
   */
  if (!begin || beginYear == null || beginYear < 1) {
    return false;
  }

  // The begin date must be before now.
  if (timestamp(begin) >= Date.now()) {
    return false;
  }

  // If the entity is still active, the end date is now (so there is an age).
  if (!ended) {
    return true;
  }

  // The end date must have a year.
  if (!end || end.year == null) {
    return false;
  }

  /*
   * Return true if we find a begin date component less than its corresponding
   * end date component, but return false if we come across a null field in
   * either position, since we can't determine anything about the age in that
   * case.
   */
  if (beginYear < end.year) {
    return true;
  }

  if (beginYear === end.year) {
    if (begin.month == null || end.month == null) {
      return false;
    }
    if (begin.month < end.month) {
      return true;
    }
    if (begin.month === end.month) {
      if (begin.day == null || end.day == null) {
        return false;
      }
      if (begin.day < end.day) {
        return true;
      }
    }
  }

  return false;
}

export function age<+T: {...DatePeriodRoleT, ...}>(entity: T) {
  const begin = entity.begin_date;

  if (!begin || !hasAge(entity)) {
    return null;
  }

  const end = entity.end_date;
  let ey;
  let em;
  let ed;

  if (end) {
    ey = end.year ?? 1;
    em = end.month ?? 1;
    ed = end.day ?? 1;
  } else {
    const now = new Date();
    ey = now.getUTCFullYear();
    // Months in JavaScript are 0-based. (Days and years are not.)
    em = now.getUTCMonth() + 1;
    ed = now.getUTCDate();
  }

  let dy = ey - (begin.year ?? 1);
  let dm = em - (begin.month ?? 1);
  let dd = ed - (begin.day ?? 1);

  /*
   * A "month" is not a fixed unit, but intuitively we'd say a month has
   * passed when the days are at the same number.
   *
   * So if the days delta is negative, decrement dm and add the number of
   * days from the month previous to the end month to make it positive.
   */
  if (dd < 0) {
    dm--;
    em--;
    if (em === 0) {
      ey--;
      em = 12;
    }
    dd += getDaysInMonth(ey, em);
  }

  /*
   * If the months delta is negative, decrement dy and add that year
   * (as 12 months) to dm to make it positive.
   */
  if (dm < 0) {
    dy--;
    dm += 12;
  }

  return [dy, dm, dd];
}

export function displayAge(age: [number, number, number], isPerson: boolean) {
  const [years, months, days] = age;

  if (isPerson && years) {
    return texp.l('aged {num}', {num: years});
  } else if (years) {
    return texp.ln('{num} year', '{num} years', years, {num: years});
  } else if (months) {
    return texp.ln('{num} month', '{num} months', months, {num: months});
  }
  return texp.ln('{num} day', '{num} days', days, {num: days});
}

export function displayAgeAgo(age: [number, number, number]) {
  const [years, months, days] = age;

  if (years) {
    return texp.ln('{num} year ago', '{num} years ago', years, {num: years});
  } else if (months) {
    return texp.ln(
      '{num} month ago',
      '{num} months ago',
      months,
      {num: months},
    );
  }
  return texp.ln('{num} day ago', '{num} days ago', days, {num: days});
}
