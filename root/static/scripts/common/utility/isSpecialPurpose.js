/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  DLABEL_ID,
  NOLABEL_GID,
  NOLABEL_ID,
  SPECIAL_ARTIST_GIDS,
  SPECIAL_ARTIST_IDS,
} from '../constants.js';

export default function isSpecialPurpose(
  entity: {
    +entityType: string,
    +gid?: string,
    +id: number,
    ...
  },
): boolean {
  if (entity.entityType === 'artist') {
    return SPECIAL_ARTIST_IDS.includes(entity.id) ||
      SPECIAL_ARTIST_GIDS.includes(entity.gid);
  } else if (entity.entityType === 'label') {
    return entity.id === DLABEL_ID ||
      entity.id === NOLABEL_ID ||
      entity.gid === NOLABEL_GID;
  }
  return false;
}
