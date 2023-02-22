/*
 * @flow strict
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
import {unwrapNl} from '../i18n.js';
import clean from '../utility/clean.js';
import getCookie from '../utility/getCookie.js';
import isBlank from '../utility/isBlank.js';

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
import formatItem, {
  type FormatOptionsT,
} from './Autocomplete2/formatters.js';
import {getOrFetchRecentItems} from './Autocomplete2/recentItems.js';
import {
  generateItems,
  generateStatusMessage,
} from './Autocomplete2/reducer.js';
import searchItems, {
  getItemName,
  indexItems,
} from './Autocomplete2/searchItems.js';
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
    const pager: {+current: StrOrNum, +pages: StrOrNum} = entities.pop();
    const newPage = parseInt(pager.current, 10);
    const totalPages = parseInt(pager.pages, 10);

    dispatch({
      entities,
      page: newPage,
      totalPages,
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
  +canChangeType?: (string) => boolean,
  +containerClass?: string,
  +disabled?: boolean,
  +entityType: T['entityType'],
  +extractSearchTerms?: (OptionItemT<T>) => Array<string>,
  +id: string,
  +inputChangeHook?: (
    inputValue: string,
    state: StateT<T>,
    selectItem: (OptionItemT<T>) => boolean,
  ) => boolean,
  +inputClass?: string,
  +inputValue?: string,
  +labelStyle?: {...},
  +placeholder?: string,
  +recentItemsKey?: string,
  +required?: boolean,
  +selectedItem?: OptionItemT<T> | null,
  +staticItems?: $ReadOnlyArray<OptionItemT<T>>,
  +width?: string,
};

const EMPTY_ITEMS: $ReadOnlyArray<ItemT<empty>> = Object.freeze([]);

export function createInitialState<+T: EntityItemT>(
  initialState: InitialStateT<T>,
): {...StateT<T>} {
  const {
    disabled = false,
    entityType,
    extractSearchTerms = getItemName,
    inputValue: initialInputValue,
    recentItemsKey,
    required = false,
    selectedItem,
    staticItems,
    ...restProps
  } = initialState;

  const inputValue =
    initialInputValue ??
    (selectedItem == null ? null : unwrapNl<string>(selectedItem.name)) ??
    '';

  if (staticItems) {
    indexItems(staticItems, extractSearchTerms);
  }

  let staticResults = staticItems ?? null;
  if (staticResults && nonEmpty(inputValue)) {
    staticResults = searchItems(staticResults, inputValue);
  }

  const state: {...StateT<T>} = {
    disabled,
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
    required,
    results: staticResults,
    selectedItem: selectedItem ?? null,
    showDescriptions:
      getCookie('show_autocomplete_descriptions') !== 'false',
    staticItems,
    statusMessage: '',
    totalPages: null,
    ...restProps,
  };

  state.items = generateItems(state);
  state.statusMessage = generateStatusMessage(state);

  return state;
}

type AutocompleteItemPropsT<T: EntityItemT> = {
  autocompleteId: string,
  dispatch: (ActionT<T>) => void,
  formatOptions?: ?FormatOptionsT,
  index: number,
  isHighlighted: boolean,
  isSelected: boolean,
  item: ItemT<T>,
  selectItem: (ItemT<T>) => boolean,
};

const AutocompleteItem = React.memo(<+T: EntityItemT>({
  autocompleteId,
  dispatch,
  formatOptions,
  index,
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
  } = (item.level != null && item.level > 0)
    ? {paddingLeft: String(4 + (item.level * 8)) + 'px'}
    : null;

  if (item.action) {
    style = {textAlign: 'center'};
  }

  function handleItemClick() {
    if (!isDisabled) {
      selectItem(item);
    }
  }

  function handleItemMouseOver() {
    if (item.disabled !== true) {
      dispatch({index, type: 'highlight-index'});
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
      onMouseOver={handleItemMouseOver}
      role="option"
      style={style}
    >
      {formatItem<T>(item, formatOptions)}
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
    disabled = false,
    entityType,
    highlightedIndex,
    id,
    inputChangeHook,
    inputValue,
    isAddEntityDialogOpen = false,
    isOpen,
    items,
    pendingSearch,
    recentItems,
    selectedItem,
    staticItems,
    statusMessage,
  } = state;

  const xhr = React.useRef<XMLHttpRequest | null>(null);
  const inputRef = React.useRef<HTMLInputElement | null>(null);
  const buttonRef = React.useRef<HTMLButtonElement | null>(null);
  const inputTimeout = React.useRef<TimeoutID | null>(null);
  const containerRef = React.useRef<HTMLDivElement | null>(null);
  const shouldUpdateScrollPositionRef = React.useRef<boolean>(false);
  const recentItemsPromise =
    React.useRef<Promise<$ReadOnlyArray<OptionItemT<T>>> | null>(null);

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
    const isDisabled = !!item.disabled;

    if (!isDisabled) {
      stopRequests();
      if (item.type === 'option') {
        const newEntityType = item.entity.entityType;
        if (newEntityType !== entityType) {
          if (canChangeType?.(newEntityType)) {
            dispatch({
              entityType: newEntityType,
              type: 'change-entity-type',
            });
          } else {
            return false;
          }
        }
      }
      dispatch({item, type: 'select-item'});
      return true;
    }
    return false;
  }, [
    stopRequests,
    entityType,
    canChangeType,
    dispatch,
  ]);

  function handleButtonClick() {
    inputRef.current?.focus();

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

    dispatch({type: 'type-value', value: newInputValue});

    if (isBlank(newInputValue)) {
      stopRequests();
      return;
    }

    if (
      inputChangeHook != null &&
      inputChangeHook(
        newInputValue,
        state,
        selectItem,
      )
    ) {
      return;
    }

    beginLookupOrSearch(inputValue, newInputValue);
  }

  function beginLookupOrSearch(
    oldInputValue: string,
    newInputValue: string,
  ) {
    const mbidMatch = newInputValue.match(MBID_REGEXP);
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

        if (!selectItem(option)) {
          dispatch(SHOW_LOOKUP_TYPE_ERROR);
        }
      });

      lookupXhr.open('GET', '/ws/js/entity/' + mbidMatch[0]);
      lookupXhr.send();
    } else if (oldInputValue !== newInputValue) {
      stopRequests();
      dispatch({
        searchTerm: clean(newInputValue),
        type: 'search-after-timeout',
      });
    }
  }

  function handleInputFocus() {
    if (selectedItem == null) {
      showAvailableItems();
    }
  }

  async function showAvailableItems() {
    const recentItems = await recentItemsPromise.current;
    /*
     * Normally `items` should comprise `recentItems` after the
     * `set-recent-items` action runs, but this event may trigger before that
     * action is run and thus while `items` has yet to be updated.
     */
    if (
      (
        items.length ||
        (
          /*
           * Recent items are only shown if the input is empty.
           * (See `generateItems` in ./reducer.js.)
           */
          empty(state.inputValue) &&
          recentItems?.length
        )
      ) &&
      !isOpen
    ) {
      shouldUpdateScrollPositionRef.current = true;
      dispatch(SHOW_MENU);
      return true;
    }
    return false;
  }

  async function showAvailableItemsOrBeginLookupOrSearch() {
    if (await showAvailableItems()) {
      return;
    }
    /*
     * If there's an existing search term, there should be at least one
     * item even if there are no results (saying so). If there isn't,
     * the entity type probably changed; re-initiate the search with
     * the existing input value.
     */
    if (!isBlank(inputValue)) {
      beginLookupOrSearch('', inputValue);
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

      case 'Enter':
      case 'Tab': {
        if (isOpen && highlightedItem) {
          event.preventDefault();
          selectItem(highlightedItem);
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

  const recentItemsNotLoaded = recentItems == null;

  React.useEffect(() => {
    let cancelled = false;
    if (recentItemsNotLoaded) {
      recentItemsPromise.current = getOrFetchRecentItems<T>(
        entityType,
        state.recentItemsKey,
      ).then((loadedRecentItems) => {
        if (cancelled) {
          return [];
        }
        setTimeout(() => {
          dispatch({
            items: loadedRecentItems,
            type: 'set-recent-items',
          });
        }, 1);
        return loadedRecentItems;
      });
    }
    return () => {
      cancelled = true;
    };
  }, [
    recentItemsNotLoaded,
    dispatch,
    entityType,
    state.recentItemsKey,
  ]);

  React.useEffect(() => {
    if (
      !staticItems &&
      nonEmpty(pendingSearch) &&
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

    return () => {
      clearTimeout(inputTimeout.current);
    };
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
    // $FlowIssue[unclear-type]
    (AutocompleteItem: any);

  const menuItemElements = React.useMemo(
    () => items.map((item, index) => (
      <AutocompleteItemWithType
        autocompleteId={id}
        dispatch={dispatch}
        formatOptions={
          (
            entityType === 'link_attribute_type' ||
            entityType === 'link_type'
          )
            ? {showDescriptions: state.showDescriptions}
            : undefined
        }
        index={index}
        isHighlighted={!!(highlightedItem && item.id === highlightedItem.id)}
        isSelected={!!(
          selectedItem &&
          item.type === 'option' &&
          item.entity.id === selectedItem.id
        )}
        item={item}
        key={item.id}
        selectItem={selectItem}
      />
    )),
    [
      dispatch,
      entityType,
      highlightedItem,
      id,
      items,
      selectItem,
      selectedItem,
      state.showDescriptions,
    ],
  );

  const isLookupPerformed = (
    state.isLookupPerformed == null
      ? (selectedItem != null)
      : state.isLookupPerformed
  );

  return (
    <div
      className={
        'autocomplete2' +
        (nonEmpty(containerClass) ? ' ' + containerClass : '')}
      onBlur={handleBlur}
      ref={node => {
        containerRef.current = node;
      }}
      style={nonEmpty(state.width) ? {width: state.width} : null}
    >
      <label
        className={state.labelClass}
        htmlFor={inputId}
        id={labelId}
        style={state.labelStyle || DISPLAY_NONE_STYLE}
      >
        {addColonText(
          nonEmpty(state.placeholder)
            ? state.placeholder
            : SEARCH_PLACEHOLDERS[entityType](),
        )}
      </label>
      <div
        aria-expanded={isOpen ? 'true' : 'false'}
        aria-haspopup="listbox"
        aria-owns={menuId}
        className={state.required ? 'required' : undefined}
        role="combobox"
      >
        <input
          aria-activedescendant={activeDescendant}
          aria-autocomplete="list"
          aria-controls={menuId}
          aria-labelledby={labelId}
          aria-required={state.required ? 'true' : 'false'}
          autoComplete="off"
          className={
            (
              state.inputClass == null
                ? ''
                : (state.inputClass + ' ')
            ) +
            (
              isLookupPerformed
                ? 'lookup-performed'
                : (state.required ? 'required' : '')
            )
          }
          disabled={disabled}
          id={inputId}
          onChange={handleInputChange}
          onClick={handleInputFocus}
          onFocus={handleInputFocus}
          onKeyDown={handleInputKeyDown}
          placeholder={
            nonEmpty(state.placeholder)
              ? state.placeholder
              : l('Type to search, or paste an MBID')
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
              nonEmpty(pendingSearch) &&
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
          ref={buttonRef}
          role="button"
          tabIndex="-1"
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
        tabIndex="-1"
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
// $FlowIgnore[unclear-type]
}): React$AbstractComponent<PropsT<any>, void>);

export default Autocomplete2;
