// @flow

import React from 'react';

import FormRow from './FormRow';
import FormLabel from './FormLabel';
import FieldErrors from './FieldErrors';

type Props = {
  field: FieldT<string>,
  onChange: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  onPressGuessCaseCopy: (e: SyntheticEvent<HTMLButtonElement>) => void,
  onPressGuessCaseSortName: (e: SyntheticEvent<HTMLButtonElement>) => void,
  required?: boolean,
};

const FormRowSortNameWithGuessCase = ({
  field,
  required = false,
  onChange,
  onPressGuessCaseSortName,
  onPressGuessCaseCopy,
  ...inputProps
}: Props) => {
  return (
    <FormRow>
      <FormLabel
        forField={field}
        label={l('Sort name:')}
        required={required}
      />
      <input
        className="with-guesscase"
        id={'id-' + field.html_name}
        name={field.html_name}
        // eslint-disable-next-line react/jsx-no-bind
        onChange={onChange}
        required={required}
        type="text"
        value={field.value}
        {...inputProps}
      />
      {' '}
      <button
        className="guesscase-sortname icon"
        // eslint-disable-next-line react/jsx-no-bind
        onClick={onPressGuessCaseSortName}
        title={l('Guess sort name')}
        type="button"
      />
      {' '}
      <button
        className="sortname-copy icon"
        // eslint-disable-next-line react/jsx-no-bind
        onClick={onPressGuessCaseCopy}
        title={l('Copy name')}
        type="button"
      />
      <FieldErrors field={field} />
    </FormRow>
  );
};

export default FormRowSortNameWithGuessCase;
