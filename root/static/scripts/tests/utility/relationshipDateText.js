/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import relationshipDateText
  from '../../common/utility/relationshipDateText.js';

test('relationshipDateText', function (t) {
  t.plan(9);

  t.equal(
    relationshipDateText({
      begin_date: {day: 2, month: 1, year: 2021},
      end_date: {day: 2, month: 1, year: 2021},
      ended: true,
    }),
    'on 2021-01-02',
    'Same date (day precision)',
  );

  t.equal(
    relationshipDateText({
      begin_date: {month: 1, year: 2021},
      end_date: {month: 1, year: 2021},
      ended: true,
    }),
    'in 2021-01',
    'Same date (month precision)',
  );

  t.equal(
    relationshipDateText({
      begin_date: {day: 1, month: 1, year: 2021},
      end_date: {day: 2, month: 1, year: 2021},
      ended: true,
    }),
    'from 2021-01-01 until 2021-01-02',
    'Different date',
  );

  t.equal(
    relationshipDateText({
      begin_date: {day: 1, month: 1, year: 2021},
      end_date: null,
      ended: false,
    }),
    'from 2021-01-01 to present',
    'Begin date, no end date, not ended',
  );

  t.equal(
    relationshipDateText({
      begin_date: {day: 1, month: 1, year: 2021},
      end_date: null,
      ended: true,
    }),
    'from 2021-01-01 to ????',
    'Begin date, no end date, but marked as ended',
  );

  t.equal(
    relationshipDateText({
      begin_date: null,
      end_date: {day: 2, month: 1, year: 2021},
      ended: true,
    }),
    'until 2021-01-02',
    'End date, no begin date',
  );

  t.equal(
    relationshipDateText({
      begin_date: null,
      end_date: null,
      ended: true,
    }),
    '(ended)',
    'No dates, but marked as ended',
  );

  t.equal(
    relationshipDateText({
      begin_date: null,
      end_date: null,
      ended: true,
    }, false),
    'ended',
    'No dates, but marked as ended - we ask not to bracket "ended"',
  );

  t.equal(
    relationshipDateText({
      begin_date: null,
      end_date: null,
      ended: false,
    }),
    '',
    'No date info at all',
  );
});
