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
  InnerFormRowTextList as FormRowTextList,
  reducer,
} from './FormRowTextList.js';

component _StandaloneFormRowTextList(
  addButtonId: string,
  addButtonLabel: string,
  currentTextValues: $ReadOnlyArray<string>,
  initialState: StateT,
  label: string,
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  removeButtonLabel: string,
  required: boolean = false,
) {
  const [state, dispatch] =
    React.useReducer<StateT, ActionT, StateT>(
      reducer,
      initialState,
      createInitialState,
    );

  return (
    <FormRowTextList
      addButtonId={addButtonId}
      addButtonLabel={addButtonLabel}
      currentTextValues={currentTextValues}
      dispatch={dispatch}
      label={label}
      onFocus={onFocus}
      removeButtonLabel={removeButtonLabel}
      required={required}
      state={state}
    />
  );
}

const StandaloneFormRowTextList:
  component(
    ...React.PropsOf<_StandaloneFormRowTextList>
  ) =
  hydrate<React.PropsOf<_StandaloneFormRowTextList>>(
    'div.row.form-row-text-list-container',
    _StandaloneFormRowTextList,
  );

export default StandaloneFormRowTextList;
