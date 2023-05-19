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
  t.plan(12);

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
  /* eslint-enable sort-keys */
});

test('isDatePeriodValid', function (t) {
  t.plan(8);

  var tests = [
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

  for (const test of tests) {
    t.equal(dates.isDatePeriodValid(test.a, test.b), test.expected);
  }
});
