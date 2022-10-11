/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import StatusPage from '../components/StatusPage.js';
import {SanitizedCatalystContext} from '../context.mjs';

const PreferencesSaved = (): React.Element<typeof StatusPage> => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <StatusPage title={l('Preferences')}>
      <p>
        {exp.l(
          `Your preferences have been saved. Click {link|here} to
           continue to your user page.`,
          {
            link: $c.user
              ? '/user/' + encodeURIComponent($c.user.name)
              : '/register',
          },
        )}
      </p>
    </StatusPage>
  );
};

export default PreferencesSaved;
