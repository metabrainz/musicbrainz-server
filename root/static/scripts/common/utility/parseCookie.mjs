/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * NOTE: This is used by root/server.mjs.
 * Don't use any magic variables (like `hasOwnProp`) from the ProvidePlugin.
 */

import {parse} from 'cookie';

// $FlowIgnore[method-unbinding]
const hasOwnProperty = Object.prototype.hasOwnProperty;

export default function parseCookie(
  cookie /*: mixed */,
  name /*: string */,
  defaultValue /*: string */ = '',
) /*: string */ {
  if (typeof cookie === 'string') {
    const values = parse(cookie);
    if (hasOwnProperty.call(values, name)) {
      return values[name];
    }
  }
  return defaultValue;
}
