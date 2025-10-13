/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  type RelationshipEditStatusT,
  REL_STATUS_ADD,
  REL_STATUS_EDIT,
  REL_STATUS_NOOP,
  REL_STATUS_REMOVE,
} from '../constants.js';
import type {RelationshipStateT} from '../types.js';

export function getStatusName(
  status: RelationshipEditStatusT,
): string {
  return match (status) {
    REL_STATUS_ADD => 'add',
    REL_STATUS_EDIT => 'edit',
    REL_STATUS_NOOP => 'noop',
    REL_STATUS_REMOVE => 'remove',
  };
}

export default function getRelationshipStatusName(
  relationship: RelationshipStateT,
): string {
  return getStatusName(relationship._status);
}
