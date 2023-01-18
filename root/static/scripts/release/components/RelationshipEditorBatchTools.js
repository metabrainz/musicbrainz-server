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
import {createCoreEntityObject} from '../../common/entity2.js';
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
  +sourceType: CoreEntityTypeT,
};

const BatchAddRelationshipButtonPopover = ({
  batchSelectionCount,
  buttonClassName,
  buttonContent,
  dispatch,
  entityPlaceholder,
  isOpen,
  popoverId,
  sourceType,
}: BatchAddRelationshipButtonPopoverPropsT) => {
  const addButtonRef = React.useRef<HTMLButtonElement | null>(null);

  const sourcePlaceholder = React.useMemo(() =>(
    createCoreEntityObject(sourceType, {
      name: entityPlaceholder,
    })
  ), [sourceType, entityPlaceholder]);

  const buildPopoverContent = useAddRelationshipDialogContent({
    batchSelectionCount,
    defaultTargetType: null,
    dispatch,
    source: sourcePlaceholder,
    title: l('Add Relationship'),
  });

  const setOpen = React.useCallback((open) => {
    dispatch({
      location: open ? {
        batchSelection: true,
        source: sourcePlaceholder,
      } : null,
      type: 'update-dialog-location',
    });
  }, [dispatch, sourcePlaceholder]);

  const [hover, setHover] = React.useState(false);

  const onMouseEnter = React.useCallback(() => {
    setHover(true);
  }, [setHover]);

  const onMouseLeave = React.useCallback(() => {
    setHover(false);
  }, [setHover]);

  const isDisabled = batchSelectionCount === 0;

  const wrapButtonForTooltip = React.useCallback((buttonElement) => {
    /*
     * Note: mouseenter isn't triggered for disabled buttons, so these
     * events must go on the parent.
     */
    return (
      <span
        className="tooltip-wrapper"
        onMouseEnter={() => setHover(true)}
        onMouseLeave={() => setHover(false)}
      >
        {buttonElement}
        {(isDisabled && hover) ? (
          <Tooltip
            content={l(
              `To use the batch tools, select some
              recordings or works using the checkboxes.`,
            )}
            hoverCallback={setHover}
          />
        ) : null}
      </span>
    );
  }, [setHover, isDisabled, hover]);

  return (
    <ButtonPopover
      buildChildren={buildPopoverContent}
      buttonContent={buttonContent}
      buttonProps={{
        className: `add-item with-label ${buttonClassName}`,
      }}
      buttonRef={addButtonRef}
      className="relationship-dialog"
      closeOnOutsideClick={false}
      id={popoverId}
      isDisabled={isDisabled}
      isOpen={isOpen}
      toggle={setOpen}
      wrapButton={wrapButtonForTooltip}
    />
  );
};

const RelationshipEditorBatchTools = (React.memo<PropsT>(({
  dialogLocation,
  dispatch,
  recordingSelectionCount,
  workSelectionCount,
}: PropsT): React.Element<'table'> => {
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
              sourceType="work"
            />
          </td>
        </tr>
      </tbody>
    </table>
  );
}): React.AbstractComponent<PropsT>);

export default RelationshipEditorBatchTools;
