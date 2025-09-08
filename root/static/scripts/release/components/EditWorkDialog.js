/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import isBlank from '../../common/utility/isBlank.js';
import {
  type MultiselectActionT,
  accumulateMultiselectValues,
} from '../../edit/components/Multiselect.js';
import DialogButtons
  from '../../relationship-editor/components/DialogButtons.js';
import useDialogEnterKeyHandler
  from '../../relationship-editor/hooks/useDialogEnterKeyHandler.js';
import type {
  EditWorkDialogStateT,
} from '../../relationship-editor/types.js';
import type {
  ReleaseRelationshipEditorActionT,
} from '../../relationship-editor/types/actions.js';

import WorkLanguageMultiselect, {
  createInitialState as createWorkLanguagesState,
  runReducer as runWorkLanguageMultiselectReducer,
} from './WorkLanguageMultiselect.js';
import WorkTypeSelect, {
  type WorkTypeSelectActionT,
} from './WorkTypeSelect.js';

type ActionT =
  | {
      name: string,
      type: 'update-name',
    }
  | {
      action: MultiselectActionT<LanguageT>,
      type: 'update-languages',
    }
  | WorkTypeSelectActionT;

export function createInitialState(
  work: WorkT,
): EditWorkDialogStateT {
  return {
    languages: createWorkLanguagesState(
      work.languages.map(workLanguage => workLanguage.language),
    ),
    name: work.name,
    workType: work.typeID,
  };
}

function reducer(
  state: EditWorkDialogStateT,
  action: ActionT,
): EditWorkDialogStateT {
  const newState = {...state};

  match (action) {
    {type: 'update-name', const name} => {
      newState.name = name;
    }
    {type: 'update-languages', const action} => {
      const newLanguages = {...newState.languages};

      runWorkLanguageMultiselectReducer(
        newLanguages,
        action,
      );

      newState.languages = newLanguages;
    }
    {type: 'update-work-type', const workType} => {
      newState.workType = workType;
    }
  }

  return newState;
}

component _EditWorkDialog(
  closeDialog: () => void,
  initialFocusRef?: {-current: HTMLElement | null},
  rootDispatch: (ReleaseRelationshipEditorActionT) => void,
  work: WorkT,
) {
  const [state, dispatch] = React.useReducer(
    reducer,
    work,
    createInitialState,
  );

  const {
    languages,
    name,
    workType,
  } = state;

  const isNameBlank = isBlank(name);

  function handleNameChange(
    event: SyntheticEvent<HTMLInputElement>,
  ) {
    dispatch({name: event.currentTarget.value, type: 'update-name'});
  }

  const languagesDispatch = React.useCallback((
    action: MultiselectActionT<LanguageT>,
  ) => {
    dispatch({action, type: 'update-languages'});
  }, [dispatch]);

  const acceptDialog = React.useCallback(() => {
    if (isNameBlank) {
      return;
    }

    rootDispatch({
      languages: accumulateMultiselectValues(languages.values),
      name,
      type: 'accept-edit-work-dialog',
      work,
      workType,
    });

    closeDialog();
  }, [
    isNameBlank,
    rootDispatch,
    languages,
    name,
    workType,
    work,
    closeDialog,
  ]);

  const handleKeyDown = useDialogEnterKeyHandler(acceptDialog);

  return (
    <div className="form" onKeyDown={handleKeyDown}>
      <h1>{lp('Edit work', 'header')}</h1>
      <table className="work-details">
        <tbody>
          <tr>
            <td className="section">{addColonText(l('Name'))}</td>
            <td>
              <input
                onChange={handleNameChange}
                ref={initialFocusRef}
                type="text"
                value={name}
              />
              {isNameBlank ? (
                <div aria-atomic="true" className="error" role="alert">
                  {l('Required field.')}
                </div>
              ) : null}
            </td>
          </tr>
          <WorkTypeSelect
            dispatch={dispatch}
            workType={workType}
          />
          <WorkLanguageMultiselect
            dispatch={languagesDispatch}
            state={languages}
          />
        </tbody>
      </table>
      <DialogButtons
        isDoneDisabled={isNameBlank}
        onCancel={closeDialog}
        onDone={acceptDialog}
      />
    </div>
  );
}

const EditWorkDialog:
  component(...React.PropsOf<_EditWorkDialog>) =
  React.memo(_EditWorkDialog);

export default EditWorkDialog;
