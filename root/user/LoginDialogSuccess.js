/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {WEB_SERVER} from '../static/scripts/common/DBDefs.mjs';

component LoginDialogSuccess() {
  return (
    <html>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              if (window.parent !== window) {
                window.parent.postMessage(
                  'mb-login-dialog-success',
                  window.location.protocol + '//' +
                    ${JSON.stringify(WEB_SERVER)},
                );
              }
            `,
          }}
        />
      </head>
      <body>
        <p>{l('Login successful. You may close this dialog.')}</p>
      </body>
    </html>
  );
}

export default LoginDialogSuccess;
