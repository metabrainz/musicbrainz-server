/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {
  RelationshipStateT,
} from '../types.js';

import {areLinkAttributesEqual} from './compareRelationships.js';

export default function relationshipsHaveSamePhraseGroup(
  relationship1: RelationshipStateT,
  relationship2: RelationshipStateT,
): boolean {
  return (
    relationship1.linkTypeID === relationship2.linkTypeID &&
    relationship1.entity0.id === relationship2.entity0.id &&
    relationship1.entity1.id === relationship2.entity1.id &&
    areLinkAttributesEqual(
      relationship1.attributes,
      relationship2.attributes,
    )
  );
}
