/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import formatEntityTypeName from '../utility/formatEntityTypeName.js';

export default function localizeTypeNameForEntity(
  entity: CentralEntityT | CollectionT,
): string {
  const formattedEntityTypeName = formatEntityTypeName(entity.entityType);

  switch (entity.entityType) {
    case 'area':
    case 'artist':
    case 'collection':
    case 'event':
    case 'instrument':
    case 'label':
    case 'place':
    case 'series':
    case 'work':
      return nonEmpty(entity.typeName)
        ? lp_attributes(entity.typeName, entity.entityType + '_type')
        : formattedEntityTypeName;
    case 'genre':
    case 'recording':
    case 'release':
    case 'url':
      return formattedEntityTypeName;
    case 'release_group':
      return l('Release Group');
    default:
      throw new Error('Unknown entity type: ' + entity.entityType);
  }
}
