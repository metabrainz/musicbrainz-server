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
import FormLabel from './FormLabel';

type Props = {
  +field: FieldT<string>,
  +label: string,
  +required?: boolean,
};

const FormRowText = ({
  field,
  label,
  required = false,
  ...inputProps
}: Props) => (
  <FormRow>
    <FormLabel forField={field} label={label} required={required} />
    <input
      defaultValue={field.value}
      id={'id-' + field.html_name}
      name={field.html_name}
      type="text"
      {...inputProps}
    />
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowText;
