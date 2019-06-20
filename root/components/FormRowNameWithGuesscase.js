// @flow

import React from 'react';

import FormRow from './FormRow';
import FormLabel from './FormLabel';
import FieldErrors from './FieldErrors';

type Props = {
  field: FieldT<string>,
  onChangeInput?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  onPressGuessCaseOptions?: (e: SyntheticEvent<HTMLSelectElement>) => void,
  onPressGuessCaseTitle?: (e: SyntheticEvent<HTMLSelectElement>) => void,
  options: {
    guessfeat?: string,
    label?: string,
  },
  required?: boolean,
};

const FormRowNameWithGuesscase = ({
  field,
  options,
  required = false,
  onChangeInput,
  onPressGuessCaseTitle,
  onPressGuessCaseOptions,
  ...inputProps
}: Props) => {
  return (
    <FormRow>
      <FormLabel
        forField={field}
        label={options.label ? options.label : l('Alias name:')}
        required={required}
      />
      <input
        className={options.guessfeat ? 'with-guesscase-guessfeat' : 'with-guesscase'}
        id={'id-' + field.html_name}
        name={field.html_name}
        // eslint-disable-next-line react/jsx-no-bind
        onChange={onChangeInput}
        required={required}
        type="text"
        value={field.value}
        {...inputProps}
      />
      {' '}
      <button
        className="guesscase-title icon"
        // eslint-disable-next-line react/jsx-no-bind
        onClick={onPressGuessCaseTitle}
        title={l('Guess case')}
        type="button"
      />
      {options.guessfeat ? (
        <>
          {' '}
          <button className="guessfeat icon" title={l('Guess feat. artists')} type="button" />
        </>
      ) : null}
      {' '}
      <button
        className="guesscase-options icon"
        // eslint-disable-next-line react/jsx-no-bind
        onClick={onPressGuessCaseOptions}
        title={l('Guess case options')}
        type="button"
      />
      <FieldErrors field={field} />
    </FormRow>
  );
};

export default FormRowNameWithGuesscase;
