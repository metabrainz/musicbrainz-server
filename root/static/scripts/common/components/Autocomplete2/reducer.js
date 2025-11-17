/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  TITLES as ADD_NEW_ENTITY_TITLES,
} from '../../../edit/components/AddEntityDialog.js';
import {unwrapNl} from '../../i18n.js';
import {getCatalystContext} from '../../utility/catalyst.js';
import {
  isLocationEditor,
  isRelationshipEditor,
} from '../../utility/privileges.js';
import setCookie from '../../utility/setCookie.js';

import {
  OPEN_ADD_ENTITY_DIALOG,
  SEARCH_AGAIN,
} from './actions.js';
import {
  CLEAR_RECENT_ITEMS,
  ERROR_LOOKUP,
  ERROR_LOOKUP_TYPE,
  ERROR_SEARCH,
  IS_TOP_WINDOW,
  MENU_ITEMS,
  PAGE_SIZE,
  RECENT_ITEMS_HEADER,
} from './constants.js';
import {
  clearRecentItems,
  pushRecentItem,
} from './recentItems.js';
import searchItems from './searchItems.js';
import type {
  ActionT,
  EntityItemT,
  ItemT,
  SearchActionT,
  StateT,
} from './types.js';

function initSearch<T: EntityItemT>(
  state: {...StateT<T>},
  action: SearchActionT,
) {
  if (action.indexed !== undefined) {
    state.indexedSearch = action.indexed;
  }

  let searchTerm;
  if (Object.hasOwn(action, 'searchTerm')) {
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

export function generateItems<T: EntityItemT>(
  state: StateT<T>,
): $ReadOnlyArray<ItemT<T>> {
  const items: Array<ItemT<T>> = [];

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
    entityType,
    page,
    recentItems,
    results,
    showDescriptions = true,
  } = state;

  const isInputValueNonEmpty = nonEmpty(state.inputValue);
  const hasStaticItems = Boolean(state.staticItems);
  const hasSelection = state.selectedItem != null;
  const showingRecentItems = !isInputValueNonEmpty &&
    Boolean(recentItems?.length);

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
      const totalPages = state.totalPages ??
        Math.ceil(resultCount / PAGE_SIZE);

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

      if (
        entityType === 'link_attribute_type' ||
        entityType === 'link_type'
      ) {
        items.push({
          action: {
            showDescriptions: !showDescriptions,
            type: 'toggle-descriptions',
          },
          id: 'toggle-descriptions',
          name:
            showDescriptions
              ? l('Hide descriptions')
              : l('Show descriptions'),
          separator: true,
          type: 'action',
        });
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
      if (
        determineIfUserCanAddEntities(state) &&
        typeof ADD_NEW_ENTITY_TITLES[state.entityType] === 'function'
      ) {
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

export function determineIfUserCanAddEntities<T: EntityItemT>(
  state: StateT<T>,
): boolean {
  const user = getCatalystContext().user;

  if (!user || !IS_TOP_WINDOW) {
    return false;
  }
  return match (state) {
    {entityType: 'area', ...} => isLocationEditor(user),
    {
      entityType:
        | 'editor'
        | 'genre'
        | 'link_type'
        | 'link_attribute_type'
        | 'release',
      ...
    } => false,
    {entityType: 'instrument', ...} => isRelationshipEditor(user),
    _ => true,
  };
}

function getFirstHighlightableIndex<T: EntityItemT>(
  state: StateT<T>,
): number {
  const items = state.items;
  let index = 0;
  for (const item of items) {
    // $FlowFixMe[sketchy-null-bool]
    if (!item.disabled) {
      return index;
    }
    index++;
  }
  return -1;
}

export function generateStatusMessage<T: EntityItemT>(
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
  } else if (state.selectedItem) {
    return unwrapNl<string>(state.selectedItem.name);
  }

  return '';
}

export function filterStaticItems<T: EntityItemT>(
  state: {...StateT<T>},
  newInputValue: string,
): void {
  const staticItems = state.staticItems;
  invariant(staticItems);
  state.results = searchItems(staticItems, newInputValue);
}

export function resetPage<T: EntityItemT>(
  state: {...StateT<T>},
): void {
  state.highlightedIndex = -1;
  state.isOpen = false;
  state.page = 1;
  state.totalPages = null;
  state.error = 0;
}

function selectItem<T: EntityItemT>(
  state: {...StateT<T>},
  item: ItemT<T>,
) {
  match (item) {
    {type: 'action', const action, ...} => {
      runReducer<T>(state, action);
      return;
    }
    {type: 'option', ...} as item => {
      const itemName = unwrapNl<string>(item.name);

      state.selectedItem = item;

      if (itemName !== state.inputValue) {
        if (state.staticItems) {
          filterStaticItems<T>(state, itemName);
        }
        state.inputValue = itemName;
      }

      if (!state.staticItems) {
        state.results = null;
      }

      resetPage<T>(state);

      state.recentItems = pushRecentItem(
        item,
        state.recentItemsKey,
      );
    },
    {type: 'header', ...} => {
      // Do nothing
    },
  }

  state.isOpen = false;
  state.pendingSearch = null;
}

function setError<T: EntityItemT>(
  state: {...StateT<T>},
  error: number,
) {
  state.error = error;
  state.isOpen = true;
}

function highlightNextItem<T: EntityItemT>(
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
    // $FlowFixMe[sketchy-null-bool]
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

// `runReducer` should only be run on a copy of the existing state.
export function runReducer<T: EntityItemT>(
  state: {...StateT<T>},
  action: ActionT<T>,
): void {
  const wasOpen = state.isOpen;
  let updateItems = false;
  let updateStatusMessage = false;
  let highlightFirstIndex = false;
  let showAvailableItems = false;

  match (action) {
    {type: 'change-entity-type', const entityType} => {
      const oldEntityType = state.entityType;
      state.entityType = entityType;
      state.selectedItem = null;
      state.recentItems = null;
      if (state.recentItemsKey === oldEntityType) {
        state.recentItemsKey = entityType;
      }
      state.results = null;
      resetPage<T>(state);
      updateItems = true;
      updateStatusMessage = true;
    }

    {type: 'highlight-index', const index} => {
      state.highlightedIndex = index;
      updateStatusMessage = true;
    }

    {type: 'highlight-next-item'} => {
      highlightNextItem<T>(
        state,
        state.highlightedIndex + 1,
        1,
      );
      updateStatusMessage = true;
    }

    {type: 'highlight-previous-item'} => {
      highlightNextItem<T>(
        state,
        state.highlightedIndex >= 0
          ? (state.highlightedIndex - 1)
          : (state.items.length - 1),
        -1,
      );
      updateStatusMessage = true;
    }

    {type: 'toggle-add-entity-dialog', const isOpen} => {
      state.isAddEntityDialogOpen = isOpen;
    }

    {type: 'search-after-timeout', ...} as action => {
      state.page = 1;
      initSearch<T>(state, action);
    }

    {type: 'select-item', const item} => {
      selectItem<T>(state, item);
      updateItems = true;
      updateStatusMessage = true;
    }

    {type: 'set-input-focus', const isFocused} => {
      state.isInputFocused = isFocused;
      if (isFocused && state.selectedItem == null) {
        showAvailableItems = true;
        if (!state.items.length && state.recentItems?.length) {
          updateItems = true;
        }
      }
    }

    {type: 'set-menu-visibility', const value} => {
      state.isOpen = value && state.items.length > 0;
      updateStatusMessage = true;
    }

    {type: 'show-lookup-error'} => {
      setError<T>(state, ERROR_LOOKUP);
      updateItems = true;
      updateStatusMessage = true;
    }

    {type: 'show-lookup-type-error'} => {
      setError<T>(state, ERROR_LOOKUP_TYPE);
      updateItems = true;
      updateStatusMessage = true;
    }

    {type: 'show-ws-results', ...} as action => {
      const {entities, page, totalPages} = action;

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
        /*
         * Keep the previous `highlightedIndex` position here (most likely
         * where "Show more" was clicked).
         */
      } else {
        highlightFirstIndex = true;
      }

      state.results = newResults;
      state.isOpen = true;
      state.page = page;
      state.totalPages = totalPages;
      state.pendingSearch = null;
      state.error = 0;

      updateItems = true;
      updateStatusMessage = true;
    }

    {type: 'set-recent-items', const items} => {
      state.recentItems = items;

      const staticItems = state.staticItems;
      if (staticItems) {
        state.recentItems = state.recentItems.filter(
          (recentItem) => staticItems.find((staticItem) => (
            staticItem.entity.id === recentItem.entity.id
          )),
        );
      }

      updateItems = true;

      if (
        state.isInputFocused &&
        empty(state.inputValue) &&
        state.recentItems?.length
      ) {
        showAvailableItems = true;
      }
    }

    {type: 'clear-recent-items'} => {
      clearRecentItems(state.recentItemsKey);
      state.recentItems = [];
      state.highlightedIndex = -1;
      updateItems = true;
    }

    {type: 'show-search-error'} => {
      setError<T>(state, ERROR_SEARCH);
      state.pendingSearch = null;
      updateItems = true;
      updateStatusMessage = true;
    }

    {type: 'show-more-results'} => {
      state.page++;
      if (!state.staticItems) {
        initSearch<T>(state, SEARCH_AGAIN);
      }
    }

    {type: 'stop-search'} => {
      state.pendingSearch = null;
    }

    {type: 'toggle-descriptions', const showDescriptions} => {
      state.showDescriptions = showDescriptions;
      setCookie('show_autocomplete_descriptions', state.showDescriptions);
    }

    {type: 'toggle-indexed-search'} => {
      state.indexedSearch = !state.indexedSearch;
      state.page = 1;
      state.isOpen = false;
      initSearch<T>(state, SEARCH_AGAIN);
    }

    {type: 'reset-menu'} => {
      resetPage<T>(state);
    }

    {type: 'type-value', const value} => {
      const newInputValue = value;
      const staticItems = state.staticItems;

      if (staticItems) {
        filterStaticItems<T>(state, newInputValue);

        if (nonEmpty(newInputValue)) {
          // We'll display "(No results)" even if `results` is null.
          state.isOpen = true;
          highlightFirstIndex = true;
        }
      } else {
        state.results = null;
      }

      state.error = 0;
      state.inputValue = newInputValue;
      state.selectedItem = null;
      state.highlightedIndex = -1;

      updateItems = true;
      updateStatusMessage = true;
      showAvailableItems = true;
    }
  }

  if (updateItems) {
    state.items = generateItems(state);

    if (!state.items.length) {
      state.isOpen = false;
    }
  }

  if (showAvailableItems && state.items.length) {
    state.isOpen = true;
  }

  if (updateStatusMessage) {
    state.statusMessage = generateStatusMessage(state);
  }

  const isOpen = state.isOpen;
  if (isOpen && highlightFirstIndex) {
    state.highlightedIndex = getFirstHighlightableIndex(state);
  } else if (wasOpen && !isOpen) {
    state.highlightedIndex = -1;
  }
}

export default function reducer<T: EntityItemT>(
  state: StateT<T>,
  action: ActionT<T>,
): StateT<T> {
  const nextState = {...state};
  runReducer<T>(nextState, action);
  return nextState;
}
