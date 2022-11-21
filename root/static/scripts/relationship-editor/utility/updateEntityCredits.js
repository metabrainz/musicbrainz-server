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
  onConflictUseGivenValue,
} from 'weight-balanced-tree/update';

import type {
  CreditChangeOptionT,
  RelationshipLinkTypeGroupT,
  RelationshipSourceGroupsT,
  RelationshipStateT,
} from '../types.js';

import {cloneRelationshipState} from './cloneState.js';
import {
  compareLinkTypeGroupKeyWithGroup,
  compareTargetTypeWithGroup,
  findTargetTypeGroups,
} from './findState.js';
import getRelationshipEditStatus from './getRelationshipEditStatus.js';
import isRelationshipBackward from './isRelationshipBackward.js';
import type {RelationshipUpdateT} from './updateRelationships.js';
import {
  ADD_RELATIONSHIP,
  REMOVE_RELATIONSHIP,
} from './updateRelationships.js';

export default function* updateEntityCredits(
  sourceGroups: RelationshipSourceGroupsT,
  sourceRelationship: RelationshipStateT,
  creditsToChange: CreditChangeOptionT,
  creditedEntity: CentralEntityT,
  creditedName: string,
): Generator<RelationshipUpdateT, void, void> {
  const targetTypeGroups = findTargetTypeGroups(
    sourceGroups,
    creditedEntity,
  );
  if (!targetTypeGroups) {
    return;
  }

  const backward =
    isRelationshipBackward(sourceRelationship, creditedEntity);
  const otherEntityType = backward
    ? sourceRelationship.entity0.entityType
    : sourceRelationship.entity1.entityType;

  const findLinkTypeGroupsForSameEntityType = () => {
    const targetTypeGroup = tree.find(
      targetTypeGroups,
      otherEntityType,
      compareTargetTypeWithGroup,
    );
    if (targetTypeGroup) {
      return targetTypeGroup[1];
    }
    return null;
  };

  const getCreditUpdatesForRelationship = function* (
    linkTypeGroup: RelationshipLinkTypeGroupT,
    relationship: RelationshipStateT,
  ): Generator<RelationshipUpdateT, void, void> {
    if (relationship.id === sourceRelationship.id) {
      return;
    }
    const creditProp = linkTypeGroup.backward
      ? 'entity1_credit'
      : 'entity0_credit';
    if (relationship[creditProp] !== creditedName) {
      const newRelationship = cloneRelationshipState(relationship);
      newRelationship[creditProp] = creditedName;
      newRelationship._status =
        getRelationshipEditStatus(newRelationship);
      yield {
        relationship,
        throwIfNotExists: true,
        type: REMOVE_RELATIONSHIP,
      };
      yield {
        onConflict: onConflictUseGivenValue,
        relationship: newRelationship,
        type: ADD_RELATIONSHIP,
      };
    }
  };

  const getCreditUpdatesForLinkTypeGroup = function* (
    linkTypeGroup: RelationshipLinkTypeGroupT,
  ): Generator<RelationshipUpdateT, void, void> {
    for (
      const linkPhraseGroup of tree.iterate(linkTypeGroup.phraseGroups)
    ) {
      for (
        const relationship of tree.iterate(linkPhraseGroup.relationships)
      ) {
        yield *getCreditUpdatesForRelationship(linkTypeGroup, relationship);
      }
    }
  };

  switch (creditsToChange) {
    case 'all': {
      for (
        const [/* targetType */, linkTypeGroups] of
        tree.iterate(targetTypeGroups)
      ) {
        for (const linkTypeGroup of tree.iterate(linkTypeGroups)) {
          yield *getCreditUpdatesForLinkTypeGroup(linkTypeGroup);
        }
      }
      break;
    }
    case 'same-entity-types': {
      const linkTypeGroups = findLinkTypeGroupsForSameEntityType();
      if (linkTypeGroups) {
        for (const linkTypeGroup of tree.iterate(linkTypeGroups)) {
          yield *getCreditUpdatesForLinkTypeGroup(linkTypeGroup);
        }
      }
      break;
    }
    case 'same-relationship-type': {
      const linkTypeGroups = findLinkTypeGroupsForSameEntityType();
      const linkTypeGroup = tree.find(
        linkTypeGroups,
        {backward, typeId: sourceRelationship.linkTypeID ?? 0},
        compareLinkTypeGroupKeyWithGroup,
      );
      if (linkTypeGroup) {
        yield *getCreditUpdatesForLinkTypeGroup(linkTypeGroup);
      }
      break;
    }
  }
}
