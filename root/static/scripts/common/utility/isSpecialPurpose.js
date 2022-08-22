/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  DARTIST_ID,
  DLABEL_ID,
  NOLABEL_ID,
  NOLABEL_GID,
  VARTIST_ID,
  VARTIST_GID,
} from '../constants.js';

export default function isSpecialPurpose(
  entity: CoreEntityT | CollectionT | EditorT,
): boolean {
  if (entity.entityType === 'artist') {
    return !!(
      (entity.id === DARTIST_ID || entity.id === VARTIST_ID) ||
      (entity.gid === VARTIST_GID)
    );
  } else if (entity.entityType === 'label') {
    return !!(
      (entity.id === DLABEL_ID || entity.id === NOLABEL_ID) ||
      (entity.gid === NOLABEL_GID)
    );
  }
  return false;
}
