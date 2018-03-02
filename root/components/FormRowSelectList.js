/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {addColon} from '../static/scripts/common/i18n';

import FieldErrors from './FieldErrors';
import SelectField from './SelectField';

type Props = {|
  +addId: string,
  +addLabel: string,
  +fieldName: string | null,
  +label: string,
  +name: string,
  +onAdd: (event: SyntheticEvent<HTMLButtonElement>) => void,
  +onEdit: (index: number, value: string) => void,
  +onRemove: (index: number) => void,
  +options: MaybeGroupedOptionsT,
  +removeClassName: string,
  +removeLabel: string,
  +repeatable: RepeatableFieldT<*>,
|};

const FormRowSelectList = ({
  addId,
  addLabel,
  fieldName,
  label,
  name,
  onAdd,
  onEdit,
  onRemove,
  options,
  removeClassName,
  removeLabel,
  repeatable,
}: Props) => (
  <div className="row">
    <label>{addColon(label)}</label>
    <div className="form-row-select-list">
      {repeatable.field.map((subfield, index) => (
        <div className="select-list-row" key={subfield.id}>
          <SelectField
            field={fieldName ? (subfield: any).field[fieldName] : subfield}
            name={name + '.' + index + (fieldName ? '.' + fieldName : '')}
            onChange={event => onEdit(index, event.currentTarget.value)}
            options={options}
          />
          {' '}
          <button
            className={`nobutton icon remove-item ${removeClassName}`}
            onClick={event => onRemove(index)}
            title={removeLabel}
            type="button"
          />
          <FieldErrors
            field={fieldName ? (subfield: any).field[fieldName] : subfield}
          />
        </div>
      ))}
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
    </div>
  </div>
);

export default FormRowSelectList;
