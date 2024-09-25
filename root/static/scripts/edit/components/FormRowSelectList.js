/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import SelectField from '../../common/components/SelectField.js';

import AddButton from './AddButton.js';
import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';

component FormRowSelectList<S: {+id: number, ...}>(
  addId: string,
  addLabel: string,
  getSelectField: (S) => FieldT<?StrOrNum>,
  hideAddButton: boolean = false,
  label: React.Node,
  onAdd: (event: SyntheticEvent<HTMLButtonElement>) => void,
  onEdit: (index: number, value: string) => void,
  onRemove: (index: number) => void,
  options: MaybeGroupedOptionsT,
  removeClassName: string,
  removeLabel: string,
  repeatable: RepeatableFieldT<S>,
) {
  return (
    <FormRow>
      <label>{label}</label>
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
            <AddButton
              id={addId}
              label={addLabel}
              onClick={onAdd}
            />
          </div>
        )}
      </div>
    </FormRow>
  );
}

export default FormRowSelectList;
