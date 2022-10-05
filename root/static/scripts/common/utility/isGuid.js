/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {MBID_REGEXP} from '../constants.js';

const MBID_ONLY_REGEXP = new RegExp('^' + MBID_REGEXP.source + '$');

export default function isGuid(str: string): boolean {
  return str.length === 36 && MBID_ONLY_REGEXP.test(str);
}
