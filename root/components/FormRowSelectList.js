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

type Props<S> = {|
  +addId: string,
  +addLabel: string,
  +getSelectField: (S) => FieldT<number | string>,
  +label: string,
  +onAdd: (event: SyntheticEvent<HTMLButtonElement>) => void,
  +onEdit: (index: number, value: string) => void,
  +onRemove: (index: number) => void,
  +options: MaybeGroupedOptionsT,
  +removeClassName: string,
  +removeLabel: string,
  +repeatable: RepeatableFieldT<S>,
|};

const FormRowSelectList = <F, S: AnyFieldT<F>>({
  addId,
  addLabel,
  getSelectField,
  label,
  onAdd,
  onEdit,
  onRemove,
  options,
  removeClassName,
  removeLabel,
  repeatable,
}: Props<S>) => (
  <div className="row">
    <label>{addColon(label)}</label>
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
            onClick={event => onRemove(index)}
            title={removeLabel}
            type="button"
          />
          <FieldErrors field={getSelectField(subfield)} />
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
