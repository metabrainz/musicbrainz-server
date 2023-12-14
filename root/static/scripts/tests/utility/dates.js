/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import * as dates from '../../edit/utility/dates.js';

test('isDateValid', function (t) {
  t.plan(18);

  /* eslint-disable sort-keys */
  t.equal(
    dates.isDateValid({year: '', month: '', day: ''}),
    true,
    'all empty strings are valid',
  );
  t.equal(
    dates.isDateValid({year: undefined, month: undefined, day: undefined}),
    true,
    'all undefined values are valid',
  );
  t.equal(
    dates.isDateValid({year: null, month: null, day: null}),
    true,
    'all null values are valid',
  );
  t.equal(
    dates.isDateValid({year: 2000}),
    true,
    'just a year is valid',
  );
  t.equal(
    dates.isDateValid({year: -4}),
    true,
    'just a year BCE is valid',
  );
  t.equal(
    dates.isDateValid({year: '', month: 10}),
    true,
    'just a month is valid',
  );
  t.equal(
    dates.isDateValid({year: '', month: '', day: 29}),
    true,
    'just a day is valid',
  );
  t.equal(
    dates.isDateValid({year: 0}),
    false,
    'the year 0 is invalid',
  );
  t.equal(
    dates.isDateValid({year: '', month: 13}),
    false,
    'months > 12 are invalid',
  );
  t.equal(
    dates.isDateValid({year: '', month: '', day: 32}),
    false,
    'days > 31 are invalid',
  );
  t.equal(
    dates.isDateValid({year: 2001, month: 2, day: 29}),
    false,
    '2001-02-29 is invalid',
  );
  t.equal(
    dates.isDateValid({year: '2000f'}),
    false,
    'letters are invalid',
  );
  t.equal(
    dates.isDateValid({year: 1960, month: 2, day: 29}),
    true,
    'leap years are handled correctly (MBS-5663)',
  );
  t.equal(
    dates.isDateValid({year: null, month: null, day: 10}),
    true,
    'just a day with nulls is valid',
  );
  t.equal(
    dates.isDateValid({year: 2010, month: null, day: 10}),
    true,
    'just a day and year with null month is valid',
  );
  t.equal(
    dates.isDateValid({year: 1900, month: 2, day: 29}),
    false,
    '1900 was no leap year',
  );
  t.equal(
    dates.isDateValid({year: 2000, month: 2, day: 29}),
    true,
    '2000 was a leap year',
  );
  t.equal(
    dates.isDateValid({year: -5, month: 2, day: 29}),
    true,
    'leap years BCE are handled correctly',
  );
  /* eslint-enable sort-keys */
});

test('isDatePeriodValid', function (t) {
  t.plan(9);

  /* eslint-disable sort-keys */
  const tests = [
    {
      a: {},
      b: {},
      expected: true,
    },
    {
      a: {year: 2000, month: null, day: 11},
      b: {year: 2000, month: null, day: 10},
      expected: true,
    },
    {
      a: {year: -45, month: null, day: null},
      b: {year: 17, month: null, day: null},
      expected: true,
    },
    {
      a: {year: 2000, month: 11, day: 11},
      b: {year: 2000, month: 12, day: 12},
      expected: true,
    },
    {
      a: {year: 2000, month: 11, day: 11},
      b: {year: 1999, month: 12, day: 12},
      expected: false,
    },
    {
      a: {year: 2000, month: 11, day: 11},
      b: {year: 2000, month: 10, day: 12},
      expected: false,
    },
    {
      a: {year: 2000, month: 11, day: 11},
      b: {year: 2000, month: 11, day: 10},
      expected: false,
    },
    {
      a: {year: '2000', month: '3', day: '1'},
      b: {year: '2000', month: '10', day: '1'},
      expected: true,
    },
    {
      a: {year: 1961, month: 2, day: 28},
      b: {year: 1961, month: 2, day: 29},
      expected: false,
    },
  ];
  /* eslint-enable sort-keys */

  for (const test of tests) {
    t.equal(dates.isDatePeriodValid(test.a, test.b), test.expected);
  }
});
