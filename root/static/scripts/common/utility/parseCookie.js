/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * NOTE: Don't convert to an ES module; this is used by root/server.js.
 * Don't use any magic variables (like `hasOwnProp`) from the ProvidePlugin
 * either.
 */
/* eslint-disable import/no-commonjs */

const {parse} = require('cookie');

// $FlowIgnore[method-unbinding]
const hasOwnProperty = Object.prototype.hasOwnProperty;

function parseCookie(
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

module.exports = parseCookie;
