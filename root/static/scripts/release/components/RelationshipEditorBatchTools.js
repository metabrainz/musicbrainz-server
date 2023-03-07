/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ButtonPopover from '../../common/components/ButtonPopover.js';
import {createRelatableEntityObject} from '../../common/entity2.js';
import Tooltip from '../../edit/components/Tooltip.js';
import {
  useAddRelationshipDialogContent,
} from '../../relationship-editor/hooks/useRelationshipDialogContent.js';
import type {
  RelationshipDialogLocationT,
} from '../../relationship-editor/types.js';
import type {
  ReleaseRelationshipEditorActionT,
} from '../../relationship-editor/types/actions.js';

import {BatchCreateWorksButtonPopover} from './BatchCreateWorksDialog.js';

type PropsT = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +recordingSelectionCount: number,
  +releaseHasUnloadedTracks: boolean,
  +workSelectionCount: number,
};

type BatchAddRelationshipButtonPopoverPropsT = {
  +batchSelectionCount: number,
  +buttonClassName: string,
  +buttonContent: string,
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +entityPlaceholder: string,
  +isOpen: boolean,
  +popoverId: string,
  +releaseHasUnloadedTracks: boolean,
  +sourceType: RelatableEntityTypeT,
};

const BatchAddRelationshipButtonPopover = ({
  batchSelectionCount,
  buttonClassName,
  buttonContent,
  dispatch,
  entityPlaceholder,
  isOpen,
  popoverId,
  releaseHasUnloadedTracks,
  sourceType,
}: BatchAddRelationshipButtonPopoverPropsT) => {
  const addButtonRef = React.useRef<HTMLButtonElement | null>(null);

  const sourcePlaceholder = createRelatableEntityObject(sourceType, {
    name: entityPlaceholder,
  });

  const buildPopoverContent = useAddRelationshipDialogContent({
    batchSelectionCount,
    dispatch,
    preselectedTargetType: null,
    releaseHasUnloadedTracks,
    source: sourcePlaceholder,
    title: l('Add Relationship'),
  });

  const setOpen = React.useCallback((open: boolean) => {
    dispatch({
      location: open ? {
        batchSelection: true,
        source: sourcePlaceholder,
      } : null,
      type: 'update-dialog-location',
    });
  }, [dispatch, sourcePlaceholder]);

  const isDisabled = batchSelectionCount === 0;

  const buttonProps = React.useMemo(() => ({
    className: `add-item with-label ${buttonClassName}`,
  }), [buttonClassName]);

  let tooltipMessage = null;
  if (isDisabled) {
    switch (sourceType) {
      case 'recording': {
        tooltipMessage = l(
          `To use this tool, select some recordings
           using the checkboxes below.`,
        );
        break;
      }
      case 'work': {
        tooltipMessage = l(
          `To use this tool, select some works
           using the checkboxes below.`,
        );
        break;
      }
    }
  }

  return (
    <Tooltip
      content={tooltipMessage}
      target={
        <ButtonPopover
          buildChildren={buildPopoverContent}
          buttonContent={buttonContent}
          buttonProps={buttonProps}
          buttonRef={addButtonRef}
          className="relationship-dialog"
          closeOnOutsideClick={false}
          id={popoverId}
          isDisabled={isDisabled}
          isOpen={isOpen}
          toggle={setOpen}
        />
      }
    />
  );
};

const RelationshipEditorBatchTools = (React.memo<PropsT>(({
  dialogLocation,
  dispatch,
  recordingSelectionCount,
  releaseHasUnloadedTracks,
  workSelectionCount,
}: PropsT): React$Element<'table'> => {
  return (
    <table id="batch-tools">
      <tbody>
        <tr>
          <td>
            <BatchAddRelationshipButtonPopover
              batchSelectionCount={recordingSelectionCount}
              buttonClassName="batch-add-recording-relationship"
              buttonContent={l('Batch-add a relationship to recordings')}
              dispatch={dispatch}
              entityPlaceholder={l('[selected recording]')}
              isOpen={
                dialogLocation != null &&
                dialogLocation.source.entityType === 'recording' &&
                dialogLocation.targetType == null
              }
              popoverId="batch-add-recording-relationship-dialog"
              releaseHasUnloadedTracks={releaseHasUnloadedTracks}
              sourceType="recording"
            />
          </td>
          <td>
            <BatchCreateWorksButtonPopover
              dispatch={dispatch}
              isDisabled={recordingSelectionCount === 0}
              isOpen={
                dialogLocation != null &&
                dialogLocation.source.entityType === 'recording' &&
                dialogLocation.targetType === 'work'
              }
            />
          </td>
          <td>
            <BatchAddRelationshipButtonPopover
              batchSelectionCount={workSelectionCount}
              buttonClassName="batch-add-work-relationship"
              buttonContent={l('Batch-add a relationship to works')}
              dispatch={dispatch}
              entityPlaceholder={l('[selected work]')}
              isOpen={
                dialogLocation != null &&
                dialogLocation.source.entityType === 'work'
              }
              popoverId="batch-add-work-relationship-dialog"
              releaseHasUnloadedTracks={releaseHasUnloadedTracks}
              sourceType="work"
            />
          </td>
        </tr>
      </tbody>
    </table>
  );
}): React$AbstractComponent<PropsT, mixed>);

export default RelationshipEditorBatchTools;
