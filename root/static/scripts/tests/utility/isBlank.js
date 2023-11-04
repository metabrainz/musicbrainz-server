/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isBlank from '../../common/utility/isBlank.js';

test('isBlank', function (t) {
  t.plan(4);

  t.ok(
    !isBlank('abcde'),
    'Letter string is not blank',
  );
  t.ok(
    !isBlank('123'),
    'Number string is not blank',
  );
  t.ok(
    isBlank(''),
    'Empty string is blank',
  );
  t.ok(
    isBlank('    '),
    'Multi-space string is blank',
  );
});
