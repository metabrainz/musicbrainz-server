// @flow

import * as React from 'react';

import {uniqueId} from '../../../common/utility/numbers.js';

export type StateT = {
  +description: string,
  +key: number,
};

export type ActionT =
  | {
      +description: string,
      +type: 'set-description',
    }
  | {+type: 'move-up'}
  | {+type: 'move-down'}
  | {+type: 'remove'};

type PropsT = {
  +dispatch: (key: number, action: ActionT) => void,
  +state: StateT,
};

export function createInitialState(): StateT {
  return {
    description: '',
    key: uniqueId(),
  };
}

export function reducer(
  state: StateT,
  action: ActionT,
): StateT {
  switch (action.type) {
    case 'set-description': {
      const newState = {...state};
      newState.description = action.description;
      return newState;
    }
    default: {
      /*
       * The other actions are handled by the parent
       * reducer.
       */
      throw new Error();
    }
  }
}

type TodoComponentT = React.AbstractComponent<PropsT, mixed>;

const Todo: TodoComponentT = React.memo<PropsT>(({
  dispatch,
  state,
}: PropsT) => {
  const moveUp = React.useCallback(() => {
    dispatch(state.key, {type: 'move-up'});
  }, [state.key, dispatch]);

  const moveDown = React.useCallback(() => {
    dispatch(state.key, {type: 'move-down'});
  }, [state.key, dispatch]);

  const remove = React.useCallback(() => {
    dispatch(state.key, {type: 'remove'});
  }, [state.key, dispatch]);

  const setDescription = React.useCallback((
    event: SyntheticKeyboardEvent<HTMLInputElement>,
  ) => {
    dispatch(state.key, {
      type: 'set-description',
      description: event.currentTarget.value,
    });
  }, [state.key, dispatch]);

  return (
    <li>
      <input
        onChange={setDescription}
        placeholder="Description"
        type="text"
        value={state.description}
      />
      <button onClick={moveUp} type="button">
        {'Move up'}
      </button>
      <button onClick={moveDown} type="button">
        {'Move down'}
      </button>
      <button onClick={remove} type="button">
        {'Remove'}
      </button>
    </li>
  );
});

export default Todo;
