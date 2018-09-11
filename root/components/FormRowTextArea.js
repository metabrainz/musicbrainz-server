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
  +cols?: number,
  +field: FieldT<string>,
  +label: string,
  +required?: boolean,
  +rows?: number,
};

const FormRowTextArea = ({
  cols = 80,
  field,
  label,
  required = false,
  rows = 5,
  ...textareaProps
}: Props) => (
  <FormRow>
    <FormLabel forField={field} label={label} required={required} />
    <textarea
      cols={cols}
      defaultValue={field.value}
      id={'id-' + field.html_name}
      name={field.html_name}
      required={required}
      rows={rows}
      {...textareaProps}
    />
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowTextArea;
