/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import StatusPage from '../components/StatusPage.js';

type Props = {
  +message?: string,
};

const EmailVerificationStatus = ({
  message,
}: Props): React$Element<typeof StatusPage> => (
  <StatusPage title={l('Email Verification')}>
    <p>
      {nonEmpty(message)
        ? message
        : l(`Thank you, your email address has now been verified! If you still
             can't edit, please try to log out and log in again.`)
      }
    </p>
  </StatusPage>
);

export default EmailVerificationStatus;
