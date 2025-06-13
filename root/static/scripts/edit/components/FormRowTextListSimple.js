/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * This file contains a deprecated version of ./FormRowTextList.js for fields
 * that don't support a 'removed' subfield on list items. It just submits
 * the list of text values to the server as-is, and has no way of indicating
 * which values the user removed (to handle cases like MBS-13969).
 */

import mutate from 'mutate-cow';
import React from 'react';

import {pushField} from '../utility/pushField.js';

import AddButton from './AddButton.js';
import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';
import FormRow from './FormRow.js';
import RemoveButton from './RemoveButton.js';

type StateT = RepeatableFieldT<FieldT<string>>;

type ActionT =
  | {+type: 'add-row'}
  | {+fieldId: number, +type: 'remove-row'}
  | {+fieldId: number, +type: 'update-row', +value: string};

component TextListRow(
  dispatch: (ActionT) => void,
  fieldId: number,
  name: string,
  removeButtonLabel: string,
  value: string,
) {
  const removeRow = React.useCallback((): void => {
    dispatch({fieldId, type: 'remove-row'});
  }, [dispatch, fieldId]);

  const updateRow = React.useCallback((
    event: SyntheticInputEvent<HTMLInputElement>,
  ) => {
    const value = event.currentTarget.value;
    dispatch({fieldId, type: 'update-row', value});
  }, [dispatch, fieldId]);

  return (
    <div className="text-list-row">
      <input
        className="value with-button"
        name={name}
        onChange={updateRow}
        type="text"
        value={value}
      />
      <RemoveButton
        onClick={removeRow}
        title={removeButtonLabel}
      />
    </div>
  );
}

const createInitialState = (repeatable: RepeatableFieldT<FieldT<string>>) => {
  let newField = {...repeatable};
  if (newField.last_index === -1) {
    newField = mutate(newField).update((fieldCtx) => {
      pushField(fieldCtx, '');
    }).final();
  }
  return newField;
};

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  const fieldCtx = newStateCtx.get('field');

  switch (action.type) {
    case 'add-row': {
      newStateCtx.update((fieldCtx) => {
        pushField(fieldCtx, '');
      });
      break;
    }
    case 'remove-row': {
      const index = fieldCtx.read().findIndex(
        (subfield) => subfield.id === action.fieldId,
      );

      if (fieldCtx.read().length === 1) {
        newStateCtx.set('field', index, 'value', '');
        break;
      }

      newStateCtx.update('field', (fieldCtx) => {
        fieldCtx.write().splice(index, 1);
      });
      break;
    }
    case 'update-row': {
      const index = fieldCtx.read().findIndex(
        (subfield) => subfield.id === action.fieldId,
      );

      newStateCtx.set('field', index, 'value', action.value);
      break;
    }
  }
  return newStateCtx.final();
}

component FormRowTextListSimple(
  addButtonLabel: string,
  addButtonId: string,
  label: string,
  removeButtonLabel: string,
  repeatable: RepeatableFieldT<FieldT<string>>,
  required: boolean = false,
) {
  const [state, dispatch] =
    React.useReducer<StateT, ActionT, RepeatableFieldT<FieldT<string>>>(
      reducer,
      repeatable,
      createInitialState,
    );

  const addRow = React.useCallback(() => {
    dispatch({type: 'add-row'});
  }, [dispatch]);

  return (
    <>
      <FormLabel label={label} required={required} />

      <div className="form-row-text-list">
        {state.field.map((field) => (
          <TextListRow
            dispatch={dispatch}
            fieldId={field.id}
            key={field.id}
            name={field.html_name}
            removeButtonLabel={removeButtonLabel}
            value={field.value}
          />
        ))}

        <div className="form-row-add">
          <AddButton
            id={addButtonId}
            label={addButtonLabel}
            onClick={addRow}
          />
        </div>
      </div>

      <FieldErrors field={repeatable} />
    </>
  );
}

export component NonHydratedFormRowTextListSimple(
  ...props: React.PropsOf<FormRowTextListSimple>
) {
  return (
    <FormRow className="form-row-text-list-container">
      <FormRowTextListSimple {...props} />
    </FormRow>
  );
}

/*
 * Hydration must be moved higher up in the component hierarchy once
 * more of the page is converted to React.
 */
export default (hydrate<React.PropsOf<FormRowTextListSimple>>(
  'div.row.form-row-text-list-container',
  FormRowTextListSimple,
): component(...React.PropsOf<FormRowTextListSimple>));
