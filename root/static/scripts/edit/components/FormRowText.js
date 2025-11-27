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
  +autoComplete?: string,
  +className?: string,
  defaultValue?: string,
  +disabled: boolean,
  +id: string,
  +name: string,
  onChange?: InputOnChange,
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  +placeholder?: string,
  +ref?: {-current: HTMLInputElement | null},
  +required: boolean,
  +size: ?number,
  +type: string,
  value?: string,
};

type ControlledPropsT =
  | $ReadOnly<{onChange: InputOnChange, uncontrolled?: false}>
  | $ReadOnly<{uncontrolled: true}>;

component FormRowText(
  autoComplete?: string,
  children?: React.Node,
  className?: string,
  disabled: boolean = false,
  field: FieldT<?string>,
  inputRef?: {-current: HTMLInputElement | null},
  label: React.Node,
  placeholder?: string,
  preInput?: string,
  preview?: string | null = null,
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  required: boolean = false,
  rowRef?: {-current: HTMLDivElement | null},
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
    onFocus,
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
    <FormRow rowRef={rowRef}>
      <FormLabel forField={field} label={label} required={required} />
      {preInput}
      <input {...inputProps} />
      {children}
      <FieldErrors field={field} />
    </FormRow>
  );
}

export default FormRowText;
