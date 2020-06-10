/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {Element} from "React";import partition from 'lodash/partition';
import unionBy from 'lodash/unionBy';
import React, {useEffect, useMemo, useReducer, useRef} from 'react';

import ENTITIES from '../../../../../entities';
import useOutsideClickEffect from '../hooks/useOutsideClickEffect';
import {unwrapNl} from '../i18n';
import clean from '../utility/clean';

import {
  HIDE_MENU,
  HIGHLIGHT_NEXT_ITEM,
  HIGHLIGHT_PREVIOUS_ITEM,
  SELECT_HIGHLIGHTED_ITEM,
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
  MBID_REGEXP,
  MENU_ITEMS,
  SEARCH_PLACEHOLDERS,
} from './Autocomplete2/constants';
import formatItem from './Autocomplete2/formatters';
import reducer from './Autocomplete2/reducer';
import type {
  Actions,
  Item,
  Props,
  Instance,
  State,
} from './Autocomplete2/types';

const INITIAL_STATE: State = {
  highlightedIndex: 0,
  indexedSearch: true,
  inputValue: '',
  isOpen: false,
  items: EMPTY_ARRAY,
  page: 1,
  pendingSearch: null,
  selectedItem: null,
  statusMessage: '',
};

/*
 * If the autocomplete is provided an `items` prop, it's assumed that it
 * contains the complete list of searchable options. In that case, we filter
 * them based on a simple substring match via `doFilter`.
 */
function doFilter(
  parent: Instance,
  items: $ReadOnlyArray<Item>,
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

  parent.dispatch({
    items: results,
    page: 1,
    resultCount,
    type: 'show-results',
  });
}

/*
 * `doLookup` performs a direct MBID lookup (via /ws/js/entity) in case the
 * the user pastes an MBID or some URL containing one.
 */
function doLookup(parent: Instance, mbid: string) {
  parent.stopRequests();

  const lookupXhr = new XMLHttpRequest();
  parent.xhr = lookupXhr;

  lookupXhr.addEventListener('load', () => {
    parent.xhr = null;

    if (lookupXhr.status !== 200) {
      parent.dispatch(SHOW_LOOKUP_ERROR);
      return;
    }

    const {entityType, onTypeChange} = parent.props;
    const entity = JSON.parse(lookupXhr.responseText);

    if (entity.entityType !== entityType &&
        (!onTypeChange || onTypeChange(entity.entityType) === false)) {
      parent.dispatch(SHOW_LOOKUP_TYPE_ERROR);
    } else {
      parent.dispatch({item: entity, type: 'select-item'});
    }
  });

  lookupXhr.open('GET', '/ws/js/entity/' + mbid);
  lookupXhr.send();
}

/*
 * `doSearch` performs a direct or indexed search (via /ws/js). This is the
 * default behavior if no `items` prop is given.
 */
function doSearch(instance: Instance) {
  const searchXhr = new XMLHttpRequest();
  instance.xhr = searchXhr;

  searchXhr.addEventListener('load', () => {
    instance.xhr = null;

    if (searchXhr.status !== 200) {
      instance.dispatch(SHOW_SEARCH_ERROR);
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

    actions.push(instance.state.indexedSearch
      ? MENU_ITEMS.TRY_AGAIN_DIRECT
      : MENU_ITEMS.TRY_AGAIN_INDEXED);

    const [, prevItems] = partition(instance.state.items, hasAction);

    newItems = newPage > 1
      ? unionBy(prevItems, newItems, x => x.id)
      : newItems;

    instance.dispatch({
      items: newItems.concat(actions),
      page: newPage,
      resultCount: newItems.length,
      type: 'show-results',
    });
  });

  const url = (
    '/ws/js/' + ENTITIES[instance.props.entityType].url +
    '/?q=' + encodeURIComponent(instance.state.inputValue || '') +
    '&page=' + String(instance.state.page) +
    '&direct=' + (instance.state.indexedSearch ? 'false' : 'true')
  );

  searchXhr.open('GET', url);
  searchXhr.send();
}

function doSearchOrFilter(instance: Instance, searchTerm: string) {
  if (instance.props.items) {
    doFilter(instance, instance.props.items, searchTerm);
  } else if (searchTerm) {
    instance.dispatch({searchTerm, type: 'search-after-timeout'});
  }
}

function findItem(instance: Instance, itemId: string) {
  const items = instance.state.items;
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    if (String(item.id) === itemId) {
      return [i, item];
    }
  }
  return [-1, null];
}

const hasOwnProperty = Object.prototype.hasOwnProperty;

function hasAction(x: Item) {
  return hasOwnProperty.call(x, 'action');
}

function setScrollPosition(menuId: string, siblingAccessor: string) {
  const menu = document.getElementById(menuId);
  if (!menu) {
    return;
  }
  // $FlowFixMe
  const item = menu.querySelector('li[aria-selected=true]')[siblingAccessor];
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

export default function Autocomplete2(props: Props): Element<"div"> {
  const {entityType, id} = props;

  const [state, dispatch] = useReducer<State, Actions>(
    reducer,
    INITIAL_STATE,
  );

  let activeElementBeforeItemClick = null;
  let itemClickInProgress = false;
  let prevChildren = null;

  /*
   * The "instance" below, including associated methods, is created only once
   * on initial render. This avoids unnecessary allocations and closures for
   * each render by reusing the previous ones. It's important to note,
   * however, that the `state` variable above (and `props` for that matter)
   * should not be accessed in the closures below unless you know what you're
   * doing (because it'll refer to the *original* state on the initial
   * render). If access to the current state is needed in a callback or event
   * handler, `instance.state` should be used instead, as it'll refer to the
   * state of the last render.
   */
  const instanceRef = useRef<Instance | null>(null);
  const instance: Instance = instanceRef.current || (instanceRef.current = {
    container: {current: null},

    dispatch,

    handleBlur() {
      if (itemClickInProgress) {
        return;
      }
      setTimeout(() => {
        const container = instance.container.current;
        if (container && !container.contains(document.activeElement)) {
          instance.stopRequests();
          if (instance.state.isOpen) {
            dispatch(HIDE_MENU);
          }
        }
      }, 10);
    },

    handleButtonClick() {
      const state = instance.state;

      instance.stopRequests();

      if (state.isOpen) {
        instance.dispatch(HIDE_MENU);
      } else if (state.items.length) {
        instance.dispatch(SHOW_MENU);
      } else if (state.inputValue) {
        doSearchOrFilter(instance, state.inputValue);
      }
    },

    handleInputChange(event: SyntheticKeyboardEvent<HTMLInputElement>) {
      const newInputValue = event.currentTarget.value;
      const newCleanInputValue = clean(newInputValue);

      dispatch({type: 'type-value', value: newInputValue});

      const mbidMatch = newCleanInputValue.match(MBID_REGEXP);
      if (mbidMatch) {
        doLookup(instance, mbidMatch[0]);
      } else if (clean(instance.state.inputValue) !== newCleanInputValue) {
        instance.stopRequests();
        doSearchOrFilter(instance, newCleanInputValue);
      }
    },

    handleInputKeyDown(
      event: SyntheticKeyboardEvent<HTMLInputElement | HTMLButtonElement>,
    ) {
      const isInputNonEmpty = !!instance.state.inputValue;
      const isMenuNonEmpty = instance.state.items.length > 0;
      const isMenuOpen = instance.state.isOpen;
      const menuId = instance.props.id + '-menu';

      switch (event.key) {
        case 'ArrowDown':
          event.preventDefault();

          if (isMenuOpen) {
            setScrollPosition(menuId, 'nextElementSibling');
            dispatch(HIGHLIGHT_NEXT_ITEM);
          } else if (isMenuNonEmpty) {
            dispatch(SHOW_MENU);
          } else if (isInputNonEmpty) {
            doSearchOrFilter(instance, instance.state.inputValue);
          }
          break;

        case 'ArrowUp':
          if (isMenuOpen) {
            event.preventDefault();
            setScrollPosition(menuId, 'previousElementSibling');
            dispatch(HIGHLIGHT_PREVIOUS_ITEM);
          }
          break;

        case 'Enter':
          if (isMenuOpen) {
            event.preventDefault();
            dispatch(SELECT_HIGHLIGHTED_ITEM);
          }
          break;

        case 'Escape':
          instance.stopRequests();
          if (isMenuOpen) {
            dispatch(HIDE_MENU);
          }
          break;
      }
    },

    handleItemClick(event: SyntheticMouseEvent<HTMLLIElement>) {
      const active = activeElementBeforeItemClick;
      if (active) {
        setTimeout(() => {
          active.focus();
          itemClickInProgress = false;
        }, 10);
        activeElementBeforeItemClick = null;
      }
      const [, item] = findItem(instance, event.currentTarget.dataset.itemId);
      item && instance.dispatch({item, type: 'select-item'});
    },

    handleItemMouseDown() {
      activeElementBeforeItemClick = document.activeElement;
      itemClickInProgress = true;
    },

    handleItemMouseOver(event: SyntheticMouseEvent<HTMLLIElement>) {
      const [index] = findItem(instance, event.currentTarget.dataset.itemId);
      index >= 0 && instance.dispatch({index, type: 'highlight-item'});
    },

    handleOuterClick() {
      instance.stopRequests();
      dispatch(HIDE_MENU);
    },

    inputTimeout: null,

    props,

    /*
     * This needs to accept parameters for the state at the time of render.
     * (The state outside this closure refers to the original component state,
     * because the closure was created on the initial render; instance.state
     * refers to the state of the last render, not the current one.)
     */
    renderItems(items, highlightedIndex, selectedItem) {
      const children = new Map();

      for (let index = 0; index < items.length; index++) {
        const item = items[index];
        const isHighlighted = index === highlightedIndex;
        const isSelected = !!(selectedItem && item.id === selectedItem.id);
        const itemMapKey = item.id + ',' +
          String(isHighlighted) + ',' +
          String(isSelected);

        let style = item.level
          ? {paddingLeft: String((item.level - 1) * 8) + 'px'}
          : null;

        if (item.action) {
          style = {textAlign: 'center'};
        }

        children.set(
          itemMapKey,
          (prevChildren && prevChildren.get(itemMapKey)) || (
            <li
              aria-selected={isHighlighted ? 'true' : 'false'}
              className={
                (isHighlighted ? 'highlighted ' : '') +
                (isSelected ? 'selected ' : '') +
                (item.separator ? 'separator ' : '')
              }
              data-item-id={item.id}
              id={`${id}-item-${item.id}`}
              key={item.id}
              onClick={instance.handleItemClick}
              onMouseDown={instance.handleItemMouseDown}
              onMouseOver={instance.handleItemMouseOver}
              role="option"
              style={style}
            >
              {formatItem(item)}
            </li>
          ),
        );
      }

      prevChildren = children;
      return children;
    },

    setContainer(node) {
      instance.container.current = node;
    },

    state,

    stopRequests() {
      if (instance.xhr) {
        instance.xhr.abort();
        instance.xhr = null;
      }

      if (instance.inputTimeout) {
        clearTimeout(instance.inputTimeout);
        instance.inputTimeout = null;
      }

      dispatch(STOP_SEARCH);
    },

    xhr: null,
  });

  const activeDescendant = state.items.length
    ? `${id}-item-${state.items[state.highlightedIndex].id}`
    : null;
  const inputId = `${id}-input`;
  const labelId = `${id}-label`;
  const menuId = `${id}-menu`;
  const statusId = `${id}-status`;

  const menuItems = useMemo(() => instance.renderItems(
    state.items,
    state.highlightedIndex,
    state.selectedItem,
  ), [instance, state.items, state.highlightedIndex, state.selectedItem]);

  useOutsideClickEffect(
    instance.container,
    instance.handleOuterClick,
    instance.stopRequests,
  );

  useEffect(() => {
    /*
     * This gives event handlers access to the props and state of the most
     * recent render. `useEffect` runs after a completed render; this does
     * *not* allow access to props or state from any current, "in progress"
     * render. This should generally be fine for events, since they're
     * triggered through what's visible on screen, but care is advised.
     */
    instance.props = props;
    instance.state = state;

    if (
      state.pendingSearch &&
      !instance.inputTimeout &&
      !instance.xhr &&
      !props.items
    ) {
      instance.inputTimeout = setTimeout(() => {
        instance.inputTimeout = null;

        // Check if the input value has changed before proceeding.
        if (clean(state.pendingSearch) === clean(instance.state.inputValue)) {
          doSearch(instance);
        }
      }, 300);
    }
  });

  return (
    <div
      className="autocomplete2"
      ref={instance.setContainer}
      style={props.width ? {width: props.width} : null}
    >
      <label htmlFor={inputId} id={labelId} style={DISPLAY_NONE_STYLE}>
        {props.placeholder || SEARCH_PLACEHOLDERS[entityType]()}
      </label>
      <div
        aria-expanded={state.isOpen ? 'true' : 'false'}
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
          className={state.selectedItem ? 'lookup-performed' : ''}
          id={inputId}
          onBlur={instance.handleBlur}
          onChange={instance.handleInputChange}
          onKeyDown={instance.handleInputKeyDown}
          placeholder={
            props.placeholder || l('Type to search, or paste an MBID')
          }
          value={state.inputValue}
        />
        <button
          aria-activedescendant={activeDescendant}
          aria-autocomplete="list"
          aria-controls={menuId}
          aria-haspopup="true"
          aria-label={l('Search')}
          className={'search' + (state.pendingSearch ? ' loading' : '')}
          data-toggle="true"
          onBlur={instance.handleBlur}
          onClick={instance.handleButtonClick}
          onKeyDown={instance.handleInputKeyDown}
          role="button"
          title={l('Search')}
          type="button"
        />
      </div>

      <ul
        aria-controls={statusId}
        aria-labelledby={labelId}
        id={menuId}
        role="listbox"
        style={{visibility: state.isOpen ? 'visible' : 'hidden'}}
      >
        {Array.from(menuItems.values())}
      </ul>

      <div
        aria-live="assertive"
        aria-relevant="additions text"
        id={statusId}
        role="status"
        style={ARIA_LIVE_STYLE}
      >
        {state.statusMessage}
      </div>
    </div>
  );
}
