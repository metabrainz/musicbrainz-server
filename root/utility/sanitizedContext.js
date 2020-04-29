/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// NOTE: Don't convert to an ES module; this is used by root/server.js.
/* eslint-disable import/no-commonjs */

const sanitizedEditor = require('./sanitizedEditor');

/*
 * Returns a sanitized $c, with private or sensitive data removed, suitable
 * for embedding into server-generated markup.
 */
function sanitizedContext(
  $c /*: CatalystContextT */,
) /*: SanitizedCatalystContextT */ {
  const stash = $c.stash;
  const user = $c.user;
  return {
    action: {
      name: $c.action.name,
    },
    req: {
      uri: $c.req.uri,
    },
    stash: {
      csrf_token: stash.csrf_token,
      current_language: stash.current_language,
      genre_map: stash.genre_map,
      invalid_csrf_token: stash.invalid_csrf_token,
    },
    user: user ? sanitizedEditor(user) : null,
  };
}

module.exports = sanitizedContext;
