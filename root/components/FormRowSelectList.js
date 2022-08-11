/*
 * @flow strict-local
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';
import SelectField from './SelectField.js';

type Props<S> = {
  +addId: string,
  +addLabel: string,
  +getSelectField: (S) => ReadOnlyFieldT<?StrOrNum>,
  +hideAddButton?: boolean,
  +label: string,
  +onAdd: (event: SyntheticEvent<HTMLButtonElement>) => void,
  +onEdit: (index: number, value: string) => void,
  +onRemove: (index: number) => void,
  +options: MaybeGroupedOptionsT,
  +removeClassName: string,
  +removeLabel: string,
  +repeatable: ReadOnlyRepeatableFieldT<S>,
};

const FormRowSelectList = <S: {+id: number, ...}>({
  addId,
  addLabel,
  getSelectField,
  hideAddButton = false,
  label,
  onAdd,
  onEdit,
  onRemove,
  options,
  removeClassName,
  removeLabel,
  repeatable,
}: Props<S>): React.Element<typeof FormRow> => (
  <FormRow>
    <label>{addColonText(label)}</label>
    <div className="form-row-select-list">
      {repeatable.field.map((subfield, index) => (
        <div className="select-list-row" key={subfield.id}>
          <SelectField
            field={getSelectField(subfield)}
            onChange={event => onEdit(index, event.currentTarget.value)}
            options={options}
          />
          {' '}
          <button
            className={`nobutton icon remove-item ${removeClassName}`}
            onClick={() => onRemove(index)}
            title={removeLabel}
            type="button"
          />
          <FieldErrors field={getSelectField(subfield)} />
        </div>
      ))}
      {hideAddButton ? null : (
        <div className="form-row-add">
          <button
            className="with-label add-item"
            id={addId}
            onClick={onAdd}
            type="button"
          >
            {addLabel}
          </button>
        </div>
      )}
    </div>
  </FormRow>
);

export default FormRowSelectList;
