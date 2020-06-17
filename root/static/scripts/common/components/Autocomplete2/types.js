/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type Props = {
  containerClass?: string,
  entityType: CoreEntityTypeT | 'editor',
  id: string,
  initialInputValue?: string,
  initialSelectedItem?: EntityItem | null,
  items?: $ReadOnlyArray<EntityItem>,
  labelClass?: string,
  onChange: (EntityItem | null) => void,
  onTypeChange?: (string) => boolean,
  placeholder?: string,
  width?: string,
};

export type State = {
  highlightedItem: Item | null,
  indexedSearch: boolean,
  inputValue: string,
  isOpen: boolean,
  items: $ReadOnlyArray<Item>,
  page: number,
  pendingSearch: string | null,
  selectedItem: EntityItem | null,
  statusMessage: string,
};

export type SearchAction = {
  +indexed?: boolean,
  +searchTerm?: string,
  +type: 'search-after-timeout',
};

/* eslint-disable flowtype/sort-keys */
export type Actions =
  | SearchAction
  | { +type: 'highlight-item', +item: Item }
  | { +type: 'highlight-next-item' }
  | { +type: 'highlight-previous-item' }
  | { +type: 'noop' }
  | { +type: 'select-item', +item: Item }
  | { +type: 'set-menu-visibility', +value: boolean }
  | {
      +type: 'show-results',
      +items: $ReadOnlyArray<Item>,
      +page: number,
      +resultCount: number,
    }
  | { +type: 'show-lookup-error' }
  | { +type: 'show-lookup-type-error' }
  | { +type: 'show-more-results' }
  | { +type: 'show-search-error' }
  | { +type: 'stop-search' }
  | { +type: 'toggle-indexed-search' }
  | { +type: 'type-value', +value: string }
  ;
/* eslint-enable flowtype/sort-keys */

export type ActionItem = {
  +action: Actions,
  +id: number | string,
  +level?: number,
  +name: string | () => string,
  +separator?: boolean,
};

export type EntityItem =
  | CoreEntityT;

export type Item = ActionItem | EntityItem;
