/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */


const ymdRegex = /^\W*([0-9]{4})(?:\W+(0?[1-9]|1[0-2])(?:\W+(0?[1-9]|[12][0-9]|3[01]))?)?\W*$/;

function cleanDateString(
  str: string,
): string {
  let cleanedString = str;

  // Clean fullwidth digits to standard digits
  cleanedString = cleanedString.replace(
    /[０-９－]/g,
    function (fullwidthDigit) {
      return String.fromCharCode(
        fullwidthDigit.charCodeAt(0) -
        ('０'.charCodeAt(0) - '0'.charCodeAt(0)),
      );
    },
  );

  return cleanedString;
}

export function parseNaturalDate(
  str: string,
): PartialDateStringsT {
  const cleanedString = cleanDateString(str);

  const match = cleanedString.match(ymdRegex) || [];
  return {
    /* eslint-disable sort-keys */
    year: match[1] || '',
    month: match[2] || '',
    day: match[3] || '',
    /* eslint-enable sort-keys */
  };
}

export default parseNaturalDate;
