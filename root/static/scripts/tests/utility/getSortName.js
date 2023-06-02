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

test('getSortName', function (t) {
  t.plan(2);

  const artist: ArtistT = {
    area: null,
    begin_area: null,
    begin_date: null,
    comment: '',
    end_area: null,
    end_date: null,
    ended: false,
    entityType: 'artist',
    gender: null,
    gid: 'daa7b69c-bb32-486a-8b88-260327938568',
    id: 123,
    ipi_codes: [],
    isni_codes: [],
    last_updated: null,
    name: 'SomeName',
    sort_name: 'NameSome',
    typeID: null,
  };

  t.equal(
    getSortName(artist),
    'NameSome',
    'Sort name is returned if the entity has it',
  );

  const work: WorkT = {
    artists: [],
    attributes: [],
    comment: '',
    entityType: 'work',
    gid: 'daa7b69c-bb32-486a-8b88-260327938568',
    id: 123,
    iswcs: [],
    languages: [],
    last_updated: null,
    name: 'SomeName',
    typeID: null,
    writers: [],
  };

  t.equal(
    getSortName(work),
    'SomeName',
    'Name is returned for entity type without sort name',
  );
});
