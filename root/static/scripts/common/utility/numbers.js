/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export function incrementCounter<K>(
  counter: Map<K, number>,
  key: K,
  amount?: number = 1,
): number {
  const newValue = (counter.get(key) ?? 0) + amount;
  counter.set(key, newValue);
  return newValue;
}

let NEXT_UNIQUE_ID = 1;

export function uniqueId(): number {
  return NEXT_UNIQUE_ID++;
}

export function uniqueNegativeId(): number {
  return uniqueId() * -1;
}
