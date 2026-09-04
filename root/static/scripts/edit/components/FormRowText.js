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

type InputOnChange = (SyntheticInputEvent<HTMLInputElement>) => void;

type InputProps = {
  readonly autoComplete?: string,
  readonly className?: string,
  defaultValue?: string,
  readonly disabled: boolean,
  readonly id: string,
  readonly name: string,
  onChange?: InputOnChange,
  readonly placeholder?: string,
  readonly ref?: {writeonly current: HTMLInputElement | null},
  readonly required: boolean,
  readonly size: ?number,
  readonly type: string,
  value?: string,
};

type ControlledPropsT =
  | Readonly<{onChange: InputOnChange, uncontrolled?: false}>
  | Readonly<{uncontrolled: true}>;

component FormRowText(
  autoComplete?: string,
  children?: React.Node,
  className?: string,
  disabled: boolean = false,
  field: FieldT<?string>,
  inputRef?: {writeonly current: HTMLInputElement | null},
  label: React.Node,
  placeholder?: string,
  preview?: string | null = null,
  required: boolean = false,
  size?: number,
  type: string = 'text',
  ...controlledProps: ControlledPropsT
) {
  const inputProps: InputProps = {
    autoComplete,
    className,
    disabled,
    id: 'id-' + field.html_name,
    name: field.html_name,
    placeholder: placeholder ?? '',
    ref: inputRef,
    required,
    size,
    type,
  };

  const inputValue = preview ?? field.value ?? '';

  if (controlledProps.uncontrolled /*:: === true */) {
    inputProps.defaultValue = inputValue;
  } else {
    inputProps.onChange = controlledProps.onChange;
    inputProps.value = inputValue;
  }

  return (
    <FormRow>
      <FormLabel forField={field} label={label} required={required} />
      <input {...inputProps} />
      {children}
      <FieldErrors field={field} />
    </FormRow>
  );
}

export default FormRowText;
