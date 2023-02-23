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
import {
  RECORDING_OF_LINK_TYPE_GID,
} from '../../common/constants.js';
import {createRecordingObject} from '../../common/entity2.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import {
  accumulateMultiselectValues,
} from '../../edit/components/Multiselect.js';
import Tooltip from '../../edit/components/Tooltip.js';
import DialogAttributes, {
  createInitialState as createDialogAttributesState,
  reducer as dialogAttributesReducer,
} from '../../relationship-editor/components/DialogAttributes.js';
import DialogButtons
  from '../../relationship-editor/components/DialogButtons.js';
import DialogLinkType, {
  createInitialState as createDialogLinkTypeState,
  updateDialogState as updateDialogLinkTypeState,
} from '../../relationship-editor/components/DialogLinkType.js';
import useDialogEnterKeyHandler
  from '../../relationship-editor/hooks/useDialogEnterKeyHandler.js';
import type {
  BatchCreateWorksDialogStateT,
} from '../../relationship-editor/types.js';
import type {
  AcceptBatchCreateWorksDialogActionT,
  BatchCreateWorksDialogActionT,
  ReleaseRelationshipEditorActionT,
} from '../../relationship-editor/types/actions.js';
import getDialogLinkTypeOptions
  from '../../relationship-editor/utility/getDialogLinkTypeOptions.js';

import WorkLanguageMultiselect, {
  createInitialState as createWorkLanguagesState,
  runReducer as runWorkLanguageMultiselectReducer,
} from './WorkLanguageMultiselect.js';
import WorkTypeSelect from './WorkTypeSelect.js';

const RECORDING_PLACEHOLDER = createRecordingObject();

export function createInitialState(): BatchCreateWorksDialogStateT {
  return {
    attributes: createDialogAttributesState(
      linkedEntities.link_type[RECORDING_OF_LINK_TYPE_GID],
      null,
    ),
    languages: createWorkLanguagesState(),
    linkType: createDialogLinkTypeState(
      linkedEntities.link_type[RECORDING_OF_LINK_TYPE_GID],
      RECORDING_PLACEHOLDER,
      'work',
      getDialogLinkTypeOptions(RECORDING_PLACEHOLDER, 'work'),
      'batch-create-works',
      true, /* disabled */
      /*
       * There is only one selectable link type at the moment
       * (recording of), so the autocomplete is disabled. This
       * allows focus to start on "Work Type" instead.
       */
    ),
    workType: null,
  };
}

export function reducer(
  state: BatchCreateWorksDialogStateT,
  action: BatchCreateWorksDialogActionT,
): BatchCreateWorksDialogStateT {
  const newState = {...state};

  switch (action.type) {
    case 'update-attribute': {
      newState.attributes = dialogAttributesReducer(
        newState.attributes,
        action.action,
      );
      break;
    }

    case 'update-languages': {
      const newLanguages = {...newState.languages};

      runWorkLanguageMultiselectReducer(
        newLanguages,
        action.action,
      );

      newState.languages = newLanguages;
      break;
    }

    case 'update-link-type': {
      updateDialogLinkTypeState(state, newState, action);
      break;
    }

    case 'update-work-type': {
      newState.workType = action.workType;
      break;
    }
  }

  return newState;
}

type BatchCreateWorksDialogContentPropsT = {
  +closeDialog: () => void,
  +sourceDispatch: (AcceptBatchCreateWorksDialogActionT) => void,
};

const BatchCreateWorksDialogContent = React.memo<
  BatchCreateWorksDialogContentPropsT,
>(({
  closeDialog,
  sourceDispatch,
}: BatchCreateWorksDialogContentPropsT): React.Element<'div'> => {
  const [state, dispatch] = React.useReducer(
    reducer,
    null,
    createInitialState,
  );

  const {
    attributes,
    languages,
    linkType: linkTypeState,
    workType,
  } = state;

  const hasErrors = !!(
    nonEmpty(linkTypeState.error) ||
    attributes.attributesList.some(x => x.error)
  );

  const linkTypeDispatch = React.useCallback((action) => {
    dispatch({
      action,
      source: RECORDING_PLACEHOLDER,
      type: 'update-link-type',
    });
  }, [dispatch]);

  const attributesDispatch = React.useCallback((action) => {
    dispatch({action, type: 'update-attribute'});
  }, [dispatch]);

  const languagesDispatch = React.useCallback((action) => {
    dispatch({action, type: 'update-languages'});
  }, [dispatch]);

  const acceptDialog = React.useCallback(() => {
    const linkType = linkTypeState.autocomplete.selectedItem?.entity;

    invariant(!hasErrors && linkType);

    sourceDispatch({
      attributes: attributes.resultingLinkAttributes,
      languages: accumulateMultiselectValues(languages.values),
      linkType,
      type: 'accept-batch-create-works-dialog',
      workType,
    });

    closeDialog();
  }, [
    hasErrors,
    linkTypeState.autocomplete.selectedItem?.entity,
    attributes.resultingLinkAttributes,
    languages.values,
    workType,
    closeDialog,
    sourceDispatch,
  ]);

  const handleKeyDown = useDialogEnterKeyHandler(acceptDialog);

  return (
    <div className="form" onKeyDown={handleKeyDown}>
      <p className="msg">
        {l(`This will create a new work for each checked recording that has no
            work already. The work names will be the same as their respective
            recording.`)}
      </p>
      <p className="msg warning">
        {l(`Only use this option after you’ve tried searching for the work(s)
            you want to create, and are certain they do not already exist on
            MusicBrainz.`)}
      </p>
      <table className="relationship-details">
        <tbody>
          <DialogLinkType
            dispatch={linkTypeDispatch}
            isHelpVisible={false}
            source={RECORDING_PLACEHOLDER}
            state={linkTypeState}
          />
          <WorkTypeSelect
            dispatch={dispatch}
            workType={workType}
          />
          <WorkLanguageMultiselect
            dispatch={languagesDispatch}
            state={languages}
          />
          <DialogAttributes
            dispatch={attributesDispatch}
            isHelpVisible={false}
            state={attributes}
          />
        </tbody>
      </table>
      <DialogButtons
        isDoneDisabled={hasErrors}
        onCancel={closeDialog}
        onDone={acceptDialog}
      />
    </div>
  );
});

type BatchCreateWorksButtonPopoverPropsT = {
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +isDisabled: boolean,
  +isOpen: boolean,
};

export const BatchCreateWorksButtonPopover = (React.memo<
  BatchCreateWorksButtonPopoverPropsT,
>(({
  dispatch,
  isDisabled,
  isOpen,
}: BatchCreateWorksButtonPopoverPropsT): React.MixedElement => {
  const addButtonRef = React.useRef<HTMLButtonElement | null>(null);

  const setOpen = React.useCallback((open) => {
    dispatch({
      location: open ? {
        batchSelection: true,
        source: createRecordingObject(),
        targetType: 'work',
      } : null,
      type: 'update-dialog-location',
    });
  }, [dispatch]);

  const closeDialog = React.useCallback(() => {
    setOpen(false);
  }, [setOpen]);

  const buildPopoverContent = React.useCallback(() => (
    <BatchCreateWorksDialogContent
      closeDialog={closeDialog}
      sourceDispatch={dispatch}
    />
  ), [closeDialog, dispatch]);

  let tooltipMessage = null;
  if (isDisabled) {
    tooltipMessage = l(
      `To use this tool, select some recordings
       using the checkboxes below.`,
    );
  }

  return (
    <Tooltip
      content={tooltipMessage}
      target={
        <ButtonPopover
          buildChildren={buildPopoverContent}
          buttonContent={l('Batch-create new works')}
          buttonProps={{
            className: 'add-item with-label batch-create-works',
          }}
          buttonRef={addButtonRef}
          className="relationship-dialog"
          closeOnOutsideClick={false}
          id="batch-create-works-dialog"
          isDisabled={isDisabled}
          isOpen={isOpen}
          toggle={setOpen}
        />
      }
    />
  );
}): React.AbstractComponent<BatchCreateWorksButtonPopoverPropsT, mixed>);
