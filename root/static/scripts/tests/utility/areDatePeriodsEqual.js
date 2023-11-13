/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {EMPTY_PARTIAL_DATE} from '../../common/constants.js';
import areDatePeriodsEqual from '../../common/utility/areDatePeriodsEqual.js';

test('areDatePeriodsEqual', function (t) {
  t.plan(7);

  t.ok(
    areDatePeriodsEqual(
      {
        begin_date: EMPTY_PARTIAL_DATE,
        end_date: EMPTY_PARTIAL_DATE,
        ended: false,
      },
      {
        begin_date: EMPTY_PARTIAL_DATE,
        end_date: EMPTY_PARTIAL_DATE,
        ended: false,
      },
    ),
    'Two empty and non-ended periods are equal',
  );

  t.ok(
    !areDatePeriodsEqual(
      {
        begin_date: EMPTY_PARTIAL_DATE,
        end_date: EMPTY_PARTIAL_DATE,
        ended: false,
      },
      {
        begin_date: EMPTY_PARTIAL_DATE,
        end_date: EMPTY_PARTIAL_DATE,
        ended: true,
      },
    ),
    'Two empty periods are not equal if one is ended and the other is not',
  );

  /* eslint-disable sort-keys */
  t.ok(
    areDatePeriodsEqual(
      {
        begin_date: {year: 2000},
        end_date: EMPTY_PARTIAL_DATE,
        ended: false,
      },
      {
        begin_date: {year: 2000, month: null, day: null},
        end_date: EMPTY_PARTIAL_DATE,
        ended: false,
      },
    ),
    'Two periods are equal if the only difference is ommited vs null date parts',
  );

  t.ok(
    !areDatePeriodsEqual(
      {
        begin_date: {year: 2000, month: null, day: 12},
        end_date: EMPTY_PARTIAL_DATE,
        ended: false,
      },
      {
        begin_date: {year: 2000, month: null, day: null},
        end_date: EMPTY_PARTIAL_DATE,
        ended: false,
      },
    ),
    'Two periods are not equal if they have different date parts',
  );

  t.ok(
    !areDatePeriodsEqual(
      {
        begin_date: {year: 2000, month: 12, day: 12},
        end_date: {year: 2000, month: 12, day: 12},
        ended: false,
      },
      {
        begin_date: EMPTY_PARTIAL_DATE,
        end_date: {year: 2000, month: 12, day: 12},
        ended: false,
      },
    ),
    'Two periods are not equal if only one has a begin date',
  );

  t.ok(
    !areDatePeriodsEqual(
      {
        begin_date: {year: 2000, month: 12, day: 12},
        end_date: {year: 2000, month: 12, day: 12},
        ended: false,
      },
      {
        begin_date: {year: 2000, month: 12, day: 12},
        end_date: EMPTY_PARTIAL_DATE,
        ended: false,
      },
    ),
    'Two periods are not equal if only one has an end date',
  );

  t.ok(
    areDatePeriodsEqual(
      {
        begin_date: {year: 2000, month: 12, day: 12},
        end_date: {year: 2000, month: 12, day: 12},
        ended: false,
      },
      {
        begin_date: {year: 2000, month: 12, day: 12},
        end_date: {year: 2000, month: 12, day: 12},
        ended: false,
      },
    ),
    'Two equal periods with full dates are equal',
  );
  /* eslint-enable sort-keys */
});
