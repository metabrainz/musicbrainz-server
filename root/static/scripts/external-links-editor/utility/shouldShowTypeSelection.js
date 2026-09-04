/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {
  LinkRelationshipStateT,
  LinkStateT,
} from '../types.js';

import doesUrlMatchOnlyOnePossibleType
  from './doesUrlMatchOnlyOnePossibleType.js';

export default function shouldShowTypeSelection(
  sourceType: RelatableEntityTypeT,
  link: LinkStateT,
  relationship: LinkRelationshipStateT,
): boolean {
  /*
   * Allow changing the type if there are any errors, duplicates,
   * or if the URL does not match only a single type.
   */
  return !(
    link.error == null &&
    relationship.error == null &&
    link.duplicateOf == null &&
    doesUrlMatchOnlyOnePossibleType(sourceType, link)
  );
}
