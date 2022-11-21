/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';

import {compare} from '../../common/i18n.js';
import {compareStrings} from '../../common/utility/compare.js';
import type {
  RelationshipLinkTypeGroupKeyT,
  RelationshipLinkTypeGroupsT,
  RelationshipLinkTypeGroupT,
  RelationshipPhraseGroupT,
  RelationshipSourceGroupsT,
  RelationshipStateT,
  RelationshipTargetTypeGroupsT,
  RelationshipTargetTypeGroupT,
} from '../types.js';

import {compareSourceWithSourceGroup} from './comparators.js';
import {getRelationshipsComparator} from './compareRelationships.js';
import getLinkPhrase from './getLinkPhrase.js';
import isRelationshipBackward from './isRelationshipBackward.js';

export function compareTargetTypeWithGroup(
  targetType: CentralEntityTypeT,
  targetTypeGroup: RelationshipTargetTypeGroupT,
): number {
  return compareStrings(targetType, targetTypeGroup[0]);
}

export function compareLinkTypeGroupKeyWithGroup(
  key: RelationshipLinkTypeGroupKeyT,
  group: RelationshipLinkTypeGroupT,
): number {
  return (
    (key.typeId - group.typeId) ||
    (key.backward ? 1 : 0) - (group.backward ? 1 : 0)
  );
}

export function compareLinkPhraseWithGroup(
  linkPhrase: string,
  linkPhraseGroup: RelationshipPhraseGroupT,
): number {
  return compare(linkPhrase, linkPhraseGroup.textPhrase);
}

export function findTargetTypeGroups(
  sourceGroups: RelationshipSourceGroupsT,
  source: CentralEntityT,
): RelationshipTargetTypeGroupsT | null {
  const sourceGroup = tree.find(
    sourceGroups,
    source,
    compareSourceWithSourceGroup,
    null,
  );
  return sourceGroup ? sourceGroup[1] : null;
}

export function findLinkTypeGroups(
  targetTypeGroups: RelationshipTargetTypeGroupsT,
  source: CentralEntityT,
  targetType: CentralEntityTypeT,
): RelationshipLinkTypeGroupsT | null {
  const targetTypeGroup = tree.find(
    targetTypeGroups,
    targetType,
    compareTargetTypeWithGroup,
    null,
  );
  return targetTypeGroup ? targetTypeGroup[1] : null;
}

export function findLinkTypeGroup(
  linkTypeGroups: RelationshipLinkTypeGroupsT,
  linkTypeId: number,
  backward: boolean,
): RelationshipLinkTypeGroupT | null {
  return tree.find(
    linkTypeGroups,
    {backward, typeId: linkTypeId},
    compareLinkTypeGroupKeyWithGroup,
    null,
  );
}

export function findLinkPhraseGroup(
  linkTypeGroup: RelationshipLinkTypeGroupT,
  relationshipState: RelationshipStateT,
): RelationshipPhraseGroupT | null {
  return tree.find(
    linkTypeGroup.phraseGroups,
    getLinkPhrase(relationshipState, linkTypeGroup.backward),
    compareLinkPhraseWithGroup,
    null,
  );
}

export function findLinkPhraseGroupInTargetTypeGroups(
  targetTypeGroups: RelationshipTargetTypeGroupsT,
  relationshipState: RelationshipStateT,
  source: CentralEntityT,
): RelationshipPhraseGroupT | null {
  const backward = isRelationshipBackward(
    relationshipState,
    source,
  );
  const targetType = backward
    ? relationshipState.entity0.entityType
    : relationshipState.entity1.entityType;
  const linkTypeGroup = findLinkTypeGroup(
    findLinkTypeGroups(
      targetTypeGroups,
      source,
      targetType,
    ),
    relationshipState.linkTypeID ?? 0,
    backward,
  );
  if (!linkTypeGroup) {
    return null;
  }
  return findLinkPhraseGroup(
    linkTypeGroup,
    relationshipState,
  );
}

export function findExistingRelationship(
  targetTypeGroups: RelationshipTargetTypeGroupsT | null,
  relationshipState: RelationshipStateT,
  source: CentralEntityT,
): RelationshipStateT | null {
  const linkPhraseGroup = findLinkPhraseGroupInTargetTypeGroups(
    targetTypeGroups,
    relationshipState,
    source,
  );
  if (!linkPhraseGroup) {
    return null;
  }
  return tree.find(
    linkPhraseGroup.relationships,
    relationshipState,
    getRelationshipsComparator(isRelationshipBackward(
      relationshipState,
      source,
    )),
    null,
  );
}

export function* iterateRelationshipsInTargetTypeGroup(
  targetTypeGroup: RelationshipTargetTypeGroupT,
): Generator<RelationshipStateT, void, void> {
  const [/* targetType */, linkTypeGroups] = targetTypeGroup;
  for (const linkTypeGroup of tree.iterate(linkTypeGroups)) {
    for (
      const linkPhraseGroup of tree.iterate(linkTypeGroup.phraseGroups)
    ) {
      yield *tree.iterate(linkPhraseGroup.relationships);
    }
  }
}

export function* iterateRelationshipsInTargetTypeGroups(
  targetTypeGroups: RelationshipTargetTypeGroupsT,
): Generator<RelationshipStateT, void, void> {
  for (const targetTypeGroup of tree.iterate(targetTypeGroups)) {
    yield *iterateRelationshipsInTargetTypeGroup(
      targetTypeGroup,
    );
  }
}

export function* iterateTargetEntitiesOfType<T: CentralEntityT>(
  targetTypeGroups: RelationshipTargetTypeGroupsT | null,
  targetType: T['entityType'],
  targetProperty: 'entity0' | 'entity1',
): Generator<T, void, void> {
  const targetTypeGroup = tree.find(
    targetTypeGroups,
    targetType,
    compareTargetTypeWithGroup,
  );
  if (!targetTypeGroup) {
    return;
  }
  for (
    const relationship of
    iterateRelationshipsInTargetTypeGroup(targetTypeGroup)
  ) {
    const target = relationship[targetProperty];
    invariant(target.entityType === targetType);
    // $FlowIgnore[unclear-type]
    yield (target: any);
  }
}
