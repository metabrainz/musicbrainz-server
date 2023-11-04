/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import escapeRegExp from '../../common/utility/escapeRegExp.mjs';

test('escapeRegExp', function (t) {
  t.plan(2);

  t.equal(
    escapeRegExp('abcde'),
    'abcde',
    'No change to string without regex chars',
  );
  t.equal(
    escapeRegExp('[none]'),
    '\\[none\\]',
    'String with regex chars gets them escaped',
  );
});
