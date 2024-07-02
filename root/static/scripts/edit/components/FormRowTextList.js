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

type TextListRowProps = {
  +index?: number,
  +name: string,
  +onChange?: (event: SyntheticEvent<HTMLInputElement>) => void,
  +onRemove?: (event: SyntheticEvent<HTMLInputElement>) => void,
  +template?: boolean,
  +value?: string,
};

component TextListRow(...{
  index = 0,
  name,
  onChange = () => {},
  onRemove = () => {},
  template = false,
  value = '',
}: TextListRowProps) {
  if (template) {
    return (
      <div
        className={`text-list-row ${name}-template`}
        style={{display: 'none'}}
      >
        <input className="value with-button" type="text" value="" />
        <RemoveButton
          dataIndex={index}
          onClick={onRemove}
          title={l('Remove item')}
        />
      </div>
    );
  }

  return (
    <div className="text-list-row">
      <input
        className="value with-button"
        name={name}
        onChange={onChange}
        type="text"
        value={value}
      />
      <RemoveButton onClick={onRemove} title={l('Remove item')} />
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
  repeatable: RepeatableFieldT<FieldT<string>>,
  label: string,
  itemName: string,
  required: boolean = false,
) {
  const newRow = (name: string, value: string, index: number) => {
    return {name: name + '.' + index, value};
  };

  const [rows, setRows] = useState(initialRows(repeatable));

  const add = () => {
    const index = rows.length;

    setRows([...rows, newRow(repeatable.html_name, '', index)]);
  };

  const change = (index: number, value: string) => {
    const newRows = [...rows];
    newRows[index] = newRow(repeatable.html_name, value, index);
    setRows(newRows);
  };

  const removeRow = (index: number) => {
    if (rows.length === 1) {
      setRows([newRow(repeatable.html_name, '', 0)]);
      return;
    }

    setRows(rows.filter((_, i) => i !== index));
  };

  return (
    <FormRow>
      <FormLabel forField={repeatable} label={label} required={required} />

      <div className="form-row-text-list">
        <TextListRow
          name={repeatable.html_name}
          template
        />

        {rows.map((field, index) => (
          <TextListRow
            key={index}
            name={field.name}
            onChange={(event) => change(index, event.currentTarget.value)}
            onRemove={() => removeRow(index)}
            value={field.value}
          />
        ))}

        <div className="form-row-add">
          <AddButton label={`Add ${itemName}`} onClick={add} />
        </div>
      </div>

      <FieldErrors field={repeatable} />
    </FormRow>
  );
}

export default FormRowTextList;
