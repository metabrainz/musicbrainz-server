/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {compare} from '../i18n';

function compareEntities(a: CoreEntityT, b: CoreEntityT): number {
  return compare(a.name, b.name) || (a.id - b.id);
}

export default function sortByEntityName(
  entities: $ReadOnlyArray<CoreEntityT>,
): $ReadOnlyArray<CoreEntityT> {
  return entities.slice(0).sort(compareEntities);
}
