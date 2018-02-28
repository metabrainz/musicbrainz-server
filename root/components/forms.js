// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const React = require('react');

const {addColon} = require('../static/scripts/common/i18n');

function createField(form, value) {
  const field = {
    errors: [],
    has_errors: false,
    // The field `id` is unique across all fields on the page. It's purpose
    // is for passing to `key` attributes on React elements.
    id: ++form.last_field_id,
  };
  if (value && typeof value === 'object') {
    if (Array.isArray(value)) {
      field.field = value.map(x => createField(form, x));
    } else {
      const fields = {};
      for (let key in value) {
        fields[key] = createField(form, value[key]);
      }
      field.field = fields;
    }
  } else {
    field.value = value;
  }
  return field;
}

function subfieldErrors(field, accum = []) {
  if (field.errors) {
    accum = accum.concat(field.errors);
  }
  if (field.field) {
    _.each(field.field, function (subfield) {
      accum = subfieldErrors(subfield, accum);
    });
  }
  return accum;
}

const buildErrorListItem = (error, index) => (
  <li key={index}>{error}</li>
);

const FieldErrors = ({field}) => {
  if (!field) {
    return null;
  }
  let errors = subfieldErrors(field);
  if (errors.length) {
    return (
      <ul className="errors">
        {errors.map(buildErrorListItem)}
      </ul>
    );
  }
  return null;
};

const FormRow = ({children, ...props}) => (
  <div className="row" {...props}>
    {children}
  </div>
);

function getValue(field, options, allowEmpty) {
  if (field.value != null) {
    return field.value;
  }
  if (allowEmpty) {
    return '';
  }
  let firstOption = options[0];
  if (firstOption.optgroup) {
    firstOption = firstOption.options[0];
  }
  return firstOption.value;
}

const buildOption = (option, index) => (
  <option key={index} value={option.value}>
    {option.label}
  </option>
);

const buildOptGroup = (optgroup, index) => (
  <optgroup key={index} label={optgroup.optgroup}>
    {optgroup.options.map(buildOption)}
  </optgroup>
);

const SelectField = ({
  allowEmpty = true,
  field,
  name,
  onChange,
  options,
}) => (
  <select
    className="with-button"
    name={name}
    onChange={onChange}
    value={getValue(field, options, allowEmpty)}>
    {allowEmpty
      ? <option value="">{'\xA0'}</option>
      : null}
    {options[0].optgroup
      ? options.map(buildOptGroup)
      : options.map(buildOption)}
  </select>
);

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
}) => (
  <div className="row">
    <label>{addColon(label)}</label>
    <div className="form-row-select-list">
      {repeatable.field.map((subfield, index) => (
        <div className="select-list-row" key={subfield.id}>
          <SelectField
            field={fieldName ? subfield.field[fieldName] : subfield}
            name={name + '.' + index + (fieldName ? '.' + fieldName : '')}
            onChange={event => onEdit(index, event.target.value)}
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
            field={fieldName ? subfield.field[fieldName] : subfield}
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

exports.createField = createField;
exports.FieldErrors = FieldErrors;
exports.FormRow = FormRow;
exports.FormRowSelectList = FormRowSelectList;
exports.subfieldErrors = subfieldErrors;
