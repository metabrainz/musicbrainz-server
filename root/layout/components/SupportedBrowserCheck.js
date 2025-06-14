/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';

component SupportedBrowserCheck() {
  const $c = React.useContext(CatalystContext);

  const hideWarning = (
    $c.stash.legacy_browser === true ||
    // supported-browser-check.js requires `eval`.
    $c.stash.has_content_security_policy === true
  );

  return hideWarning ? null : (
    <>
      <div
        className="warning"
        id="unsupported-browser"
        style={{display: 'none'}}
      >
        <p>
          {exp.l(
            `The browser you’re using is unsupported, and the website may
             not work correctly for you.
             It’s recommended that you upgrade to a recent version of
             Firefox, Safari, Edge, or any Chrome-based browser.
             If that’s not possible, you can try enabling
             {url|legacy browser mode}.`,
            {
              url: '/toggle-legacy-browser?returnto=' +
                encodeURIComponent($c.req.uri),
            },
          )}
        </p>
      </div>
      <script src="/static/scripts/supported-browser-check.js" />
    </>
  );
}

export default SupportedBrowserCheck;
