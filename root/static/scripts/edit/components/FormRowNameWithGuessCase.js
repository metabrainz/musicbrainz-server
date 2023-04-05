/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import GuessCase from '../../guess-case/MB/GuessCase/Main.js';

import FormRowText from './FormRowText.js';
import {
  type ActionT as GuessCaseOptionsActionT,
  type StateT as GuessCaseOptionsStateT,
  type WritableStateT as WritableGuessCaseOptionsStateT,
  createInitialState as createGuessCaseOptionsState,
  runReducer as runGuessCaseOptionsReducer,
} from './GuessCaseOptions.js';
import GuessCaseOptionsPopover from './GuessCaseOptionsPopover.js';

type NamedEntityT = {
  +entityType: EditableEntityTypeT,
  +name: string,
  ...
};

/* eslint-disable flowtype/sort-keys */
export type ActionT =
  | {+type: 'guess-case', +entity: NamedEntityT}
  | {+type: 'open-guess-case-options'}
  | {+type: 'close-guess-case-options'}
  | {+type: 'update-guess-case-options', +action: GuessCaseOptionsActionT}
  | {+type: 'set-name', +name: string};
/* eslint-enable flowtype/sort-keys */

type PropsT = {
  +dispatch: (ActionT) => void,
  +entity: NamedEntityT,
  +field: ReadOnlyFieldT<string | null>,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +guessFeat?: boolean,
  +isGuessCaseOptionsOpen: boolean,
  +label?: string,
};

export type StateT = {
  +field: ReadOnlyFieldT<string | null>,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
};

export type WritableStateT = {
  ...StateT,
  field: FieldT<string | null>,
  guessCaseOptions: WritableGuessCaseOptionsStateT,
};

export function createInitialState(
  field: ReadOnlyFieldT<string | null>,
): StateT {
  return {
    field,
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
  };
}

export function runReducer(
  newState: WritableStateT,
  action: ActionT,
): void {
  switch (action.type) {
    case 'guess-case': {
      newState.field.value =
        GuessCase.entities[action.entity.entityType].guess(
          newState.field.value ?? '',
        );
      break;
    }
    case 'open-guess-case-options': {
      newState.isGuessCaseOptionsOpen = true;
      break;
    }
    case 'close-guess-case-options': {
      newState.isGuessCaseOptionsOpen = false;
      break;
    }
    case 'update-guess-case-options': {
      runGuessCaseOptionsReducer(
        newState.guessCaseOptions,
        action.action,
      );
      break;
    }
    case 'set-name': {
      newState.field.value = action.name;
      break;
    }
  }
}

export const FormRowNameWithGuessCase = ({
  dispatch,
  entity,
  field,
  guessCaseOptions,
  guessFeat = false,
  isGuessCaseOptionsOpen = false,
  label = addColonText(l('Name')),
}: PropsT): React$Element<typeof FormRowText> => {
  function handleNameChange(event: SyntheticKeyboardEvent<HTMLInputElement>) {
    dispatch({
      name: event.currentTarget.value,
      type: 'set-name',
    });
  }

  function handleGuessCase() {
    dispatch({entity, type: 'guess-case'});
  }

  const toggleGuessCaseOptions = React.useCallback((
    open: boolean,
  ) => {
    if (open) {
      dispatch({type: 'open-guess-case-options'});
    } else {
      dispatch({type: 'close-guess-case-options'});
    }
  }, [dispatch]);

  const guessCaseOptionsDispatch = React.useCallback(
    (action: GuessCaseOptionsActionT) => {
      dispatch({action, type: 'update-guess-case-options'});
    },
    [dispatch],
  );

  return (
    <FormRowText
      className={'with-guesscase' + (guessFeat ? '-guessfeat' : '')}
      field={field}
      label={label}
      onChange={handleNameChange}
      required
    >
      <button
        className="guesscase-title icon"
        onClick={handleGuessCase}
        title={l('Guess case')}
        type="button"
      />
      {guessFeat ? (
        <button
          className="guessfeat icon"
          title={l('Guess feat. artists')}
          type="button"
        />
      ) : null}

      <GuessCaseOptionsPopover
        dispatch={guessCaseOptionsDispatch}
        isOpen={isGuessCaseOptionsOpen}
        toggle={toggleGuessCaseOptions}
        {...guessCaseOptions}
      />
    </FormRowText>
  );
};

export default FormRowNameWithGuessCase;
