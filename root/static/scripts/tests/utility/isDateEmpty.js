/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isDateEmpty from '../../common/utility/isDateEmpty.js';

test('isDateEmpty', function (t) {
  t.plan(8);

  t.ok(
    isDateEmpty(null),
    'null "date" is empty',
  );

  t.ok(
    isDateEmpty(undefined),
    'undefined "date" is empty',
  );

  t.ok(
    isDateEmpty({}),
    'Empty object "date" is empty',
  );

  t.ok(
    isDateEmpty({day: null, month: null, year: null}),
    'Date with all null parts is empty',
  );

  t.ok(
    isDateEmpty({year: null}),
    'Date with one null part and rest undefined is empty',
  );

  t.ok(
    !isDateEmpty({year: 2020}),
    'Date with one non-null part and rest undefined is not empty',
  );

  t.ok(
    !isDateEmpty({day: null, month: null, year: 2020}),
    'Date with one non-null part and rest null is not empty',
  );

  t.ok(
    !isDateEmpty({day: 1, month: 2, year: 2020}),
    'Date with all parts non-null is not empty',
  );
});
