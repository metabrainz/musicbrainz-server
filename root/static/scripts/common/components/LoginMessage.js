/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {WEB_SERVER} from '../DBDefs-client.mjs';

component LoginMessage(
  success: () => void,
) {
  React.useEffect(() => {
    const expectedOrigin = window.location.protocol + '//' + WEB_SERVER;
    const handleMessage = (event: MessageEvent) => {
      if (
        event.data === 'mb-login-dialog-success' &&
        event.origin === expectedOrigin
      ) {
        success();
      }
    };
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, [success]);

  return (
    <div className="row no-label">
      <p className="error">
        {l(`We’re currently unable to process your submission
            because your login session has expired.`)}
        {' '}
        <a
          href="/login?returnto=/login-dialog-success"
          onClick={(event) => {
            event.preventDefault();
            window.open(
              event.currentTarget.href,
              'musicbrainz-login',
              'popup,width=800,height=600',
            );
          }}
        >
          {l('Click here to log in.')}
        </a>
      </p>
    </div>
  );
}

export default LoginMessage;
