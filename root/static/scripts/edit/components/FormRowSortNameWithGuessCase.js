/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRowText from '../../../../components/FormRowText';

/* eslint-disable flowtype/sort-keys */
export type ActionT =
  | {+type: 'guess-case-sortname'}
  | {+type: 'set-sortname', +sortName: string}
  | {+type: 'copy-sortname'};
/* eslint-enable flowtype/sort-keys */

type PropsT = {
  +disabled?: boolean,
  +dispatch: (ActionT) => void,
  +field: ReadOnlyFieldT<string | null>,
  +label?: string,
};

export const FormRowSortNameWithGuessCase = ({
  disabled = false,
  dispatch,
  field,
  label = addColonText(l('Sort name')),
}: PropsT): React.Element<typeof FormRowText> => {
  const handleSortNameChange = React.useCallback((
    event: SyntheticKeyboardEvent<HTMLInputElement>,
  ) => {
    dispatch({
      sortName: event.currentTarget.value,
      type: 'set-sortname',
    });
  }, [dispatch]);

  function handleGuessCase() {
    dispatch({type: 'guess-case-sortname'});
  }

  function handleSortNameCopy() {
    dispatch({type: 'copy-sortname'});
  }

  return (
    <FormRowText
      className="with-guesscase"
      disabled={disabled}
      field={field}
      label={label}
      onChange={handleSortNameChange}
      required
    >
      <button
        className="guesscase-title icon"
        disabled={disabled}
        onClick={handleGuessCase}
        title={l('Guess case')}
        type="button"
      />
      <button
        className="sortname-copy icon"
        disabled={disabled}
        onClick={handleSortNameCopy}
        title={l('Copy name')}
        type="button"
      />
    </FormRowText>
  );
};

export default FormRowSortNameWithGuessCase;
