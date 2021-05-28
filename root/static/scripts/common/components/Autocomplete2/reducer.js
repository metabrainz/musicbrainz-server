/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  TITLES as ADD_NEW_ENTITY_TITLES,
} from '../../../edit/components/AddEntityDialog';
import {unwrapNl} from '../../i18n';
import {
  isLocationEditor,
  isRelationshipEditor,
} from '../../utility/privileges';

import {
  OPEN_ADD_ENTITY_DIALOG,
  SEARCH_AGAIN,
} from './actions';
import {
  CLEAR_RECENT_ITEMS,
  ERROR_LOOKUP,
  ERROR_LOOKUP_TYPE,
  ERROR_SEARCH,
  IS_TOP_WINDOW,
  MENU_ITEMS,
  PAGE_SIZE,
  RECENT_ITEMS_HEADER,
} from './constants';
import type {
  ActionT,
  EntityItemT,
  ItemT,
  SearchActionT,
  StateT,
} from './types';
import {
  clearRecentItems,
  pushRecentItem,
} from './recentItems';

function initSearch<+T: EntityItemT>(
  state: {...StateT<T>},
  action: SearchActionT,
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

export function generateItems<+T: EntityItemT>(
  state: StateT<T>,
): $ReadOnlyArray<ItemT<T>> {
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
      if (determineIfUserCanAddEntities(state)) {
        items.push({
          action: OPEN_ADD_ENTITY_DIALOG,
          id: 'add-new-entity',
          name: ADD_NEW_ENTITY_TITLES[state.entityType](),
          type: 'action',
        });
      }
    }
  }

  return items;
}

export function determineIfUserCanAddEntities<+T: EntityItemT>(
  state: StateT<T>,
): boolean {
  const user = state.activeUser;

  if (!user || !IS_TOP_WINDOW) {
    return false;
  }
  switch (state.entityType) {
    case 'area':
      return isLocationEditor(user);
    case 'instrument':
      return isRelationshipEditor(user);
    default:
      return true;
  }
}

function getFirstHighlightableIndex<+T: EntityItemT>(
  state: StateT<T>,
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

export function generateStatusMessage<+T: EntityItemT>(
  state: StateT<T>,
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

export function filterStaticItems<+T: EntityItemT>(
  state: {...StateT<T>},
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
        (accum: Array<ItemT<T>>, item: ItemT<T>) => {
          if (filter(item, newInputValue)) {
            accum.push(item);
          }
          return accum;
        },
        [],
    ): $ReadOnlyArray<ItemT<T>>)
    : itemsToFilter;
}

export function resetPage<+T: EntityItemT>(
  state: {...StateT<T>},
): void {
  state.highlightedIndex = -1;
  state.isOpen = false;
  state.page = 1;
  state.error = 0;
}

function selectItem<+T: EntityItemT>(
  state: {...StateT<T>},
  item: ItemT<T>,
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

function setError<+T: EntityItemT>(
  state: {...StateT<T>},
  error: number,
) {
  state.error = error;
  state.isOpen = true;
}

function highlightNextItem<+T: EntityItemT>(
  state: {...StateT<T>},
  startingIndex: number,
  offset: number,
) {
  const items = state.items;
  let index = startingIndex;
  let count = items.length;

  while (true) {
    if (index < 0) {
      index = items.length - 1;
    } else if (index >= items.length) {
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
    index += offset;
  }
}

export function defaultStaticItemsFilter<+T: EntityItemT>(
  item: ItemT<T>,
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
export function runReducer<+T: EntityItemT>(
  state: {...StateT<T>},
  action: ActionT<T>,
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
      highlightNextItem<T>(
        state,
        state.highlightedIndex + 1,
        1,
      );
      updateStatusMessage = true;
      break;
    }

    case 'highlight-previous-item': {
      highlightNextItem<T>(
        state,
        state.highlightedIndex >= 0
          ? (state.highlightedIndex - 1)
          : (state.items.length - 1),
        -1,
      );
      updateStatusMessage = true;
      break;
    }

    case 'noop':
      break;

    case 'toggle-add-entity-dialog': {
      state.isAddEntityDialogOpen = action.isOpen;
      break;
    }

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

      let newResults: Array<ItemT<T>> = entities.map((entity: T) => ({
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

        if (nonEmpty(newInputValue)) {
          // We'll display "(No results)" even if `results` is null.
          state.isOpen = true;
        }
      } else {
        state.results = null;
      }

      state.error = 0;
      state.inputValue = newInputValue;
      state.selectedEntity = null;
      state.highlightedIndex = -1;

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

    if (!state.items.length) {
      state.isOpen = false;
    }
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

export default function reducer<+T: EntityItemT>(
  state: StateT<T>,
  action: ActionT<T>,
): StateT<T> {
  if (action.type === 'noop') {
    return state;
  }

  const nextState = {...state};
  runReducer<T>(nextState, action);
  return nextState;
}
