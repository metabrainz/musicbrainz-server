/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import escapeRegExp from '../../common/utility/escapeRegExp.mjs';

// For aggregator pages which should still be allowed as a host-only link
const AGGREGATOR_ALLOWED_HOSTS = [
  'bruit.app',
  'distrokid.com',
  'trac.co',
];

const URL_AGGREGATORS = [
  'album.link',
  'allmylinks.com',
  'ampl.ink',
  'amu.se',
  'artist.link',
  'band.link',
  'bfan.link',
  'biglink.to',
  'bio.link',
  'backl.ink',
  'bruit.app',
  'bstlnk.to',
  'distrokid.com',
  'ditto.fm',
  'drum.io',
  'eventlink.to',
  'fanlink.to',
  'ffm.bio',
  'ffm.to',
  'found.ee',
  'frontl.ink',
  'fty.li',
  'fur.ly',
  'gate.fm',
  'gyro.to',
  'hypeddit.com',
  'hypel.ink',
  'hyperfollow.com',
  'hyperurl.co',
  'koji.game',
  'koji.sh',
  'laburbain.com',
  'li.sten.to',
  'linkco.re',
  'lnkfi.re',
  'linkfly.to',
  'linktr.ee',
  'listen.lt',
  'lnk.bio',
  'lnk.site',
  'lnk.to',
  'lsnto.me',
  'many.link',
  'mez.ink',
  'music.indiefy.net',
  'musics.link',
  'mylink.page',
  'myurls.bio',
  'odesli.co',
  'onerpm.link',
  'orcd.co',
  'podlink.to',
  'pods.link',
  'push.fm',
  'share.amuse.io',
  'smarturl.it',
  'snd.click',
  'song.link',
  'songwhip.com',
  'spinnup.link',
  'spread.link',
  'streamerlinks.com',
  'streamlink.to',
  'strm.to',
  'tourlink.to',
  'trac.co',
  'unitedmasters.com',
  'untd.io',
  'vyd.co',
  'withkoji.com',
].map(aggregator => new RegExp(
  '^https?://([^/]+\\.)?' +
  escapeRegExp(aggregator) +
  (AGGREGATOR_ALLOWED_HOSTS.includes(aggregator) ? '/.+' : '(?:/.*)?$'),
  'i',
));

export default function isLinkAggregator(url: string): boolean {
  return URL_AGGREGATORS.some(function (aggregatorRegex) {
    return url.match(aggregatorRegex) !== null;
  });
}
