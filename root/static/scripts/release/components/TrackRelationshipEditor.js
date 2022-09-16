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

import ArtistCreditLink from '../../common/components/ArtistCreditLink.js';
import ButtonPopover from '../../common/components/ButtonPopover.js';
import EntityLink from '../../common/components/EntityLink.js';
import {RECORDING_OF_LINK_TYPE_ID} from '../../common/constants.js';
import {createWorkObject} from '../../common/entity2.js';
import {bracketedText} from '../../common/utility/bracketed.js';
import formatTrackLength from '../../common/utility/formatTrackLength.js';
import NewWorkLink
  from '../../relationship-editor/components/NewWorkLink.js';
import RelationshipTargetTypeGroups
  // eslint-disable-next-line max-len
  from '../../relationship-editor/components/RelationshipTargetTypeGroups.js';
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

import EditWorkDialog from './EditWorkDialog.js';

type TrackLinkPropsT = {
  +showArtists: boolean,
  +track: TrackWithRecordingT,
};

const TrackLink = React.memo<TrackLinkPropsT>(({
  showArtists,
  track,
}) => {
  let trackLink: Expand2ReactOutput = (
    <EntityLink
      content={track.name}
      entity={track.recording}
      target="_blank"
    />
  );

  if (showArtists) {
    trackLink = exp.l('{entity} by {artist}', {
      artist: <ArtistCreditLink artistCredit={track.artistCredit} />,
      entity: trackLink,
    });
  }

  return (
    <>
      {trackLink}
      {' '}
      {bracketedText(formatTrackLength(track.length))}
    </>
  );
});

type WorkLinkPropsT = {
  +work: WorkT,
};

const WorkLink = React.memo<WorkLinkPropsT>(({
  work,
}) => (
  <EntityLink allowNew entity={work} target="_blank" />
));

type RelatedWorkHeadingPropsT = {
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +isSelected: boolean,
  +work: WorkT,
};

const RelatedWorkHeading = ({
  dispatch,
  isSelected,
  work,
}: RelatedWorkHeadingPropsT) => {
  const selectWork = React.useCallback((event) => {
    dispatch({
      isSelected: event.target.checked,
      type: 'toggle-select-work',
      work,
    });
  }, [dispatch, work]);

  return (
    <h3>
      <input
        checked={isSelected}
        className="work"
        onChange={selectWork}
        type="checkbox"
      />
      {' '}
      <WorkLink work={work} />
    </h3>
  );
};

const NewRelatedWorkHeading = ({
  dispatch,
  isSelected,
  work,
}: RelatedWorkHeadingPropsT) => {
  const selectWork = React.useCallback((event) => {
    dispatch({
      isSelected: event.target.checked,
      type: 'toggle-select-work',
      work,
    });
  }, [dispatch, work]);

  const editWorkButtonRef = React.useRef(null);

  const [
    isEditWorkDialogOpen,
    setEditWorkDialogOpen,
  ] = React.useState(false);

  const buildEditWorkPopoverContent = React.useCallback(
    (closeAndReturnFocus) => (
      <EditWorkDialog
        closeDialog={closeAndReturnFocus}
        rootDispatch={dispatch}
        work={work}
      />
    ),
    [dispatch, work],
  );

  return (
    <h3 id={'new-work-' + String(work.id)}>
      <input
        checked={isSelected}
        className="work"
        onChange={selectWork}
        type="checkbox"
      />
      {' '}
      <ButtonPopover
        buildChildren={buildEditWorkPopoverContent}
        buttonContent={null}
        buttonProps={{
          className: 'icon edit-item',
        }}
        buttonRef={editWorkButtonRef}
        className="work-dialog"
        id="edit-work-dialog"
        isOpen={isEditWorkDialogOpen}
        toggle={setEditWorkDialogOpen}
      />
      {' '}
      <NewWorkLink work={work} />
    </h3>
  );
};

type RelatedWorkRelationshipEditorPropsT = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +relatedWork: MediumWorkStateT,
  +track: TrackWithRecordingT,
};

const filterRecordings = (
  targetType: CoreEntityTypeT,
) => targetType !== 'recording';

const RelatedWorkRelationshipEditor = React.memo<
  RelatedWorkRelationshipEditorPropsT,
>(({
  dialogLocation,
  dispatch,
  relatedWork,
  track,
}) => {
  const work = relatedWork.work;
  const isNewWork = work._fromBatchCreateWorksDialog === true;
  const hasLoadedRelationships = work.relationships != null;

  React.useEffect(function () {
    if (isNewWork || hasLoadedRelationships) {
      return;
    }
    fetch(
      '/ws/js/entity/' + work.gid + '?inc=rels',
    ).then((resp) => {
      if (!resp.ok) {
        return null;
      }
      return resp.json();
    // $FlowIgnore[unclear-type]
    }).then((data: any) => {
      if (data.relationships?.length) {
        dispatch({
          relationships: data.relationships,
          type: 'load-work-relationships',
          work,
        });
      }
    });
  }, [
    isNewWork,
    hasLoadedRelationships,
    dispatch,
    work,
  ]);

  const RelatedWorkHeadingComponent =
    isNewWork ? NewRelatedWorkHeading : RelatedWorkHeading;

  return (
    <>
      <RelatedWorkHeadingComponent
        dispatch={dispatch}
        isSelected={relatedWork.isSelected}
        work={work}
      />
      <RelationshipTargetTypeGroups
        dialogLocation={dialogLocation}
        dispatch={dispatch}
        filter={filterRecordings}
        source={work}
        targetTypeGroups={relatedWork.targetTypeGroups}
        track={track}
      />
    </>
  );
});

type RelatedWorksRelationshipEditorPropsT = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +recording: RecordingT,
  +relatedWorks: MediumWorkStateTreeT | null,
  +track: TrackWithRecordingT,
};

const RelatedWorksRelationshipEditor = React.memo<
  RelatedWorksRelationshipEditorPropsT,
>(({
  dialogLocation,
  dispatch,
  recording,
  relatedWorks,
  track,
}) => {
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
        track={track}
      />,
    );
  }

  const addRelatedWorkButtonRef = React.useRef(null);

  const buildNewRelatedWorkRelationshipData = React.useCallback(() => ({
    entity0: recording,
    entity1: createWorkObject({
      name: recording.name,
    }),
    linkTypeID: RECORDING_OF_LINK_TYPE_ID,
  }), [recording]);

  const buildAddRelatedWorkPopoverContent = useAddRelationshipDialogContent({
    buildNewRelationshipData: buildNewRelatedWorkRelationshipData,
    defaultTargetType: 'work',
    dispatch,
    source: recording,
    title: l('Add Relationship'),
  });

  const setAddRelatedWorkDialogOpen = React.useCallback((open) => {
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
        buttonRef={addRelatedWorkButtonRef}
        className="relationship-dialog"
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
});

type TrackRelationshipEditorPropsT = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +recordingState: MediumRecordingStateT,
  +showArtists: boolean,
  +track: TrackWithRecordingT,
};

const TrackRelationshipEditor = (React.memo<TrackRelationshipEditorPropsT>(({
  dialogLocation,
  dispatch,
  recordingState,
  showArtists,
  track,
}: TrackRelationshipEditorPropsT) => {
  const selectRecording = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      isSelected: event.currentTarget.checked,
      type: 'toggle-select-recording',
      recording: track.recording,
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
        track={track}
      />
    </tr>
  );
}): React.AbstractComponent<TrackRelationshipEditorPropsT>);

TrackRelationshipEditor.displayName = 'TrackRelationshipEditor';

export default TrackRelationshipEditor;
