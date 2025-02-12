/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import * as arrays from '../../common/utility/arrays.js';
import {compareStrings} from '../../common/utility/compare.mjs';

const emptyArray: Array<string> = [];
const oneItemStringArray = ['platypus'];
const multiItemStringArray = ['echidna', 'platypus', 'kangaroo'];
const idsAndNamesArray = [
  {id: 2, name: 'kangaroo'},
  {id: 4, name: 'echidna'},
  {id: 1, name: 'quokka'},
  {id: 3, name: 'platypus'},
];
const arrayWithDupes = [
  {id: 1, name: 1},
  {id: 1, name: '1'},
  {id: 2, name: '1'},
  {id: 3, name: '1'},
];

test('arraysEqual', function (t) {
  t.plan(4);

  t.ok(
    arrays.arraysEqual(emptyArray, emptyArray),
    'Two empty arrays are equal by default',
  );

  t.ok(
    arrays.arraysEqual(multiItemStringArray, multiItemStringArray),
    'Two of the same array are equal by default',
  );

  t.ok(
    !arrays.arraysEqual([1], ['1']),
    'Two arrays with the string 1 vs the number 1 are not equal by default',
  );

  t.ok(
    arrays.arraysEqual(
      [1],
      ['1'],
      (a, b) => a.toString() === b.toString(),
    ),
    'Two arrays with the string 1 vs the number 1 are equal when passing isEqual function which uses toString',
  );
});

test('compactMap', function (t) {
  t.plan(1);

  t.deepEqual(
    arrays.compactMap(multiItemStringArray, item => item.charAt(0)),
    ['e', 'p', 'k'],
    'Returns the right result when mapping charAt(0) in array of strings',
  );
});

test('sortedFindOrInsert', function (t) {
  t.plan(10);

  const sortedMultiItemStringArray =
    [...multiItemStringArray].sort(compareStrings);

  t.equal(
    arrays.sortedFindOrInsert(
      sortedMultiItemStringArray,
      'kangaroo',
      compareStrings,
    ),
    'kangaroo',
    'Array of strings: Passed/existing value returned when it exists',
  );

  t.equal(
    sortedMultiItemStringArray.length,
    3,
    'Array of strings: Value not inserted when it already exists',
  );

  t.equal(
    arrays.sortedFindOrInsert(
      sortedMultiItemStringArray,
      'koala',
      compareStrings,
    ),
    'koala',
    'Array of strings: Passed value returned when it does not exist',
  );

  t.equal(
    sortedMultiItemStringArray.length,
    4,
    'Array of strings: Value inserted when it does not exist',
  );

  t.deepEqual(
    sortedMultiItemStringArray,
    ['echidna', 'kangaroo', 'koala', 'platypus'],
    'Array of strings: Value inserted in the right position',
  );

  const sortedIdsAndNamesArray = [...arrays.sortByNumber(
    idsAndNamesArray,
    x => x.id,
  )];

  t.deepEqual(
    arrays.sortedFindOrInsert(
      sortedIdsAndNamesArray,
      {id: 1, name: 'koala'},
      (a, b) => a.id - b.id,
    ),
    {id: 1, name: 'quokka'},
    'Array of objects: Existing object returned when object with same id exists',
  );

  t.equal(
    sortedIdsAndNamesArray.length,
    4,
    'Array of objects: Object not inserted when object with same id exists',
  );

  t.deepEqual(
    arrays.sortedFindOrInsert(
      sortedIdsAndNamesArray,
      {id: 5, name: 'koala'},
      (a, b) => a.id - b.id,
    ),
    {id: 5, name: 'koala'},
    'Array of objects: Passed object returned when object with same id does not exist',
  );

  t.equal(
    sortedIdsAndNamesArray.length,
    5,
    'Array of objects: Object inserted when object with same id does not exist',
  );

  t.deepEqual(
    sortedIdsAndNamesArray,
    [
      {id: 1, name: 'quokka'},
      {id: 2, name: 'kangaroo'},
      {id: 3, name: 'platypus'},
      {id: 4, name: 'echidna'},
      {id: 5, name: 'koala'},
    ],
    'Array of objects: Object inserted in the right position',
  );
});

test('mergeSortedArrayInto', function (t) {
  t.plan(2);

  const sortedMultiItemStringArray =
    [...multiItemStringArray].sort(compareStrings);

  arrays.mergeSortedArrayInto(
    sortedMultiItemStringArray,
    ['quokka', 'kangaroo', 'koala'],
    compareStrings,
  );

  t.deepEqual(
    sortedMultiItemStringArray,
    ['echidna', 'kangaroo', 'koala', 'platypus', 'quokka'],
    'Array of strings: New items are added (sorted), repeats are not duplicated',
  );

  const sortedIdsAndNamesArray = [...arrays.sortByNumber(
    idsAndNamesArray,
    x => x.id,
  )];

  arrays.mergeSortedArrayInto(
    sortedIdsAndNamesArray,
    [
      {id: 2, name: 'kangaroo'},
      {id: 6, name: 'bandicoot'},
      {id: 5, name: 'koala'},
    ],
    (a, b) => a.id - b.id,
  );

  t.deepEqual(
    sortedIdsAndNamesArray,
    [
      {id: 1, name: 'quokka'},
      {id: 2, name: 'kangaroo'},
      {id: 3, name: 'platypus'},
      {id: 4, name: 'echidna'},
      {id: 5, name: 'koala'},
      {id: 6, name: 'bandicoot'},
    ],
    'Array of objects: New items are added (sorted), repeats are not duplicated',
  );
});

test('sortedIndexWith', function (t) {
  t.plan(4);

  const sortedMultiItemStringArray =
    [...multiItemStringArray].sort(compareStrings);

  t.deepEqual(
    arrays.sortedIndexWith(
      sortedMultiItemStringArray,
      'kangaroo',
      compareStrings,
    ),
    [1, true],
    'Array of strings: right index and exists: true for string already in array',
  );

  t.deepEqual(
    arrays.sortedIndexWith(
      sortedMultiItemStringArray,
      'koala',
      compareStrings,
    ),
    [2, false],
    'Array of strings: right index and exists: false for string not in array',
  );

  const sortedIdsAndNamesArray = [...arrays.sortByNumber(
    idsAndNamesArray,
    x => x.id,
  )];

  t.deepEqual(
    arrays.sortedIndexWith(
      sortedIdsAndNamesArray,
      {id: 1, name: 'koala'},
      (a, b) => a.id - b.id,
    ),
    [0, true],
    'Array of objects: right index and exists: true for object with id already in array',
  );

  t.deepEqual(
    arrays.sortedIndexWith(
      sortedIdsAndNamesArray,
      {id: 5, name: 'koala'},
      (a, b) => a.id - b.id,
    ),
    [4, false],
    'Array of object: right index and exists: false for object with id not in array',
  );
});

test('sortByNumber', function (t) {
  t.plan(2);

  t.deepEqual(
    arrays.sortByNumber(idsAndNamesArray, x => x.id),
    [
      {id: 1, name: 'quokka'},
      {id: 2, name: 'kangaroo'},
      {id: 3, name: 'platypus'},
      {id: 4, name: 'echidna'},
    ],
    'Default numeric sort orders in ascending order by property',
  );

  t.deepEqual(
    arrays.sortByNumber(
      idsAndNamesArray,
      x => x.id,
      (a, b) => (a > b ? -1 : 1),
    ),
    [
      {id: 4, name: 'echidna'},
      {id: 3, name: 'platypus'},
      {id: 2, name: 'kangaroo'},
      {id: 1, name: 'quokka'},
    ],
    'Array is sorted by descendent number when passed the appropriate custom sorter',
  );
});

test('sortByString', function (t) {
  t.plan(2);

  t.deepEqual(
    arrays.sortByString(idsAndNamesArray, x => x.name),
    [
      {id: 4, name: 'echidna'},
      {id: 2, name: 'kangaroo'},
      {id: 3, name: 'platypus'},
      {id: 1, name: 'quokka'},
    ],
    'Default string sort orders A-Z by property',
  );

  t.deepEqual(
    arrays.sortByString(
      idsAndNamesArray,
      x => x.name,
      (a, b) => (a > b ? -1 : 1),
    ),
    [
      {id: 1, name: 'quokka'},
      {id: 3, name: 'platypus'},
      {id: 2, name: 'kangaroo'},
      {id: 4, name: 'echidna'},
    ],
    'Array is sorted Z-A by property when passed the appropriate custom sorter',
  );
});

test('groupBy', function (t) {
  t.plan(6);

  const mapById = arrays.groupBy(arrayWithDupes, x => x.id);

  t.deepEqual(
    mapById.size,
    3,
    'groupBy id returns two keys',
  );

  t.deepEqual(
    mapById.get(1),
    [{id: 1, name: 1}, {id: 1, name: '1'}],
    'groupBy id returns the expected result for key 1',
  );

  const mapByName = arrays.groupBy(arrayWithDupes, x => x.name);

  t.equal(
    mapByName.size,
    2,
    'groupBy name returns two keys',
  );

  t.deepEqual(
    mapByName.get(1),
    [{id: 1, name: 1}],
    'groupBy name returns the expected result for name 1',
  );

  const mapByNameString = arrays.groupBy(
    arrayWithDupes,
    x => x.name.toString(),
  );

  t.equal(
    mapByNameString.size,
    1,
    'groupBy name.toString returns one key',
  );

  t.deepEqual(
    mapByNameString.get('1'),
    [
      {id: 1, name: 1},
      {id: 1, name: '1'},
      {id: 2, name: '1'},
      {id: 3, name: '1'},
    ],
    'groupBy name.toString returns the expected result for key \'1\'',
  );
});

test('first', function (t) {
  t.plan(3);

  t.equal(
    arrays.first(emptyArray),
    undefined,
    'First item of an empty array is undefined',
  );

  t.equal(
    arrays.first(oneItemStringArray),
    'platypus',
    'First item of a one item array is the only item',
  );

  t.equal(
    arrays.first(multiItemStringArray),
    'echidna',
    'First item of a multi-item array is the expected one',
  );
});

test('last', function (t) {
  t.plan(3);

  t.equal(
    arrays.last(emptyArray),
    undefined,
    'Last item of an empty array is undefined',
  );

  t.equal(
    arrays.last(oneItemStringArray),
    'platypus',
    'Last item of a one item array is the only item',
  );

  t.equal(
    arrays.last(multiItemStringArray),
    'kangaroo',
    'Last item of a multi-item array is the expected one',
  );
});

test('keyBy', function (t) {
  t.plan(6);

  const mapById = arrays.keyBy(arrayWithDupes, x => x.id);
  t.equal(
    mapById.size,
    3,
    'keyBy id returns three keys',
  );

  t.deepEqual(
    mapById.get(1),
    {id: 1, name: '1'},
    'keyBy id returns the expected result for key 1',
  );

  const mapByName = arrays.keyBy(arrayWithDupes, x => x.name);

  t.equal(
    mapByName.size,
    2,
    'keyBy name returns two keys',
  );

  t.deepEqual(
    mapByName.get(1),
    {id: 1, name: 1},
    'keyBy name returns the expected result for name 1',
  );

  const mapByNameString = arrays.keyBy(
    arrayWithDupes,
    x => x.name.toString(),
  );

  t.equal(
    mapByNameString.size,
    1,
    'keyBy name.toString returns one key',
  );

  t.deepEqual(
    mapByNameString.get('1'),
    {id: 3, name: '1'},
    'keyBy name.toString returns the expected result for key \'1\'',
  );
});

test('uniqBy', function (t) {
  t.plan(3);

  t.equal(
    arrays.uniqBy(arrayWithDupes, x => x.id).length,
    3,
    'uniqBy id leaves 3 entries in the array as expected',
  );

  t.equal(
    arrays.uniqBy(arrayWithDupes, x => x.name).length,
    2,
    'uniqBy name leaves 3 entries in the array as expected',
  );

  t.equal(
    arrays.uniqBy(arrayWithDupes, x => x.name.toString()).length,
    1,
    'uniqBy name.toString leaves just 1 entry in the array as expected',
  );
});
