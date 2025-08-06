/*
 * @flow strict
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import {fixedWidthInteger} from './strings.js';

function formatDate(date: ?{
  +day?: ?StrOrNum,
  +month?: ?StrOrNum,
  +year?: ?StrOrNum,
}): string {
  if (!date) {
    return '';
  }

  const y: StrOrNum | null = ko.unwrap(date.year ?? null);
  const m: StrOrNum | null = ko.unwrap(date.month ?? null);
  const d: StrOrNum | null = ko.unwrap(date.day ?? null);

  let result = '';

  if (nonEmpty(y)) {
    result += fixedWidthInteger(y, 4);
  } else if (nonEmpty(m) || nonEmpty(d)) {
    result = '????';
  }

  if (nonEmpty(m)) {
    result += '-' + fixedWidthInteger(m, 2);
  } else if (nonEmpty(d)) {
    result += '-??';
  }

  if (nonEmpty(d)) {
    result += '-' + fixedWidthInteger(d, 2);
  }

  return result;
}

export default formatDate;
