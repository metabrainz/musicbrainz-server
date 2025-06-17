/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {arraysEqual} from '../../../common/utility/arrays.js';
import {
  compactEntityJson,
  decompactEntityJson,
} from '../../../edit/utility/compactEntityJson.js';

test('compact/decompact', function (t) {
  t.plan(12);

  type CyclicObject = {
    array: Array<mixed>,
    boolean: boolean,
    cycle?: CyclicObject,
    null: null,
    number: number,
    string: string,
  };
  type CyclicObjectTuple = [CyclicObject, CyclicObject];

  const object: CyclicObject = {
    array: [true, null, 12, 'bar'],
    boolean: false,
    null: null,
    number: -9,
    string: 'foo',
  };
  object.cycle = object;

  const strictEqual = (a: mixed, b: mixed) => Object.is(a, b);

  function areCyclicObjectsEqual(
    a: CyclicObject,
    b: CyclicObject,
  ) {
    return (
      arraysEqual(a.array, b.array, strictEqual) &&
      strictEqual(a.boolean, b.boolean) &&
      strictEqual(a.cycle, a) &&
      strictEqual(b.cycle, b) &&
      strictEqual(a.null, b.null) &&
      strictEqual(a.number, b.number) &&
      strictEqual(a.string, b.string)
    );
  }

  function runTest<T>(
    value: T,
    valueType: string,
    isEqual: (T, T) => boolean,
  ) {
    // eslint-disable-next-line ft-flow/no-weak-types
    const result: any = decompactEntityJson(compactEntityJson(value));
    t.ok(
      isEqual(value, result),
      'can compact and decompact ' + valueType,
    );
  }

  runTest('value', 'strings', strictEqual);
  runTest('123', 'numbers', strictEqual);
  runTest(true, 'booleans', strictEqual);
  runTest(null, 'nulls', strictEqual);
  runTest(object, 'circular objects', areCyclicObjectsEqual);
  runTest(
    [object, object],
    'arrays containing circular objects',
    (a: CyclicObjectTuple, b: CyclicObjectTuple) => (
      a.length === 2 &&
      b.length === 2 &&
      strictEqual(a[0], a[1]) &&
      strictEqual(b[0], b[1]) &&
      areCyclicObjectsEqual(a[0], b[0])
    ),
  );

  const errorCases = [
    {
      error: 'Only plain objects and arrays can be converted into JSON',
      message: 'cannot serialize objects with null prototypes',
      value: Object.create(null),
    },
    {
      error: 'Only plain objects and arrays can be converted into JSON',
      message: 'cannot serialize class instances',
      value: new (class Foo {})(),
    },
    {
      error: 'Cannot convert function to JSON',
      message: 'cannot serialize functions',
      value: {value: () => {}},
    },
    {
      error: 'Cannot convert bigint to JSON',
      message: 'cannot serialize bigints',
      value: {value: BigInt(0)},
    },
    {
      error: 'Cannot convert symbol to JSON',
      message: 'cannot serialize symbols',
      value: {value: Symbol()},
    },
    {
      error: 'Cannot convert undefined to JSON',
      message: 'cannot serialize undefined',
      value: {value: undefined},
    },
  ];

  for (const errorCase of errorCases) {
    t.throws(
      () => compactEntityJson(errorCase.value),
      {message: errorCase.error},
      errorCase.message,
    );
  }
});
