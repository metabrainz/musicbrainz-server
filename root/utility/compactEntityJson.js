/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * `compactEntityJson` compacts large JSON objects into an array of unique
 * values, referenced by index.  While this can save space if many values are
 * repeated, the main use is the ability to serialize circular references into
 * JSON.
 *
 * You can use `decompactEntityJson` to get the original object back.
 *
 * compactEntityJson({"key": "value"})
 *    -> [{"1": 2}, "key", "value"]
 */

const functionToString: () => string =
  // $FlowIgnore[method-unbinding]
  Function.prototype.toString;
const objectCtorString: string = functionToString.call(Object);

function _indexValue(
  value: mixed,
  indexCache: Map<mixed, number>,
  result: Array<mixed>,
): number {
  let index = indexCache.get(value);
  if (index != null) {
    return index;
  }

  index = result.length;
  indexCache.set(value, index);
  result.push(undefined);

  let compactValue;

  switch (typeof value) {
    case 'boolean':
    case 'number':
    case 'string':
      compactValue = value;
      break;
    case 'object': {
      if (value) {
        if (Array.isArray(value)) {
          compactValue = [];
          for (const arrayItem of value) {
            compactValue.push(
              _indexValue(
                arrayItem,
                indexCache,
                result,
              ),
            );
          }
        } else {
          const prototype = Object.getPrototypeOf(value);
          if (
            prototype &&
            // $FlowIgnore[prop-missing]
            typeof prototype.constructor === 'function' &&
            functionToString.call(prototype.constructor) === objectCtorString
          ) {
            compactValue = {};
            for (const objectKey in value) {
              if (hasOwnProp(value, objectKey)) {
                const compactObjectKey = _indexValue(
                  objectKey,
                  indexCache,
                  result,
                );
                const compactObjectValue = _indexValue(
                  value[objectKey],
                  indexCache,
                  result,
                );
                compactValue[compactObjectKey] = compactObjectValue;
              }
            }
          } else {
            throw new Error(
              'Only plain objects and arrays can be converted into JSON',
            );
          }
        }
      } else {
        compactValue = null;
      }
      break;
    }
    // $FlowIssue[illegal-typeof]
    case 'bigint':
    case 'function':
    case 'symbol':
    case 'undefined': {
      throw new Error(`Cannot convert ${typeof value} to JSON`);
    }
  }

  result[index] = compactValue;
  return index;
}

export function compactEntityJson(
  value: mixed,
): $ReadOnlyArray<mixed> {
  const result = [];
  _indexValue(value, new Map(), result);
  return result;
}

export function decompactEntityJson(
  compactedArray: $ReadOnlyArray<mixed>,
): mixed {
  const resolved = new Array(compactedArray.length);

  function _decompactIndex(
    index: number,
  ): mixed {
    const value = compactedArray[index];
    if (typeof value === 'object' && value !== null) {
      const resolvedValue = resolved[index];
      if (resolvedValue !== undefined) {
        return resolvedValue;
      }
      if (Array.isArray(value)) {
        const result = [];
        resolved[index] = result;
        for (let i = 0; i < value.length; i++) {
          result.push(_decompactIndex(value[i]));
        }
        return result;
      }
      const result = {};
      resolved[index] = result;
      for (const objectKeyIndex in value) {
        if (hasOwnProp(value, objectKeyIndex)) {
          const objectKey = compactedArray[+objectKeyIndex];
          /*:: invariant(typeof objectKey === 'string'); */
          const objectValueIndex = value[objectKeyIndex];
          /*:: invariant(typeof objectValueIndex === 'number'); */
          result[objectKey] = _decompactIndex(objectValueIndex);
        }
      }
      return result;
    }
    return value;
  }

  return _decompactIndex(0);
}
