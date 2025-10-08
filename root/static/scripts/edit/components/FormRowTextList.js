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

export type StateT = TextListFieldT;

export type ActionT =
  | {+type: 'add-row'}
  | {
    +currentTextValues: $ReadOnlyArray<string>,
    +fieldId: number,
    +type: 'remove-row',
  }
  | {
    +currentTextValues: $ReadOnlyArray<string>,
    +fieldId: number,
    +type: 'update-row',
    +value: string,
  };

component TextListRow(
  currentTextValues: $ReadOnlyArray<string>,
  dispatch: (ActionT) => void,
  field: TextListItemFieldT,
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  removeButtonLabel: string,
) {
  const fieldId = field.id;
  const removeRow = React.useCallback((): void => {
    dispatch({currentTextValues, fieldId, type: 'remove-row'});
  }, [currentTextValues, dispatch, fieldId]);

  const updateRow = React.useCallback((
    event: SyntheticInputEvent<HTMLInputElement>,
  ) => {
    const value = event.currentTarget.value;
    dispatch({currentTextValues, fieldId, type: 'update-row', value});
  }, [currentTextValues, dispatch, fieldId]);

  return (
    <>
      <div className="text-list-row">
        <input
          className="value with-button"
          name={field.html_name}
          onChange={updateRow}
          onFocus={onFocus}
          type="text"
          value={field.field.value.value}
        />
        <RemoveButton
          onClick={removeRow}
          title={removeButtonLabel}
        />
      </div>
      <FieldErrors field={field} />
    </>
  );
}

function pushNewListItem(fieldCtx: CowContext<TextListFieldT>) {
  pushCompoundField(fieldCtx, {removed: false, value: ''});
}

export function createInitialState(state: StateT): StateT {
  let newRepeatableField = {...state};
  if (newRepeatableField.last_index === -1) {
    newRepeatableField = mutate(newRepeatableField).update((fieldCtx) => {
      pushNewListItem(fieldCtx);
    }).final();
  }
  return newRepeatableField;
}

export function runReducer(
  newStateCtx: CowContext<StateT>,
  action: ActionT,
): void {
  const fieldCtx = newStateCtx.get('field');

  match (action) {
    {type: 'add-row'} => {
      pushCompoundField(newStateCtx, {removed: false, value: ''});
    }
    {type: 'remove-row', const currentTextValues, const fieldId} => {
      let removedValue;
      const index = fieldCtx.read().findIndex((subfield) => {
        if (subfield.id === fieldId) {
          removedValue = subfield.field.value.value;
          return true;
        }
        return false;
      });
      if (nonEmpty(removedValue) &&
        currentTextValues.includes(removedValue)) {
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
        pushNewListItem(newStateCtx);
      }
    }
    {
      type: 'update-row',
      const currentTextValues,
      const fieldId,
      const value,
    } => {
      const index = fieldCtx.read().findIndex(
        (subfield) => subfield.id === fieldId,
      );
      const subFieldCtx = fieldCtx.get(index);
      const valueCtx = subFieldCtx.get('field', 'value', 'value');
      const oldValue = valueCtx.read();
      valueCtx.set(value);
      if (currentTextValues.includes(oldValue)) {
        pushCompoundField(newStateCtx, {removed: true, value: oldValue});
      }
    }
  }
}

export function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);

  runReducer(newStateCtx, action);

  return newStateCtx.final();
}

export component InnerFormRowTextList(
  addButtonId: string,
  addButtonLabel: string,
  currentTextValues: $ReadOnlyArray<string>,
  dispatch: (ActionT) => void,
  label: string,
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  removeButtonLabel: string,
  required: boolean = false,
  state: StateT,
) {
  const addRow = React.useCallback(() => {
    dispatch({type: 'add-row'});
  }, [dispatch]);

  return (
    <>
      <FormLabel label={label} required={required} />

      <div className="form-row-text-list">
        {state.field.map((field) => (
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
                currentTextValues={currentTextValues}
                dispatch={dispatch}
                field={field}
                key={field.id}
                onFocus={onFocus}
                removeButtonLabel={removeButtonLabel}
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

      <FieldErrors field={state} includeSubFields={false} />
    </>
  );
}

component FormRowTextList(
  rowRef?: {-current: HTMLDivElement | null},
  ...props: React.PropsOf<InnerFormRowTextList>
) {
  return (
    <FormRow rowRef={rowRef}>
      <InnerFormRowTextList {...props} />
    </FormRow>
  );
}

export default FormRowTextList;
