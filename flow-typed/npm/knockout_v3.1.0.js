/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable flowtype/sort-keys */

declare module 'knockout' {
  declare type Observable<T> = {
    // eslint-disable-next-line no-undef
    [[call]]: (() => T) & ((T) => empty),
    peek: () => T,
    subscribe: (
      (T) => void,
      target?: mixed,
      event?: string
    ) => {dispose: () => empty},
  };

  declare type ObservableArray<T> =
    & Observable<$ReadOnlyArray<T>>
    & {
        push: (T) => empty,
        remove: (T) => empty,
      };

  declare type ComputedObservable<T> = Observable<T>;

  declare function applyBindings(
    bindings: interface {},
    container: HTMLElement,
  ): void;

  declare function computed<T>(
    callback: () => T,
  ): ComputedObservable<T>;

  declare function observable<T>(
    value: T,
  ): Observable<T>;

  declare function observableArray<T>(
    array: $ReadOnlyArray<T>,
  ): ObservableArray<T>;

  declare function unwrap<T>(
    observable:
      | Observable<T>
      | ObservableArray<T>
      | ComputedObservable<T>,
  ): T;

  declare function unwrap<T>(
    value: T,
  ): T;

  declare module.exports: {
    applyBindings: typeof applyBindings,
    computed: typeof computed,
    observable: typeof observable,
    observableArray: typeof observableArray,
    unwrap: typeof unwrap,
  };
}
