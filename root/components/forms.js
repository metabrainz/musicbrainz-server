// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const Immutable = require('immutable');
const _ = require('lodash');
const React = require('react');

const {addColon} = require('../static/scripts/common/i18n');

const Form = Immutable.Record({
  field: Immutable.Map(),
  has_errors: false,
  name: '',
});

const RepeatableField = Immutable.Record({
  errors: Immutable.List(),
  field: Immutable.List(),
  has_errors: false,
  // The field `id` is unique across all fields on the page. It's purpose is
  // for passing to `key` attributes on React elements.
  id: 0,
});

const CompoundField = Immutable.Record({
  errors: Immutable.List(),
  field: Immutable.Map(),
  has_errors: false,
  id: 0,
});

const Field = Immutable.Record({
  errors: Immutable.List(),
  has_errors: false,
  id: 0,
  value: null,
});

let FIELD_ID_COUNTER = 0;

function _formFromHash(key, value, path) {
  switch (key) {
    case '':
      return new Form(value);

    case 'errors':
      return value.toList();

    case 'field':
      return Immutable.isIndexed(value) ?
        value.toList() : value.toMap();

    default:
      if (value.has('field')) {
        value = Immutable.isIndexed(value.get('field')) ?
          (new RepeatableField(value)) : (new CompoundField(value));
      } else if (value.has('value')) {
        value = new Field(value);
      } else {
        return null;
      }
      return value.set('id', ++FIELD_ID_COUNTER);
  }
}

function formFromHash(form) {
  return Immutable.fromJS(form, _formFromHash);
}

function createField(value) {
  const id = ++FIELD_ID_COUNTER;
  if (value && typeof value === 'object') {
    if (Array.isArray(value)) {
      return new RepeatableField({
        field: Immutable.List(value.map(createField)),
        id,
      });
    }
    const fields = {};
    for (let key in value) {
      fields[key] = createField(value[key]);
    }
    return new CompoundField({field: Immutable.Map(fields), id});
  }
  return new Field({id, value});
}

function subfieldErrors(field, accum = Immutable.List()) {
  if (field.has('field')) {
    for (let subfield of field.field.values()) {
      if (subfield.errors) {
        accum = accum.concat(subfield.errors);
      }
      accum = subfieldErrors(subfield, accum);
    }
  }
  return accum;
}

const FieldErrors = ({field}) => {
  if (!field) {
    return null;
  }
  let errors = subfieldErrors(field);
  if (field.errors) {
    errors = field.errors.concat(errors);
  }
  if (errors.size) {
    return (
      <ul className="errors">
        <For each="error" of={errors.toArray()}>
          <li>{error}</li>
        </For>
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

function selectOptions(options) {
  return (
    <For each="option" index="index" of={options}>
      <option key={index} value={option.value}>
        {option.label}
      </option>
    </For>
  );
}

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
    <If condition={allowEmpty}>
      <option value="">{'\xA0'}</option>
    </If>
    <If condition={options[0].optgroup}>
      <For each="optgroup" index="index" of={options}>
        <optgroup key={index} label={optgroup.optgroup}>
          {selectOptions(optgroup.options)}
        </optgroup>
      </For>
    <Else />
      {selectOptions(options)}
    </If>
  </select>
);

const FormRowSelectList = ({
  addLabel,
  fieldName,
  label,
  name,
  onAdd,
  onEdit,
  onRemove,
  options,
  removeLabel,
  repeatable,
}) => (
  <div className="row">
    <label>{addColon(label)}</label>
    <div className="form-row-select-list">
      <For each="subfield" index="index" of={repeatable.field.toArray()}>
        <div className="select-list-row" key={subfield.id}>
          <SelectField
            field={fieldName ? subfield.field.get(fieldName) : subfield}
            name={name + '.' + index + (fieldName ? '.' + fieldName : '')}
            onChange={event => onEdit(index, event.target.value)}
            options={options}
          />
          {' '}
          <button
            className="nobutton icon remove-item"
            onClick={event => onRemove(index)}
            title={removeLabel}
            type="button"
          />
          <FieldErrors
            field={fieldName ? subfield.field.get(fieldName) : subfield}
          />
        </div>
      </For>
      <div className="form-row-add">
        <button
          className="with-label add-item"
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
exports.formFromHash = formFromHash;
exports.FormRow = FormRow;
exports.FormRowSelectList = FormRowSelectList;
