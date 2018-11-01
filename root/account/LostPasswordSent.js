/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {CONTACT_URL} from '../constants';
import {hyphenateTitle, l} from '../static/scripts/common/i18n';
import StatusPage from '../components/StatusPage';

const LostPasswordSent = () => (
  <StatusPage title={hyphenateTitle(l('Lost Password'), l('Email Sent!'))}>
    <p>
      {l('We\'ve sent you instructions on how to reset your password. If you don\'t receive this email or still have problems logging in, please {link|contact us}.',
        {__react: true, link: CONTACT_URL})}
    </p>
  </StatusPage>
);

export default LostPasswordSent;
