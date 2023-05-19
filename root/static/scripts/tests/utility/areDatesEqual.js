/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {EMPTY_PARTIAL_DATE} from '../../common/constants.js';
import areDatesEqual from '../../common/utility/areDatesEqual.js';

test('areDatesEqual', function (t) {
  t.plan(7);

  const date1 = {year: 2000, month: 1, day: 1};
  const date2 = {year: 2000, month: 11, day: 1};

  t.ok(areDatesEqual(null, null));
  t.ok(areDatesEqual(EMPTY_PARTIAL_DATE, null));
  t.ok(areDatesEqual(null, EMPTY_PARTIAL_DATE));
  t.ok(areDatesEqual(EMPTY_PARTIAL_DATE, EMPTY_PARTIAL_DATE));
  t.ok(areDatesEqual(date1, date1));
  t.ok(areDatesEqual(date2, date2));
  t.ok(!areDatesEqual(date1, date2));
});
