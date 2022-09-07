/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// For shortener pages which should still be allowed as a host-only link
const SHORTENER_ALLOWED_HOSTS = [
  'bruit.app',
  'distrokid.com',
  'trac.co',
];

const URL_SHORTENERS = [
  'adf.ly',
  'album.link',
  'ampl.ink',
  'amu.se',
  'artist.link',
  'band.link',
  'bfan.link',
  'biglink.to',
  'bio.link',
  'bit.ly',
  'bitly.com',
  'backl.ink',
  'bruit.app',
  'bstlnk.to',
  'cli.gs',
  'deck.ly',
  'distrokid.com',
  'ditto.fm',
  'eventlink.to',
  'fanlink.to',
  'ffm.to',
  'found.ee',
  'fty.li',
  'fur.ly',
  'g.co',
  'gate.fm',
  'geni.us',
  'goo.gl',
  'hypeddit.com',
  'hypel.ink',
  'hyperfollow.com',
  'hyperurl.co',
  'is.gd',
  'kl.am',
  'laburbain.com',
  'li.sten.to',
  'linkco.re',
  'lnkfi.re',
  'linkfly.to',
  'linktr.ee',
  'listen.lt',
  'lnk.bio',
  'lnk.co',
  'lnk.site',
  'lnk.to',
  'lsnto.me',
  'many.link',
  'mcaf.ee',
  'mez.ink',
  'moourl.com',
  'music.indiefy.net',
  'musics.link',
  'mylink.page',
  'myurls.bio',
  'odesli.co',
  'orcd.co',
  'owl.ly',
  'page.link',
  'pandora.app.link',
  'podlink.to',
  'pods.link',
  'push.fm',
  'rb.gy',
  'rubyurl.com',
  'share.amuse.io',
  'smarturl.it',
  'snd.click',
  'song.link',
  'songwhip.com',
  'spinnup.link',
  'spoti.fi',
  'sptfy.com',
  'spread.link',
  'streamerlinks.com',
  'streamlink.to',
  'su.pr',
  't.co',
  'tiny.cc',
  'tinyurl.com',
  'tourlink.to',
  'trac.co',
  'u.nu',
  'unitedmasters.com',
  'untd.io',
  'vyd.co',
  'yep.it',
].map(shortener => new RegExp(
  '^https?://([^/]+\\.)?' +
  shortener +
  (SHORTENER_ALLOWED_HOSTS.includes(shortener) ? '/.+' : ''),
  'i',
));

export default function isShortenedUrl(url: string): boolean {
  return URL_SHORTENERS.some(function (shortenerRegex) {
    return url.match(shortenerRegex) !== null;
  });
}
