/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import * as age from '../../../../utility/age.js';

type WritableDatePeriodRoleT = {
  begin_date: PartialDateT | null,
  end_date: PartialDateT | null,
  ended: boolean,
};

/* eslint-disable sort-keys */

test('age', function (t) {
  t.plan(11);

  t.deepEqual(age.age({
    begin_date: {year: 1976, month: 7, day: 23},
    end_date: {year: 1976, month: 7, day: 24},
    ended: true,
  }), [0, 0, 1], 'age is 1 day');

  t.deepEqual(age.age({
    begin_date: {year: 1976, month: 7, day: 23},
    end_date: {year: 1976, month: 8, day: 1},
    ended: true,
  }), [0, 0, 9], 'age is 9 days');

  t.deepEqual(age.age({
    begin_date: {year: 1976, month: 7, day: 23},
    end_date: {year: 1976, month: 11, day: 1},
    ended: true,
  }), [0, 3, 9], 'age is 3 months');

  t.deepEqual(age.age({
    begin_date: {year: 1553, month: 7, day: 23},
    end_date: {year: 1976, month: 11, day: 1},
    ended: true,
  }), [423, 3, 9], 'age is 423 years');

  t.deepEqual(age.age({
    begin_date: {year: 1553, month: 7, day: 23},
    end_date: {year: 2140, month: 11, day: 1},
    ended: true,
  }), [587, 3, 9], 'age is 587 years');

  t.deepEqual(age.age({
    begin_date: {year: 2008, month: 2, day: 29},
    end_date: {year: 2009, month: 2, day: 1},
    ended: true,
  }), [0, 11, 3], 'age is 11 months');

  t.deepEqual(age.age({
    begin_date: {
      year: (new Date()).getFullYear() - 24,
      month: null,
      day: null,
    },
    end_date: null,
    ended: false,
  })?.[0], 24, 'age is 24 years');

  t.deepEqual(age.age({
    begin_date: {year: 2010, month: null, day: null},
    end_date: {year: 2012, month: null, day: null},
    ended: true,
  }), [2, 0, 0], 'age with partial dates is 2 years');

  t.deepEqual(age.age({
    begin_date: {year: 2010, month: null, day: null},
    end_date: {year: 2012, month: 12, day: null},
    ended: true,
  }), [2, 11, 0], 'age with partial dates is 2 years, 11 months');

  t.deepEqual(age.age({
    begin_date: {year: 2010, month: 12, day: null},
    end_date: {year: 2012, month: 1, day: null},
    ended: true,
  }), [1, 1, 0], 'age with partial dates is 1 year, 1 month');

  t.deepEqual(age.age({
    begin_date: {year: 2010, month: 12, day: 31},
    end_date: {year: 2012, month: 1, day: null},
    ended: true,
  }), [1, 0, 1], 'age with partial dates is 1 year, 1 day');
});

test('hasAge', function (t) {
  t.plan(4);

  const entity: WritableDatePeriodRoleT = {
    begin_date: {year: 1970, month: 1, day: 1},
    end_date: {year: null, month: 1, day: 1},
    ended: true,
  };
  t.ok(!age.hasAge(entity), 'no age for ended artist without end year');

  // testing hasAge with negative years
  entity.begin_date = {year: 551, month: 9, day: 28};
  entity.end_date = {year: 479, month: 4, day: 11};
  t.ok(!age.hasAge(entity), 'no age for artists with negative years');

  // testing hasAge with future begin dates
  entity.begin_date = {year: 9998, month: 9, day: 28};
  entity.end_date = {year: 9999, month: 4, day: 11};
  t.ok(!age.hasAge(entity), 'no age for artists with future begin dates');

  // testing hasAge when the begin date is more specific than the end date
  entity.begin_date = {year: 1987, month: 3, day: 7};
  entity.end_date = {year: 1987, month: null, day: null};
  t.ok(
    !age.hasAge(entity),
    'no age for artists with more specific begin than end dates',
  );
});
