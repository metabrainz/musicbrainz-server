/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isAreaSmallerThanCountry
  from '../../../edit/utility/isAreaSmallerThanCountry.js';

test('isAreaSmallerThanCountry', function (t) {
  t.plan(6);

  t.ok(
    !isAreaSmallerThanCountry({typeID: 1}),
    'A country is not smaller than a country',
  );

  t.ok(
    isAreaSmallerThanCountry({typeID: 3}),
    'A city is smaller than a country',
  );

  t.ok(
    isAreaSmallerThanCountry({typeID: 2}),
    'A subdivision is smaller than a country',
  );

  t.ok(
    !isAreaSmallerThanCountry({typeID: null}),
    'An area without a type is not flagged',
  );

  t.ok(
    !isAreaSmallerThanCountry({name: 'Berlin'}),
    'An area whose type is not known, such as one typed in, is not flagged',
  );

  t.ok(
    !isAreaSmallerThanCountry(null),
    'No area is not flagged',
  );
});
