/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import areDatePeriodsEqual from '../../common/utility/areDatePeriodsEqual.js';
import type {
  RelationshipStateT,
} from '../types.js';

import relationshipsHaveSamePhraseGroup
  from './relationshipsHaveSamePhraseGroup.js';

export default function relationshipsAreDuplicates(
  relationship1: RelationshipStateT,
  relationship2: RelationshipStateT,
): boolean {
  return (
    relationship1.linkOrder === relationship2.linkOrder &&
    relationshipsHaveSamePhraseGroup(relationship1, relationship2) &&
    areDatePeriodsEqual(relationship1, relationship2)
  );
}
