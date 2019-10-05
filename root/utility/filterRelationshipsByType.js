/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function filterRelationshipsByType(
  relationships: ?$ReadOnlyArray<RelationshipT>,
  types: ?$ReadOnlyArray<CoreEntityTypeT>,
): $ReadOnlyArray<RelationshipT> {
  const result: Array<RelationshipT> = [];

  if (!relationships) {
    return result;
  }

  for (let i = 0; i < relationships.length; i++) {
    const relationship = relationships[i];
    const targetType = relationship.target.entityType;

    if (types && types.includes(targetType)) {
      result.push(relationship);
    }
  }

  return result;
}
