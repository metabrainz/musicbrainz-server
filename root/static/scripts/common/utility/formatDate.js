/*
 * @flow
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

  const y: number = ko.unwrap(date.year);
  const m: number = ko.unwrap(date.month);
  const d: number = ko.unwrap(date.day);

  let result = '';

  if (nonEmpty(y)) {
    result += fixedWidthInteger(y, 4);
  } else if (m || d) {
    result = '????';
  }

  if (m) {
    result += '-' + fixedWidthInteger(m, 2);
  } else if (d) {
    result += '-??';
  }

  if (d) {
    result += '-' + fixedWidthInteger(d, 2);
  }

  return result;
}

export default formatDate;
