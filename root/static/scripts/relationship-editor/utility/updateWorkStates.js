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
  onNotFoundDoNothing,
} from 'weight-balanced-tree/update';

import {compare} from '../../common/i18n.js';
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

export const ADD_RELATIONSHIP: 1 = 1;
export const REMOVE_RELATIONSHIP: 2 = 2;

export function compareWorkWithWorkState(
  work: WorkT,
  workState: MediumWorkStateT,
): number {
  return (
    compare(work.name, workState.work.name) ||
    (work.id - workState.work.id)
  );
}

export function* findWorkRecordings(
  writableRootState: ReleaseRelationshipEditorStateT,
  work: WorkT,
): Generator<RecordingT, void, void> {
  yield *iterateTargetEntitiesOfType<RecordingT>(
    findTargetTypeGroups(
      writableRootState.relationshipsBySource,
      work,
    ),
    'recording',
    'entity0',
  );
}

export default function updateWorkStates(
  writableRootState: ReleaseRelationshipEditorStateT,
  works: Iterable<WorkT>,
  updateWorkState: (MediumWorkStateT) => MediumWorkStateT,
): void {
  const worksByRecordingId = new Map();
  let recordingsToUpdate = null;

  for (const work of works) {
    for (
      const recording of findWorkRecordings(
        writableRootState,
        work,
      )
    ) {
      recordingsToUpdate = tree.insertIfNotExists(
        recordingsToUpdate,
        recording,
        compareRecordings,
      );

      worksByRecordingId.set(
        recording.id,
        tree.insertIfNotExists(
          worksByRecordingId.get(recording.id) ?? null,
          work,
          compareWorks,
        ),
      );
    }
  }

  updateRecordingStates(
    writableRootState,
    tree.iterate(recordingsToUpdate),
    (recordingState) => {
      let newRelatedWorks = recordingState.relatedWorks;

      const worksToUpdate =
        worksByRecordingId.get(recordingState.recording.id);

      if (worksToUpdate) {
        for (const work of tree.iterate(worksToUpdate)) {
          newRelatedWorks = tree.update(
            newRelatedWorks,
            work,
            compareWorkWithWorkState,
            updateWorkState,
            onNotFoundDoNothing,
          );
        }
      }

      if (newRelatedWorks !== recordingState.relatedWorks) {
        return {
          isSelected: recordingState.isSelected,
          recording: recordingState.recording,
          relatedWorks: newRelatedWorks,
          targetTypeGroups: recordingState.targetTypeGroups,
        };
      }
      return recordingState;
    },
  );
}
