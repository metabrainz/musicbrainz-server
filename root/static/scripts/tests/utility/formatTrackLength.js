/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import formatTrackLength from '../../common/utility/formatTrackLength.js';

test('formatTrackLength', function (t) {
  t.plan(6);

  var seconds = 1000;
  var minutes = 60 * seconds;
  var hours = 60 * minutes;

  t.equal(formatTrackLength(23), '23 ms', 'formatTrackLength');
  t.equal(formatTrackLength(260586), '4:21', 'formatTrackLength');
  t.equal(formatTrackLength(23 * seconds), '0:23', 'formatTrackLength');
  t.equal(formatTrackLength(59 * minutes), '59:00', 'formatTrackLength');
  t.equal(formatTrackLength(60 * minutes), '1:00:00', 'formatTrackLength');
  t.equal(
    formatTrackLength(14 * hours + 15 * minutes + 16 * seconds),
    '14:15:16',
    'formatTrackLength',
  );
});
