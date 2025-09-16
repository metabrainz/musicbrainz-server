// @flow

import * as React from 'react';

import Todo, {
  type ActionT as TodoActionT,
  type StateT as TodoStateT,
  createInitialState as createTodoState,
  reducer as todoReducer,
} from './Todo.js';

type PropsT = {
  +initialTodos: $ReadOnlyArray<TodoStateT>,
};

type StateT = {
  +todos: $ReadOnlyArray<TodoStateT>,
};

type ActionT =
  | {
      +type: 'add-todo',
    }
  | {
      +action: TodoActionT,
      +key: number,
      +type: 'update-todo',
    };

export function createInitialState(
  initialTodos: $ReadOnlyArray<TodoStateT>,
): StateT {
  return {todos: initialTodos};
}

function reducer(state: StateT, action: ActionT): StateT {
  const newState = {...state};
  match (action) {
    {type: 'add-todo'} => {
      newState.todos = [
        ...newState.todos,
        createTodoState(),
      ];
    }
    {type: 'update-todo', const action, const key} => {
      const index = newState.todos.findIndex(x => x.key === key);
      const todoAction = action;
      let newTodos = newState.todos;

      match (todoAction) {
        {type: 'move-up'} => {
          if (index > 0) {
            newTodos = [...newState.todos];
            // $FlowExpectedError[unsupported-syntax]
            [newTodos[index - 1], newTodos[index]] =
              [newTodos[index], newTodos[index - 1]];
          }
        }
        {type: 'move-down'} => {
          if (index < (newState.todos.length - 1)) {
            newTodos = [...newState.todos];
            // $FlowExpectedError[unsupported-syntax]
            [newTodos[index], newTodos[index + 1]] =
              [newTodos[index + 1], newTodos[index]];
          }
        }
        {type: 'remove'} => {
          newTodos = [...newState.todos];
          newTodos.splice(index, 1);
          if (newTodos.length === 0) {
            newTodos.push(createTodoState());
          }
        }
        _ => {
          newTodos = [...newState.todos];
          newTodos[index] = todoReducer(newTodos[index], todoAction);
        }
      }
      newState.todos = newTodos;
    }
  }
  return newState;
}

export default function TodoList(props: PropsT): React.MixedElement {
  const [state, dispatch] = React.useReducer(
    reducer,
    props.initialTodos,
    createInitialState,
  );

  const addTodo = React.useCallback(() => {
    dispatch({type: 'add-todo'});
  }, [dispatch]);

  const todoDispatch = React.useCallback((
    key: number,
    action: TodoActionT,
  ) => {
    dispatch({
      action,
      key,
      type: 'update-todo',
    });
  }, [dispatch]);

  return (
    <>
      <ul>
        {state.todos.map((todo) => (
          <Todo
            dispatch={todoDispatch}
            key={todo.key}
            state={todo}
          />
        ))}
      </ul>
      <button onClick={addTodo} type="button">
        {'Add todo'}
      </button>
    </>
  );
}
