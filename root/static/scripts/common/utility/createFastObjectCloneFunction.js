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
 * node v20.11.1:
 * spread x 31,909,715 ops/sec ±0.95% (87 runs sampled)
 * fastClone x 196,128,209 ops/sec ±1.08% (90 runs sampled)
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

  // $FlowIgnore[incompatible-type]
  return new Function(
    'o',
    'return {' + keyValueItems.join(',') + '}',
  );
}
