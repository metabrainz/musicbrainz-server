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
  type InsertConflictHandler,
  onConflictThrowError,
  onNotFoundDoNothing,
  onNotFoundUseGivenValue,
} from 'weight-balanced-tree/update';

import {compare} from '../../common/i18n.js';
import {compareStrings} from '../../common/utility/compare.js';
import setMapDefault from '../../common/utility/setMapDefault.js';
import type {
  RelationshipEditorStateT,
  RelationshipLinkTypeGroupT,
  RelationshipPhraseGroupT,
  RelationshipSourceGroupT,
  RelationshipStateT,
  RelationshipTargetTypeGroupT,
  ReleaseRelationshipEditorStateT,
} from '../types.js';

import {
  cloneLinkPhraseGroup,
  cloneLinkTypeGroup,
} from './cloneState.js';
import {compareSourceWithSourceGroup} from './comparators.js';
import {
  getRelationshipsComparator,
} from './compareRelationships.js';
import getLinkPhrase from './getLinkPhrase.js';
import updateReleaseRelationships from './updateReleaseRelationships.js';

export const ADD_RELATIONSHIP: 1 = 1;
export const REMOVE_RELATIONSHIP: 2 = 2;

type RelationshipConflictHandlerT =
  InsertConflictHandler<RelationshipStateT, RelationshipStateT>;

export type RelationshipUpdateT =
  | {
      +onConflict?: RelationshipConflictHandlerT,
      +relationship: RelationshipStateT,
      +type: typeof ADD_RELATIONSHIP,
    }
  | {
      +relationship: RelationshipStateT,
      +throwIfNotExists: boolean,
      +type: typeof REMOVE_RELATIONSHIP,
    };

type RelationshipUpdatesT = {
  createLinkPhraseGroup: boolean,
  phraseGroupUpdates: LinkPhraseGroupUpdatesT,
  textPhrase: string,
  updates: Array<RelationshipUpdateT>,
};

type LinkPhraseGroupUpdatesT = {
  backward: boolean,
  createLinkTypeGroup: boolean,
  linkTypeGroupUpdates: LinkTypeGroupUpdatesT,
  linkTypeId: number,
  relationshipUpdatesMap: Map<string, RelationshipUpdatesT>,
};

type LinkTypeGroupUpdatesT = {
  createTargetTypeGroup: boolean,
  linkPhraseGroupUpdatesMap: Map<number, LinkPhraseGroupUpdatesT>,
  targetType: CentralEntityTypeT,
  targetTypeGroupUpdates: TargetTypeGroupUpdatesT,
};

type TargetTypeGroupUpdatesT = {
  createSourceGroup: boolean,
  linkTypeGroupUpdatesMap: Map<CentralEntityTypeT, LinkTypeGroupUpdatesT>,
  source: CentralEntityT,
};

function compareRelationshipUpdatesWithLinkPhraseGroup(
  relationshipUpdates: RelationshipUpdatesT,
  linkPhraseGroup: RelationshipPhraseGroupT,
): number {
  return compare(
    relationshipUpdates.textPhrase,
    linkPhraseGroup.textPhrase,
  );
}

function compareLinkPhraseGroupUpdatesWithLinkTypeGroup(
  updates: LinkPhraseGroupUpdatesT,
  group: RelationshipLinkTypeGroupT,
): number {
  return (
    (updates.linkTypeId - group.typeId) ||
    (updates.backward ? 1 : 0) - (group.backward ? 1 : 0)
  );
}

function compareLinkTypeGroupUpdatesWithTargetTypeGroup(
  linkTypeGroupUpdates: LinkTypeGroupUpdatesT,
  targetTypeGroup: RelationshipTargetTypeGroupT,
): number {
  return compareStrings(
    linkTypeGroupUpdates.targetType,
    targetTypeGroup[0],
  );
}

function compareTargetTypeGroupUpdatesWithSourceGroup(
  targetTypeGroupUpdates: TargetTypeGroupUpdatesT,
  sourceGroup: RelationshipSourceGroupT,
): number {
  return compareSourceWithSourceGroup(
    targetTypeGroupUpdates.source,
    sourceGroup,
  );
}

const createLinkPhraseGroup = (
  relationshipUpdates: RelationshipUpdatesT,
): RelationshipPhraseGroupT => {
  return updateLinkPhraseGroup({
    relationships: null,
    textPhrase: relationshipUpdates.textPhrase,
  }, relationshipUpdates);
};

const createLinkTypeGroup = (
  phraseGroupUpdates: LinkPhraseGroupUpdatesT,
) => {
  return updateLinkTypeGroup({
    backward: phraseGroupUpdates.backward,
    phraseGroups: null,
    typeId: phraseGroupUpdates.linkTypeId,
  }, phraseGroupUpdates);
};

const createTargetTypeGroup = (
  linkTypeGroupUpdates: LinkTypeGroupUpdatesT,
) => updateTargetTypeGroup([
  linkTypeGroupUpdates.targetType,
  null,
], linkTypeGroupUpdates);

const createSourceGroup = (
  targetTypeGroupUpdates: TargetTypeGroupUpdatesT,
) => updateSourceGroup([
  targetTypeGroupUpdates.source,
  null,
], targetTypeGroupUpdates);

const updateLinkPhraseGroup = (
  linkPhraseGroup: RelationshipPhraseGroupT,
  relationshipUpdates: RelationshipUpdatesT,
): RelationshipPhraseGroupT => {
  let newRelationships = linkPhraseGroup.relationships;

  const cmpRelationships = getRelationshipsComparator(
    relationshipUpdates.phraseGroupUpdates.backward,
  );

  for (const update of relationshipUpdates.updates) {
    switch (update.type) {
      case ADD_RELATIONSHIP: {
        newRelationships = tree.update(
          newRelationships,
          update.relationship,
          cmpRelationships,
          update.onConflict ?? onConflictThrowError,
          onNotFoundUseGivenValue,
        );
        break;
      }
      case REMOVE_RELATIONSHIP: {
        const {
          relationship: relationshipState,
          throwIfNotExists,
        } = update;
        const remove = throwIfNotExists
          ? tree.removeOrThrowIfNotExists
          : tree.removeIfExists;
        newRelationships = remove(
          newRelationships,
          relationshipState,
          cmpRelationships,
        );
        break;
      }
    }
  }

  if (newRelationships === linkPhraseGroup.relationships) {
    return linkPhraseGroup;
  }
  const newLinkPhraseGroup = cloneLinkPhraseGroup(linkPhraseGroup);
  newLinkPhraseGroup.relationships = newRelationships;
  return newLinkPhraseGroup;
};

const updateLinkTypeGroup = (
  linkTypeGroup: RelationshipLinkTypeGroupT,
  phraseGroupUpdates: LinkPhraseGroupUpdatesT,
): RelationshipLinkTypeGroupT => {
  let newPhraseGroups = linkTypeGroup.phraseGroups;
  for (
    const relationshipUpdates of
    phraseGroupUpdates.relationshipUpdatesMap.values()
  ) {
    newPhraseGroups = tree.update(
      newPhraseGroups,
      relationshipUpdates,
      compareRelationshipUpdatesWithLinkPhraseGroup,
      updateLinkPhraseGroup,
      relationshipUpdates.createLinkPhraseGroup
        ? createLinkPhraseGroup
        : onNotFoundDoNothing,
    );
  }
  if (newPhraseGroups === linkTypeGroup.phraseGroups) {
    return linkTypeGroup;
  }
  const newLinkTypeGroup = cloneLinkTypeGroup(linkTypeGroup);
  newLinkTypeGroup.phraseGroups = newPhraseGroups;
  return newLinkTypeGroup;
};

const updateTargetTypeGroup = (
  targetTypeGroup: RelationshipTargetTypeGroupT,
  linkTypeGroupUpdates: LinkTypeGroupUpdatesT,
): RelationshipTargetTypeGroupT => {
  const [targetType, linkTypeGroups] = targetTypeGroup;
  let newLinkTypeGroups = linkTypeGroups;
  for (
    const phraseGroupUpdates of
    linkTypeGroupUpdates.linkPhraseGroupUpdatesMap.values()
  ) {
    newLinkTypeGroups = tree.update(
      newLinkTypeGroups,
      phraseGroupUpdates,
      compareLinkPhraseGroupUpdatesWithLinkTypeGroup,
      updateLinkTypeGroup,
      phraseGroupUpdates.createLinkTypeGroup
        ? createLinkTypeGroup
        : onNotFoundDoNothing,
    );
  }
  if (newLinkTypeGroups === linkTypeGroups) {
    return targetTypeGroup;
  }
  return [targetType, newLinkTypeGroups];
};

const updateSourceGroup = (
  sourceGroup: RelationshipSourceGroupT,
  targetTypeGroupUpdates: TargetTypeGroupUpdatesT,
): RelationshipSourceGroupT => {
  const [source, targetTypeGroups] = sourceGroup;
  let newTargetTypeGroups = targetTypeGroups;
  for (
    const linkTypeGroupUpdates of
    targetTypeGroupUpdates.linkTypeGroupUpdatesMap.values()
  ) {
    newTargetTypeGroups = tree.update(
      newTargetTypeGroups,
      linkTypeGroupUpdates,
      compareLinkTypeGroupUpdatesWithTargetTypeGroup,
      updateTargetTypeGroup,
      linkTypeGroupUpdates.createTargetTypeGroup
        ? createTargetTypeGroup
        : onNotFoundDoNothing,
    );
  }
  if (newTargetTypeGroups === targetTypeGroups) {
    return sourceGroup;
  }
  return [source, newTargetTypeGroups];
};

export function getLinkTypeGroupKey(
  linkTypeId: number,
  backward: boolean,
): number {
  return (linkTypeId << 1) | (backward ? 1 : 0);
}

export default function updateRelationships(
  writableRootState:
    | {...RelationshipEditorStateT}
    | {...ReleaseRelationshipEditorStateT},
  updates: Iterable<RelationshipUpdateT>,
): void {
  const sourceGroupUpdates = new Map();
  const allUpdates =
    writableRootState.entity.entityType === 'release' ? [] : null;

  for (const update of updates) {
    const relationship = update.relationship;
    const entity0 = relationship.entity0;
    const entity1 = relationship.entity1;
    for (
      const [source, targetType, backward] of
      [
        [entity0, entity1.entityType, false],
        [entity1, entity0.entityType, true],
      ]
    ) {
      const targetTypeGroupUpdates = setMapDefault<
        string,
        TargetTypeGroupUpdatesT,
      >(
        sourceGroupUpdates,
        source.entityType + String(source.id),
        () => ({
          createSourceGroup: false,
          linkTypeGroupUpdatesMap: new Map(),
          source,
        }),
      );
      const linkTypeGroupUpdates = setMapDefault<
        CentralEntityTypeT,
        LinkTypeGroupUpdatesT,
      >(
        targetTypeGroupUpdates.linkTypeGroupUpdatesMap,
        targetType,
        () => ({
          createTargetTypeGroup: false,
          linkPhraseGroupUpdatesMap: new Map(),
          targetType,
          targetTypeGroupUpdates,
        }),
      );
      const linkTypeId = relationship.linkTypeID ?? 0;
      const phraseGroupUpdates =
        setMapDefault<number, LinkPhraseGroupUpdatesT>(
          linkTypeGroupUpdates.linkPhraseGroupUpdatesMap,
          getLinkTypeGroupKey(linkTypeId, backward),
          () => ({
            backward,
            createLinkTypeGroup: false,
            linkTypeGroupUpdates,
            linkTypeId,
            relationshipUpdatesMap: new Map(),
          }),
        );
      const textPhrase = getLinkPhrase(relationship, backward);
      const relationshipUpdates = setMapDefault<string, RelationshipUpdatesT>(
        phraseGroupUpdates.relationshipUpdatesMap,
        textPhrase,
        () => ({
          createLinkPhraseGroup: false,
          phraseGroupUpdates,
          textPhrase,
          updates: [],
        }),
      );
      relationshipUpdates.updates.push(update);
      if (update.type === ADD_RELATIONSHIP) {
        targetTypeGroupUpdates.createSourceGroup = true;
        linkTypeGroupUpdates.createTargetTypeGroup = true;
        phraseGroupUpdates.createLinkTypeGroup = true;
        relationshipUpdates.createLinkPhraseGroup = true;
      }
    }
    if (allUpdates) {
      allUpdates.push(update);
    }
  }

  for (const targetTypeGroupUpdates of sourceGroupUpdates.values()) {
    writableRootState.relationshipsBySource = tree.update(
      writableRootState.relationshipsBySource,
      targetTypeGroupUpdates,
      compareTargetTypeGroupUpdatesWithSourceGroup,
      updateSourceGroup,
      targetTypeGroupUpdates.createSourceGroup
        ? createSourceGroup
        : onNotFoundDoNothing,
    );
  }

  if (
    writableRootState.entity.entityType === 'release' &&
    allUpdates?.length
  ) {
    updateReleaseRelationships(
      // $FlowIgnore[unclear-type]
      (writableRootState: any),
      allUpdates,
    );
  }
}
