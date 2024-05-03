/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import StatusPage from '../components/StatusPage.js';

component ResetPasswordStatus(message: string) {
  return (
    <StatusPage title={lp('Reset password', 'header')}>
      <p>{message}</p>
    </StatusPage>
  );
}

export default ResetPasswordStatus;
