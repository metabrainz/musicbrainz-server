/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import unformatTrackLength from '../../common/utility/unformatTrackLength.js';

test('unformatTrackLength', function (t) {
  t.plan(7);

  const seconds = 1000;
  const minutes = 60 * seconds;
  const hours = 60 * minutes;

  t.equal(
    unformatTrackLength('?:??'),
    null,
    'MBS-5086: unformatTrackLength(?:??) should be null',
  );
  t.equal(unformatTrackLength('23 ms'), 23, 'Handle ms entry');
  t.equal(unformatTrackLength('00:23'), 23 * seconds, 'Handle seconds only');
  t.equal(
    unformatTrackLength(':57'),
    57 * seconds,
    'MBS-3352: Handle the case of ":57"',
  );
  t.equal(unformatTrackLength('59:00'), 59 * minutes, 'Handle minutes only');
  t.equal(
    unformatTrackLength('01:00:00'),
    60 * minutes,
    'Handle 1h',
  );
  t.equal(
    unformatTrackLength('14:15:16'),
    (14 * hours) + (15 * minutes) + (16 * seconds),
    'Handle HH:MM:SS',
  );
});
