/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import utils from '../../release-editor/utils.js';

test('calculateDiscID', function (t) {
  t.plan(2);

  t.equal(
    utils.calculateDiscID('1 2 157005 150 77950'),
    'borOdvYNUkc2SF8GrzPepad0H3M-',
  );

  t.equal(
    utils.calculateDiscID(
      '1 9 252000 150 31615 67600 87137 108242 127110 142910 166340 231445',
    ),
    'gtWBI_F_fQFSSRt8nVChAVFaT_A-',
  );
});

test('similarTrackNames', function (t) {
  t.plan(1);

  t.ok(
    utils.similarTrackNames(
      'Brooklyn Rumba (feat. Dr. Israel & Marc Ribot)',
      'Brooklyn Rumba',
    ),
    'name with feat. artist is similar to name without feat. artist',
  );
});
