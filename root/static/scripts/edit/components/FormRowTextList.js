/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import React, {useState} from 'react';

import {pushField} from '../utility/pushField.js';

import AddButton from './AddButton.js';
import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';
import FormRow from './FormRow.js';
import RemoveButton from './RemoveButton.js';

component TextListRow(
  name: string,
  onChange: (event: SyntheticEvent<HTMLInputElement>) => void,
  onRemove: (event: SyntheticEvent<HTMLInputElement>) => void,
  removeButtonLabel: string,
  value: string,
) {
  return (
    <div className="text-list-row">
      <input
        className="value with-button"
        name={name}
        onChange={onChange}
        type="text"
        value={value}
      />
      <RemoveButton onClick={onRemove} title={removeButtonLabel} />
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

component FormRowTextList(
  addButtonLabel: string,
  addButtonId: string,
  label: string,
  removeButtonLabel: string,
  repeatable: RepeatableFieldT<FieldT<string>>,
  required: boolean = false,
) {
  const [compoundField, setCompoundField] =
    useState(createInitialState(repeatable));

  const addRow = () => {
    const newField = mutate(compoundField).update((fieldCtx) => {
      pushField(fieldCtx, '');
    }).final();

    setCompoundField(newField);
  };

  const changeRow = (id: number, value: string) => {
    const index = compoundField.field.findIndex(
      (subfield) => subfield.id === id,
    );

    const newField = mutate(compoundField)
      .set('field', index, 'value', value)
      .final();
    setCompoundField(newField);
  };

  const removeRow = (id: number) => {
    const index = compoundField.field.findIndex(
      (subfield) => subfield.id === id,
    );

    if (compoundField.field.length === 1) {
      const newField = mutate(compoundField)
        .set('field', index, 'value', '')
        .final();

      setCompoundField(newField);

      return;
    }

    const newField = mutate(compoundField).update('field', (fieldCtx) => {
      fieldCtx.write().splice(index, 1);
    }).final();

    setCompoundField(newField);
  };

  return (
    <>
      <FormLabel forField={repeatable} label={label} required={required} />

      <div className="form-row-text-list">
        {compoundField.field.map((field) => (
          <TextListRow
            key={field.id}
            name={field.html_name}
            onChange={(event) => changeRow(
              field.id,
              event.currentTarget.value,
            )}
            onRemove={() => removeRow(field.id)}
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
): React.AbstractComponent<React.PropsOf<FormRowTextList>, void>);
