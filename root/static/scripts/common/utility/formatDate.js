/*
 * @flow
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import padStart from 'lodash/padStart';
import nonEmpty from './nonEmpty';

function formatDate(date: PartialDateT | null): string {
  if (!date) {
    return '';
  }

  const y: number = ko.unwrap(date.year);
  const m: number = ko.unwrap(date.month);
  const d: number = ko.unwrap(date.day);

  let result = '';

  if (nonEmpty(y)) {
    if (y < 0) {
      result += '-' + padStart(String(-y), 3, '0');
    } else {
      result += padStart(String(y), 4, '0');
    }
  } else if (m || d) {
    result = '????';
  }

  if (m) {
    result += '-' + padStart(String(m), 2, '0');
  } else if (d) {
    result += '-??';
  }

  if (d) {
    result += '-' + padStart(String(d), 2, '0');
  }

  return result;
}

export default formatDate;
