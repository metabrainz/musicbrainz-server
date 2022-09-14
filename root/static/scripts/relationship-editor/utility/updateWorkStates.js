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
  ReleaseRelationshipEditorStateT,
  WorkRecordingsT,
} from '../types.js';

import {compareRecordings, compareWorks} from './comparators.js';
import updateRecordingStates from './updateRecordingStates.js';

export const ADD_RELATIONSHIP: 1 = 1;
export const REMOVE_RELATIONSHIP: 2 = 2;

export function compareWorkWithWorkState(
  work: WorkT,
  workState: MediumWorkStateT,
): number {
  return work.id - workState.work.id;
}

function compareWorkIdWithWorkRecordings(
  workId: number,
  workRecordings: [number, tree.ImmutableTree<RecordingT> | null],
): number {
  return workId - workRecordings[0];
}

export function* getWorkRecordings(
  workRecordings: WorkRecordingsT,
  workId: number,
): Generator<RecordingT, void, void> {
  const recordingsTuple = tree.find(
    workRecordings,
    workId,
    compareWorkIdWithWorkRecordings,
  );
  if (recordingsTuple) {
    const recordings = recordingsTuple[1];
    if (recordings) {
      for (const recording of tree.iterate(recordings)) {
        yield recording;
      }
    }
  }
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
      const recording of getWorkRecordings(
        writableRootState.workRecordings,
        work.id,
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
