/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {uniqueId as uniqueNumericId} from './numbers.js';

export function capitalize(str: string): string {
  return str[0].toUpperCase() + str.slice(1).toLowerCase();
}

export function fixedWidthInteger(input: StrOrNum, len: number): string {
  let num = input;
  if (typeof num === 'string') {
    num = Number.parseInt(num, 10);
    if (Number.isNaN(num)) {
      num = 0;
    }
  }
  const negative = num < 0;
  return (negative ? '-' : '') +
    (String(negative ? -num : num).padStart(len, '0'));
}

export function upperFirst(str: string): string {
  return str[0].toUpperCase() + str.slice(1);
}

const lowerThenUpper = /([a-z])([A-Z])/g;
const nonWord = /[^0-9A-Za-z]+/g;

export function kebabCase(str: string): string {
  return str
    .replace(lowerThenUpper, '$1-$2')
    .replace(nonWord, '-')
    .toLowerCase();
}

const combiningDiacriticalMarks = /[\u0300-\u036F]/g;

export function unaccent(str: string): string {
  return str
    .normalize('NFD')
    .replace(combiningDiacriticalMarks, '');
}

export function uniqueId(prefix?: string = ''): string {
  return prefix + String(uniqueNumericId());
}
