/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import rememberHeaderSearchType
  from './utility/rememberHeaderSearchType.js';

const select = document.getElementById('headerid-type');
if (select instanceof HTMLSelectElement) {
  rememberHeaderSearchType(select);
}
