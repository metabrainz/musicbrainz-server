/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import formatEndDate from '../../common/utility/formatEndDate.js';

test('formatEndDate', function (t) {
  t.plan(10);

  const a = {year: 1999};
  const b = {year: 2000};

  t.equal(
    formatEndDate({begin_date: a, end_date: a, ended: false}),
    '1999',
    'Correct format when begin date matches end date (not ended)',
  );
  t.equal(
    formatEndDate({begin_date: a, end_date: a, ended: true}),
    '1999',
    'Correct format when begin date matches end date (ended)',
  );

  t.equal(
    formatEndDate({begin_date: a, end_date: b, ended: false}),
    '2000',
    'Correct format when begin date does not match end date (not ended)',
  );
  t.equal(
    formatEndDate({begin_date: a, end_date: b, ended: true}),
    '2000',
    'Correct format when begin date does not match end date (ended)',
  );

  t.equal(
    formatEndDate({begin_date: null, end_date: b, ended: false}),
    '2000',
    'Correct format when only end date exists (not ended)',
  );
  t.equal(
    formatEndDate({begin_date: null, end_date: b, ended: true}),
    '2000',
    'Correct format when only end date exists (ended)',
  );

  t.equal(
    formatEndDate({begin_date: a, end_date: {}, ended: false}),
    null,
    'null returned when end date empty and not ended',
  );
  t.equal(
    formatEndDate({begin_date: a, end_date: {}, ended: true}),
    '[unknown]',
    'unknown returned when end date empty but ended',
  );

  t.equal(
    formatEndDate({begin_date: a, end_date: null, ended: false}),
    null,
    'null returned when end date missing and not ended',
  );
  t.equal(
    formatEndDate({begin_date: a, end_date: null, ended: true}),
    '[unknown]',
    'unknown returned when end date missing but ended',
  );
});
