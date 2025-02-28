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
} as const;

export const HIGHLIGHT_NEXT_ITEM = {
  type: 'highlight-next-item',
} as const;

export const HIGHLIGHT_PREVIOUS_ITEM = {
  type: 'highlight-previous-item',
} as const;

export const SHOW_MENU = {
  type: 'set-menu-visibility',
  value: true,
} as const;

export const SHOW_MORE_RESULTS = {
  type: 'show-more-results',
} as const;

export const SEARCH_AGAIN = {
  type: 'search-after-timeout',
} as const;

export const SHOW_LOOKUP_ERROR = {
  type: 'show-lookup-error',
} as const;

export const SHOW_LOOKUP_TYPE_ERROR = {
  type: 'show-lookup-type-error',
} as const;

export const SHOW_SEARCH_ERROR = {
  type: 'show-search-error',
} as const;

export const STOP_SEARCH = {
  type: 'stop-search',
} as const;

export const TOGGLE_INDEXED_SEARCH = {
  type: 'toggle-indexed-search',
} as const;

export const OPEN_ADD_ENTITY_DIALOG = {
  isOpen: true,
  type: 'toggle-add-entity-dialog',
} as const;

export const CLOSE_ADD_ENTITY_DIALOG = {
  isOpen: false,
  type: 'toggle-add-entity-dialog',
} as const;
