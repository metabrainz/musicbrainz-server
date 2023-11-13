/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import clean from '../../common/utility/clean.js';

test('clean', function (t) {
  t.plan(5);

  t.equal(
    clean(null),
    '',
    'Cleaning null returns the empty string',
  );

  t.equal(
    clean(undefined),
    '',
    'Cleaning undefined returns the empty string',
  );

  t.equal(
    clean('This sentence has no extra spaces'),
    'This sentence has no extra spaces',
    'Cleaning already clean string returns it unchanged',
  );

  t.equal(
    clean('This sentence has a trailing space '),
    'This sentence has a trailing space',
    'Cleaning string with trailing space removes that space',
  );

  t.equal(
    clean('This  sentence     has    too  many        spaces'),
    'This sentence has too many spaces',
    'Cleaning string with multiple consecutive spaces collapses them',
  );
});
