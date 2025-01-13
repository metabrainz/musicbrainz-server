/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import utils from '../../release-editor/utils.js';

test('unformatTrackLength', function (t) {
  t.plan(7);

  const seconds = 1000;
  const minutes = 60 * seconds;
  const hours = 60 * minutes;

  t.equal(
    utils.unformatTrackLength('?:??'),
    null,
    'MBS-5086: unformatTrackLength(?:??) should be null',
  );
  t.equal(utils.unformatTrackLength('23 ms'), 23, 'unformatTrackLength');
  t.equal(utils.unformatTrackLength('00:23'), 23 * seconds, 'unformatTrackLength');
  t.equal(
    utils.unformatTrackLength(':57'),
    57 * seconds,
    'MBS-3352: Handle the case of ":57"',
  );
  t.equal(utils.unformatTrackLength('59:00'), 59 * minutes, 'unformatTrackLength');
  t.equal(
    utils.unformatTrackLength('01:00:00'),
    60 * minutes,
    'unformatTrackLength',
  );
  t.equal(
    utils.unformatTrackLength('14:15:16'),
    (14 * hours) + (15 * minutes) + (16 * seconds),
    'unformatTrackLength',
  );
});

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
