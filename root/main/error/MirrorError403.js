/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ErrorLayout from './ErrorLayout.js';

component MirrorError403() {
  return (
    <ErrorLayout title={l('Forbidden request')}>
      <p>
        <strong>
          {l(`Sorry, you are unable to perform that action
              on a mirror server.`)}
        </strong>
      </p>

      <p>
        {exp.l(
          `In order to log in or make changes to the database
           you must visit the main server at {mb|https://musicbrainz.org/}.`,
          {mb: {className: 'external', href: 'https://musicbrainz.org/'}},
        )}
      </p>
    </ErrorLayout>
  );
}

export default MirrorError403;
