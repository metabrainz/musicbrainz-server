/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import formatDate from '../../common/utility/formatDate.js';

test('formatDate', function (t) {
  t.plan(13);

  t.equal(formatDate(null), '');
  t.equal(formatDate(undefined), '');
  t.equal(formatDate({}), '');
  t.equal(formatDate({year: 0}), '0000');
  t.equal(formatDate({year: 1999}), '1999');
  t.equal(formatDate({year: 1999, month: 1}), '1999-01');
  t.equal(formatDate({year: 1999, month: 1, day: 1}), '1999-01-01');
  t.equal(formatDate({year: 1999, day: 1}), '1999-??-01');
  t.equal(formatDate({month: 1}), '????-01');
  t.equal(formatDate({month: 1, day: 1}), '????-01-01');
  t.equal(formatDate({day: 1}), '????-??-01');
  t.equal(formatDate({year: 0, month: 1, day: 1}), '0000-01-01');
  t.equal(formatDate({year: -1, month: 1, day: 1}), '-0001-01-01');
});
