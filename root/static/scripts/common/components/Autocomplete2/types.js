/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type State = {
  +canChangeType?: (string) => boolean,
  +children?: React$Node,
  +containerClass?: string,
  +disabled?: boolean,
  +entityType: CoreEntityTypeT | 'editor',
  +highlightedItem: Item | null,
  +id: string,
  +indexedSearch: boolean,
  +inputValue: string,
  +isLookupPerformed?: boolean,
  +isOpen: boolean,
  +items: $ReadOnlyArray<Item>,
  +labelClass?: string,
  +page: number,
  +pendingSearch: string | null,
  +placeholder?: string,
  +selectedItem: EntityItem | null,
  +staticItems?: $ReadOnlyArray<EntityItem>,
  +statusMessage: string,
  +width?: string,
};

export type Props = $ReadOnly<{
  ...State,
  +dispatch: (Actions) => void,
}>;

export type SearchAction = {
  +indexed?: boolean,
  +searchTerm?: string,
  +type: 'search-after-timeout',
};

/* eslint-disable flowtype/sort-keys */
export type Actions =
  | SearchAction
  | {
      +type: 'change-entity-type',
      +entityType: CoreEntityTypeT | 'editor',
    }
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
