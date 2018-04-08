/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {parse} from 'cookie';

const hasOwnProperty = Object.prototype.hasOwnProperty;

export default function parseCookie(
  cookie: mixed,
  name: string,
  defaultValue: mixed = undefined,
) {
  if (typeof cookie === 'string') {
    const values = parse(cookie);
    if (hasOwnProperty.call(values, name)) {
      return values[name];
    }
  }
  return defaultValue;
}
