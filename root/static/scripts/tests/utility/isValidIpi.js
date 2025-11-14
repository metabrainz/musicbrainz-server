/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isValidIpi from '../../edit/utility/isValidIpi.js';

test('isValidIpi', function (t) {
  t.plan(9);

  t.ok(
    !isValidIpi(''),
    'An empty string is not a valid IPI',
  );
  t.ok(
    !isValidIpi('00000000000'),
    'An all-zeroes IPI is not valid',
  );
  t.ok(
    !isValidIpi('0000000'),
    'An unpadded all-zeroes IPI is still not valid',
  );
  t.ok(
    isValidIpi('00014107338'),
    'A zero-padded eight-digit IPI is valid',
  );
  t.ok(
    isValidIpi('14107338'),
    'An unpadded eight-digit IPI is still valid',
  );
  t.ok(
    !isValidIpi('123'),
    'An unpadded IPI shorter than 5 digits is not valid (likely an error)',
  );
  t.ok(
    isValidIpi('00000000123'),
    'A zero-padded IPI with less than 5 non-zero digits is valid (too weird an error to make)',
  );
  t.ok(
    isValidIpi('   1.2345.67  '),
    'A valid IPI is still valid if it contains periods or whitespace',
  );
  t.ok(
    !isValidIpi('   .....   '),
    'A bunch of periods and whitespace is not a valid IPI in itself',
  );
});
