/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import compareDates, {
  compareDatePeriods,
} from '../../common/utility/compareDates.js';

test('compareDates', function (t) {
  t.plan(7);

  t.ok(compareDates(null, null) === 0);
  t.ok(compareDates({}, {}) === 0);
  t.ok(compareDates(null, {}) === 0);
  t.ok(compareDates({}, null) === 0);

  /* eslint-disable sort-keys */
  const sortedDates = [
    null,
    {day: 1},
    {day: 2},
    {month: 1},
    {month: 1, day: 1},
    {month: 1, day: 2},
    {month: 2},
    {month: 2, day: 1},
    {month: 2, day: 2},
    {year: 0},
    {year: 0, day: 1},
    {year: 0, day: 2},
    {year: 0, month: 1},
    {year: 0, month: 1, day: 1},
    {year: 0, month: 1, day: 2},
    {year: 0, month: 2},
    {year: 0, month: 2, day: 1},
    {year: 0, month: 2, day: 2},
    {year: 2000},
    {year: 2000, day: 1},
    {year: 2000, day: 2},
    {year: 2000, month: 1},
    {year: 2000, month: 1, day: 1},
    {year: 2000, month: 1, day: 2},
    {year: 2000, month: 2},
    {year: 2000, month: 2, day: 1},
    {year: 2000, month: 2, day: 2},
  ];
  /* eslint-enable sort-keys */

  let copy = sortedDates.slice(0)
    .sort((a, b) => (a?.year ?? 0) - (b?.year ?? 0));
  copy.sort(compareDates);
  t.deepEqual(copy, sortedDates);

  copy = sortedDates.slice(0)
    .sort((a, b) => (a?.month ?? 0) - (b?.month ?? 0));
  copy.sort(compareDates);
  t.deepEqual(copy, sortedDates);

  copy = sortedDates.slice(0)
    .sort((a, b) => (a?.day ?? 0) - (b?.day ?? 0));
  copy.sort(compareDates);
  t.deepEqual(copy, sortedDates);
});

test('compareDatePeriods', function (t) {
  t.plan(9);

  /* eslint-disable sort-keys */
  t.ok(compareDatePeriods(
    null,
    {begin_date: {year: 0}, end_date: {year: 0}, ended: true},
  ) < 0, 'null date periods sort before non-null ones');

  t.ok(compareDatePeriods(
    null,
    {},
  ) === 0, 'empty date period objects are considered null');

  t.ok(compareDatePeriods(
    {
      begin_date: {month: 12, day: 1},
      end_date: {month: 1, day: 1},
      ended: true,
    },
    {
      begin_date: {month: 1, day: 1},
      end_date: {month: 1, day: 1},
      ended: true,
    },
  ) > 0, 'date periods without years are sorted by month, day');

  t.ok(compareDatePeriods(
    {
      begin_date: {month: 1, day: 1},
      end_date: {month: 1, day: 1},
      ended: true,
    },
    {
      begin_date: {month: 1, day: 1},
      end_date: {month: 12, day: 1},
      ended: true,
    },
  ) < 0, 'date periods without years are sorted by month, day');

  t.ok(compareDatePeriods(
    {begin_date: {month: 12, day: 1}, end_date: {year: 1977}, ended: true},
    {begin_date: {month: 1, day: 1}, end_date: {year: 2001}, ended: true},
  ) < 0, 'date periods with no begin years are sorted by end years');

  t.ok(compareDatePeriods(
    {begin_date: {day: 12}, end_date: {month: 1}, ended: true},
    {begin_date: {day: 1}, end_date: {month: 12}, ended: true},
  ) < 0, 'date periods with no begin months are sorted by end months');

  t.ok(compareDatePeriods(
    {begin_date: null, end_date: {day: 12}, ended: true},
    {begin_date: null, end_date: {day: 1}, ended: true},
  ) > 0, 'date periods with only end days are sorted');

  t.ok(compareDatePeriods(
    {
      begin_date: {month: 12, day: 1},
      end_date: {year: 1977},
      ended: true,
    },
    {
      begin_date: {month: 1, day: 1},
      end_date: {month: 1, day: 1},
      ended: true,
    },
  ) > 0, 'date periods with null years are sorted before ones with years');

  t.ok(compareDatePeriods(
    {begin_date: null, end_date: null, ended: true},
    {begin_date: null, end_date: null, ended: false},
  ) < 0, 'ended date periods are sorted before non-ended ones');
  /* eslint-enable sort-keys */
});
