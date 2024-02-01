/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/newline-after-import -- the FlowIgnore triggers it */
import type {CowContext} from 'mutate-cow';
import * as React from 'react';
// $FlowIgnore[missing-export]
import {flushSync} from 'react-dom';

import GuessCase from '../../guess-case/MB/GuessCase/Main.js';

import FormRowText from './FormRowText.js';
import {
  type ActionT as GuessCaseOptionsActionT,
  type StateT as GuessCaseOptionsStateT,
  createInitialState as createGuessCaseOptionsState,
  runReducer as runGuessCaseOptionsReducer,
} from './GuessCaseOptions.js';
import GuessCaseOptionsPopover from './GuessCaseOptionsPopover.js';

type NamedEntityT = {
  +entityType: EditableEntityTypeT,
  +name: string,
  ...
};

/* eslint-disable ft-flow/sort-keys */
export type ActionT =
  | {+type: 'guess-case', +entity: NamedEntityT}
  | {+type: 'open-guess-case-options'}
  | {+type: 'close-guess-case-options'}
  | {+type: 'update-guess-case-options', +action: GuessCaseOptionsActionT}
  | {+type: 'set-name', +name: string};
/* eslint-enable ft-flow/sort-keys */

type PropsT = {
  +dispatch: (ActionT) => void,
  +entity: NamedEntityT,
  +field: FieldT<string | null>,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +guessFeat?: boolean,
  +isGuessCaseOptionsOpen: boolean,
  +label?: React$Node,
};

export type StateT = {
  +field: FieldT<string | null>,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
};

export function createInitialState(
  field: FieldT<string | null>,
): StateT {
  return {
    field,
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
  };
}

export function runReducer(
  newState: CowContext<StateT>,
  action: ActionT,
): void {
  switch (action.type) {
    case 'guess-case': {
      newState.set(
        'field', 'value',
        GuessCase.entities[action.entity.entityType].guess(
          newState.read().field.value ?? '',
        ),
      );
      break;
    }
    case 'open-guess-case-options': {
      newState.set('isGuessCaseOptionsOpen', true);
      break;
    }
    case 'close-guess-case-options': {
      newState.set('isGuessCaseOptionsOpen', false);
      break;
    }
    case 'update-guess-case-options': {
      runGuessCaseOptionsReducer(
        newState.get('guessCaseOptions'),
        action.action,
      );
      break;
    }
    case 'set-name': {
      newState.set('field', 'value', action.name);
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
  const inputRef = React.useRef<HTMLInputElement | null>(null);

  function handleNameChange(event: SyntheticKeyboardEvent<HTMLInputElement>) {
    dispatch({
      name: event.currentTarget.value,
      type: 'set-name',
    });
  }

  function handleGuessCase() {
    flushSync(() => {
      dispatch({entity, type: 'guess-case'});
    });

    if (inputRef.current) {
      inputRef.current.dispatchEvent(new Event('input'));
    }
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
      inputRef={inputRef}
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
