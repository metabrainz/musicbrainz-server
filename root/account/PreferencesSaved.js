/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../context';
import StatusPage from '../components/StatusPage';

type Props = {
  +$c: CatalystContextT | SanitizedCatalystContextT,
};

const PreferencesSaved = ({$c}: Props) => (
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

export default withCatalystContext(PreferencesSaved);
