/*
 * @flow strict-local
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as URLCleanup from '../../edit/URLCleanup.js';

export default function cleanupUrl(url: string): string {
  let result = url;
  // URLCleanup requires a scheme in order the parse the URL.
  if (url.match(/^\w+\./)) {
    result = 'http://' + url;
  }
  return URLCleanup.cleanURL(result) || result;
}
