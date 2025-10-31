/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as tree from 'weight-balanced-tree';

import ButtonPopover from '../../common/components/ButtonPopover.js';
import DescriptiveLink from '../../common/components/DescriptiveLink.js';
import EntityLink from '../../common/components/EntityLink.js';
import {RECORDING_OF_LINK_TYPE_ID} from '../../common/constants.js';
import {createWorkObject} from '../../common/entity2.js';
import {bracketedText} from '../../common/utility/bracketed.js';
import coerceToError from '../../common/utility/coerceToError.js';
import formatTrackLength from '../../common/utility/formatTrackLength.js';
import NewWorkLink
  from '../../relationship-editor/components/NewWorkLink.js';
import RelationshipTargetTypeGroups
  from '../../relationship-editor/components/RelationshipTargetTypeGroups.js';
import {REL_STATUS_REMOVE} from '../../relationship-editor/constants.js';
import {
  useAddRelationshipDialogContent,
} from '../../relationship-editor/hooks/useRelationshipDialogContent.js';
import type {
  MediumRecordingStateT,
  MediumWorkStateT,
  MediumWorkStateTreeT,
  RelationshipDialogLocationT,
} from '../../relationship-editor/types.js';
import type {
  ReleaseRelationshipEditorActionT,
} from '../../relationship-editor/types/actions.js';
import {
  compareTargetTypeWithGroup,
  iterateRelationshipsInTargetTypeGroup,
  iterateRelationshipsInTargetTypeGroups,
} from '../../relationship-editor/utility/findState.js';

import EditWorkDialog from './EditWorkDialog.js';

component _TrackLink(
  showArtists: boolean,
  track: TrackWithRecordingT,
) {
  let trackLink: Expand2ReactOutput;
  if (showArtists) {
    trackLink = (
      <DescriptiveLink
        className="wrap-anywhere"
        content={track.name}
        customArtistCredit={track.artistCredit}
        entity={track.recording}
        showDisambiguation={false}
        target="_blank"
      />
    );
  } else {
    trackLink = (
      <EntityLink
        className="wrap-anywhere"
        content={track.name}
        entity={track.recording}
        showDisambiguation={false}
        target="_blank"
      />
    );
  }
  return (
    <>
      {trackLink}
      {' '}
      {bracketedText(formatTrackLength(track.length))}
    </>
  );
}

const TrackLink = React.memo(_TrackLink);

component _WorkLink(work: WorkT) {
  return (
    <EntityLink
      allowNew
      className="wrap-anywhere"
      entity={work}
      target="_blank"
    />
  );
}

const WorkLink = React.memo(_WorkLink);

component RelatedWorkHeading(
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  isRemoved: boolean,
  isSelected: boolean,
  removeWorkButton: React.MixedElement,
  work: WorkT,
) {
  const selectWork = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      isSelected: event.currentTarget.checked,
      type: 'toggle-select-work',
      work,
    });
  }, [dispatch, work]);

  let workLink: React.MixedElement = <WorkLink work={work} />;
  if (isRemoved) {
    workLink = (
      <span className="rel-remove">
        {workLink}
      </span>
    );
  }

  return (
    <h3>
      <input
        checked={isSelected}
        className="work"
        onChange={selectWork}
        type="checkbox"
      />
      {' '}
      {removeWorkButton}
      {' '}
      {workLink}
    </h3>
  );
}

component NewRelatedWorkHeading(
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  isSelected: boolean,
  removeWorkButton: React.MixedElement,
  work: WorkT,
) {
  const selectWork = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      isSelected: event.currentTarget.checked,
      type: 'toggle-select-work',
      work,
    });
  }, [dispatch, work]);

  const [
    isEditWorkDialogOpen,
    setEditWorkDialogOpen,
  ] = React.useState(false);

  const buildEditWorkPopoverContent = React.useCallback((
    closeAndReturnFocus: () => void,
    initialFocusRef: {-current: HTMLElement | null},
  ) => (
    <EditWorkDialog
      closeDialog={closeAndReturnFocus}
      initialFocusRef={initialFocusRef}
      rootDispatch={dispatch}
      work={work}
    />
  ), [dispatch, work]);

  return (
    <h3 id={'new-work-' + String(work.id)}>
      <input
        checked={isSelected}
        className="work"
        onChange={selectWork}
        type="checkbox"
      />
      {' '}
      {removeWorkButton}
      <ButtonPopover
        buildChildren={buildEditWorkPopoverContent}
        buttonContent={null}
        buttonProps={{
          className: 'icon edit-item',
        }}
        className="work-dialog"
        closeOnOutsideClick={false}
        id="edit-work-dialog"
        isOpen={isEditWorkDialogOpen}
        toggle={setEditWorkDialogOpen}
      />
      {' '}
      <NewWorkLink work={work} />
    </h3>
  );
}

const filterRecordings = (
  targetType: RelatableEntityTypeT,
) => targetType !== 'recording';

component _RelatedWorkRelationshipEditor(
  dialogLocation: RelationshipDialogLocationT | null,
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  relatedWork: MediumWorkStateT,
  releaseHasUnloadedTracks: boolean,
  track: TrackWithRecordingT,
) {
  const work = relatedWork.work;
  const isNewWork = work._fromBatchCreateWorksDialog === true;
  const hasLoadedRelationships = work.relationships != null;
  const [loadingError, setLoadingError] = React.useState<Error | null>(null);

  React.useEffect(function () {
    if (isNewWork || hasLoadedRelationships) {
      return;
    }
    fetch('/ws/js/entity/' + work.gid + '?inc=rels')
      .then((resp) => {
        if (!resp.ok) {
          return null;
        }
        return resp.json();
      })
      // $FlowFixMe[unclear-type]
      .then((data: any) => {
        if (data.relationships?.length) {
          dispatch({
            relationships: data.relationships,
            type: 'load-work-relationships',
            work,
          });
        }
      })
      .catch((caughtError: mixed) => {
        setLoadingError(coerceToError(caughtError));
      });
  }, [
    isNewWork,
    hasLoadedRelationships,
    dispatch,
    work,
  ]);

  const removeWork = React.useCallback(() => {
    if (isNewWork) {
      let hasActiveRelationships = false;
      for (
        const relationship of
        iterateRelationshipsInTargetTypeGroups(relatedWork.targetTypeGroups)
      ) {
        if (relationship._status === REL_STATUS_REMOVE) {
          continue;
        }
        if (
          relationship.entity0.entityType === 'recording' &&
        relationship.entity0.id === track.recording.id &&
        relationship.entity1.entityType === 'work' &&
        relationship.entity1.id === relatedWork.work.id
        ) {
          continue;
        }
        hasActiveRelationships = true;
        break;
      }
      if (hasActiveRelationships) {
        const confirmed = window.confirm(
          l('Are you sure you want to remove this work?'),
        );
        if (!confirmed) {
          return;
        }
      }
    }
    dispatch({
      recording: track.recording,
      type: 'remove-work',
      workState: relatedWork,
    });
  }, [dispatch, track.recording, relatedWork, isNewWork]);

  const removeWorkButton = React.useMemo(() => (
    <button
      className="icon remove-item"
      onClick={removeWork}
      type="button"
    />
  ), [removeWork]);

  const isWorkRemoved = React.useMemo(() => {
    if (isNewWork) {
      /*
       * Pending works are removed once their last recording link is removed,
       * so if we still exist then this can't be true.
       */
      return false;
    }
    const targetTypeGroup = tree.find(
      relatedWork.targetTypeGroups,
      'recording',
      compareTargetTypeWithGroup,
    );
    if (!targetTypeGroup) {
      return true;
    }
    for (
      const relationship of
      iterateRelationshipsInTargetTypeGroup(targetTypeGroup)
    ) {
      if (relationship._status !== REL_STATUS_REMOVE) {
        return false;
      }
    }
    return true;
  }, [
    isNewWork,
    relatedWork.targetTypeGroups,
  ]);

  return (
    <>
      {isNewWork ? (
        <NewRelatedWorkHeading
          dispatch={dispatch}
          isSelected={relatedWork.isSelected}
          removeWorkButton={removeWorkButton}
          work={work}
        />
      ) : (
        <RelatedWorkHeading
          dispatch={dispatch}
          isRemoved={isWorkRemoved}
          isSelected={relatedWork.isSelected}
          removeWorkButton={removeWorkButton}
          work={work}
        />
      )}
      <RelationshipTargetTypeGroups
        dialogLocation={dialogLocation}
        dispatch={dispatch}
        filter={filterRecordings}
        releaseHasUnloadedTracks={releaseHasUnloadedTracks}
        source={work}
        targetTypeGroups={relatedWork.targetTypeGroups}
        track={track}
      />
      {loadingError ? (
        <p className="error">
          {texp.l(
            'Error loading work relationships: {error}',
            {error: loadingError.message},
          )}
        </p>
      ) : null}
    </>
  );
}

const RelatedWorkRelationshipEditor =
  React.memo(_RelatedWorkRelationshipEditor);

component _RelatedWorksRelationshipEditor(
  dialogLocation: RelationshipDialogLocationT | null,
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  recording: RecordingT,
  relatedWorks: MediumWorkStateTreeT,
  releaseHasUnloadedTracks: boolean,
  track: TrackWithRecordingT,
) {
  const relatedWorkElements = [];
  for (const relatedWork of tree.iterate(relatedWorks)) {
    relatedWorkElements.push(
      <RelatedWorkRelationshipEditor
        dialogLocation={
          (
            dialogLocation != null &&
            dialogLocation.source.entityType === 'work' &&
            dialogLocation.source.id === relatedWork.work.id
          ) ? dialogLocation : null
        }
        dispatch={dispatch}
        key={relatedWork.work.id}
        relatedWork={relatedWork}
        releaseHasUnloadedTracks={releaseHasUnloadedTracks}
        track={track}
      />,
    );
  }

  const buildNewRelatedWorkRelationshipData = React.useCallback(() => ({
    entity0: recording,
    entity1: createWorkObject({
      name: recording.name,
    }),
    linkTypeID: RECORDING_OF_LINK_TYPE_ID,
  }), [recording]);

  const buildAddRelatedWorkPopoverContent = useAddRelationshipDialogContent({
    buildNewRelationshipData: buildNewRelatedWorkRelationshipData,
    dispatch,
    preselectedTargetType: 'work',
    releaseHasUnloadedTracks,
    source: recording,
    title: lp('Add relationship', 'header'),
  });

  const setAddRelatedWorkDialogOpen = React.useCallback((
    open: boolean,
  ) => {
    dispatch({
      location: open ? {
        source: track.recording,
        targetType: 'work',
        track,
      } : null,
      type: 'update-dialog-location',
    });
  }, [dispatch, track]);

  return (
    <td className="works">
      <ButtonPopover
        buildChildren={buildAddRelatedWorkPopoverContent}
        buttonContent={l('Add related work')}
        buttonProps={{
          className: 'add-item with-label',
        }}
        className="relationship-dialog"
        closeOnOutsideClick={false}
        id="add-relationship-dialog"
        isDisabled={false}
        isOpen={
          dialogLocation != null &&
          dialogLocation.source.entityType === 'recording'
        }
        toggle={setAddRelatedWorkDialogOpen}
      />
      {relatedWorkElements}
    </td>
  );
}

const RelatedWorksRelationshipEditor =
  React.memo(_RelatedWorksRelationshipEditor);

component _TrackRelationshipEditor(
  dialogLocation: RelationshipDialogLocationT | null,
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  recordingState: MediumRecordingStateT,
  releaseHasUnloadedTracks: boolean,
  showArtists: boolean,
  track: TrackWithRecordingT,
) {
  const selectRecording = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      isSelected: event.currentTarget.checked,
      recording: track.recording,
      type: 'toggle-select-recording',
    });
  }, [dispatch, track.recording]);

  return (
    <tr className={'track ' + ((track.position % 2) ? 'odd' : 'even')}>
      <td className="pos t">{track.number}</td>
      <td className="recording">
        <input
          checked={recordingState.isSelected}
          className="recording"
          onChange={selectRecording}
          type="checkbox"
        />
        {' '}
        <TrackLink
          showArtists={showArtists}
          track={track}
        />
        <RelationshipTargetTypeGroups
          dialogLocation={
            (
              dialogLocation != null &&
              dialogLocation.source.entityType === 'recording' &&
              /*
               * Differentiate between "Add another work" within a phrase
               * group on the recording side, and "Add related work" on the
               * work side, which isn't associated with any phrase group.
               */
              (
                dialogLocation.targetType !== 'work' ||
                dialogLocation.textPhrase != null
              )
            ) ? dialogLocation : null
          }
          dispatch={dispatch}
          releaseHasUnloadedTracks={releaseHasUnloadedTracks}
          source={track.recording}
          targetTypeGroups={recordingState.targetTypeGroups}
          track={track}
        />
      </td>
      <RelatedWorksRelationshipEditor
        dialogLocation={
          (
            dialogLocation != null &&
            (
              dialogLocation.source.entityType === 'work' ||
              (
                // => The source type is implied to be 'recording'.
                dialogLocation.targetType === 'work' &&
                dialogLocation.textPhrase == null
              )
            )
          ) ? dialogLocation : null
        }
        dispatch={dispatch}
        recording={recordingState.recording}
        relatedWorks={recordingState.relatedWorks}
        releaseHasUnloadedTracks={releaseHasUnloadedTracks}
        track={track}
      />
    </tr>
  );
}

const TrackRelationshipEditor:
  component(...React.PropsOf<_TrackRelationshipEditor>) =
  React.memo(_TrackRelationshipEditor);

TrackRelationshipEditor.displayName = 'TrackRelationshipEditor';

export default TrackRelationshipEditor;
