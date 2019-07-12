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
import PartialDateInput from './PartialDateInput';

type Props = {
  +field: PartialDateFieldT,
  +label: string,
  +onChangeDay?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  +onChangeMonth?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  +onChangeYear?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  +required?: boolean,
};

const FormRowPartialDate = ({
  field,
  label,
  required = false,
  onChangeDay,
  onChangeMonth,
  onChangeYear,
  ...inputProps
}: Props) => (
  <FormRow>
    <FormLabel
      forField={field.field.year}
      label={label}
      required={required}
    />
    <PartialDateInput
      field={field}
      onChangeDay={onChangeDay}
      onChangeMonth={onChangeMonth}
      onChangeYear={onChangeYear}
      {...inputProps}
    />
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowPartialDate;
