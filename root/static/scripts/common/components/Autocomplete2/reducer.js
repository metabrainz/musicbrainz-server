/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';

import {unwrapNl} from '../../i18n';

import {
  SEARCH_AGAIN,
} from './actions';
import {EMPTY_ARRAY, MENU_ITEMS} from './constants';
import type {
  ActionItem,
  Actions,
  Props,
  SearchAction,
  State,
} from './types';

function initSearch(state: State, action: SearchAction) {
  if (action.indexed !== undefined) {
    state.indexedSearch = action.indexed;
  }

  state.statusMessage = '';

  let searchTerm;
  if (hasOwnProp(action, 'searchTerm')) {
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
  state.highlightedItem = null;
  state.isOpen = false;
  state.items = EMPTY_ARRAY;
  state.page = 1;
}

function runOnChange(props, state, item) {
  const selectedItem = state.selectedItem;
  if ((!selectedItem !== !item) ||
      (selectedItem && item && selectedItem.id !== item.id)) {
    props.onChange(item);
  }
}

function selectItem(props, state, item, unwrapProxy) {
  if (item.action) {
    runReducer(props, state, item.action, unwrapProxy);
    return;
  }

  state.isOpen = false;
  state.selectedItem = item;
  state.statusMessage = item.name;

  if (item.name !== state.inputValue) {
    state.inputValue = item.name;
    resetPage(state);
  }

  runOnChange(props, state, item);
}

function showError(state: State, error: ActionItem) {
  state.highlightedItem = null;
  state.isOpen = true;
  state.items = [error];
  state.statusMessage = unwrapNl<string>(error.name);
}

// `runReducer` should only be run on a copy of the existing state.
function runReducer(
  props: Props,
  state: State,
  action: Actions,
  unwrapProxy: <T>(T) => T,
) {
  switch (action.type) {
    case 'highlight-item': {
      state.highlightedItem = action.item;
      break;
    }

    case 'highlight-next-item': {
      const {highlightedItem} = state;
      let index = highlightedItem
        ? state.items.findIndex(item => item.id === highlightedItem.id) + 1
        : 0;
      if (index >= state.items.length) {
        index = 0;
      }
      state.highlightedItem = state.items[index];
      break;
    }

    case 'highlight-previous-item': {
      const {highlightedItem} = state;
      let index = highlightedItem
        ? state.items.findIndex(item => item.id === highlightedItem.id) - 1
        : 0;
      if (index < 0) {
        index = state.items.length - 1;
      }
      state.highlightedItem = state.items[index];
      break;
    }

    case 'noop':
      break;

    case 'search-after-timeout':
      state.page = 1;
      initSearch(state, action);
      break;

    case 'select-item':
      selectItem(props, state, action.item, unwrapProxy);
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
        state.highlightedItem = items[0];
      }

      const highlightedItem = state.highlightedItem;

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
      state.items = unwrapProxy(state.items).concat(
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

      runOnChange(props, state, null);
      break;

    default:
      throw new Error('Unknown action: ' + action.type);
  }
}

export default function reducer(
  props: Props,
  state: State,
  action: Actions,
): State {
  if (action.type === 'noop') {
    return state;
  }

  return mutate(state, (nextState, unwrapProxy) => {
    runReducer(props, nextState, action, unwrapProxy);
  });
}
