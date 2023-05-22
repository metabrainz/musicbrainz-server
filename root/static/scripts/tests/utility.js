/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isShortenedUrl from '../edit/utility/isShortenedUrl.js';

test('isShortenedUrl', function (t) {
  t.plan(17);

  t.ok(isShortenedUrl('https://su.pr/example'));
  t.ok(isShortenedUrl('https://t.co/example'));
  t.ok(isShortenedUrl('https://bit.ly/example'));
  t.ok(isShortenedUrl('http://example.su.pr'));
  t.ok(isShortenedUrl('http://example.t.co'));
  t.ok(isShortenedUrl('http://example.bit.ly'));

  // Allowed host-only shorteners
  t.ok(!isShortenedUrl('https://example.bruit.app/'));
  t.ok(!isShortenedUrl('https://example.distrokid.com'));
  t.ok(!isShortenedUrl('https://example.trac.co'));

  t.ok(isShortenedUrl('https://bruit.app/abc'));
  t.ok(isShortenedUrl('https://example.distrokid.com/abc'));
  t.ok(isShortenedUrl('https://example.trac.co/abc'));

  // MBS-12566
  t.ok(!isShortenedUrl('https://surprisechef.bandcamp.com' +
                       '/album/velodrome-b-w-springs-theme'));
  t.ok(!isShortenedUrl('https://t.co.example'));
  t.ok(!isShortenedUrl('https://taco.example'));
  t.ok(!isShortenedUrl('https://bit.ly.example'));
  t.ok(!isShortenedUrl('https://bitaly.example'));
});
