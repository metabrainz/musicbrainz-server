/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import sortByEntityName from '../../common/utility/sortByEntityName.js';

import {genericArea, genericArtist, genericWork} from './constants.js';

test('sortByEntityName', function (t) {
  t.plan(2);

  t.deepEqual(
    sortByEntityName([genericArea, genericArtist, genericWork]),
    [genericArtist, genericArea, genericWork],
    'Entities are correctly sorted by sort name / name',
  );

  const artistWithSmallId = {...genericArtist, id: 1};

  t.deepEqual(
    sortByEntityName([genericArtist, artistWithSmallId]),
    [artistWithSmallId, genericArtist],
    'Entities with the same sort name / name are sorted by ID',
  );
});
