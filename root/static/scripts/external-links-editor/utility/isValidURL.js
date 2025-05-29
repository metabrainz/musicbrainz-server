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

const protocolRegex = /^(https?|ftp):$/;
const hostnameRegex = /^(([A-z\d]|[A-z\d][A-z\d-]*[A-z\d])\.)*([A-z\d]|[A-z\d][A-z\d-]*[A-z\d])$/;

export default function isValidURL(url: string): boolean {
  const a = document.createElement('a');
  a.href = url;

  const hostname = a.hostname;

  // To compare with the url we need to decode the Punycode if present
  const unicodeHostname = toUnicode(hostname);
  if (url.indexOf(hostname) < 0 && url.indexOf(unicodeHostname) < 0) {
    return false;
  }

  if (!hostnameRegex.test(hostname)) {
    return false;
  }

  if (hostname.indexOf('.') < 0) {
    return false;
  }

  /*
   * Check if protocol string is in URL and is valid
   * Protocol of URL like "//google.com" is inferred as "https:"
   * but the URL is invalid
   */
  if (!url.startsWith(a.protocol) || !protocolRegex.test(a.protocol)) {
    return false;
  }

  return true;
}
