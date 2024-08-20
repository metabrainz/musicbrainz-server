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

type TextAreaOnChange =
  (SyntheticKeyboardEvent<HTMLTextAreaElement>) => void;

type TextAreaProps = {
  +cols: number,
  defaultValue?: string,
  +id: string,
  +name: string,
  onChange?: TextAreaOnChange,
  +required: boolean,
  +rows: number,
  value?: string,
};

type ControlledPropsT =
  | $ReadOnly<{onChange: TextAreaOnChange, uncontrolled?: false}>
  | $ReadOnly<{uncontrolled: true}>;

component FormRowTextArea(
  cols: number = 80,
  field: FieldT<string>,
  label: React.Node,
  required: boolean = false,
  rows: number = 5,
  ...controlledProps: ControlledPropsT
) {
  const textAreaProps: TextAreaProps = {
    cols,
    id: 'id-' + field.html_name,
    name: field.html_name,
    required,
    rows,
  };
  if (controlledProps.uncontrolled /*:: === true */) {
    textAreaProps.defaultValue = field.value;
  } else {
    textAreaProps.onChange = controlledProps.onChange;
    textAreaProps.value = field.value;
  }
  return (
    <FormRow>
      <FormLabel forField={field} label={label} required={required} />
      <textarea {...textAreaProps} />
      <FieldErrors field={field} />
    </FormRow>
  );
}

export default FormRowTextArea;
