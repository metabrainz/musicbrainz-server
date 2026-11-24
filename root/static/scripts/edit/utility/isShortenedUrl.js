/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import escapeRegExp from '../../common/utility/escapeRegExp.mjs';

const URL_SHORTENERS = [
  'adf.ly',
  'bit.ly',
  'bitly.com',
  'cli.gs',
  'deck.ly',
  'g.co',
  'geni.us',
  'goo.gl',
  'is.gd',
  'kl.am',
  'lnk.co',
  'mcaf.ee',
  'moourl.com',
  'owl.ly',
  'page.link',
  'pandora.app.link',
  'rb.gy',
  'rubyurl.com',
  'share.google',
  'spoti.fi',
  'sptfy.com',
  'su.pr',
  't.co',
  'tiny.cc',
  'tinyurl.com',
  'u.nu',
  'yep.it',
].map(shortener => new RegExp(
  '^https?://([^/]+\\.)?' +
  escapeRegExp(shortener) +
  '(?:/.*)?$',
  'i',
));

export default function isShortenedUrl(url: string): boolean {
  return URL_SHORTENERS.some(function (shortenerRegex) {
    return url.match(shortenerRegex) !== null;
  });
}
