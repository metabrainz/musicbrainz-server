/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * See ./createFastObjectCloneFunction.benchmark.js
 *
 * node v25.9.0 (6.19.11-arch1-1):
 * spread x 33,332,361 ops/sec ±2.09% (90 runs sampled)
 * fastClone x 94,883,537 ops/sec ±4.03% (81 runs sampled)
 * Fastest is fastClone
 */

export default function createFastObjectCloneFunction<T: {...}>(
  // eslint-disable-next-line no-unused-vars -- Flow wants this
  spec: {[key in keyof $Exact<T>]: null},
): (($Exact<T>) => $Exact<{...T, ...}>) {
  const keyValueItems = [];

  for (const key of Object.keys(spec)) {
    const jsonKey = JSON.stringify(key);
    keyValueItems.push(jsonKey + ':o[' + jsonKey + ']');
  }

  // $FlowFixMe[incompatible-type]
  return new Function(
    'o',
    'return {' + keyValueItems.join(',') + '}',
  );
}
