/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import formatUserDate from '../../../../utility/formatUserDate.js';

test('formatUserDate', function (t) {
  t.plan(1);

  t.equal(
    formatUserDate(
      {
        stash: {current_language: 'en'},
        user: {
          preferences: {
            datetime_format: '%Y-%m-%d %H:%M %Z',
            timezone: 'Africa/Cairo',
          },
        },
      },
      '2021-05-12T22:05:05.640Z',
    ),
    '2021-05-13 00:05 GMT+2',
    '%H ranges from 00-23',
  );
});
