/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {compare} from '../i18n.js';

import getSortName from './getSortName.js';

function compareEntities(a: CoreEntityT, b: CoreEntityT): number {
  return compare(getSortName(a), getSortName(b)) || (a.id - b.id);
}

export default function sortByEntityName<T: CoreEntityT>(
  entities: $ReadOnlyArray<T>,
): $ReadOnlyArray<T> {
  return entities.slice(0).sort(compareEntities);
}
