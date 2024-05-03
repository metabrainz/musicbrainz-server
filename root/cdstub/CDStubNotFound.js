/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import StatusPage from '../components/StatusPage.js';

component CDStubNotFound(discId: string) {
  return (
    <StatusPage title={l('CD stub not found')}>
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
}

export default CDStubNotFound;
