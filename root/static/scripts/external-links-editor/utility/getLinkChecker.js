/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {Checker as URLCleanupChecker} from '../../edit/URLCleanup.js';
import type {
  LinkStateT,
} from '../types.js';

const linkCheckerCache:
  WeakMap<LinkStateT, URLCleanupChecker> = new WeakMap();

export default function getLinkChecker(
  sourceType: RelatableEntityTypeT,
  link: LinkStateT,
): URLCleanupChecker {
  let checker = linkCheckerCache.get(link);
  if (!checker) {
    checker = new URLCleanupChecker(link.url, sourceType);
    linkCheckerCache.set(link, checker);
  }
  return checker;
}
