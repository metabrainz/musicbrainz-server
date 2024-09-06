/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React, {useState} from 'react';

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

const initialRows = (repeatable: RepeatableFieldT<FieldT<string>>) => {
  if (repeatable.field.length === 0) {
    return [{name: repeatable.html_name + '.0', value: ''}];
  }

  return repeatable.field.map((field, index) => ({
    name: repeatable.html_name + '.' + index,
    value: field.value ?? '',
  }));
};

component FormRowTextList(
  addButtonLabel: string,
  label: string,
  removeButtonLabel: string,
  repeatable: RepeatableFieldT<FieldT<string>>,
  required: boolean = false,
) {
  const newRow = (name: string, value: string, index: number) => {
    return {name: name + '.' + index, value};
  };

  const [rows, setRows] = useState(initialRows(repeatable));

  const addRow = () => {
    const index = rows.length;

    setRows([...rows, newRow(repeatable.html_name, '', index)]);
  };

  const changeRow = (index: number, value: string) => {
    const newRows = [...rows];
    newRows[index] = newRow(repeatable.html_name, value, index);
    setRows(newRows);
  };

  const removeRow = (index: number) => {
    if (rows.length === 1) {
      setRows([newRow(repeatable.html_name, '', 0)]);
      return;
    }

    const newRows = [...rows];
    newRows.splice(index, 1);
    setRows(newRows);
  };

  return (
    <>
      <FormLabel forField={repeatable} label={label} required={required} />

      <div className="form-row-text-list">
        {rows.map((field, index) => (
          <TextListRow
            key={index}
            name={field.name}
            onChange={(event) => changeRow(index, event.currentTarget.value)}
            onRemove={() => removeRow(index)}
            removeButtonLabel={removeButtonLabel}
            value={field.value}
          />
        ))}

        <div className="form-row-add">
          <AddButton label={addButtonLabel} onClick={addRow} />
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
