/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */
/* eslint-disable multiline-comment-style */

function _cloneDeep/*:: <+T> */(
  value/*: T */,
  seen/*: WeakMap<any, any> */,
)/*: any */ {
  if (value != null && typeof value === 'object') {
    const clone = seen.get(value);
    if (clone) {
      return clone;
    }
    if (Array.isArray(value)) {
      return _cloneArrayDeep(value, seen);
    }
    return _cloneObjectDeep(value, seen);
  }
  return value;
}

function _cloneArrayDeep/*:: <+T> */(
  array/*: $ReadOnlyArray<T> */,
  seen/*: WeakMap<any, any> */,
)/*: $ReadOnlyArray<T> */ {
  const clone/*: Array<T> */ = [];
  seen.set(array, clone);
  const size = array.length;
  for (let i = 0; i < size; i++) {
    clone.push(_cloneDeep/*:: <T> */(array[i], seen));
  }
  return clone;
}

function cloneArrayDeep/*:: <+T> */(
  array/*: $ReadOnlyArray<T> */,
)/*: $ReadOnlyArray<T> */ {
  return _cloneArrayDeep/*:: <T> */(array, new WeakMap());
}

/*
 * This module is imported by our Webpack config file, so don't use
 * `hasOwnProp` here. It's not available!
 */
// $FlowIgnore[method-unbinding]
const hasOwnProperty = Object.prototype.hasOwnProperty;

function _cloneObjectDeep/*:: <+T: {...}> */(
  object/*: T */,
  seen/*: WeakMap<any, any> */,
)/*: T */ {
  const clone/*: any */ = Object.create(Object.getPrototypeOf(object));
  seen.set(object, clone);
  for (const key in object) {
    if (hasOwnProperty.call(object, key)) {
      clone[key] = _cloneDeep(object[key], seen);
    }
  }
  return clone;
}

function cloneObjectDeep/*:: <+T: {...}> */(
  object/*: T */,
)/*: T */ {
  return _cloneObjectDeep/*:: <T> */(object, new WeakMap());
}

exports.cloneArrayDeep = cloneArrayDeep;
exports.cloneObjectDeep = cloneObjectDeep;
