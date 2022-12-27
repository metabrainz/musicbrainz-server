/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isUselessMediumTitle
  from '../../../edit/utility/isUselessMediumTitle.js';

test('isUselessMediumTitle', function (t) {
  t.plan(3);

  t.ok(
    !isUselessMediumTitle('The Happy Disc'),
    'A normal title is not useless',
  );

  t.ok(
    isUselessMediumTitle('DVD 42'),
    'A "format plus number" title is useless',
  );

  t.ok(
    isUselessMediumTitle('Disk1'),
    'A "format plus number" title is still useless if not space-separated',
  );
});
