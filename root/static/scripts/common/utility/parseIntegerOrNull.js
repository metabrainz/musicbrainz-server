/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import parseInteger from './parseInteger';

export default function parseIntegerOrNull(str: string): number | null {
  const integer = parseInteger(str);
  return isNaN(integer) ? null : integer;
}
