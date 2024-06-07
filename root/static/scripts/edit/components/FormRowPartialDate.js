/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';
import FormRow from './FormRow.js';
import PartialDateInput, {
  type ActionT as PartialDateInputActionT,
  runReducer as runPartialDateInputReducer,
} from './PartialDateInput.js';

export type ActionT = PartialDateInputActionT;

type ControlledPropsT =
  | $ReadOnly<{
      +dispatch: (PartialDateInputActionT) => void,
      +uncontrolled?: false,
    }>
  | $ReadOnly<{+uncontrolled: true}>;

export type StateT = PartialDateFieldT;

export const runReducer = runPartialDateInputReducer;

component FormRowPartialDate(
  children?: React.Node,
  disabled: boolean = false,
  field: PartialDateFieldT,
  label: React.Node,
  required: boolean = false,
  yearInputRef?: {current: HTMLInputElement | null},
  ...controlledProps: ControlledPropsT
) {
  return (
    <FormRow>
      <FormLabel
        forField={field.field.year}
        label={label}
        required={required}
      />
      <PartialDateInput
        disabled={disabled}
        field={field}
        yearInputRef={yearInputRef}
        {...controlledProps}
      />
      {children}
      <FieldErrors field={field} />
    </FormRow>
  );
}

export default FormRowPartialDate;
