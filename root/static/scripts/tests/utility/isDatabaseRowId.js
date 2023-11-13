/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';

test('isDatabaseRowId', function (t) {
  t.plan(6);

  t.ok(
    !isDatabaseRowId(null),
    'null is not a valid database row id',
  );
  t.ok(
    !isDatabaseRowId('1'),
    'A number in string form is not a valid database row id',
  );
  t.ok(
    !isDatabaseRowId(-123),
    'A negative integer is not a valid database row id',
  );
  t.ok(
    !isDatabaseRowId(0),
    'Zero is not a valid database row id',
  );
  t.ok(
    !isDatabaseRowId(978020137962),
    'Too large an integer is not a valid database row id',
  );
  t.ok(
    isDatabaseRowId(123),
    'A small enough positive integer is a valid database row id',
  );
});
