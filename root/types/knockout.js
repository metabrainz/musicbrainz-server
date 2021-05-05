/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type KnockoutObservable<T> = {
  // eslint-disable-next-line no-undef
  [[call]]: (() => T) & ((T) => empty),
  peek: () => T,
  subscribe: (
    (T) => void,
    target?: mixed,
    event?: string
  ) => {dispose: () => empty},
};

declare type KnockoutObservableArray<T> =
  & KnockoutObservable<$ReadOnlyArray<T>>
  & {
      push: (T) => empty,
      remove: (T) => empty,
    };
