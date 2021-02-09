/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ENTITIES from '../../../../../entities';
import {MBID_REGEXP} from '../constants';
import useOutsideClickEffect from '../hooks/useOutsideClickEffect';
import {unwrapNl} from '../i18n';
import clean from '../utility/clean';

import {
  HIDE_MENU,
  HIGHLIGHT_NEXT_ITEM,
  HIGHLIGHT_PREVIOUS_ITEM,
  SHOW_LOOKUP_ERROR,
  SHOW_LOOKUP_TYPE_ERROR,
  SHOW_MENU,
  SHOW_SEARCH_ERROR,
  STOP_SEARCH,
} from './Autocomplete2/actions';
import {
  ARIA_LIVE_STYLE,
  DISPLAY_NONE_STYLE,
  EMPTY_ARRAY,
  MENU_ITEMS,
  SEARCH_PLACEHOLDERS,
} from './Autocomplete2/constants';
import formatItem from './Autocomplete2/formatters';
import type {
  Actions,
  EntityItem,
  Item,
  Props,
  State,
} from './Autocomplete2/types';

/*
 * If the autocomplete is provided an `items` prop, it's assumed that it
 * contains the complete list of searchable options. In that case, we filter
 * them based on a simple substring match via `doFilter`.
 */
function doFilter<T: EntityItem>(
  dispatch: (Actions<T>) => void,
  items: $ReadOnlyArray<Item<T>>,
  searchTerm: string,
) {
  let results = items;
  let resultCount = results.length;

  if (searchTerm) {
    results = items.filter(item => (
      unwrapNl<string>(item.name)
        .toLowerCase()
        .includes(searchTerm.toLowerCase())
    ));
    resultCount = results.length;
    if (!resultCount) {
      results.push(MENU_ITEMS.NO_RESULTS);
    }
  }

  dispatch({
    items: results,
    page: 1,
    resultCount,
    type: 'show-results',
  });
}

/*
 * `doSearch` performs a direct or indexed search (via /ws/js). This is the
 * default behavior if no `items` prop is given.
 */
function doSearch<T: EntityItem>(
  dispatch: (Actions<T>) => void,
  props: Props<T>,
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

    const actions = [];
    let newItems = JSON.parse(searchXhr.responseText);
    const pager = newItems.pop();
    const newPage = parseInt(pager.current, 10);
    const totalPages = parseInt(pager.pages, 10);

    if (newItems.length) {
      if (newPage < totalPages) {
        actions.push(MENU_ITEMS.SHOW_MORE);
      }
    } else if (newPage === 1) {
      actions.push(MENU_ITEMS.NO_RESULTS);
    }

    actions.push(props.indexedSearch
      ? MENU_ITEMS.TRY_AGAIN_DIRECT
      : MENU_ITEMS.TRY_AGAIN_INDEXED);

    const prevItems: Array<T> = [];
    const prevItemIds = new Set();
    for (const item of props.items) {
      if (!item.action) {
        prevItems.push(item);
        prevItemIds.add(item.id);
      }
    }

    newItems = newPage > 1
      ? prevItems.concat(newItems.filter(x => !prevItemIds.has(x.id)))
      : newItems;

    dispatch({
      items: newItems.concat(actions),
      page: newPage,
      resultCount: newItems.length,
      type: 'show-results',
    });
  });

  const url = (
    '/ws/js/' + ENTITIES[props.entityType].url +
    '/?q=' + encodeURIComponent(props.inputValue || '') +
    '&page=' + String(props.page) +
    '&direct=' + (props.indexedSearch ? 'false' : 'true')
  );

  searchXhr.open('GET', url);
  searchXhr.send();
}

function doSearchOrFilter<T: EntityItem>(
  dispatch: (Actions<T>) => void,
  items: ?$ReadOnlyArray<Item<T>>,
  searchTerm: string,
) {
  if (items) {
    doFilter<T>(dispatch, items, searchTerm);
  } else if (searchTerm) {
    dispatch({searchTerm, type: 'search-after-timeout'});
  }
}

function handleItemMouseDown(event) {
  event.preventDefault();
}

function setScrollPosition(
  menuId: string,
  siblingAccessor: 'nextElementSibling' | 'previousElementSibling',
) {
  const menu = document.getElementById(menuId);
  if (!menu) {
    return;
  }
  const selectedItem = menu.querySelector('li[aria-selected=true]');
  if (!selectedItem) {
    return;
  }
  // $FlowIssue[prop-missing]
  const item = selectedItem[siblingAccessor];
  if (!item) {
    return;
  }
  const position =
    (item.offsetTop + (item.offsetHeight / 2)) - menu.scrollTop;
  const middle = menu.offsetHeight / 2;
  if (position < middle) {
    menu.scrollTop -= (middle - position);
  }
  if (position > middle) {
    menu.scrollTop += (position - middle);
  }
}

type InitialPropsT<+T: EntityItem> = {
  +canChangeType?: (string) => boolean,
  +entityType: $ElementType<T, 'entityType'>,
  +id: string,
  +inputValue?: string,
  +placeholder?: string,
  +selectedItem?: T | null,
  +staticItems?: $ReadOnlyArray<T>,
  +width?: string,
};

export function createInitialState<+T: EntityItem>(
  props: InitialPropsT<T>,
): {...State<T>} {
  const {inputValue, selectedItem, ...restProps} = props;
  return {
    entityType: props.entityType,
    highlightedItem: null,
    indexedSearch: true,
    inputValue: inputValue ?? selectedItem?.name ?? '',
    isOpen: false,
    items: EMPTY_ARRAY,
    page: 1,
    pendingSearch: null,
    selectedItem: selectedItem ?? null,
    statusMessage: '',
    ...restProps,
  };
}

type AutocompleteItemProps<T: EntityItem> = {
  autocompleteId: string,
  dispatch: (Actions<T>) => void,
  isHighlighted: boolean,
  isSelected: boolean,
  item: Item<T>,
  selectItem: (Item<T>) => void,
};

const AutocompleteItem = React.memo(<+T: EntityItem>({
  autocompleteId,
  dispatch,
  isHighlighted,
  isSelected,
  item,
  selectItem,
}: AutocompleteItemProps<T>) => {
  const itemId = `${autocompleteId}-item-${item.id}`;

  let style = item.level
    ? {paddingLeft: String((item.level - 1) * 8) + 'px'}
    : null;

  if (item.action) {
    style = {textAlign: 'center'};
  }

  function handleItemClick() {
    selectItem(item);
  }

  function handleItemMouseOver() {
    dispatch({item, type: 'highlight-item'});
  }

  return (
    <li
      aria-selected={isHighlighted ? 'true' : 'false'}
      className={
        (isHighlighted ? 'highlighted ' : '') +
        (isSelected ? 'selected ' : '') +
        (item.separator ? 'separator ' : '')
      }
      id={itemId}
      key={item.id}
      onClick={handleItemClick}
      onMouseDown={handleItemMouseDown}
      onMouseOver={handleItemMouseOver}
      role="option"
      style={style}
    >
      {formatItem<T>(item)}
    </li>
  );
}, (a, b) => {
  return (
    a.item.id === b.item.id &&
    a.isHighlighted === b.isHighlighted &&
    a.isSelected === b.isSelected
  );
});

type AutocompleteItemsProps<T: EntityItem> = {
  autocompleteId: string,
  dispatch: (Actions<T>) => void,
  highlightedItem: Item<T> | null,
  items: $ReadOnlyArray<Item<T>>,
  selectedItem: Item<T> | null,
  selectItem: (Item<T>) => void,
};

type AutocompleteItemComponent<T> =
  React$AbstractComponent<AutocompleteItemProps<T>, void>;

function AutocompleteItems<T: EntityItem>({
  autocompleteId,
  dispatch,
  highlightedItem,
  items,
  selectedItem,
  selectItem,
}: AutocompleteItemsProps<T>):
  $ReadOnlyArray<React.Element<AutocompleteItemComponent<T>>> {
  // XXX Until Flow supports https://github.com/facebook/flow/issues/7672
  const AutocompleteItemWithType: AutocompleteItemComponent<T> =
    (AutocompleteItem: any);

  const children = [];
  for (let index = 0; index < items.length; index++) {
    const item = items[index];
    children.push(
      <AutocompleteItemWithType
        autocompleteId={autocompleteId}
        dispatch={dispatch}
        isHighlighted={!!(highlightedItem && item.id === highlightedItem.id)}
        isSelected={!!(selectedItem && item.id === selectedItem.id)}
        item={item}
        key={item.id}
        selectItem={selectItem}
      />,
    );
  }
  return children;
}

export default function Autocomplete2<+T: EntityItem>(
  props: Props<T>,
): React.Element<'div'> {
  const {
    canChangeType,
    containerClass,
    dispatch,
    entityType,
    id,
  } = props;

  const xhr = React.useRef<XMLHttpRequest | null>(null);
  const inputRef = React.useRef<HTMLInputElement | null>(null);
  const inputTimeout = React.useRef<TimeoutID | null>(null);
  const containerRef = React.useRef<HTMLDivElement | null>(null);

  const stopRequests = React.useCallback(() => {
    if (xhr.current) {
      xhr.current.abort();
      xhr.current = null;
    }

    if (inputTimeout.current) {
      clearTimeout(inputTimeout.current);
      inputTimeout.current = null;
    }

    dispatch(STOP_SEARCH);
  }, [dispatch]);

  const selectItem = React.useCallback((item) => {
    stopRequests();
    dispatch({item, type: 'select-item'});
  }, [stopRequests, dispatch]);

  function handleButtonClick() {
    stopRequests();

    if (props.isOpen) {
      dispatch(HIDE_MENU);
    } else if (props.items.length) {
      dispatch(SHOW_MENU);
    } else if (props.inputValue) {
      doSearchOrFilter<T>(dispatch, props.staticItems, props.inputValue);
    }
  }

  function handleInputChange(
    event: SyntheticKeyboardEvent<HTMLInputElement>,
  ) {
    const newInputValue = event.currentTarget.value;
    const newCleanInputValue = clean(newInputValue);

    dispatch({type: 'type-value', value: newInputValue});

    const mbidMatch = newCleanInputValue.match(MBID_REGEXP);
    if (mbidMatch) {
      /*
       * The user pasted an MBID (or a URL containing one). Perform a
       * direct lookup.
       */
      stopRequests();

      const lookupXhr = new XMLHttpRequest();
      xhr.current = lookupXhr;

      lookupXhr.addEventListener('load', () => {
        xhr.current = null;

        if (lookupXhr.status !== 200) {
          dispatch(SHOW_LOOKUP_ERROR);
          return;
        }

        const entity = JSON.parse(lookupXhr.responseText);
        if (entity.entityType === entityType) {
          selectItem(entity);
        } else if (canChangeType && canChangeType(entity.entityType)) {
          dispatch({
            entityType: entity.entityType,
            type: 'change-entity-type',
          });
          selectItem(entity);
        } else {
          dispatch(SHOW_LOOKUP_TYPE_ERROR);
        }
      });

      lookupXhr.open('GET', '/ws/js/entity/' + mbidMatch[0]);
      lookupXhr.send();
    } else if (clean(props.inputValue) !== newCleanInputValue) {
      stopRequests();
      doSearchOrFilter<T>(dispatch, props.staticItems, newCleanInputValue);
    }
  }

  function handleInputKeyDown(
    event: SyntheticKeyboardEvent<HTMLInputElement | HTMLButtonElement>,
  ) {
    const isInputNonEmpty = !!props.inputValue;
    const isMenuNonEmpty = props.items.length > 0;
    const isMenuOpen = props.isOpen;
    const menuId = id + '-menu';

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();

        if (isMenuOpen) {
          setScrollPosition(menuId, 'nextElementSibling');
          dispatch(HIGHLIGHT_NEXT_ITEM);
        } else if (isMenuNonEmpty) {
          dispatch(SHOW_MENU);
        } else if (isInputNonEmpty) {
          doSearchOrFilter<T>(dispatch, props.staticItems, props.inputValue);
        }
        break;

      case 'ArrowUp':
        if (isMenuOpen) {
          event.preventDefault();
          setScrollPosition(menuId, 'previousElementSibling');
          dispatch(HIGHLIGHT_PREVIOUS_ITEM);
        }
        break;

      case 'Enter': {
        if (isMenuOpen) {
          event.preventDefault();
          const item = props.highlightedItem;
          if (item) {
            selectItem(item);
          }
        }
        break;
      }

      case 'Escape':
        stopRequests();
        if (isMenuOpen) {
          event.preventDefault();
          dispatch(HIDE_MENU);
        }
        break;
    }
  }

  const handleOuterClick = React.useCallback(() => {
    stopRequests();
    dispatch(HIDE_MENU);
  }, [stopRequests, dispatch]);

  const activeDescendant = props.highlightedItem
    ? `${id}-item-${props.highlightedItem.id}`
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
    if (
      props.pendingSearch &&
      !inputTimeout.current &&
      !xhr.current &&
      !props.staticItems
    ) {
      inputTimeout.current = setTimeout(() => {
        inputTimeout.current = null;

        // Check if the input value has changed before proceeding.
        if (clean(props.pendingSearch) === clean(props.inputValue)) {
          doSearch<T>(dispatch, props, xhr);
        }
      }, 300);
    }
  });

  // XXX Until Flow supports https://github.com/facebook/flow/issues/7672
  const AutocompleteItemsWithType:
    React$AbstractComponent<AutocompleteItemsProps<T>, void> =
    (AutocompleteItems: any);

  return (
    <div
      className={
        'autocomplete2' + (containerClass ? ' ' + containerClass : '')}
      ref={node => {
        containerRef.current = node;
      }}
      style={props.width ? {width: props.width} : null}
    >
      <label
        className={props.labelClass}
        htmlFor={inputId}
        id={labelId}
        style={DISPLAY_NONE_STYLE}
      >
        {props.placeholder || SEARCH_PLACEHOLDERS[entityType]()}
      </label>
      <div
        aria-expanded={props.isOpen ? 'true' : 'false'}
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
              props.isLookupPerformed == null
                ? props.selectedItem
                : props.isLookupPerformed
            )
              ? 'lookup-performed'
              : ''}
          disabled={props.disabled}
          id={inputId}
          onChange={handleInputChange}
          onKeyDown={handleInputKeyDown}
          placeholder={
            props.placeholder || l('Type to search, or paste an MBID')
          }
          ref={inputRef}
          value={props.inputValue}
        />
        <button
          aria-activedescendant={activeDescendant}
          aria-autocomplete="list"
          aria-controls={menuId}
          aria-haspopup="true"
          aria-label={l('Search')}
          className={
            'search' +
            (props.pendingSearch && !props.disabled ? ' loading' : '')}
          data-toggle="true"
          disabled={props.disabled}
          onClick={handleButtonClick}
          onKeyDown={handleInputKeyDown}
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
        role="listbox"
        style={{
          visibility: (props.isOpen && !props.disabled)
            ? 'visible'
            : 'hidden',
        }}
      >
        {props.disabled ? null : (
          <AutocompleteItemsWithType
            autocompleteId={id}
            dispatch={dispatch}
            highlightedItem={props.highlightedItem}
            items={props.items}
            selectItem={selectItem}
            selectedItem={props.selectedItem}
          />
        )}
      </ul>

      <div
        aria-live="assertive"
        aria-relevant="additions text"
        id={statusId}
        role="status"
        style={ARIA_LIVE_STYLE}
      >
        {props.statusMessage}
      </div>
    </div>
  );
}
