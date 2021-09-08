/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  FAVICON_CLASSES,
} from '../../static/scripts/common/constants';

import isUrlValid from './isUrlValid';

export default function getFaviconClass(url: string): string | null {
  let faviconClass = null;

  if (isUrlValid(url)) {
    const urlObject = new URL(url);

    for (const key of Object.keys(FAVICON_CLASSES)) {
      const constraints = FAVICON_CLASSES[key];
      const hostMatch = urlObject.hostname.match(constraints.host);
      const pathMatch = constraints.path
        ? urlObject.pathname.match(constraints.path)
        : true;
      if (hostMatch && pathMatch) {
        faviconClass = key + '-favicon';
        break;
      }
    }
    faviconClass = faviconClass ?? 'no-favicon';
  }

  return faviconClass;
}
