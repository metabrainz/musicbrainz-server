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

function formatDate(date: PartialDateT | null): string {
  if (!date) {
    return '';
  }

  const y: number | null = ko.unwrap(date.year);
  const m: number | null = ko.unwrap(date.month);
  const d: number | null = ko.unwrap(date.day);

  let result = '';

  if (nonEmpty(y)) {
    result += fixedWidthInteger(y, 4);
  } else if (m != null || d != null) {
    result = '????';
  }

  if (m != null) {
    result += '-' + fixedWidthInteger(m, 2);
  } else if (d != null) {
    result += '-??';
  }

  if (d != null) {
    result += '-' + fixedWidthInteger(d, 2);
  }

  return result;
}

export default formatDate;
