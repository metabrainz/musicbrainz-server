// @flow
import React from 'react';

import FormRow from './FormRow';
import FormLabel from './FormLabel';
import FieldErrors from './FieldErrors';

type Props = {
  +field: ReadOnlyFieldT<?string>,
  +label: string,
  +onChange?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  +required?: boolean,
};

const FormRowTime = ({field, label, required, ...inputProps}: Props) => {
  return (
    <FormRow>
      <FormLabel forField={field} label={label} required={required} />
      <input
        className="time"
        defaultValue={field.value || ''}
        id={'id-' + field.html_name}
        name={field.html_name}
        placeholder={l('HH:MM')}
        required={required}
        size={5}
        type="text"
        {...inputProps}
      />
      <FieldErrors field={field} />
    </FormRow>
  );
};

export default FormRowTime;
