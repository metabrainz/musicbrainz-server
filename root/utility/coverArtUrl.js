/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

function amazonHttps(url) {
  return url.replace(/http:\/\/ec[x4]\.images-amazon\.com\//,
    'https://images-na.ssl-images-amazon.com/');
}

function genericHttps(url) {
  // list only those sites that support https
  return url.replace(
    /http:\/\/(www\.ozon\.ru|(?:[^.\/]+\.)?archive\.org)\//,
    'https://$1/',
  );
}

export default function coverArtUrl($c: CatalystContextT, url: string) {
  if ($c.req.secure) {
    return amazonHttps(genericHttps(url));
  }
  return url;
}
