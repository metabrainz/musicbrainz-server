/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// eslint-disable-next-line import/enforce-node-protocol-usage
import {toUnicode} from 'punycode';

import isValidURL from './isValidURL.js';

export default function getUnicodeUrl(url: string): string {
  if (!isValidURL(url)) {
    return url;
  }

  const urlObject = new URL(url);
  const unicodeHostname = toUnicode(urlObject.hostname);
  const unicodeUrl = url.replace(urlObject.hostname, unicodeHostname);

  return unicodeUrl;
}
