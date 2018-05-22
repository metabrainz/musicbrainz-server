/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const url = require('url');

export default function uriWith(
  uriString: string,
  params: {[string]: mixed},
) {
  const u = url.parse(uriString, true);

  u.query = Object.assign(u.query, params);
  u.search = undefined;

  return url.format(u);
}
