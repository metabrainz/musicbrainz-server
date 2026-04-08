/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import deepFreeze from 'deep-freeze-strict';

export default function deepFreezeInDevelopment<T: {...}>(object: T): T {
  /*
   * `deepFreeze` is slow, but this allows us to catch writes to `object`
   * in development and during test runs without affecting production
   * performance.
   *
   * Ensure that the object type `T` already uses read-only properties
   * in its Flow types.
   */
  if (__DEV__) {
    return deepFreeze(object);
  }
  return object;
}
