/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import natatime from '../../common/utility/natatime.js';

test('natatime', function (t) {
  t.plan(4);

  const longArray = [...Array(13).keys()];
  const iterator = natatime(5, longArray);

  t.deepEqual(
    iterator.next(),
    {done: false, value: [0, 1, 2, 3, 4]},
    'The first iteration returns the first 5 items of the array',
  );

  t.deepEqual(
    iterator.next(),
    {done: false, value: [5, 6, 7, 8, 9]},
    'The second iteration returns the next 5 items of the array',
  );

  t.deepEqual(
    iterator.next(),
    {done: false, value: [10, 11, 12]},
    'The third iteration returns the last 3 items of the array',
  );

  t.deepEqual(
    iterator.next(),
    {done: true, value: undefined},
    'Trying to iterate again lets us know we are done',
  );
});
