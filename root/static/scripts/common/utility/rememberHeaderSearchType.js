/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {localStorage} from './storage.js';

export const HEADER_SEARCH_TYPE_KEY = 'headerSearchType';

/*
 * Makes the header search keep the type last picked in it, rather than
 * going back to the first option on every page (MBS-13664). A saved type
 * that is no longer an option (e.g. "Documentation" where the search is
 * not configured) is ignored.
 */
export default function rememberHeaderSearchType(
  select: HTMLSelectElement,
): void {
  const saved = localStorage(HEADER_SEARCH_TYPE_KEY);
  if (
    saved != null &&
    Array.from(select.options).some((option) => option.value === saved)
  ) {
    select.value = saved;
  }
  select.addEventListener('change', () => {
    localStorage(HEADER_SEARCH_TYPE_KEY, select.value);
  });
}
