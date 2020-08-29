/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

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
