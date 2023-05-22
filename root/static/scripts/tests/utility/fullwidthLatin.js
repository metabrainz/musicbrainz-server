/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import * as fullwidthLatin from '../../edit/utility/fullwidthLatin.js';

test('hasFullwidthLatin', function (t) {
  t.plan(7);

  t.equal(
    fullwidthLatin.hasFullwidthLatin(undefined),
    false,
    'undefined contains no full width Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(null),
    false,
    'null contains no full width Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(''),
    false,
    'the empty string contains no full width Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin('　ｆｅａｔ．　'),
    true,
    'entirely full width Latin string contains full width Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(' ｆｅａｔ. '),
    true,
    'Latin string with full width letters only contains full width Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin('　feat.　'),
    true,
    'Latin string with ideographic space contains full width Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(' feat． '),
    true,
    'Latin string with one full width full stop contains full width Latin',
  );
});

test('fromFullwidthLatin', function (t) {
  t.plan(5);

  t.equal(
    fullwidthLatin.fromFullwidthLatin(undefined),
    '',
    'fromFullwidthLatin returns the empty string from undefined',
  );

  t.equal(
    fullwidthLatin.fromFullwidthLatin(null),
    '',
    'fromFullwidthLatin returns the empty string from null',
  );

  t.equal(
    fullwidthLatin.fromFullwidthLatin(''),
    '',
    'fromFullwidthLatin returns the empty string from the empty string',
  );

  t.equal(
    fullwidthLatin.fromFullwidthLatin('　ｆｅａｔ．　'),
    ' feat. ',
    'entirely full width text is converted to entirely non-full width text',
  );

  t.equal(
    fullwidthLatin.fromFullwidthLatin(' ｆｅａｔ. '),
    ' feat. ',
    'partly full width text is converted to entirely non-full width text',
  );
});

test('toFullwidthLatin', function (t) {
  t.plan(5);

  t.equal(
    fullwidthLatin.toFullwidthLatin(undefined),
    '',
    'toFullwidthLatin returns the empty string from undefined',
  );

  t.equal(
    fullwidthLatin.toFullwidthLatin(null),
    '',
    'toFullwidthLatin returns the empty string from null',
  );

  t.equal(
    fullwidthLatin.toFullwidthLatin(''),
    '',
    'toFullwidthLatin returns the empty string from the empty string',
  );

  t.equal(
    fullwidthLatin.toFullwidthLatin('　feat．　'),
    '　ｆｅａｔ．　',
    'partly full width text is converted to entirely full width text',
  );

  t.equal(
    fullwidthLatin.toFullwidthLatin(' feat. '),
    '　ｆｅａｔ．　',
    'entirely non-full width text is converted to entirely full width text',
  );
});
