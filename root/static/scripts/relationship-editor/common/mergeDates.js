/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import parseIntegerOrNull from '../../common/utility/parseIntegerOrNull.js';

function conflict(a, b, prop) {
  return nonEmpty(a[prop]) && nonEmpty(b[prop]) && a[prop] !== b[prop];
}

var unwrapInteger = x => parseIntegerOrNull(ko.unwrap(x));

function mergeDates(a, b) {
  a = {
    year: unwrapInteger(a.year),
    month: unwrapInteger(a.month),
    day: unwrapInteger(a.day),
  };
  b = {
    year: unwrapInteger(b.year),
    month: unwrapInteger(b.month),
    day: unwrapInteger(b.day),
  };

  if (conflict(a, b, 'year') ||
      conflict(a, b, 'month') ||
      conflict(a, b, 'day')) {
    return null;
  }

  /* eslint-disable no-multi-spaces */
  return {
    year:  nonEmpty(a.year)  ? a.year  : b.year,
    month: nonEmpty(a.month) ? a.month : b.month,
    day:   nonEmpty(a.day)   ? a.day   : b.day,
  };
  /* eslint-enable no-multi-spaces */
}

export default mergeDates;
