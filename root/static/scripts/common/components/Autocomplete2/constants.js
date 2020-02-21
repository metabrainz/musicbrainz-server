/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {bracketedText} from '../../utility/bracketed.js';

import {
  NOOP,
  SEARCH_AGAIN,
  SHOW_MORE_RESULTS,
  TOGGLE_INDEXED_SEARCH,
} from './actions.js';
import type {
  ActionItemT,
  HeaderItemT,
  SearchableTypeT,
} from './types.js';

export const ARIA_LIVE_STYLE: {
  +height: string,
  +left: string,
  +overflow: string,
  +position: string,
  +top: string,
  +width: string,
} = Object.seal({
  height: '1px',
  left: '-1px',
  overflow: 'hidden',
  position: 'absolute',
  top: '-1px',
  width: '1px',
});

export const ERROR_LOOKUP: 1 = 1;
export const ERROR_LOOKUP_TYPE: 2 = 2;
export const ERROR_SEARCH: 3 = 3;

/* eslint-disable sort-keys */
export const CLEAR_RECENT_ITEMS: ActionItemT<empty> = {
  type: 'action',
  action: {type: 'clear-recent-items'},
  id: 'clear-recent-items',
  name: N_l('Clear recent items'),
};

export const RECENT_ITEMS_HEADER: HeaderItemT = {
  type: 'header',
  id: 'recent-items-header',
  name: N_l('Recent items'),
  disabled: true,
};

export const MENU_ITEMS: {+[name: string]: ActionItemT<empty>, ...} = {
  ERROR_TRY_AGAIN_DIRECT: {
    type: 'action',
    action: TOGGLE_INDEXED_SEARCH,
    id: 'error-try-again-direct',
    name: N_l('Try again with direct search.'),
  },
  ERROR_TRY_AGAIN_INDEXED: {
    type: 'action',
    action: TOGGLE_INDEXED_SEARCH,
    id: 'error-try-again-indexed',
    name: N_l('Try again with indexed search.'),
  },
  LOOKUP_ERROR: {
    type: 'action',
    action: NOOP,
    id: 'lookup-error',
    name: N_l('An error occurred while looking up the MBID you entered.'),
  },
  LOOKUP_TYPE_ERROR: {
    type: 'action',
    action: NOOP,
    id: 'lookup-type-error',
    name: N_l('The type of entity you pasted isn’t supported here.'),
  },
  NO_RESULTS: {
    type: 'action',
    action: NOOP,
    id: 'no-results',
    name: () => bracketedText(l('No results')),
  },
  SEARCH_ERROR: {
    type: 'action',
    action: SEARCH_AGAIN,
    id: 'try-again',
    name: N_l('An error occurred while searching. Click here to try again.'),
    separator: true,
  },
  SHOW_MORE: {
    type: 'action',
    action: SHOW_MORE_RESULTS,
    id: 'show-more',
    name: N_l('Show more...'),
    separator: true,
  },
  TRY_AGAIN_DIRECT: {
    type: 'action',
    action: TOGGLE_INDEXED_SEARCH,
    id: 'try-again-direct',
    name: N_l('Not found? Try again with direct search.'),
    separator: true,
  },
  TRY_AGAIN_INDEXED: {
    type: 'action',
    action: TOGGLE_INDEXED_SEARCH,
    id: 'try-again-indexed',
    name: N_l('Slow? Switch back to indexed search.'),
    separator: true,
  },
};
/* eslint-enable sort-keys */

export const PAGE_SIZE: number = 25;

export const SEARCH_PLACEHOLDERS: {
  +[type: SearchableTypeT]: () => string,
  ...
} = {
  area: N_l('Search for an area'),
  artist: N_l('Search for an artist'),
  editor: N_l('Search for an editor'),
  event: N_l('Search for an event'),
  genre: N_l('Search for a genre'),
  instrument: N_l('Search for an instrument'),
  label: N_l('Search for a label'),
  link_attribute_type: () => '',
  link_type: N_l('Search for a relationship type'),
  place: N_l('Search for a place'),
  recording: N_l('Search for a recording'),
  release: N_l('Search for a release'),
  release_group: N_l('Search for a release group'),
  series: N_l('Search for a series'),
  work: N_l('Search for a work'),
};

export const IS_TOP_WINDOW: boolean =
  typeof window !== 'undefined' &&
  window === window.top;
