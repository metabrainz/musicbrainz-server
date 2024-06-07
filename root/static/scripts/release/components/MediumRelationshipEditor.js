/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as tree from 'weight-balanced-tree';

import {DISPLAY_NONE_STYLE} from '../../common/constants.js';
import usePagedMediumTable from '../../common/hooks/usePagedMediumTable.js';
import {
  type LinkedEntitiesT,
  mergeLinkedEntities,
} from '../../common/linkedEntities.mjs';
import type {
  MediumRecordingStateT,
  MediumRecordingStateTreeT,
  RelationshipDialogLocationT,
} from '../../relationship-editor/types.js';
import type {
  ReleaseRelationshipEditorActionT,
} from '../../relationship-editor/types/actions.js';

import TrackRelationshipEditor from './TrackRelationshipEditor.js';

export type WritableReleasePathsT = Map<number, Set<number>>;

const getColumnCount = () => 3;

function compareRecordingWithRecordingState(
  recording: RecordingT,
  recordingState: MediumRecordingStateT,
): number {
  return recording.id - recordingState.recording.id;
}

function handleLinkedEntitiesForMedium(
  update: ?$ReadOnly<Partial<LinkedEntitiesT>>,
): void {
  if (update) {
    /*
     * We've already loaded all link (attribute) types via
     * `withLoadedTypeInfo`, and modified them to add translated and
     * normalized strings in `exportTypeInfo`.  So we'd like to avoid
     * overwriting that (modified) type data here.
     */
    const {
      /* eslint-disable no-unused-vars, camelcase */
      link_type,
      link_attribute_type,
      /* eslint-enable no-unused-vars, camelcase */
      ...nonTypeUpdates
    } = update;
    mergeLinkedEntities(nonTypeUpdates);
  }
}

component _MediumRelationshipEditor(
  dialogLocation: RelationshipDialogLocationT | null,
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  hasUnloadedTracks: boolean,
  isExpanded: boolean,
  medium: MediumWithRecordingsT,
  recordingStates: MediumRecordingStateTreeT | null,
  release: ReleaseWithMediumsT,
  releaseHasUnloadedTracks: boolean,
  tracks: $ReadOnlyArray<TrackWithRecordingT> | null,
) {
  const tableVars = usePagedMediumTable({
    dispatch,
    getColumnCount,
    handleLinkedEntities: handleLinkedEntitiesForMedium,
    hasUnloadedTracks,
    isExpanded,
    medium,
    release,
    tracks,
  });

  const allMediumRecordingsChecked = React.useMemo(() => {
    let hasRecordings = false;
    for (const recordingState of tree.iterate(recordingStates)) {
      if (!recordingState.isSelected) {
        return false;
      }
      hasRecordings = true;
    }
    return hasRecordings;
  }, [recordingStates]);

  const allMediumWorksChecked = React.useMemo(() => {
    let hasWorks = false;
    for (const recordingState of tree.iterate(recordingStates)) {
      for (const workState of tree.iterate(recordingState.relatedWorks)) {
        if (!workState.isSelected) {
          return false;
        }
        hasWorks = true;
      }
    }
    return hasWorks;
  }, [recordingStates]);

  const selectMediumRecordings = React.useCallback(() => {
    dispatch({
      isSelected: !allMediumRecordingsChecked,
      recordingStates,
      type: 'toggle-select-medium-recordings',
    });
  }, [dispatch, allMediumRecordingsChecked, recordingStates]);

  const selectMediumWorks = React.useCallback(() => {
    dispatch({
      isSelected: !allMediumWorksChecked,
      recordingStates,
      type: 'toggle-select-medium-works',
    });
  }, [dispatch, allMediumWorksChecked, recordingStates]);

  return (
    <>
      <tbody>
        <tr className="subh">
          <td />
          <td>
            <input
              checked={allMediumRecordingsChecked}
              className="medium-recordings"
              disabled={hasUnloadedTracks}
              id={'medium-recordings-checkbox-' + String(medium.id)}
              onChange={selectMediumRecordings}
              type="checkbox"
            />
            {' '}
            {tableVars.mediumHeaderLink}
          </td>
          <td>
            <input
              checked={allMediumWorksChecked}
              className="medium-works"
              disabled={hasUnloadedTracks}
              id={'medium-works-checkbox-' + String(medium.id)}
              onChange={selectMediumWorks}
              type="checkbox"
            />
          </td>
        </tr>
      </tbody>
      <tbody style={isExpanded ? null : DISPLAY_NONE_STYLE}>
        {(tableVars.loadedTrackCount /*:: && tracks */) ? (
          tracks.map((track) => {
            const recordingState = tree.find(
              recordingStates,
              track.recording,
              compareRecordingWithRecordingState,
            );
            return recordingState ? (
              <TrackRelationshipEditor
                dialogLocation={
                  (
                    dialogLocation != null &&
                    (dialogLocation.track?.id) === track.id
                  ) ? dialogLocation : null
                }
                dispatch={dispatch}
                key={track.id}
                recordingState={recordingState}
                releaseHasUnloadedTracks={releaseHasUnloadedTracks}
                showArtists={tableVars.showArtists}
                track={track}
              />
            ) : null;
          })
        ) : hasUnloadedTracks ? null : (
          <tr>
            <td colSpan="3">
              {l('The tracklist for this medium is unknown.')}
            </td>
          </tr>
        )}
        {tableVars.pagingElements}
      </tbody>
    </>
  );
}

const MediumRelationshipEditor: React.AbstractComponent<
  React.PropsOf<_MediumRelationshipEditor>
> = React.memo(_MediumRelationshipEditor);

export default MediumRelationshipEditor;
