/*
 * @flow strict
 * Copyright (C) 2014-2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import parseIntegerOrNull from './parseIntegerOrNull.js';

const dateRegex = /^(\d{4}|\?{4}|-)(?:-(\d{2}|\?{2}|-)(?:-(\d{2}|\?{2}|-))?)?$/;

function parseDate(str: string): PartialDateT {
  const match = str.match(dateRegex) || [];
  return {
    year: parseIntegerOrNull(match[1]),
    month: parseIntegerOrNull(match[2]),
    day: parseIntegerOrNull(match[3]),
  };
}

export default parseDate;
