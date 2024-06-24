/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import groupRelationships from '../../common/utility/groupRelationships.js';
import {
  exportLinkAttributeTypeInfo,
  exportLinkTypeInfo,
} from '../../relationship-editor/utility/exportTypeInfo.js';
import {linkAttributeTypes, linkTypes} from '../typeInfo.js';

exportLinkTypeInfo(linkTypes);
exportLinkAttributeTypeInfo(linkAttributeTypes);

test('MBS-13588: Phrase groups are highlighted for pending edits regardless of relationship order', function (t) {
  t.plan(2);

  const target: ArtistT = {
    area: null,
    begin_area: null,
    begin_area_id: null,
    begin_date: null,
    comment: '',
    editsPending: false,
    end_area: null,
    end_area_id: null,
    end_date: null,
    ended: false,
    entityType: 'artist',
    gender: null,
    gender_id: null,
    gid: 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
    id: 8,
    ipi_codes: [],
    isni_codes: [],
    last_updated: '2024-05-16T15:48:43Z',
    name: 'Test Alias',
    sort_name: 'Kate Bush',
    typeID: null,
  };

  const attributes = [
    {
      type: {
        gid: '63021302-86cd-4aee-80df-2270d54f4978',
      },
      typeID: 229,
      typeName: 'guitar',
    },
  ];

  const relationship1: RelationshipT = {
    attributes,
    backward: true,
    begin_date: null,
    editsPending: false,
    end_date: null,
    ended: false,
    entity0_credit: '',
    entity0_id: 8,
    entity1_credit: '',
    entity1_id: 2,
    id: 1,
    linkOrder: 0,
    linkTypeID: 148,
    source_id: 2,
    source_type: 'recording',
    target,
    target_type: 'artist',
    verbosePhrase: 'performed <a href="/instrument/63021302-86cd-4aee-80df-2270d54f4978">guitar</a> on',
  };

  const relationship2: RelationshipT = {
    attributes,
    backward: true,
    begin_date: null,
    editsPending: true,
    end_date: null,
    ended: false,
    entity0_credit: '',
    entity0_id: 9,
    entity1_credit: '',
    entity1_id: 2,
    id: 2,
    linkOrder: 0,
    linkTypeID: 148,
    source_id: 2,
    source_type: 'recording',
    target,
    target_type: 'artist',
    verbosePhrase: 'performed <a href="/instrument/63021302-86cd-4aee-80df-2270d54f4978">guitar</a> on',
  };

  const groups1 = groupRelationships(
    [relationship1, relationship2],
  );
  const groups2 = groupRelationships(
    [relationship2, relationship1],
  );
  t.ok(
    groups1[0].relationshipPhraseGroups[0].linkTypeInfo[0].editsPending,
    'editsPending is true for order relationship1, relationship2',
  );
  t.ok(
    groups2[0].relationshipPhraseGroups[0].linkTypeInfo[0].editsPending,
    'editsPending is true for order relationship2, relationship1',
  );
});
