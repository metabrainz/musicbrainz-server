/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';
import * as React from 'react';

import {ARTIST_TYPE_PERSON} from '../../common/constants.js';
import GuessCase from '../../guess-case/MB/GuessCase/Main.js';

import FormRowText from './FormRowText.js';

type SortNamedEntityT = {
  +entityType: EditableEntityTypeT,
  +typeID?: number | null,
  ...
};

/* eslint-disable ft-flow/sort-keys */
export type ActionT =
  | {+type: 'guess-case-sortname', +entity: SortNamedEntityT}
  | {+type: 'set-sortname', +sortName: string}
  | {+type: 'copy-sortname'};
/* eslint-enable ft-flow/sort-keys */

export type StateT = {
  +nameField: FieldT<string | null>,
  +sortNameField: FieldT<string | null>,
};

export function runReducer(
  newState: CowContext<StateT>,
  action: ActionT,
) {
  switch (action.type) {
    case 'set-sortname': {
      newState.set('sortNameField', 'value', action.sortName);
      break;
    }
    case 'guess-case-sortname': {
      newState.set(
        'sortNameField', 'value',
        guessSortName(newState.read().nameField.value ?? '', action.entity),
      );
      break;
    }
    case 'copy-sortname': {
      newState.set(
        'sortNameField', 'value',
        newState.read().nameField.value ?? '',
      );
      break;
    }
  }
}

component FormRowSortNameWithGuessCase(
  disabled: boolean = false,
  dispatch: (ActionT) => void,
  entity: SortNamedEntityT,
  sortNameField: FieldT<string | null>,
  nameField: FieldT<string | null>,
  label: React$Node = addColonText(l('Sort name')),
  required: boolean = false,
) {
  const [preview, setPreview] = React.useState<string | null>(null);

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
    setPreview(null);
  }

  function showGuessCasePreview() {
    setPreview(guessSortName(nameField.value ?? '', entity));
  }

  function handleSortNameCopy() {
    dispatch({type: 'copy-sortname'});
    setPreview(null);
  }

  function showSortNameCopyPreview() {
    setPreview(nameField.value ?? '');
  }

  function hidePreview() {
    setPreview(null);
  }

  const previewDiffers = preview !== null && preview !== sortNameField.value;

  return (
    <FormRowText
      className={'with-guesscase' + (previewDiffers ? ' preview' : '')}
      disabled={disabled}
      field={sortNameField}
      label={label}
      onChange={handleSortNameChange}
      preview={preview}
      required={required}
    >
      <button
        className="guesscase-sortname icon"
        disabled={disabled}
        onClick={handleGuessCase}
        onMouseEnter={showGuessCasePreview}
        onMouseLeave={hidePreview}
        title={l('Guess sort name')}
        type="button"
      />
      <button
        className="sortname-copy icon"
        disabled={disabled}
        onClick={handleSortNameCopy}
        onMouseEnter={showSortNameCopyPreview}
        onMouseLeave={hidePreview}
        title={l('Copy name')}
        type="button"
      />
    </FormRowText>
  );
}

export default FormRowSortNameWithGuessCase;

function guessSortName(name: string, entity: SortNamedEntityT): string {
  const isPerson =
    entity.entityType === 'artist' && entity.typeID === ARTIST_TYPE_PERSON;
  return GuessCase.entities[entity.entityType].sortname(name, isPerson);
}
