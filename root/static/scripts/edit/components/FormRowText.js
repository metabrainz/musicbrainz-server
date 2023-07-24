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

type InputOnChange = (SyntheticKeyboardEvent<HTMLInputElement>) => void;

type InputProps = {
  +autoComplete?: string,
  +className?: string,
  defaultValue?: string,
  +disabled: boolean,
  +id: string,
  +name: string,
  onChange?: InputOnChange,
  +required: boolean,
  +size: ?number,
  +type: string,
  value?: string,
};

type CommonProps = {
  +autoComplete?: string,
  +children?: React$Node,
  +className?: string,
  +disabled?: boolean,
  +field: ReadOnlyFieldT<?string>,
  +label: string,
  +required?: boolean,
  +size?: number,
  +type?: string,
};

export type Props =
  | $ReadOnly<{
      ...CommonProps,
      onChange: InputOnChange,
      uncontrolled?: false,
    }>
  | $ReadOnly<{
      ...CommonProps,
      uncontrolled: true,
    }>;

const FormRowText = (props: Props): React$Element<typeof FormRow> => {
  const field = props.field;
  const required = props.required ?? false;

  const inputProps: InputProps = {
    autoComplete: props.autoComplete,
    className: props.className,
    disabled: props.disabled ?? false,
    id: 'id-' + field.html_name,
    name: field.html_name,
    required: required,
    size: props.size,
    type: props.type ?? 'text',
  };

  const inputValue = field.value ?? '';

  if (props.uncontrolled /*:: === true */) {
    inputProps.defaultValue = inputValue;
  } else {
    inputProps.onChange = props.onChange;
    inputProps.value = inputValue;
  }

  return (
    <FormRow>
      <FormLabel forField={field} label={props.label} required={required} />
      <input {...inputProps} />
      {props.children}
      <FieldErrors field={field} />
    </FormRow>
  );
};

export default FormRowText;
