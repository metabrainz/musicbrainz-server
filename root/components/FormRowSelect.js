/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import FormRow from './FormRow';
import FieldErrors from './FieldErrors';
import FormLabel from './FormLabel';
import SelectField from './SelectField';

type Props = {|
  +field: FieldT<number | string>,
  +label: string,
  +onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  +options: MaybeGroupedOptionsT,
  +required?: boolean,
|};

const FormRowSelect = ({
  field,
  label,
  onChange,
  options,
  required = false,
}: Props) => (
  <FormRow>
    <FormLabel forField={field} label={label} required={required} />
    <SelectField
      allowEmpty={!required}
      field={field}
      onChange={onChange}
      options={options}
    />
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowSelect;
