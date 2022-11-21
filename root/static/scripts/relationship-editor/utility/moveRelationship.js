/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';
import {
  onConflictThrowError,
} from 'weight-balanced-tree/update';

import {
  isLinkTypeOrderableByUser,
} from '../../common/utility/isLinkTypeDirectionOrderable.js';
import type {
  RelationshipEditorStateT,
  RelationshipStateT,
  ReleaseRelationshipEditorStateT,
} from '../types.js';

import {
  cloneRelationshipState,
} from './cloneState.js';
import {
  getRelationshipsComparator,
} from './compareRelationships.js';
import {
  findLinkPhraseGroupInTargetTypeGroups,
  findTargetTypeGroups,
} from './findState.js';
import getRelationshipEditStatus from './getRelationshipEditStatus.js';
import isRelationshipBackward from './isRelationshipBackward.js';
import updateRelationships, {
  ADD_RELATIONSHIP,
  REMOVE_RELATIONSHIP,
} from './updateRelationships.js';

export default function moveRelationship(
  writableRootState:
    | {...RelationshipEditorStateT}
    | {...ReleaseRelationshipEditorStateT},
  relationship: RelationshipStateT,
  source: CentralEntityT,
  moveForward: boolean,
): void {
  const targetTypeGroups = findTargetTypeGroups(
    writableRootState.relationshipsBySource,
    source,
  );

  const linkPhraseGroup = findLinkPhraseGroupInTargetTypeGroups(
    targetTypeGroups,
    relationship,
    source,
  );

  invariant(
    linkPhraseGroup &&
    isLinkTypeOrderableByUser(
      relationship.linkTypeID,
      source,
      isRelationshipBackward(relationship, source),
    ),
  );

  const relationships = linkPhraseGroup.relationships;
  const findAdjacent = moveForward ? tree.findNext : tree.findPrev;
  const adjacentRelationship = findAdjacent(
    relationships,
    relationship,
    getRelationshipsComparator(isRelationshipBackward(
      relationship,
      source,
    )),
  );

  const nextLogicalLinkOrder =
    Math.max(0, relationship.linkOrder + (moveForward ? 1 : -1));
  const updates = [];

  const relationshipWithNewLinkOrder = (
    relationship: RelationshipStateT,
    newLinkOrder: number,
  ) => {
    const newRelationship = cloneRelationshipState(relationship);
    newRelationship.linkOrder = newLinkOrder;
    newRelationship._status = getRelationshipEditStatus(
      newRelationship,
    );
    return newRelationship;
  };

  if (
    adjacentRelationship &&
    adjacentRelationship.linkOrder === nextLogicalLinkOrder
  ) {
    updates.push(
      {
        relationship,
        throwIfNotExists: true,
        type: REMOVE_RELATIONSHIP,
      },
      {
        relationship: adjacentRelationship,
        throwIfNotExists: true,
        type: REMOVE_RELATIONSHIP,
      },
      {
        onConflict: onConflictThrowError,
        relationship: relationshipWithNewLinkOrder(
          relationship,
          adjacentRelationship.linkOrder,
        ),
        type: ADD_RELATIONSHIP,
      },
      {
        onConflict: onConflictThrowError,
        relationship: relationshipWithNewLinkOrder(
          adjacentRelationship,
          relationship.linkOrder,
        ),
        type: ADD_RELATIONSHIP,
      },
    );
  } else {
    updates.push(
      {
        relationship,
        throwIfNotExists: true,
        type: REMOVE_RELATIONSHIP,
      },
      {
        onConflict: onConflictThrowError,
        relationship: relationshipWithNewLinkOrder(
          relationship,
          nextLogicalLinkOrder,
        ),
        type: ADD_RELATIONSHIP,
      },
    );
  }

  updateRelationships(writableRootState, updates);
}
