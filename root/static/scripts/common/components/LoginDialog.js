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

import Modal from './Modal.js';

component LoginDialog(
  close: () => void,
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
    <Modal
      className="iframe-dialog"
      id="login-dialog"
      onEscape={close}
      title={lp('Log in', 'header')}
    >
      <iframe src="/login?returnto=/login-dialog-success" />
    </Modal>
  );
}

export default LoginDialog;
