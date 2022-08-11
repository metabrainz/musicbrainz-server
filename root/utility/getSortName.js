/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ENTITIES from '../../entities.json';

/*
 * Returns the sort name for entities that have them, or falls back to
 * the name otherwise.
 */

export default function getSortName(entity: CoreEntityT): string {
  const hasSortName = ENTITIES[entity.entityType].sort_name;
  return hasSortName /*:: && entity.sort_name */
    ? entity.sort_name
    : entity.name;
}
