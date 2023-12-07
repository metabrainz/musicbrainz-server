// @flow

import * as ReactDOMClient from 'react-dom/client';

import {uniqueId} from '../../../common/utility/numbers.js';

import TodoList from './TodoList.js';

const container = document.getElementById('todo-list-container');
if (container) {
  const root = ReactDOMClient.createRoot(container);
  root.render(
    <TodoList
      initialTodos={[
        {description: 'todo1', key: uniqueId()},
        {description: 'todo2', key: uniqueId()},
      ]}
    />,
  );
}
