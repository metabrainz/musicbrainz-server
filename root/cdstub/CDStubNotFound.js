/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import StatusPage from '../components/StatusPage.js';

type Props = {
  +discId: string,
};

const CDStubNotFound = ({
  discId,
}: Props): React.Element<typeof StatusPage> => (
  <StatusPage title={l('CD Stub Not Found')}>
    <p>
      {exp.l(
        `Sorry, <code>{discid}</code> does not match a CD stub.
         You can try {search_url|searching for it} instead.`,
        {
          discid: discId,
          search_url: '/search',
        },
      )}
    </p>
  </StatusPage>
);

export default CDStubNotFound;
