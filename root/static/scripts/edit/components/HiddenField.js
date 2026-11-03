/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

function serializeFieldValue(value: unknown): string {
  if (value == null) {
    return '';
  }
  if (typeof value === 'boolean') {
    return value ? '1' : '0';
  }
  return String(value);
}

component HiddenField(field: FieldT<unknown>, value?: string) {
  return (
    <input
      name={field.html_name}
      type="hidden"
      value={value ?? serializeFieldValue(field.value)}
    />
  );
}

component _HiddenFields(field: AnyFieldT) {
  return match (field) {
    {type: 'compound_field', ...} as compoundField => (
      Object.values(compoundField.field).map((subfield) => (
        <HiddenFields field={subfield} key={subfield.html_name} />
      ))
    ),
    {type: 'field', ...} as scalarField => (
      <HiddenField field={scalarField} />
    ),
    {type: 'repeatable_field', ...} as repeatableField => (
      repeatableField.field.map((subfield) => (
        subfield == null
          ? null
          : <HiddenFields field={subfield} key={subfield.html_name} />
      ))
    )
  };
}

const HiddenFields: component(field: AnyFieldT) = React.memo(_HiddenFields);

export default HiddenField;

export {HiddenFields};
