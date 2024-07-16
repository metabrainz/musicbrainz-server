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

function formatDate(date: ?PartialDateT): string {
  if (!date) {
    return '';
  }

  const y: number | null = ko.unwrap(date.year ?? null);
  const m: number | null = ko.unwrap(date.month ?? null);
  const d: number | null = ko.unwrap(date.day ?? null);

  let result = '';

  if (nonEmpty(y)) {
    let year = y;
    // Turn astronomical year into BCE year
    if (year <= 0) {
      year--;
    }
    result += fixedWidthInteger(year, 4);
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
