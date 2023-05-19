/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import formatDatePeriod from '../../common/utility/formatDatePeriod.js';

test('formatDatePeriod', function (t) {
  t.plan(8);

  var a = {year: 1999};
  var b = {year: 2000};

  t.equal(
    formatDatePeriod({begin_date: a, end_date: a, ended: false}),
    '1999',
  );
  t.equal(
    formatDatePeriod({begin_date: a, end_date: a, ended: true}),
    '1999',
  );

  t.equal(
    formatDatePeriod({begin_date: a, end_date: b, ended: false}),
    '1999 \u2013 2000',
  );
  t.equal(
    formatDatePeriod({begin_date: a, end_date: b, ended: true}),
    '1999 \u2013 2000',
  );

  t.equal(
    formatDatePeriod({begin_date: {}, end_date: b, ended: false}),
    '\u2013 2000',
  );
  t.equal(
    formatDatePeriod({begin_date: {}, end_date: b, ended: true}),
    '\u2013 2000',
  );

  t.equal(
    formatDatePeriod({begin_date: a, end_date: {}, ended: false}),
    '1999 \u2013',
  );
  t.equal(
    formatDatePeriod({begin_date: a, end_date: {}, ended: true}),
    '1999 \u2013 ????',
  );
});
