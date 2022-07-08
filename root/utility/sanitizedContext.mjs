/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import activeSanitizedEditor from './activeSanitizedEditor.js';

/*
 * Returns a sanitized $c, with private or sensitive data removed, suitable
 * for embedding into server-generated markup.
 */
export default function sanitizedContext(
  $c: CatalystContextT,
): SanitizedCatalystContextT {
  const session = $c.session;
  const stash = $c.stash;
  const user = $c.user;
  return {
    action: {
      name: $c.action.name,
    },
    relative_uri: $c.relative_uri,
    req: {
      uri: $c.req.uri,
    },
    session: session ? {
      ...(session.tport == null ? null : {tport: session.tport}),
    } : null,
    stash: {
      current_language: stash.current_language,
    },
    user: user ? activeSanitizedEditor(user) : null,
  };
}
