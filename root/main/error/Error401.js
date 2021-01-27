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

type Props = {
  +$c: CatalystContextT,
};

const Error401 = ({
  $c,
}: Props): React.Element<typeof ErrorLayout> => (
  <ErrorLayout $c={$c} title={l('Unauthorized Request')}>
    <p>
      <strong>
        {l('Sorry, you are not authorized to view this page.')}
      </strong>
    </p>

    {$c.user && !$c.user.has_confirmed_email_address ? (
      <p>
        {exp.l(
          `You must first {url|add and verify your email address} before
           being able to edit or add anything to the database.`,
          {url: '/account/edit'},
        )}
      </p>
    ) : null}

    <p>
      {exp.l(
        `If you think this is a mistake, please contact
         <code>support@musicbrainz.org</code>
         with the name of your account.`,
      )}
    </p>
  </ErrorLayout>
);

export default Error401;
