/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import formatBarcode from '../../common/utility/formatBarcode.js';

test('formatBarcode', function (t) {
  t.plan(3);

  t.equal(
    formatBarcode(null),
    '',
    'null (no info about barcode) is formatted as the empty string',
  );
  t.equal(
    formatBarcode(''),
    '[none]',
    'Empty string (known to have no barcode) is formatted as [none]',
  );
  t.equal(
    formatBarcode('978020137962'),
    '978020137962',
    'Same string is returned when non-empty string passed',
  );
});
