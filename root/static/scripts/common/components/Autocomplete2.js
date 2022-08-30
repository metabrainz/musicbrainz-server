/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ENTITIES from '../../../../../entities.mjs';
import AddEntityDialog from '../../edit/components/AddEntityDialog.js';
import {
  DISPLAY_NONE_STYLE,
  MBID_REGEXP,
} from '../constants.js';
import useOutsideClickEffect from '../hooks/useOutsideClickEffect.js';
import clean from '../utility/clean.js';

import {
  CLOSE_ADD_ENTITY_DIALOG,
  HIDE_MENU,
  HIGHLIGHT_NEXT_ITEM,
  HIGHLIGHT_PREVIOUS_ITEM,
  SHOW_LOOKUP_ERROR,
  SHOW_LOOKUP_TYPE_ERROR,
  SHOW_MENU,
  SHOW_SEARCH_ERROR,
  STOP_SEARCH,
} from './Autocomplete2/actions.js';
import {
  ARIA_LIVE_STYLE,
  SEARCH_PLACEHOLDERS,
} from './Autocomplete2/constants.js';
import formatItem from './Autocomplete2/formatters.js';
import {getOrFetchRecentItems} from './Autocomplete2/recentItems.js';
import {
  defaultStaticItemsFilter,
  generateItems,
  generateStatusMessage,
} from './Autocomplete2/reducer.js';
import type {
  ActionT,
  EntityItemT,
  ItemT,
  OptionItemT,
  PropsT,
  StateT,
} from './Autocomplete2/types.js';

/*
 * `doSearch` performs a direct or indexed search (via /ws/js). This is the
 * default behavior if no `items` prop is given.
 */
function doSearch<T: EntityItemT>(
  dispatch: (ActionT<T>) => void,
  state: StateT<T>,
  xhr: {current: XMLHttpRequest | null},
) {
  const searchXhr = new XMLHttpRequest();
  xhr.current = searchXhr;

  searchXhr.addEventListener('load', () => {
    xhr.current = null;

    if (searchXhr.status !== 200) {
      dispatch(SHOW_SEARCH_ERROR);
      return;
    }

    const entities = JSON.parse(searchXhr.responseText);
    const pager = entities.pop();
    const newPage = parseInt(pager.current, 10);

    dispatch({
      entities,
      page: newPage,
      type: 'show-ws-results',
    });
  });

  const entityWebServicePath = state.entityType === 'editor'
    ? 'editor'
    : ENTITIES[state.entityType].url;

  if (entityWebServicePath == null) {
    throw new Error(
      'Can\'t build a web service URL for ' +
      JSON.stringify(state.entityType) +
      ' entities.',
    );
  }

  const url = (
    '/ws/js/' + entityWebServicePath +
    '/?q=' + encodeURIComponent(state.inputValue || '') +
    '&page=' + String(state.page) +
    '&direct=' + (state.indexedSearch ? 'false' : 'true')
  );

  searchXhr.open('GET', url);
  searchXhr.send();
}

function handleItemMouseDown(event: SyntheticMouseEvent<HTMLLIElement>) {
  event.preventDefault();
}

function setScrollPosition(menuId: string) {
  const menu = document.getElementById(menuId);
  if (!menu) {
    return;
  }
  const selectedItem = menu.querySelector('li[aria-selected=true]');
  if (!selectedItem) {
    return;
  }
  const position =
    (selectedItem.offsetTop + (selectedItem.offsetHeight / 2)) -
    menu.scrollTop;
  const middle = menu.offsetHeight / 2;
  if (position < middle) {
    menu.scrollTop -= (middle - position);
  }
  if (position > middle) {
    menu.scrollTop += (position - middle);
  }
}

type InitialStateT<T: EntityItemT> = {
  +activeUser?: ActiveEditorT,
  +canChangeType?: (string) => boolean,
  +entityType: T['entityType'],
  +id: string,
  +inputValue?: string,
  +placeholder?: string,
  +recentItemsKey?: string,
  +selectedEntity?: T | null,
  +staticItems?: $ReadOnlyArray<ItemT<T>>,
  +staticItemsFilter?: (ItemT<T>, string) => boolean,
  +width?: string,
};

const EMPTY_ITEMS: $ReadOnlyArray<ItemT<empty>> = Object.freeze([]);

export function createInitialState<+T: EntityItemT>(
  initialState: InitialStateT<T>,
): {...StateT<T>} {
  const {
    entityType,
    inputValue: initialInputValue,
    recentItemsKey,
    selectedEntity,
    staticItems,
    staticItemsFilter,
    ...restProps
  } = initialState;

  const inputValue =
    initialInputValue ?? (selectedEntity?.name) ?? '';

  let staticResults = staticItems ?? null;
  if (staticResults && nonEmpty(inputValue)) {
    const filter = staticItemsFilter || defaultStaticItemsFilter;
    staticResults = staticResults.filter(
      (item) => filter(item, inputValue),
    );
  }

  const state: {...StateT<T>} = {
    activeUser: null,
    entityType,
    error: 0,
    highlightedIndex: -1,
    indexedSearch: true,
    inputValue,
    isOpen: false,
    items: EMPTY_ITEMS,
    page: 1,
    pendingSearch: null,
    recentItems: null,
    recentItemsKey: recentItemsKey ?? entityType,
    results: staticResults,
    selectedEntity: selectedEntity ?? null,
    staticItems,
    staticItemsFilter,
    statusMessage: '',
    ...restProps,
  };

  state.items = generateItems(state);
  state.statusMessage = generateStatusMessage(state);

  return state;
}

type AutocompleteItemPropsT<T: EntityItemT> = {
  autocompleteId: string,
  isHighlighted: boolean,
  isSelected: boolean,
  item: ItemT<T>,
  selectItem: (ItemT<T>) => void,
};

const AutocompleteItem = React.memo(<+T: EntityItemT>({
  autocompleteId,
  isHighlighted,
  isSelected,
  item,
  selectItem,
}: AutocompleteItemPropsT<T>) => {
  const itemId = `${autocompleteId}-item-${item.id}`;
  const isDisabled = !!item.disabled;
  const isSeparator = !!item.separator;

  /*
   * `item.level` allows showing a hierarchy by indenting each option.
   * The first level (with normal padding) is 0. Each level increment
   * adds 8px to the left padding.
   */
  if (__DEV__) {
    invariant(item.level == null || item.level >= 0);
  }

  let style: ?{
    +paddingLeft?: string,
    +textAlign?: string,
  } = (item.level && item.level > 0)
    ? {paddingLeft: String(4 + (item.level * 8)) + 'px'}
    : null;

  if (item.action) {
    style = {textAlign: 'center'};
  }

  function handleItemClick() {
    if (!item.disabled) {
      selectItem(item);
    }
  }

  return (
    <li
      aria-disabled={isDisabled ? 'true' : 'false'}
      aria-selected={isHighlighted ? 'true' : 'false'}
      className={
        (isDisabled ? 'disabled ' : '') +
        (isHighlighted ? 'highlighted ' : '') +
        (isSelected ? 'selected ' : '') +
        (isSeparator ? 'separator ' : '') +
        `${item.type}-item `
      }
      id={itemId}
      key={item.id}
      onClick={handleItemClick}
      onMouseDown={handleItemMouseDown}
      role="option"
      style={style}
    >
      {formatItem<T>(item)}
    </li>
  );
});

const Autocomplete2 = (React.memo(<+T: EntityItemT>(
  props: PropsT<T>,
): React.Element<'div'> => {
  const {dispatch, state} = props;

  const {
    canChangeType,
    containerClass,
    disabled,
    entityType,
    highlightedIndex,
    id,
    inputValue,
    isAddEntityDialogOpen,
    isOpen,
    items,
    pendingSearch,
    recentItems,
    selectedEntity,
    staticItems,
    statusMessage,
  } = state;

  const xhr = React.useRef<XMLHttpRequest | null>(null);
  const inputRef = React.useRef<HTMLInputElement | null>(null);
  const buttonRef = React.useRef<HTMLButtonElement | null>(null);
  const inputTimeout = React.useRef<TimeoutID | null>(null);
  const containerRef = React.useRef<HTMLDivElement | null>(null);
  const shouldUpdateScrollPositionRef = React.useRef<boolean>(false);

  const highlightedItem = highlightedIndex >= 0
    ? (items[highlightedIndex] ?? null)
    : null;

  const stopRequests = React.useCallback(() => {
    if (xhr.current) {
      xhr.current.abort();
      xhr.current = null;
    }

    if (inputTimeout.current) {
      clearTimeout(inputTimeout.current);
      inputTimeout.current = null;
    }

    if (nonEmpty(pendingSearch)) {
      dispatch(STOP_SEARCH);
    }
  }, [dispatch, pendingSearch]);

  const selectItem = React.useCallback((item) => {
    if (!item.disabled) {
      stopRequests();
      dispatch({item, type: 'select-item'});
    }
  }, [stopRequests, dispatch]);

  function handleButtonClick(
    event: SyntheticMouseEvent<HTMLButtonElement>,
  ) {
    event.currentTarget.focus();

    stopRequests();

    if (isOpen) {
      dispatch(HIDE_MENU);
    } else {
      showAvailableItemsOrBeginLookupOrSearch();
    }
  }

  function handleBlur() {
    if (isOpen) {
      setTimeout(() => {
        const container = containerRef.current;
        if (container && !container.contains(document.activeElement)) {
          stopRequests();
          dispatch(HIDE_MENU);
        }
      }, 1);
    }
  }

  function handleInputChange(
    event: SyntheticKeyboardEvent<HTMLInputElement>,
  ) {
    const newInputValue = event.currentTarget.value;
    const newCleanInputValue = clean(newInputValue);

    dispatch({type: 'type-value', value: newInputValue});

    if (!newCleanInputValue) {
      stopRequests();
      return;
    }

    beginLookupOrSearch(inputValue, newCleanInputValue);
  }

  function beginLookupOrSearch(
    oldInputValue: string,
    newCleanInputValue: string,
  ) {
    const mbidMatch = newCleanInputValue.match(MBID_REGEXP);
    if (mbidMatch) {
      /*
       * The user pasted an MBID (or a URL containing one). Perform a
       * direct lookup.
       */
      stopRequests();

      if (staticItems) {
        const option = staticItems.find((item) => (
          item.type === 'option' &&
          hasOwnProp(item.entity, 'gid') &&
          // $FlowIgnore[prop-missing]
          item.entity.gid === mbidMatch[0]
        ));
        if (option) {
          selectItem(option);
        }
        return;
      }

      const lookupXhr = new XMLHttpRequest();
      xhr.current = lookupXhr;

      lookupXhr.addEventListener('load', () => {
        xhr.current = null;

        if (lookupXhr.status !== 200) {
          dispatch(SHOW_LOOKUP_ERROR);
          return;
        }

        const entity = JSON.parse(lookupXhr.responseText);
        const option: OptionItemT<T> = {
          entity,
          id: entity.id,
          name: entity.name,
          type: 'option',
        };

        if (entity.entityType === entityType) {
          selectItem(option);
        } else if (canChangeType && canChangeType(entity.entityType)) {
          dispatch({
            entityType: entity.entityType,
            type: 'change-entity-type',
          });
          selectItem(option);
        } else {
          dispatch(SHOW_LOOKUP_TYPE_ERROR);
        }
      });

      lookupXhr.open('GET', '/ws/js/entity/' + mbidMatch[0]);
      lookupXhr.send();
    } else if (clean(oldInputValue) !== newCleanInputValue) {
      stopRequests();
      dispatch({
        searchTerm: newCleanInputValue,
        type: 'search-after-timeout',
      });
    }
  }

  function handleInputFocus() {
    showAvailableItems();
  }

  function showAvailableItems() {
    if (items.length && !isOpen) {
      shouldUpdateScrollPositionRef.current = true;
      dispatch(SHOW_MENU);
      return true;
    }
    return false;
  }

  function showAvailableItemsOrBeginLookupOrSearch() {
    if (showAvailableItems()) {
      return;
    }
    /*
     * If there's an existing search term, there should be at least one
     * item even if there are no results (saying so). If there isn't,
     * the entity type probably changed; re-initiate the search with
     * the existing input value.
     */
    const cleanInputValue = clean(inputValue);
    if (cleanInputValue) {
      beginLookupOrSearch('', cleanInputValue);
    }
  }

  function handleInputKeyDown(
    event: SyntheticKeyboardEvent<HTMLInputElement | HTMLButtonElement>,
  ) {
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();

        if (isOpen) {
          shouldUpdateScrollPositionRef.current = true;
          dispatch(HIGHLIGHT_NEXT_ITEM);
        } else {
          showAvailableItemsOrBeginLookupOrSearch();
        }
        break;

      case 'ArrowUp':
        if (isOpen) {
          event.preventDefault();
          shouldUpdateScrollPositionRef.current = true;
          dispatch(HIGHLIGHT_PREVIOUS_ITEM);
        }
        break;

      case 'Enter': {
        if (isOpen) {
          event.preventDefault();
          if (highlightedItem) {
            selectItem(highlightedItem);
          }
        }
        break;
      }

      case 'Escape':
        stopRequests();
        if (isOpen) {
          event.preventDefault();
          dispatch(HIDE_MENU);
        }
        break;
    }
  }

  const handleMenuMouseDown = function (
    event: SyntheticMouseEvent<HTMLUListElement>,
  ) {
    /*
     * Clicking on the menu itself (including any scroll bar) should not
     * close the menu.  `preventDefault` here prevents a blur event on
     * the input.
     */
    event.preventDefault();
  };

  const handleOuterClick = React.useCallback(() => {
    stopRequests();
    if (isOpen) {
      dispatch(HIDE_MENU);
    }
  }, [stopRequests, isOpen, dispatch]);

  const closeAddEntityDialog = React.useCallback(() => {
    dispatch(CLOSE_ADD_ENTITY_DIALOG);
    setTimeout(function () {
      const input = inputRef.current;
      if (input) {
        input.focus();
      }
    }, 1);
  }, [dispatch, inputRef]);

  const addEntityDialogCallback = React.useCallback((entity: CoreEntityT) => {
    invariant(
      entity?.entityType === entityType,
      'Wrong type of entity received',
    );
    const item = {
      // $FlowIgnore[incompatible-cast]
      entity: (entity: T),
      id: entity.id,
      name: entity.name,
      type: 'option',
    };
    dispatch({item, type: 'select-item'});
    closeAddEntityDialog();
  }, [closeAddEntityDialog, dispatch, entityType]);

  const activeDescendant = highlightedItem
    ? `${id}-item-${highlightedItem.id}`
    : null;
  const inputId = `${id}-input`;
  const labelId = `${id}-label`;
  const menuId = `${id}-menu`;
  const statusId = `${id}-status`;

  useOutsideClickEffect(
    containerRef,
    handleOuterClick,
  );

  React.useEffect(() => {
    if (!recentItems) {
      getOrFetchRecentItems<T>(
        entityType,
        state.recentItemsKey,
      ).then((loadedRecentItems) => {
        dispatch({
          items: loadedRecentItems,
          type: 'set-recent-items',
        });
      });
    }

    if (
      !staticItems &&
      pendingSearch &&
      !inputTimeout.current &&
      !xhr.current
    ) {
      inputTimeout.current = setTimeout(() => {
        inputTimeout.current = null;

        const pendingSearchTerm = clean(pendingSearch);
        // Check if the input value has changed before proceeding.
        if (
          nonEmpty(pendingSearchTerm) &&
          pendingSearchTerm === clean(inputValue)
        ) {
          doSearch<T>(dispatch, state, xhr);
        }
      }, 300);
    }
  });

  React.useLayoutEffect(() => {
    if (shouldUpdateScrollPositionRef.current) {
      setScrollPosition(menuId);
      shouldUpdateScrollPositionRef.current = false;
    }
  });

  type AutocompleteItemComponent<T> =
    React$AbstractComponent<AutocompleteItemPropsT<T>, void>;

  // XXX Until Flow supports https://github.com/facebook/flow/issues/7672
  const AutocompleteItemWithType: AutocompleteItemComponent<T> =
    (AutocompleteItem: any);

  const menuItemElements = React.useMemo(
    () => items.map((item) => (
      <AutocompleteItemWithType
        autocompleteId={id}
        isHighlighted={!!(highlightedItem && item.id === highlightedItem.id)}
        isSelected={!!(
          selectedEntity &&
          item.type === 'option' &&
          item.entity.id === selectedEntity.id
        )}
        item={item}
        key={item.id}
        selectItem={selectItem}
      />
    )),
    [
      highlightedItem,
      id,
      items,
      selectItem,
      selectedEntity,
    ],
  );

  return (
    <div
      className={
        'autocomplete2' + (containerClass ? ' ' + containerClass : '')}
      onBlur={handleBlur}
      ref={node => {
        containerRef.current = node;
      }}
      style={state.width ? {width: state.width} : null}
    >
      <label
        className={state.labelClass}
        htmlFor={inputId}
        id={labelId}
        style={DISPLAY_NONE_STYLE}
      >
        {state.placeholder || SEARCH_PLACEHOLDERS[entityType]()}
      </label>
      <div
        aria-expanded={isOpen ? 'true' : 'false'}
        aria-haspopup="listbox"
        aria-owns={menuId}
        role="combobox"
      >
        <input
          aria-activedescendant={activeDescendant}
          aria-autocomplete="list"
          aria-controls={menuId}
          aria-labelledby={labelId}
          autoComplete="off"
          className={
            (
              state.isLookupPerformed == null
                ? selectedEntity
                : state.isLookupPerformed
            )
              ? 'lookup-performed'
              : ''}
          disabled={disabled}
          id={inputId}
          onChange={handleInputChange}
          onClick={handleInputFocus}
          onFocus={handleInputFocus}
          onKeyDown={handleInputKeyDown}
          placeholder={
            state.placeholder || l('Type to search, or paste an MBID')
          }
          ref={inputRef}
          value={inputValue}
        />
        <button
          aria-activedescendant={activeDescendant}
          aria-autocomplete="list"
          aria-controls={menuId}
          aria-haspopup="true"
          aria-label={l('Search')}
          className={
            'search' +
            ((
              pendingSearch &&
              !disabled &&
              /*
               * Lookups for static item lists complete near-instantly,
               * so flashing a loading spinner is obnoxious.
               */
              !staticItems
            ) ? ' loading' : '')
          }
          data-toggle="true"
          disabled={disabled}
          onClick={handleButtonClick}
          onKeyDown={handleInputKeyDown}
          ref={buttonRef}
          role="button"
          title={l('Search')}
          type="button"
        />
        {props.children}
      </div>

      <ul
        aria-controls={statusId}
        aria-labelledby={labelId}
        id={menuId}
        onMouseDown={handleMenuMouseDown}
        role="listbox"
        style={{
          visibility: (isOpen && !disabled)
            ? 'visible'
            : 'hidden',
        }}
      >
        {disabled ? null : menuItemElements}
      </ul>

      <div
        aria-live="assertive"
        aria-relevant="additions text"
        id={statusId}
        role="status"
        style={ARIA_LIVE_STYLE}
      >
        {statusMessage}
      </div>

      {isAddEntityDialogOpen ? (
        <AddEntityDialog
          callback={addEntityDialogCallback}
          close={closeAddEntityDialog}
          entityType={entityType}
          name={inputValue}
        />
      ) : null}
    </div>
  );
}): React$AbstractComponent<PropsT<any>, void>);

export default Autocomplete2;
