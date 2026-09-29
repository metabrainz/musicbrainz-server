/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isValidTime from '../../edit/utility/isValidTime.js';

test('isValidTime', function (t) {
  t.plan(8);

  t.ok(
    isValidTime(''),
    'null "time" is valid',
  );

  t.ok(
    isValidTime('11:11'),
    'HH:MM time is valid',
  );

  t.ok(
    isValidTime(' 11:11   '),
    'HH:MM time is valid if surrounded by spaces',
  );

  t.ok(
    !isValidTime('eight am'),
    'Non-number "time" is invalid',
  );

  t.ok(
    !isValidTime('1:11'),
    'Time with just H:MM is invalid',
  );

  t.ok(
    !isValidTime('11:1'),
    'Time with just HH:M is invalid',
  );

  t.ok(
    !isValidTime('26:26'),
    'Time with nonsensical HH is invalid',
  );

  t.ok(
    !isValidTime('08:75'),
    'Time with nonsensical MM is invalid',
  );
});
