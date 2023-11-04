/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import * as strings from '../../common/utility/strings.js';

test('capitalize', function (t) {
  t.plan(6);

  t.equal(
    strings.capitalize('stuff'),
    'Stuff',
    'Lowercase one-word string',
  );

  t.equal(
    strings.capitalize('some stuff'),
    'Some stuff',
    'Lowercase multi-word string',
  );

  t.equal(
    strings.capitalize('STUFF'),
    'Stuff',
    'Uppercase one-word string',
  );

  t.equal(
    strings.capitalize('SOME STUFF'),
    'Some stuff',
    'Uppercase multi-word string',
  );

  t.equal(
    strings.capitalize('sTuFf'),
    'Stuff',
    'Mixed case one-word string',
  );

  t.equal(
    strings.capitalize('sOMe STUff'),
    'Some stuff',
    'Mixed case multi-word string',
  );
});

test('fixedWidthInteger', function (t) {
  t.plan(9);

  t.equal(
    strings.fixedWidthInteger('stuff', 10),
    '0000000000',
    'Passing non-number string returns string of zeroes of requested length',
  );

  t.equal(
    strings.fixedWidthInteger('1234', 10),
    '0000001234',
    'Passing number string shorter than the requested length returns string of the number padded by zeros',
  );

  t.equal(
    strings.fixedWidthInteger(1234, 10),
    '0000001234',
    'Passing number shorter than the requested length returns string of the number padded by zeros',
  );

  t.equal(
    strings.fixedWidthInteger('1234567890', 10),
    '1234567890',
    'Passing number string as long as the requested length returns the same number string',
  );

  t.equal(
    strings.fixedWidthInteger(1234567890, 10),
    '1234567890',
    'Passing number as long as the requested length returns the same number as a string',
  );

  t.equal(
    strings.fixedWidthInteger('123456789012345', 10),
    '123456789012345',
    'Passing number string longer than the requested length returns the same number string',
  );

  t.equal(
    strings.fixedWidthInteger(123456789012345, 10),
    '123456789012345',
    'Passing number as longer than the requested length returns the same number as a string',
  );

  t.equal(
    strings.fixedWidthInteger('-1234', 10),
    '-0000001234',
    'Passing negative number string shorter than the requested length returns string of the negative number padded by zeros',
  );

  t.equal(
    strings.fixedWidthInteger(-1234, 10),
    '-0000001234',
    'Passing negative number shorter than the requested length returns string of the negative number padded by zeros',
  );
});

test('upperFirst', function (t) {
  t.plan(6);

  t.equal(
    strings.upperFirst('stuff'),
    'Stuff',
    'Lowercase one-word string',
  );

  t.equal(
    strings.upperFirst('some stuff'),
    'Some stuff',
    'Lowercase multi-word string',
  );

  t.equal(
    strings.upperFirst('STUFF'),
    'STUFF',
    'Uppercase one-word string',
  );

  t.equal(
    strings.upperFirst('SOME STUFF'),
    'SOME STUFF',
    'Uppercase multi-word string',
  );

  t.equal(
    strings.upperFirst('sTuFf'),
    'STuFf',
    'Mixed case one-word string',
  );

  t.equal(
    strings.upperFirst('sOMe STUff'),
    'SOMe STUff',
    'Mixed case multi-word string',
  );
});

test('kebabCase', function (t) {
  t.plan(6);

  t.equal(
    strings.kebabCase('stuff'),
    'stuff',
    'Lowercase one-word string',
  );

  t.equal(
    strings.kebabCase('some stuff'),
    'some-stuff',
    'Lowercase multi-word string',
  );

  t.equal(
    strings.kebabCase('STUFF'),
    'stuff',
    'Uppercase one-word string',
  );

  t.equal(
    strings.kebabCase('SOME STUFF'),
    'some-stuff',
    'Uppercase multi-word string',
  );

  t.equal(
    strings.kebabCase('sTuFf'),
    's-tu-ff',
    'Mixed case one-word string',
  );

  t.equal(
    strings.kebabCase('sOMe STUff'),
    's-ome-stuff',
    'Mixed case multi-word string',
  );
});

test('unaccent', function (t) {
  t.plan(4);

  t.equal(
    strings.unaccent('stuff'),
    'stuff',
    'English ASCII word',
  );

  t.equal(
    strings.unaccent('España'),
    'Espana',
    'Spanish ñ',
  );

  t.equal(
    strings.unaccent('lavaş'),
    'lavas',
    'Turkish ş',
  );

  t.equal(
    strings.unaccent('côté'),
    'cote',
    'French accents',
  );
});

test('uniqueId', function (t) {
  t.plan(3);

  // We get the first string to calculate the rest from it
  const initialId = parseInt(strings.uniqueId(), 10);

  t.equal(
    strings.uniqueId(),
    String(initialId + 1),
    'First call adds one to the original ID',
  );

  t.equal(
    strings.uniqueId(),
    String(initialId + 2),
    'Second call adds two to the original ID',
  );

  t.equal(
    strings.uniqueId('id-'),
    'id-' + String(initialId + 3),
    'Third call (with prefix "id") returns "id-" followed by adding three to the original ID',
  );
});
