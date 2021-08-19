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
import GuessCase from '../../guess-case/MB/GuessCase/Main';

type SortNamedEntityT = {
  +entityType: CoreEntityTypeT,
  +typeID?: number | null,
  ...
};

/* eslint-disable flowtype/sort-keys */
export type ActionT =
  | {+type: 'guess-case-sortname', +entity: SortNamedEntityT}
  | {+type: 'set-sortname', +sortName: string}
  | {+type: 'copy-sortname'};
/* eslint-enable flowtype/sort-keys */

type PropsT = {
  +disabled?: boolean,
  +dispatch: (ActionT) => void,
  +entity: SortNamedEntityT,
  +field: ReadOnlyFieldT<string | null>,
  +label?: string,
  +required?: boolean,
};

export type StateT = {
  +nameField: ReadOnlyFieldT<string | null>,
  +sortNameField: ReadOnlyFieldT<string | null>,
};

export type WritableStateT = {
  +nameField: ReadOnlyFieldT<string | null>,
  sortNameField: FieldT<string | null>,
};

export function runReducer(
  newState: WritableStateT,
  action: ActionT,
) {
  switch (action.type) {
    case 'set-sortname': {
      newState.sortNameField.value = action.sortName;
      break;
    }
    case 'guess-case-sortname': {
      const {entityType, typeID} = action.entity;
      newState.sortNameField.value =
        GuessCase.entities[entityType].sortname(
          newState.nameField.value ?? '',
          typeID,
        );
      break;
    }
    case 'copy-sortname': {
      newState.sortNameField.value =
        newState.nameField.value ?? '';
      break;
    }
  }
}

export const FormRowSortNameWithGuessCase = ({
  disabled = false,
  dispatch,
  entity,
  field,
  label = addColonText(l('Sort name')),
  required = false,
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
    dispatch({entity, type: 'guess-case-sortname'});
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
      required={required}
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
