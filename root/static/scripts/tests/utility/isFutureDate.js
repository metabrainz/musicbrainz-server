/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isFutureDate from '../../common/utility/isFutureDate.js';

test('isFutureDate', function (t) {
  t.plan(4);

  t.ok(
    !isFutureDate(null),
    'null date is not in the future',
  );

  t.ok(
    !isFutureDate({day: 12, month: 12, year: null}),
    'Date without a year is not in the future',
  );

  t.ok(
    !isFutureDate({day: 12, month: 12, year: 1111}),
    'Date with a year in the past is not in the future',
  );

  t.ok(
    // This will break in a thousand years or so, we can fix it by then
    isFutureDate({day: 12, month: 12, year: 3111}),
    'Date with a year in the future is indeed in the future',
  );
});
