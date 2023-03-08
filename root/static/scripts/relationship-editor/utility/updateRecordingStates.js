// @flow strict

import * as tree from 'weight-balanced-tree';

import setMapDefault from '../../common/utility/setMapDefault.js';
import type {
  MediumRecordingStateT,
  MediumRecordingStateTreeT,
  ReleaseRelationshipEditorStateT,
} from '../types.js';

export function compareMediumWithMediumStateTuple(
  medium: MediumWithRecordingsT,
  mediumStateTuple: [MediumWithRecordingsT, MediumRecordingStateTreeT],
): number {
  return medium.position - mediumStateTuple[0].position;
}

export function compareRecordingIdWithRecordingState(
  recordingId: number,
  recordingState: MediumRecordingStateT,
): number {
  return recordingId - recordingState.recording.id;
}

const createSet = <T>(): Set<T> => new Set<T>();

export default function updateRecordingStates(
  writableRootState: ReleaseRelationshipEditorStateT,
  recordings: Iterable<RecordingT>,
  updateRecordingState: (MediumRecordingStateT) => MediumRecordingStateT,
): void {
  const recordingsByMedium =
    new Map<MediumWithRecordingsT, Set<RecordingT>>();

  for (const recording of recordings) {
    const mediums =
      writableRootState.mediumsByRecordingId.get(recording.id);
    if (mediums) {
      for (const medium of mediums) {
        setMapDefault(
          recordingsByMedium,
          medium,
          createSet,
        ).add(recording);
      }
    }
  }

  for (const [medium, mediumRecordings] of recordingsByMedium) {
    const updateMediumState = (
      mediumStateTuple: [MediumWithRecordingsT, MediumRecordingStateTreeT],
    ) => {
      const [mediumPosition, recordingStateTree] = mediumStateTuple;

      let newRecordingStateTree = recordingStateTree;
      for (const recording of mediumRecordings) {
        newRecordingStateTree = tree.update(
          newRecordingStateTree,
          recording.id,
          compareRecordingIdWithRecordingState,
          updateRecordingState,
          () => updateRecordingState({
            isSelected: false,
            recording,
            relatedWorks: null,
            targetTypeGroups:  null,
          }),
        );
      }
      if (newRecordingStateTree !== recordingStateTree) {
        return [mediumPosition, newRecordingStateTree];
      }
      return mediumStateTuple;
    };

    writableRootState.mediums = tree.update<
      [MediumWithRecordingsT, MediumRecordingStateTreeT],
      MediumWithRecordingsT,
    >(
      writableRootState.mediums,
      medium,
      compareMediumWithMediumStateTuple,
      updateMediumState,
      () => updateMediumState([medium, null]),
    );
  }
}
