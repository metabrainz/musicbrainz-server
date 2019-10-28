/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import linkedEntities from '../static/scripts/common/linkedEntities';

import filterRelationshipsByType from './filterRelationshipsByType';

const generalTypesList = ['recording', 'release', 'release_group', 'work'];
const recordingOnlyTypesList = ['recording'];

const pickAppearancesTypes = (entityType) => {
  switch (entityType) {
    case 'artist':
    case 'label':
    case 'place': {
      return generalTypesList;
    }
    case 'work': {
      return recordingOnlyTypesList;
    }
    default: return [];
  }
};

export default function generateRelationshipAppearancesList(
  entity: CoreEntityT,
): {[string]: $ReadOnlyArray<RelationshipT>, ...} {
  const result = {};
  const appearancesTypes = pickAppearancesTypes(entity.entityType);
  const relationships =
    filterRelationshipsByType(entity.relationships, appearancesTypes);

  if (!relationships) {
    return result;
  }

  for (let i = 0; i < relationships.length; i++) {
    const relationship = relationships[i];
    const linkPhrase = linkedEntities.link_type[relationship.linkTypeID].name;

    result[linkPhrase] = result[linkPhrase] || [];
    result[linkPhrase].push(relationship);
  }

  return result;
}
