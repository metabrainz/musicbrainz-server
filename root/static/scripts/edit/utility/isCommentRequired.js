/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {unaccent} from '../../common/utility/strings.js';

const normalizeName = (name: string) => unaccent(name).toUpperCase();

// TODO: port isPlaceCommentRequired when converting the place form
export default function isCommentRequired(
  name: string,
  duplicates: $ReadOnlyArray<EditableEntityT>,
): boolean {
  const normalizedName = normalizeName(name);

  return duplicates.some(function (duplicate) {
    return normalizedName === normalizeName(duplicate.name);
  });
}
