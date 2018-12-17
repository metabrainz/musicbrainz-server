/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type Instance = {|
  container: {|current: HTMLElement | null|},
  dispatch: (Actions) => void,
  handleBlur: () => void,
  handleButtonClick: () => void,
  handleInputChange: (SyntheticKeyboardEvent<HTMLInputElement>) => void,
  handleInputKeyDown: (SyntheticKeyboardEvent<HTMLInputElement>) => void,
  handleItemClick: (SyntheticMouseEvent<HTMLLIElement>) => void,
  handleItemMouseDown: () => void,
  handleItemMouseOver: (SyntheticMouseEvent<HTMLLIElement>) => void,
  handleOuterClick: () => void,
  inputTimeout: TimeoutID | null,
  props: Props,
  renderItems: (
    $ReadOnlyArray<Item>,
    number,
    EntityItem | null,
  ) => Map<string, React$Element<'li'>>,
  setContainer: (HTMLDivElement | null) => void,
  state: State,
  stopRequests: () => void,
  xhr: XMLHttpRequest | null,
|};

export type Props = {
  entityType: string,
  id: string,
  items?: $ReadOnlyArray<EntityItem>,
  onChange: () => void,
  onTypeChange?: (string) => boolean,
  placeholder?: string,
  width?: string,
};

export type State = {
  highlightedIndex: number,
  indexedSearch: boolean,
  inputValue: string,
  isOpen: boolean,
  items: $ReadOnlyArray<Item>,
  page: number,
  pendingSearch: string | null,
  selectedItem: EntityItem | null,
  statusMessage: string,
};

export type SearchAction = {|
  +indexed?: boolean,
  +searchTerm?: string,
  +type: 'search-after-timeout',
|};

export type Actions =
  | SearchAction
  | {| +index: number, +type: 'highlight-item' |}
  | {| +type: 'highlight-next-item' |}
  | {| +type: 'highlight-previous-item' |}
  | {| +type: 'noop' |}
  | {| +type: 'select-highlighted-item' |}
  | {| +item: Item, +type: 'select-item' |}
  | {| +type: 'set-menu-visibility', +value: boolean |}
  | {|
      +items: $ReadOnlyArray<Item>,
      +page: number,
      +resultCount: number,
      +type: 'show-results',
    |}
  | {| +type: 'show-lookup-error' |}
  | {| +type: 'show-lookup-type-error' |}
  | {| +type: 'show-more-results' |}
  | {| +type: 'show-search-error' |}
  | {| +type: 'stop-search' |}
  | {| +type: 'toggle-indexed-search' |}
  | {| +type: 'type-value', +value: string |}
  ;

export type ActionItem = {|
  +action: Actions,
  +id: number | string,
  +name: string | () => string,
  +separator?: boolean,
|};

export type EntityItem = {|
  +id: number | string,
  +level?: number,
  +name: string,
|};

export type Item = ActionItem | EntityItem;
