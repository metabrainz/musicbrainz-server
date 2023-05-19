/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import parseDate from '../../common/utility/parseDate.js';

test('parseDate', function (t) {
  t.plan(16);

  /* eslint-disable sort-keys */
  const parseDateTests = [
    {date: '', expected: {year: null, month: null, day: null}},
    {date: '0000', expected: {year: 0, month: null, day: null}},
    {date: '1999-01-02', expected: {year: 1999, month: 1, day: 2}},
    {date: '1999-01', expected: {year: 1999, month: 1, day: null}},
    {date: '1999', expected: {year: 1999, month: null, day: null}},
    {date: '????-01-02', expected: {year: null, month: 1, day: 2}},
    {date: '????-??-02', expected: {year: null, month: null, day: 2}},
    {date: '1999-??-02', expected: {year: 1999, month: null, day: 2}},

    // Relationship editor seeding format (via URL query params).
    {date: '-----', expected: {year: null, month: null, day: null}},
    {date: '----02', expected: {year: null, month: null, day: 2}},
    {date: '--01--', expected: {year: null, month: 1, day: null}},
    {date: '--01-02', expected: {year: null, month: 1, day: 2}},
    {date: '1999--', expected: {year: 1999, month: null, day: null}},
    {date: '1999----', expected: {year: 1999, month: null, day: null}},
    {date: '1999---02', expected: {year: 1999, month: null, day: 2}},
    {date: '1999-01--', expected: {year: 1999, month: 1, day: null}},
  ];
  /* eslint-enable sort-keys */

  for (const test of parseDateTests) {
    const result = parseDate(test.date);
    t.deepEqual(result, test.expected, test.date);
  }
});
