/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {RelationshipStateT} from '../types.js';

export default function isRelationshipBackward(
  relationship: RelationshipStateT,
  source: RelatableEntityT,
): boolean {
  const {entity0, entity1} = relationship;
  const backward = (
    entity1.entityType === source.entityType &&
    entity1.id === source.id
  );
  invariant(
    (
      entity0.entityType === source.entityType &&
      entity0.id === source.id
    ) !== backward,
    'Invalid relationship source',
  );
  invariant(
    entity0.entityType <= entity1.entityType,
    'Invalid entity order: ' +
    `${entity0.entityType} > ${entity1.entityType}`,
  );
  return backward;
}
