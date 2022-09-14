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
 * node v16.6.0:
 * spread x 30,049,382 ops/sec ±0.60% (92 runs sampled)
 * fastClone x 182,189,219 ops/sec ±0.04% (100 runs sampled)
 */

export default function createFastObjectCloneFunction<T: {...}>(
  spec: $ObjMap<$Exact<T>, () => null>,
): (($Exact<T>) => $Exact<{...T, ...}>) {
  const keyValueItems = [];

  for (const key of Object.keys(spec)) {
    const jsonKey = JSON.stringify(key);
    keyValueItems.push(jsonKey + ':o[' + jsonKey + ']');
  }

  // $FlowIgnore[incompatible-return]
  return new Function(
    'o',
    'return {' + keyValueItems.join(',') + '}',
  );
}
