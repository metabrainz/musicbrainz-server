/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  compareNumbers,
  compareStrings,
} from './compare.js';

/*
 * Checks if two arrays are equal using the provided `isEqual` function
 * against each pair of items.
 */
export function arraysEqual<T>(
  a: $ReadOnlyArray<T>,
  b: $ReadOnlyArray<T>,
  isEqual: (T, T) => boolean = (a: T, b: T) => a === b,
): boolean {
  const length = a.length;
  if (length !== b.length) {
    return false;
  }
  for (let i = 0; i < length; i++) {
    if (!isEqual(a[i], b[i])) {
      return false;
    }
  }
  return true;
}

/*
 * Equivalent to array.map(func).filter(Boolean), but shorter and only
 * loops over the array once.
 */
export function compactMap<T, U>(
  array: $ReadOnlyArray<T>,
  func: (T) => ?U,
): $ReadOnlyArray<U> {
  return array.reduce(function (result, item) {
    const mappedValue = func(item);
    /*
     * The Flow lint is disabled because we intend to
     * strip /all/ falsey values here.
     */
    // flowlint-next-line sketchy-null-mixed:off
    if (mappedValue) {
      result.push(mappedValue);
    }
    return result;
  }, []);
}

/*
 * Given a `destination` array that's already in sorted order according
 * to the provided `cmp` function, merges unique items from `source`
 * into `destination` while preserving the sorted order.
 */
export function mergeSortedArrayInto<T>(
  destination: Array<T>,
  source: $ReadOnlyArray<T>,
  cmp: (T, T) => number,
) {
  const length = source.length;
  for (let i = 0; i < length; i++) {
    const value = source[i];
    const [index, exists] = sortedIndexWith(
      destination,
      value,
      cmp,
    );
    if (!exists) {
      destination.splice(index, 0, value);
    }
  }
}

/*
 * Like Lodash's _.sortedIndexBy, but takes a comparator function
 * rather than an iteratee, and returns whether the item already
 * exists in the array.
 */
export function sortedIndexWith<T, U>(
  array: $ReadOnlyArray<T>,
  value: U,
  cmp: (T, U) => number,
): [number, boolean] {
  let low = 0;
  let high = array.length;
  let middle;
  let order;
  while (low < high) {
    middle = Math.floor((low + high) / 2);
    order = cmp(array[middle], value);
    if (order < 0) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  if (middle !== undefined && high !== middle && high < array.length) {
    order = cmp(array[high], value);
  }
  return [high, order === 0];
}

export function sortByNumber<T>(
  array: $ReadOnlyArray<T>,
  func: (T) => number,
  customCmp?: (number, number) => number,
): $ReadOnlyArray<T> {
  const keys = array.map((x, i): [number, number] => [i, func(x)]);
  const cmp = customCmp ?? compareNumbers;
  keys.sort((a, b) => cmp(a[1], b[1]));
  return keys.map(x => array[x[0]]);
}

export function sortByString<T>(
  array: $ReadOnlyArray<T>,
  func: (T) => string,
  customCmp?: (string, string) => number,
): $ReadOnlyArray<T> {
  const keys = array.map((x, i): [number, string] => [i, func(x)]);
  const cmp = customCmp ?? compareStrings;
  keys.sort((a, b) => cmp(a[1], b[1]));
  return keys.map(x => array[x[0]]);
}

export function groupBy<T, K>(
  array: $ReadOnlyArray<T>,
  func: (T) => K,
): Map<K, Array<T>> {
  return array.reduce(function (result, item) {
    const key = func(item);
    let values = result.get(key);
    if (values == null) {
      values = [];
      result.set(key, values);
    }
    values.push(item);
    return result;
  }, new Map());
}

export function first<T>(array: ?$ReadOnlyArray<T>): ?T {
  return array?.length ? array[0] : undefined;
}

export function keyBy<T, K = string>(
  array: $ReadOnlyArray<T>,
  func: (T) => K,
): Map<K, T> {
  return array.reduce(function (result, item) {
    result.set(func(item), item);
    return result;
  }, new Map());
}

export function last<T>(array: ?$ReadOnlyArray<T>): ?T {
  return array?.length ? array[array.length - 1] : undefined;
}

export function uniqBy<T, U>(
  array: $ReadOnlyArray<T>,
  func: (T) => U,
): Array<T> {
  const seenKeys = new Set<U>();
  return array.reduce(function (result, item) {
    const key = func(item);
    if (!seenKeys.has(key)) {
      seenKeys.add(key);
      result.push(item);
    }
    return result;
  }, []);
}
