/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../context.mjs';
import {
  BETA_REDIRECT_HOSTNAME,
  IS_BETA,
} from '../../static/scripts/common/DBDefs.mjs';

component BetaOnlyEdit(edit: EditT) {
  const $c = React.useContext(SanitizedCatalystContext);
  const editId = edit.id;
  if (
    !IS_BETA &&
    nonEmpty(BETA_REDIRECT_HOSTNAME) &&
    editId != null
  ) {
    const betaUri = new URL($c.req.uri);
    betaUri.host = BETA_REDIRECT_HOSTNAME;
    betaUri.pathname = '/edit/' + encodeURIComponent(String(editId));
    betaUri.search = '';
    return (
      <p>
        {exp.l(
          `This edit can currently only be viewed on the
           {beta|beta server}.`,
          {
            beta: {
              href: betaUri.toString(),
              target: '_blank',
            },
          },
        )}
      </p>
    );
  }
  return (
    /*
     * This shouldn't happen except in development or if a
     * misconfiguration exists.
     */
    <p>
      {'This edit cannot currently be displayed.'}
    </p>
  );
}

export default BetaOnlyEdit;
