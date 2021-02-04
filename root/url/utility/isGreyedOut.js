/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const MALWARE_URLS = [
  'decoda.com',
  'starzik.com',
].map(host => new RegExp('^https?://([^/]+\\.)?' + host + '/.+', 'i'));

export function isMalware(
  url: string,
): boolean {
  return MALWARE_URLS.some(function (malwareRegex) {
    return url.match(malwareRegex) !== null;
  });
}

export default function isGreyedOut(
  url: string,
): boolean {
  return isMalware(url);
}
