/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';
import FormRow from './FormRow.js';
import PartialDateInput, {
  type ActionT as PartialDateInputActionT,
  runReducer as runPartialDateInputReducer,
} from './PartialDateInput.js';

export type ActionT = PartialDateInputActionT;

type CommonProps = {
  +children?: React.Node,
  +disabled?: boolean,
  +field: PartialDateFieldT,
  +label: string,
  +required?: boolean,
  +yearInputRef?: {current: HTMLInputElement | null},
};

type Props =
  | $ReadOnly<{
      ...CommonProps,
      +dispatch: (PartialDateInputActionT) => void,
      +uncontrolled?: false,
    }>
  | $ReadOnly<{
      ...CommonProps,
      +uncontrolled: true,
    }>;

export type StateT = PartialDateFieldT;

export type WritableStateT = WritablePartialDateFieldT;

export const runReducer = runPartialDateInputReducer;

const FormRowPartialDate = ({
  children,
  disabled = false,
  field,
  label,
  required = false,
  ...inputProps
}: Props): React.Element<typeof FormRow> => (
  <FormRow>
    <FormLabel
      forField={field.field.year}
      label={label}
      required={required}
    />
    <PartialDateInput
      disabled={disabled}
      field={field}
      {...inputProps}
    />
    {children}
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowPartialDate;
