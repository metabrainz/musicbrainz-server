/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable sort-keys */
const NULL_DATE: PartialDateT = Object.freeze({
  year: -Infinity,
  month: 1,
  day: 1,
});
/* eslint-enable sort-keys */

export default function compareDates(a: ?PartialDateT, b: ?PartialDateT) {
  a = a || NULL_DATE;
  b = b || NULL_DATE;

  const result = (a.year || -Infinity) - (b.year || -Infinity);
  // Both have no year
  if (isNaN(result)) {
    return 0;
  } else if (result) {
    return result;
  }

  return (
    ((a.month || 1) - (b.month || 1)) ||
    ((a.day || 1) - (b.day || 1))
  );
}
