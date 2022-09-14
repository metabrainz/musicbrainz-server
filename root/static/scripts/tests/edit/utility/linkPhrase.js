/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import linkedEntities, {
  mergeLinkedEntities,
} from '../../../common/linkedEntities.mjs';
import {
  getPhraseAndExtraAttributesText,
} from '../../../edit/utility/linkPhrase.js';
import {
  exportLinkAttributeTypeInfo,
  exportLinkTypeInfo,
} from '../../../relationship-editor/utility/exportTypeInfo.js';
import {linkAttributeTypes, linkTypes} from '../../typeInfo.js';

exportLinkTypeInfo(linkTypes);
exportLinkAttributeTypeInfo(linkAttributeTypes);

test('required attributes are left with forGrouping', function (t) {
  t.plan(1);

  /*
   * Note: There are currently no orderable link types with any
   * required attributes, so we're adding a fake one here.
   */
  mergeLinkedEntities({
    link_type: {
      [10000]: {
        attributes: {
          [10000]: {
            max: null,
            min: 1,
          },
        },
        cardinality0: 0,
        cardinality1: 0,
        child_order: 1,
        deprecated: false,
        description: 'description',
        entityType: 'link_type',
        gid: '43faf40a-281f-404f-a338-8efbe7775060',
        has_dates: true,
        id: 10000,
        link_phrase: 'supporting {instrument} for',
        long_link_phrase: 'does/did {instrument} support for',
        name: 'instrumental supporting musician',
        orderable_direction: 1,
        parent_id: null,
        reverse_link_phrase: 'supporting {instrument} by',
        type0: 'artist',
        type1: 'artist',
      },
    },

    link_attribute_type: {
      [10000]: {
        child_order: 0,
        creditable: true,
        description: 'description',
        entityType: 'link_attribute_type',
        free_text: false,
        gid: 'd8c8f4d4-c7e9-4db9-93c3-319c722ddd98',
        id: 10000,
        name: 'instrument',
        parent_id: null,
        root_gid: 'd8c8f4d4-c7e9-4db9-93c3-319c722ddd98',
        root_id: 10000,
      },
      [10001]: {
        child_order: 0,
        creditable: true,
        description: 'description',
        entityType: 'link_attribute_type',
        free_text: false,
        gid: '706e788b-cf8d-4294-a118-b078e09905c9',
        id: 10001,
        name: 'guitar',
        parent_id: 10000,
        root_gid: 'd8c8f4d4-c7e9-4db9-93c3-319c722ddd98',
        root_id: 10000,
      },
    },
  });

  const result = getPhraseAndExtraAttributesText(
    linkedEntities.link_type[10000],
    [
      {
        type: {
          gid: '706e788b-cf8d-4294-a118-b078e09905c9',
        },
        typeID: 10001,
        typeName: 'guitar',
      },
    ],
    'link_phrase',
    true, /* forGrouping */
  );

  t.deepEqual(result, ['supporting guitar for', []]);
});


test('non-required attributes are stripped with forGrouping', function (t) {
  t.plan(2);

  const instrumentalAttribute = {
    type: {
      gid: 'c031ed4f-c9bb-4394-8cf5-e8ce4db512ae',
    },
    typeID: 580,
    typeName: 'instrumental',
  };

  /*
   * "recording of" has an orderable direction of 1, so the instrumental
   * attribute should be stripped from link_phrase but not
   * reverse_link_phrase.
   */

  let result = getPhraseAndExtraAttributesText(
    linkedEntities.link_type[278],
    [instrumentalAttribute],
    'link_phrase',
    true, /* forGrouping */
  );
  t.deepEqual(result, ['recording of', [instrumentalAttribute]]);

  result = getPhraseAndExtraAttributesText(
    linkedEntities.link_type[278],
    [instrumentalAttribute],
    'reverse_link_phrase',
    true, /* forGrouping */
  );
  t.deepEqual(result, ['instrumental recordings', []]);
});

test('MBS-6129: Interpolating link phrases containing %', function (t) {
  t.plan(2);

  /*
   * Note: The current vocal link type uses `{vocal} {vocal:|vocals}`
   * instead, which is why we're defining our own.
   */
  mergeLinkedEntities({
    link_type: {
      [10001]: {
        attributes: {
          [3]: {
            max: null,
            min: 0,
          },
        },
        cardinality0: 0,
        cardinality1: 0,
        child_order: 0,
        deprecated: false,
        description: '',
        entityType: 'link_type',
        gid: 'd4013546-019d-4c59-8206-e0a6dec5d03a',
        has_dates: true,
        id: 10001,
        link_phrase: '{vocal:%|vocals}',
        long_link_phrase: '{vocal:%|vocals}',
        name: 'vocal',
        orderable_direction: 0,
        parent_id: null,
        reverse_link_phrase: '{vocal:%|vocals}',
        type0: 'artist',
        type1: 'artist',
      },
    },
  });

  const leadVocalsAttribute = {
    type: {
      gid: '8e2a3255-87c2-4809-a174-98cb3704f1a5',
    },
    typeID: 4,
    typeName: 'lead vocals',
  };

  let result = getPhraseAndExtraAttributesText(
    linkedEntities.link_type[10001],
    [],
    'link_phrase',
    true, /* forGrouping */
  );
  t.deepEqual(result, ['vocals', []]);

  result = getPhraseAndExtraAttributesText(
    linkedEntities.link_type[10001],
    [leadVocalsAttribute],
    'link_phrase',
    true, /* forGrouping */
  );
  t.deepEqual(result, ['lead vocals', []]);
});
