/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {LinkStateT} from '../types.js';

import getLinkChecker from './getLinkChecker.js';

export default function doesUrlMatchOnlyOnePossibleType(
  sourceType: RelatableEntityTypeT,
  link: LinkStateT,
): boolean {
  return getLinkChecker(sourceType, link).possibleTypes.length === 1;
}
