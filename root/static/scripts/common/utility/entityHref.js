/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const {ENTITIES} = require('../constants');
const nonEmpty = require('./nonEmpty');

const leadingSlash = /^\/?(.*)/;

function entityHref(
  entityType: $Keys<ENTITIES>,
  id: number | string,
  subPath?: string,
) {
  let href = '/' + ENTITIES[entityType].url + '/' +
    encodeURIComponent(String(id));

  if (nonEmpty(subPath)) {
    subPath = subPath.replace(leadingSlash, '$1');
    if (subPath) {
      href += '/' + subPath;
    }
  }

  return href;
}

module.exports = entityHref;
