/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

interface MapInterface<-K, V> {
  get(K): V | void,
  set(K, V): MapInterface<K, V>,
}

type ObjectType = interface {} | $ReadOnlyArray<mixed>;

// Currently, only objects are supported as keys.

// const createMap = <K, V>(): Map<K, V> => new Map<K, V>();

const createWeakMap =
  <K: ObjectType, V>(): WeakMap<K, V> => new WeakMap<K, V>();

function memoizeGeneric<-T, +U>(
  func: (T) => U,
  createCache: () => MapInterface<T, U>,
): (T) => U {
  const cache = createCache();
  return function (obj: T): U {
    let result = cache.get(obj);
    if (result != null) {
      return result;
    }
    result = func(obj);
    cache.set(obj, result);
    return result;
  };
}

export default function memoize<-T: interface {}, +U>(
  func: (T) => U,
): (T) => U {
  return memoizeGeneric(func, createWeakMap);
}

export function memoizeWithDefault<-T: interface {}, +U>(
  func: (T) => U,
  defaultValue: U,
): (?T) => U {
  const memoizedFunc = memoize<T, U>(func);
  return function (obj: ?T): U {
    if (obj == null) {
      return defaultValue;
    }
    return memoizedFunc(obj);
  };
}
