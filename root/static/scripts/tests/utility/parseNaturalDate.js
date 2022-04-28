/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import parseNaturalDate from '../../common/utility/parseNaturalDate.js';

test('parseNaturalDate', function (t) {
  t.plan(10);

  /* eslint-disable sort-keys */
  const parseDateTests = [
    // Nothing
    {date: '', expected: {year: '', month: '', day: ''}},

    // Y-M-D
    {date: '0000', expected: {year: '0000', month: '', day: ''}},
    {date: '1999-01-02', expected: {year: '1999', month: '01', day: '02'}},
    {date: '1999-01', expected: {year: '1999', month: '01', day: ''}},
    {date: '1999', expected: {year: '1999', month: '', day: ''}},

    // Y M D
    {date: '1999 01 02', expected: {year: '1999', month: '01', day: '02'}},
    {date: '1999 01', expected: {year: '1999', month: '01', day: ''}},

    // Fullwidth numbers
    {
      date: '１９９９－０１－０２',
      expected: {year: '1999', month: '01', day: '02'},
    },
    {
      date: '１９９９-０１-０２',
      expected: {year: '1999', month: '01', day: '02'},
    },
    {
      date: '１９９９ ０１ ０２',
      expected: {year: '1999', month: '01', day: '02'},
    },
  ];
  /* eslint-enable sort-keys */

  for (const test of parseDateTests) {
    const result = parseNaturalDate(test.date);
    t.deepEqual(result, test.expected, test.date);
  }
});
