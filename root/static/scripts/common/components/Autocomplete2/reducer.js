/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {EntityItem} from "./types.js";import {unwrapNl} from '../../i18n';

import {
  SEARCH_AGAIN,
} from './actions';
import {EMPTY_ARRAY, MENU_ITEMS} from './constants';
import type {
  ActionItem,
  Actions,
  Item,
  SearchAction,
  State,
} from './types';

const hasOwnProperty = Object.prototype.hasOwnProperty;

function initSearch(state: State, action: SearchAction) {
  if (action.indexed !== undefined) {
    state.indexedSearch = action.indexed;
  }

  state.statusMessage = '';

  let searchTerm;
  if (hasOwnProperty.call(action, 'searchTerm')) {
    searchTerm = action.searchTerm;
  } else {
    /*
     * If we didn't provide a searchTerm, then that indicates we want to
     * search again with the text we already have.
     */
    searchTerm = state.inputValue;
  }

  if (!nonEmpty(searchTerm)) {
    return;
  }

  state.pendingSearch = searchTerm;
}

function resetPage(state: State) {
  state.highlightedIndex = 0;
  state.isOpen = false;
  state.items = EMPTY_ARRAY;
  state.page = 1;
}

function selectItem(state: State, item: Item) {
  if (item.action) {
    runReducer(state, item.action);
    return;
  }

  state.isOpen = false;
  state.selectedItem = item;
  state.statusMessage = item.name;

  if (item.name !== state.inputValue) {
    state.inputValue = item.name;
    resetPage(state);
  }
}

function selectItemAtIndex(state: State, index: number) {
  const item = state.items[index];
  if (item) {
    selectItem(state, item);
  }
}

function showError(state: State, error: ActionItem) {
  state.highlightedIndex = 0;
  state.isOpen = true;
  state.items = [error];
  state.statusMessage = unwrapNl<string>(error.name);
}

// `runReducer` should only be run on a copy of the existing state.
function runReducer(
  state: State,
  action: Actions,
) {
  switch (action.type) {
    case 'highlight-item': {
      state.highlightedIndex = action.index;
      break;
    }

    case 'highlight-next-item': {
      let index = state.highlightedIndex + 1;
      if (index >= state.items.length) {
        index = 0;
      }
      state.highlightedIndex = index;
      break;
    }

    case 'highlight-previous-item': {
      let index = state.highlightedIndex - 1;
      if (index < 0) {
        index = state.items.length - 1;
      }
      state.highlightedIndex = index;
      break;
    }

    case 'noop':
      break;

    case 'search-after-timeout':
      state.page = 1;
      initSearch(state, action);
      break;

    case 'select-highlighted-item':
      selectItemAtIndex(state, state.highlightedIndex);
      break;

    case 'select-item':
      selectItem(state, action.item);
      break;

    case 'set-menu-visibility':
      state.isOpen = action.value;
      break;

    case 'show-lookup-error': {
      showError(state, MENU_ITEMS.LOOKUP_ERROR);
      break;
    }

    case 'show-lookup-type-error': {
      showError(state, MENU_ITEMS.LOOKUP_TYPE_ERROR);
      break;
    }

    case 'show-results': {
      const {items, page, resultCount} = action;

      if (page === 1) {
        state.highlightedIndex = 0;
      } else if (state.highlightedIndex >= items.length) {
        state.highlightedIndex = items.length - 1;
      }

      const highlightedItem = items[state.highlightedIndex];

      state.isOpen = true;
      state.items = items;
      state.page = page;
      state.pendingSearch = null;
      state.statusMessage = items.length ? (
        (highlightedItem
          ? unwrapNl<string>(highlightedItem.name) + '. '
          : '') +
        texp.ln(
          `1 result found.
            Press enter to select, or
            use the up and down arrow keys to navigate.`,
          `{n} results found.
            Press enter to select, or
            use the up and down arrow keys to navigate.`,
          items.length,
          {n: resultCount},
        )
      ) : '';
      break;
    }

    case 'show-search-error': {
      showError(state, MENU_ITEMS.SEARCH_ERROR);
      state.items = state.items.concat(
        state.indexedSearch
          ? MENU_ITEMS.ERROR_TRY_AGAIN_DIRECT
          : MENU_ITEMS.ERROR_TRY_AGAIN_INDEXED,
      );
      state.pendingSearch = null;
      break;
    }

    case 'show-more-results':
      state.page++;
      initSearch(state, SEARCH_AGAIN);
      break;

    case 'stop-search':
      state.pendingSearch = null;
      break;

    case 'toggle-indexed-search':
      state.indexedSearch = !state.indexedSearch;
      state.page = 1;
      initSearch(state, SEARCH_AGAIN);
      break;

    case 'type-value':
      state.inputValue = action.value;
      state.pendingSearch = null;
      state.selectedItem = null;
      state.statusMessage = '';

      if (!state.inputValue) {
        resetPage(state);
      }

      break;

    default:
      throw new Error('Unknown action: ' + action.type);
  }
}

export default function reducer(
  state: State,
  action: Actions,
): State {
  if (action.type === 'noop') {
    return state;
  }

  const nextState = {...state};
  runReducer(nextState, action);
  return nextState;
}
