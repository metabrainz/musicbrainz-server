/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import getSortName from '../../common/utility/getSortName.js';

import {genericArtist, genericWork} from './constants.js';

test('getSortName', function (t) {
  t.plan(2);

  t.equal(
    getSortName(genericArtist),
    'Artist, Test',
    'Sort name is returned if the entity has it',
  );

  t.equal(
    getSortName(genericWork),
    'Test Work',
    'Name is returned for entity type without sort name',
  );
});
