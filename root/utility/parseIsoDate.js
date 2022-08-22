/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * This is intended to support parsing a specific, limited subset of the
 * ISO-8601 datetime format (though it can be expanded if needed):
 *
 *  1. The output of the DateTime::iso8601 method in Perl, with 'Z' appended.
 *     See Entity::Role::LastUpdate::TO_JSON.
 *
 *  2. The output of Date.prototype.toISOString() in JavaScript, which is
 *     identical to the above except with subseconds included.
 */

const isoFormat = new RegExp(
  '^' +
  '(-?[0-9]{4})' +      // year
  '-([0-9]{2})' +       // month
  '-([0-9]{2})' +       // day
  'T([0-9]{2})' +       // hours
  ':([0-9]{2})' +       // minutes
  ':([0-9]{2})' +       // seconds
  '(?:\\.[0-9]{3})?' +  // (optional) subseconds
  'Z$',
);

const parseIntBase10 = (x: string) => parseInt(x, 10);

export default function parseIsoDate(isoDate: string): Date | null {
  const match = isoDate.match(isoFormat);

  if (!match) {
    return null;
  }

  const [year, month, day, hour, minute, second] =
    match.slice(1, 7).map(parseIntBase10);

  // Note: The Date API requires that months start at 0.
  return new Date(Date.UTC(year, month - 1, day, hour, minute, second));
}
