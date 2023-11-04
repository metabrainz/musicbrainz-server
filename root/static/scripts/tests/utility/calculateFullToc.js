/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import calculateFullToc from '../../common/utility/calculateFullToc.js';

test('calculateFullToc', function (t) {
  t.plan(3);

  const cdToc = {
    leadout_offset: 135210,
    track_count: 6,
    track_offset: [150, 3525, 24576, 54919, 82241, 110939],
  };

  t.equal(
    calculateFullToc(cdToc),
    '1 6 135210 150 3525 24576 54919 82241 110939',
    'The right CD TOC string is put together from the CD TOC object',
  );

  const cdToc2 = {
    leadout_offset: 135210,
    track_count: 6,
    track_offset: null,
  };

  t.throws(
    () => calculateFullToc(cdToc2),
    {message: 'Expected a defined track offset'},
    'Right error is raised when track offset is missing',
  );

  const cdToc3 = {
    leadout_offset: null,
    track_count: 6,
    track_offset: [150, 3525, 24576, 54919, 82241, 110939],
  };

  t.throws(
    () => calculateFullToc(cdToc3),
    {message: 'Expected a defined leadout offset'},
    'Right error is raised when leadout offset is missing',
  );
});
