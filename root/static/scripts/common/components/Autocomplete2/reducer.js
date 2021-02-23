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
import {
  CLEAR_RECENT_ITEMS,
  ERROR_LOOKUP,
  ERROR_LOOKUP_TYPE,
  ERROR_SEARCH,
  MENU_ITEMS,
  PAGE_SIZE,
  RECENT_ITEMS_HEADER,
} from './constants';
import type {
  Actions,
  EntityItem,
  Item,
  SearchAction,
  State,
} from './types';
import {
  clearRecentItems,
  pushRecentItem,
} from './recentItems';

function initSearch<+T: EntityItem>(
  state: {...State<T>},
  action: SearchAction,
) {
  if (action.indexed !== undefined) {
    state.indexedSearch = action.indexed;
  }

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

export function generateItems<+T: EntityItem>(
  state: State<T>,
): $ReadOnlyArray<Item<T>> {
  const items = [];

  if (state.error) {
    switch (state.error) {
      case ERROR_LOOKUP:
        items.push(MENU_ITEMS.LOOKUP_ERROR);
        break;
      case ERROR_LOOKUP_TYPE:
        items.push(MENU_ITEMS.LOOKUP_TYPE_ERROR);
        break;
      case ERROR_SEARCH:
        items.push(MENU_ITEMS.SEARCH_ERROR);
        if (state.indexedSearch) {
          items.push(MENU_ITEMS.ERROR_TRY_AGAIN_DIRECT);
        } else {
          items.push(MENU_ITEMS.ERROR_TRY_AGAIN_INDEXED);
        }
        break;
    }
    return items;
  }

  const {
    page,
    recentItems,
    results,
  } = state;

  const isInputValueNonEmpty = nonEmpty(state.inputValue);
  const hasStaticItems = !!state.staticItems;
  const hasSelection = !!state.selectedEntity;
  const showingRecentItems = !!(
    !isInputValueNonEmpty && recentItems?.length
  );

  if (showingRecentItems /*:: && recentItems */) {
    items.push(RECENT_ITEMS_HEADER);
    items.push(...recentItems);
    items.push(CLEAR_RECENT_ITEMS);
  }

  if (__DEV__) {
    if (hasSelection) {
      invariant(isInputValueNonEmpty);
    }
  }

  if (results != null) {
    const resultCount = results.length;

    if (resultCount > 0) {
      const visibleResults = Math.min(resultCount, page * PAGE_SIZE);
      const totalPages = Math.ceil(resultCount / PAGE_SIZE);

      if (showingRecentItems) {
        items.push({...results[0], separator: true});
      } else {
        items.push(results[0]);
      }

      for (let i = 1; i < visibleResults; i++) {
        items.push(results[i]);
      }

      if (page < totalPages) {
        items.push(MENU_ITEMS.SHOW_MORE);
      }
    } else if (isInputValueNonEmpty && !hasSelection) {
      items.push(MENU_ITEMS.NO_RESULTS);
    }

    if (!hasStaticItems) {
      if (state.indexedSearch) {
        items.push(MENU_ITEMS.TRY_AGAIN_DIRECT);
      } else {
        items.push(MENU_ITEMS.TRY_AGAIN_INDEXED);
      }
    }
  }

  return items;
}

function getFirstHighlightableIndex<+T: EntityItem>(
  state: State<T>,
): number {
  const items = state.items;
  let index = 0;
  for (const item of items) {
    // $FlowIgnore[sketchy-null-bool]
    if (!item.disabled) {
      return index;
    }
    index++;
  }
  return -1;
}

export function generateStatusMessage<+T: EntityItem>(
  state: State<T>,
): string {
  if (state.isOpen) {
    if (state.error) {
      switch (state.error) {
        case ERROR_LOOKUP:
          return unwrapNl<string>(MENU_ITEMS.LOOKUP_ERROR.name);
        case ERROR_LOOKUP_TYPE:
          return unwrapNl<string>(MENU_ITEMS.LOOKUP_TYPE_ERROR.name);
        case ERROR_SEARCH:
          return unwrapNl<string>(MENU_ITEMS.SEARCH_ERROR.name);
      }
    }

    const resultCount = state.results?.length;
    if (resultCount /*:: != null && resultCount > 0 */) {
      const highlightedItem = state.highlightedIndex >= 0
        ? (state.items[state.highlightedIndex] ?? null)
        : null;
      return (
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
          resultCount,
          {n: resultCount},
        )
      );
    }
  } else if (state.selectedEntity) {
    return state.selectedEntity.name;
  }

  return '';
}

function filterStaticItems<+T: EntityItem>(
  state: {...State<T>},
  newInputValue: string,
): void {
  const {
    inputValue: prevInputValue,
    results: prevResults,
    staticItems,
    staticItemsFilter: filter = defaultStaticItemsFilter,
  } = state;

  invariant(staticItems);

  /*
   * If the new search term starts with the previous one,
   * we can filter the existing items rather than starting
   * anew.
   */
  const itemsToFilter = (
    nonEmpty(prevInputValue) &&
    newInputValue.startsWith(prevInputValue)
  ) ? prevResults : staticItems;

  state.results = (itemsToFilter && nonEmpty(newInputValue))
    ? (itemsToFilter.reduce(
        (accum: Array<Item<T>>, item: Item<T>) => {
          if (filter(item, newInputValue)) {
            accum.push(item);
          }
          return accum;
        },
        [],
    ): $ReadOnlyArray<Item<T>>)
    : itemsToFilter;
}

export function resetPage<+T: EntityItem>(
  state: {...State<T>},
): void {
  state.highlightedIndex = -1;
  state.isOpen = false;
  state.page = 1;
  state.error = 0;
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
      const entityName = entity.name;

      state.selectedEntity = entity;

      if (entityName !== state.inputValue) {
        if (state.staticItems) {
          filterStaticItems<T>(state, entityName);
        }
        state.inputValue = entityName;
      }

      if (!state.staticItems) {
        state.results = null;
      }

      resetPage<T>(state);

      state.recentItems = pushRecentItem(
        item,
        state.recentItemsKey,
      );
    }
  }

  state.isOpen = false;
  state.pendingSearch = null;
}

function setError<+T: EntityItem>(
  state: {...State<T>},
  error: number,
) {
  state.error = error;
  state.isOpen = true;
}

function highlightNextItem<+T: EntityItem>(
  state: {...State<T>},
  items: $ReadOnlyArray<Item<T>>,
  startingIndex: number,
) {
  let index = startingIndex;
  let count = items.length;

  while (true) {
    if (index >= items.length) {
      index = 0;
    }
    const item = items[index];
    // $FlowIgnore[sketchy-null-bool]
    if (!item.disabled) {
      state.highlightedIndex = index;
      break;
    }
    count--;
    if (count <= 0) {
      break;
    }
    index++;
  }
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
  const wasOpen = state.isOpen;
  let updateItems = false;
  let updateStatusMessage = false;

  switch (action.type) {
    case 'change-entity-type': {
      const oldEntityType = state.entityType;
      state.entityType = action.entityType;
      state.selectedEntity = null;
      state.recentItems = null;
      if (state.recentItemsKey === oldEntityType) {
        state.recentItemsKey = action.entityType;
      }
      state.results = null;
      resetPage<T>(state);
      updateItems = true;
      updateStatusMessage = true;
      break;
    }

    case 'highlight-next-item': {
      highlightNextItem<T>(state, action.items, state.highlightedIndex + 1);
      updateStatusMessage = true;
      break;
    }

    case 'highlight-previous-item': {
      const items = action.items;

      let count = items.length;
      let index = state.highlightedIndex >= 0
        ? (state.highlightedIndex - 1)
        : (count - 1);

      while (true) {
        if (index < 0) {
          index = items.length - 1;
        }
        const item = items[index];
        // $FlowIgnore[sketchy-null-bool]
        if (!item.disabled) {
          state.highlightedIndex = index;
          break;
        }
        count--;
        if (count <= 0) {
          break;
        }
        index--;
      }

      updateStatusMessage = true;
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
      updateItems = true;
      updateStatusMessage = true;
      break;

    case 'set-menu-visibility':
      state.isOpen = action.value;
      updateStatusMessage = true;
      break;

    case 'show-lookup-error': {
      setError<T>(state, ERROR_LOOKUP);
      updateItems = true;
      updateStatusMessage = true;
      break;
    }

    case 'show-lookup-type-error': {
      setError<T>(state, ERROR_LOOKUP_TYPE);
      updateItems = true;
      updateStatusMessage = true;
      break;
    }

    case 'show-ws-results': {
      const {entities, page} = action;

      let newResults: Array<Item<T>> = entities.map((entity: T) => ({
        entity,
        id: entity.id,
        name: entity.name,
        type: 'option',
      }));

      const prevResults = state.results;
      if (page > 1 && prevResults) {
        const prevIds = new Set(prevResults.map(item => item.id));

        newResults = prevResults.concat(
          newResults.filter(x => !prevIds.has(x.id)),
        );
      }

      state.results = newResults;
      state.isOpen = true;
      state.page = page;
      state.pendingSearch = null;
      state.error = 0;
      state.highlightedIndex = 0;

      updateItems = true;
      updateStatusMessage = true;
      break;
    }

    case 'set-recent-items': {
      state.recentItems = action.items;
      updateItems = true;
      break;
    }

    case 'clear-recent-items': {
      clearRecentItems(state.recentItemsKey);
      state.recentItems = [];
      state.highlightedIndex = -1;
      updateItems = true;
      break;
    }

    case 'show-search-error': {
      setError<T>(state, ERROR_SEARCH);
      state.pendingSearch = null;
      updateItems = true;
      updateStatusMessage = true;
      break;
    }

    case 'show-more-results':
      state.page++;
      if (!state.staticItems) {
        initSearch<T>(state, SEARCH_AGAIN);
      }
      break;

    case 'stop-search':
      state.pendingSearch = null;
      break;

    case 'toggle-indexed-search':
      state.indexedSearch = !state.indexedSearch;
      state.page = 1;
      state.isOpen = false;
      initSearch<T>(state, SEARCH_AGAIN);
      break;

    case 'reset-menu': {
      resetPage<T>(state);
      break;
    }

    case 'type-value': {
      const newInputValue = action.value;
      const staticItems = state.staticItems;

      if (staticItems) {
        filterStaticItems<T>(state, newInputValue);
      } else {
        state.results = null;
      }

      state.error = 0;
      state.inputValue = newInputValue;
      state.selectedEntity = null;
      state.highlightedIndex = getFirstHighlightableIndex(state);
      if (state.highlightedIndex >= 0) {
        state.isOpen = true;
      }

      updateItems = true;
      updateStatusMessage = true;
      break;
    }

    default:
      /*:: exhaustive(action); */
      throw new Error('Unknown action: ' + action.type);
  }

  if (updateItems) {
    state.items = generateItems(state);
  }

  if (updateStatusMessage) {
    state.statusMessage = generateStatusMessage(state);
  }

  // Highlight the first item by default.
  const isOpen = state.isOpen;
  if (isOpen && (!wasOpen || state.highlightedIndex < 0)) {
    state.highlightedIndex = getFirstHighlightableIndex(state);
  } else if (wasOpen && !isOpen) {
    state.highlightedIndex = -1;
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
