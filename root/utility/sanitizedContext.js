/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import sanitizedEditor from './sanitizedEditor';

/*
 * Returns a sanitized $c, with private or sensitive data removed, suitable
 * for embedding into server-generated markup.
 */
export default function sanitizedContext(
  $c: CatalystContextT,
): SanitizedCatalystContextT {
  const user = $c.user;
  return {
    user: user ? sanitizedEditor(user) : null,
    user_exists: $c.user_exists,
  };
};
