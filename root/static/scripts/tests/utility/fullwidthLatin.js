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
    'undefined has no fullwidth Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(null),
    false,
    'null has no fullwidth Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(''),
    false,
    'empty has no fullwidth Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin('　ｆｅａｔ．　'),
    true,
    'fully fullwidth Latin has fullwidth Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(' ｆｅａｔ. '),
    true,
    'fullwidth Latin letters are fullwidth Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin('　feat.　'),
    true,
    'ideographic space is fullwidth Latin',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(' feat． '),
    true,
    'fullwidth full stop is fullwidth Latin',
  );
});

test('fromFullwidthLatin', function (t) {
  t.plan(5);

  t.equal(
    fullwidthLatin.fromFullwidthLatin(undefined),
    '',
    'undefined (fromFullwidthLatin) empty',
  );

  t.equal(
    fullwidthLatin.fromFullwidthLatin(null),
    '',
    'null (fromFullwidthLatin) empty',
  );

  t.equal(
    fullwidthLatin.fromFullwidthLatin(''),
    '',
    'empty (fromFullwidthLatin) empty',
  );

  t.equal(
    fullwidthLatin.fromFullwidthLatin('　ｆｅａｔ．　'),
    ' feat. ',
    'fully converted fromFullwidthLatin',
  );

  t.equal(
    fullwidthLatin.fromFullwidthLatin(' ｆｅａｔ. '),
    ' feat. ',
    'partly converted fromFullwidthLatin',
  );
});

test('toFullwidthLatin', function (t) {
  t.plan(5);

  t.equal(
    fullwidthLatin.toFullwidthLatin(undefined),
    '',
    'undefined (toFullwidthLatin) empty',
  );

  t.equal(
    fullwidthLatin.toFullwidthLatin(null),
    '',
    'null (toFullwidthLatin) empty',
  );

  t.equal(
    fullwidthLatin.toFullwidthLatin(''),
    '',
    'empty (toFullwidthLatin) empty',
  );

  t.equal(
    fullwidthLatin.toFullwidthLatin('　feat．　'),
    '　ｆｅａｔ．　',
    'partly converted toFullwidthLatin',
  );

  t.equal(
    fullwidthLatin.toFullwidthLatin(' feat. '),
    '　ｆｅａｔ．　',
    'fully converted toFullwidthLatin',
  );
});
