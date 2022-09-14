/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';
import {
  onNotFoundDoNothing,
} from 'weight-balanced-tree/update';

import type {
  MediumWorkStateT,
  RelationshipStateForTypesT,
  RelationshipTargetTypeGroupsT,
  ReleaseRelationshipEditorStateT,
} from '../types.js';

import {
  compareTargetTypeWithGroup,
  findTargetTypeGroups,
} from './findState.js';
import type {RelationshipUpdateT} from './updateRelationships.js';
import {compareRecordings, compareWorks} from './comparators.js';
import updateRecordingStates from './updateRecordingStates.js';
import {
  compareWorkWithWorkState,
  getWorkRecordings,
} from './updateWorkStates.js';

export const ADD_RELATIONSHIP: 1 = 1;
export const REMOVE_RELATIONSHIP: 2 = 2;

function compareWorkToWorkRecordings(
  work: WorkT,
  workRecordings: [number, tree.ImmutableTree<RecordingT> | null],
): number {
  return work.id - workRecordings[0];
}

// This should only be passed recording-work relationships.
function compareRelationshipToWorkRecordings(
  relationship: RelationshipStateForTypesT<RecordingT, WorkT>,
  workRecordings: [number, tree.ImmutableTree<RecordingT> | null],
): number {
  return compareWorkToWorkRecordings(relationship.entity1, workRecordings);
}

function compareWorkStates(
  a: MediumWorkStateT,
  b: MediumWorkStateT,
): number {
  return a.work.id - b.work.id;
}

const createWorkRecordings = (
  relationship: RelationshipStateForTypesT<RecordingT, WorkT>,
) => {
  const recording = relationship.entity0;
  return [relationship.entity1.id, tree.create(recording)];
};

function* findRecordingWorks(
  recordingTargetTypeGroups: RelationshipTargetTypeGroupsT,
): Generator<WorkT, void, void> {
  const targetTypeGroup = tree.find(
    recordingTargetTypeGroups,
    'work',
    compareTargetTypeWithGroup,
  );
  if (!targetTypeGroup) {
    return;
  }
  const [/* 'work' */, linkTypeGroups] = targetTypeGroup;
  for (const linkTypeGroup of tree.iterate(linkTypeGroups)) {
    for (
      const linkPhraseGroup of
      tree.iterate(linkTypeGroup.phraseGroups)
    ) {
      for (
        const relationship of
        tree.iterate(linkPhraseGroup.relationships)
      ) {
        /*:: invariant(relationship.entity1.entityType === 'work'); */
        yield relationship.entity1;
      }
    }
  }
}

function insertWorkRecording(
  workIdAndRecordings: [number, tree.ImmutableTree<RecordingT> | null],
  relationship: RelationshipStateForTypesT<RecordingT, WorkT>,
): [number, tree.ImmutableTree<RecordingT> | null] {
  const [workId, recordings] = workIdAndRecordings;
  const recording = relationship.entity0;
  const newRecordings = tree.insertIfNotExists(
    recordings,
    recording,
    compareRecordings,
  );
  if (newRecordings !== recordings) {
    return [workId, newRecordings];
  }
  return workIdAndRecordings;
}

function removeWorkRecording(
  workIdAndRecordings: [number, tree.ImmutableTree<RecordingT> | null],
  relationship: RelationshipStateForTypesT<RecordingT, WorkT>,
): [number, tree.ImmutableTree<RecordingT> | null] {
  const [workId, recordings] = workIdAndRecordings;
  const recording: RecordingT = relationship.entity0;
  const newRecordings = tree.removeIfExists(
    recordings,
    recording,
    compareRecordings,
  );
  if (newRecordings !== recordings) {
    return [workId, newRecordings];
  }
  return workIdAndRecordings;
}

export default function updateReleaseRelationships(
  writableRootState: ReleaseRelationshipEditorStateT,
  updates: Iterable<RelationshipUpdateT>,
): void {
  invariant(
    writableRootState.entity.entityType === 'release',
  );

  const existingWorkRecordings = writableRootState.workRecordings;
  let updatedRecordings = null;

  for (const update of updates) {
    const relationship = update.relationship;
    const entity0 = relationship.entity0;
    const entity1 = relationship.entity1;
    switch (entity0.entityType) {
      case 'recording': {
        updatedRecordings = tree.insertIfNotExists(
          updatedRecordings,
          entity0,
          compareRecordings,
        );
        if (entity1.entityType === 'work') {
          switch (update.type) {
            /* eslint-disable flowtype/no-weak-types */
            case ADD_RELATIONSHIP: {
              writableRootState.workRecordings = tree.update(
                writableRootState.workRecordings,
                (
                  // $FlowIgnore[unclear-type] - proved per above
                  (relationship: any):
                  RelationshipStateForTypesT<RecordingT, WorkT>
                ),
                compareRelationshipToWorkRecordings,
                insertWorkRecording,
                createWorkRecordings,
              );
              break;
            }
            case REMOVE_RELATIONSHIP: {
              writableRootState.workRecordings = tree.update(
                writableRootState.workRecordings,
                (
                  // $FlowIgnore[unclear-type] - proved per above
                  (relationship: any):
                  RelationshipStateForTypesT<RecordingT, WorkT>
                ),
                compareRelationshipToWorkRecordings,
                removeWorkRecording,
                onNotFoundDoNothing,
              );
              break;
            }
            /* eslint-enable flowtype/no-weak-types */
          }
        }
        break;
      }
      case 'work': {
        for (
          const recording of
          getWorkRecordings(existingWorkRecordings, entity0.id)
        ) {
          updatedRecordings = tree.insertIfNotExists(
            updatedRecordings,
            recording,
            compareRecordings,
          );
        }
        break;
      }
    }
    switch (entity1.entityType) {
      case 'recording': {
        updatedRecordings = tree.insertIfNotExists(
          updatedRecordings,
          entity1,
          compareRecordings,
        );
        break;
      }
      case 'work': {
        for (
          const recording of
          getWorkRecordings(existingWorkRecordings, entity1.id)
        ) {
          updatedRecordings = tree.insertIfNotExists(
            updatedRecordings,
            recording,
            compareRecordings,
          );
        }
        break;
      }
    }
  }

  let selectedWorksToRemove = null;

  updateRecordingStates(
    writableRootState,
    tree.iterate(updatedRecordings),
    function (recordingState) {
      let newRelatedWorks = recordingState.relatedWorks;

      const newTargetTypeGroups = findTargetTypeGroups(
        writableRootState.relationshipsBySource,
        recordingState.recording,
      );

      const recordingWorkIds = new Set();

      for (const work of findRecordingWorks(newTargetTypeGroups)) {
        recordingWorkIds.add(work.id);

        const updateWorkState = (
          workState: MediumWorkStateT,
        ): MediumWorkStateT => {
          const newWorkTargetTypeGroups = findTargetTypeGroups(
            writableRootState.relationshipsBySource,
            work,
          );
          if (newWorkTargetTypeGroups !== workState.targetTypeGroups) {
            return {
              isSelected: workState.isSelected,
              targetTypeGroups: newWorkTargetTypeGroups,
              work: workState.work,
            };
          }
          return workState;
        };

        newRelatedWorks = tree.update(
          newRelatedWorks,
          work,
          compareWorkWithWorkState,
          updateWorkState,
          () => updateWorkState({
            isSelected: false,
            targetTypeGroups: null,
            work,
          }),
        );
      }

      for (const workState of tree.iterate(newRelatedWorks)) {
        if (
          workState.targetTypeGroups === null ||
          !recordingWorkIds.has(workState.work.id)
        ) {
          newRelatedWorks = tree.remove(
            newRelatedWorks,
            workState,
            compareWorkStates,
          );
          if (
            workState.isSelected &&
            tree.find(
              writableRootState.workRecordings,
              workState.work,
              compareWorkToWorkRecordings,
            )?.[1] == null
          ) {
            selectedWorksToRemove = tree.insertIfNotExists(
              selectedWorksToRemove,
              workState.work,
              compareWorks,
            );
          }
        }
      }

      if (
        newTargetTypeGroups !== recordingState.targetTypeGroups ||
        newRelatedWorks !== recordingState.relatedWorks
      ) {
        return {
          isSelected: recordingState.isSelected,
          recording: recordingState.recording,
          relatedWorks: newRelatedWorks,
          targetTypeGroups:  newTargetTypeGroups,
        };
      }

      return recordingState;
    },
  );

  if (selectedWorksToRemove) {
    writableRootState.selectedWorks = tree.difference(
      writableRootState.selectedWorks,
      selectedWorksToRemove,
      compareWorks,
    );
  }
}
