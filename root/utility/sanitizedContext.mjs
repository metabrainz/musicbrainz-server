/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import activeSanitizedEditor from './activeSanitizedEditor.mjs';

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
  const req = $c.req;
  return {
    action: {
      name: $c.action.name,
    },
    relative_uri: $c.relative_uri,
    req: {
      method: req.method,
      query_params: req.query_params,
      uri: req.uri,
    },
    session: session ? {
      ...(session.tport == null ? null : {tport: session.tport}),
    } : null,
    stash: {
      artist_credit: stash.artist_credit,
      artist_credit_field: stash.artist_credit_field,
      current_isrcs: stash.current_isrcs,
      current_iswcs: stash.current_iswcs,
      current_language: stash.current_language,
      mtcaptcha_script_nonce: stash.mtcaptcha_script_nonce,
      seeded_relationships: stash.seeded_relationships,
      series_ordering_types: stash.series_ordering_types,
      server_languages: stash.server_languages,
      source_entity: stash.source_entity,
    },
    user: user ? activeSanitizedEditor(user) : null,
  };
}
