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
  entity: EditableEntityT | CollectionT,
): string {
  const formattedEntityTypeName = formatEntityTypeName(entity.entityType);

  return match (entity) {
    {
      entityType:
        | 'area'
        | 'artist'
        | 'collection'
        | 'event'
        | 'instrument'
        | 'label'
        | 'place'
        | 'series'
        | 'work',
      ...
    } as entity => nonEmpty(entity.typeName)
      ? lp_attributes(entity.typeName, entity.entityType + '_type')
      : formattedEntityTypeName,
    {
      entityType: 'genre' | 'recording' | 'release' | 'url',
      ...
    } => formattedEntityTypeName,
    {entityType: 'release_group', ...} => l('Release group'),
  };
}
