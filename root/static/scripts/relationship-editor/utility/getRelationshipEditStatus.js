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
} from '../constants.js';
import type {RelationshipStateT} from '../types.js';

import relationshipsAreIdentical from './relationshipsAreIdentical.js';

export default function getRelationshipEditStatus(
  relationshipState: RelationshipStateT,
): RelationshipEditStatusT {
  if (!relationshipState._original) {
    return REL_STATUS_ADD;
  }
  return relationshipsAreIdentical(
    relationshipState._original,
    relationshipState,
  ) ? REL_STATUS_NOOP : REL_STATUS_EDIT;
}
