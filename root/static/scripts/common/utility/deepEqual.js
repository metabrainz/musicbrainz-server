/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * Note: This module is used by t/selenium.js.
 */
/* eslint-disable import/no-commonjs */

const objectPrototype = Object.prototype;
// $FlowIgnore[method-unbinding]
const hasOwnProperty = objectPrototype.hasOwnProperty;

function deepEqual(
  a/*: any */,
  b/*: any */,
  cmp/*:: ?: (any, any) => boolean */,
)/*: boolean */ {
  if (cmp) {
    const result = cmp(a, b);
    // returning null or undefined performs the default comparison
    if (result != null) {
      return Boolean(result);
    }
  }
  if (Object.is(a, b)) {
    return true;
  }
  // a & b have different values
  const aType = typeof a;
  if (aType !== typeof b) {
    return false;
  }
  // a & b have the same type
  switch (aType) {
    case 'boolean':
    case 'number':
    case 'string':
      return false;

    case 'object': {
      if (
        (a === null || b === null) ||
        (Object.getPrototypeOf(a) !== Object.getPrototypeOf(b))
      ) {
        return false;
      }
      const aIsArray = Array.isArray(a);
      if (aIsArray !== Array.isArray(b)) {
        return false;
      }
      if (aIsArray) {
        const aLength = a.length;
        if (aLength !== b.length) {
          return false;
        }
        for (let i = 0; i < aLength; i++) {
          if (!deepEqual(a[i], b[i], cmp)) {
            return false;
          }
        }
      } else {
        const aKeys = Object.keys(a);
        const bKeys = Object.keys(b);
        if (aKeys.length !== bKeys.length) {
          return false;
        }
        const keySet = new Set(aKeys.concat(bKeys));
        for (const key of keySet) {
          if (
            hasOwnProperty.call(a, key) !== hasOwnProperty.call(b, key) ||
            !deepEqual(a[key], b[key], cmp)
          ) {
            return false;
          }
        }
      }
      return true;
    }
    default: {
      throw new Error('Unsupported value type: ' + aType);
    }
  }
}

module.exports = deepEqual;
