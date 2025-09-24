/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate, {type CowContext} from 'mutate-cow';
import React from 'react';

import {pushCompoundField} from '../utility/pushField.js';

import AddButton from './AddButton.js';
import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';
import FormRow from './FormRow.js';
import RemoveButton from './RemoveButton.js';

type StateT = {
  // The current text values as stored in the database.
  +currentTextValues: $ReadOnlyArray<string>,
  /*
   * The current form values, as either initialized from the database or
   * submitted by the user.
   */
  +repeatable: TextListFieldT,
};

type InitialStateT = {
  +currentTextValues: ?$ReadOnlyArray<string>,
  +repeatable: TextListFieldT,
};

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

function pushNewListItem(fieldCtx: CowContext<TextListFieldT>) {
  pushCompoundField(fieldCtx, {removed: false, value: ''});
}

const createInitialState = (state: InitialStateT): StateT => {
  let newRepeatableField = {...state.repeatable};
  if (newRepeatableField.last_index === -1) {
    newRepeatableField = mutate(newRepeatableField).update((fieldCtx) => {
      pushNewListItem(fieldCtx);
    }).final();
  }
  return {
    currentTextValues: state.currentTextValues ?? [],
    repeatable: newRepeatableField,
  };
};

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  const repeatableCtx = newStateCtx.get('repeatable');
  const fieldCtx = repeatableCtx.get('field');

  match (action) {
    {type: 'add-row'} => {
      pushCompoundField(repeatableCtx, {removed: false, value: ''});
    }
    {type: 'remove-row', const fieldId} => {
      let removedValue;
      const index = fieldCtx.read().findIndex((subfield) => {
        if (subfield.id === fieldId) {
          removedValue = subfield.field.value.value;
          return true;
        }
        return false;
      });
      if (nonEmpty(removedValue) &&
          state.currentTextValues.includes(removedValue)) {
        fieldCtx.set(index, 'field', 'removed', 'value', true);
      } else {
        const newField = fieldCtx.read().slice(0);
        newField.splice(index, 1);
        fieldCtx.set(newField);
      }
      const nonRemovedCount = fieldCtx.read().reduce((count, field) => {
        return field.field.removed.value ? count : (count + 1);
      }, 0);
      if (nonRemovedCount === 0) {
        pushNewListItem(repeatableCtx);
      }
    }
    {type: 'update-row', const fieldId, const value} => {
      const index = fieldCtx.read().findIndex(
        (subfield) => subfield.id === fieldId,
      );
      const valueCtx = fieldCtx.get(index, 'field', 'value', 'value');
      const oldValue = valueCtx.read();
      valueCtx.set(value);
      if (state.currentTextValues.includes(oldValue)) {
        pushCompoundField(repeatableCtx, {removed: true, value: oldValue});
      }
    }
  }
  return newStateCtx.final();
}

component FormRowTextList(
  addButtonLabel: string,
  addButtonId: string,
  initialState: InitialStateT,
  label: string,
  removeButtonLabel: string,
  required: boolean = false,
) {
  const [state, dispatch] =
    React.useReducer<StateT, ActionT, InitialStateT>(
      reducer,
      initialState,
      createInitialState,
    );

  const addRow = React.useCallback(() => {
    dispatch({type: 'add-row'});
  }, [dispatch]);

  return (
    <>
      <FormLabel label={label} required={required} />

      <div className="form-row-text-list">
        {state.repeatable.field.map((field) => (
          field.field.removed.value
            ? (
              <React.Fragment key={field.id}>
                <input
                  name={field.html_name}
                  type="hidden"
                  value={field.field.value.value}
                />
                <input
                  name={field.html_name + '.removed'}
                  type="hidden"
                  value="1"
                />
              </React.Fragment>
            )
            : (
              <TextListRow
                dispatch={dispatch}
                fieldId={field.id}
                key={field.id}
                name={field.html_name}
                removeButtonLabel={removeButtonLabel}
                value={field.field.value.value}
              />
            )
        ))}

        <div className="form-row-add">
          <AddButton
            id={addButtonId}
            label={addButtonLabel}
            onClick={addRow}
          />
        </div>
      </div>

      <FieldErrors field={state.repeatable} />
    </>
  );
}

export component NonHydratedFormRowTextList(
  ...props: React.PropsOf<FormRowTextList>
) {
  return (
    <FormRow className="form-row-text-list-container">
      <FormRowTextList {...props} />
    </FormRow>
  );
}

/*
 * Hydration must be moved higher up in the component hierarchy once
 * more of the page is converted to React.
 */
export default (hydrate<React.PropsOf<FormRowTextList>>(
  'div.row.form-row-text-list-container',
  FormRowTextList,
): component(...React.PropsOf<FormRowTextList>));
