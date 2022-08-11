/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import StatusPage from '../components/StatusPage.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';

type Props = {
  +message: string,
  +title: string,
};

const UserMessage = ({
  message,
  title,
}: Props): React.Element<typeof StatusPage> => (
  <StatusPage title={title}>
    <p>{expand2react(message)}</p>
  </StatusPage>
);

export default UserMessage;
