/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isObjectEmpty from '../../common/utility/isObjectEmpty.js';

test('isObjectEmpty', function (t) {
  t.plan(3);

  t.ok(
    !isObjectEmpty({key: 'value'}),
    'Object with a key-value pair is not empty',
  );
  t.ok(
    !isObjectEmpty({key: null}),
    'Object with a key with null value is not empty',
  );
  t.ok(
    isObjectEmpty({}),
    'Object with no keys is empty',
  );
});
