/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {hyphenateTitle, l} from '../static/scripts/common/i18n';
import StatusPage from '../components/StatusPage';

type Props = {|
  +contactURL: string,
|};

const LostUsernameSent = ({contactURL}: Props) => (
  <StatusPage title={hyphenateTitle(l('Lost Username'), l('Email Sent!'))}>
    <p>
      {l('We\'ve sent you information about your MusicBrainz account. If you don\'t receive this email or still have problems logging in, please {link|contact us}.',
        {__react: true, link: contactURL})}
    </p>
  </StatusPage>
);

export default LostUsernameSent;
