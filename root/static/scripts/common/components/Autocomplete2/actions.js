/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export const HIDE_MENU = {
  type: 'set-menu-visibility',
  value: false,
};

export const NOOP = {
  type: 'noop',
};

export const SHOW_MENU = {
  type: 'set-menu-visibility',
  value: true,
};

export const SHOW_MORE_RESULTS = {
  type: 'show-more-results',
};

export const SEARCH_AGAIN = {
  type: 'search-after-timeout',
};

export const SHOW_LOOKUP_ERROR = {
  type: 'show-lookup-error',
};

export const SHOW_LOOKUP_TYPE_ERROR = {
  type: 'show-lookup-type-error',
};

export const SHOW_SEARCH_ERROR = {
  type: 'show-search-error',
};

export const STOP_SEARCH = {
  type: 'stop-search',
};

export const TOGGLE_INDEXED_SEARCH = {
  type: 'toggle-indexed-search',
};
