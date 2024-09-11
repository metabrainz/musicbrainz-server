/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';
import * as React from 'react';
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
  match (action) {
    {type: 'guess-case', const entity} => {
      newState.set(
        'field', 'value', GuessCase.entities[entity.entityType].guess(
          newState.read().field.value ?? '',
        ),
      );
    }
    {type: 'open-guess-case-options'} => {
      newState.set('isGuessCaseOptionsOpen', true);
    }
    {type: 'close-guess-case-options'} => {
      newState.set('isGuessCaseOptionsOpen', false);
    }
    {type: 'update-guess-case-options', const action} => {
      runGuessCaseOptionsReducer(
        newState.get('guessCaseOptions'),
        action,
      );
    }
    {type: 'set-name', const name} => {
      newState.set('field', 'value', name);
    }
  }
}

component FormRowNameWithGuessCase(
  dispatch: (ActionT) => void,
  entity: NamedEntityT,
  field: FieldT<string | null>,
  guessCaseOptions: GuessCaseOptionsStateT,
  guessFeat: boolean = false,
  handleGuessFeat?: (event: SyntheticEvent<HTMLButtonElement>) => void,
  isGuessCaseOptionsOpen: boolean = false,
  label: React.Node = addColonText(l('Name')),
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  rowRef?: {-current: HTMLDivElement | null},
) {
  const inputRef = React.useRef<HTMLInputElement | null>(null);
  const [preview, setPreview] = React.useState<string | null>(null);

  function handleNameChange(event: SyntheticInputEvent<HTMLInputElement>) {
    dispatch({
      name: event.currentTarget.value,
      type: 'set-name',
    });
  }

  function handleGuessCase() {
    flushSync(() => {
      dispatch({entity, type: 'guess-case'});
      setPreview(null);
    });

    if (inputRef.current) {
      inputRef.current.dispatchEvent(new Event('input'));
    }
  }

  function showGuessCasePreview(
    event: SyntheticMouseEvent<HTMLButtonElement>,
  ) {
    // Don't change the value while the user is dragging to select text.
    if (event.nativeEvent.buttons === 0) {
      setPreview(
        GuessCase.entities[entity.entityType].guess(field.value ?? ''),
      );
    }
  }

  function hidePreview() {
    setPreview(null);
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

  const previewDiffers = preview !== null && preview !== field.value;
  const className =
    'with-guesscase' + (guessFeat ? '-guessfeat' : '') +
    (previewDiffers ? ' preview' : '');

  return (
    <FormRowText
      className={className}
      field={field}
      inputRef={inputRef}
      label={label}
      onChange={handleNameChange}
      onFocus={onFocus}
      preview={preview}
      required
      rowRef={rowRef}
    >
      <button
        className="guesscase-title icon"
        onClick={handleGuessCase}
        onMouseEnter={showGuessCasePreview}
        onMouseLeave={hidePreview}
        title={l('Guess case')}
        type="button"
      />
      {guessFeat ? (
        <button
          className="guessfeat icon"
          onClick={handleGuessFeat}
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
}

export default FormRowNameWithGuessCase;
