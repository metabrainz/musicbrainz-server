/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isValidIsrc from '../../edit/utility/isValidIsrc.js';

test('isValidIsrc', function (t) {
  t.plan(8);

  t.ok(
    !isValidIsrc(''),
    'An empty string is not a valid ISRC',
  );
  t.ok(
    isValidIsrc('GB5KW2103369'),
    'An ISRC with no separators is valid',
  );
  t.ok(
    isValidIsrc('GB 5KW 22 02504'),
    'A space-separated ISRC is valid',
  );
  t.ok(
    isValidIsrc('GB-ARL-04-01372'),
    'A hyphen-separated ISRC is valid',
  );
  t.ok(
    isValidIsrc('  GB5KW2103369 '),
    'An ISRC surrounded by spaces is valid',
  );
  t.ok(
    !isValidIsrc('thisisnotanisrc'),
    'A random string is not valid',
  );
  t.ok(
    !isValidIsrc('5318008'),
    'A random number is not valid',
  );
  t.ok(
    !isValidIsrc('GB5KW210336985'),
    'An ISRC with extra digits is not valid',
  );
});
