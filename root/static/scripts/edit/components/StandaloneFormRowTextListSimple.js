/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  type ActionT,
  type StateT,
  createInitialState,
  InnerFormRowTextListSimple as FormRowTextListSimple,
  reducer,
} from './FormRowTextListSimple.js';

component _StandaloneFormRowTextListSimple(
  addButtonId: string,
  addButtonLabel: string,
  repeatable: StateT,
  label: string,
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  removeButtonLabel: string,
  required: boolean = false,
) {
  const [state, dispatch] =
    React.useReducer<StateT, ActionT, StateT>(
      reducer,
      repeatable,
      createInitialState,
    );

  return (
    <FormRowTextListSimple
      addButtonId={addButtonId}
      addButtonLabel={addButtonLabel}
      dispatch={dispatch}
      label={label}
      onFocus={onFocus}
      removeButtonLabel={removeButtonLabel}
      required={required}
      state={state}
    />
  );
}

const StandaloneFormRowTextListSimple:
  component(
    ...React.PropsOf<_StandaloneFormRowTextListSimple>
  ) =
  hydrate<React.PropsOf<_StandaloneFormRowTextListSimple>>(
    'div.row.form-row-text-list-container',
    _StandaloneFormRowTextListSimple,
  );

export default StandaloneFormRowTextListSimple;
