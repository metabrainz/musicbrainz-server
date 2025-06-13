/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type SearchableTypeT = EntityItemT['entityType'];

export type StateT<T: EntityItemT> = {
  +canChangeType?: (string) => boolean,
  +containerClass?: string,
  +disabled?: boolean,
  +entityType: T['entityType'],
  +error: number,
  +highlightedIndex: number,
  +htmlName?: string,
  +id: string,
  +indexedSearch: boolean,
  +inputChangeHook?: (
    inputValue: string,
    state: StateT<T>,
    selectItem: (OptionItemT<T>) => boolean,
  ) => boolean,
  +inputClass?: string,
  +inputRef?: {-current: HTMLInputElement | null},
  +inputValue: string,
  +isAddEntityDialogOpen?: boolean,
  +isInputFocused: boolean,
  +isLookupPerformed?: boolean,
  +isOpen: boolean,
  +items: $ReadOnlyArray<ItemT<T>>,
  +label?: string,
  +page: number,
  +pendingSearch: string | null,
  +placeholder?: string,
  +recentItems: $ReadOnlyArray<OptionItemT<T>> | null,
  +recentItemsKey: string,
  +required: boolean,
  +results: $ReadOnlyArray<ItemT<T>> | null,
  +selectedItem: OptionItemT<T> | null,
  +showDescriptions?: boolean,
  +showLabel?: boolean,
  +staticItems?: $ReadOnlyArray<OptionItemT<T>>,
  +statusMessage: string,
  +totalPages: ?number,
  +width?: string,
};

export type PropsT<T: EntityItemT> = {
  +children?: React.Node,
  +dispatch: (ActionT<T>) => void,
  +state: StateT<T>,
};

export type SearchActionT = {
  +indexed?: boolean,
  +searchTerm?: string,
  +type: 'search-after-timeout',
};

/* eslint-disable ft-flow/sort-keys */
export type ActionT<+T: EntityItemT> =
  | SearchActionT
  | {
      +type: 'change-entity-type',
      +entityType: SearchableTypeT,
    }
  | {+type: 'clear-recent-items'}
  | {+type: 'highlight-index', +index: number}
  | {+type: 'highlight-next-item'}
  | {+type: 'highlight-previous-item'}
  | {+type: 'reset-menu'}
  | {+type: 'select-item', +item: ItemT<T>}
  | {+type: 'set-input-focus', +isFocused: boolean}
  | {+type: 'set-menu-visibility', +value: boolean}
  | {
      +type: 'show-ws-results',
      +entities: $ReadOnlyArray<T>,
      +page: number,
      +totalPages: number,
    }
  | {+type: 'show-lookup-error'}
  | {+type: 'show-lookup-type-error'}
  | {+type: 'show-more-results'}
  | {+type: 'set-recent-items', +items: $ReadOnlyArray<OptionItemT<T>>}
  | {+type: 'show-search-error'}
  | {+type: 'stop-search'}
  | {+type: 'toggle-add-entity-dialog', +isOpen: boolean}
  | {+type: 'toggle-indexed-search'}
  | {
      +type: 'toggle-descriptions',
      +showDescriptions: boolean,
    }
  | {+type: 'type-value', +value: string};

export type ActionItemT<+T> = {
  +type: 'action',
  +action: ActionT<T>,
  +id: number | string,
  +name: string | () => string,
  +level?: number,
  +separator?: boolean,
  +disabled?: boolean,
};

export type OptionItemT<+T> = {
  +type: 'option',
  +id: number | string,
  +name: string | () => string,
  +entity: T,
  +level?: number,
  +separator?: boolean,
  +disabled?: boolean,
};

export type HeaderItemT = {
  +type: 'header',
  +id: number | string,
  +name: string | () => string,
  +disabled: true,
  +separator?: boolean,
};

export type ItemT<+T: EntityItemT> =
  | ActionItemT<T>
  | OptionItemT<T>
  | HeaderItemT;

/* eslint-enable ft-flow/sort-keys */

export type EntityItemT =
  | EditorT
  | LanguageT
  | LinkAttrTypeT
  | LinkTypeT
  | NonUrlRelatableEntityT;
