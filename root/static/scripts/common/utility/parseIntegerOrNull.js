/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import parseInteger from './parseInteger.js';

export default function parseIntegerOrNull(value: ?StrOrNum): number | null {
  if (value == null) {
    return null;
  }
  const integer = parseInteger(String(value));
  return isNaN(integer) ? null : integer;
}
