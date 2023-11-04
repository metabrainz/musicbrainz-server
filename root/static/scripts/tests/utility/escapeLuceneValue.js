/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import escapeLuceneValue from '../../common/utility/escapeLuceneValue.js';

test('escapeLuceneValue', function (t) {
  t.plan(2);

  t.equal(
    escapeLuceneValue('abcde'),
    'abcde',
    'No change to string without regex chars',
  );
  t.equal(
    escapeLuceneValue('[none?!]'),
    '\\[none\\?\\!\\]',
    'String with regex chars gets them escaped',
  );
});
