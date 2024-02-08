/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */


const ymdRegex = /^\W*([0-9]{4})(?:\W+(0?[1-9]|1[0-2])(?:\W+(0?[1-9]|[12][0-9]|3[01]))?)?\W*$/;
const cjkRegex = /^\W*([0-9]{2}|[0-9]{4})(?:(?:\u5E74|\uB144\W?)(0?[1-9]|1[0-2])(?:(?:\u6708|\uC6D4\W?)(0?[1-9]|[12][0-9]|3[01])(?:\u65E5|\uC77C)?)?)?\W*$/;

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

  // See https://reference.discogs.com/wiki/japanese-release-dates#date-format
  const japaneseYearCodes = {
    /* eslint-disable sort-keys */
    N: '1984',
    I: '1985',
    H: '1986',
    O: '1987',
    R: '1988',
    E: '1989',
    C: '1990',
    D: '1991',
    K: '1992',
    L: '1993',
    /* eslint-enable sort-keys */
  };
  cleanedString = cleanedString.replace(
    /([NIHORECDKL])-([0-9]{1,2}-[0-9]{1,2})/,
    function (match, year, date) {
      return japaneseYearCodes[year] + '-' + date;
    },
  );

  // RoC year numbering - http://en.wikipedia.org/wiki/Minguo_calendar
  cleanedString = cleanedString.replace(
    /民國([0-9]{1,3})/,
    function (match, year) {
      return String(parseInt(year, 10) + 1911);
    },
  );

  return cleanedString;
}

export function parseNaturalDate(
  str: string,
): PartialDateStringsT {
  const cleanedString = cleanDateString(str);

  const match = cleanedString.match(cjkRegex) ||
                cleanedString.match(ymdRegex) ||
                [];

  return {
    /* eslint-disable sort-keys */
    year: match[1] || '',
    month: match[2] || '',
    day: match[3] || '',
    /* eslint-enable sort-keys */
  };
}

export default parseNaturalDate;
