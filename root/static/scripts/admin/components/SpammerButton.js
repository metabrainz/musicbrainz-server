/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  ADDING_NOTES_DISABLED_FLAG,
  EDITING_DISABLED_FLAG,
  SPAMMER_FLAG,
  VOTING_DISABLED_FLAG,
} from '../../../../constants.js';
import {isSpammer} from '../../common/utility/privileges.js';

type InexactUserT = {
  +id: number,
  +privileges: number,
  ...
};

export type ActionT<T: InexactUserT> = {
  +state: StateT<T>,  /* Looks useless, but allows parent reducers to
                         determine which button triggered the action. */
  +type: 'update',
  +update: Partial<StateT<T>>,
  ...
};

export type StateT<T: InexactUserT> = {
  +initialPrivileges: number,
  +requestError: string,
  +requestPending: boolean,
  +user: T,
};

const SPAMMER_PRIVILEGES = (
  ADDING_NOTES_DISABLED_FLAG |
  EDITING_DISABLED_FLAG |
  SPAMMER_FLAG |
  VOTING_DISABLED_FLAG
);

export function createInitialState<T: InexactUserT>(
  user: T,
): StateT<T> {
  return {
    initialPrivileges: user.privileges,
    requestError: '',
    requestPending: false,
    user,
  };
}

export function reducer<T: InexactUserT>(
  state: StateT<T>,
  action: ActionT<T>,
): StateT<T> {
  match (action) {
    {type: 'update', const update, ...} => {
      return {...state, ...update};
    }
  }
}

component _SpammerButton<T: InexactUserT>(
  dispatch: (ActionT<T>) => void,
  state: StateT<T>,
) {
  const isMarkedAsSpammer = isSpammer(state.user);

  const doUpdate = React.useCallback((update: Partial<StateT<T>>): void => {
    dispatch({state, type: 'update', update});
  }, [dispatch, state]);

  const setError = React.useCallback((error: mixed): void => {
    doUpdate({requestError: String(error), requestPending: false});
  }, [doUpdate]);

  const handleClick = React.useCallback(() => {
    const userIdString = String(state.user.id);
    const url = (
      '/ws/js/mark-spammer/' + encodeURIComponent(userIdString) +
      (isMarkedAsSpammer
        ? ('?undo=' +
           String(state.initialPrivileges ^ state.user.privileges))
        : '')
    );
    doUpdate({requestPending: true});
    fetch(url).then(
      (response) => response.text().then(
        (text) => {
          if (response.ok) {
            doUpdate({
              requestError: '',
              requestPending: false,
              user: {
                ...state.user,
                privileges: isMarkedAsSpammer
                  ? state.initialPrivileges
                  : (state.user.privileges | SPAMMER_PRIVILEGES),
              },
            });
          } else {
            setError(text);
          }
        },
        setError,
      ),
      setError,
    );
  }, [state, isMarkedAsSpammer, doUpdate, setError]);

  return (
    <>
      <button
        className={
          'styled-button' +
          (isMarkedAsSpammer ? '' : ' negative')
        }
        disabled={state.requestPending}
        onClick={handleClick}
        type="button"
      >
        {isMarkedAsSpammer ? '↩️ Undo' : '🔨 Spammer'}
      </button>
      {nonEmpty(state.requestError) ? (
        <div className="error">{state.requestError}</div>
      ) : null}
    </>
  );
}

const SpammerButton: typeof _SpammerButton =
  // $FlowIssue[incompatible-type]
  React.memo(_SpammerButton);

export default SpammerButton;

component _StandaloneSpammerButton<T: InexactUserT>(
  user: T,
) {
  const [state, dispatch] = React.useReducer(
    reducer,
    user,
    createInitialState,
  );
  return <SpammerButton dispatch={dispatch} state={state} />;
}

export const StandaloneSpammerButton =
  (hydrate<React.PropsOf<_StandaloneSpammerButton<InexactUserT>>>(
    'div.spammer-button',
    _StandaloneSpammerButton,
  ): component(...React.PropsOf<_StandaloneSpammerButton<InexactUserT>>));
