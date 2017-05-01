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

function _formFromHash(key, value, path) {
  switch (key) {
    case '':
      return new Form(value);

    case 'errors':
      return value.toList();

    case 'field':
      return Immutable.Iterable.isIndexed(value) ?
        value.toList() : value.toMap();

    default:
      if (value.has('field')) {
        value = Immutable.Iterable.isIndexed(value.get('field')) ?
          (new RepeatableField(value)) : (new CompoundField(value));
      } else if (value.has('value')) {
        value = new Field(value);
      } else {
        return null;
      }
      return value;
  }
}

function formFromHash(form) {
  return Immutable.fromJS(form, _formFromHash);
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

exports.FieldErrors = FieldErrors;
exports.formFromHash = formFromHash;
exports.FormRow = FormRow;
