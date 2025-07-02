/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import SearchIcon from '../../common/components/SearchIcon.js';
import {last} from '../../common/utility/arrays.js';

import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';
import FormRow from './FormRow.js';

component FormRowArea(
  children ?: React.Node,
  disabled: boolean = false,
  field: AreaFieldT,
  idField: FieldT<string>,
  label: React.Node,
  required: boolean = false,
) {
  const subfields = field.field;

  return (
    <FormRow>
      <FormLabel
        forField={subfields.name}
        label={label}
        required={required}
      />
      <span
        className="area autocomplete"
        disabled={disabled}
        id={last(field.html_name.split('.'))}
      >
        <SearchIcon />
        <input
          className={'gid' + (subfields.gid.has_errors ? ' error' : '')}
          defaultValue={subfields.gid.value}
          id={'id-' + subfields.gid.html_name}
          name={subfields.gid.html_name}
          type="hidden"
        />
        <input
          className={'id' + (idField.has_errors ? ' error' : '')}
          defaultValue={idField.value}
          id={'id-' + idField.html_name}
          name={idField.html_name}
          type="hidden"
        />
        <input
          className={'name' + (subfields.name.has_errors ? ' error' : '')}
          defaultValue={subfields.name.value}
          id={'id-' + subfields.name.html_name}
          name={subfields.name.html_name}
          type="text"
        />
      </span>
      {children}
      <FieldErrors field={field} />
    </FormRow>
  );
}

export default FormRowArea;
