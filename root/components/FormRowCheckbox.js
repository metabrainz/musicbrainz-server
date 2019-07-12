/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import FieldErrors from './FieldErrors';
import FormRow from './FormRow';

type Props = {|
  +disabled?: boolean,
  +field: ReadOnlyFieldT<boolean>,
  +label: string,
  +onChange?: (event: SyntheticEvent<HTMLInputElement>) => void,
|};

const FormRowCheckbox = ({field, label, onChange, ...inputProps}: Props) => (
  <FormRow hasNoLabel>
    <label className="inline">
      <input
        defaultChecked={field.value}
        name={field.html_name}
        onChange={onChange}
        type="checkbox"
        value="1"
        {...inputProps}
      />
      {' '}
      {label}
    </label>
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowCheckbox;
