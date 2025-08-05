/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as tree from 'weight-balanced-tree';
import {
  onNotFoundThrowError,
} from 'weight-balanced-tree/update';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import formatUserDate from '../../../../utility/formatUserDate.js';
import hydrate from '../../../../utility/hydrate.js';
import invariant from '../../../../utility/invariant.js';
import loopParity from '../../../../utility/loopParity.js';
import EditorLink from '../../common/components/EditorLink.js';
import isDatabaseRowId, {
  MAX_POSTGRES_INT,
} from '../../common/utility/isDatabaseRowId.js';
import nonEmpty from '../../common/utility/nonEmpty.js';
import {isSpammer} from '../../common/utility/privileges.js';

import SpammerButton, {
  type ActionT as SpammerButtonActionT,
  type StateT as SpammerButtonStateT,
  createInitialState as createSpammerButtonState,
  reducer as spammerButtonReducer,
} from './SpammerButton.js';

type FindNewUsersResponseT =
  | {+users: $ReadOnlyArray<UnsanitizedEditorT>}
  | {+error: string};

type ActionT =
  | {
      +type: 'set-users',
      +users: $ReadOnlyArray<UnsanitizedEditorT>,
    }
  | {
      +type: 'remove-user',
      +userState: UserStateT,
    }
  | {
      +action: SpammerButtonActionT<UnsanitizedEditorT>,
      +type: 'update-spammer-button',
    }
  | {
      +error: string,
      +type: 'set-users-fetch-error',
    }
  | {+type: 'most-recent-page'}
  | {+type: 'previous-page'}
  | {+type: 'next-page'};

type UserStateT = SpammerButtonStateT<UnsanitizedEditorT>;

type PageStateT = {
  +id: number,
  +op: 'gt' | 'gte' | 'lt' | 'lte',
};

type StateT = {
  +page: PageStateT,
  +users: tree.ImmutableTree<UserStateT>,
  +usersFetchError: string,
};

function getPageState(): PageStateT {
  if (typeof window !== 'undefined') {
    const params = new URLSearchParams(window.location.search);
    const op = params.get('op');
    const id = parseInt(params.get('id'), 10);
    if (nonEmpty(op) && nonEmpty(id)) {
      try {
        invariant(
          op === 'gt' || op === 'gte' ||
          op === 'lt' || op === 'lte',
        );
        invariant(isDatabaseRowId(id));
        return {id, op};
      } catch (error) {
        console.error(error);
      }
    }
  }
  return {id: MAX_POSTGRES_INT, op: 'lte'};
}

function cmpUserState(a: UserStateT, b: UserStateT) {
  return b.user.id - a.user.id;
}

function errorToString(error: mixed) {
  if (error == null) {
    return '';
  }
  return String(
    (typeof error === 'object' && nonEmpty(error.message))
      ? error.message
      : error,
  );
}

function createInitialState(): StateT {
  return {
    page: getPageState(),
    users: tree.empty,
    usersFetchError: '',
  };
}

// eslint-disable-next-line consistent-return
function reducer(state: StateT, action: ActionT): StateT {
  switch (action.type) {
    case 'set-users': {
      let newUsers: tree.ImmutableTree<UserStateT> = tree.empty;
      for (const user of action.users) {
        newUsers = tree.insertIfNotExists(
          newUsers,
          createSpammerButtonState(user),
          cmpUserState,
        );
      }
      return {
        ...state,
        users: newUsers,
        usersFetchError: '',
      };
    }
    case 'remove-user': {
      return {
        ...state,
        users: tree.removeOrThrowIfNotExists(
          state.users,
          action.userState,
          cmpUserState,
        ),
      };
    }
    case 'update-spammer-button': {
      return {
        ...state,
        users: tree.update(
          state.users,
          action.action.state,
          cmpUserState,
          (existingValue) => spammerButtonReducer(
            existingValue,
            action.action,
          ),
          onNotFoundThrowError,
        ),
      };
    }
    case 'set-users-fetch-error': {
      return {
        ...state,
        usersFetchError: action.error,
      };
    }
    case 'most-recent-page': {
      return {
        ...state,
        page: {id: MAX_POSTGRES_INT, op: 'lte'},
      };
    }
    case 'previous-page': {
      const page = state.page;
      let newPage;
      switch (page.op) {
        case 'gt':
        case 'gte': {
          if (!state.users.size) {
            return state;
          }
          newPage = {
            id: tree.minValue(state.users).user.id,
            op: 'gt' as const,
          };
          break;
        }
        case 'lt': {
          newPage = {id: page.id, op: 'gte' as const};
          break;
        }
        case 'lte': {
          newPage = {id: page.id, op: 'gt' as const};
          break;
        }
        default: {
          invariant(false);
        }
      }
      return {
        ...state,
        page: newPage,
      };
    }
    case 'next-page': {
      const page = state.page;
      let newPage;
      switch (page.op) {
        case 'gt': {
          newPage = {id: page.id, op: 'lte' as const};
          break;
        }
        case 'gte': {
          newPage = {id: page.id, op: 'lt' as const};
          break;
        }
        case 'lt':
        case 'lte': {
          if (!state.users.size) {
            return state;
          }
          newPage = {
            id: tree.maxValue(state.users).user.id,
            op: 'lt' as const,
          };
          break;
        }
        default: {
          invariant(false);
        }
      }
      return {
        ...state,
        page: newPage,
      };
    }
    default: {
      invariant(false, `unknown action: ${action.type}`);
    }
  }
}

component _PossibleSpammersList() {
  const $c = React.useContext(SanitizedCatalystContext);

  const [state, dispatch] = React.useReducer(
    reducer,
    null,
    createInitialState,
  );

  React.useEffect(() => {
    const params = new URLSearchParams();
    params.set('op', state.page.op);
    params.set('id', String(state.page.id));
    window.history.replaceState(
      null, '', window.location.pathname + '?' + params.toString(),
    );
  }, [state.page]);

  const fetchPage = React.useCallback(() => {
    const url = (
      '/ws/js/find-possible-spammers' +
        '?op=' + encodeURIComponent(state.page.op) +
        '&id=' + encodeURIComponent(String(state.page.id))
    );
    fetch(url)
      .then(
        (response) => {
          return response.json() as Promise<FindNewUsersResponseT>;
        },
        (error) => {
          dispatch({
            error: errorToString(error),
            type: 'set-users-fetch-error',
          });
        },
      )
      .then(
        (body) => {
          invariant(body != null, 'body is null');
          const error = body?.error;
          if (nonEmpty(error)) {
            dispatch({
              error: errorToString(error),
              type: 'set-users-fetch-error',
            });
            return;
          }
          invariant(body.users, 'body.users is undefined');
          dispatch({type: 'set-users', users: body.users});
        },
        (error) => {
          dispatch({
            error: errorToString(error),
            type: 'set-users-fetch-error',
          });
        },
      );
  }, [state.page]);

  const spammerButtonDispatch = React.useCallback((
    action: SpammerButtonActionT<UnsanitizedEditorT>,
  ) => {
    dispatch({
      action,
      type: 'update-spammer-button',
    });
  }, []);

  const mostRecentPage = React.useCallback(() => {
    dispatch({type: 'most-recent-page'});
  }, []);

  const previousPage = React.useCallback(() => {
    dispatch({type: 'previous-page'});
  }, []);

  const nextPage = React.useCallback(() => {
    dispatch({type: 'next-page'});
  }, []);

  React.useEffect(() => {
    fetchPage();
  }, [fetchPage]);

  const rows = [];
  let index = 0;
  for (const userState of tree.iterate(state.users)) {
    const user = userState.user;
    rows.push(
      <tr
        className={
          'hoverable ' +
          (isSpammer(user) ? 'spammer ' : '') +
          loopParity(index++)
        }
        key={user.id}
      >
        <td>
          <EditorLink editor={user} />
        </td>
        <td>{user.email}</td>
        <td>{user.website}</td>
        <td>{user.biography}</td>
        <td>{formatUserDate($c, user.registration_date)}</td>
        <td>{user.unused === true ? '✅' : '❌'}</td>
        <td>
          <SpammerButton
            dispatch={spammerButtonDispatch}
            state={userState}
          />
        </td>
      </tr>,
    );
  }

  return (
    <table className="tbl">
      <colgroup>
        <col style={{width: '11%'}} />
        <col style={{width: '11%'}} />
        <col style={{width: '11%'}} />
        <col style={{width: '44%'}} />
        <col style={{width: '11%'}} />
        <col style={{width: '4%'}} />
        <col style={{width: '8%'}} />
      </colgroup>
      <thead>
        <tr>
          <th>{'Editor'}</th>
          <th>{'Email'}</th>
          <th>{'Website'}</th>
          <th>{'Bio'}</th>
          <th>{'Member since'}</th>
          <th>{'Unused'}</th>
          <th>{'Action'}</th>
        </tr>
      </thead>
      <tbody>
        {nonEmpty(state.usersFetchError) ? (
          <tr key="users-fetch-error">
            <td className="error" colSpan={7}>
              {state.usersFetchError}
            </td>
          </tr>
        ) : null}
        {rows}
        <tr key="buttons">
          <td className="buttons" colSpan={7}>
            <button onClick={mostRecentPage} type="button">
              {'Most recent'}
            </button>
            <button onClick={previousPage} type="button">
              {'Previous page'}
            </button>
            <button onClick={nextPage} type="button">
              {'Next page'}
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  );
}

const PossibleSpammersList = (hydrate<{}>(
  'div.possible-spammers',
  _PossibleSpammersList,
): component());

export default PossibleSpammersList;
