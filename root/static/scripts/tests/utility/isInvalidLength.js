/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isInvalidLength from '../../edit/utility/isInvalidLength.js';

test('isInvalidLength', function (t) {
  t.plan(12);

  t.ok(
    !isInvalidLength(''),
    'No length is not invalid',
  );
  t.ok(
    !isInvalidLength('?:??'),
    '?:?? is empty/unknown, but not invalid',
  );
  t.ok(
    !isInvalidLength('23 ms'),
    'Miliseconds length is valid',
  );
  t.ok(
    !isInvalidLength('00:23'),
    'MM:SS is valid',
  );
  t.ok(
    !isInvalidLength('00:57'),
    ':SS is valid',
  );
  t.ok(
    !isInvalidLength('85:23'),
    'MM:SS is valid with more than 60 minutes',
  );
  t.ok(
    !isInvalidLength('1:00:57'),
    'HH:MM:SS is valid',
  );
  t.ok(
    isInvalidLength('foo'),
    'A random string is not valid',
  );
  t.ok(
    isInvalidLength('10:80'),
    'MM:SS is not valid with more than 60 seconds',
  );
  t.ok(
    isInvalidLength(':80'),
    ':SS is not valid with more than 60 seconds',
  );
  t.ok(
    isInvalidLength('1:75:10'),
    'HH:MM:SS is not valid with more than 60 minutes',
  );
  t.ok(
    isInvalidLength('1000:35:10'),
    'Times longer than the max number of ms we can store are invalid',
  );
});
