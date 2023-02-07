/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  REL_STATUS_ADD,
  REL_STATUS_EDIT,
  REL_STATUS_NOOP,
  REL_STATUS_REMOVE,
} from '../constants.js';
import type {RelationshipStateT} from '../types.js';

export default function getRelationshipStatusName(
  relationship: RelationshipStateT,
): string {
  switch (relationship._status) {
    case REL_STATUS_ADD:
      return 'add';
    case REL_STATUS_EDIT:
      return 'edit';
    case REL_STATUS_NOOP:
      return 'noop';
    case REL_STATUS_REMOVE:
      return 'remove';
  }
  return '';
}
