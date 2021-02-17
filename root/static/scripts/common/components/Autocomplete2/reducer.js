/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {unwrapNl} from '../../i18n';

import {
  SEARCH_AGAIN,
} from './actions';
import {EMPTY_ARRAY, MENU_ITEMS, PAGE_SIZE} from './constants';
import type {
  Actions,
  ActionItem,
  EntityItem,
  Item,
  SearchAction,
  State,
} from './types';

function initSearch<+T: EntityItem>(
  state: {...State<T>},
  action: SearchAction,
) {
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

  if (nonEmpty(searchTerm)) {
    state.pendingSearch = searchTerm;
  }
}

function resetPage<+T: EntityItem>(state: {...State<T>}) {
  state.highlightedItem = null;
  state.isOpen = false;
  state.items = EMPTY_ARRAY;
  state.page = 1;
}

function selectItem<+T: EntityItem>(
  state: {...State<T>},
  item: Item<T>,
) {
  switch (item.type) {
    case 'action': {
      runReducer<T>(state, item.action);
      return;
    }
    case 'option': {
      const entity = item.entity;
      state.selectedEntity = entity;
      state.statusMessage = entity.name;

      if (item.name !== state.inputValue) {
        state.inputValue = entity.name;
        resetPage<T>(state);
      }
    }
  }

  state.isOpen = false;
  state.pendingSearch = null;
}

function showError<+T: EntityItem>(
  state: {...State<T>},
  error: ActionItem<T>,
) {
  state.highlightedItem = null;
  state.isOpen = true;
  state.items = [error];
  state.statusMessage = unwrapNl<string>(error.name);
}

function highlightNextItem<+T: EntityItem>(
  state: {...State<T>},
  startingIndex: number,
) {
  const items = state.items;
  let index = startingIndex;
  let count = items.length;

  while (true) {
    if (index >= items.length) {
      index = 0;
    }
    const item = items[index];
    // $FlowIgnore[sketchy-null-bool]
    if (!item.disabled) {
      state.highlightedItem = item;
      break;
    }
    count--;
    if (count <= 0) {
      break;
    }
    index++;
  }
}

function showFilteredItems<T: EntityItem>(
  state: {...State<T>},
  filteredItems: $ReadOnlyArray<Item<T>>,
): void {
  const page = state.page;
  const resultCount = filteredItems.length;

  showResults<T>(
    state,
    filteredItems.slice(0, page * PAGE_SIZE),
    page,
    resultCount,
    Math.ceil(resultCount / PAGE_SIZE),
  );
}

function showResults<T: EntityItem>(
  state: {...State<T>},
  items: Array<Item<T>>,
  page: number,
  resultCount: number,
  totalPages: number,
) {
  if (items.length) {
    if (page < totalPages) {
      items.push(MENU_ITEMS.SHOW_MORE);
    }
  } else if (page === 1) {
    items.push(MENU_ITEMS.NO_RESULTS);
  }

  if (!state.staticItems) {
    items.push(state.indexedSearch
      ? MENU_ITEMS.TRY_AGAIN_DIRECT
      : MENU_ITEMS.TRY_AGAIN_INDEXED);
  }

  state.items = items;

  if (page === 1) {
    highlightNextItem<T>(state, 0);
  }

  const highlightedItem = state.highlightedItem;

  state.isOpen = true;
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
}

export function defaultStaticItemsFilter<+T: EntityItem>(
  item: Item<T>,
  searchTerm: string,
): boolean {
  if (item.type === 'option') {
    return unwrapNl<string>(item.name)
      .toLowerCase()
      .includes(searchTerm.toLowerCase());
  }
  return true;
}

// `runReducer` should only be run on a copy of the existing state.
export function runReducer<+T: EntityItem>(
  state: {...State<T>},
  action: Actions<T>,
): void {
  switch (action.type) {
    case 'change-entity-type': {
      state.entityType = action.entityType;
      state.selectedEntity = null;
      resetPage<T>(state);
      break;
    }

    case 'filter-static-items': {
      const {
        staticItems,
        staticItemsFilter: filter = defaultStaticItemsFilter,
        staticItemsFilterResult: previousResult,
      } = state;

      invariant(staticItems);

      const searchTerm = action.searchTerm;
      const prevSearchTerm = previousResult?.searchTerm;

      /*
       * If the new search term starts with the previous one,
       * we can filter the existing items rather than starting
       * anew.
       */
      let filteredItems: ?$ReadOnlyArray<Item<T>>;
      let itemsToFilter;
      if (
        nonEmpty(prevSearchTerm) &&
        /*:: previousResult && */ /* implied by prevSearchTerm */
        searchTerm.startsWith(prevSearchTerm)
      ) {
        if (searchTerm.length === prevSearchTerm.length) {
          // The string hasn't changed; we can use the previous results.
          filteredItems = previousResult.items;
        } else {
          itemsToFilter = previousResult.items;
        }
      }

      if (!filteredItems) {
        if (!itemsToFilter) {
          itemsToFilter = staticItems;
        }
        filteredItems = searchTerm
          ? (itemsToFilter.reduce(
            (accum: Array<Item<T>>, item: Item<T>) => {
              if (filter(item, searchTerm)) {
                accum.push(item);
              }
              return accum;
            },
            [],
          ): $ReadOnlyArray<Item<T>>)
          : itemsToFilter;
      }

      state.staticItemsFilterResult = {
        items: filteredItems,
        searchTerm,
      };

      showFilteredItems<T>(state, filteredItems);

      break;
    }

    case 'highlight-item': {
      state.highlightedItem = action.item;
      break;
    }

    case 'highlight-next-item': {
      const {highlightedItem} = state;
      const items = state.items;
      const index = highlightedItem
        ? items.indexOf(highlightedItem) + 1
        : 0;
      highlightNextItem<T>(state, index);
      break;
    }

    case 'highlight-previous-item': {
      const {highlightedItem} = state;
      const items = state.items;

      let count = items.length;
      let index = highlightedItem
        ? state.items.indexOf(highlightedItem) - 1
        : (count - 1);

      while (true) {
        if (index < 0) {
          index = items.length - 1;
        }
        const item = items[index];
        // $FlowIgnore[sketchy-null-bool]
        if (!item.disabled) {
          state.highlightedItem = item;
          break;
        }
        count--;
        if (count <= 0) {
          break;
        }
        index--;
      }

      break;
    }

    case 'noop':
      break;

    case 'search-after-timeout':
      state.page = 1;
      initSearch<T>(state, action);
      break;

    case 'select-item':
      selectItem<T>(state, action.item);
      break;

    case 'set-menu-visibility':
      state.isOpen = action.value;
      if (!state.isOpen) {
        state.highlightedItem = null;
      }
      break;

    case 'show-lookup-error': {
      showError<T>(state, MENU_ITEMS.LOOKUP_ERROR);
      break;
    }

    case 'show-lookup-type-error': {
      showError<T>(state, MENU_ITEMS.LOOKUP_TYPE_ERROR);
      break;
    }

    case 'show-ws-results': {
      const {entities, page, totalPages} = action;

      let newItems: Array<Item<T>> = entities.map((entity: T) => ({
        entity,
        id: entity.id,
        name: entity.name,
        type: 'option',
      }));

      const prevItems: Array<Item<T>> = [];
      const prevItemIds = new Set();
      for (const item of state.items) {
        if (!item.action) {
          prevItems.push(item);
          prevItemIds.add(item.id);
        }
      }

      newItems = page > 1
        ? prevItems.concat(newItems.filter(x => !prevItemIds.has(x.id)))
        : newItems;

      showResults<T>(state, newItems, page, newItems.length, totalPages);

      break;
    }

    case 'show-search-error': {
      showError<T>(state, MENU_ITEMS.SEARCH_ERROR);
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
      if (state.staticItems) {
        showFilteredItems(
          state,
          (state.staticItemsFilterResult?.items) ?? [],
        );
      } else {
        initSearch<T>(state, SEARCH_AGAIN);
      }
      break;

    case 'stop-search':
      state.pendingSearch = null;
      break;

    case 'toggle-indexed-search':
      state.indexedSearch = !state.indexedSearch;
      state.page = 1;
      initSearch<T>(state, SEARCH_AGAIN);
      break;

    case 'type-value':
      state.inputValue = action.value;
      state.pendingSearch = null;
      state.selectedEntity = null;
      state.statusMessage = '';

      if (!state.inputValue) {
        resetPage<T>(state);

        const staticItems = state.staticItems;
        if (staticItems) {
          // Show a paged listing of all available options.
          state.staticItemsFilterResult = {
            items: staticItems,
            searchTerm: '',
          };
          showFilteredItems<T>(state, staticItems);
        }
      }

      break;

    default:
      /*:: exhaustive(action); */
      throw new Error('Unknown action: ' + action.type);
  }
}

export default function reducer<+T: EntityItem>(
  state: State<T>,
  action: Actions<T>,
): State<T> {
  if (action.type === 'noop') {
    return state;
  }

  const nextState = {...state};
  runReducer<T>(nextState, action);
  return nextState;
}
