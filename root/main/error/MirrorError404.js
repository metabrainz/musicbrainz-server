/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ErrorLayout from './ErrorLayout';

const MirrorError404 = (): React.Element<typeof ErrorLayout> => (
  <ErrorLayout title={l('Page Not Found')}>
    <p>
      <strong>
        {l(`Sorry, the page you're looking for
            is not available on a mirror server.`)}
      </strong>
    </p>

    <p>
      {exp.l(
        `In order to view this page, please visit the main server
         at {mb|https://musicbrainz.org/}.`,
        {mb: {className: 'external', href: 'https://musicbrainz.org/'}},
      )}
    </p>
  </ErrorLayout>
);

export default MirrorError404;
