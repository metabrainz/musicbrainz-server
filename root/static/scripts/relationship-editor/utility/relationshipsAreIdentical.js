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

import relationshipsAreDuplicates
  from './relationshipsAreDuplicates.js';

export default function relationshipsAreIdentical(
  relationship1: RelationshipStateT,
  relationship2: RelationshipStateT,
): boolean {
  return (
    relationship1.entity0_credit === relationship2.entity0_credit &&
    relationship1.entity1_credit === relationship2.entity1_credit &&
    relationshipsAreDuplicates(relationship1, relationship2)
  );
}
