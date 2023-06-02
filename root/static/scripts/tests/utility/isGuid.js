/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isGuid from '../../common/utility/isGuid.js';

test('isGuid', function (t) {
  t.plan(4);

  t.ok(
    !isGuid('lol-nope'),
    'Too short string is not a GUID',
  );

  t.ok(
    !isGuid('lol-no-way-of-course-not-nope-not-at-all-obviously'),
    'Too long string is not a GUID',
  );

  t.ok(
    !isGuid('89ad4ac3-39f7-470e-963a-56509c54637n'),
    '36-character string with non hex character is not a GUID',
  );

  t.ok(
    isGuid('89ad4ac3-39f7-470e-963a-56509c546377'),
    'Valid MBID is a GUID',
  );
});
