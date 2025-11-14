/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isValidIsni from '../../edit/utility/isValidIsni.js';

test('isValidIsni', function (t) {
  t.plan(9);

  t.ok(
    !isValidIsni(''),
    'An empty string is not a valid ISNI',
  );
  t.ok(
    isValidIsni('0000000000000000'),
    'An all-zeroes ISNI is valid',
  );
  t.ok(
    isValidIsni('0000000106750994'),
    'A digits-only ISNI is valid',
  );
  t.ok(
    isValidIsni('000000010675099X'),
    'An ISNI ending with X is valid',
  );
  t.ok(
    !isValidIsni('000000010675099Y'),
    'An ISNI ending with Y is not valid',
  );
  t.ok(
    !isValidIsni('000X000106750990'),
    'An ISNI having X elsewhere than the ending is not valid',
  );
  t.ok(
    !isValidIsni('14107338'),
    'A too-short ISNI is not valid',
  );
  t.ok(
    isValidIsni('   0.000000.10675099-X  '),
    'A valid ISNI is still valid if it contains periods, hyphens or whitespace',
  );
  t.ok(
    !isValidIsni('   ..-..-.   '),
    'A bunch of periods, hyphens and whitespace is not a valid ISNI in itself',
  );
});
