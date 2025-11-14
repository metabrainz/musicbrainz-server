/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isValidLabelCode from '../../edit/utility/isValidLabelCode.js';

test('isValidLabelCode', function (t) {
  t.plan(8);

  t.ok(
    !isValidLabelCode(''),
    'An empty string is not a valid label code',
  );
  t.ok(
    !isValidLabelCode('0'),
    'Zero (string) is not a valid label code',
  );
  t.ok(
    !isValidLabelCode(0),
    'Zero (number) is not a valid label code',
  );
  t.ok(
    isValidLabelCode('123456'),
    'A six-digit label code is valid (string)',
  );
  t.ok(
    isValidLabelCode(123456),
    'A six-digit label code is valid (number)',
  );
  t.ok(
    !isValidLabelCode('1234567'),
    'A seven-digit label code is not valid (string)',
  );
  t.ok(
    !isValidLabelCode(1234567),
    'A seven-digit label code is not valid (number)',
  );
  t.ok(
    isValidLabelCode('   123456   '),
    'A valid label code string is still valid if surrounded by whitespace',
  );
});
