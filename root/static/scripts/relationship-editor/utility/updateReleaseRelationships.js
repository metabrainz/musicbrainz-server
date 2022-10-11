/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';

import type {
  MediumWorkStateT,
  ReleaseRelationshipEditorStateT,
} from '../types.js';

import {compareRecordings, compareWorks} from './comparators.js';
import {
  findTargetTypeGroups,
  iterateTargetEntitiesOfType,
} from './findState.js';
import updateRecordingStates from './updateRecordingStates.js';
import type {RelationshipUpdateT} from './updateRelationships.js';
import {
  compareWorkWithWorkState,
  findWorkRecordings,
} from './updateWorkStates.js';

export const ADD_RELATIONSHIP: 1 = 1;
export const REMOVE_RELATIONSHIP: 2 = 2;

function compareWorkStates(
  a: MediumWorkStateT,
  b: MediumWorkStateT,
): number {
  return a.work.id - b.work.id;
}

function workHasNoRecordings(
  writableRootState: ReleaseRelationshipEditorStateT,
  work: WorkT,
): boolean {
  return findWorkRecordings(writableRootState, work).next().done;
}

export default function updateReleaseRelationships(
  writableRootState: ReleaseRelationshipEditorStateT,
  updates: Iterable<RelationshipUpdateT>,
): void {
  invariant(
    writableRootState.entity.entityType === 'release',
  );

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
        break;
      }
      case 'work': {
        for (
          const recording of findWorkRecordings(writableRootState, entity0)
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
          const recording of findWorkRecordings(writableRootState, entity1)
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

      for (
        const work of iterateTargetEntitiesOfType<WorkT>(
          newTargetTypeGroups,
          'work',
          'entity1',
        )
      ) {
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
            workHasNoRecordings(writableRootState, workState.work)
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
