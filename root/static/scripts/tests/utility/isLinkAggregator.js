/*
 * @flow strict
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isLinkAggregator from '../../edit/utility/isLinkAggregator.js';

test('isLinkAggregator', function (t) {
  t.plan(14);

  t.ok(isLinkAggregator('https://amu.se/share/artist/kazi-kamrul-hasan'));
  t.ok(isLinkAggregator('http://smarturl.it/fallingasleep'));
  t.ok(isLinkAggregator('https://lnk.bio/mnbw'));
  t.ok(isLinkAggregator('http://example.amu.se'));
  t.ok(isLinkAggregator('http://example.smarturl.it'));
  t.ok(isLinkAggregator('http://example.lnk.bio'));

  // Allowed host-only aggregators
  t.ok(!isLinkAggregator('https://example.bruit.app/'));
  t.ok(!isLinkAggregator('https://example.distrokid.com'));
  t.ok(!isLinkAggregator('https://example.trac.co'));

  t.ok(isLinkAggregator('https://bruit.app/abc'));
  t.ok(isLinkAggregator('https://example.distrokid.com/abc'));
  t.ok(isLinkAggregator('https://example.trac.co/abc'));

  // MBS-12566
  t.ok(!isLinkAggregator('https://smarturlit.example'));
  t.ok(!isLinkAggregator('https://smarturlait.example'));
});
